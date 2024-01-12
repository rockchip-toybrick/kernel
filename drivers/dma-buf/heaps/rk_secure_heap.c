// SPDX-License-Identifier: GPL-2.0
/*
 * DMABUF SECURE heap exporter
 *
 * Copyright (C) 2012, 2019, 2020 Linaro Ltd.
 * Author: <benjamin.gaignard@linaro.org> for ST-Ericsson.
 *
 * Also utilizing parts of Andrew Davis' SRAM heap:
 * Copyright (C) 2019 Texas Instruments Incorporated - http://www.ti.com/
 *	Andrew F. Davis <afd@ti.com>
 *
 * Copyright (C) 2021, 2022 Rockchip Electronics Co. Ltd.
 */

#include <linux/cma.h>
#include <linux/dma-buf.h>
#include <linux/dma-heap.h>
#include <linux/dma-map-ops.h>
#include <linux/err.h>
#include <linux/highmem.h>
#include <linux/io.h>
#include <linux/mm.h>
#include <linux/module.h>
#include <linux/scatterlist.h>
#include <linux/slab.h>
#include <linux/vmalloc.h>
#include <uapi/linux/dma-heap.h>
#include <linux/of_reserved_mem.h>

struct secure_heap_buffer {
	struct secure_heap *heap;
	struct list_head attachments;
	struct mutex lock;
	unsigned long len;
	phys_addr_t phys_addr;
	struct page **pages;
	pgoff_t pagecount;
	int vmap_cnt;
	void *vaddr;
	bool attached;
	bool uncached;
};

struct secure_heap_attachment {
	struct device *dev;
	struct sg_table table;
	struct list_head list;
	bool mapped;
	bool uncached;
};

struct dma_secure_mem {
	void		*virt_base;
	unsigned long	pfn_base;
	int		page_counts;
	unsigned long	*bitmap;
	spinlock_t	spinlock;
};

struct secure_heap {
	struct dma_heap *heap;
	struct dma_secure_mem *sec_mem;
};

static unsigned long secure_base;
static unsigned long secure_size;

static int secure_heap_attach(struct dma_buf *dmabuf,
			   struct dma_buf_attachment *attachment)
{
	struct secure_heap_buffer *buffer = dmabuf->priv;
	struct secure_heap_attachment *a;
	struct sg_table *table;
	size_t size = buffer->pagecount << PAGE_SHIFT;
	int ret;

	a = kzalloc(sizeof(*a), GFP_KERNEL);
	if (!a)
		return -ENOMEM;

	table = &a->table;

	ret = sg_alloc_table(table, 1, GFP_KERNEL);
	if (ret) {
		kfree(a);
		return ret;
	}
	sg_set_page(table->sgl, phys_to_page(buffer->phys_addr), PAGE_ALIGN(size), 0);

	a->dev = attachment->dev;
	INIT_LIST_HEAD(&a->list);
	a->mapped = false;

	a->uncached = buffer->uncached;

	attachment->priv = a;

	buffer->attached = true;

	mutex_lock(&buffer->lock);
	list_add(&a->list, &buffer->attachments);
	mutex_unlock(&buffer->lock);

	return 0;

}

static void secure_heap_detach(struct dma_buf *dmabuf,
			    struct dma_buf_attachment *attachment)
{
	struct secure_heap_buffer *buffer = dmabuf->priv;
	struct secure_heap_attachment *a = attachment->priv;

	mutex_lock(&buffer->lock);
	list_del(&a->list);
	mutex_unlock(&buffer->lock);

	buffer->attached = false;

	sg_free_table(&a->table);
	kfree(a);
}

static struct sg_table *secure_heap_map_dma_buf(struct dma_buf_attachment *attachment,
					     enum dma_data_direction direction)
{
	struct secure_heap_attachment *a = attachment->priv;
	struct sg_table *table = &a->table;
	int ret;
	unsigned long attrs = attachment->dma_map_attrs;

	if (a->uncached)
		attrs |= DMA_ATTR_SKIP_CPU_SYNC;

	ret = dma_map_sgtable(attachment->dev, table, direction, attrs);
	if (ret)
		return ERR_PTR(-ENOMEM);
	a->mapped = true;

	return table;
}

static void secure_heap_unmap_dma_buf(struct dma_buf_attachment *attachment,
				   struct sg_table *table,
				   enum dma_data_direction direction)
{
	struct secure_heap_attachment *a = attachment->priv;
	unsigned long attrs = attachment->dma_map_attrs;

	a->mapped = false;

	if (a->uncached)
		attrs |= DMA_ATTR_SKIP_CPU_SYNC;

	dma_unmap_sgtable(attachment->dev, table, direction, attrs);

}

static int __maybe_unused
secure_heap_dma_buf_begin_cpu_access_partial(struct dma_buf *dmabuf,
					  enum dma_data_direction direction,
					  unsigned int offset,
					  unsigned int len)
{
	struct secure_heap_buffer *buffer = dmabuf->priv;
	struct secure_heap_attachment *a;

	if (buffer->vmap_cnt)
		invalidate_kernel_vmap_range(buffer->vaddr, buffer->len);

	if (buffer->uncached)
		return 0;

	mutex_lock(&buffer->lock);
	list_for_each_entry(a, &buffer->attachments, list) {
		if (!a->mapped)
			continue;
		dma_sync_sgtable_for_cpu(a->dev, &a->table, direction);
	}

	/* For userspace that not attach yet */
	if (buffer->phys_addr && !buffer->attached)
		dma_sync_single_for_cpu(dma_heap_get_dev(buffer->heap->heap),
					buffer->phys_addr + offset,
					len,
					direction);
	mutex_unlock(&buffer->lock);

	return 0;

}

static int __maybe_unused
secure_heap_dma_buf_end_cpu_access_partial(struct dma_buf *dmabuf,
					enum dma_data_direction direction,
					unsigned int offset,
					unsigned int len)
{
	struct secure_heap_buffer *buffer = dmabuf->priv;
	struct secure_heap_attachment *a;

	if (buffer->vmap_cnt)
		flush_kernel_vmap_range(buffer->vaddr, buffer->len);

	if (buffer->uncached)
		return 0;

	mutex_lock(&buffer->lock);
	list_for_each_entry(a, &buffer->attachments, list) {
		if (!a->mapped)
			continue;
		dma_sync_sgtable_for_device(a->dev, &a->table, direction);
	}

	/* For userspace that not attach yet */
	if (buffer->phys_addr && !buffer->attached)
		dma_sync_single_for_device(dma_heap_get_dev(buffer->heap->heap),
					   buffer->phys_addr + offset,
					   len,
					   direction);
	mutex_unlock(&buffer->lock);

	return 0;

}

static int secure_heap_dma_buf_begin_cpu_access(struct dma_buf *dmabuf,
					     enum dma_data_direction dir)
{
	struct secure_heap_buffer *buffer = dmabuf->priv;
	unsigned int len = buffer->pagecount * PAGE_SIZE;

	return secure_heap_dma_buf_begin_cpu_access_partial(dmabuf, dir, 0, len);

}

static int secure_heap_dma_buf_end_cpu_access(struct dma_buf *dmabuf,
					   enum dma_data_direction dir)
{
	struct secure_heap_buffer *buffer = dmabuf->priv;
	unsigned int len = buffer->pagecount * PAGE_SIZE;

	return secure_heap_dma_buf_end_cpu_access_partial(dmabuf, dir, 0, len);

}

static int secure_heap_mmap(struct dma_buf *dmabuf, struct vm_area_struct *vma)
{
	struct secure_heap_buffer *buffer = dmabuf->priv;
	size_t size = vma->vm_end - vma->vm_start;
	int ret;

	if (buffer->uncached)
		vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);

	ret = remap_pfn_range(vma, vma->vm_start, __phys_to_pfn(buffer->phys_addr),
			      size, vma->vm_page_prot);
	if (ret)
		return -EAGAIN;

	return 0;
}

static void *secure_heap_do_vmap(struct secure_heap_buffer *buffer)
{
	void *vaddr;
	pgprot_t pgprot = PAGE_KERNEL;

	if (buffer->uncached)
		pgprot = pgprot_writecombine(PAGE_KERNEL);

	vaddr = vmap(buffer->pages, buffer->pagecount, VM_MAP, pgprot);
	if (!vaddr)
		return ERR_PTR(-ENOMEM);

	return vaddr;
}

static void *secure_heap_vmap(struct dma_buf *dmabuf)
{
	struct secure_heap_buffer *buffer = dmabuf->priv;
	void *vaddr;

	mutex_lock(&buffer->lock);
	if (buffer->vmap_cnt) {
		buffer->vmap_cnt++;
		vaddr = buffer->vaddr;
		goto out;
	}

	vaddr = secure_heap_do_vmap(buffer);
	if (IS_ERR(vaddr))
		goto out;

	buffer->vaddr = vaddr;
	buffer->vmap_cnt++;
out:
	mutex_unlock(&buffer->lock);

	return vaddr;
}

static void secure_heap_vunmap(struct dma_buf *dmabuf, void *vaddr)
{
	struct secure_heap_buffer *buffer = dmabuf->priv;

	mutex_lock(&buffer->lock);
	if (!--buffer->vmap_cnt) {
		vunmap(buffer->vaddr);
		buffer->vaddr = NULL;
	}
	mutex_unlock(&buffer->lock);
}

static void secure_heap_dma_buf_release(struct dma_buf *dmabuf)
{
	struct secure_heap_buffer *buffer = dmabuf->priv;
	struct secure_heap *sec_heap = buffer->heap;
	unsigned long flags;

	spin_lock_irqsave(&sec_heap->sec_mem->spinlock, flags);
	bitmap_release_region(sec_heap->sec_mem->bitmap,
			      buffer->phys_addr >> PAGE_SHIFT,
			      get_order(buffer->len));
	spin_unlock_irqrestore(&sec_heap->sec_mem->spinlock, flags);
	kfree(buffer);
}

static const struct dma_buf_ops secure_heap_buf_ops = {
	.attach = secure_heap_attach,
	.detach = secure_heap_detach,
	.map_dma_buf = secure_heap_map_dma_buf,
	.unmap_dma_buf = secure_heap_unmap_dma_buf,
	.begin_cpu_access = secure_heap_dma_buf_begin_cpu_access,
	.end_cpu_access = secure_heap_dma_buf_end_cpu_access,
#ifdef CONFIG_DMABUF_PARTIAL
	.begin_cpu_access_partial = secure_heap_dma_buf_begin_cpu_access_partial,
	.end_cpu_access_partial = secure_heap_dma_buf_end_cpu_access_partial,
#endif
	.mmap = secure_heap_mmap,
	.vmap = secure_heap_vmap,
	.vunmap = secure_heap_vunmap,
	.release = secure_heap_dma_buf_release,
};

static struct dma_buf *secure_heap_allocate(struct dma_heap *heap,
					 unsigned long len,
					 unsigned long fd_flags,
					 unsigned long heap_flags)
{
	struct secure_heap *sec_heap = dma_heap_get_drvdata(heap);
	struct secure_heap_buffer *buffer;
	DEFINE_DMA_BUF_EXPORT_INFO(exp_info);
	size_t size = PAGE_ALIGN(len);
	struct dma_buf *dmabuf;
	unsigned long flags;
	int pageno;
	pgoff_t pg;
	dma_addr_t dma;

	buffer = kzalloc(sizeof(*buffer), GFP_KERNEL);
	if (!buffer)
		return ERR_PTR(-ENOMEM);

	INIT_LIST_HEAD(&buffer->attachments);
	mutex_init(&buffer->lock);
	buffer->len = size;

	spin_lock_irqsave(&sec_heap->sec_mem->spinlock, flags);

	pageno = bitmap_find_free_region(sec_heap->sec_mem->bitmap,
					 sec_heap->sec_mem->page_counts,
					 get_order(size));
	if (unlikely(pageno < 0)) {
		kfree(buffer);
		spin_unlock_irqrestore(&sec_heap->sec_mem->spinlock, flags);
		return ERR_PTR(-ENOMEM);
	}

	spin_unlock_irqrestore(&sec_heap->sec_mem->spinlock, flags);

	buffer->phys_addr = (sec_heap->sec_mem->pfn_base << PAGE_SHIFT) +
			    ((dma_addr_t)pageno << PAGE_SHIFT);
	buffer->heap = sec_heap;
	buffer->pagecount = size >> PAGE_SHIFT;

	buffer->pages = kmalloc_array(buffer->pagecount, sizeof(*buffer->pages),
				      GFP_KERNEL);
	if (!buffer->pages) {
		spin_lock_irqsave(&sec_heap->sec_mem->spinlock, flags);
		bitmap_release_region(sec_heap->sec_mem->bitmap,
			      buffer->phys_addr >> PAGE_SHIFT,
			      get_order(buffer->len));
		spin_unlock_irqrestore(&sec_heap->sec_mem->spinlock, flags);
		return ERR_PTR(-ENOMEM);
	}

	for (pg = 0; pg < buffer->pagecount; pg++)
		buffer->pages[pg] = phys_to_page(buffer->phys_addr + pg * PAGE_SIZE);

	/* create the dmabuf */
	exp_info.exp_name = dma_heap_get_name(heap);
	exp_info.ops = &secure_heap_buf_ops;
	exp_info.size = buffer->len;
	exp_info.flags = fd_flags;
	exp_info.priv = buffer;
	dmabuf = dma_buf_export(&exp_info);
	if (IS_ERR(dmabuf))
		kfree(buffer);

	buffer->uncached = true;

	if (buffer->uncached) {
		dma = dma_map_page(dma_heap_get_dev(heap), phys_to_page(buffer->phys_addr), 0,
			     buffer->pagecount * PAGE_SIZE, DMA_FROM_DEVICE);
		dma_unmap_page(dma_heap_get_dev(heap), dma,
			       buffer->pagecount * PAGE_SIZE, DMA_FROM_DEVICE);
	}

	return dmabuf;
}

#if IS_ENABLED(CONFIG_NO_GKI)
static int secure_heap_get_phys(struct dma_heap *heap,
			     struct dma_heap_phys_data *phys)
{
	struct secure_heap *sec_heap = dma_heap_get_drvdata(heap);
	struct secure_heap_buffer *buffer;
	struct dma_buf *dmabuf;

	if (IS_ERR_OR_NULL(phys))
		return -EINVAL;

	phys->paddr = (__u64)-1;

	dmabuf = dma_buf_get(phys->fd);
	if (IS_ERR_OR_NULL(dmabuf))
		return -EBADFD;

	buffer = dmabuf->priv;
	if (IS_ERR_OR_NULL(buffer))
		goto err;

	if (buffer->heap != sec_heap)
		goto err;

	phys->paddr = buffer->phys_addr;

err:
	dma_buf_put(dmabuf);

	return (phys->paddr == (__u64)-1) ? -EINVAL : 0;
}
#endif

static const struct dma_heap_ops secure_heap_ops = {
	.allocate = secure_heap_allocate,
#if IS_ENABLED(CONFIG_NO_GKI)
	.get_phys = secure_heap_get_phys,
#endif
};

static int set_heap_dev_dma(struct device *heap_dev)
{
	int err = 0;

	if (!heap_dev)
		return -EINVAL;

	dma_coerce_mask_and_coherent(heap_dev, DMA_BIT_MASK(64));

	if (!heap_dev->dma_parms) {
		heap_dev->dma_parms = devm_kzalloc(heap_dev,
						   sizeof(*heap_dev->dma_parms),
						   GFP_KERNEL);
		if (!heap_dev->dma_parms)
			return -ENOMEM;

		err = dma_set_max_seg_size(heap_dev, (unsigned int)DMA_BIT_MASK(64));
		if (err) {
			devm_kfree(heap_dev, heap_dev->dma_parms);
			dev_err(heap_dev, "Failed to set DMA segment size, err:%d\n", err);
			return err;
		}
	}

	return 0;
}

static struct dma_secure_mem *dma_init_secure_memory(phys_addr_t phys_addr, size_t size)
{
	struct dma_secure_mem *dma_sec_mem = NULL;
	int page_counts = size >> PAGE_SHIFT;
	int bitmap_size = BITS_TO_LONGS(page_counts) * sizeof(long);

	if (!size)
		return NULL;

	dma_sec_mem = kzalloc(sizeof(struct dma_secure_mem), GFP_KERNEL);
	if (!dma_sec_mem)
		return NULL;

	dma_sec_mem->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
	if (!dma_sec_mem->bitmap) {
		kfree(dma_sec_mem);
		return NULL;
	}

	dma_sec_mem->pfn_base = PFN_DOWN(phys_addr);
	dma_sec_mem->page_counts = page_counts;
	spin_lock_init(&dma_sec_mem->spinlock);

	return dma_sec_mem;
}

static void dma_release_secure_memory(struct dma_secure_mem *mem)
{
	if (!mem)
		return;

	kfree(mem->bitmap);
	kfree(mem);
}

static int add_secure_heap(void)
{
	struct secure_heap *sec_heap;
	struct dma_heap_export_info exp_info;
	int ret;

	sec_heap = kzalloc(sizeof(*sec_heap), GFP_KERNEL);
	if (!sec_heap)
		return -ENOMEM;

	exp_info.name = "secure";
	exp_info.ops = &secure_heap_ops;
	exp_info.priv = sec_heap;

	sec_heap->sec_mem = dma_init_secure_memory(secure_base, secure_size);
	if (!sec_heap->sec_mem) {
		pr_err("Failed to init secure dma\n");
		ret = -ENOMEM;
		goto free_sec_heap;
	}

	sec_heap->heap = dma_heap_add(&exp_info);
	if (IS_ERR(sec_heap->heap)) {
		ret = PTR_ERR(sec_heap->heap);
		goto free_sec_memory;
	}

	ret = set_heap_dev_dma(dma_heap_get_dev(sec_heap->heap));
	if (ret)
		goto put_sec_heap;

	mb(); /* make sure we only set allocate after dma_mask is set */

	pr_info("create SECURE DMA memory pool at 0x%lx, size %ld MiB\n",
		secure_base, secure_size / SZ_1M);

	return 0;

put_sec_heap:
	dma_heap_put(sec_heap->heap);
free_sec_memory:
	dma_release_secure_memory(sec_heap->sec_mem);
free_sec_heap:
	kfree(sec_heap);

	return ret;
}

static int secure_heap_create(void)
{
	int ret;

	ret = add_secure_heap();
	if (ret) {
		pr_err("Failed to add secure heap\n");
		return ret;
	}

	return 0;
}

module_init(secure_heap_create);
MODULE_LICENSE("GPL");
MODULE_IMPORT_NS(DMA_BUF);

static int __init rmem_secure_dma_setup(struct reserved_mem *rmem)
{
	secure_base = rmem->base;
	secure_size = rmem->size;

	return 0;
}

RESERVEDMEM_OF_DECLARE(dma, "secured-dma-pool", rmem_secure_dma_setup);

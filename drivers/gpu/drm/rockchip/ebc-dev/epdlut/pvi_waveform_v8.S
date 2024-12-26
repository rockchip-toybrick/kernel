// SPDX-License-Identifier: GPL-2.0
/*
 * Copyright (c) 2020-2024 Rockchip Electronics Co., Ltd.
 *
 * Author: Zorro Liu <zorro.liu@rock-chips.com>
 */

	.arch armv8-a
	.file	"pvi_waveform.c"
	.text
	.align	2
	.p2align 3,,7
	.type	get_wf_frm_num, %function
get_wf_frm_num:
	stp	x29, x30, [sp, -48]!
	lsl	w0, w0, 2
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	adrp	x20, .LANCHOR0
	str	x21, [sp, 32]
	ldr	x17, [x20, #:lo12:.LANCHOR0]
	ldrb	w2, [x17, 32]
	add	x0, x2, x0, sxtw
	add	x3, x17, x0
	ldrb	w2, [x17, x0]
	ldrb	w6, [x3, 1]
	ldrb	w5, [x3, 3]
	ldrb	w3, [x3, 2]
	add	w2, w2, w6
	add	w2, w2, w3
	cmp	w5, w2, uxtb
	bne	.L42
	ldr	w2, [x17, x0]
	lsl	w0, w1, 2
	and	x1, x2, 16777215
	add	x0, x1, x0, sxtw
	add	x2, x17, x0
	ldrb	w1, [x17, x0]
	ldrb	w5, [x2, 1]
	ldrb	w3, [x2, 3]
	ldrb	w2, [x2, 2]
	add	w1, w1, w5
	add	w1, w1, w2
	cmp	w3, w1, uxtb
	bne	.L43
	add	x4, x20, :lo12:.LANCHOR0
	ldr	w0, [x17, x0]
	and	x0, x0, 16777215
	ldr	x7, [x4, 8]
	add	x17, x17, x0
	cbz	x7, .L44
	adrp	x21, .LANCHOR2
	mov	w12, 0
	add	x0, x21, :lo12:.LANCHOR2
	ldr	w11, [x21, #:lo12:.LANCHOR2]
	cmp	w11, 16
	beq	.L45
.L6:
	add	w8, w12, 5
	mov	w9, 0
	mov	w1, 0
	mov	w6, 1
	mov	w16, 0
	mov	w19, 0
	.p2align 2
.L7:
	ldrb	w10, [x17, w16, uxtw]
	cmp	w10, 255
	beq	.L8
	cmp	w10, 252
	beq	.L46
.L9:
	lsl	w0, w19, 10
	lsl	w5, w1, w8
	add	w2, w5, w0
	lsl	w5, w9, w12
	add	w0, w0, w5
	add	w5, w2, w5
	add	w4, w1, 1
	add	w3, w1, 2
	add	w2, w1, 3
	and	w13, w10, 3
	strb	w13, [x7, w5, uxtw]
	lsl	w4, w4, w8
	lsl	w3, w3, w8
	add	w4, w4, w0
	add	w3, w3, w0
	lsl	w2, w2, w8
	add	w0, w2, w0
	cbz	w6, .L10
	ubfx	x14, x10, 2, 2
	strb	w14, [x7, w4, uxtw]
	ubfx	x15, x10, 4, 2
	strb	w15, [x7, w3, uxtw]
	lsr	w10, w10, 6
	strb	w10, [x7, w0, uxtw]
	add	w1, w1, 4
	add	w0, w16, 1
	cmp	w1, w11
	bcc	.L11
	add	w9, w9, 1
	mov	w1, 0
	cmp	w11, w9
	bhi	.L11
	add	w19, w19, 1
	mov	w9, 0
.L11:
	ldrb	w6, [x17, w0, uxtw]
	cbz	w6, .L12
	.p2align 2
.L14:
	lsl	w0, w19, 10
	lsl	w5, w1, w8
	add	w4, w1, 1
	add	w2, w5, w0
	add	w3, w1, 2
	lsl	w5, w9, w12
	add	w0, w0, w5
	add	w5, w2, w5
	lsl	w4, w4, w8
	add	w2, w1, 3
	add	w4, w4, w0
	lsl	w3, w3, w8
	add	w3, w3, w0
	strb	w13, [x7, w5, uxtw]
	lsl	w2, w2, w8
	add	w0, w2, w0
	strb	w14, [x7, w4, uxtw]
	add	w1, w1, 4
	strb	w15, [x7, w3, uxtw]
	sub	w6, w6, #1
	strb	w10, [x7, w0, uxtw]
	cmp	w11, w1
	bhi	.L13
	add	w9, w9, 1
	mov	w1, 0
	cmp	w11, w9
	bhi	.L13
	add	w19, w19, 1
	mov	w9, 0
.L13:
	ands	w6, w6, 255
	bne	.L14
.L12:
	add	w16, w16, 2
	mov	w6, 1
.L15:
	cmp	w19, 254
	bls	.L7
	adrp	x0, .LC2
	add	x0, x0, :lo12:.LC2
	bl	printk
.L8:
	ldr	w0, [x21, #:lo12:.LANCHOR2]
	add	x21, x21, :lo12:.LANCHOR2
	cmp	w0, 32
	beq	.L16
.L17:
	mov	w0, w19
.L1:
	ldp	x19, x20, [sp, 16]
	ldr	x21, [sp, 32]
	ldp	x29, x30, [sp], 48
	ret
	.p2align 3
.L10:
	ubfx	x2, x10, 2, 2
	strb	w2, [x7, w4, uxtw]
	ubfx	x2, x10, 4, 2
	strb	w2, [x7, w3, uxtw]
	lsr	w10, w10, 6
	strb	w10, [x7, w0, uxtw]
	add	w1, w1, 4
	add	w16, w16, 1
	cmp	w1, w11
	bcc	.L15
	add	w9, w9, 1
	mov	w1, 0
	cmp	w11, w9
	bhi	.L15
	add	w19, w19, 1
	mov	w9, 0
	mov	w1, w6
	b	.L15
	.p2align 3
.L46:
	add	w16, w16, 1
	eor	w6, w6, 1
	ldrb	w10, [x17, w16, uxtw]
	b	.L9
.L16:
	ldr	w0, [x21, 4]
	cmp	w0, 16
	bne	.L17
	cbz	w19, .L17
	add	x20, x20, :lo12:.LANCHOR0
	mov	w8, 0
	ldr	x1, [x20, 8]
.L22:
	lsl	w7, w8, 10
	mov	w6, 0
	mov	w5, w7
	.p2align 2
.L20:
	lsr	w4, w6, 1
	mov	w0, 0
	add	w4, w7, w4, lsl 5
	.p2align 2
.L19:
	add	w3, w0, w5
	add	w2, w4, w0, lsr 1
	add	w0, w0, 2
	cmp	w0, 32
	ldrb	w3, [x1, w3, uxtw]
	strb	w3, [x1, w2, uxtw]
	bne	.L19
	add	w6, w6, 2
	add	w5, w5, 64
	cmp	w6, 32
	bne	.L20
	add	w8, w8, 1
	and	w8, w8, 255
	cmp	w8, w19
	bcc	.L22
	b	.L17
.L45:
	ldr	w0, [x0, 4]
	cmp	w0, 32
	cset	w12, eq
	b	.L6
.L42:
	adrp	x1, .LANCHOR1
	adrp	x0, .LC0
	mov	w2, 256
	add	x1, x1, :lo12:.LANCHOR1
	add	x0, x0, :lo12:.LC0
	bl	printk
	mov	w0, -22
	b	.L1
.L44:
	adrp	x0, .LC1
	add	x0, x0, :lo12:.LC1
	bl	printk
	mov	w0, -22
	b	.L1
.L43:
	adrp	x1, .LANCHOR1
	adrp	x0, .LC0
	mov	w2, 263
	add	x1, x1, :lo12:.LANCHOR1
	add	x0, x0, :lo12:.LC0
	bl	printk
	mov	w0, -22
	b	.L1
	.size	get_wf_frm_num, .-get_wf_frm_num
	.align	2
	.p2align 3,,7
	.type	get_wf_mode_index, %function
get_wf_mode_index:
	cmp	w0, 14
	bhi	.L91
	mov	x1, 3
	cmp	w0, 10
	beq	.L50
	mov	x1, 6
	cmp	w0, 12
	beq	.L50
	mov	x1, 5
	cmp	w0, 11
	beq	.L50
	mov	x1, 4
	cmp	w0, 13
	beq	.L50
	uxtw	x1, w0
	cmp	w0, 14
	mov	x0, 3
	csel	x1, x1, x0, ne
.L50:
	adrp	x0, .LANCHOR0
	ldr	x2, [x0, #:lo12:.LANCHOR0]
	ldrb	w2, [x2, 16]
	cmp	w2, 32
	beq	.L52
	bls	.L92
	cmp	w2, 72
	beq	.L59
	bls	.L93
	cmp	w2, 84
	beq	.L62
	cmp	w2, 114
	bne	.L51
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 79
	ldrb	w0, [x0, x1]
	ret
	.p2align 3
.L92:
	cmp	w2, 22
	beq	.L54
	bhi	.L55
	cmp	w2, 9
	beq	.L56
	cmp	w2, 18
	bne	.L51
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 25
	ldrb	w0, [x0, x1]
	ret
	.p2align 3
.L56:
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 16
	ldrb	w0, [x0, x1]
	ret
	.p2align 3
.L62:
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 70
	ldrb	w0, [x0, x1]
	ret
	.p2align 3
.L93:
	cmp	w2, 35
	bne	.L94
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 52
	ldrb	w0, [x0, x1]
	ret
	.p2align 3
.L55:
	cmp	w2, 24
	beq	.L52
	cmp	w2, 25
	bne	.L51
.L58:
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 43
	ldrb	w0, [x0, x1]
	ret
	.p2align 3
.L94:
	cmp	w2, 67
	beq	.L58
.L51:
	add	x3, x0, :lo12:.LANCHOR0
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x3, x3, 16
	add	x0, x0, 88
	ldrb	w4, [x3, 9]
	cmp	w4, w2
	csel	x0, x0, x3, ne
	ldrb	w0, [x0, x1]
	ret
	.p2align 3
.L59:
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 61
	ldrb	w0, [x0, x1]
	ret
	.p2align 3
.L54:
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 34
	ldrb	w0, [x0, x1]
	ret
	.p2align 3
.L52:
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 88
	ldrb	w0, [x0, x1]
	ret
.L91:
	stp	x29, x30, [sp, -16]!
	adrp	x0, .LC3
	add	x0, x0, :lo12:.LC3
	add	x29, sp, 0
	bl	printk
	mov	w0, 255
	ldp	x29, x30, [sp], 16
	ret
	.size	get_wf_mode_index, .-get_wf_mode_index
	.align	2
	.p2align 3,,7
	.global	pvi_wf_add_custom_mode_table
	.type	pvi_wf_add_custom_mode_table, %function
pvi_wf_add_custom_mode_table:
	cmp	w1, 11
	bne	.L98
	adrp	x1, .LANCHOR0
	add	x1, x1, :lo12:.LANCHOR0
	add	x2, x1, 16
	ldr	x4, [x0, 2]
	ldrb	w3, [x0, 10]
	str	x4, [x1, 16]
	strb	w3, [x2, 8]
	ldrb	w1, [x0]
	strb	w1, [x2, 9]
	ldrb	w1, [x0, 1]
	cmp	w1, 4
	beq	.L100
	mov	w0, 0
	cmp	w1, 5
	beq	.L101
	ret
	.p2align 3
.L101:
	mov	w1, 32
	str	w1, [x2, 12]
	ret
	.p2align 3
.L100:
	mov	w1, 16
	mov	w0, 0
	str	w1, [x2, 12]
	ret
	.p2align 3
.L98:
	mov	w0, -1
	ret
	.size	pvi_wf_add_custom_mode_table, .-pvi_wf_add_custom_mode_table
	.align	2
	.p2align 3,,7
	.global	pvi_wf_get_lut
	.type	pvi_wf_get_lut, %function
pvi_wf_get_lut:
	stp	x29, x30, [sp, -80]!
	add	x29, sp, 0
	stp	x25, x26, [sp, 64]
	adrp	x25, .LANCHOR0
	stp	x19, x20, [sp, 16]
	ldr	x5, [x25, #:lo12:.LANCHOR0]
	stp	x21, x22, [sp, 32]
	stp	x23, x24, [sp, 48]
	cbz	x5, .L143
	cbz	x0, .L173
.L104:
	mov	w20, w2
	adrp	x21, .LANCHOR2
	add	x2, x21, :lo12:.LANCHOR2
	mov	w23, w1
	mov	x22, x0
	mov	w0, 21846
	movk	w0, 0x5555, lsl 16
	mov	w26, w4
	ldr	w1, [x2, 8]
	smull	x24, w20, w0
	smull	x0, w1, w0
	lsr	x24, x24, 32
	sub	w24, w24, w20, asr 31
	lsr	x0, x0, 32
	sub	w0, w0, w1, asr 31
	cmp	w24, w0
	beq	.L174
	str	w3, [x2, 4]
	cmp	w23, 10
	beq	.L140
.L139:
	add	x0, x25, :lo12:.LANCHOR0
	ldrb	w6, [x5, 38]
	ldr	x1, [x22, 16]
	str	x1, [x0, 8]
	cbz	w6, .L107
	ldrb	w0, [x5, 48]
	cmp	w20, w0
	ble	.L145
	add	x2, x5, 49
	mov	w19, 0
	b	.L109
	.p2align 3
.L110:
	ldrb	w3, [x2], 1
	cmp	w20, w3
	ble	.L141
.L109:
	add	w19, w19, 1
	cmp	w6, w19
	bne	.L110
.L107:
	sub	w19, w6, #1
.L141:
	mov	w0, w23
	bl	get_wf_mode_index
	mov	w1, w19
	and	w0, w0, 255
	bl	get_wf_frm_num
	tbnz	w0, #31, .L138
	cmp	w23, 7
	beq	.L175
	cmp	w23, 1
	beq	.L176
	sub	w1, w23, #5
	cmp	w1, 1
	bls	.L177
	sub	w1, w23, #11
	cmp	w1, 1
	bls	.L178
	sub	w1, w23, #13
	cmp	w1, 1
	bls	.L179
.L114:
	add	x3, x21, :lo12:.LANCHOR2
	ldr	w2, [x22]
	mov	w1, 21846
	and	w2, w2, 65280
	movk	w1, 0x5555, lsl 16
	str	w23, [x3, 12]
	orr	w0, w2, w0
	ldr	w3, [x3, 8]
	add	x2, x25, :lo12:.LANCHOR0
	str	w0, [x22]
	str	w26, [x2, 32]
	smull	x0, w3, w1
	lsr	x0, x0, 32
	sub	w0, w0, w3, asr 31
	cmp	w24, w0
	beq	.L133
.L140:
	ldr	x1, [x22, 24]
	add	x0, x25, :lo12:.LANCHOR0
	str	x1, [x0, 8]
	bl	epd_overlay_lut
	ldr	x1, [x25, #:lo12:.LANCHOR0]
	ldrb	w3, [x1, 38]
	cbz	w3, .L134
	ldrb	w2, [x1, 48]
	cmp	w20, w2
	ble	.L146
	add	x1, x1, 49
	mov	w19, 0
	b	.L136
	.p2align 3
.L137:
	ldrb	w2, [x1], 1
	cmp	w20, w2
	ble	.L142
.L136:
	add	w19, w19, 1
	cmp	w3, w19
	bne	.L137
.L134:
	sub	w19, w3, #1
.L142:
	bl	get_wf_mode_index
	and	w0, w0, 255
	mov	w1, w19
	bl	get_wf_frm_num
	mov	w1, w0
	tbnz	w0, #31, .L138
	ldrb	w2, [x22]
	add	x21, x21, :lo12:.LANCHOR2
	mov	w0, 0
	orr	w1, w2, w1, lsl 8
	str	w20, [x21, 8]
	str	w1, [x22]
.L102:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x29, x30, [sp], 80
	ret
	.p2align 3
.L174:
	ldr	w0, [x2, 12]
	cmp	w0, w23
	beq	.L180
.L106:
	add	x0, x21, :lo12:.LANCHOR2
	cmp	w23, 10
	str	w3, [x0, 4]
	bne	.L139
.L133:
	mov	w0, 0
.L181:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x29, x30, [sp], 80
	ret
.L176:
	mov	w2, 0
	ldr	x4, [x22, 16]
	cbz	w0, .L121
	.p2align 2
.L158:
	lsl	w3, w2, 10
	add	w2, w2, 1
	add	x1, x4, x3, sxtw
	cmp	w0, w2
	ldrb	w5, [x1, 960]
	strb	w5, [x4, w3, sxtw]
	ldrb	w3, [x1, 30]
	strb	w3, [x1, 990]
	bne	.L158
	mov	w3, 0
	.p2align 2
.L120:
	lsl	w1, w3, 10
	add	w3, w3, 2
	add	x1, x4, x1, sxtw
	cmp	w2, w3
	ldrb	w5, [x1, 960]
	strb	w5, [x1, 96]
	ldrb	w5, [x1, 30]
	strb	w5, [x1, 126]
	bgt	.L120
.L121:
	sub	w1, w0, #2
	lsl	w1, w1, 10
	add	x4, x4, x1, sxtw
	mov	w1, 2
	strb	w1, [x4, 830]
	b	.L114
	.p2align 3
.L175:
	mov	w3, 0
	ldr	x4, [x22, 16]
	cbz	w0, .L121
	.p2align 2
.L157:
	lsl	w5, w3, 10
	add	w3, w3, 1
	add	x2, x4, x5, sxtw
	cmp	w0, w3
	ldrb	w1, [x2, 960]
	strb	w1, [x4, w5, sxtw]
	strb	w1, [x2, 96]
	ldrb	w1, [x2, 30]
	strb	w1, [x2, 990]
	strb	w1, [x2, 126]
	bne	.L157
	sub	w1, w0, #2
	lsl	w1, w1, 10
	add	x4, x4, x1, sxtw
	mov	w1, 2
	strb	w1, [x4, 830]
	b	.L114
	.p2align 3
.L173:
	ldr	x6, [x0, 16]
	cbnz	x6, .L104
	mov	w0, -22
	b	.L102
	.p2align 3
.L177:
	mov	w2, 0
	ldr	x4, [x22, 16]
	cbz	w0, .L114
	.p2align 2
.L159:
	lsl	w1, w2, 10
	add	w2, w2, 1
	add	x1, x4, x1, sxtw
	cmp	w0, w2
	ldrb	w3, [x1, 30]
	strb	w3, [x1, 31]
	strb	w3, [x1, 29]
	bne	.L159
	b	.L114
	.p2align 3
.L178:
	ldr	x4, [x22, 16]
	cbz	w0, .L114
	mov	w2, 0
	.p2align 2
.L128:
	lsl	w1, w2, 10
	add	w2, w2, 1
	add	x1, x4, x1, sxtw
	cmp	w0, w2
	ldrb	w3, [x1, 30]
	strb	wzr, [x1, 989]
	strb	w3, [x1, 31]
	strb	w3, [x1, 29]
	cbz	w26, .L127
	strb	wzr, [x1, 1021]
	strb	wzr, [x1, 1022]
.L127:
	bne	.L128
	b	.L114
	.p2align 3
.L180:
	add	x0, x25, :lo12:.LANCHOR0
	ldr	w0, [x0, 32]
	cmp	w0, w4
	bne	.L106
	mov	w0, 0
	b	.L181
.L179:
	mov	w2, 0
	ldr	x4, [x22, 16]
	cbz	w0, .L132
	.p2align 2
.L160:
	lsl	w1, w2, 10
	add	w2, w2, 1
	add	x1, x4, x1, sxtw
	cbz	w26, .L130
	ldrb	w3, [x1, 990]
	strb	w3, [x1, 989]
	strb	wzr, [x1, 990]
	strb	w3, [x1, 1021]
	strb	w3, [x1, 957]
.L130:
	ldrb	w3, [x1, 30]
	cmp	w0, w2
	strb	wzr, [x1, 958]
	strb	wzr, [x1, 1022]
	strb	w3, [x1, 31]
	strb	w3, [x1, 29]
	strb	w3, [x1, 61]
	bne	.L160
.L132:
	sub	w3, w0, #4
	sub	w2, w0, #3
	lsl	w3, w3, 10
	lsl	w2, w2, 10
	add	x3, x4, x3, sxtw
	sub	w1, w0, #2
	add	x2, x4, x2, sxtw
	lsl	w1, w1, 10
	add	x4, x4, x1, sxtw
	mov	w1, 1
	strb	w1, [x3, 991]
	strb	w1, [x3, 959]
	strb	w1, [x3, 1023]
	mov	w1, 2
	strb	w1, [x2, 991]
	strb	w1, [x2, 959]
	strb	w1, [x2, 1023]
	strb	w1, [x4, 991]
	strb	w1, [x4, 959]
	strb	w1, [x4, 1023]
	b	.L114
.L145:
	mov	w19, 0
	b	.L141
.L146:
	mov	w19, 0
	b	.L142
.L143:
	mov	w0, -19
	b	.L102
.L138:
	adrp	x0, .LC4
	add	x0, x0, :lo12:.LC4
	bl	printk
	mov	w0, -5
	b	.L102
	.size	pvi_wf_get_lut, .-pvi_wf_get_lut
	.align	2
	.p2align 3,,7
	.global	pvi_wf_input
	.type	pvi_wf_input, %function
pvi_wf_input:
	stp	x29, x30, [sp, -32]!
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	adrp	x19, .LANCHOR0
	ldr	x1, [x19, #:lo12:.LANCHOR0]
	cbz	x1, .L220
	mov	w0, -16
.L182:
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 32
	ret
.L220:
	ldrb	w1, [x0, 16]
	mov	x20, x0
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
	bl	printk
	ldrb	w1, [x20, 16]
	cmp	w1, 32
	beq	.L185
	bls	.L221
	cmp	w1, 72
	beq	.L185
	bhi	.L189
	cmp	w1, 35
	beq	.L188
	cmp	w1, 67
	beq	.L185
.L184:
	add	x0, x19, :lo12:.LANCHOR0
	add	x0, x0, 16
	ldrb	w2, [x0, 9]
	cmp	w2, w1
	bne	.L190
	adrp	x1, .LANCHOR2
	ldr	w0, [x0, 12]
	str	w0, [x1, #:lo12:.LANCHOR2]
.L188:
	str	x20, [x19, #:lo12:.LANCHOR0]
	mov	w0, 0
	b	.L182
.L221:
	cmp	w1, 22
	beq	.L185
	bhi	.L187
	cmp	w1, 9
	beq	.L188
	cmp	w1, 18
	beq	.L188
	b	.L184
.L189:
	cmp	w1, 84
	beq	.L188
	cmp	w1, 114
	bne	.L184
.L185:
	adrp	x0, .LANCHOR2
	mov	w1, 32
	str	w1, [x0, #:lo12:.LANCHOR2]
	b	.L188
.L187:
	sub	w0, w1, #24
	cmp	w0, 1
	bhi	.L184
	b	.L185
.L190:
	ldrb	w2, [x20, 22]
	adrp	x0, .LC6
	add	x0, x0, :lo12:.LC6
	bl	printk
	mov	w0, -8
	b	.L182
	.size	pvi_wf_input, .-pvi_wf_input
	.align	2
	.p2align 3,,7
	.global	pvi_wf_get_version
	.type	pvi_wf_get_version, %function
pvi_wf_get_version:
	adrp	x0, .LANCHOR0
	add	x3, x0, :lo12:.LANCHOR0
	ldr	x1, [x0, #:lo12:.LANCHOR0]
	cbz	x1, .L224
	add	x1, x1, 65
	add	x2, x3, 40
	mov	x0, x2
	ldp	x4, x5, [x1]
	stp	x4, x5, [x3, 40]
	ldr	x3, [x1, 16]
	str	x3, [x2, 16]
	ldr	x1, [x1, 23]
	str	x1, [x2, 23]
	strb	wzr, [x2, 31]
	ret
	.p2align 3
.L224:
	mov	x0, 0
	ret
	.size	pvi_wf_get_version, .-pvi_wf_get_version
	.global	custom_mode_table
	.global	pvi_mode_table
	.section	.rodata
	.align	3
	.set	.LANCHOR1,. + 0
	.type	__func__.16881, %object
	.size	__func__.16881, 15
__func__.16881:
	.string	"get_wf_frm_num"
	.zero	1
	.type	pvi_mode_table, %object
	.size	pvi_mode_table, 81
pvi_mode_table:
	.byte	0
	.byte	1
	.byte	1
	.byte	2
	.byte	3
	.byte	3
	.byte	3
	.byte	4
	.byte	3
	.byte	0
	.byte	1
	.byte	7
	.byte	3
	.byte	3
	.byte	5
	.byte	6
	.byte	4
	.byte	5
	.byte	0
	.byte	1
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	4
	.byte	6
	.byte	5
	.byte	0
	.byte	1
	.byte	7
	.byte	2
	.byte	3
	.byte	4
	.byte	5
	.byte	6
	.byte	4
	.byte	0
	.byte	1
	.byte	5
	.byte	2
	.byte	3
	.byte	3
	.byte	3
	.byte	4
	.byte	3
	.byte	0
	.byte	1
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	4
	.byte	6
	.byte	4
	.byte	0
	.byte	1
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	4
	.byte	5
	.byte	4
	.byte	0
	.byte	1
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	11
	.byte	6
	.byte	10
	.byte	0
	.byte	1
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	5
	.byte	6
	.byte	4
	.data
	.align	2
	.set	.LANCHOR2,. + 0
	.type	maxpic, %object
	.size	maxpic, 4
maxpic:
	.word	16
	.type	need_pic, %object
	.size	need_pic, 4
need_pic:
	.word	16
	.type	sftemp.16940, %object
	.size	sftemp.16940, 4
sftemp.16940:
	.word	-1
	.type	stype.16939, %object
	.size	stype.16939, 4
stype.16939:
	.word	15
	.bss
	.align	3
	.set	.LANCHOR0,. + 0
	.type	global_waveform, %object
	.size	global_waveform, 8
global_waveform:
	.zero	8
	.type	waveformdata, %object
	.size	waveformdata, 8
waveformdata:
	.zero	8
	.type	custom_mode_table, %object
	.size	custom_mode_table, 16
custom_mode_table:
	.zero	16
	.type	fix.16941, %object
	.size	fix.16941, 4
fix.16941:
	.zero	4
	.zero	4
	.type	spi_id_buffer.16967, %object
	.size	spi_id_buffer.16967, 32
spi_id_buffer.16967:
	.zero	32
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align	3
.LC0:
	.string	"pvi: %s %d check error\n"
.LC1:
	.string	"waveformdata is NULL\n"
	.zero	2
.LC2:
	.string	"pvi: decodec waveform error, framenum err\n"
	.zero	5
.LC3:
	.string	"pvi: unspport PVI waveform type"
.LC4:
	.string	"pvi waveform get frame number failed\n"
	.zero	2
.LC5:
	.string	"pvi : input waveform version 0x%x\n"
	.zero	5
.LC6:
	.string	"pvi : Unknow waveform version 0x%x, 0x%x, may be wrong waveform file\n"
	.ident	"GCC: (Linaro GCC 6.3-2017.05) 6.3.1 20170404"
	.section	.note.GNU-stack,"",@progbits

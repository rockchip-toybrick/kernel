/*===========================================================================
FILE:
   GobiUSBNet.c

DESCRIPTION:
   Qualcomm USB Network device for Gobi 3000
   
FUNCTIONS:
   GatherEndpoints
   GobiSuspend
   GobiResume
   GobiNetDriverBind
   GobiNetDriverUnbind
   GobiUSBNetURBCallback
   GobiUSBNetTXTimeout
   GobiUSBNetAutoPMThread
   GobiUSBNetStartXmit
   GobiUSBNetOpen
   GobiUSBNetStop
   GobiUSBNetProbe
   GobiUSBNetModInit
   GobiUSBNetModExit

Copyright (c) 2011, Code Aurora Forum. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Code Aurora Forum nor
      the names of its contributors may be used to endorse or promote
      products derived from this software without specific prior written
      permission.


THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
===========================================================================*/

/* ------------------------------------------------- */
/* 					 Include Files						*/
/* ------------------------------------------------- */
#include "Structs.h"
#include "QMIDevice.h"
#include "QMI.h"
#include "linux/module.h"
#include "linux/kernel.h"

/* ------------------------------------------------- */
/* 					 Definitions						*/
/* ------------------------------------------------- */
extern int usbnet_start_xmit (struct sk_buff *skb, struct net_device *net);
extern typeof(jiffies) GobiConectJiffes;

#if (LINUX_VERSION_CODE < KERNEL_VERSION( 2,6,29 ))
static int (*local_usbnet_start_xmit) (struct sk_buff *skb, struct net_device *net);
#endif

//#define LS_MODIFIED_USBNET  //if not modified usbnet.c, enable this micro

/* ------------------------------------------------- */
/* 					 Version Information				*/
/* ------------------------------------------------- */
#define DRIVER_VERSION "GobiNet-fastdial-v3.2"
#define DRIVER_AUTHOR "Longsung Technology"
#define DRIVER_DESC "GobiNet"

/* ------------------------------------------------- */
/* 				The Global variable 				        */
/* ------------------------------------------------- */
// For Support Multiple modules  
int mod2ls = 0;

// Driver debug flag 
int debug = 0;

// Allow user interrupts 
int interruptible = 1;

// Number of IP packets which may be queued up for transmit
int txQueueLength = 100;

// Class should be created during module init, so needs to be global
static struct class * gpClass;

//Interrupt Endpoint read length
unsigned int INTERRUPT_READ_URB_LENGTH;

/* ------------------------------------------------- */
/* 				Functions							        */
/* ------------------------------------------------- */
bool longsung_9300_detected(struct usb_device *dev)
{
	if (NULL == dev)
		return false;
	
	if ((le16_to_cpu(dev->descriptor.idVendor) == LONGSUNG_VENDOR_ID &&
	    le16_to_cpu(dev->descriptor.idProduct) == LONGSUNG_PRODUCT_UC9300) ||
	    (le16_to_cpu(dev->descriptor.idVendor) == LONGSUNG_EU_VENDOR_ID &&
	    le16_to_cpu(dev->descriptor.idProduct) == LONGSUNG_PRODUCT_UC9507E))
	{
		return true;
	}

	return false;
}

static bool possibly_iphdr(const char *data)
{
	if (NULL == data)
	{
		return 0;
	}

	return (data[0] & 0xd0) == 0x40;
}

struct sk_buff *GobiNet_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
{
	DBG("GobiNet_tx_fixup start\n");
	PRINT_HEX_BYTE(DUMP_PREFIX_NONE, skb->data, skb->len);
	if (!longsung_9300_detected(dev->udev))
	{
		DBG("GobiNet_tx_fixup not LS module\n");
		return skb;
	}
	// Skip Ethernet header from message
	if (skb_pull(skb, ETH_HLEN)) 
	{
		DBG("GobiNet_tx_fixup OK\n");
		return skb;
	} 
	else 
	{
		DBG("GobiNet_tx_fixup Packet Dropped\n");
		//dev_err(&dev->intf->dev,  "Packet Dropped ");
	}

	// Filter the packet out, release it
	dev_kfree_skb_any(skb);
	
	DBG("GobiNet_tx_fixup end\n");
	return NULL;
}

/* ============================================ 
 *Make up an ethernet header if the packet doesn't have one.
 *
 * A firmware bug common among several devices cause them to send raw
 * IP packets under some circumstances.  There is no way for the
 * driver/host to know when this will happen.  And even when the bug
 * hits, some packets will still arrive with an intact header.
 *
 * The supported devices are only capably of sending IPv4, IPv6 and
 * ARP packets on a point-to-point link. Any packet with an ethernet
 * header will have either our address or a broadcast/multicast
 * address as destination.  ARP packets will always have a header.
 *
 * This means that this function will reliably add the appropriate
 * header iff necessary, provided our hardware address does not start
 * with 4 or 6.
 *
 * Another common firmware bug results in all packets being addressed
 * to 00:a0:c6:00:00:00 despite the host address being different.
 * This function will also fixup such packets.
 ============================================  */
 
/* Added by chenlei for 9x07 driver support 20161029 begin */
static int GobiNet_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
{
	__be16 proto;

	DBG("GobiNet_rx_fixup Start\n");

	PRINT_HEX_BYTE(DUMP_PREFIX_NONE, skb->data, skb->len);
	if (!longsung_9300_detected(dev->udev))
	{
		DBG("GobiNet_rx_fixup not LS module\n");
		return 1;
	}

	/* This check is no longer done by usbnet */
	if (skb->len < dev->net->hard_header_len)
		return 0;

	DBG("GobiNet_rx_fixup 3, skb->data[0] & 0xf0=0x%x\n", 
	skb->data[0] & 0xf0);


	switch (skb->data[0] & 0xf0) {
	case 0x40:
		DBG("GobiNet_rx_fixup 3.1\n");
		proto = htons(ETH_P_IP);
		break;
	case 0x60:
		proto = htons(ETH_P_IPV6);
		break;
	case 0x00:
		if (is_multicast_ether_addr(skb->data))
			return 1;
		/* possibly bogus destination - rewrite just in case */
		skb_reset_mac_header(skb);
		goto fix_dest;
	default:
		/* pass along other packets without modifications */
		return 1;
	}
	
	DBG("GobiNet_rx_fixup 3.2, header=0x%p, len=%d; data=0x%p, data_len=%d\n", 
		skb->head, skb->len, skb->data, skb->data_len);
	if (skb_headroom(skb) < ETH_HLEN)
	{	
#if defined(LS_MODIFIED_USBNET)
		//added by chenlei for do not modify usbnet at 20170214 begin
		struct sk_buff *skb2 = skb_copy_expand(skb, ETH_HLEN, ETH_HLEN, GFP_ATOMIC);
		DBG("error, not enough space for ethernet header.\n");	
		if(skb2==NULL)
		{
			DBG("error, new skb2 null.\n"); 	
			return 0;
		}		
		dev_kfree_skb_any(skb); 		
		skb = skb2;
		if (!skb){
			DBG("error, skb null.\n");		
			return 0;
		}
		//added by chenlei for do not modify usbnet at 20170214 end
#else
		DBG("GobiNet_rx_fixup skb header err\n");
		return 0;
#endif
	}

	DBG("GobiNet_rx_fixup ok\n");
	skb_push(skb, ETH_HLEN);
	skb_reset_mac_header(skb);
	eth_hdr(skb)->h_proto = proto;
	memset(eth_hdr(skb)->h_source, 0, ETH_ALEN);
fix_dest:
	memcpy(eth_hdr(skb)->h_dest, dev->net->dev_addr, ETH_ALEN);
	
	PRINT_HEX_BYTE(DUMP_PREFIX_NONE, skb->data, skb->len);
	DBG("GobiNet_rx_fixup end\n");

	return 1;
}
/* Added by chenlei for 9x07 driver support 20161029 end */

/*=====================================
METHOD:
   GatherEndpoints (Public Method)

DESCRIPTION:
   Enumerate endpoints

PARAMETERS
   pIntf          [ I ] - Pointer to usb interface

RETURN VALUE:
   sEndpoints structure
              NULL for failure
====================================== */
sEndpoints * GatherEndpoints( struct usb_interface * pIntf )
{
	int numEndpoints;
	int endpointIndex;
	sEndpoints * pOut;
	struct usb_host_endpoint * pEndpoint = NULL;
   
	DBG(" start \n");

	pOut = kzalloc( sizeof( sEndpoints ), GFP_ATOMIC );
	if (pOut == NULL)
	{
		DBG( "unable to allocate memory\n" );
		return NULL;
	}

	pOut->mIntfNum = pIntf->cur_altsetting->desc.bInterfaceNumber;

	// Scan endpoints
	numEndpoints = pIntf->cur_altsetting->desc.bNumEndpoints;
	for (endpointIndex = 0; endpointIndex < numEndpoints; endpointIndex++)
	{
		pEndpoint = pIntf->cur_altsetting->endpoint + endpointIndex;
		if (pEndpoint == NULL)
		{
			DBG( "invalid endpoint %u\n", endpointIndex );
			kfree( pOut );
			return NULL;
		}

		if (usb_endpoint_dir_in( &pEndpoint->desc ) == true
		&&  usb_endpoint_xfer_int( &pEndpoint->desc ) == true)
		{
			pOut->mIntInEndp = pEndpoint->desc.bEndpointAddress;
			INTERRUPT_READ_URB_LENGTH = pEndpoint->desc.wMaxPacketSize;
			DBG(" Interrupt endpoint wMaxPacketSize is %d\n",INTERRUPT_READ_URB_LENGTH);
		}
		else if (usb_endpoint_dir_in( &pEndpoint->desc ) == true
		&&  usb_endpoint_xfer_int( &pEndpoint->desc ) == false)
		{
			pOut->mBlkInEndp = pEndpoint->desc.bEndpointAddress;
		}
		else if (usb_endpoint_dir_in( &pEndpoint->desc ) == false
		&&  usb_endpoint_xfer_int( &pEndpoint->desc ) == false)
		{
			pOut->mBlkOutEndp = pEndpoint->desc.bEndpointAddress;
		}
	}

	if (pOut->mIntInEndp == 0
	||  pOut->mBlkInEndp == 0
	||  pOut->mBlkOutEndp == 0)
	{
		DBG( "One or more endpoints missing\n" );
		kfree( pOut );
		return NULL;
	}

	DBG( "	intf %u\n", pOut->mIntfNum );
	DBG( "   int in  0x%02x\n", pOut->mIntInEndp );
	DBG( "   blk in  0x%02x\n", pOut->mBlkInEndp );
	DBG( "   blk out 0x%02x\n", pOut->mBlkOutEndp );

	DBG(" end \n");

	return pOut;
}

/*===================================
METHOD:
   GobiSuspend (Public Method)

DESCRIPTION:
   Stops QMI traffic while device is suspended

PARAMETERS
   pIntf          [ I ] - Pointer to interface
   powerEvent     [ I ] - Power management event

RETURN VALUE:
   int - 0 for success
         negative errno for failure
====================================== */
#ifdef CONFIG_PM

int GobiSuspend( 
   struct usb_interface *     pIntf,
   pm_message_t               powerEvent )
{
	struct usbnet * pDev;
	sGobiUSBNet * pGobiDev;

	DBG(" start \n");

	if (pIntf == 0)
	{
		return -ENOMEM;
	}

#if (LINUX_VERSION_CODE > KERNEL_VERSION( 2,6,23 ))
	pDev = usb_get_intfdata( pIntf );
#else
	pDev = (struct usbnet *)pIntf->dev.platform_data;
#endif

	if (pDev == NULL || pDev->net == NULL)
	{
		DBG( "failed to get netdevice\n" );
		return -ENXIO;
	}

	pGobiDev = (sGobiUSBNet *)pDev->data[0];
	if (pGobiDev == NULL)
	{
		DBG( "failed to get QMIDevice\n" );
		return -ENXIO;
	}

// Is this autosuspend or system suspend?
//    do we allow remote wakeup?
/* Begin mod by zxc for compatible with  below 2.6.24 ver 20170315 */   
#if (LINUX_VERSION_CODE < KERNEL_VERSION( 2,6,33 ))
#if (LINUX_VERSION_CODE > KERNEL_VERSION( 2,6,24 ))
#ifdef CONFIG_PM
	if (pDev->udev->auto_pm == 0)
#else
	if (1)
#endif
#else
	if (1)
#endif

#else

#ifdef CONFIG_PM
	if ((powerEvent.event & PM_EVENT_AUTO) == 0)
#else
	if (1)
#endif

#endif
/* End mod by zxc for compatible with	below 2.6.24 ver 20170315 */   
	{
		DBG( "device suspended to power level %d\n", powerEvent.event );
		GobiSetDownReason( pGobiDev, DRIVER_SUSPENDED );
	}
	else
	{
		DBG( "device autosuspend\n" );
	}

	if (powerEvent.event & PM_EVENT_SUSPEND)
	{
		// Stop QMI read callbacks
		KillRead( pGobiDev );
#if (LINUX_VERSION_CODE > KERNEL_VERSION( 2,6,24 ))
#ifdef CONFIG_PM
		pDev->udev->reset_resume = 0;
#endif
#endif      
		// Store power state to avoid duplicate resumes
		pIntf->dev.power.power_state.event = powerEvent.event;
	}
	else
	{
		// Other power modes cause QMI connection to be lost
#if (LINUX_VERSION_CODE > KERNEL_VERSION( 2,6,24 ))
#ifdef CONFIG_PM
		pDev->udev->reset_resume = 1;
#endif
#endif
	}

	DBG(" end ");
// Run usbnet's suspend function
return usbnet_suspend( pIntf, powerEvent );
}
   
/*=========================================
METHOD:
   GobiResume (Public Method)

DESCRIPTION:
   Resume QMI traffic or recreate QMI device

PARAMETERS
   pIntf          [ I ] - Pointer to interface

RETURN VALUE:
   int - 0 for success
         negative errno for failure
============================================ */
int GobiResume( struct usb_interface * pIntf )
{
	struct usbnet * pDev;
	sGobiUSBNet * pGobiDev;
	int nRet;
	int oldPowerState;

	DBG(" start \n");

	if (pIntf == 0)
	{
		return -ENOMEM;
	}

#if (LINUX_VERSION_CODE > KERNEL_VERSION( 2,6,23 ))
	pDev = usb_get_intfdata( pIntf );
#else
	pDev = (struct usbnet *)pIntf->dev.platform_data;
#endif

	if (pDev == NULL || pDev->net == NULL)
	{
		DBG( "failed to get netdevice\n" );
		return -ENXIO;
	}

	pGobiDev = (sGobiUSBNet *)pDev->data[0];
	if (pGobiDev == NULL)
	{
		DBG( "failed to get QMIDevice\n" );
		return -ENXIO;
	}

	oldPowerState = pIntf->dev.power.power_state.event;
	pIntf->dev.power.power_state.event = PM_EVENT_ON;
	DBG( "resuming from power mode %d\n", oldPowerState );

	if (oldPowerState & PM_EVENT_SUSPEND)
	{
		// It doesn't matter if this is autoresume or system resume
		GobiClearDownReason( pGobiDev, DRIVER_SUSPENDED );

		nRet = usbnet_resume( pIntf );
		if (nRet != 0)
		{
			DBG( "usbnet_resume error %d\n", nRet );
			return nRet;
		}

		// Restart QMI read callbacks
		nRet = StartRead( pGobiDev );
		if (nRet != 0)
		{
			DBG( "StartRead error %d\n", nRet );
			return nRet;
		}

#ifdef CONFIG_PM
#if (LINUX_VERSION_CODE < KERNEL_VERSION( 2,6,29 ))   
		// Kick Auto PM thread to process any queued URBs
		complete( &pGobiDev->mAutoPM.mThreadDoWork );
#endif
#endif /* CONFIG_PM */
	}
	else
	{
		DBG( "nothing to resume\n" );
		return 0;
	}

	DBG(" end \n");

	return nRet;
}
#endif /* CONFIG_PM */
/*===========================================================================
METHOD:
   GobiNetDriverBind (Public Method)

DESCRIPTION:
   Setup in and out pipes

PARAMETERS
   pDev           [ I ] - Pointer to usbnet device
   pIntf          [ I ] - Pointer to interface

RETURN VALUE:
   int - 0 for success
         Negative errno for error
===========================================================================*/
static int GobiNetDriverBind( 
   struct usbnet *         pDev, 
   struct usb_interface *  pIntf )
{
	int numEndpoints;
	int endpointIndex;
	u16 product_Name = 0;

	struct usb_host_endpoint * pEndpoint = NULL;
	struct usb_host_endpoint * pIn = NULL;
	struct usb_host_endpoint * pOut = NULL;
  
	DBG(" start \n");

	// Verify one altsetting
	if (pIntf->num_altsetting != 1)
	{
		DBG( "invalid num_altsetting %u\n", pIntf->num_altsetting );
		return -ENODEV;
	}

	product_Name = le16_to_cpu(pDev->udev->descriptor.idProduct); 
	// Verify correct interface (4 is vaild)
	switch (product_Name) {
	case LONGSUNG_PRODUCT_UC9300:
	case LONGSUNG_PRODUCT_UC8300:
		if (pIntf->cur_altsetting->desc.bInterfaceNumber != 4)
		{
			DBG( "invalid interface %d, not longsung ethx interface...\n", pIntf->cur_altsetting->desc.bInterfaceNumber );
			return -ENODEV;
		}
			
		break;
	case LONGSUNG_PRODUCT_UC9507E:
		if (pIntf->cur_altsetting->desc.bInterfaceNumber != 3)
		{
			DBG( "invalid interface %d, not longsung ethx interface...\n", pIntf->cur_altsetting->desc.bInterfaceNumber );
			return -ENODEV;
		}

		break;
	default:
		/* not long sung dev */
		DBG( "invalid device, not longsung devices ...\n");
		return -ENODEV;
	}
   
	// Collect In and Out endpoints
	numEndpoints = pIntf->cur_altsetting->desc.bNumEndpoints;
	for (endpointIndex = 0; endpointIndex < numEndpoints; endpointIndex++)
	{
		pEndpoint = pIntf->cur_altsetting->endpoint + endpointIndex;
		if (pEndpoint == NULL)
		{
			DBG( "invalid endpoint %u\n", endpointIndex );
			return -ENODEV;
		}

		if (usb_endpoint_dir_in( &pEndpoint->desc ) == true
		&&  usb_endpoint_xfer_int( &pEndpoint->desc ) == false)
		{
			pIn = pEndpoint;
		}
		else if (usb_endpoint_dir_out( &pEndpoint->desc ) == true)
		{
			pOut = pEndpoint;
		}
	}
   
	if (pIn == NULL || pOut == NULL)
	{
		DBG( "invalid endpoints\n" );
		return -ENODEV;
	}

	if (usb_set_interface( pDev->udev, 
	                      pIntf->cur_altsetting->desc.bInterfaceNumber,
	                      0 ) != 0)
	{
		DBG( "unable to set interface\n" );
		return -ENODEV;
	}

	pDev->in = usb_rcvbulkpipe( pDev->udev,
	               pIn->desc.bEndpointAddress & USB_ENDPOINT_NUMBER_MASK );
	pDev->out = usb_sndbulkpipe( pDev->udev,
	               pOut->desc.bEndpointAddress & USB_ENDPOINT_NUMBER_MASK );
	               
	DBG( " in %x, out %x\n", pIn->desc.bEndpointAddress, pOut->desc.bEndpointAddress );

   // In later versions of the kernel, usbnet helps with this
#if (LINUX_VERSION_CODE <= KERNEL_VERSION( 2,6,23 ))
	pIntf->dev.platform_data = (void *)pDev;
#endif

	/* added by chenlei for 9x07 driver support 20160723 begin */
	if (longsung_9300_detected(pDev->udev))
	{
		/* Added by zxc for generate random mac */
		random_ether_addr(pDev->net->dev_addr);
		dev_info(&pIntf->dev,  "work on RawIP mode\n");
		pDev->net->flags |= IFF_NOARP;
		/* make MAC addr easily distinguishable from an IP header */
		if (possibly_iphdr(pDev->net->dev_addr)) {
			pDev->net->dev_addr[0] |= 0x02;  /* set local assignment bit */
			pDev->net->dev_addr[0] &= 0xbf;  /* clear "IP" bit */
		}
		usb_control_msg(
			interface_to_usbdev(pIntf),
			usb_sndctrlpipe(interface_to_usbdev(pIntf), 0),
			0x22, //USB_CDC_REQ_SET_CONTROL_LINE_STATE
			0x21, //USB_DIR_OUT | USB_TYPE_CLASS | USB_RECIP_INTERFACE
			1,    //active CDC DTR
			pIntf->cur_altsetting->desc.bInterfaceNumber,
			NULL, 0, 100);
	}
	/* added by chenlei for 9x07 driver support 20160723 end */

	DBG(" end \n");

   return 0;
}

/*===========================================================================
METHOD:
   GobiNetDriverUnbind (Public Method)

DESCRIPTION:
   Deregisters QMI device (Registration happened in the probe function)

PARAMETERS
   pDev           [ I ] - Pointer to usbnet device
   pIntfUnused    [ I ] - Pointer to interface

RETURN VALUE:
   None
===========================================================================*/
static void GobiNetDriverUnbind( 
   struct usbnet *         pDev, 
   struct usb_interface *  pIntf)
{
	sGobiUSBNet * pGobiDev = (sGobiUSBNet *)pDev->data[0];

	DBG(" start \n");

	// Should already be down, but just in case...
	netif_carrier_off( pDev->net );

	DeregisterQMIDevice( pGobiDev );
   
#if (LINUX_VERSION_CODE >= KERNEL_VERSION( 2,6,29 ))
	kfree( pDev->net->netdev_ops );
	pDev->net->netdev_ops = NULL;
#endif

#if (LINUX_VERSION_CODE <= KERNEL_VERSION( 2,6,23 ))
	pIntf->dev.platform_data = NULL;
#endif

#if (LINUX_VERSION_CODE >= KERNEL_VERSION( 2,6,19 ))
	pIntf->needs_remote_wakeup = 0;
#endif

	if (atomic_dec_and_test(&pGobiDev->refcount))
	   kfree( pGobiDev );
	else
	   DBG("memory leak!\n");

	pGobiDev = NULL;
	DBG(" end \n");
}

#if (LINUX_VERSION_CODE < KERNEL_VERSION( 2,6,29 ))
#ifdef CONFIG_PM
/*===========================================================================
METHOD:
   GobiUSBNetURBCallback (Public Method)

DESCRIPTION:
   Write is complete, cleanup and signal that we're ready for next packet

PARAMETERS
   pURB     [ I ] - Pointer to sAutoPM struct

RETURN VALUE:
   None
===========================================================================*/
void GobiUSBNetURBCallback( struct urb * pURB )
{
	unsigned long activeURBflags;
	sAutoPM * pAutoPM = (sAutoPM *)pURB->context;

	DBG(" start \n");

	if (pAutoPM == NULL)
	{
		// Should never happen
		DBG( "bad context\n" );
		return;
	}

	if (pURB->status != 0)
	{
		// Note that in case of an error, the behaviour is no different
		DBG( "urb finished with error %d\n", pURB->status );
	}

	// Remove activeURB (memory to be freed later)
	spin_lock_irqsave( &pAutoPM->mActiveURBLock, activeURBflags );

	// EAGAIN used to signify callback is done
	pAutoPM->mpActiveURB = ERR_PTR( -EAGAIN );

	spin_unlock_irqrestore( &pAutoPM->mActiveURBLock, activeURBflags );

	complete( &pAutoPM->mThreadDoWork );

	usb_free_urb( pURB );

	DBG(" end \n");
}

/*===========================================================================
METHOD:
   GobiUSBNetTXTimeout (Public Method)

DESCRIPTION:
   Timeout declared by the net driver.  Stop all transfers

PARAMETERS
   pNet     [ I ] - Pointer to net device

RETURN VALUE:
   None
===========================================================================*/
void GobiUSBNetTXTimeout( struct net_device * pNet )
{
	struct sGobiUSBNet * pGobiDev;
	sAutoPM * pAutoPM;
	sURBList * pURBListEntry;
	unsigned long activeURBflags, URBListFlags;
	struct usbnet * pDev = netdev_priv( pNet );
	struct urb * pURB;

	DBG(" start \n");

	if (pDev == NULL || pDev->net == NULL)
	{
		DBG( "failed to get usbnet device\n" );
		return;
	}
   
	pGobiDev = (sGobiUSBNet *)pDev->data[0];
	if (pGobiDev == NULL)
	{
		DBG( "failed to get QMIDevice\n" );
		return;
	}
	pAutoPM = &pGobiDev->mAutoPM;

	DBG( "\n" );

	// Grab a pointer to active URB
	spin_lock_irqsave( &pAutoPM->mActiveURBLock, activeURBflags );
	pURB = pAutoPM->mpActiveURB;
	spin_unlock_irqrestore( &pAutoPM->mActiveURBLock, activeURBflags );

	// Stop active URB
	if (pURB != NULL)
	{
		usb_kill_urb( pURB );
	}

	// Cleanup URB List
	spin_lock_irqsave( &pAutoPM->mURBListLock, URBListFlags );

	pURBListEntry = pAutoPM->mpURBList;
	while (pURBListEntry != NULL)
	{
		pAutoPM->mpURBList = pAutoPM->mpURBList->mpNext;
		atomic_dec( &pAutoPM->mURBListLen );
		usb_free_urb( pURBListEntry->mpURB );
		kfree( pURBListEntry );
		pURBListEntry = pAutoPM->mpURBList;
	}

	spin_unlock_irqrestore( &pAutoPM->mURBListLock, URBListFlags );

	complete( &pAutoPM->mThreadDoWork );

	DBG(" end \n");

	return;
}

/*===========================================================================
METHOD:
   GobiUSBNetAutoPMThread (Public Method)

DESCRIPTION:
   Handle device Auto PM state asynchronously
   Handle network packet transmission asynchronously

PARAMETERS
   pData     [ I ] - Pointer to sAutoPM struct

RETURN VALUE:
   int - 0 for success
         Negative errno for error
===========================================================================*/
static int GobiUSBNetAutoPMThread( void * pData )
{
   unsigned long activeURBflags, URBListFlags;
   sURBList * pURBListEntry;
   int status;
   struct usb_device * pUdev;
   sAutoPM * pAutoPM = (sAutoPM *)pData;
   struct urb * pURB;

   DBG(" start \n");

	if (pAutoPM == NULL)
	{
		DBG( "passed null pointer\n" );
		return -EINVAL;
	}
   
	pUdev = interface_to_usbdev( pAutoPM->mpIntf );

	DBG( "traffic thread started\n" );

	while (pAutoPM->mbExit == false)
	{
		// Wait for someone to poke us
		wait_for_completion_interruptible( &pAutoPM->mThreadDoWork );

		// Time to exit?
		if (pAutoPM->mbExit == true)
		{
			DBG("\n");
			// Stop activeURB
			spin_lock_irqsave( &pAutoPM->mActiveURBLock, activeURBflags );
			pURB = pAutoPM->mpActiveURB;
			spin_unlock_irqrestore( &pAutoPM->mActiveURBLock, activeURBflags );

			// EAGAIN used to signify callback is done
			if (IS_ERR( pAutoPM->mpActiveURB )
			     &&  PTR_ERR( pAutoPM->mpActiveURB ) == -EAGAIN )
			{
				pURB = NULL;
			}

			if (pURB != NULL)
			{
				usb_kill_urb( pURB );
			}
			// Will be freed in callback function

			// Cleanup URB List
			spin_lock_irqsave( &pAutoPM->mURBListLock, URBListFlags );

			pURBListEntry = pAutoPM->mpURBList;
			while (pURBListEntry != NULL)
			{
				pAutoPM->mpURBList = pAutoPM->mpURBList->mpNext;
				atomic_dec( &pAutoPM->mURBListLen );
				usb_free_urb( pURBListEntry->mpURB );
				kfree( pURBListEntry );
				pURBListEntry = pAutoPM->mpURBList;
			}

			spin_unlock_irqrestore( &pAutoPM->mURBListLock, URBListFlags );

			break;
		}

		// Is our URB active?
		spin_lock_irqsave( &pAutoPM->mActiveURBLock, activeURBflags );

		// EAGAIN used to signify callback is done
		if (IS_ERR( pAutoPM->mpActiveURB ) 
		&&  PTR_ERR( pAutoPM->mpActiveURB ) == -EAGAIN )
		{
			pAutoPM->mpActiveURB = NULL;

			// Restore IRQs so task can sleep
			spin_unlock_irqrestore( &pAutoPM->mActiveURBLock, activeURBflags );

			// URB is done, decrement the Auto PM usage count
			usb_autopm_put_interface( pAutoPM->mpIntf );

			// Lock ActiveURB again
			spin_lock_irqsave( &pAutoPM->mActiveURBLock, activeURBflags );
		}

		if (pAutoPM->mpActiveURB != NULL)
		{
			// There is already a URB active, go back to sleep
			spin_unlock_irqrestore( &pAutoPM->mActiveURBLock, activeURBflags );
			continue;
		}
      
		// Is there a URB waiting to be submitted?
		spin_lock_irqsave( &pAutoPM->mURBListLock, URBListFlags );
		if (pAutoPM->mpURBList == NULL)
		{
			// No more URBs to submit, go back to sleep
			spin_unlock_irqrestore( &pAutoPM->mURBListLock, URBListFlags );
			spin_unlock_irqrestore( &pAutoPM->mActiveURBLock, activeURBflags );
			continue;
		}

		// Pop an element
		pURBListEntry = pAutoPM->mpURBList;
		pAutoPM->mpURBList = pAutoPM->mpURBList->mpNext;
		atomic_dec( &pAutoPM->mURBListLen );
		spin_unlock_irqrestore( &pAutoPM->mURBListLock, URBListFlags );

		// Set ActiveURB
		pAutoPM->mpActiveURB = pURBListEntry->mpURB;
		spin_unlock_irqrestore( &pAutoPM->mActiveURBLock, activeURBflags );

		// Tell autopm core we need device woken up
		status = usb_autopm_get_interface( pAutoPM->mpIntf );
		if (status < 0)
		{
			 DBG( "unable to autoresume interface: %d\n", status );

			// likely caused by device going from autosuspend -> full suspend
			if (status == -EPERM)
			{
#if (LINUX_VERSION_CODE < KERNEL_VERSION( 2,6,33 ))
#if (LINUX_VERSION_CODE > KERNEL_VERSION( 2,6,14 ))
				pUdev->auto_pm = 0;
#else
				pUdev = pUdev;
#endif
#endif
				GobiSuspend( pAutoPM->mpIntf, PMSG_SUSPEND );
			}

			// Add pURBListEntry back onto pAutoPM->mpURBList
			spin_lock_irqsave( &pAutoPM->mURBListLock, URBListFlags );
			pURBListEntry->mpNext = pAutoPM->mpURBList;
			pAutoPM->mpURBList = pURBListEntry;
			atomic_inc( &pAutoPM->mURBListLen );
			spin_unlock_irqrestore( &pAutoPM->mURBListLock, URBListFlags );

			spin_lock_irqsave( &pAutoPM->mActiveURBLock, activeURBflags );
			pAutoPM->mpActiveURB = NULL;
			spin_unlock_irqrestore( &pAutoPM->mActiveURBLock, activeURBflags );

			// Go back to sleep
			continue;
		}

		// Submit URB
		status = usb_submit_urb( pAutoPM->mpActiveURB, GFP_KERNEL );
		if (status < 0)
		{
			// Could happen for a number of reasons
			DBG( "Failed to submit URB: %d.  Packet dropped\n", status );
			spin_lock_irqsave( &pAutoPM->mActiveURBLock, activeURBflags );
			usb_free_urb( pAutoPM->mpActiveURB );
			pAutoPM->mpActiveURB = NULL;
			spin_unlock_irqrestore( &pAutoPM->mActiveURBLock, activeURBflags );
			usb_autopm_put_interface( pAutoPM->mpIntf );

			// Loop again
			complete( &pAutoPM->mThreadDoWork );
		}
      
		kfree( pURBListEntry );
	}   
   
	DBG( "traffic thread exiting\n" );
	pAutoPM->mpThread = NULL;
	DBG(" end \n");
	return 0;
}      

/*===========================================================================
METHOD:
   GobiUSBNetStartXmit (Public Method)

DESCRIPTION:
   Convert sk_buff to usb URB and queue for transmit

PARAMETERS
   pNet     [ I ] - Pointer to net device

RETURN VALUE:
   NETDEV_TX_OK on success
   NETDEV_TX_BUSY on error
===========================================================================*/
int GobiUSBNetStartXmit2( 
	struct sk_buff *     pSKB,
	struct net_device *  pNet )
{
	//unsigned long URBListFlags;
	struct sGobiUSBNet * pGobiDev;
	sAutoPM * pAutoPM;
	//sURBList * pURBListEntry, ** ppURBListEnd;
	//void * pURBData;
	struct usbnet * pDev = netdev_priv( pNet );
	 
	//DBG(" start \n");
	if (pDev == NULL || pDev->net == NULL)
	{
		DBG( "failed to get usbnet device\n" );
		return NETDEV_TX_BUSY;
	}
	 
	pGobiDev = (sGobiUSBNet *)pDev->data[0];
	if (pGobiDev == NULL)
	{
		DBG( "failed to get QMIDevice\n" );
		return NETDEV_TX_BUSY;
	}
	 
	if( NULL == pSKB )
	{
		DBG( "Buffer is NULL \n" );
		return NETDEV_TX_BUSY;
	}
  
#if (LINUX_VERSION_CODE < KERNEL_VERSION( 2,6,29 ))
	pAutoPM = &pGobiDev->mAutoPM;
#endif
	if (GobiTestDownReason( pGobiDev, DRIVER_SUSPENDED ) == true)
	{
		// Should not happen
		DBG( "device is suspended\n" );
		//dump_stack();
		return NETDEV_TX_BUSY;
	}
	 
	if (GobiTestDownReason( pGobiDev, NO_NDIS_CONNECTION ))
	{
		netif_carrier_off( pGobiDev->mpNetDev->net );
		// Should not happen
		//DBG( "device is disconnected\n" );
		//dump_stack();
		return NETDEV_TX_BUSY;
	}
  
	//DBG(" end \n");
#if (LINUX_VERSION_CODE < KERNEL_VERSION( 2,6,29 ))
	return local_usbnet_start_xmit(pSKB, pNet);
#else
	return usbnet_start_xmit(pSKB, pNet);
#endif
}
#endif
#endif

/*===========================================================================
METHOD:
   GobiUSBNetStartXmit (Public Method)

DESCRIPTION:
   Convert sk_buff to usb URB and queue for transmit

PARAMETERS
   pNet     [ I ] - Pointer to net device

RETURN VALUE:
   NETDEV_TX_OK on success
   NETDEV_TX_BUSY on error
===========================================================================*/
int GobiUSBNetStartXmit( 
	struct sk_buff *     pSKB,
	struct net_device *  pNet )
{
	//unsigned long URBListFlags;
	struct sGobiUSBNet * pGobiDev;
#ifdef CONFIG_PM   
#if (LINUX_VERSION_CODE < KERNEL_VERSION( 2,6,29 ))
	sAutoPM * pAutoPM;
#endif
#endif
	//sURBList * pURBListEntry, ** ppURBListEnd;
	//void * pURBData;
	struct usbnet * pDev = netdev_priv( pNet );
   
   //DBG(" start \n");
	if (pDev == NULL || pDev->net == NULL)
	{
		DBG( "failed to get usbnet device\n" );
		return NETDEV_TX_BUSY;
	}
   
	pGobiDev = (sGobiUSBNet *)pDev->data[0];
	if (pGobiDev == NULL)
	{
		DBG( "failed to get QMIDevice\n" );
		return NETDEV_TX_BUSY;
	}
   
	if( NULL == pSKB )
	{
		DBG( "Buffer is NULL \n" );
		return NETDEV_TX_BUSY;
	}

#ifdef CONFIG_PM   
#if (LINUX_VERSION_CODE < KERNEL_VERSION( 2,6,29 ))
	pAutoPM = &pGobiDev->mAutoPM;
#endif
#endif
	if (GobiTestDownReason( pGobiDev, DRIVER_SUSPENDED ) == true)
	{
		// Should not happen
		DBG( "device is suspended\n" );
		//dump_stack();
		return NETDEV_TX_BUSY;
	}
   
	if (GobiTestDownReason( pGobiDev, NO_NDIS_CONNECTION ))
	{
		netif_carrier_off( pGobiDev->mpNetDev->net );
		// Should not happen
		//DBG( "device is disconnected\n" );
		//dump_stack();
		return NETDEV_TX_BUSY;
	}

	//DBG(" end \n");
#if (LINUX_VERSION_CODE < KERNEL_VERSION( 2,6,29 ))
	return local_usbnet_start_xmit(pSKB, pNet);
#else
	return usbnet_start_xmit(pSKB, pNet);
#endif
}

/*===========================================================================
METHOD:
   GobiUSBNetOpen (Public Method)

DESCRIPTION:
   Wrapper to usbnet_open, correctly handling autosuspend
   Start AutoPM thread

PARAMETERS
   pNet     [ I ] - Pointer to net device

RETURN VALUE:
   int - 0 for success
         Negative errno for error
===========================================================================*/
int GobiUSBNetOpen( struct net_device * pNet )
{
	int status = 0;
	struct sGobiUSBNet * pGobiDev;
	struct usbnet * pDev = netdev_priv( pNet );
	//int maxtimes = 30;  
 
	DBG(" start \n");
	if (pDev == NULL)
	{
		DBG( "failed to get usbnet device\n" );
		return -ENXIO;
	}
   
	pGobiDev = (sGobiUSBNet *)pDev->data[0];
	if (pGobiDev == NULL)
	{
		DBG( "failed to get QMIDevice\n" );
		return -ENXIO;
	}

	DBG( "\n" );

#ifdef CONFIG_PM
	// Start the AutoPM thread
#if (LINUX_VERSION_CODE < KERNEL_VERSION( 2,6,29 ))
	pGobiDev->mAutoPM.mpIntf = pGobiDev->mpIntf;
	pGobiDev->mAutoPM.mbExit = false;
	pGobiDev->mAutoPM.mpURBList = NULL;
	pGobiDev->mAutoPM.mpActiveURB = NULL;
	spin_lock_init( &pGobiDev->mAutoPM.mURBListLock );
	spin_lock_init( &pGobiDev->mAutoPM.mActiveURBLock );
	atomic_set( &pGobiDev->mAutoPM.mURBListLen, 0 );
	init_completion( &pGobiDev->mAutoPM.mThreadDoWork );

	pGobiDev->mAutoPM.mpThread = kthread_run( GobiUSBNetAutoPMThread, 
                                               &pGobiDev->mAutoPM, 
                                               "GobiUSBNetAutoPMThread" );
	if (IS_ERR( pGobiDev->mAutoPM.mpThread ))
	{
		DBG( "AutoPM thread creation error\n" );
		return PTR_ERR( pGobiDev->mAutoPM.mpThread );
	}
#endif
#endif /* CONFIG_PM */

	// Allow traffic
	GobiConectJiffes = 0;
	GobiClearDownReason( pGobiDev, NET_IFACE_STOPPED );
    //if (GobiTestDownReason( pGobiDev, NO_NDIS_CONNECTION ))
	//GobiClearDownReason( pGobiDev, NO_NDIS_CONNECTION );

	QMIWDSStartNetworkInterface(pGobiDev);  

	while (GobiTestDownReason( pGobiDev, NO_NDIS_CONNECTION ))
	{
		DBG("wait NDIS_CONNECTION\n");
		//msleep(1000);
		break;
	}
	DBG("%s\n", GobiTestDownReason( pGobiDev, NO_NDIS_CONNECTION ) ? "NO_NDIS_CONNECTION" : "NDIS_CONNECTION");
        
	// Pass to usbnet_open if defined
	if (pGobiDev->mpUSBNetOpen != NULL)
	{
		netif_carrier_on( pGobiDev->mpNetDev->net );
		status = pGobiDev->mpUSBNetOpen( pNet );
		//if (GobiTestDownReason( pGobiDev, NO_NDIS_CONNECTION ))
		//netif_carrier_off( pGobiDev->mpNetDev->net );
   
#ifdef CONFIG_PM
		// If usbnet_open was successful enable Auto PM
		if (status == 0)
		{
#if (LINUX_VERSION_CODE < KERNEL_VERSION( 2,6,33 ))
			usb_autopm_enable( pGobiDev->mpIntf );
#else
			usb_autopm_put_interface( pGobiDev->mpIntf );
#endif
		}
#endif /* CONFIG_PM */
	}
	else
	{
		DBG( "no USBNetOpen defined\n" );
	}
   
   DBG(" end \n");
   return status;
}

/*===========================================================================
METHOD:
   GobiUSBNetStop (Public Method)

DESCRIPTION:
   Wrapper to usbnet_stop, correctly handling autosuspend
   Stop AutoPM thread

PARAMETERS
   pNet     [ I ] - Pointer to net device

RETURN VALUE:
   int - 0 for success
         Negative errno for error
===========================================================================*/
int GobiUSBNetStop( struct net_device * pNet )
{
	struct sGobiUSBNet * pGobiDev;
	struct usbnet * pDev = netdev_priv( pNet );

	DBG(" start \n");

	if (pDev == NULL || pDev->net == NULL)
	{
		DBG( "failed to get netdevice\n" );
		return -ENXIO;
	}
   
	pGobiDev = (sGobiUSBNet *)pDev->data[0];
	if (pGobiDev == NULL)
	{
		DBG( "failed to get QMIDevice\n" );
		return -ENXIO;
	}

	// Stop traffic
	GobiSetDownReason( pGobiDev, NET_IFACE_STOPPED );
   
#ifdef CONFIG_PM
#if (LINUX_VERSION_CODE < KERNEL_VERSION( 2,6,29 ))

	// Tell traffic thread to exit
	pGobiDev->mAutoPM.mbExit = true;
	complete( &pGobiDev->mAutoPM.mThreadDoWork );
   
	// Wait for it to exit
	while( pGobiDev->mAutoPM.mpThread != NULL )
	{
		msleep( 100 );
	}
	DBG( "thread stopped\n" );
#endif
#endif /* CONFIG_PM */

	//QMIWDSStopNetworkInterface(pGobiDev);  
	// Pass to usbnet_stop, if defined

	DBG(" end \n");	
	if (pGobiDev->mpUSBNetStop != NULL)
	{
		return pGobiDev->mpUSBNetStop( pNet );
	}
	else
	{
		return 0;
	}
}

/* ================================== */
/*			Struct driver_info	                                    */
/* ================================== */
static const struct driver_info GobiNetInfo = 
{
	.description   = "GobiNet Ethernet Device",
#ifdef CONFIG_ANDROID
	.flags		 = FLAG_ETHER | FLAG_POINTTOPOINT,
#else
	.flags		 = FLAG_ETHER,
#endif
	.bind          = GobiNetDriverBind,
	.unbind        = GobiNetDriverUnbind,
	//.check_connect        = GobiNetDriver_check_connect,
	.data          = 0,

	//added by chenlei for 9x07 driver support 20160723 begin
	.rx_fixup	   = GobiNet_rx_fixup,
	.tx_fixup	   = GobiNet_tx_fixup,
	//added by chenlei for 9x07 driver support 20160723 end

};

/*=========================================================================*/
// Qualcomm Gobi 3000 VID/PIDs
/*=========================================================================*/
static const struct usb_device_id GobiVIDPIDTable [] =
{
	{
		USB_DEVICE( 0x2df3, 0x9b2f ),
		.driver_info = (unsigned long)&GobiNetInfo
	},
	{
		USB_DEVICE( 0x2df3, 0x9b3e ),
		.driver_info = (unsigned long)&GobiNetInfo
	},
	{
		USB_DEVICE( 0x1c9e, 0x9b05 ),
		.driver_info = (unsigned long)&GobiNetInfo
	},
	{
		USB_DEVICE( 0x1c9e, 0x9b3c ),
		.driver_info = (unsigned long)&GobiNetInfo
	},
	//Terminating entry
	{ }
};

MODULE_DEVICE_TABLE( usb, GobiVIDPIDTable );

/*===========================================================================
METHOD:
   GobiUSBNetProbe (Public Method)

DESCRIPTION:
   Run usbnet_probe
   Setup QMI device

PARAMETERS
   pIntf        [ I ] - Pointer to interface
   pVIDPIDs     [ I ] - Pointer to VID/PID table

RETURN VALUE:
   int - 0 for success
         Negative errno for error
===========================================================================*/
int GobiUSBNetProbe( 
   struct usb_interface *        pIntf, 
   const struct usb_device_id *  pVIDPIDs )
{
	int status;
	struct usbnet * pDev;
	sGobiUSBNet * pGobiDev;
	sEndpoints * pEndpoints;
	int pipe;
#if (LINUX_VERSION_CODE >= KERNEL_VERSION( 2,6,29 ))
	struct net_device_ops * pNetDevOps;
#endif

	DBG(" start \n");
	pEndpoints = GatherEndpoints( pIntf );
	if (pEndpoints == NULL)
	{
		DBG("GatherEndpoints is NULL\n");
		return -ENODEV;
	}      

	status = usbnet_probe( pIntf, pVIDPIDs );
	if (status < 0)
	{
		DBG( "usbnet_probe failed %d\n", status );
		return status; 
	}
   
#if (LINUX_VERSION_CODE >= KERNEL_VERSION( 2,6,19 ))
	pIntf->needs_remote_wakeup = 1;
#endif

#if (LINUX_VERSION_CODE > KERNEL_VERSION( 2,6,23 ))
	pDev = usb_get_intfdata( pIntf );
#else
	pDev = (struct usbnet *)pIntf->dev.platform_data;
#endif

	if (pDev == NULL || pDev->net == NULL)
	{
		DBG( "failed to get netdevice\n" );
		usbnet_disconnect( pIntf );
		return -ENXIO;
	}

	pGobiDev = kmalloc( sizeof( sGobiUSBNet ), GFP_KERNEL );
	if (pGobiDev == NULL)
	{
		DBG( "falied to allocate device buffers" );
		usbnet_disconnect( pIntf );
		return -ENOMEM;
	}

	atomic_set(&pGobiDev->refcount, 1);

	pDev->data[0] = (unsigned long)pGobiDev;

	pGobiDev->mpNetDev = pDev;
	pGobiDev->mpEndpoints = pEndpoints;

	// Clearing endpoint halt is a magic handshake that brings 
	// the device out of low power (airplane) mode
	// NOTE: FCC verification should be done before this, if required
	pipe = usb_sndbulkpipe( pGobiDev->mpNetDev->udev,
	                       pGobiDev->mpEndpoints->mBlkOutEndp );
	usb_clear_halt( pGobiDev->mpNetDev->udev, pipe );

   // Overload PM related network functions
#if (LINUX_VERSION_CODE < KERNEL_VERSION( 2,6,29 ))
	pGobiDev->mpUSBNetOpen = pDev->net->open;
	pDev->net->open = GobiUSBNetOpen;
	pGobiDev->mpUSBNetStop = pDev->net->stop;
	pDev->net->stop = GobiUSBNetStop;

#if defined(CONFIG_PM) && (LINUX_VERSION_CODE > KERNEL_VERSION( 2,6,14 ))
	local_usbnet_start_xmit = pDev->net->hard_start_xmit;   //added by chenlei for 2.6.22
	pDev->net->hard_start_xmit = GobiUSBNetStartXmit2;
	pDev->net->tx_timeout = GobiUSBNetTXTimeout;
#else
	local_usbnet_start_xmit = pDev->net->hard_start_xmit;
	pDev->net->hard_start_xmit = GobiUSBNetStartXmit;
#endif

#else
	pNetDevOps = kmalloc( sizeof( struct net_device_ops ), GFP_KERNEL );
	if (pNetDevOps == NULL)
	{
		DBG( "falied to allocate net device ops" );
		usbnet_disconnect( pIntf );
		return -ENOMEM;
	}
	memcpy( pNetDevOps, pDev->net->netdev_ops, sizeof( struct net_device_ops ) );

	pGobiDev->mpUSBNetOpen = pNetDevOps->ndo_open;
	pNetDevOps->ndo_open = GobiUSBNetOpen;
	pGobiDev->mpUSBNetStop = pNetDevOps->ndo_stop;
	pNetDevOps->ndo_stop = GobiUSBNetStop;

	//pNetDevOps->ndo_start_xmit = GobiUSBNetndoStartXmit;
	pNetDevOps->ndo_start_xmit = GobiUSBNetStartXmit;
	pNetDevOps->ndo_tx_timeout = usbnet_tx_timeout;

	pDev->net->netdev_ops = pNetDevOps;
#endif

#if (LINUX_VERSION_CODE < KERNEL_VERSION( 2,6,31 ))
	memset( &(pGobiDev->mpNetDev->stats), 0, sizeof( struct net_device_stats ) );
#else
	memset( &(pGobiDev->mpNetDev->net->stats), 0, sizeof( struct net_device_stats ) );
#endif

	pGobiDev->mpIntf = pIntf;
	memset( &(pGobiDev->mMEID), '0', 14 );
   
	DBG( "Mac Address:\n" );
	PrintHex( &pGobiDev->mpNetDev->net->dev_addr[0], 6 );

	pGobiDev->mbQMIValid = false;
	memset( &pGobiDev->mQMIDev, 0, sizeof( sQMIDev ) );
	pGobiDev->mQMIDev.mbCdevIsInitialized = false;

	pGobiDev->mQMIDev.mpDevClass = gpClass;

#ifdef CONFIG_PM
#if (LINUX_VERSION_CODE < KERNEL_VERSION( 2,6,29 ))
	init_completion( &pGobiDev->mAutoPM.mThreadDoWork );
#endif
#endif /* CONFIG_PM */
	spin_lock_init( &pGobiDev->mQMIDev.mClientMemLock );

	// Default to device down
	pGobiDev->mDownReason = 0;
	//GobiSetDownReason( pGobiDev, NO_NDIS_CONNECTION );
	GobiSetDownReason( pGobiDev, NET_IFACE_STOPPED );
	//netif_carrier_on( pGobiDev->mpNetDev->net );
	//pGobiDev->mpUSBNetOpen( pGobiDev->mpNetDev->net );

	DBG(" Start Register QmiDevice ... \n");
	// Register QMI
	status = RegisterQMIDevice( pGobiDev );
	if (status != 0)
	{
		// usbnet_disconnect() will call GobiNetDriverUnbind() which will call
		// DeregisterQMIDevice() to clean up any partially created QMI device
		DBG( "ERR: RegisterQMIDevice failed status=%d, before usbnet_disconnect() \n", status);
		usbnet_disconnect( pIntf );
		DBG( "ERR: RegisterQMIDevice failed, after  usbnet_disconnect() .\n" );

		return status;
	}

	printk("GobiNet is initializing... \n");

	return 0;
}

static struct usb_driver GobiNet =
{
	.name       = "GobiNet-LS",
	.id_table   = GobiVIDPIDTable,
	.probe      = GobiUSBNetProbe,
	.disconnect = usbnet_disconnect,
#ifdef CONFIG_PM
	.suspend	= GobiSuspend,
	.resume	    = GobiResume,
#if (LINUX_VERSION_CODE > KERNEL_VERSION( 2,6,14 ))   
	.supports_autosuspend = true,
#endif   
#else
	.suspend	= NULL,
	.resume	    = NULL,
#if (LINUX_VERSION_CODE > KERNEL_VERSION( 2,6,14 ))   
	.supports_autosuspend = false,
#endif   
#endif /* CONFIG_PM */
};

/*===========================================================================
METHOD:
   GobiUSBNetModInit (Public Method)

DESCRIPTION:
   Initialize module
   Create device class
   Register out usb_driver struct

RETURN VALUE:
   int - 0 for success
         Negative errno for error
===========================================================================*/
static int __init GobiUSBNetModInit( void )
{
	DBG(" start \n");

    gpClass = class_create( THIS_MODULE, "GobiQMI-LS" );
    if (IS_ERR( gpClass ) == true)
    {
       DBG( "error at class_create %ld\n",
            PTR_ERR( gpClass ) );
       return -ENOMEM;
    }
 
    // This will be shown whenever driver is loaded
    printk( KERN_INFO "%s: %s\n", DRIVER_DESC, DRIVER_VERSION );
	DBG(" end \n");

    return usb_register( &GobiNet );
}
module_init( GobiUSBNetModInit );

/*===========================================================================
METHOD:
   GobiUSBNetModExit (Public Method)

DESCRIPTION:
   Deregister module
   Destroy device class

RETURN VALUE:
   void
===========================================================================*/
static void __exit GobiUSBNetModExit( void )
{
	DBG(" start \n");

	usb_deregister( &GobiNet );

	class_destroy( gpClass );

	DBG(" end \n");
}
module_exit( GobiUSBNetModExit );

MODULE_VERSION( DRIVER_VERSION );
MODULE_AUTHOR( DRIVER_AUTHOR );
MODULE_DESCRIPTION( DRIVER_DESC );
MODULE_LICENSE("Dual BSD/GPL");
 

#ifdef bool
#undef bool
#endif

module_param( mod2ls, int, S_IRUGO | S_IWUSR );
MODULE_PARM_DESC( mod2ls, "Support Multiple modules " );

module_param( debug, int, S_IRUGO | S_IWUSR );
MODULE_PARM_DESC( debug, "Debuging enabled or not" );

module_param( interruptible, int, S_IRUGO | S_IWUSR );
MODULE_PARM_DESC( interruptible, "Listen for and return on user interrupt" );

module_param( txQueueLength, int, S_IRUGO | S_IWUSR );
MODULE_PARM_DESC( txQueueLength, 
                  "Number of IP packets which may be queued up for transmit" );


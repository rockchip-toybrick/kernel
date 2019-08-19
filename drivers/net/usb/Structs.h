/*===========================================================================
FILE:
   Structs.h

DESCRIPTION:
   Declaration of structures used by the Qualcomm Linux USB Network driver
   
FUNCTIONS:
   none

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

//---------------------------------------------------------------------------
// Pragmas
//---------------------------------------------------------------------------
#pragma once

//---------------------------------------------------------------------------
// Include Files
//---------------------------------------------------------------------------
#include <linux/etherdevice.h>
#include <linux/ethtool.h>
#include <linux/mii.h>
#include <linux/usb.h>
#include <linux/version.h>
#include <linux/cdev.h>
#include <linux/kthread.h>
#include <linux/poll.h>

#if (LINUX_VERSION_CODE <= KERNEL_VERSION( 2,6,24 ))
   #include "usbnet.h"
#else
   #include <linux/usb/usbnet.h>
#endif

#if (LINUX_VERSION_CODE > KERNEL_VERSION( 2,6,25 ))
   #include <linux/fdtable.h>
#else
   #include <linux/file.h>
#endif

// DBG macro
#define DBG_MACRO
extern int debug;

#define LONGSUNG_PRODUCT_UC8300     0x9b05
#define LONGSUNG_PRODUCT_UC9300     0x9b3c
#define LONGSUNG_PRODUCT_UC9507E    0x9b3e

#define LONGSUNG_VENDOR_ID			0x1c9e
#define LONGSUNG_EU_VENDOR_ID		0x2df3

//if disable dtr, disable this micro 
#define LS_ENABLE_DTR  //added by chenlei
//#define LS_REREGIST_DEVICE //added by chenlei for hongdian

#ifdef DBG_MACRO
#define DBG( format, arg... ) \
   if (debug == 1)\
   { \
		printk( KERN_INFO "===GobiNet:: %s(), Line=%d " format, __FUNCTION__, __LINE__ ,## arg ); \
   } \

#define PRINT_HEX_BYTE(id, data, len)\
	if (debug == 1)\
	{ \
		print_hex_dump_bytes("", id, data, len);\
	} \

#else
#define DBG( format, arg... ) 
#define PRINT_HEX_BYTE(id, data, len)
#endif
// Used in recursion, defined later below
struct sGobiUSBNet;

/*=========================================================================*/
// Struct sReadMemList
//
//    Structure that defines an entry in a Read Memory linked list
/*=========================================================================*/
typedef struct sReadMemList
{
   /* Data buffer */
   void *                     mpData;
   
   /* Transaction ID */
   u16                        mTransactionID;

   /* Size of data buffer */
   u16                        mDataSize;

   /* Next entry in linked list */
   struct sReadMemList *      mpNext;

} sReadMemList;

/*=========================================================================*/
// Struct sNotifyList
//
//    Structure that defines an entry in a Notification linked list
/*=========================================================================*/
typedef struct sNotifyList
{
   /* Function to be run when data becomes available */
   void                  (* mpNotifyFunct)(struct sGobiUSBNet *, u16, void *);
   
   /* Transaction ID */
   u16                   mTransactionID;

   /* Data to provide as parameter to mpNotifyFunct */
   void *                mpData;
   
   /* Next entry in linked list */
   struct sNotifyList *  mpNext;

} sNotifyList;

/*=========================================================================*/
// Struct sURBList
//
//    Structure that defines an entry in a URB linked list
/*=========================================================================*/
typedef struct sURBList
{
   /* The current URB */
   struct urb *       mpURB;

   /* Next entry in linked list */
   struct sURBList *  mpNext;

} sURBList;

/*=========================================================================*/
// Struct sClientMemList
//
//    Structure that defines an entry in a Client Memory linked list
//      Stores data specific to a Service Type and Client ID
/*=========================================================================*/
typedef struct sClientMemList
{
   /* Client ID for this Client */
   u16                          mClientID;

   /* Linked list of Read entries */
   /*    Stores data read from device before sending to client */
   sReadMemList *               mpList;
   
   /* Linked list of Notification entries */
   /*    Stores notification functions to be run as data becomes 
         available or the device is removed */
   sNotifyList *                mpReadNotifyList;

   /* Linked list of URB entries */
   /*    Stores pointers to outstanding URBs which need canceled 
         when the client is deregistered or the device is removed */
   sURBList *                   mpURBList;
   
   /* Next entry in linked list */
   struct sClientMemList *      mpNext;

   /* Wait queue object for poll() */
   wait_queue_head_t    mWaitQueue;

} sClientMemList;

/*=========================================================================*/
// Struct sURBSetupPacket
//
//    Structure that defines a USB Setup packet for Control URBs
//    Taken from USB CDC specifications
/*=========================================================================*/
typedef struct sURBSetupPacket
{
   /* Request type */
   u8    mRequestType;

   /* Request code */
   u8    mRequestCode;

   /* Value */
   u16   mValue;

   /* Index */
   u16   mIndex;

   /* Length of Control URB */
   u16   mLength;

} sURBSetupPacket;

// Common value for sURBSetupPacket.mLength

// not for Interrupt Endpoint
#define DEFAULT_READ_URB_LENGTH 0x1000

/*=========================================================================*/
// Struct sAutoPM
//
//    Structure used to manage AutoPM thread which determines whether the
//    device is in use or may enter autosuspend.  Also submits net 
//    transmissions asynchronously.
/*=========================================================================*/
#ifdef CONFIG_PM
#if (LINUX_VERSION_CODE < KERNEL_VERSION( 2,6,29 ))

typedef struct sAutoPM
{
   /* Thread for atomic autopm function */
   struct task_struct *       mpThread;

   /* Signal for completion when it's time for the thread to work */
   struct completion          mThreadDoWork;

   /* Time to exit? */
   bool                       mbExit;

   /* List of URB's queued to be sent to the device */
   sURBList *                 mpURBList;

   /* URB list lock (for adding and removing elements) */
   spinlock_t                 mURBListLock;

   /* Length of the URB list */
   atomic_t                   mURBListLen;
   
   /* Active URB */
   struct urb *               mpActiveURB;

   /* Active URB lock (for adding and removing elements) */
   spinlock_t                 mActiveURBLock;
   
   /* Duplicate pointer to USB device interface */
   struct usb_interface *     mpIntf;

} sAutoPM;

#endif
#endif /* CONFIG_PM */

/*=========================================================================*/
// Struct sQMIDev
//
//    Structure that defines the data for the QMI device
/*=========================================================================*/
typedef struct sQMIDev
{
   /* Device number */
   dev_t                      mDevNum;

   /* Device class */
   struct class *             mpDevClass;

   /* cdev struct */
   struct cdev                mCdev;

   /* is mCdev initialized? */
   bool                       mbCdevIsInitialized;

   /* Pointer to read URB */
   struct urb *               mpReadURB;

   /* Read setup packet */
   sURBSetupPacket *          mpReadSetupPacket;

   /* Read buffer attached to current read URB */
   void *                     mpReadBuffer;
   
   /* Inturrupt URB */
   /*    Used to asynchronously notify when read data is available */
   struct urb *               mpIntURB;

   /* Buffer used by Inturrupt URB */
   void *                     mpIntBuffer;
   
   /* Pointer to memory linked list for all clients */
   sClientMemList *           mpClientMemList;
   
   /* Spinlock for client Memory entries */
   spinlock_t                 mClientMemLock;

   /* Transaction ID associated with QMICTL "client" */
   atomic_t                   mQMICTLTransactionID;

//wzm
      /*MuxId*/
   unsigned short             MuxId;

   unsigned int               IPv4Addr;

   unsigned int               IPv4SubnetMask;

   unsigned int               IPv4Gateway;

   unsigned int               IPv4PrimaryDNS;

   unsigned int               IPv4SecondaryDNS;

   unsigned long  mIntfNum;  //added by chenlei for bind mux

//wzm
} sQMIDev;

/*=========================================================================*/
// Struct sEndpoints
//
//    Structure that defines the endpoints of the device
/*=========================================================================*/
typedef struct sEndpoints
{
   /* Interface number */
   unsigned               mIntfNum;

   /* Interrupt in endpoint */
   unsigned               mIntInEndp;

   /* Bulk in endpoint */
   unsigned               mBlkInEndp;

   /* Bulk out endpoint */
   unsigned               mBlkOutEndp;

} sEndpoints;

/*=========================================================================*/
// Struct sGobiUSBNet
//
//    Structure that defines the data associated with the Qualcomm USB device
/*=========================================================================*/
typedef struct sGobiUSBNet
{
    atomic_t refcount;
   /* Net device structure */
   struct usbnet *        mpNetDev;
#if 1 //def DATA_MODE_RP
	  /* QMI "device" work in IP Mode or ETH Mode */
	  bool					 mbRawIPMode;
#endif
   struct completion mQMIReadyCompletion;
   bool                   mbQMIReady;

   /* Usb device interface */
   struct usb_interface * mpIntf;

   /* Endpoint numbers */
   sEndpoints *           mpEndpoints;

   /* Pointers to usbnet_open and usbnet_stop functions */
   int                  (* mpUSBNetOpen)(struct net_device *);
   int                  (* mpUSBNetStop)(struct net_device *);
   
   /* Reason(s) why interface is down */
   /* Used by Gobi*DownReason */
   unsigned long          mDownReason;
#define NO_NDIS_CONNECTION    0
#define CDC_CONNECTION_SPEED  1
#define DRIVER_SUSPENDED      2
#define NET_IFACE_STOPPED     3

   /* QMI "device" status */
   bool                   mbQMIValid;

   /* QMI "device" memory */
   sQMIDev                mQMIDev;

   /* QMI "device" memory for MUXING*/
   sQMIDev                mQMIMUXDev[1];

   /* Device MEID */
   char                   mMEID[14];
   
#ifdef CONFIG_PM
   #if (LINUX_VERSION_CODE < KERNEL_VERSION( 2,6,29 ))   
   /* AutoPM thread */
   sAutoPM                mAutoPM;
#endif
#endif /* CONFIG_PM */

   /*QMAP DL Aggregation information */
   unsigned int      ULAggregationMaxDatagram;
   unsigned int    ULAggregationMaxSize;
} sGobiUSBNet;

/*=========================================================================*/
// Struct sQMIFilpStorage
//
//    Structure that defines the storage each file handle contains
//       Relates the file handle to a client
/*=========================================================================*/
typedef struct sQMIFilpStorage
{
   /* Client ID */
   u16                  mClientID;
   
   /* Device pointer */
   sGobiUSBNet *        mpDev;

} sQMIFilpStorage;



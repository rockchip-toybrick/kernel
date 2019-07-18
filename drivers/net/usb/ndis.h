typedef int            BOOL, BOOLEAN, *PINT;     /* f */
typedef unsigned char  BYTE, *PUCHAR;     /* b */
typedef unsigned int   UINT;     /* ui */
typedef unsigned short USHORT;   /* us */
typedef unsigned long  ULONG;    /* ul */
typedef unsigned char UCHAR;
typedef char CHAR, *PCHAR;
typedef short SHORT;
typedef long LONG;
typedef int INT;
typedef SHORT *PSHORT;  // winnt
typedef LONG *PLONG;    // winnt
typedef void VOID, *PVOID;
typedef ULONG* PULONG;

typedef signed char         INT8;
typedef unsigned char       UINT8;
typedef signed short        INT16;
typedef unsigned short      UINT16;
typedef unsigned short      WORD;
typedef signed int          INT32;
typedef unsigned int        UINT32;
typedef unsigned long       DWORD;
typedef unsigned long long ULONG64;
typedef void *LIST_ENTRY, *PIRP, *PDEVICE_OBJECT;
#define QCNET_DbgPrint(mask,level,_x_) do {} while(0)
#define FALSE	0
#define TRUE	1
#define QC_IP_MODE 1
typedef int NDIS_STATUS, *PNDIS_STATUS, NDIS_OID, NTSTATUS; // note default size

struct _MP_ADAPTER
{
   //CHAR                    PortName[32];
   //int USBDo;
	UCHAR                   ClientId[0xFF+1];
	PVOID    WdsIpClientContext;  // PMPIOC_DEV_INFO
};

struct _MPIOC_DEV_INFO
{
   UCHAR          ClientId;
   UCHAR          QMIType;
};

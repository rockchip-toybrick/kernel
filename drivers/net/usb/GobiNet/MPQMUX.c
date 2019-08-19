#include <linux/string.h>
#include <linux/kernel.h>
//#include <linux/printk.h>

#include "MPQMI.h"
#include "MPQMUX.h"
#include "MPQCTL.h"

//added by chenlei for log begin
extern int debug;
#define printf( format, arg... ) \
   if (debug == 1)\
   { \
		printk( KERN_INFO format, ## arg ); \
   } \
//#define printf printk
//added by chenlei for log end

extern int sprintf(char *, const char*, ...);
extern bool data_connect ;

// To retrieve the ith (Index) TLV
PQCQMUX_TLV MPQMUX_GetTLV
(
   PQMUX_MSG   qmux_msg,
   int         Index,          // zero-based
   PINT        RemainingLength // length including the returned TLV
)
{
   int         i;
   PCHAR       dataPtr;
   PQCQMUX_TLV tlv = NULL;
   int         len = qmux_msg->QMUXMsgHdr.Length;  // length of TLVs

   QCNET_DbgPrint
   (
      MP_DBG_MASK_OID_QMI,
      MP_DBG_LEVEL_TRACE,
      ("<%s> -->_GetTLV: 0x%x (%dB)\n", pAdapter->PortName,
             qmux_msg->QMUXMsgHdr.Type, qmux_msg->QMUXMsgHdr.Length)
   );

   if (len <=0 )
   {
      QCNET_DbgPrint
      (
         MP_DBG_MASK_CONTROL,
         MP_DBG_LEVEL_ERROR,
         ("<%s> _GetTLV: msg too short [0x%x, %dB]\n", pAdapter->PortName,
           qmux_msg->QMUXMsgHdr.Type, len)
      );
      return NULL;
   }

   dataPtr = (PCHAR)&(qmux_msg->QMUXMsgHdr.Length);
   dataPtr += sizeof(USHORT);  // point to the 1st TLV

   for (i = 0; i <= Index; i++)
   {
      *RemainingLength = len;
      len -= sizeof(QMI_TLV_HDR);
      if (len >= 0)
      {
         tlv = (PQCQMUX_TLV)dataPtr;
         dataPtr = (PCHAR)&(tlv->Value);
         dataPtr += tlv->Length;   // point to next TLV
         len -= tlv->Length;       // len of remaining TLVs
      }
      else
      {
         QCNET_DbgPrint
         (
            MP_DBG_MASK_CONTROL,
            MP_DBG_LEVEL_ERROR,
            ("<%s> _GetTLV: msg exhausted too early: [0x%x, %dB, %d/%d]\n", pAdapter->PortName,
              qmux_msg->QMUXMsgHdr.Type, len, i, Index)
         );
         tlv = NULL;
         break;
      }
   }

   if (tlv != NULL)
   {
      
      QCNET_DbgPrint
      (
         MP_DBG_MASK_OID_QMI,
         MP_DBG_LEVEL_TRACE,
         ("<%s> _GetTLV: 0x%p (0x%x, %dB) rem %dB %d/%d\n", pAdapter->PortName, tlv,
                 tlv->Type, tlv->Length, *RemainingLength, i, Index)
      );
   }

   return tlv;
}  // MPQMUX_GetTLV

// To retrieve the next TLV
PQCQMUX_TLV MPQMUX_GetNextTLV
(
   PQCQMUX_TLV CurrentTLV,
   PINT       RemainingLength // length including CurrentTLV
)
{
   PQCQMUX_TLV nextTlv = NULL;
   PCHAR dataPtr;

   
   QCNET_DbgPrint
   (
      MP_DBG_MASK_OID_QMI,
      MP_DBG_LEVEL_TRACE,
      ("<%s> -->_GetNextTLV: 0x%x (%dB)\n", pAdapter->PortName,
             CurrentTLV->Type, CurrentTLV->Length)
   );

   // skip current TLV header
   if (*RemainingLength > sizeof(QMI_TLV_HDR))
   {
      *RemainingLength -= sizeof(QMI_TLV_HDR);
   }
   else
   {
      QCNET_DbgPrint
      (
         MP_DBG_MASK_CONTROL,
         MP_DBG_LEVEL_ERROR,
         ("<%s> _GetNextTLV: no more TLV\n", pAdapter->PortName)
      );
      return NULL;
   }

   if (*RemainingLength > CurrentTLV->Length)
   {
      // skip current TLV body
      *RemainingLength -= CurrentTLV->Length;
      dataPtr = (PCHAR)&(CurrentTLV->Value);
      dataPtr += CurrentTLV->Length;
      nextTlv = (PQCQMUX_TLV)dataPtr;
   }
   else
   {
      QCNET_DbgPrint
      (
         MP_DBG_MASK_CONTROL,
         MP_DBG_LEVEL_ERROR,
         ("<%s> _GetNextTLV: no more TLV %d/%d\n", pAdapter->PortName,
           *RemainingLength, CurrentTLV->Length)
      );
   }

   if (nextTlv != NULL)
   {
      
      QCNET_DbgPrint
      (
         MP_DBG_MASK_OID_QMI,
         MP_DBG_LEVEL_TRACE,
         ("<%s> _GetNextTLV: 0x%p (0x%x, %dB) rem %dB\n", pAdapter->PortName, nextTlv,
              nextTlv->Type, nextTlv->Length, *RemainingLength)
      );
   }
   else
   {
      
      QCNET_DbgPrint
      (
         MP_DBG_MASK_OID_QMI,
         MP_DBG_LEVEL_TRACE,
         ("<%s> _GetNextTLV: NULL rem %dB\n", pAdapter->PortName, *RemainingLength)
      );
   }

   return nextTlv;
}  // MPQMUX_GetNextTLV


typedef struct {
    UINT type;
    const char *name;
} QMI_NAME_T;

#define qmi_name_item(type) {type, #type}

static const QMI_NAME_T qmi_IFType[] = {
{USB_CTL_MSG_TYPE_QMI, "USB_CTL_MSG_TYPE_QMI"},
};

static const QMI_NAME_T qmi_CtlFlags[] = {
qmi_name_item(QMICTL_CTL_FLAG_CMD),
qmi_name_item(QCQMI_CTL_FLAG_SERVICE),
};

static const QMI_NAME_T qmi_QMIType[] = {
qmi_name_item(QMUX_TYPE_CTL),
qmi_name_item(QMUX_TYPE_WDS),
qmi_name_item(QMUX_TYPE_DMS),
qmi_name_item(QMUX_TYPE_NAS),
qmi_name_item(QMUX_TYPE_QOS),
qmi_name_item(QMUX_TYPE_WMS),
qmi_name_item(QMUX_TYPE_PDS),
qmi_name_item(QMUX_TYPE_WDS_ADMIN),
};

static const QMI_NAME_T qmi_ctl_CtlFlags[] = {
qmi_name_item(QMICTL_FLAG_REQUEST),
qmi_name_item(QMICTL_FLAG_RESPONSE),
qmi_name_item(QMICTL_FLAG_INDICATION),
};

static const QMI_NAME_T qmux_ctl_QMICTLType[] = {
// QMICTL Type
qmi_name_item(QMICTL_SET_INSTANCE_ID_REQ), //    0x0020
qmi_name_item(QMICTL_SET_INSTANCE_ID_RESP), //   0x0020
qmi_name_item(QMICTL_GET_VERSION_REQ), //        0x0021
qmi_name_item(QMICTL_GET_VERSION_RESP), //       0x0021
qmi_name_item(QMICTL_GET_CLIENT_ID_REQ), //      0x0022
qmi_name_item(QMICTL_GET_CLIENT_ID_RESP), //     0x0022
qmi_name_item(QMICTL_RELEASE_CLIENT_ID_REQ), //  0x0023
qmi_name_item(QMICTL_RELEASE_CLIENT_ID_RESP), // 0x0023
qmi_name_item(QMICTL_REVOKE_CLIENT_ID_IND), //   0x0024
qmi_name_item(QMICTL_INVALID_CLIENT_ID_IND), //  0x0025
qmi_name_item(QMICTL_SET_DATA_FORMAT_REQ), //    0x0026
qmi_name_item(QMICTL_SET_DATA_FORMAT_RESP), //   0x0026
qmi_name_item(QMICTL_SYNC_REQ), //               0x0027
qmi_name_item(QMICTL_SYNC_RESP), //              0x0027
qmi_name_item(QMICTL_SYNC_IND), //               0x0027
};

static const QMI_NAME_T qmux_CtlFlags[] = {
qmi_name_item(QMUX_CTL_FLAG_TYPE_CMD),
qmi_name_item(QMUX_CTL_FLAG_TYPE_RSP),
qmi_name_item(QMUX_CTL_FLAG_TYPE_IND),
};


static const QMI_NAME_T qmux_wds_Type[] = {
qmi_name_item(QMIWDS_SET_EVENT_REPORT_REQ), //           0x0001
qmi_name_item(QMIWDS_SET_EVENT_REPORT_RESP), //          0x0001
qmi_name_item(QMIWDS_EVENT_REPORT_IND), //               0x0001
qmi_name_item(QMIWDS_START_NETWORK_INTERFACE_REQ), //    0x0020
qmi_name_item(QMIWDS_START_NETWORK_INTERFACE_RESP), //   0x0020
qmi_name_item(QMIWDS_STOP_NETWORK_INTERFACE_REQ), //     0x0021
qmi_name_item(QMIWDS_STOP_NETWORK_INTERFACE_RESP), //    0x0021
qmi_name_item(QMIWDS_GET_PKT_SRVC_STATUS_REQ), //        0x0022
qmi_name_item(QMIWDS_GET_PKT_SRVC_STATUS_RESP), //       0x0022
qmi_name_item(QMIWDS_GET_PKT_SRVC_STATUS_IND), //        0x0022  
qmi_name_item(QMIWDS_GET_CURRENT_CHANNEL_RATE_REQ), //   0x0023  
qmi_name_item(QMIWDS_GET_CURRENT_CHANNEL_RATE_RESP), //  0x0023  
qmi_name_item(QMIWDS_GET_PKT_STATISTICS_REQ), //         0x0024  
qmi_name_item(QMIWDS_GET_PKT_STATISTICS_RESP), //        0x0024  
qmi_name_item(QMIWDS_MODIFY_PROFILE_SETTINGS_REQ), //    0x0028
qmi_name_item(QMIWDS_MODIFY_PROFILE_SETTINGS_RESP), //   0x0028
qmi_name_item(QMIWDS_GET_DEFAULT_SETTINGS_REQ), //       0x002C
qmi_name_item(QMIWDS_GET_DEFAULT_SETTINGS_RESP), //      0x002C
qmi_name_item(QMIWDS_GET_RUNTIME_SETTINGS_REQ), //       0x002D
qmi_name_item(QMIWDS_GET_RUNTIME_SETTINGS_RESP), //      0x002D
qmi_name_item(QMIWDS_GET_MIP_MODE_REQ), //               0x002F
qmi_name_item(QMIWDS_GET_MIP_MODE_RESP), //              0x002F
qmi_name_item(QMIWDS_GET_DATA_BEARER_REQ), //            0x0037
qmi_name_item(QMIWDS_GET_DATA_BEARER_RESP), //           0x0037
qmi_name_item(QMIWDS_DUN_CALL_INFO_REQ), //              0x0038
qmi_name_item(QMIWDS_DUN_CALL_INFO_RESP), //             0x0038
qmi_name_item(QMIWDS_DUN_CALL_INFO_IND), //              0x0038
qmi_name_item(QMIWDS_SET_CLIENT_IP_FAMILY_PREF_REQ), //  0x004D  
qmi_name_item(QMIWDS_SET_CLIENT_IP_FAMILY_PREF_RESP), // 0x004D  
qmi_name_item(QMIWDS_BIND_MUX_DATA_PORT_REQ), //         0x00A2  
qmi_name_item(QMIWDS_BIND_MUX_DATA_PORT_RESP), //        0x00A2  
};

static const QMI_NAME_T qmux_dms_Type[] = {
// ======================= DMS ==============================
qmi_name_item(QMIDMS_SET_EVENT_REPORT_REQ), //           0x0001
qmi_name_item(QMIDMS_SET_EVENT_REPORT_RESP), //          0x0001
qmi_name_item(QMIDMS_EVENT_REPORT_IND), //               0x0001
qmi_name_item(QMIDMS_GET_DEVICE_CAP_REQ), //             0x0020
qmi_name_item(QMIDMS_GET_DEVICE_CAP_RESP), //            0x0020
qmi_name_item(QMIDMS_GET_DEVICE_MFR_REQ), //             0x0021
qmi_name_item(QMIDMS_GET_DEVICE_MFR_RESP), //            0x0021
qmi_name_item(QMIDMS_GET_DEVICE_MODEL_ID_REQ), //        0x0022
qmi_name_item(QMIDMS_GET_DEVICE_MODEL_ID_RESP), //       0x0022
qmi_name_item(QMIDMS_GET_DEVICE_REV_ID_REQ), //          0x0023
qmi_name_item(QMIDMS_GET_DEVICE_REV_ID_RESP), //         0x0023
qmi_name_item(QMIDMS_GET_MSISDN_REQ), //                 0x0024
qmi_name_item(QMIDMS_GET_MSISDN_RESP), //                0x0024
qmi_name_item(QMIDMS_GET_DEVICE_SERIAL_NUMBERS_REQ), //  0x0025
qmi_name_item(QMIDMS_GET_DEVICE_SERIAL_NUMBERS_RESP), // 0x0025
qmi_name_item(QMIDMS_UIM_SET_PIN_PROTECTION_REQ), //     0x0027
qmi_name_item(QMIDMS_UIM_SET_PIN_PROTECTION_RESP), //    0x0027
qmi_name_item(QMIDMS_UIM_VERIFY_PIN_REQ), //             0x0028
qmi_name_item(QMIDMS_UIM_VERIFY_PIN_RESP), //            0x0028
qmi_name_item(QMIDMS_UIM_UNBLOCK_PIN_REQ), //            0x0029
qmi_name_item(QMIDMS_UIM_UNBLOCK_PIN_RESP), //           0x0029
qmi_name_item(QMIDMS_UIM_CHANGE_PIN_REQ), //             0x002A
qmi_name_item(QMIDMS_UIM_CHANGE_PIN_RESP), //            0x002A
qmi_name_item(QMIDMS_UIM_GET_PIN_STATUS_REQ), //         0x002B
qmi_name_item(QMIDMS_UIM_GET_PIN_STATUS_RESP), //        0x002B
qmi_name_item(QMIDMS_GET_DEVICE_HARDWARE_REV_REQ), //    0x002C
qmi_name_item(QMIDMS_GET_DEVICE_HARDWARE_REV_RESP), //   0x002C
qmi_name_item(QMIDMS_GET_OPERATING_MODE_REQ), //         0x002D 
qmi_name_item(QMIDMS_GET_OPERATING_MODE_RESP), //        0x002D 
qmi_name_item(QMIDMS_SET_OPERATING_MODE_REQ), //         0x002E 
qmi_name_item(QMIDMS_SET_OPERATING_MODE_RESP), //        0x002E 
qmi_name_item(QMIDMS_GET_ACTIVATED_STATUS_REQ), //       0x0031 
qmi_name_item(QMIDMS_GET_ACTIVATED_STATUS_RESP), //      0x0031 
qmi_name_item(QMIDMS_ACTIVATE_AUTOMATIC_REQ), //         0x0032
qmi_name_item(QMIDMS_ACTIVATE_AUTOMATIC_RESP), //        0x0032
qmi_name_item(QMIDMS_ACTIVATE_MANUAL_REQ), //            0x0033
qmi_name_item(QMIDMS_ACTIVATE_MANUAL_RESP), //           0x0033
qmi_name_item(QMIDMS_UIM_GET_ICCID_REQ), //              0x003C 
qmi_name_item(QMIDMS_UIM_GET_ICCID_RESP), //             0x003C 
qmi_name_item(QMIDMS_UIM_GET_CK_STATUS_REQ), //          0x0040
qmi_name_item(QMIDMS_UIM_GET_CK_STATUS_RESP), //         0x0040
qmi_name_item(QMIDMS_UIM_SET_CK_PROTECTION_REQ), //      0x0041
qmi_name_item(QMIDMS_UIM_SET_CK_PROTECTION_RESP), //     0x0041
qmi_name_item(QMIDMS_UIM_UNBLOCK_CK_REQ), //             0x0042
qmi_name_item(QMIDMS_UIM_UNBLOCK_CK_RESP), //            0x0042
qmi_name_item(QMIDMS_UIM_GET_IMSI_REQ), //               0x0043 
qmi_name_item(QMIDMS_UIM_GET_IMSI_RESP), //              0x0043 
qmi_name_item(QMIDMS_UIM_GET_STATE_REQ), //              0x0044 
qmi_name_item(QMIDMS_UIM_GET_STATE_RESP), //             0x0044 
qmi_name_item(QMIDMS_GET_BAND_CAP_REQ), //               0x0045 
qmi_name_item(QMIDMS_GET_BAND_CAP_RESP), //              0x0045 
};

static const QMI_NAME_T qmux_nas_Type[] = {
// ======================= NAS ==============================
qmi_name_item(QMINAS_SET_EVENT_REPORT_REQ), //             0x0002
qmi_name_item(QMINAS_SET_EVENT_REPORT_RESP), //            0x0002
qmi_name_item(QMINAS_EVENT_REPORT_IND), //                 0x0002
qmi_name_item(QMINAS_GET_SIGNAL_STRENGTH_REQ), //          0x0020
qmi_name_item(QMINAS_GET_SIGNAL_STRENGTH_RESP), //         0x0020
qmi_name_item(QMINAS_PERFORM_NETWORK_SCAN_REQ), //         0x0021
qmi_name_item(QMINAS_PERFORM_NETWORK_SCAN_RESP), //        0x0021
qmi_name_item(QMINAS_INITIATE_NW_REGISTER_REQ), //         0x0022
qmi_name_item(QMINAS_INITIATE_NW_REGISTER_RESP), //        0x0022
qmi_name_item(QMINAS_INITIATE_ATTACH_REQ), //              0x0023
qmi_name_item(QMINAS_INITIATE_ATTACH_RESP), //             0x0023
qmi_name_item(QMINAS_GET_SERVING_SYSTEM_REQ), //           0x0024
qmi_name_item(QMINAS_GET_SERVING_SYSTEM_RESP), //          0x0024
qmi_name_item(QMINAS_SERVING_SYSTEM_IND), //               0x0024
qmi_name_item(QMINAS_GET_HOME_NETWORK_REQ), //             0x0025
qmi_name_item(QMINAS_GET_HOME_NETWORK_RESP), //            0x0025
qmi_name_item(QMINAS_GET_PREFERRED_NETWORK_REQ), //        0x0026
qmi_name_item(QMINAS_GET_PREFERRED_NETWORK_RESP), //       0x0026
qmi_name_item(QMINAS_SET_PREFERRED_NETWORK_REQ), //        0x0027
qmi_name_item(QMINAS_SET_PREFERRED_NETWORK_RESP), //       0x0027
qmi_name_item(QMINAS_GET_FORBIDDEN_NETWORK_REQ), //        0x0028
qmi_name_item(QMINAS_GET_FORBIDDEN_NETWORK_RESP), //       0x0028
qmi_name_item(QMINAS_SET_FORBIDDEN_NETWORK_REQ), //        0x0029
qmi_name_item(QMINAS_SET_FORBIDDEN_NETWORK_RESP), //       0x0029
qmi_name_item(QMINAS_SET_TECHNOLOGY_PREF_REQ), //          0x002A
qmi_name_item(QMINAS_SET_TECHNOLOGY_PREF_RESP), //         0x002A
qmi_name_item(QMINAS_GET_RF_BAND_INFO_REQ), //             0x0031
qmi_name_item(QMINAS_GET_RF_BAND_INFO_RESP), //            0x0031
qmi_name_item(QMINAS_GET_PLMN_NAME_REQ), //                0x0044
qmi_name_item(QMINAS_GET_PLMN_NAME_RESP), //               0x0044
};

static const QMI_NAME_T qmux_wms_Type[] = {
// ======================= WMS ==============================
qmi_name_item(QMIWMS_SET_EVENT_REPORT_REQ), //           0x0001
qmi_name_item(QMIWMS_SET_EVENT_REPORT_RESP), //          0x0001
qmi_name_item(QMIWMS_EVENT_REPORT_IND), //               0x0001
qmi_name_item(QMIWMS_RAW_SEND_REQ), //                   0x0020
qmi_name_item(QMIWMS_RAW_SEND_RESP), //                  0x0020
qmi_name_item(QMIWMS_RAW_WRITE_REQ), //                  0x0021
qmi_name_item(QMIWMS_RAW_WRITE_RESP), //                 0x0021
qmi_name_item(QMIWMS_RAW_READ_REQ), //                   0x0022
qmi_name_item(QMIWMS_RAW_READ_RESP), //                  0x0022
qmi_name_item(QMIWMS_MODIFY_TAG_REQ), //                 0x0023
qmi_name_item(QMIWMS_MODIFY_TAG_RESP), //                0x0023
qmi_name_item(QMIWMS_DELETE_REQ), //                     0x0024
qmi_name_item(QMIWMS_DELETE_RESP), //                    0x0024
qmi_name_item(QMIWMS_GET_MESSAGE_PROTOCOL_REQ), //       0x0030
qmi_name_item(QMIWMS_GET_MESSAGE_PROTOCOL_RESP), //      0x0030
qmi_name_item(QMIWMS_LIST_MESSAGES_REQ), //              0x0031
qmi_name_item(QMIWMS_LIST_MESSAGES_RESP), //             0x0031
qmi_name_item(QMIWMS_GET_SMSC_ADDRESS_REQ), //           0x0034
qmi_name_item(QMIWMS_GET_SMSC_ADDRESS_RESP), //          0x0034
qmi_name_item(QMIWMS_SET_SMSC_ADDRESS_REQ), //           0x0035
qmi_name_item(QMIWMS_SET_SMSC_ADDRESS_RESP), //          0x0035
qmi_name_item(QMIWMS_GET_STORE_MAX_SIZE_REQ), //         0x0036
qmi_name_item(QMIWMS_GET_STORE_MAX_SIZE_RESP), //        0x0036
};

static const QMI_NAME_T qmux_wds_admin_Type[] = {
qmi_name_item(QMIWDS_ADMIN_SET_DATA_FORMAT_REQ), //      0x0020
qmi_name_item(QMIWDS_ADMIN_SET_DATA_FORMAT_RESP), //     0x0020
qmi_name_item(QMIWDS_ADMIN_GET_DATA_FORMAT_REQ), //      0x0021
qmi_name_item(QMIWDS_ADMIN_GET_DATA_FORMAT_RESP), //     0x0021
qmi_name_item(QMIWDS_ADMIN_SET_QMAP_SETTINGS_REQ), //    0x002B
qmi_name_item(QMIWDS_ADMIN_SET_QMAP_SETTINGS_RESP), //   0x002B
qmi_name_item(QMIWDS_ADMIN_GET_QMAP_SETTINGS_REQ), //    0x002C
qmi_name_item(QMIWDS_ADMIN_GET_QMAP_SETTINGS_RESP), //   0x002C
};

static const char * qmi_name_get(const QMI_NAME_T *table, size_t size, int type, const char *tag) {
    static char unknow[40];
    size_t i;

    if (qmux_CtlFlags == table) {
        if (!strcmp(tag, "_REQ"))
            tag = "_CMD";
        else  if (!strcmp(tag, "_RESP"))
            tag = "_RSP";
    }
    
    for (i = 0; i < size; i++) {
        if (table[i].type == type) {
            if (!tag || (strstr(table[i].name, tag)))
                return table[i].name;
        }
    }
    sprintf(unknow, "unknow_%x", type);
    return unknow;
}

#define QMI_NAME(table, type) qmi_name_get(table, sizeof(table) / sizeof(table[0]), type, 0)
#define QMUX_NAME(table, type, tag) qmi_name_get(table, sizeof(table) / sizeof(table[0]), type, tag)

static UCHAR tlv_buf[1024];
int parse_qmi(PUCHAR qmi, ULONG TotalDataLength) 
{
    PQCQMUX_TLV                 tlv;
    INT                        len = 0;
    BOOL done = FALSE;
    PQCQMI_HDR qmi_hdr = (PQCQMI_HDR)qmi;
    PQCQMUX qmux_hdr = (PQCQMUX) (qmi_hdr + 1);
    PQCQMICTL_MSG qmictl_msg_hdr =  (PQCQMICTL_MSG) (qmi_hdr + 1);
    PQMUX_MSG Message = (PQMUX_MSG) (&qmux_hdr->Message);
    CHAR *tag;
    
    //printf("QCQMI_HDR-----------------------------------------\n");
    //printf("IFType:             %02x\t\t%s\n", qmi_hdr->IFType, QMI_NAME(qmi_IFType, qmi_hdr->IFType));
    //printf("Length:             %04x\n", qmi_hdr->Length);
    //printf("CtlFlags:           %02x\t\t%s\n", qmi_hdr->CtlFlags, QMI_NAME(qmi_CtlFlags, qmi_hdr->CtlFlags));
    //printf("QMIType:            %02x\t\t%s\n", qmi_hdr->QMIType, QMI_NAME(qmi_QMIType, qmi_hdr->QMIType));
    //printf("ClientId:           %02x\n", qmi_hdr->ClientId);

    if ((qmi_hdr->QMIType == QMUX_TYPE_CTL) ) {
        //printf("QCQMICTL_MSG--------------------------------------------\n");
        //printf("CtlFlags:           %02x\t\t%s\n", qmictl_msg_hdr->CtlFlags, QMI_NAME(qmi_ctl_CtlFlags, qmictl_msg_hdr->CtlFlags));
        //printf("TransactionId:      %02x\n", qmictl_msg_hdr->TransactionId);
        switch (qmictl_msg_hdr->CtlFlags) {
            case QMICTL_FLAG_REQUEST: tag = "_REQ"; break;
            case QMICTL_FLAG_RESPONSE: tag = "_RESP"; break;
            case QMICTL_FLAG_INDICATION: tag = "_IND"; break;
            default: tag = 0; break;
       }
        printf("QMICTLType:         %04x\t%s\n",  cpu_to_le16(qmictl_msg_hdr->QMICTLType),
        (QMUX_NAME(qmux_ctl_QMICTLType, cpu_to_le16(qmictl_msg_hdr->QMICTLType), tag)));     
        printf("Length:             %04x\n",  cpu_to_le16(qmictl_msg_hdr->Length));
        Message = (PQMUX_MSG) (&qmictl_msg_hdr->QMICTLType);     
    }
    else
    {
        //printf("QCQMUX--------------------------------------------\n");
        switch (qmux_hdr->CtlFlags&QMUX_CTL_FLAG_MASK_TYPE) {
            case QMUX_CTL_FLAG_TYPE_CMD: tag = "_REQ"; break;
            case QMUX_CTL_FLAG_TYPE_RSP: tag = "_RESP"; break;
            case QMUX_CTL_FLAG_TYPE_IND: tag = "_IND"; break;
            default: tag = 0; break;
       }
        //printf("CtlFlags:           %02x\t\t%s\n", qmux_hdr->CtlFlags, QMUX_NAME(qmux_CtlFlags, qmux_hdr->CtlFlags, tag));
        //printf("TransactionId:    %04x\n", qmux_hdr->TransactionId);

        //printf("QCQMUX_MSG_HDR-----------------------------------\n");
        switch (qmi_hdr->QMIType) {
            case QMUX_TYPE_DMS:
                printf("Type:               %04x\t%s\n", cpu_to_le16(Message->QMUXMsgHdr.Type),
                QMUX_NAME(qmux_dms_Type, cpu_to_le16(Message->QMUXMsgHdr.Type), tag));
            break;
            case QMUX_TYPE_NAS:
                printf("Type:               %04x\t%s\n", cpu_to_le16(Message->QMUXMsgHdr.Type),
                QMUX_NAME(qmux_nas_Type, cpu_to_le16(Message->QMUXMsgHdr.Type), tag));
            break;
            case QMUX_TYPE_WDS:
                printf("Type:               %04x\t%s\n", cpu_to_le16(Message->QMUXMsgHdr.Type),
                QMUX_NAME(qmux_wds_Type, cpu_to_le16(Message->QMUXMsgHdr.Type), tag));
            break;
            case QMUX_TYPE_WMS:
                printf("Type:               %04x\t%s\n", cpu_to_le16(Message->QMUXMsgHdr.Type),
                QMUX_NAME(qmux_wms_Type, cpu_to_le16(Message->QMUXMsgHdr.Type), tag));
            break;
            case QMUX_TYPE_WDS_ADMIN:
                printf("Type:               %04x\t%s\n", cpu_to_le16(Message->QMUXMsgHdr.Type),
                QMUX_NAME(qmux_wds_admin_Type, cpu_to_le16(Message->QMUXMsgHdr.Type), tag));
            break;
            case QMUX_TYPE_PDS:
            case QMUX_TYPE_QOS:
            case QMUX_TYPE_CTL:                
            default:
                printf("Type:               %04x\t%s\n", cpu_to_le16(Message->QMUXMsgHdr.Type), "unkonw!");
            break;    
        }
        printf("Length:             %04x\n", cpu_to_le16(Message->QMUXMsgHdr.Length));
    }

    if (Message->QMUXMsgHdr.Length) {
        //printf("QCQMUX_TLV-----------------------------------\n");
        printf("{Type,\tLength,\tValue}\n");

        tlv = MPQMUX_GetTLV(Message, 0, &len); // point to the first TLV
        while (tlv != NULL) {
            INT i;
            sprintf(tlv_buf, "{%02x,\t%04x,\t", tlv->Type, tlv->Length);
            for (i = 0; i < tlv->Length; i++) {
                PUCHAR value = ((unsigned char *)(&tlv->Value)) + i;
                if ((value - qmi) >= TotalDataLength) {
                    done =  TRUE;
                    sprintf(tlv_buf+strlen(tlv_buf), "...... ");
                    break;
               } else {
               
				   if ((qmi_hdr->QMIType==QMUX_TYPE_WDS)&&(Message->QMUXMsgHdr.Type == 0x0022)&&(tlv->Type == 0x01)&&(value[0]==0x02))
					   {
				   data_connect = true;
				   
				   //printk( "===www,GobiNet::%s ,Line %d:Message->QMUXMsgHdr.Type =0x%x, tlv->Type =0x%x ,value[0] =0x%x \n ",  __FUNCTION__,__LINE__, cpu_to_le16(Message->QMUXMsgHdr.Type),tlv->Type,value[0] );
				   printk( "===GobiNet:: data connect true,data_connect =%d \n ", data_connect);
			   }
			//if ((0x20 <= value[0]) && (value[0] <= 0x7f))
			//	sprintf(tlv_buf+strlen(tlv_buf), "%c ", value[0]);
			//else
				sprintf(tlv_buf+strlen(tlv_buf), "%02x ", value[0]);
                }
            }
            sprintf(tlv_buf+strlen(tlv_buf) - 1, "}");
            printf("%s\n", tlv_buf);

            if (done)
                break;

            tlv = MPQMUX_GetNextTLV(tlv, &len);
        }  // while
    }
    printf("\n");
   //MPQMI_ProcessInboundQMUX(0, qmi, TotalDataLength);
    return 0;
}

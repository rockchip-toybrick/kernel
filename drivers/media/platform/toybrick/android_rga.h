#ifndef _RGA_DRIVER_H_
#define _RGA_DRIVER_H_

#ifdef __cplusplus
extern "C"
{
#endif



#define RGA_BLIT_SYNC	0x5017
#define RGA_BLIT_ASYNC  0x5018
#define RGA_FLUSH       0x5019
#define RGA_GET_RESULT  0x501a
#define RGA_GET_VERSION 0x501b


#define RGA_REG_CTRL_LEN    0x8    /* 8  */
#define RGA_REG_CMD_LEN     0x1c   /* 28 */
#define RGA_CMD_BUF_SIZE    0x700  /* 16*28*4 */



#ifndef ENABLE
#define ENABLE 1
#endif


#ifndef DISABLE
#define DISABLE 0
#endif



/* RGA process mode enum */
enum
{    
    bitblt_mode               = 0x0,
    color_palette_mode        = 0x1,
    color_fill_mode           = 0x2,
    line_point_drawing_mode   = 0x3,
    blur_sharp_filter_mode    = 0x4,
    pre_scaling_mode          = 0x5,
    update_palette_table_mode = 0x6,
    update_patten_buff_mode   = 0x7,
};


enum
{
    rop_enable_mask          = 0x2,
    dither_enable_mask       = 0x8,
    fading_enable_mask       = 0x10,
    PD_enbale_mask           = 0x20,
};

enum
{
    yuv2rgb_mode0            = 0x0,     /* BT.601 MPEG */
    yuv2rgb_mode1            = 0x1,     /* BT.601 JPEG */
    yuv2rgb_mode2            = 0x2,     /* BT.709      */
};


/* RGA rotate mode */
enum 
{
    rotate_mode0             = 0x0,     /* no rotate */
    rotate_mode1             = 0x1,     /* rotate    */
    rotate_mode2             = 0x2,     /* x_mirror  */
    rotate_mode3             = 0x3,     /* y_mirror  */
};

enum
{
    color_palette_mode0      = 0x0,     /* 1K */
    color_palette_mode1      = 0x1,     /* 2K */
    color_palette_mode2      = 0x2,     /* 4K */
    color_palette_mode3      = 0x3,     /* 8K */
};

enum 
{
    BB_BYPASS   = 0x0,     /* no rotate */
    BB_ROTATE   = 0x1,     /* rotate    */
    BB_X_MIRROR = 0x2,     /* x_mirror  */
    BB_Y_MIRROR = 0x3      /* y_mirror  */
};

enum 
{
    nearby   = 0x0,     /* no rotate */
    bilinear = 0x1,     /* rotate    */
    bicubic  = 0x2,     /* x_mirror  */
};





/*
//          Alpha    Red     Green   Blue  
{  4, 32, {{32,24,   8, 0,  16, 8,  24,16 }}, GGL_RGBA },   // RK_FORMAT_RGBA_8888    
{  4, 24, {{ 0, 0,   8, 0,  16, 8,  24,16 }}, GGL_RGB  },   // RK_FORMAT_RGBX_8888    
{  3, 24, {{ 0, 0,   8, 0,  16, 8,  24,16 }}, GGL_RGB  },   // RK_FORMAT_RGB_888
{  4, 32, {{32,24,  24,16,  16, 8,   8, 0 }}, GGL_BGRA },   // RK_FORMAT_BGRA_8888
{  2, 16, {{ 0, 0,  16,11,  11, 5,   5, 0 }}, GGL_RGB  },   // RK_FORMAT_RGB_565        
{  2, 16, {{ 1, 0,  16,11,  11, 6,   6, 1 }}, GGL_RGBA },   // RK_FORMAT_RGBA_5551    
{  2, 16, {{ 4, 0,  16,12,  12, 8,   8, 4 }}, GGL_RGBA },   // RK_FORMAT_RGBA_4444
{  3, 24, {{ 0, 0,  24,16,  16, 8,   8, 0 }}, GGL_BGR  },   // RK_FORMAT_BGB_888

*/
typedef enum _Rga_SURF_FORMAT
{
    RK_FORMAT_RGBA_8888    = 0x0,
    RK_FORMAT_RGBX_8888    = 0x1,
    RK_FORMAT_RGB_888      = 0x2,
    RK_FORMAT_BGRA_8888    = 0x3,
    RK_FORMAT_RGB_565      = 0x4,
    RK_FORMAT_RGBA_5551    = 0x5,
    RK_FORMAT_RGBA_4444    = 0x6,
    RK_FORMAT_BGR_888      = 0x7,
    
    RK_FORMAT_YCbCr_422_SP = 0x8,    
    RK_FORMAT_YCbCr_422_P  = 0x9,    
    RK_FORMAT_YCbCr_420_SP = 0xa,    
    RK_FORMAT_YCbCr_420_P  = 0xb,

    RK_FORMAT_YCrCb_422_SP = 0xc,    
    RK_FORMAT_YCrCb_422_P  = 0xd,    
    RK_FORMAT_YCrCb_420_SP = 0xe,    
    RK_FORMAT_YCrCb_420_P  = 0xf,
    
    RK_FORMAT_BPP1         = 0x10,
    RK_FORMAT_BPP2         = 0x11,
    RK_FORMAT_BPP4         = 0x12,
    RK_FORMAT_BPP8         = 0x13,
    RK_FORMAT_YCbCr_420_SP_10B = 0x20,
    RK_FORMAT_YCrCb_420_SP_10B = 0x21,
    RK_FORMAT_UNKNOWN       = 0x100, 
}RgaSURF_FORMAT;
    
    
typedef struct rga_img_info_t
{
    unsigned long yrgb_addr;      /* yrgb    mem addr         */
    unsigned long uv_addr;        /* cb/cr   mem addr         */
    unsigned long v_addr;         /* cr      mem addr         */
    unsigned int format;         //definition by RK_FORMAT
    unsigned short act_w;
    unsigned short act_h;
    unsigned short x_offset;
    unsigned short y_offset;
    
    unsigned short vir_w;
    unsigned short vir_h;
    
    unsigned short endian_mode; //for BPP
    unsigned short alpha_swap;
}
rga_img_info_t;


typedef struct mdp_img_act
{
    unsigned short w;         // width
    unsigned short h;         // height
    short x_off;     // x offset for the vir
    short y_off;     // y offset for the vir
}
mdp_img_act;



typedef struct RANGE
{
    unsigned short min;
    unsigned short max;
}
RANGE;

typedef struct POINT
{
    unsigned short x;
    unsigned short y;
}
POINT;

typedef struct RECT
{
    unsigned short xmin;
    unsigned short xmax; // width - 1
    unsigned short ymin; 
    unsigned short ymax; // height - 1 
} RECT;

typedef struct RGB
{
    unsigned char r;
    unsigned char g;
    unsigned char b;
    unsigned char res;
}RGB;


typedef struct MMU
{
    unsigned char mmu_en;
    unsigned long base_addr;
    unsigned int mmu_flag;     /* [0] mmu enable [1] src_flush [2] dst_flush [3] CMD_flush [4~5] page size*/
} MMU;




typedef struct COLOR_FILL
{
    short gr_x_a;
    short gr_y_a;
    short gr_x_b;
    short gr_y_b;
    short gr_x_g;
    short gr_y_g;
    short gr_x_r;
    short gr_y_r;

    //u8  cp_gr_saturation;
}
COLOR_FILL;

typedef struct FADING
{
    unsigned char b;
    unsigned char g;
    unsigned char r;
    unsigned char res;
}
FADING;


typedef struct line_draw_t
{
    POINT start_point;              /* LineDraw_start_point                */
    POINT end_point;                /* LineDraw_end_point                  */
    unsigned int   color;               /* LineDraw_color                      */
    unsigned int   flag;                /* (enum) LineDrawing mode sel         */
    unsigned int   line_width;          /* range 1~16 */
}
line_draw_t;



 struct rga_req { 
    unsigned char render_mode;            /* (enum) process mode sel */
    
    rga_img_info_t src;                   /* src image info */
    rga_img_info_t dst;                   /* dst image info */
    rga_img_info_t pat;             /* patten image info */

    unsigned long rop_mask_addr;         /* rop4 mask addr */
    unsigned long LUT_addr;              /* LUT addr */

    RECT clip;                      /* dst clip window default value is dst_vir */
                                    /* value from [0, w-1] / [0, h-1]*/
        
    int sina;                   /* dst angle  default value 0  16.16 scan from table */
    int cosa;                   /* dst angle  default value 0  16.16 scan from table */        

    unsigned short alpha_rop_flag;        /* alpha rop process flag           */
                                    /* ([0] = 1 alpha_rop_enable)       */
                                    /* ([1] = 1 rop enable)             */                                                                                                                
                                    /* ([2] = 1 fading_enable)          */
                                    /* ([3] = 1 PD_enable)              */
                                    /* ([4] = 1 alpha cal_mode_sel)     */
                                    /* ([5] = 1 dither_enable)          */
                                    /* ([6] = 1 gradient fill mode sel) */
                                    /* ([7] = 1 AA_enable)              */

    unsigned char  scale_mode;            /* 0 nearst / 1 bilnear / 2 bicubic */                             
                            
    unsigned int color_key_max;         /* color key max */
    unsigned int color_key_min;         /* color key min */     

    unsigned int fg_color;              /* foreground color */
    unsigned int bg_color;              /* background color */

    COLOR_FILL gr_color;            /* color fill use gradient */
    
    line_draw_t line_draw_info;
    
    FADING fading;
                              
    unsigned char PD_mode;                /* porter duff alpha mode sel */
    
    unsigned char alpha_global_value;     /* global alpha value */
     
    unsigned short rop_code;              /* rop2/3/4 code  scan from rop code table*/
    
    unsigned char bsfilter_flag;          /* [2] 0 blur 1 sharp / [1:0] filter_type*/
    
    unsigned char palette_mode;           /* (enum) color palatte  0/1bpp, 1/2bpp 2/4bpp 3/8bpp*/

    unsigned char yuv2rgb_mode;           /* (enum) BT.601 MPEG / BT.601 JPEG / BT.709  */ 
    
    unsigned char endian_mode;            /* 0/big endian 1/little endian*/

    unsigned char rotate_mode;            /* (enum) rotate mode  */
                                    /* 0x0,     no rotate  */
                                    /* 0x1,     rotate     */
                                    /* 0x2,     x_mirror   */
                                    /* 0x3,     y_mirror   */

    unsigned char color_fill_mode;        /* 0 solid color / 1 patten color */
                                    
    MMU mmu_info;                   /* mmu information */

    unsigned char  alpha_rop_mode;        /* ([0~1] alpha mode)       */
                                    /* ([2~3] rop   mode)       */
                                    /* ([4]   zero  mode en)    */
                                    /* ([5]   dst   alpha mode) */

    unsigned char  src_trans_mode;

    unsigned char CMD_fin_int_enable;                        

    /* completion is reported through a callback */
	void (*complete)(int retval);
};

#endif

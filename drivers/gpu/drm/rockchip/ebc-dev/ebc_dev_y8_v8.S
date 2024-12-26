// SPDX-License-Identifier: GPL-2.0
/*
 * Copyright (c) 2020-2024 Rockchip Electronics Co., Ltd.
 *
 * Author: Zorro Liu <zorro.liu@rock-chips.com>
 */

	.arch armv8-a
	.file	"ebc_dev_y8.c"
#APP
	.section	".initcall6s.init", "a"	
__initcall_ebc_init6s:			
.long	ebc_init - .			
.previous					

#NO_APP
	.text
	.align	2
	.p2align 3,,7
	.type	get_overlay_image_area, %function
get_overlay_image_area:
	stp	x29, x30, [sp, -128]!
	adrp	x6, .LANCHOR0
	add	x29, sp, 0
	stp	x25, x26, [sp, 64]
	ldr	x26, [x6, #:lo12:.LANCHOR0]
	str	x0, [x29, 104]
	ldr	x0, [x5, 232]
	add	x26, x26, 40
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	stp	x27, x28, [sp, 80]
	stp	x23, x24, [sp, 48]
	ldr	w19, [x5, 84]
	ldp	w7, w23, [x0, 48]
	add	w27, w19, 7
	ldr	w6, [x26, 156]
	str	w6, [x29, 124]
	cmp	w7, 0
	ldp	w6, w28, [x0, 56]
	add	w25, w7, 7
	csel	w25, w25, w7, lt
	ldr	w0, [x5, 80]
	cmp	w6, 0
	add	w21, w6, 7
	csel	w21, w21, w6, lt
	cmp	w19, 0
	csel	w27, w27, w19, lt
	asr	w21, w21, 3
	add	w21, w21, 1
	asr	w27, w27, 3
	cmp	w21, w27
	sub	w6, w27, #1
	csel	w21, w6, w21, ge
	cmp	w28, w0
	sub	w0, w0, #1
	csel	w28, w0, w28, ge
	cmp	w28, w23
	blt	.L1
	asr	w25, w25, 3
	mov	w22, 1
	lsl	w0, w25, 1
	str	w0, [x29, 120]
	lsl	w0, w25, 3
	str	w0, [x29, 116]
	ldr	w0, [x29, 124]
	mul	w20, w23, w27
	mov	w30, w22
	cbz	w0, .L6
	.p2align 2
.L50:
	ldp	w0, w15, [x26, 76]
	sub	w15, w15, #1
	sub	w15, w15, w23
	mul	w15, w15, w0
	ldr	x0, [x29, 104]
	lsr	w15, w15, 2
	add	x15, x0, x15
.L7:
	mul	w19, w23, w19
	mov	w10, w25
	cmp	w21, w25
	ldp	w14, w11, [x29, 116]
	sxtw	x19, w19
	blt	.L20
	.p2align 2
.L37:
	sbfiz	x0, x10, 3, 32
	add	x0, x0, x20, sxtw 3
	ldr	x8, [x1, x0]
	ldr	x7, [x2, x0]
	cmp	x8, x7
	beq	.L10
	add	x9, x19, x14, sxtw
	ldrb	w13, [x15, w11, sxtw]
	eor	x6, x8, x7
	str	w22, [x5, 60]
	and	x0, x6, 255
	add	x12, x15, x11, sxtw
	cmp	x0, 0
	ldrb	w0, [x3, x9]
	add	x16, x4, x9
	ccmp	w0, 0, 0, ne
	add	x0, x3, x9
	bne	.L11
	ldrb	w17, [x4, x9]
	ubfx	x24, x8, 3, 5
	add	x17, x5, x17, lsl 3
	ldr	x18, [x17, 120]
	lsl	x17, x7, 2
	and	x17, x17, 992
	orr	x17, x17, x24
	ldrb	w17, [x18, x17]
	strb	w22, [x3, x9]
	orr	w13, w17, w13
.L11:
	ldrb	w9, [x0, 1]
	tst	x6, 65280
	ccmp	w9, 0, 0, ne
	bne	.L12
	ldrb	w9, [x16, 1]
	ubfx	x18, x8, 11, 5
	add	x9, x5, x9, lsl 3
	ldr	x17, [x9, 120]
	lsr	x9, x7, 6
	and	x9, x9, 992
	orr	x9, x9, x18
	ldrb	w9, [x17, x9]
	strb	w30, [x0, 1]
	orr	w13, w13, w9, lsl 2
	and	w13, w13, 255
.L12:
	ldrb	w9, [x0, 2]
	tst	x6, 16711680
	ccmp	w9, 0, 0, ne
	bne	.L13
	ldrb	w9, [x16, 2]
	ubfx	x18, x8, 19, 5
	add	x9, x5, x9, lsl 3
	ldr	x17, [x9, 120]
	lsr	x9, x7, 14
	and	x9, x9, 992
	orr	x9, x9, x18
	ldrb	w9, [x17, x9]
	strb	w30, [x0, 2]
	orr	w13, w13, w9, lsl 4
	and	w13, w13, 255
.L13:
	ldrb	w9, [x0, 3]
	tst	x6, 4278190080
	ccmp	w9, 0, 0, ne
	bne	.L14
	ldrb	w9, [x16, 3]
	lsr	w18, w8, 27
	add	x9, x5, x9, lsl 3
	ldr	x17, [x9, 120]
	lsr	x9, x7, 22
	and	x9, x9, 992
	orr	x9, x9, x18
	ldrb	w9, [x17, x9]
	strb	w30, [x0, 3]
	orr	w13, w13, w9, lsl 6
	and	w13, w13, 255
.L14:
	strb	w13, [x12]
	tst	x6, 1095216660480
	ldrb	w9, [x12, 1]
	ldrb	w13, [x0, 4]
	ccmp	w13, 0, 0, ne
	bne	.L15
	ldrb	w13, [x16, 4]
	ubfx	x18, x8, 35, 5
	add	x13, x5, x13, lsl 3
	ldr	x17, [x13, 120]
	lsr	x13, x7, 30
	and	x13, x13, 992
	orr	x13, x13, x18
	ldrb	w13, [x17, x13]
	strb	w30, [x0, 4]
	orr	w9, w13, w9
.L15:
	ldrb	w13, [x0, 5]
	tst	x6, 280375465082880
	ccmp	w13, 0, 0, ne
	bne	.L16
	ldrb	w13, [x16, 5]
	ubfx	x18, x8, 43, 5
	add	x13, x5, x13, lsl 3
	ldr	x17, [x13, 120]
	lsr	x13, x7, 38
	and	x13, x13, 992
	orr	x13, x13, x18
	ldrb	w13, [x17, x13]
	strb	w30, [x0, 5]
	orr	w9, w9, w13, lsl 2
	and	w9, w9, 255
.L16:
	ldrb	w13, [x0, 6]
	tst	x6, 71776119061217280
	ccmp	w13, 0, 0, ne
	bne	.L17
	ldrb	w13, [x16, 6]
	ubfx	x18, x8, 51, 5
	add	x13, x5, x13, lsl 3
	ldr	x17, [x13, 120]
	lsr	x13, x7, 46
	and	x13, x13, 992
	orr	x13, x13, x18
	ldrb	w13, [x17, x13]
	strb	w30, [x0, 6]
	orr	w9, w9, w13, lsl 4
	and	w9, w9, 255
.L17:
	tst	x6, -72057594037927936
	ldrb	w6, [x0, 7]
	ccmp	w6, 0, 0, ne
	bne	.L18
	ldrb	w6, [x16, 7]
	lsr	x7, x7, 54
	and	x7, x7, 992
	add	x6, x5, x6, lsl 3
	ldr	x6, [x6, 120]
	add	x8, x6, x8, lsr 59
	ldrb	w6, [x8, x7]
	strb	w30, [x0, 7]
	orr	w9, w9, w6, lsl 6
	and	w9, w9, 255
.L18:
	strb	w9, [x12, 1]
.L10:
	add	w10, w10, 1
	add	w11, w11, 2
	add	w14, w14, 8
	cmp	w21, w10
	bge	.L37
.L20:
	add	w23, w23, 1
	add	w20, w20, w27
	cmp	w28, w23
	blt	.L1
	ldr	w0, [x29, 124]
	ldr	w19, [x5, 84]
	cbnz	w0, .L50
.L6:
	ldr	w15, [x26, 76]
	ldr	x0, [x29, 104]
	mul	w15, w23, w15
	lsr	w15, w15, 2
	add	x15, x0, x15
	b	.L7
.L1:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	ldp	x29, x30, [sp], 128
	ret
	.size	get_overlay_image_area, .-get_overlay_image_area
	.align	2
	.p2align 3,,7
	.type	get_auto_image, %function
get_auto_image:
	stp	x29, x30, [sp, -48]!
	adrp	x6, .LANCHOR0
	cmp	w5, 2
	add	x29, sp, 0
	ldr	x17, [x6, #:lo12:.LANCHOR0]
	stp	x19, x20, [sp, 16]
	add	x19, x4, 60
	add	x17, x17, 40
	stp	x21, x22, [sp, 32]
	ldrb	w13, [x4, 56]
	ldp	w6, w22, [x17, 76]
	ldr	w30, [x17, 156]
	lsr	w14, w6, 3
	beq	.L106
	cmp	w5, 3
	mov	w18, 0
	beq	.L107
.L55:
	cmp	w18, w22
	bge	.L79
	sub	w16, w14, #1
	mov	w8, 0
	add	x16, x16, 1
	lsl	x16, x16, 3
	cbz	w30, .L56
	.p2align 2
.L116:
	ldr	w10, [x17, 80]
	sub	w10, w10, #1
	sub	w10, w10, w18
	mul	w10, w10, w6
	lsr	w10, w10, 2
	add	x10, x0, x10
.L59:
	add	x6, x3, 8
	add	x10, x10, 2
	mov	x9, 0
	cbz	w14, .L58
	.p2align 2
.L95:
	ldr	x7, [x1, x9, lsl 3]
	ldr	x5, [x2, x9, lsl 3]
	cmp	x7, x5
	beq	.L60
	eor	x8, x7, x5
	mov	w11, 0
	and	x12, x8, 255
	cbz	x12, .L61
	ldrb	w12, [x6, -8]
	lsl	x11, x5, 2
	and	x20, x11, 992
	ldr	x21, [x4, 120]
	ubfx	x11, x7, 3, 5
	orr	x11, x20, x11
	lsl	w20, w12, 10
	add	x11, x21, x11
	add	w12, w12, 1
	and	w12, w12, 255
	cmp	w13, w12
	ldrb	w11, [x11, w20, sxtw]
	beq	.L108
.L62:
	strb	w12, [x6, -8]
.L61:
	tst	x8, 65280
	beq	.L63
	ldrb	w12, [x6, -7]
	lsr	x20, x5, 6
	and	x21, x20, 992
	ldr	x15, [x4, 120]
	ubfx	x20, x7, 11, 5
	orr	x20, x21, x20
	lsl	w21, w12, 10
	add	x20, x15, x20
	add	w12, w12, 1
	and	w12, w12, 255
	cmp	w13, w12
	ldrb	w20, [x20, w21, sxtw]
	orr	w11, w11, w20, lsl 2
	and	w11, w11, 255
	beq	.L109
.L64:
	strb	w12, [x6, -7]
.L63:
	tst	x8, 16711680
	beq	.L65
	ldrb	w12, [x6, -6]
	lsr	x20, x5, 14
	and	x21, x20, 992
	ldr	x15, [x4, 120]
	ubfx	x20, x7, 19, 5
	orr	x20, x21, x20
	lsl	w21, w12, 10
	add	x20, x15, x20
	add	w12, w12, 1
	and	w12, w12, 255
	cmp	w13, w12
	ldrb	w20, [x20, w21, sxtw]
	orr	w11, w11, w20, lsl 4
	and	w11, w11, 255
	beq	.L110
.L66:
	strb	w12, [x6, -6]
.L65:
	tst	x8, 4278190080
	beq	.L67
	ldrb	w12, [x6, -5]
	lsr	x20, x5, 22
	and	x21, x20, 992
	ldr	x15, [x4, 120]
	lsr	w20, w7, 27
	orr	x20, x21, x20
	lsl	w21, w12, 10
	add	x20, x15, x20
	add	w12, w12, 1
	and	w12, w12, 255
	cmp	w13, w12
	ldrb	w20, [x20, w21, sxtw]
	orr	w11, w11, w20, lsl 6
	and	w11, w11, 255
	beq	.L111
.L68:
	strb	w12, [x6, -5]
.L67:
	strb	w11, [x10, -2]
	tst	x8, 1095216660480
	mov	w11, 0
	beq	.L69
	ldrb	w12, [x6, -4]
	lsr	x11, x5, 30
	and	x20, x11, 992
	ldr	x21, [x4, 120]
	ubfx	x11, x7, 35, 5
	orr	x11, x20, x11
	lsl	w20, w12, 10
	add	x11, x21, x11
	add	w12, w12, 1
	and	w12, w12, 255
	cmp	w13, w12
	ldrb	w11, [x11, w20, sxtw]
	beq	.L112
.L70:
	strb	w12, [x6, -4]
.L69:
	tst	x8, 280375465082880
	beq	.L71
	ldrb	w12, [x6, -3]
	lsr	x20, x5, 38
	and	x21, x20, 992
	ldr	x15, [x4, 120]
	ubfx	x20, x7, 43, 5
	orr	x20, x21, x20
	lsl	w21, w12, 10
	add	x20, x15, x20
	add	w12, w12, 1
	and	w12, w12, 255
	cmp	w13, w12
	ldrb	w20, [x20, w21, sxtw]
	orr	w11, w11, w20, lsl 2
	and	w11, w11, 255
	beq	.L113
.L72:
	strb	w12, [x6, -3]
.L71:
	tst	x8, 71776119061217280
	beq	.L73
	ldrb	w12, [x6, -2]
	lsr	x20, x5, 46
	and	x21, x20, 992
	ldr	x15, [x4, 120]
	ubfx	x20, x7, 51, 5
	orr	x20, x21, x20
	lsl	w21, w12, 10
	add	x20, x15, x20
	add	w12, w12, 1
	and	w12, w12, 255
	cmp	w13, w12
	ldrb	w20, [x20, w21, sxtw]
	orr	w11, w11, w20, lsl 4
	and	w11, w11, 255
	beq	.L114
.L74:
	strb	w12, [x6, -2]
.L73:
	tst	x8, -72057594037927936
	beq	.L75
	ldrb	w20, [x6, -1]
	lsr	x21, x5, 54
	ldr	x8, [x4, 120]
	and	x21, x21, 992
	add	w12, w20, 1
	ubfiz	x20, x20, 10, 8
	and	w12, w12, 255
	add	x8, x8, x20
	cmp	w13, w12
	add	x8, x8, x7, lsr 59
	ldrb	w8, [x8, x21]
	orr	w11, w11, w8, lsl 6
	and	w11, w11, 255
	beq	.L115
.L76:
	strb	w12, [x6, -1]
.L75:
	str	x5, [x2, x9, lsl 3]
	mov	w8, 1
	strb	w11, [x10, -1]
.L77:
	add	x9, x9, 1
	add	x6, x6, 8
	add	x10, x10, 2
	cmp	w14, w9
	bgt	.L95
	add	x3, x3, x16
	add	x2, x2, x16
	add	x1, x1, x16
.L58:
	add	w18, w18, 1
	cmp	w22, w18
	beq	.L53
	ldr	w6, [x17, 76]
	cbnz	w30, .L116
.L56:
	mul	w10, w18, w6
	lsr	w10, w10, 2
	add	x10, x0, x10
	b	.L59
	.p2align 3
.L115:
	and	x5, x5, 72057594037927935
	and	x7, x7, -72057594037927936
	orr	x5, x7, x5
	mov	w12, 0
	b	.L76
	.p2align 3
.L114:
	and	x12, x7, 71776119061217280
	and	x5, x5, -71776119061217281
	orr	x5, x12, x5
	mov	w12, 0
	b	.L74
	.p2align 3
.L112:
	and	x12, x7, 1095216660480
	and	x5, x5, -1095216660481
	orr	x5, x12, x5
	mov	w12, 0
	b	.L70
	.p2align 3
.L113:
	and	x12, x7, 280375465082880
	and	x5, x5, -280375465082881
	orr	x5, x12, x5
	mov	w12, 0
	b	.L72
	.p2align 3
.L111:
	and	x12, x7, 4278190080
	and	x5, x5, -4278190081
	orr	x5, x12, x5
	mov	w12, 0
	b	.L68
	.p2align 3
.L109:
	and	x12, x7, 65280
	and	x5, x5, -65281
	orr	x5, x12, x5
	mov	w12, 0
	b	.L64
	.p2align 3
.L110:
	and	x12, x7, 16711680
	and	x5, x5, -16711681
	orr	x5, x12, x5
	mov	w12, 0
	b	.L66
	.p2align 3
.L108:
	bfi	x5, x7, 0, 8
	mov	w12, 0
	b	.L62
	.p2align 3
.L60:
	strb	wzr, [x10, -2]
	strb	wzr, [x10, -1]
	b	.L77
.L79:
	mov	w8, 0
.L53:
	str	w8, [x19]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 48
	ret
.L106:
	add	w18, w22, w22, lsr 31
	asr	w22, w18, 1
	mov	w18, 0
	b	.L55
.L107:
	add	w15, w22, w22, lsr 31
	add	x19, x4, 64
	asr	w18, w15, 1
	mul	w5, w14, w18
	sbfiz	x5, x5, 3, 32
	add	x1, x1, x5
	add	x2, x2, x5
	mul	w5, w18, w6
	add	x3, x3, x5
	b	.L55
	.size	get_auto_image, .-get_auto_image
	.align	2
	.p2align 3,,7
	.type	direct_mode_data_change_full, %function
direct_mode_data_change_full:
	stp	x29, x30, [sp, -80]!
	adrp	x5, .LANCHOR0
	add	x29, sp, 0
	ldr	w7, [x3, 676]
	ldr	x6, [x5, #:lo12:.LANCHOR0]
	ldr	w5, [x3, 672]
	cmp	w7, 0
	add	w12, w7, 7
	ldrb	w13, [x3, 56]
	csel	w12, w12, w7, lt
	add	w15, w5, 7
	cmp	w5, 0
	add	x6, x6, 40
	csel	w15, w15, w5, lt
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	asr	w12, w12, 3
	stp	x23, x24, [sp, 48]
	asr	w15, w15, 3
	str	x25, [sp, 64]
	ldp	w18, w5, [x6, 76]
	msub	w13, w13, w15, w12
	cmp	w13, 0
	csel	w13, w13, wzr, ge
	lsr	w11, w18, 3
	cmp	w4, 2
	beq	.L133
	mov	w30, w5
	cmp	w4, 3
	mov	w16, 0
	beq	.L134
.L119:
	ldr	w4, [x6, 156]
	lsr	w18, w18, 2
	cbz	w4, .L120
	sub	w4, w5, #1
	sub	w4, w4, w16
	mul	w4, w4, w18
	neg	w18, w18
	add	x10, x0, x4
.L123:
	cmp	w16, w30
	bge	.L117
	sub	w17, w11, #1
	sxtw	x18, w18
	add	x17, x17, 1
	sub	w14, w12, #1
	lsl	x17, x17, 3
	.p2align 2
.L122:
	mov	x8, 0
	mov	w7, 0
	cbnz	w11, .L130
	b	.L127
	.p2align 3
.L136:
	strh	wzr, [x10, x8, lsl 1]
	add	w7, w7, 1
	add	x8, x8, 1
	cmp	w11, w7
	beq	.L135
.L130:
	cmp	w13, w7
	sub	w0, w14, w7
	ccmp	w12, w7, 4, le
	ble	.L136
	ldr	x5, [x2, x8, lsl 3]
	add	w7, w7, 1
	sdiv	w0, w0, w15
	ldr	x4, [x1, x8, lsl 3]
	ldr	x24, [x3, 120]
	cmp	w11, w7
	lsr	x23, x5, 14
	lsr	x22, x5, 30
	ubfx	x19, x4, 19, 5
	ubfx	x9, x4, 35, 5
	lsr	x6, x5, 6
	lsr	x21, x5, 22
	lsr	x20, x5, 46
	and	x23, x23, 992
	lsl	w0, w0, 10
	and	x22, x22, 992
	add	x0, x24, x0, sxtw
	ubfx	x25, x4, 11, 5
	lsr	w24, w4, 27
	orr	x23, x23, x19
	orr	x22, x22, x9
	lsr	x19, x5, 38
	ubfx	x9, x4, 51, 5
	and	x6, x6, 992
	and	x21, x21, 992
	and	x20, x20, 992
	orr	x20, x20, x9
	orr	x21, x21, x24
	lsl	x9, x5, 2
	ubfx	x24, x4, 43, 5
	orr	x6, x6, x25
	and	x19, x19, 992
	orr	x19, x19, x24
	and	x9, x9, 992
	ubfx	x24, x4, 3, 5
	lsr	x5, x5, 54
	ldrb	w22, [x0, x22]
	and	x5, x5, 992
	ldrb	w23, [x0, x23]
	add	x4, x0, x4, lsr 59
	orr	x9, x9, x24
	ldrb	w6, [x0, x6]
	ldrb	w21, [x0, x21]
	lsl	w22, w22, 8
	ldrb	w20, [x0, x20]
	ldrb	w19, [x0, x19]
	ldrb	w9, [x0, x9]
	lsl	w0, w23, 4
	ldrb	w4, [x4, x5]
	orr	w0, w0, w6, lsl 2
	orr	w22, w22, w21, lsl 6
	lsl	w5, w20, 12
	orr	w0, w0, w22
	orr	w5, w5, w19, lsl 10
	orr	w0, w0, w5
	orr	w4, w9, w4, lsl 14
	orr	w0, w0, w4
	strh	w0, [x10, x8, lsl 1]
	add	x8, x8, 1
	bne	.L130
.L135:
	add	x1, x1, x17
	add	x2, x2, x17
.L127:
	add	w16, w16, 1
	add	x10, x10, x18
	cmp	w30, w16
	bne	.L122
.L117:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldr	x25, [sp, 64]
	ldp	x29, x30, [sp], 80
	ret
.L120:
	mul	w10, w16, w18
	add	x10, x0, x10, sxtw
	b	.L123
.L133:
	add	w30, w5, w5, lsr 31
	mov	w16, 0
	asr	w30, w30, 1
	b	.L119
.L134:
	add	w16, w5, w5, lsr 31
	asr	w16, w16, 1
	mul	w4, w11, w16
	sbfiz	x4, x4, 3, 32
	add	x1, x1, x4
	add	x2, x2, x4
	b	.L119
	.size	direct_mode_data_change_full, .-direct_mode_data_change_full
	.align	2
	.p2align 3,,7
	.type	direct_mode_data_change_full2, %function
direct_mode_data_change_full2:
	ldr	w7, [x3, 676]
	adrp	x5, .LANCHOR0
	ldr	w6, [x3, 672]
	cmp	w7, 0
	add	w9, w7, 7
	csel	w9, w9, w7, lt
	ldr	x5, [x5, #:lo12:.LANCHOR0]
	cmp	w6, 0
	add	w13, w6, 7
	csel	w13, w13, w6, lt
	ldrb	w10, [x3, 56]
	asr	w9, w9, 3
	asr	w13, w13, 3
	ldp	w17, w18, [x5, 116]
	msub	w10, w10, w13, w9
	cmp	w10, 0
	lsr	w12, w17, 3
	csel	w10, w10, wzr, ge
	cmp	w4, 2
	beq	.L165
	cmp	w4, 3
	mov	w15, 0
	beq	.L166
.L139:
	lsr	w17, w17, 2
	cmp	w15, w18
	bge	.L158
.L173:
	sub	w14, w12, #1
	mul	w16, w15, w17
	add	x14, x14, 1
	lsl	w17, w17, 1
	lsl	x14, x14, 3
	sub	w11, w9, #1
.L159:
	add	x8, x0, x16, sxtw
	cbz	w12, .L167
	stp	x29, x30, [sp, -96]!
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	stp	x23, x24, [sp, 48]
	stp	x25, x26, [sp, 64]
	stp	x27, x28, [sp, 80]
	.p2align 2
.L160:
	mov	x30, 0
	mov	w7, 0
	b	.L144
	.p2align 3
.L169:
	str	wzr, [x8, x30, lsl 2]
	add	w7, w7, 1
	add	x30, x30, 1
	cmp	w12, w7
	beq	.L168
.L144:
	cmp	w10, w7
	sub	w4, w11, w7
	ccmp	w9, w7, 4, le
	ble	.L169
	ldr	x5, [x2, x30, lsl 3]
	add	w7, w7, 1
	sdiv	w4, w4, w13
	ldr	x6, [x1, x30, lsl 3]
	ldr	x26, [x3, 120]
	cmp	w12, w7
	lsr	x24, x5, 14
	lsr	x23, x5, 30
	ubfx	x25, x6, 19, 5
	ubfx	x21, x6, 35, 5
	lsr	x22, x5, 6
	lsr	x20, x5, 22
	lsr	x19, x5, 46
	and	x24, x24, 992
	lsl	w4, w4, 10
	and	x23, x23, 992
	add	x4, x26, x4, sxtw
	ubfx	x27, x6, 11, 5
	lsr	w26, w6, 27
	orr	x24, x24, x25
	orr	x23, x23, x21
	ubfx	x25, x6, 51, 5
	lsr	x21, x5, 38
	and	x22, x22, 992
	and	x20, x20, 992
	and	x19, x19, 992
	orr	x22, x22, x27
	orr	x19, x19, x25
	ubfx	x27, x6, 43, 5
	orr	x20, x20, x26
	and	x21, x21, 992
	lsl	x26, x5, 2
	orr	x21, x21, x27
	ubfx	x25, x6, 3, 5
	and	x26, x26, 992
	lsr	x5, x5, 54
	ldrb	w23, [x4, x23]
	orr	x25, x26, x25
	ldrb	w24, [x4, x24]
	add	x26, x4, x6, lsr 59
	and	x5, x5, 992
	ldrb	w6, [x4, x22]
	ldrb	w20, [x4, x20]
	lsl	w23, w23, 16
	ldrb	w22, [x4, x19]
	ldrb	w19, [x4, x21]
	ldrb	w5, [x26, x5]
	orr	w20, w23, w20, lsl 12
	ldrb	w21, [x4, x25]
	lsl	w4, w24, 8
	orr	w4, w4, w6, lsl 4
	lsl	w22, w22, 24
	orr	w4, w4, w20
	orr	w19, w22, w19, lsl 20
	orr	w4, w4, w19
	orr	w5, w21, w5, lsl 28
	orr	w4, w4, w5
	str	w4, [x8, x30, lsl 2]
	add	x30, x30, 1
	bne	.L144
.L168:
	add	x20, x2, x14
	add	x19, x1, x14
	mov	x2, 0
	mov	w6, 0
	b	.L147
	.p2align 3
.L171:
	str	wzr, [x8, x2, lsl 2]
	add	w6, w6, 1
	add	x2, x2, 1
	cmp	w7, w6
	beq	.L170
.L147:
	cmp	w10, w6
	sub	w4, w11, w6
	ccmp	w9, w6, 4, le
	ble	.L171
	ldr	x5, [x20, x2, lsl 3]
	add	w6, w6, 1
	sdiv	w4, w4, w13
	ldr	x30, [x19, x2, lsl 3]
	ldr	x27, [x3, 120]
	cmp	w7, w6
	lsr	x25, x5, 22
	lsr	x24, x5, 6
	lsr	w26, w30, 27
	ubfx	x21, x30, 11, 5
	lsr	x1, x5, 14
	lsl	x23, x5, 2
	lsr	x22, x5, 38
	and	x25, x25, 992
	lsl	w4, w4, 10
	and	x24, x24, 992
	add	x4, x27, x4, sxtw
	ubfx	x28, x30, 19, 5
	ubfx	x27, x30, 43, 5
	orr	x25, x25, x26
	orr	x24, x24, x21
	ubfx	x26, x30, 3, 5
	lsr	x21, x5, 30
	and	x1, x1, 992
	and	x23, x23, 992
	and	x22, x22, 992
	orr	x23, x23, x26
	orr	x22, x22, x27
	ubfx	x26, x30, 35, 5
	lsr	x27, x5, 46
	orr	x1, x1, x28
	and	x21, x21, 992
	lsr	x5, x5, 54
	orr	x21, x21, x26
	and	x27, x27, 992
	ubfx	x26, x30, 51, 5
	and	x5, x5, 992
	add	x30, x4, x30, lsr 59
	ldrb	w24, [x4, x24]
	orr	x26, x27, x26
	ldrb	w25, [x4, x25]
	ldrb	w1, [x4, x1]
	ldrb	w23, [x4, x23]
	lsl	w24, w24, 6
	ldrb	w22, [x4, x22]
	ldrb	w21, [x4, x21]
	ldrb	w27, [x30, x5]
	orr	w23, w24, w23, lsl 2
	ldrb	w5, [x4, x26]
	lsl	w4, w25, 14
	orr	w4, w4, w1, lsl 10
	lsl	w22, w22, 22
	orr	w4, w4, w23
	orr	w21, w22, w21, lsl 18
	lsl	w1, w27, 30
	orr	w4, w4, w21
	orr	w1, w1, w5, lsl 26
	orr	w4, w4, w1
	str	w4, [x8, x2, lsl 2]
	add	x2, x2, 1
	bne	.L147
.L170:
	add	w15, w15, 2
	add	x1, x19, x14
	add	x2, x20, x14
	add	w16, w16, w17
	cmp	w18, w15
	ble	.L172
.L148:
	add	x8, x0, x16, sxtw
	cbnz	w12, .L160
	add	w15, w15, 2
	add	w16, w16, w17
	cmp	w18, w15
	bgt	.L148
.L172:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	ldp	x29, x30, [sp], 96
	ret
.L167:
	add	w15, w15, 2
	add	w16, w16, w17
	cmp	w18, w15
	bgt	.L159
	ret
.L165:
	add	w18, w18, w18, lsr 31
	mov	w15, 0
	asr	w18, w18, 1
	lsr	w17, w17, 2
	cmp	w15, w18
	blt	.L173
.L158:
	ret
.L166:
	add	w15, w18, w18, lsr 31
	asr	w15, w15, 1
	mul	w4, w12, w15
	sbfiz	x4, x4, 3, 32
	add	x1, x1, x4
	add	x2, x2, x4
	b	.L139
	.size	direct_mode_data_change_full2, .-direct_mode_data_change_full2
	.align	2
	.p2align 3,,7
	.type	update_repair_buf_ghost, %function
update_repair_buf_ghost:
	sub	w1, w1, #1
	cmp	w1, 1
	ble	.L174
	sub	w13, w0, #1
	add	w9, w0, 1
	sub	w12, w0, #2
	mov	w10, 1
	mov	w11, -56
	.p2align 2
.L177:
	add	w8, w12, w9
	mov	w4, w9
	cmp	w13, 1
	bgt	.L185
	b	.L186
	.p2align 3
.L181:
	add	w6, w4, w0
	ldrb	w7, [x2, w6, sxtw]
	cmp	w7, 216
	beq	.L189
.L182:
	sub	x6, x5, #1
	ldrb	w7, [x2, x6]
	cmp	w7, 216
	beq	.L190
.L183:
	add	x5, x5, 1
	ldrb	w6, [x2, x5]
	cmp	w6, 216
	beq	.L191
.L180:
	add	w4, w4, 1
	cmp	w4, w8
	beq	.L186
.L185:
	ldrb	w7, [x3, w4, sxtw]
	sxtw	x5, w4
	ldrb	w6, [x2, w4, sxtw]
	cmp	w7, 240
	ccmp	w6, 24, 0, eq
	bne	.L180
	sub	w6, w4, w0
	ldrb	w7, [x2, w6, sxtw]
	cmp	w7, 216
	bne	.L181
	ldrb	w7, [x3, w6, sxtw]
	cmp	w7, 240
	bne	.L181
	strb	w11, [x2, w6, sxtw]
	add	w6, w4, w0
	ldrb	w7, [x2, w6, sxtw]
	cmp	w7, 216
	bne	.L182
	.p2align 2
.L189:
	ldrb	w7, [x3, w6, sxtw]
	cmp	w7, 240
	bne	.L182
	strb	w11, [x2, w6, sxtw]
	sub	x6, x5, #1
	ldrb	w7, [x2, x6]
	cmp	w7, 216
	bne	.L183
	.p2align 2
.L190:
	ldrb	w7, [x3, x6]
	cmp	w7, 240
	bne	.L183
	add	x5, x5, 1
	strb	w11, [x2, x6]
	ldrb	w6, [x2, x5]
	cmp	w6, 216
	bne	.L180
	.p2align 2
.L191:
	ldrb	w6, [x3, x5]
	cmp	w6, 240
	bne	.L180
	strb	w11, [x2, x5]
	add	w4, w4, 1
	cmp	w4, w8
	bne	.L185
	.p2align 2
.L186:
	add	w10, w10, 1
	add	w9, w9, w0
	cmp	w10, w1
	bne	.L177
	ret
.L174:
	ret
	.size	update_repair_buf_ghost, .-update_repair_buf_ghost
	.align	2
	.p2align 3,,7
	.type	waveform_open, %function
waveform_open:
	mov	w0, 0
	str	xzr, [x1, 104]
	ret
	.size	waveform_open, .-waveform_open
	.section	.exit.text,"ax",@progbits
	.align	2
	.type	ebc_exit, %function
ebc_exit:
	stp	x29, x30, [sp, -16]!
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x29, sp, 0
	bl	platform_driver_unregister
	ldp	x29, x30, [sp], 16
	ret
	.size	ebc_exit, .-ebc_exit
	.text
	.align	2
	.p2align 3,,7
	.type	ebc_resume, %function
ebc_resume:
	stp	x29, x30, [sp, -32]!
	add	x29, sp, 0
	str	x19, [sp, 16]
	ldr	x19, [x0, 184]
	ldr	x0, [x19, 16]
	cbz	x0, .L196
	ldr	x1, [x0, 48]
	blr	x1
.L196:
	ldr	x0, [x19, 312]
	adrp	x1, .LC0
	str	wzr, [x19, 796]
	add	x1, x1, :lo12:.LC0
	bl	_dev_info
	ldr	x19, [sp, 16]
	mov	w0, 0
	ldp	x29, x30, [sp], 32
	ret
	.size	ebc_resume, .-ebc_resume
	.align	2
	.p2align 3,,7
	.type	ebc_frame_control_timeout, %function
ebc_frame_control_timeout:
	adrp	x0, .LANCHOR0
	mov	w2, 1
	ldr	x0, [x0, #:lo12:.LANCHOR0]
	ldr	w1, [x0, 840]
	str	w2, [x0, 804]
	cmp	w1, 0
	ble	.L204
	add	x0, x0, 216
	stp	x29, x30, [sp, -16]!
	adrp	x1, .LC1
	add	x1, x1, :lo12:.LC1
	add	x29, sp, 0
	ldr	x0, [x0, 96]
	bl	_dev_info
	ldp	x29, x30, [sp], 16
	ret
	.p2align 3
.L204:
	ret
	.size	ebc_frame_control_timeout, .-ebc_frame_control_timeout
	.align	2
	.p2align 3,,7
	.type	ebc_power_set, %function
ebc_power_set:
	stp	x29, x30, [sp, -48]!
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	add	x19, x0, 216
	str	x21, [sp, 32]
	ldr	w2, [x19, 192]
	cmp	w2, w1
	beq	.L209
	mov	x20, x0
	mov	w21, w1
	cmp	w1, 1
	ldr	w0, [x19, 620]
	beq	.L230
	cbnz	w0, .L231
	str	w21, [x19, 192]
	ldr	x1, [x20, 8]
	mov	x0, x1
	ldr	x1, [x1, 80]
	blr	x1
	ldr	x0, [x20, 16]
	cbz	x0, .L217
.L235:
	ldr	x2, [x0, 32]
	mov	w1, 0
	mov	w21, 0
	blr	x2
.L218:
	ldr	w0, [x19, 456]
	cbnz	w0, .L232
.L219:
	ldr	w0, [x19, 624]
	cmp	w0, 0
	ble	.L209
	ldr	x0, [x19, 96]
	adrp	x1, .LC3
	mov	w2, w21
	add	x1, x1, :lo12:.LC3
	bl	_dev_info
.L209:
	mov	w0, 0
	ldr	x21, [sp, 32]
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 48
	ret
	.p2align 3
.L230:
	cbnz	w0, .L233
.L211:
	ldr	w0, [x19, 456]
	cbz	w0, .L234
.L212:
	mov	w1, 1
	str	w1, [x19, 192]
	ldr	x0, [x20, 16]
	cbz	x0, .L213
	ldr	x2, [x0, 32]
	mov	w21, 0
	blr	x2
.L214:
	ldr	x2, [x20, 8]
	add	x1, x20, 40
	mov	x0, x2
	ldr	x2, [x2, 72]
	blr	x2
	ldr	w0, [x19, 624]
	cmp	w0, 0
	ble	.L209
	ldr	x0, [x19, 96]
	mov	w2, w21
	adrp	x1, .LC2
	add	x1, x1, :lo12:.LC2
	bl	_dev_info
	ldr	x21, [sp, 32]
	mov	w0, 0
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 48
	ret
	.p2align 3
.L231:
	mov	x0, 0
	bl	ebc_notify
	str	w21, [x19, 192]
	ldr	x1, [x20, 8]
	mov	x0, x1
	ldr	x1, [x1, 80]
	blr	x1
	ldr	x0, [x20, 16]
	cbnz	x0, .L235
.L217:
	ldr	x0, [x20, 24]
	bl	regulator_disable
	mov	w21, w0
	b	.L218
	.p2align 3
.L234:
	mov	w0, 1
	str	w0, [x19, 456]
	add	x0, x20, 464
	bl	__pm_stay_awake
	b	.L212
	.p2align 3
.L233:
	mov	x0, 1
	bl	ebc_notify
	b	.L211
	.p2align 3
.L232:
	str	wzr, [x19, 456]
	add	x0, x20, 464
	bl	__pm_relax
	b	.L219
	.p2align 3
.L213:
	ldr	x0, [x20, 24]
	bl	regulator_enable
	mov	w21, w0
	b	.L214
	.size	ebc_power_set, .-ebc_power_set
	.align	2
	.p2align 3,,7
	.type	ebc_suspend, %function
ebc_suspend:
	stp	x29, x30, [sp, -32]!
	mov	w1, 0
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	ldr	x19, [x0, 184]
	add	x20, x19, 216
	mov	x0, x19
	bl	ebc_power_set
	mov	w0, 1
	str	w0, [x20, 580]
	ldr	x0, [x19, 16]
	cbz	x0, .L237
	ldr	x1, [x0, 40]
	blr	x1
.L237:
	ldr	x0, [x20, 96]
	adrp	x1, .LC4
	add	x1, x1, :lo12:.LC4
	bl	_dev_info
	mov	w0, 0
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 32
	ret
	.size	ebc_suspend, .-ebc_suspend
	.align	2
	.p2align 3,,7
	.type	ebc_remove, %function
ebc_remove:
	stp	x29, x30, [sp, -32]!
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	ldr	x20, [x0, 200]
	add	x19, x20, 848
	add	x20, x20, 888
.L244:
	ldr	x1, [x19]
	mov	x0, x1
	cbz	x1, .L243
	bl	dma_buf_put
	str	xzr, [x19]
.L243:
	add	x19, x19, 8
	cmp	x19, x20
	bne	.L244
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 224
	bl	misc_deregister
	mov	w0, 0
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 32
	ret
	.size	ebc_remove, .-ebc_remove
	.align	2
	.p2align 3,,7
	.type	ebc_release, %function
ebc_release:
	stp	x29, x30, [sp, -16]!
	add	x29, sp, 0
	ldr	x0, [x1, 200]
	bl	kfree
	mov	w0, 0
	ldp	x29, x30, [sp], 16
	ret
	.size	ebc_release, .-ebc_release
	.align	2
	.p2align 3,,7
	.type	ebc_open, %function
ebc_open:
	stp	x29, x30, [sp, -64]!
	adrp	x0, kmalloc_caches+56
	adrp	x2, .LANCHOR0
	add	x29, sp, 0
	ldr	x0, [x0, #:lo12:kmalloc_caches+56]
	str	x23, [sp, 48]
	mov	x23, x1
	mov	w1, 32960
	stp	x21, x22, [sp, 32]
	stp	x19, x20, [sp, 16]
	movk	w1, 0x60, lsl 16
	ldr	x21, [x2, #:lo12:.LANCHOR0]
	mov	x2, 20
	bl	kmem_cache_alloc_trace
	cbz	x0, .L255
	add	x19, x21, 848
	mov	x22, x0
	mov	x20, x0
	add	x21, x21, 888
.L254:
	ldr	x3, [x19], 8
	mov	x0, 1
	ldr	x2, [x3, 8]
	add	x1, x2, 56
#APP
// 260 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/atomic_lse.h" 1
	.arch_extension lse
.if 1 == 1
661:
	bl	__ll_sc_atomic64_add

662:
.pushsection .altinstructions,"a"
 .word 661b - .
 .word 663f - .
 .hword 5
 .byte 662b-661b
 .byte 664f-663f
.popsection
.pushsection .altinstr_replacement, "a"
663:
	.arch_extension lse
	stadd	x0, [x1]

664:
	.popsection
	.org	. - (664b-663b) + (662b-661b)
	.org	. - (662b-661b) + (664b-663b)
.endif

// 0 "" 2
#NO_APP
	mov	w1, 524288
	mov	x0, x3
	bl	dma_buf_fd
	str	w0, [x20], 4
	cmp	x19, x21
	bne	.L254
	mov	w0, 0
	str	xzr, [x23, 104]
	str	x22, [x23, 200]
.L252:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldr	x23, [sp, 48]
	ldp	x29, x30, [sp], 64
	ret
.L255:
	mov	w0, -12
	b	.L252
	.size	ebc_open, .-ebc_open
	.align	2
	.p2align 3,,7
	.type	ebc_mmap, %function
ebc_mmap:
	stp	x29, x30, [sp, -32]!
	add	x29, sp, 0
	str	x19, [sp, 16]
	mov	x19, x1
	bl	ebc_phy_buf_base_get
	lsr	x2, x0, 12
	mov	x6, 16384
	mov	x0, x19
	ldp	x4, x5, [x19, 72]
	movk	x6, 0x404, lsl 16
	ldp	x1, x3, [x19]
	orr	x5, x5, x6
	str	x5, [x19, 80]
	sub	x3, x3, x1
	bl	remap_pfn_range
	cmp	w0, 0
	mov	w1, -11
	ldr	x19, [sp, 16]
	csel	w0, w0, w1, eq
	ldp	x29, x30, [sp], 32
	ret
	.size	ebc_mmap, .-ebc_mmap
	.align	2
	.p2align 3,,7
	.type	waveform_mmap, %function
waveform_mmap:
	stp	x29, x30, [sp, -16]!
	adrp	x2, .LANCHOR0
	mov	x7, 16384
	mov	x0, x1
	add	x29, sp, 0
	ldr	x2, [x2, #:lo12:.LANCHOR0]
	movk	x7, 0x404, lsl 16
	ldp	x4, x5, [x1, 72]
	ldp	x6, x3, [x1]
	orr	x5, x5, x7
	ldr	x2, [x2, 256]
	str	x5, [x1, 80]
	sub	x3, x3, x6
	mov	x1, x6
	lsr	x2, x2, 12
	bl	remap_pfn_range
	cmp	w0, 0
	mov	w1, -11
	ldp	x29, x30, [sp], 16
	csel	w0, w0, w1, eq
	ret
	.size	waveform_mmap, .-waveform_mmap
	.align	2
	.p2align 3,,7
	.type	ebc_io_ctl, %function
ebc_io_ctl:
	stp	x29, x30, [sp, -176]!
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	adrp	x19, __stack_chk_guard
	stp	x21, x22, [sp, 32]
	add	x3, x19, :lo12:__stack_chk_guard
	stp	x23, x24, [sp, 48]
	mov	x22, x2
	stp	x25, x26, [sp, 64]
	ldr	x4, [x3]
	str	x4, [x29, 168]
	mov	x4,0
	ldr	x21, [x0, 200]
	adrp	x4, .LANCHOR0
	mov	w3, 28683
	cmp	w1, w3
	ldr	x20, [x4, #:lo12:.LANCHOR0]
	bls	.L420
	mov	w0, 28690
	cmp	w1, w0
	beq	.L269
	bls	.L421
	mov	w0, 28693
	cmp	w1, w0
	beq	.L269
	mov	w0, 28695
	cmp	w1, w0
	beq	.L269
	.p2align 2
.L267:
	sub	w1, w1, #28672
	cmp	w1, 24
	bls	.L422
.L272:
	ldr	x0, [x20, 312]
	adrp	x2, .LANCHOR2
	adrp	x1, .LC15
	add	x2, x2, :lo12:.LANCHOR2
	add	x1, x1, :lo12:.LC15
	bl	_dev_err
	.p2align 2
.L416:
	mov	x0, 0
.L266:
	add	x19, x19, :lo12:__stack_chk_guard
	ldr	x2, [x29, 168]
	ldr	x1, [x19]
	eor	x1, x2, x1
	cbnz	x1, .L423
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x29, x30, [sp], 176
	ret
	.p2align 3
.L420:
	mov	w0, 28681
	cmp	w1, w0
	bcs	.L269
	cmp	w1, 28672
	bcc	.L267
	mov	w0, 28675
	cmp	w1, w0
	bls	.L269
	mov	w0, -28678
	add	w0, w1, w0
	cmp	w0, 1
	bhi	.L267
	.p2align 2
.L269:
	cbnz	x22, .L267
	ldr	x0, [x20, 312]
	adrp	x2, .LANCHOR2
	adrp	x1, .LC5
	add	x2, x2, :lo12:.LANCHOR2
	add	x1, x1, :lo12:.LC5
	bl	_dev_err
	mov	x0, -14
	b	.L266
	.p2align 3
.L422:
	adrp	x0, .L274
	add	x0, x0, :lo12:.L274
	ldrh	w0, [x0,w1,uxtw #1]
	adr	x1, .Lrtx274
	add	x0, x1, w0, sxth #2
	br	x0
.Lrtx274:
	.section	.rodata
	.align	0
	.align	2
.L274:
	.2byte	(.L273 - .Lrtx274) / 4
	.2byte	(.L275 - .Lrtx274) / 4
	.2byte	(.L276 - .Lrtx274) / 4
	.2byte	(.L416 - .Lrtx274) / 4
	.2byte	(.L278 - .Lrtx274) / 4
	.2byte	(.L279 - .Lrtx274) / 4
	.2byte	(.L280 - .Lrtx274) / 4
	.2byte	(.L281 - .Lrtx274) / 4
	.2byte	(.L416 - .Lrtx274) / 4
	.2byte	(.L416 - .Lrtx274) / 4
	.2byte	(.L416 - .Lrtx274) / 4
	.2byte	(.L282 - .Lrtx274) / 4
	.2byte	(.L283 - .Lrtx274) / 4
	.2byte	(.L284 - .Lrtx274) / 4
	.2byte	(.L416 - .Lrtx274) / 4
	.2byte	(.L416 - .Lrtx274) / 4
	.2byte	(.L285 - .Lrtx274) / 4
	.2byte	(.L286 - .Lrtx274) / 4
	.2byte	(.L287 - .Lrtx274) / 4
	.2byte	(.L288 - .Lrtx274) / 4
	.2byte	(.L289 - .Lrtx274) / 4
	.2byte	(.L290 - .Lrtx274) / 4
	.2byte	(.L272 - .Lrtx274) / 4
	.2byte	(.L291 - .Lrtx274) / 4
	.2byte	(.L292 - .Lrtx274) / 4
	.text
	.p2align 3
.L421:
	mov	w0, 28688
	cmp	w1, w0
	beq	.L269
	sub	w1, w1, #28672
	cmp	w1, 24
	bhi	.L272
	b	.L422
	.p2align 3
.L278:
	ldr	w0, [x20, 840]
	mov	w1, 1
	str	w1, [x20, 800]
	add	x20, x20, 216
	tbnz	w0, #31, .L416
	ldr	x0, [x20, 96]
	adrp	x1, .LC8
	add	x1, x1, :lo12:.LC8
	bl	_dev_info
	mov	x0, 0
	b	.L266
	.p2align 3
.L279:
	ldr	w0, [x20, 840]
	add	x20, x20, 216
	str	wzr, [x20, 584]
	tbnz	w0, #31, .L416
	ldr	x0, [x20, 96]
	adrp	x1, .LC9
	add	x1, x1, :lo12:.LC9
	bl	_dev_info
	mov	x0, 0
	b	.L266
	.p2align 3
.L280:
	bl	ebc_empty_osd_buf_get
	cbz	x0, .L301
	ldr	x23, [x0, 8]
	bl	ebc_phy_buf_base_get
	mov	w1, 26215
	ldr	w2, [x20, 192]
	sub	w0, w23, w0
	movk	w1, 0x6666, lsl 16
	str	w0, [x29, 96]
	ldp	w4, w3, [x20, 116]
	smull	x1, w0, w1
	str	w2, [x29, 112]
	stp	w3, w4, [x29, 104]
	asr	x1, x1, 53
	str	wzr, [x29, 140]
	sub	w0, w1, w0, asr 31
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x2, sp_el0
// 0 "" 2
#NO_APP
	ldr	w0, [x21, w0, sxtw 2]
	str	w0, [x29, 160]
	ldr	w1, [x2, 52]
	ldr	x0, [x2, 8]
	tbnz	x1, 21, .L294
	ldr	x2, [x2]
	mov	x1, x22
	tbz	x2, 26, .L295
.L294:
	sbfx	x1, x22, 0, 56
	and	x1, x1, x22
.L295:
#APP
// 89 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x1, x1, 68
	csel	x0, xzr, x0, hi
	csinv	x1, x1, xzr, cc
	sbcs	xzr, x1, x0
	cset	x1, ls

// 0 "" 2
#NO_APP
	mov	x0, 68
	cbz	x1, .L266
	sbfx	x1, x22, 0, 56
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x2, sp_el0
// 0 "" 2
#NO_APP
	and	x1, x1, x22
	ldr	x2, [x2, 8]
#APP
// 249 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x1, x2
	csel	x3, x22, xzr, eq

// 0 "" 2
// 257 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	mov	x2, x0
	add	x1, x29, 96
	mov	x0, x3
	bl	__arch_copy_to_user
	sxtw	x0, w0
	b	.L266
	.p2align 3
.L281:
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x0, sp_el0
// 0 "" 2
#NO_APP
	ldr	w2, [x0, 52]
	ldr	x1, [x0, 8]
	tbnz	x2, 21, .L314
	ldr	x2, [x0]
	mov	x0, x22
	tbz	x2, 26, .L315
.L314:
	sbfx	x0, x22, 0, 56
	and	x0, x0, x22
.L315:
#APP
// 89 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x0, x0, 68
	csel	x1, xzr, x1, hi
	csinv	x0, x0, xzr, cc
	sbcs	xzr, x0, x1
	cset	x0, ls

// 0 "" 2
#NO_APP
	cbz	x0, .L345
	sbfx	x0, x22, 0, 56
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x1, sp_el0
// 0 "" 2
#NO_APP
	and	x0, x0, x22
	ldr	x2, [x1, 8]
#APP
// 249 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x0, x2
	csel	x1, x22, xzr, eq

// 0 "" 2
// 257 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	mov	x2, 68
	add	x0, x29, 96
	bl	__arch_copy_from_user
	cbnz	x0, .L345
	bl	ebc_osd_buf_clone
	mov	x1, x0
	cbz	x0, .L416
	ldr	w6, [x29, 100]
	add	x20, x20, 216
	ldp	w5, w3, [x29, 116]
	str	w6, [x1, 40]
	ldp	w4, w2, [x29, 124]
	stp	w5, w3, [x1, 48]
	stp	w4, w2, [x1, 56]
	bl	ebc_add_to_osd_buf_list
	ldr	w0, [x20, 92]
	cbnz	w0, .L317
	mov	w0, 1
	str	w0, [x20, 92]
.L317:
	ldr	w0, [x20, 88]
	cbnz	w0, .L416
.L417:
	mov	w2, 1
	str	w2, [x20, 88]
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 304
	mov	w1, w2
	bl	__wake_up_sync
	mov	x0, 0
	b	.L266
	.p2align 3
.L289:
	add	x20, x20, 216
	ldr	w0, [x20, 624]
	tbnz	w0, #31, .L332
	ldr	x0, [x20, 96]
	adrp	x1, .LC12
	add	x1, x1, :lo12:.LC12
	bl	_dev_info
.L332:
	ldr	w0, [x20, 576]
	cbnz	w0, .L424
.L333:
	mov	x0, 0
	str	wzr, [x20, 576]
	str	wzr, [x20, 596]
	b	.L266
	.p2align 3
.L290:
	str	wzr, [x29, 92]
	ldr	w0, [x20, 904]
	cmp	w0, 3576
	bne	.L416
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x0, sp_el0
// 0 "" 2
#NO_APP
	ldr	w2, [x0, 52]
	ldr	x1, [x0, 8]
	tbnz	x2, 21, .L335
	ldr	x2, [x0]
	mov	x0, x22
	tbz	x2, 26, .L336
.L335:
	sbfx	x0, x22, 0, 56
	and	x0, x0, x22
.L336:
#APP
// 89 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x0, x0, 4
	csel	x1, xzr, x1, hi
	csinv	x0, x0, xzr, cc
	sbcs	xzr, x0, x1
	cset	x0, ls

// 0 "" 2
#NO_APP
	cbz	x0, .L345
	sbfx	x0, x22, 0, 56
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x1, sp_el0
// 0 "" 2
#NO_APP
	and	x0, x0, x22
	ldr	x2, [x1, 8]
#APP
// 249 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x0, x2
	csel	x1, x22, xzr, eq

// 0 "" 2
// 257 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	add	x22, x29, 92
	mov	x2, 4
	mov	x0, x22
	bl	__arch_copy_from_user
	mov	x21, x0
	cbnz	x0, .L425
.L338:
	add	x20, x20, 216
	ldr	w0, [x20, 624]
	tbnz	w0, #31, .L339
	ldr	w2, [x29, 92]
	adrp	x1, .LC13
	ldr	x0, [x20, 96]
	add	x1, x1, :lo12:.LC13
	bl	_dev_info
.L339:
	ldr	w0, [x29, 92]
	str	w0, [x20, 604]
	b	.L416
	.p2align 3
.L288:
	add	x20, x20, 216
	ldr	w0, [x20, 624]
	tbnz	w0, #31, .L331
	ldr	x0, [x20, 96]
	adrp	x1, .LC11
	add	x1, x1, :lo12:.LC11
	bl	_dev_info
.L331:
	mov	x0, 2
	bl	ebc_notify
	mov	w1, 1
	mov	x0, 0
	str	w1, [x20, 576]
	str	w1, [x20, 596]
	b	.L266
	.p2align 3
.L282:
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x1, sp_el0
// 0 "" 2
#NO_APP
	ldr	w2, [x1, 52]
	ldr	x0, [x1, 8]
	tbnz	x2, 21, .L318
	ldr	x2, [x1]
	mov	x1, x22
	tbz	x2, 26, .L319
.L318:
	sbfx	x1, x22, 0, 56
	and	x1, x1, x22
.L319:
#APP
// 89 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x1, x1, 4
	csel	x0, xzr, x0, hi
	csinv	x1, x1, xzr, cc
	sbcs	xzr, x1, x0
	cset	x1, ls

// 0 "" 2
#NO_APP
	mov	x0, 4
	cbz	x1, .L266
	sbfx	x1, x22, 0, 56
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x2, sp_el0
// 0 "" 2
#NO_APP
	and	x1, x1, x22
	ldr	x2, [x2, 8]
#APP
// 249 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x1, x2
	csel	x3, x22, xzr, eq

// 0 "" 2
// 257 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	mov	x2, x0
	add	x1, x20, 800
	mov	x0, x3
	bl	__arch_copy_to_user
	sxtw	x0, w0
	b	.L266
	.p2align 3
.L273:
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x0, sp_el0
// 0 "" 2
#NO_APP
	ldr	w2, [x0, 52]
	ldr	x1, [x0, 8]
	tbnz	x2, 21, .L297
	ldr	x2, [x0]
	mov	x0, x22
	tbz	x2, 26, .L298
.L297:
	sbfx	x0, x22, 0, 56
	and	x0, x0, x22
.L298:
#APP
// 89 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x0, x0, 68
	csel	x1, xzr, x1, hi
	csinv	x0, x0, xzr, cc
	sbcs	xzr, x0, x1
	cset	x0, ls

// 0 "" 2
#NO_APP
	cbz	x0, .L345
	lsl	x24, x22, 8
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x0, sp_el0
// 0 "" 2
#NO_APP
	and	x2, x22, x24, asr 8
	ldr	x0, [x0, 8]
#APP
// 249 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x2, x0
	csel	x1, x22, xzr, eq

// 0 "" 2
// 257 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	add	x25, x29, 96
	mov	x2, 68
	mov	x0, x25
	bl	__arch_copy_from_user
	mov	x23, x0
	cbnz	x0, .L300
.L303:
	add	x0, x25, 48
	bl	ebc_empty_buf_get
	mov	x26, x0
	cbz	x0, .L301
	ldr	x23, [x0, 8]
	bl	ebc_phy_buf_base_get
	mov	w1, 26215
	str	wzr, [x29, 140]
	sub	w0, w23, w0
	movk	w1, 0x6666, lsl 16
	ldp	w2, w3, [x20, 116]
	stp	w3, w2, [x29, 104]
	smull	x1, w0, w1
	str	w0, [x29, 96]
	ldr	w2, [x20, 192]
	str	w2, [x29, 112]
	asr	x1, x1, 53
	sub	w0, w1, w0, asr 31
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x2, sp_el0
// 0 "" 2
#NO_APP
	ldr	w0, [x21, w0, sxtw 2]
	str	w0, [x29, 160]
	ldr	w0, [x2, 52]
	ldr	x1, [x2, 8]
	tbnz	x0, 21, .L304
	ldr	x2, [x2]
	mov	x0, x22
	tbnz	x2, 26, .L304
.L305:
#APP
// 89 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x0, x0, 68
	csel	x1, xzr, x1, hi
	csinv	x0, x0, xzr, cc
	sbcs	xzr, x0, x1
	cset	x0, ls

// 0 "" 2
#NO_APP
	cbnz	x0, .L306
.L307:
	mov	x0, x26
	bl	ebc_buf_release
	mov	x0, -14
	b	.L266
	.p2align 3
.L276:
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x2, sp_el0
// 0 "" 2
#NO_APP
	ldr	w3, [x2, 52]
	ldp	w1, w0, [x20, 132]
	stp	w1, w0, [x29, 132]
	ldp	w6, w5, [x20, 116]
	stp	w5, w6, [x29, 104]
	ldr	w4, [x20, 192]
	str	w4, [x29, 112]
	str	wzr, [x29, 140]
	ldr	x1, [x2, 8]
	tbnz	x3, 21, .L327
	ldr	x2, [x2]
	mov	x0, x22
	tbz	x2, 26, .L328
.L327:
	sbfx	x0, x22, 0, 56
	and	x0, x0, x22
.L328:
#APP
// 89 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x0, x0, 68
	csel	x1, xzr, x1, hi
	csinv	x0, x0, xzr, cc
	sbcs	xzr, x0, x1
	cset	x0, ls

// 0 "" 2
#NO_APP
	cbnz	x0, .L329
.L330:
	ldr	x0, [x20, 312]
	adrp	x1, .LC10
	add	x1, x1, :lo12:.LC10
	bl	_dev_err
	mov	x0, -14
	b	.L266
	.p2align 3
.L286:
	bl	ebc_drop_one_dsp_buf
	cbz	w0, .L416
	.p2align 2
.L345:
	mov	x0, -14
	b	.L266
	.p2align 3
.L287:
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x1, sp_el0
// 0 "" 2
#NO_APP
	ldr	w2, [x1, 52]
	ldr	x0, [x1, 8]
	tbnz	x2, 21, .L321
	ldr	x2, [x1]
	mov	x1, x22
	tbz	x2, 26, .L322
.L321:
	sbfx	x1, x22, 0, 56
	and	x1, x1, x22
.L322:
#APP
// 89 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x1, x1, 4
	csel	x0, xzr, x0, hi
	csinv	x1, x1, xzr, cc
	sbcs	xzr, x1, x0
	cset	x1, ls

// 0 "" 2
#NO_APP
	mov	x0, 4
	cbz	x1, .L266
	sbfx	x1, x22, 0, 56
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x2, sp_el0
// 0 "" 2
#NO_APP
	and	x1, x1, x22
	ldr	x2, [x2, 8]
#APP
// 249 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x1, x2
	csel	x3, x22, xzr, eq

// 0 "" 2
// 257 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	mov	x2, x0
	add	x1, x20, 672
	mov	x0, x3
	bl	__arch_copy_to_user
	sxtw	x0, w0
	b	.L266
	.p2align 3
.L283:
	ldr	w0, [x20, 840]
	mov	w1, 1
	str	w1, [x20, 808]
	add	x20, x20, 216
	tbnz	w0, #31, .L416
	ldr	x0, [x20, 96]
	adrp	x1, .LC6
	add	x1, x1, :lo12:.LC6
	bl	_dev_info
	mov	x0, 0
	b	.L266
	.p2align 3
.L284:
	ldr	w0, [x20, 840]
	add	x20, x20, 216
	str	wzr, [x20, 592]
	tbnz	w0, #31, .L416
	ldr	x0, [x20, 96]
	adrp	x1, .LC7
	add	x1, x1, :lo12:.LC7
	bl	_dev_info
	mov	x0, 0
	b	.L266
	.p2align 3
.L292:
	str	wzr, [x29, 92]
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x0, sp_el0
// 0 "" 2
#NO_APP
	ldr	w2, [x0, 52]
	ldr	x1, [x0, 8]
	tbnz	x2, 21, .L343
	ldr	x2, [x0]
	mov	x0, x22
	tbz	x2, 26, .L344
.L343:
	sbfx	x0, x22, 0, 56
	and	x0, x0, x22
.L344:
#APP
// 89 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x0, x0, 4
	csel	x1, xzr, x1, hi
	csinv	x0, x0, xzr, cc
	sbcs	xzr, x0, x1
	cset	x0, ls

// 0 "" 2
#NO_APP
	cbz	x0, .L345
	sbfx	x0, x22, 0, 56
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x1, sp_el0
// 0 "" 2
#NO_APP
	and	x0, x0, x22
	ldr	x2, [x1, 8]
#APP
// 249 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x0, x2
	csel	x1, x22, xzr, eq

// 0 "" 2
// 257 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	add	x22, x29, 92
	mov	x2, 4
	mov	x0, x22
	bl	__arch_copy_from_user
	mov	x21, x0
	cbnz	x0, .L426
.L346:
	add	x20, x20, 216
	ldr	w0, [x20, 624]
	tbnz	w0, #31, .L347
	ldr	w2, [x29, 92]
	adrp	x1, .LC14
	ldr	x0, [x20, 96]
	add	x1, x1, :lo12:.LC14
	bl	_dev_info
.L347:
	ldr	w2, [x29, 92]
	mov	w3, 8
	mov	x0, 0
	and	w1, w2, -8
	cmp	w2, w3
	csel	w1, w1, w3, ge
	str	w1, [x20, 672]
	b	.L266
	.p2align 3
.L285:
	mov	w0, 1
	str	w0, [x29, 92]
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x1, sp_el0
// 0 "" 2
#NO_APP
	ldr	w2, [x1, 52]
	ldr	x0, [x1, 8]
	tbnz	x2, 21, .L324
	ldr	x2, [x1]
	mov	x1, x22
	tbz	x2, 26, .L325
.L324:
	sbfx	x1, x22, 0, 56
	and	x1, x1, x22
.L325:
#APP
// 89 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x1, x1, 4
	csel	x0, xzr, x0, hi
	csinv	x1, x1, xzr, cc
	sbcs	xzr, x1, x0
	cset	x1, ls

// 0 "" 2
#NO_APP
	mov	x0, 4
	cbz	x1, .L266
	sbfx	x1, x22, 0, 56
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x2, sp_el0
// 0 "" 2
#NO_APP
	and	x1, x1, x22
	ldr	x2, [x2, 8]
#APP
// 249 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x1, x2
	csel	x3, x22, xzr, eq

// 0 "" 2
// 257 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	mov	x2, x0
	add	x1, x29, 92
	mov	x0, x3
	bl	__arch_copy_to_user
	sxtw	x0, w0
	b	.L266
	.p2align 3
.L291:
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x1, sp_el0
// 0 "" 2
#NO_APP
	ldr	w2, [x1, 52]
	ldr	x0, [x1, 8]
	tbnz	x2, 21, .L340
	ldr	x2, [x1]
	mov	x1, x22
	tbz	x2, 26, .L341
.L340:
	sbfx	x1, x22, 0, 56
	and	x1, x1, x22
.L341:
#APP
// 89 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x1, x1, 4
	csel	x0, xzr, x0, hi
	csinv	x1, x1, xzr, cc
	sbcs	xzr, x1, x0
	cset	x1, ls

// 0 "" 2
#NO_APP
	mov	x0, 4
	cbz	x1, .L266
	sbfx	x1, x22, 0, 56
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x2, sp_el0
// 0 "" 2
#NO_APP
	and	x1, x1, x22
	ldr	x2, [x2, 8]
#APP
// 249 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x1, x2
	csel	x3, x22, xzr, eq

// 0 "" 2
// 257 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	mov	x2, x0
	add	x1, x20, 828
	mov	x0, x3
	bl	__arch_copy_to_user
	sxtw	x0, w0
	b	.L266
	.p2align 3
.L275:
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x0, sp_el0
// 0 "" 2
#NO_APP
	ldr	w2, [x0, 52]
	ldr	x1, [x0, 8]
	tbnz	x2, 21, .L308
	ldr	x2, [x0]
	mov	x0, x22
	tbz	x2, 26, .L309
.L308:
	sbfx	x0, x22, 0, 56
	and	x0, x0, x22
.L309:
#APP
// 89 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x0, x0, 68
	csel	x1, xzr, x1, hi
	csinv	x0, x0, xzr, cc
	sbcs	xzr, x0, x1
	cset	x0, ls

// 0 "" 2
#NO_APP
	cbz	x0, .L345
	sbfx	x0, x22, 0, 56
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x1, sp_el0
// 0 "" 2
#NO_APP
	and	x0, x0, x22
	ldr	x2, [x1, 8]
#APP
// 249 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x0, x2
	csel	x1, x22, xzr, eq

// 0 "" 2
// 257 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	mov	x2, 68
	add	x0, x29, 96
	bl	__arch_copy_from_user
	cbnz	x0, .L345
	bl	ebc_phy_buf_base_get
	ldrsw	x1, [x29, 96]
	add	x0, x1, x0
	bl	ebc_find_buf_by_phy_addr
	mov	x1, x0
	cbz	x0, .L416
	ldr	w2, [x29, 100]
	add	x20, x20, 216
	str	w2, [x1, 40]
	ldp	w6, w3, [x29, 116]
	stp	w6, w3, [x1, 48]
	ldr	w4, [x29, 124]
	ldr	w2, [x29, 128]
	ldr	w5, [x29, 140]
	str	w4, [x1, 56]
	stp	w2, w5, [x1, 60]
	bl	ebc_add_to_dsp_buf_list
	ldr	w0, [x20, 88]
	cbnz	w0, .L416
	b	.L417
	.p2align 3
.L304:
	and	x0, x22, x24, asr 8
	b	.L305
	.p2align 3
.L424:
	mov	x0, 3
	bl	ebc_notify
	b	.L333
	.p2align 3
.L329:
	sbfx	x1, x22, 0, 56
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x0, sp_el0
// 0 "" 2
#NO_APP
	and	x1, x1, x22
	ldr	x2, [x0, 8]
#APP
// 249 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x1, x2
	csel	x0, x22, xzr, eq

// 0 "" 2
// 257 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	mov	x2, 68
	add	x1, x29, 96
	bl	__arch_copy_to_user
	cbz	x0, .L416
	b	.L330
	.p2align 3
.L306:
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x0, sp_el0
// 0 "" 2
#NO_APP
	and	x24, x22, x24, asr 8
	ldr	x1, [x0, 8]
#APP
// 249 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x24, x1
	csel	x0, x22, xzr, eq

// 0 "" 2
// 257 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	mov	x2, 68
	mov	x1, x25
	bl	__arch_copy_to_user
	cbz	w0, .L416
	b	.L307
	.p2align 3
.L301:
	mov	x0, -1
	b	.L266
.L423:
	bl	__stack_chk_fail
.L300:
	sub	x0, x25, x0
	mov	x2, x23
	mov	w1, 0
	add	x0, x0, 68
	bl	memset
	cbz	w23, .L303
	mov	x0, -14
	b	.L266
.L425:
	sub	x0, x22, x0
	mov	x2, x21
	mov	w1, 0
	add	x0, x0, 4
	bl	memset
	cbz	w21, .L338
	mov	x0, -14
	b	.L266
.L426:
	sub	x0, x22, x0
	mov	x2, x21
	mov	w1, 0
	add	x0, x0, 4
	bl	memset
	cbz	w21, .L346
	mov	x0, -14
	b	.L266
	.size	ebc_io_ctl, .-ebc_io_ctl
	.align	2
	.p2align 3,,7
	.type	get_overlay_image2, %function
get_overlay_image2:
	stp	x29, x30, [sp, -112]!
	adrp	x7, .LANCHOR0
	cmp	w6, 2
	add	x29, sp, 0
	stp	x23, x24, [sp, 48]
	mov	x23, x0
	ldr	x0, [x7, #:lo12:.LANCHOR0]
	stp	x19, x20, [sp, 16]
	mov	x19, x5
	stp	x25, x26, [sp, 64]
	mov	x26, x1
	stp	x27, x28, [sp, 80]
	mov	x20, x2
	stp	x21, x22, [sp, 32]
	mov	x27, x3
	mov	x28, x4
	add	x25, x5, 60
	ldp	w1, w22, [x0, 116]
	lsr	w24, w1, 3
	beq	.L582
	cmp	w6, 3
	beq	.L430
	lsr	w13, w1, 2
	mov	x0, 0
	mov	w21, 0
.L429:
	sub	w2, w22, w21
	add	x0, x23, x0
	mov	w1, 0
	str	w13, [x29, 108]
	mul	w2, w2, w13
	sxtw	x2, w2
	bl	memset
	cmp	w21, w22
	bge	.L490
	ldr	w13, [x29, 108]
	sub	w11, w24, #1
	add	x11, x11, 1
	mov	w3, 0
	lsl	x11, x11, 3
	mul	w12, w21, w13
	lsl	w13, w13, 1
	.p2align 2
.L489:
	add	x9, x23, x12, sxtw
	cbz	w24, .L432
	add	x1, x27, 8
	add	x8, x28, 8
	mov	x4, x9
	mov	x7, 0
	.p2align 2
.L460:
	ldr	x2, [x26, x7]
	ldr	x0, [x20, x7]
	cmp	x2, x0
	beq	.L433
	eor	x5, x2, x0
	and	x3, x5, 255
	cbz	x3, .L491
	ldrb	w10, [x8, -8]
	lsr	x6, x0, 3
	ldrb	w3, [x1, -8]
	ubfx	x16, x2, 3, 5
	ubfiz	x6, x6, 5, 5
	ldrb	w15, [x19, 56]
	add	x14, x19, x10, sxtw 3
	orr	x6, x6, x16
	ldrb	w17, [x19, 57]
	lsl	w16, w3, 10
	cmp	w10, 0
	add	w3, w3, 1
	ldr	x14, [x14, 120]
	and	w3, w3, 255
	csel	w15, w15, w17, eq
	mov	w10, 0
	add	x6, x14, x6
	cmp	w15, w3
	ldrb	w6, [x6, w16, sxtw]
	beq	.L583
.L436:
	strb	w3, [x1, -8]
.L434:
	tst	x5, 65280
	beq	.L437
	ldrb	w16, [x8, -7]
	lsr	x17, x0, 11
	ldrb	w3, [x1, -7]
	ubfx	x18, x2, 11, 5
	cmp	w16, 0
	ubfiz	x17, x17, 5, 5
	add	x30, x19, x16, sxtw 3
	orr	x14, x17, x18
	lsl	w17, w3, 10
	ldrb	w15, [x19, 56]
	ldrb	w18, [x19, 57]
	add	w3, w3, 1
	ldr	x16, [x30, 120]
	and	w3, w3, 255
	csel	w15, w15, w18, eq
	add	x14, x16, x14
	cmp	w15, w3
	ldrb	w14, [x14, w17, sxtw]
	orr	w6, w6, w14, lsl 4
	beq	.L584
.L439:
	strb	w3, [x1, -7]
.L437:
	tst	x5, 16711680
	beq	.L440
	ldrb	w16, [x8, -6]
	lsr	x17, x0, 19
	ldrb	w3, [x1, -6]
	ubfx	x18, x2, 19, 5
	cmp	w16, 0
	ubfiz	x17, x17, 5, 5
	add	x30, x19, x16, sxtw 3
	orr	x14, x17, x18
	lsl	w17, w3, 10
	ldrb	w15, [x19, 56]
	ldrb	w18, [x19, 57]
	add	w3, w3, 1
	ldr	x16, [x30, 120]
	and	w3, w3, 255
	csel	w15, w15, w18, eq
	add	x14, x16, x14
	cmp	w15, w3
	ldrb	w14, [x14, w17, sxtw]
	orr	w6, w6, w14, lsl 8
	beq	.L585
.L442:
	strb	w3, [x1, -6]
.L440:
	tst	x5, 4278190080
	beq	.L443
	ldrb	w16, [x8, -5]
	lsr	x17, x0, 27
	ldrb	w3, [x1, -5]
	lsr	w18, w2, 27
	cmp	w16, 0
	ubfiz	x17, x17, 5, 5
	add	x30, x19, x16, sxtw 3
	orr	x14, x17, x18
	lsl	w17, w3, 10
	ldrb	w15, [x19, 56]
	ldrb	w18, [x19, 57]
	add	w3, w3, 1
	ldr	x16, [x30, 120]
	and	w3, w3, 255
	csel	w15, w15, w18, eq
	add	x14, x16, x14
	cmp	w15, w3
	ldrb	w14, [x14, w17, sxtw]
	orr	w6, w6, w14, lsl 12
	beq	.L586
.L445:
	strb	w3, [x1, -5]
.L443:
	tst	x5, 1095216660480
	beq	.L446
	ldrb	w16, [x8, -4]
	lsr	x17, x0, 35
	ldrb	w3, [x1, -4]
	ubfx	x18, x2, 35, 5
	cmp	w16, 0
	ubfiz	x17, x17, 5, 5
	add	x30, x19, x16, sxtw 3
	orr	x14, x17, x18
	lsl	w17, w3, 10
	ldrb	w15, [x19, 56]
	ldrb	w18, [x19, 57]
	add	w3, w3, 1
	ldr	x16, [x30, 120]
	and	w3, w3, 255
	csel	w15, w15, w18, eq
	add	x14, x16, x14
	cmp	w15, w3
	ldrb	w14, [x14, w17, sxtw]
	orr	w6, w6, w14, lsl 16
	beq	.L587
.L448:
	strb	w3, [x1, -4]
.L446:
	tst	x5, 280375465082880
	beq	.L449
	ldrb	w16, [x8, -3]
	lsr	x17, x0, 43
	ldrb	w3, [x1, -3]
	ubfx	x18, x2, 43, 5
	cmp	w16, 0
	ubfiz	x17, x17, 5, 5
	add	x30, x19, x16, sxtw 3
	orr	x14, x17, x18
	lsl	w17, w3, 10
	ldrb	w15, [x19, 56]
	ldrb	w18, [x19, 57]
	add	w3, w3, 1
	ldr	x16, [x30, 120]
	and	w3, w3, 255
	csel	w15, w15, w18, eq
	add	x14, x16, x14
	cmp	w15, w3
	ldrb	w14, [x14, w17, sxtw]
	orr	w6, w6, w14, lsl 20
	beq	.L588
.L451:
	strb	w3, [x1, -3]
.L449:
	tst	x5, 71776119061217280
	beq	.L452
	ldrb	w16, [x8, -2]
	lsr	x17, x0, 51
	ldrb	w3, [x1, -2]
	ubfx	x18, x2, 51, 5
	cmp	w16, 0
	ubfiz	x17, x17, 5, 5
	add	x30, x19, x16, sxtw 3
	orr	x14, x17, x18
	lsl	w17, w3, 10
	ldrb	w15, [x19, 56]
	ldrb	w18, [x19, 57]
	add	w3, w3, 1
	ldr	x16, [x30, 120]
	and	w3, w3, 255
	csel	w15, w15, w18, eq
	add	x14, x16, x14
	cmp	w15, w3
	ldrb	w14, [x14, w17, sxtw]
	orr	w6, w6, w14, lsl 24
	beq	.L589
.L454:
	strb	w3, [x1, -2]
.L452:
	tst	x5, -72057594037927936
	beq	.L455
	ldrb	w18, [x8, -1]
	lsr	x14, x0, 59
	ldrb	w5, [x1, -1]
	lsl	x14, x14, 5
	ldrb	w15, [x19, 56]
	cmp	w18, 0
	add	x3, x19, x18, sxtw 3
	ldrb	w17, [x19, 57]
	ubfiz	x16, x5, 10, 8
	add	w5, w5, 1
	and	w5, w5, 255
	csel	w15, w15, w17, eq
	ldr	x3, [x3, 120]
	cmp	w15, w5
	add	x3, x3, x16
	add	x3, x3, x2, lsr 59
	ldrb	w3, [x3, x14]
	orr	w6, w6, w3, lsl 28
	beq	.L590
	strb	w5, [x1, -1]
.L455:
	cbnz	w10, .L458
.L459:
	mov	w3, 1
	str	w6, [x4]
.L433:
	add	x7, x7, 8
	add	x1, x1, 8
	add	x8, x8, 8
	add	x4, x4, 4
	cmp	x11, x7
	bne	.L460
	add	x27, x27, x11
	add	x28, x28, x11
	add	x20, x20, x11
	add	x26, x26, x11
	add	x1, x27, 8
	add	x8, x28, 8
	mov	x7, 0
	.p2align 2
.L488:
	ldr	x5, [x26, x7]
	ldr	x0, [x20, x7]
	cmp	x5, x0
	beq	.L461
	eor	x6, x5, x0
	and	x2, x6, 255
	cbz	x2, .L493
	ldrb	w10, [x8, -8]
	lsr	x2, x0, 3
	ldrb	w3, [x1, -8]
	ubfx	x4, x5, 3, 5
	cmp	w10, 0
	ubfiz	x2, x2, 5, 5
	add	x16, x19, x10, sxtw 3
	orr	x2, x2, x4
	lsl	w15, w3, 10
	ldrb	w4, [x19, 57]
	ldrb	w14, [x19, 56]
	add	w3, w3, 1
	ldr	x10, [x16, 120]
	and	w3, w3, 255
	csel	w14, w14, w4, eq
	mov	w4, 0
	add	x2, x10, x2
	cmp	w14, w3
	ldrb	w2, [x2, w15, sxtw]
	lsl	w2, w2, 2
	beq	.L591
.L464:
	strb	w3, [x1, -8]
.L462:
	tst	x6, 65280
	beq	.L465
	ldrb	w18, [x8, -7]
	lsr	x14, x0, 11
	ldrb	w3, [x1, -7]
	ubfiz	x14, x14, 5, 5
	ubfx	x10, x5, 11, 5
	ldrb	w15, [x19, 56]
	add	x17, x19, x18, sxtw 3
	orr	x10, x14, x10
	lsl	w14, w3, 10
	ldrb	w16, [x19, 57]
	cmp	w18, 0
	add	w3, w3, 1
	ldr	x17, [x17, 120]
	and	w3, w3, 255
	csel	w15, w15, w16, eq
	add	x10, x17, x10
	cmp	w15, w3
	ldrb	w10, [x10, w14, sxtw]
	orr	w2, w2, w10, lsl 6
	beq	.L592
.L467:
	strb	w3, [x1, -7]
.L465:
	tst	x6, 16711680
	beq	.L468
	ldrb	w18, [x8, -6]
	lsr	x14, x0, 19
	ldrb	w3, [x1, -6]
	ubfiz	x14, x14, 5, 5
	ubfx	x10, x5, 19, 5
	ldrb	w15, [x19, 56]
	add	x17, x19, x18, sxtw 3
	orr	x10, x14, x10
	lsl	w14, w3, 10
	ldrb	w16, [x19, 57]
	cmp	w18, 0
	add	w3, w3, 1
	ldr	x17, [x17, 120]
	and	w3, w3, 255
	csel	w15, w15, w16, eq
	add	x10, x17, x10
	cmp	w15, w3
	ldrb	w10, [x10, w14, sxtw]
	orr	w2, w2, w10, lsl 10
	beq	.L593
.L470:
	strb	w3, [x1, -6]
.L468:
	tst	x6, 4278190080
	beq	.L471
	ldrb	w18, [x8, -5]
	lsr	x14, x0, 27
	ldrb	w3, [x1, -5]
	ubfiz	x14, x14, 5, 5
	lsr	w10, w5, 27
	ldrb	w15, [x19, 56]
	add	x17, x19, x18, sxtw 3
	orr	x10, x14, x10
	lsl	w14, w3, 10
	ldrb	w16, [x19, 57]
	cmp	w18, 0
	add	w3, w3, 1
	ldr	x17, [x17, 120]
	and	w3, w3, 255
	csel	w15, w15, w16, eq
	add	x10, x17, x10
	cmp	w15, w3
	ldrb	w10, [x10, w14, sxtw]
	orr	w2, w2, w10, lsl 14
	beq	.L594
.L473:
	strb	w3, [x1, -5]
.L471:
	tst	x6, 1095216660480
	beq	.L474
	ldrb	w18, [x8, -4]
	lsr	x14, x0, 35
	ldrb	w3, [x1, -4]
	ubfiz	x14, x14, 5, 5
	ubfx	x10, x5, 35, 5
	ldrb	w15, [x19, 56]
	add	x17, x19, x18, sxtw 3
	orr	x10, x14, x10
	lsl	w14, w3, 10
	ldrb	w16, [x19, 57]
	cmp	w18, 0
	add	w3, w3, 1
	ldr	x17, [x17, 120]
	and	w3, w3, 255
	csel	w15, w15, w16, eq
	add	x10, x17, x10
	cmp	w15, w3
	ldrb	w10, [x10, w14, sxtw]
	orr	w2, w2, w10, lsl 18
	beq	.L595
.L476:
	strb	w3, [x1, -4]
.L474:
	tst	x6, 280375465082880
	beq	.L477
	ldrb	w18, [x8, -3]
	lsr	x14, x0, 43
	ldrb	w10, [x1, -3]
	ubfiz	x14, x14, 5, 5
	ubfx	x3, x5, 43, 5
	ldrb	w15, [x19, 56]
	add	x17, x19, x18, sxtw 3
	orr	x3, x14, x3
	lsl	w14, w10, 10
	ldrb	w16, [x19, 57]
	cmp	w18, 0
	add	w10, w10, 1
	ldr	x17, [x17, 120]
	and	w10, w10, 255
	csel	w15, w15, w16, eq
	add	x3, x17, x3
	cmp	w15, w10
	ldrb	w3, [x3, w14, sxtw]
	orr	w2, w2, w3, lsl 22
	beq	.L596
.L479:
	strb	w10, [x1, -3]
.L477:
	tst	x6, 71776119061217280
	beq	.L480
	ldrb	w18, [x8, -2]
	lsr	x14, x0, 51
	ldrb	w10, [x1, -2]
	ubfiz	x14, x14, 5, 5
	ubfx	x3, x5, 51, 5
	ldrb	w15, [x19, 56]
	add	x17, x19, x18, sxtw 3
	orr	x3, x14, x3
	lsl	w14, w10, 10
	ldrb	w16, [x19, 57]
	cmp	w18, 0
	add	w10, w10, 1
	ldr	x17, [x17, 120]
	and	w10, w10, 255
	csel	w15, w15, w16, eq
	add	x3, x17, x3
	cmp	w15, w10
	ldrb	w3, [x3, w14, sxtw]
	orr	w2, w2, w3, lsl 26
	beq	.L597
.L482:
	strb	w10, [x1, -2]
.L480:
	tst	x6, -72057594037927936
	beq	.L483
	ldrb	w15, [x8, -1]
	lsr	x10, x0, 59
	ldrb	w6, [x1, -1]
	lsl	x10, x10, 5
	ldrb	w14, [x19, 56]
	cmp	w15, 0
	add	x3, x19, x15, sxtw 3
	ldrb	w17, [x19, 57]
	ubfiz	x16, x6, 10, 8
	add	w6, w6, 1
	and	w6, w6, 255
	csel	w14, w14, w17, eq
	ldr	x3, [x3, 120]
	cmp	w14, w6
	add	x3, x3, x16
	add	x3, x3, x5, lsr 59
	ldrb	w3, [x3, x10]
	orr	w2, w2, w3, lsl 30
	beq	.L598
	strb	w6, [x1, -1]
.L483:
	cbnz	w4, .L486
.L487:
	ldr	w0, [x9]
	mov	w3, 1
	orr	w2, w0, w2
	str	w2, [x9]
.L461:
	add	x7, x7, 8
	add	x1, x1, 8
	add	x8, x8, 8
	add	x9, x9, 4
	cmp	x11, x7
	bne	.L488
	add	x27, x27, x11
	add	x28, x28, x11
	add	x20, x20, x11
	add	x26, x26, x11
.L432:
	add	w21, w21, 2
	add	w12, w12, w13
	cmp	w22, w21
	bgt	.L489
	str	w3, [x25]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	ldp	x29, x30, [sp], 112
	ret
	.p2align 3
.L590:
	and	x0, x0, 72057594037927935
	and	x2, x2, -72057594037927936
	orr	x0, x2, x0
	strb	wzr, [x1, -1]
.L458:
	str	x0, [x20, x7]
	b	.L459
	.p2align 3
.L589:
	and	x3, x2, 71776119061217280
	and	x0, x0, -71776119061217281
	orr	x0, x3, x0
	mov	w10, 1
	mov	w3, 0
	b	.L454
	.p2align 3
.L587:
	and	x3, x2, 1095216660480
	and	x0, x0, -1095216660481
	orr	x0, x3, x0
	mov	w10, 1
	mov	w3, 0
	b	.L448
	.p2align 3
.L588:
	and	x3, x2, 280375465082880
	and	x0, x0, -280375465082881
	orr	x0, x3, x0
	mov	w10, 1
	mov	w3, 0
	b	.L451
	.p2align 3
.L586:
	and	x3, x2, 4278190080
	and	x0, x0, -4278190081
	orr	x0, x3, x0
	mov	w10, 1
	mov	w3, 0
	b	.L445
	.p2align 3
.L584:
	and	x3, x2, 65280
	and	x0, x0, -65281
	orr	x0, x3, x0
	mov	w10, 1
	mov	w3, 0
	b	.L439
	.p2align 3
.L585:
	and	x3, x2, 16711680
	and	x0, x0, -16711681
	orr	x0, x3, x0
	mov	w10, 1
	mov	w3, 0
	b	.L442
	.p2align 3
.L583:
	bfi	x0, x2, 0, 8
	mov	w3, 0
	mov	w10, 1
	b	.L436
	.p2align 3
.L598:
	and	x0, x0, 72057594037927935
	and	x5, x5, -72057594037927936
	orr	x0, x5, x0
	strb	wzr, [x1, -1]
.L486:
	str	x0, [x20, x7]
	b	.L487
	.p2align 3
.L595:
	and	x3, x5, 1095216660480
	and	x0, x0, -1095216660481
	orr	x0, x3, x0
	mov	w4, 1
	mov	w3, 0
	b	.L476
	.p2align 3
.L596:
	and	x0, x0, -280375465082881
	and	x3, x5, 280375465082880
	orr	x0, x3, x0
	mov	w10, 0
	mov	w4, 1
	b	.L479
	.p2align 3
.L597:
	and	x0, x0, -71776119061217281
	and	x3, x5, 71776119061217280
	orr	x0, x3, x0
	mov	w10, 0
	mov	w4, 1
	b	.L482
	.p2align 3
.L593:
	and	x3, x5, 16711680
	and	x0, x0, -16711681
	orr	x0, x3, x0
	mov	w4, 1
	mov	w3, 0
	b	.L470
	.p2align 3
.L594:
	and	x3, x5, 4278190080
	and	x0, x0, -4278190081
	orr	x0, x3, x0
	mov	w4, 1
	mov	w3, 0
	b	.L473
	.p2align 3
.L592:
	and	x3, x5, 65280
	and	x0, x0, -65281
	orr	x0, x3, x0
	mov	w4, 1
	mov	w3, 0
	b	.L467
	.p2align 3
.L591:
	bfi	x0, x5, 0, 8
	mov	w3, 0
	mov	w4, 1
	b	.L464
	.p2align 3
.L493:
	mov	w2, 0
	mov	w4, 0
	b	.L462
	.p2align 3
.L491:
	mov	w6, 0
	mov	w10, 0
	b	.L434
.L582:
	add	w22, w22, w22, lsr 31
	lsr	w13, w1, 2
	asr	w22, w22, 1
	mov	x0, 0
	mov	w21, 0
	b	.L429
.L430:
	add	w21, w22, w22, lsr 31
	lsr	w13, w1, 2
	asr	w21, w21, 1
	add	x25, x5, 64
	mul	w0, w24, w21
	mul	w1, w21, w1
	sbfiz	x0, x0, 3, 32
	add	x27, x3, x1
	add	x26, x26, x0
	add	x20, x2, x0
	mul	w0, w21, w13
	add	x28, x4, x1
	sxtw	x0, w0
	b	.L429
.L490:
	mov	w3, 0
	str	w3, [x25]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	ldp	x29, x30, [sp], 112
	ret
	.size	get_overlay_image2, .-get_overlay_image2
	.align	2
	.p2align 3,,7
	.type	get_overlay_image, %function
get_overlay_image:
	stp	x29, x30, [sp, -112]!
	adrp	x7, .LANCHOR0
	cmp	w6, 2
	add	x29, sp, 0
	stp	x21, x22, [sp, 32]
	mov	x21, x1
	ldr	x22, [x7, #:lo12:.LANCHOR0]
	stp	x19, x20, [sp, 16]
	mov	x19, x5
	add	x22, x22, 40
	stp	x27, x28, [sp, 80]
	stp	x23, x24, [sp, 48]
	mov	x5, x0
	stp	x25, x26, [sp, 64]
	mov	x20, x2
	mov	x24, x3
	mov	x25, x4
	ldp	w13, w0, [x22, 76]
	add	x28, x19, 60
	lsr	w27, w13, 3
	beq	.L681
	mov	w26, w0
	cmp	w6, 3
	mov	w23, 0
	beq	.L682
.L601:
	ldr	w1, [x22, 156]
	lsr	w13, w13, 2
	cbz	w1, .L602
	sub	w2, w26, w23
	sub	w0, w0, w26
	str	x5, [x29, 96]
	mov	w1, 0
	str	w13, [x29, 108]
	mul	w2, w2, w13
	mul	w0, w0, w13
	sxtw	x2, w2
	add	x0, x5, x0
	bl	memset
	ldr	w0, [x22, 80]
	cmp	w23, w26
	ldr	w13, [x29, 108]
	sub	w0, w0, #1
	ldr	x5, [x29, 96]
	sub	w0, w0, w23
	mul	w0, w0, w13
	neg	w13, w13
	add	x22, x5, x0
	bge	.L637
.L691:
	sub	w12, w27, #1
	sxtw	x13, w13
	add	x12, x12, 1
	lsl	w11, w27, 1
	lsl	x12, x12, 3
	mov	w3, 0
	.p2align 2
.L604:
	cbz	w27, .L635
	add	x1, x24, 8
	add	x6, x25, 8
	mov	w9, 0
	mov	x7, 0
	.p2align 2
.L633:
	ldr	x2, [x21, x7]
	ldr	x0, [x20, x7]
	cmp	x2, x0
	beq	.L606
	eor	x5, x2, x0
	add	x4, x22, x9, sxtw
	and	x3, x5, 255
	cbz	x3, .L638
	ldrb	w14, [x6, -8]
	lsr	x10, x0, 3
	ldrb	w3, [x1, -8]
	ubfiz	x10, x10, 5, 5
	ubfx	x8, x2, 3, 5
	ldrb	w15, [x19, 56]
	add	x18, x19, x14, sxtw 3
	orr	x8, x10, x8
	lsl	w16, w3, 10
	ldrb	w17, [x19, 57]
	cmp	w14, 0
	add	w3, w3, 1
	ldr	x10, [x18, 120]
	and	w3, w3, 255
	csel	w15, w15, w17, eq
	mov	w14, 0
	add	x8, x10, x8
	cmp	w15, w3
	ldrb	w8, [x8, w16, sxtw]
	beq	.L683
.L609:
	strb	w3, [x1, -8]
.L607:
	tst	x5, 65280
	beq	.L610
	ldrb	w16, [x6, -7]
	lsr	x17, x0, 11
	ldrb	w3, [x1, -7]
	ubfx	x18, x2, 11, 5
	cmp	w16, 0
	ubfiz	x17, x17, 5, 5
	add	x30, x19, x16, sxtw 3
	orr	x10, x17, x18
	lsl	w17, w3, 10
	ldrb	w15, [x19, 56]
	ldrb	w18, [x19, 57]
	add	w3, w3, 1
	ldr	x16, [x30, 120]
	and	w3, w3, 255
	csel	w15, w15, w18, eq
	add	x10, x16, x10
	cmp	w15, w3
	ldrb	w10, [x10, w17, sxtw]
	ubfiz	w10, w10, 2, 6
	orr	w8, w10, w8
	beq	.L684
.L612:
	strb	w3, [x1, -7]
.L610:
	tst	x5, 16711680
	beq	.L613
	ldrb	w16, [x6, -6]
	lsr	x17, x0, 19
	ldrb	w3, [x1, -6]
	ubfx	x18, x2, 19, 5
	cmp	w16, 0
	ubfiz	x17, x17, 5, 5
	add	x30, x19, x16, sxtw 3
	orr	x10, x17, x18
	lsl	w17, w3, 10
	ldrb	w15, [x19, 56]
	ldrb	w18, [x19, 57]
	add	w3, w3, 1
	ldr	x16, [x30, 120]
	and	w3, w3, 255
	csel	w15, w15, w18, eq
	add	x10, x16, x10
	cmp	w15, w3
	ldrb	w10, [x10, w17, sxtw]
	ubfiz	w10, w10, 4, 4
	orr	w8, w10, w8
	beq	.L685
.L615:
	strb	w3, [x1, -6]
.L613:
	tst	x5, 4278190080
	beq	.L616
	ldrb	w16, [x6, -5]
	lsr	x17, x0, 27
	ldrb	w3, [x1, -5]
	lsr	w18, w2, 27
	cmp	w16, 0
	ubfiz	x17, x17, 5, 5
	add	x30, x19, x16, sxtw 3
	orr	x10, x17, x18
	lsl	w17, w3, 10
	ldrb	w15, [x19, 56]
	ldrb	w18, [x19, 57]
	add	w3, w3, 1
	ldr	x16, [x30, 120]
	and	w3, w3, 255
	csel	w15, w15, w18, eq
	add	x10, x16, x10
	cmp	w15, w3
	ldrb	w10, [x10, w17, sxtw]
	ubfiz	w10, w10, 6, 2
	orr	w8, w10, w8
	beq	.L686
.L618:
	strb	w3, [x1, -5]
.L616:
	strb	w8, [x4]
	tst	x5, 1095216660480
	mov	w8, 0
	beq	.L619
	ldrb	w18, [x6, -4]
	lsr	x10, x0, 35
	ldrb	w3, [x1, -4]
	ubfiz	x10, x10, 5, 5
	ubfx	x8, x2, 35, 5
	ldrb	w15, [x19, 56]
	add	x17, x19, x18, sxtw 3
	orr	x8, x10, x8
	ldrb	w16, [x19, 57]
	lsl	w10, w3, 10
	cmp	w18, 0
	add	w3, w3, 1
	ldr	x17, [x17, 120]
	and	w3, w3, 255
	csel	w15, w15, w16, eq
	add	x8, x17, x8
	cmp	w15, w3
	ldrb	w8, [x8, w10, sxtw]
	beq	.L687
.L621:
	strb	w3, [x1, -4]
.L619:
	tst	x5, 280375465082880
	beq	.L622
	ldrb	w16, [x6, -3]
	lsr	x17, x0, 43
	ldrb	w10, [x1, -3]
	ubfx	x18, x2, 43, 5
	cmp	w16, 0
	ubfiz	x17, x17, 5, 5
	add	x30, x19, x16, sxtw 3
	orr	x3, x17, x18
	lsl	w17, w10, 10
	ldrb	w15, [x19, 56]
	ldrb	w18, [x19, 57]
	add	w10, w10, 1
	ldr	x16, [x30, 120]
	and	w10, w10, 255
	csel	w15, w15, w18, eq
	add	x3, x16, x3
	cmp	w15, w10
	ldrb	w3, [x3, w17, sxtw]
	ubfiz	w3, w3, 2, 6
	orr	w8, w3, w8
	beq	.L688
.L624:
	strb	w10, [x1, -3]
.L622:
	tst	x5, 71776119061217280
	beq	.L625
	ldrb	w16, [x6, -2]
	lsr	x17, x0, 51
	ldrb	w10, [x1, -2]
	ubfx	x18, x2, 51, 5
	cmp	w16, 0
	ubfiz	x17, x17, 5, 5
	add	x30, x19, x16, sxtw 3
	orr	x3, x17, x18
	lsl	w17, w10, 10
	ldrb	w15, [x19, 56]
	ldrb	w18, [x19, 57]
	add	w10, w10, 1
	ldr	x16, [x30, 120]
	and	w10, w10, 255
	csel	w15, w15, w18, eq
	add	x3, x16, x3
	cmp	w15, w10
	ldrb	w3, [x3, w17, sxtw]
	ubfiz	w3, w3, 4, 4
	orr	w8, w3, w8
	beq	.L689
.L627:
	strb	w10, [x1, -2]
.L625:
	tst	x5, -72057594037927936
	beq	.L628
	ldrb	w18, [x6, -1]
	lsr	x10, x0, 59
	ldrb	w5, [x1, -1]
	lsl	x10, x10, 5
	ldrb	w15, [x19, 56]
	cmp	w18, 0
	add	x3, x19, x18, sxtw 3
	ldrb	w17, [x19, 57]
	ubfiz	x16, x5, 10, 8
	add	w5, w5, 1
	and	w5, w5, 255
	csel	w15, w15, w17, eq
	ldr	x3, [x3, 120]
	cmp	w15, w5
	add	x3, x3, x16
	add	x3, x3, x2, lsr 59
	ldrb	w3, [x3, x10]
	ubfiz	w3, w3, 6, 2
	orr	w8, w3, w8
	beq	.L690
	strb	w5, [x1, -1]
.L628:
	cbnz	w14, .L631
.L632:
	strb	w8, [x4, 1]
	mov	w3, 1
.L606:
	add	w9, w9, 2
	add	x7, x7, 8
	add	x1, x1, 8
	add	x6, x6, 8
	cmp	w9, w11
	bne	.L633
	add	x24, x24, x12
	add	x25, x25, x12
	add	x20, x20, x12
	add	x21, x21, x12
.L635:
	add	w23, w23, 1
	add	x22, x22, x13
	cmp	w26, w23
	bne	.L604
	str	w3, [x28]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	ldp	x29, x30, [sp], 112
	ret
	.p2align 3
.L690:
	and	x0, x0, 72057594037927935
	and	x2, x2, -72057594037927936
	orr	x0, x2, x0
	strb	wzr, [x1, -1]
.L631:
	str	x0, [x20, x7]
	b	.L632
	.p2align 3
.L689:
	and	x0, x0, -71776119061217281
	and	x3, x2, 71776119061217280
	orr	x0, x3, x0
	mov	w10, 0
	mov	w14, 1
	b	.L627
	.p2align 3
.L688:
	and	x0, x0, -280375465082881
	and	x3, x2, 280375465082880
	orr	x0, x3, x0
	mov	w10, 0
	mov	w14, 1
	b	.L624
	.p2align 3
.L686:
	and	x3, x2, 4278190080
	and	x0, x0, -4278190081
	orr	x0, x3, x0
	mov	w14, 1
	mov	w3, 0
	b	.L618
	.p2align 3
.L687:
	and	x3, x2, 1095216660480
	and	x0, x0, -1095216660481
	orr	x0, x3, x0
	mov	w14, 1
	mov	w3, 0
	b	.L621
	.p2align 3
.L685:
	and	x3, x2, 16711680
	and	x0, x0, -16711681
	orr	x0, x3, x0
	mov	w14, 1
	mov	w3, 0
	b	.L615
	.p2align 3
.L683:
	bfi	x0, x2, 0, 8
	mov	w3, 0
	mov	w14, 1
	b	.L609
	.p2align 3
.L684:
	and	x3, x2, 65280
	and	x0, x0, -65281
	orr	x0, x3, x0
	mov	w14, 1
	mov	w3, 0
	b	.L612
	.p2align 3
.L638:
	mov	w8, 0
	mov	w14, 0
	b	.L607
.L602:
	sub	w2, w26, w23
	mul	w22, w23, w13
	str	w13, [x29, 108]
	mov	w1, 0
	mul	w2, w2, w13
	add	x22, x5, x22, sxtw
	mov	x0, x22
	sxtw	x2, w2
	bl	memset
	ldr	w13, [x29, 108]
	cmp	w23, w26
	blt	.L691
.L637:
	mov	w3, 0
	str	w3, [x28]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	ldp	x29, x30, [sp], 112
	ret
.L681:
	add	w26, w0, w0, lsr 31
	mov	w23, 0
	asr	w26, w26, 1
	b	.L601
.L682:
	add	w23, w0, w0, lsr 31
	add	x28, x19, 64
	asr	w23, w23, 1
	mul	w1, w27, w23
	sbfiz	x1, x1, 3, 32
	add	x21, x21, x1
	add	x20, x2, x1
	mul	w1, w23, w13
	add	x24, x3, x1
	add	x25, x4, x1
	b	.L601
	.size	get_overlay_image, .-get_overlay_image
	.align	2
	.p2align 3,,7
	.type	frame_done_callback, %function
frame_done_callback:
	stp	x29, x30, [sp, -48]!
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	adrp	x20, .LANCHOR0
	str	x21, [sp, 32]
	ldr	x21, [x20, #:lo12:.LANCHOR0]
	add	x19, x21, 216
	ldr	w1, [x19, 240]
	cmp	w1, 3
	beq	.L694
	cmp	w1, 4
	beq	.L695
	cmp	w1, 1
	beq	.L734
	ldr	w0, [x19, 72]
	cbnz	w0, .L711
	ldr	w0, [x19, 680]
	cbnz	w0, .L712
.L711:
	add	x20, x20, :lo12:.LANCHOR0
	mov	w0, 1
	str	w0, [x19, 52]
	ldr	x0, [x20, 8]
	bl	wake_up_process
	ldr	x21, [sp, 32]
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 48
	ret
	.p2align 3
.L734:
	ldr	w2, [x19, 72]
	cbz	w2, .L706
	ldr	w2, [x19, 92]
	cbz	w2, .L735
.L707:
	ldr	w1, [x19, 624]
	mov	x0, x21
	cmp	w1, 0
	ble	.L708
	ldr	x0, [x19, 96]
	adrp	x1, .LC19
	add	x1, x1, :lo12:.LC19
	bl	_dev_info
	ldr	x0, [x20, #:lo12:.LANCHOR0]
.L708:
	ldr	x3, [x0, 8]
.L730:
	mov	x0, x3
	ldr	x3, [x3, 144]
	mov	w2, 0
	mov	w1, 0
	blr	x3
	str	wzr, [x19, 52]
	ldr	w0, [x19, 624]
	cmp	w0, 0
	ble	.L710
	ldr	x0, [x19, 96]
	adrp	x1, .LC20
	add	x1, x1, :lo12:.LC20
	bl	_dev_info
	b	.L710
	.p2align 3
.L695:
	ldr	w0, [x19, 60]
	mov	w1, 1
	str	w1, [x19, 76]
	cbnz	w0, .L703
	ldr	w0, [x19, 64]
	cbnz	w0, .L703
	ldr	w0, [x19, 68]
	cbz	w0, .L703
	ldr	w1, [x19, 624]
	mov	x0, x21
	cmp	w1, 0
	ble	.L700
	ldr	x0, [x19, 96]
	adrp	x1, .LC16
	add	x1, x1, :lo12:.LC16
	bl	_dev_info
	ldr	x0, [x20, #:lo12:.LANCHOR0]
.L700:
	ldr	x3, [x0, 8]
	mov	w2, 0
	mov	w1, 0
	mov	x0, x3
	ldr	x3, [x3, 144]
	blr	x3
	ldp	w3, w2, [x19, 80]
	mov	w1, 0
	ldr	x0, [x19, 160]
	mul	w2, w2, w3
	sxtw	x2, w2
	bl	memset
	ldp	w3, w2, [x19, 80]
	ldr	x0, [x19, 168]
.L732:
	mul	w2, w2, w3
	mov	w1, 0
	sxtw	x2, w2
	bl	memset
.L731:
	adrp	x2, jiffies
	mov	x1, 402653184
	add	x0, x21, 736
	ldr	x2, [x2, #:lo12:jiffies]
	add	x1, x2, x1
	bl	mod_timer
	str	wzr, [x19, 52]
.L710:
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	mov	w2, 1
	add	x0, x0, 304
	mov	w1, w2
	bl	__wake_up_sync
	ldp	x19, x20, [sp, 16]
	ldr	x21, [sp, 32]
	ldp	x29, x30, [sp], 48
	ret
	.p2align 3
.L694:
	ldr	w0, [x19, 92]
	cbnz	w0, .L736
	ldr	w0, [x19, 60]
	cbnz	w0, .L703
	ldr	w0, [x19, 64]
	cbnz	w0, .L703
	ldr	w0, [x19, 68]
	cbnz	w0, .L737
	.p2align 2
.L703:
	add	x20, x20, :lo12:.LANCHOR0
	ldr	x0, [x20, 8]
	bl	wake_up_process
.L692:
	ldp	x19, x20, [sp, 16]
	ldr	x21, [sp, 32]
	ldp	x29, x30, [sp], 48
	ret
	.p2align 3
.L706:
	ldr	w1, [x19, 92]
	mov	x0, x21
	cbz	w1, .L708
	b	.L707
	.p2align 3
.L736:
	ldr	w1, [x19, 624]
	mov	x0, x21
	cmp	w1, 0
	ble	.L702
	ldr	x0, [x19, 96]
	adrp	x1, .LC17
	add	x1, x1, :lo12:.LC17
	bl	_dev_info
	ldr	x0, [x20, #:lo12:.LANCHOR0]
.L702:
	ldr	x3, [x0, 8]
	mov	w2, 0
	mov	w1, 0
	mov	x0, x3
	ldr	x3, [x3, 144]
	blr	x3
	b	.L731
	.p2align 3
.L712:
	ldr	x3, [x21, 8]
	b	.L730
	.p2align 3
.L737:
	ldr	w1, [x19, 624]
	mov	x0, x21
	cmp	w1, 0
	ble	.L705
	ldr	x0, [x19, 96]
	adrp	x1, .LC18
	add	x1, x1, :lo12:.LC18
	bl	_dev_info
	ldr	x0, [x20, #:lo12:.LANCHOR0]
.L705:
	ldr	x3, [x0, 8]
	mov	w2, 0
	mov	w1, 0
	mov	x0, x3
	ldr	x3, [x3, 144]
	blr	x3
	ldp	w3, w2, [x19, 80]
	ldr	x0, [x19, 160]
	b	.L732
	.p2align 3
.L735:
	add	x0, x20, :lo12:.LANCHOR0
	str	w1, [x19, 52]
	ldr	x0, [x0, 8]
	bl	wake_up_process
	b	.L692
	.size	frame_done_callback, .-frame_done_callback
	.align	2
	.p2align 3,,7
	.type	ebc_frame_timeout, %function
ebc_frame_timeout:
	stp	x29, x30, [sp, -16]!
	add	x29, sp, 0
	bl	frame_done_callback
	ldp	x29, x30, [sp], 16
	ret
	.size	ebc_frame_timeout, .-ebc_frame_timeout
	.align	2
	.p2align 3,,7
	.type	ebc_buffer_manage_init, %function
ebc_buffer_manage_init:
	stp	x29, x30, [sp, -192]!
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	mov	x19, x0
	stp	x23, x24, [sp, 48]
	mov	x20, x0
	stp	x21, x22, [sp, 32]
	adrp	x24, __stack_chk_guard
	stp	x25, x26, [sp, 64]
	add	x0, x24, :lo12:__stack_chk_guard
	ldr	x21, [x19], 216
	ldr	x1, [x0]
	str	x1, [x29, 184]
	mov	x1,0
	ldr	w0, [x19, 28]
	cmp	w0, 5242880
	bgt	.L760
	ldr	x0, [x21, 752]
	adrp	x1, .LC22
	mov	w2, 0
	add	x1, x1, :lo12:.LC22
	bl	of_parse_phandle
	cbz	x0, .L752
	add	x2, x29, 88
	mov	w1, 0
	bl	of_address_to_resource
	mov	w25, w0
	cbnz	w0, .L761
	ldp	x1, x2, [x29, 88]
	str	x1, [x20, 216]
	mov	w0, 58720255
	add	x2, x2, 1
	sub	x2, x2, x1
	str	w2, [x19, 24]
	cmp	w2, w0
	ble	.L762
	mov	x3, 1
	sxtw	x2, w2
	mov	x0, x21
	bl	devm_memremap
	str	x0, [x19, 8]
	mov	x1, x0
	cbz	x0, .L763
	ldr	w2, [x19, 24]
	mov	w4, 4
	ldr	x0, [x20, 216]
	mov	w3, 5242880
	bl	ebc_buf_init
	mov	w25, w0
	cbnz	w0, .L750
	add	x0, x20, 848
	add	x26, x20, 888
	mov	x23, x0
	mov	x22, x0
	mov	x21, 0
	stp	xzr, xzr, [x0]
	stp	xzr, xzr, [x0, 16]
	str	xzr, [x20, 880]
.L748:
	ldr	x0, [x19]
	mov	x1, 5242880
	add	x0, x21, x0
	bl	ebc_get_dma_buf
	cmn	x0, #4096
	bhi	.L755
	str	x0, [x22], 8
	add	x21, x21, 5242880
	cmp	x22, x26
	bne	.L748
	ldr	x1, [x19, 8]
	mov	x0, 20971520
	mov	x4, 2097152
	mov	x2, 26214400
	add	x0, x1, x0
	str	x0, [x19, 16]
	str	x4, [x20, 80]
	add	x3, x1, x2
	str	x3, [x20, 64]
	ldr	x0, [x19]
	add	x2, x0, x2
	str	x2, [x20, 72]
	str	x3, [x19, 176]
	mov	x3, 28311552
	str	x4, [x20, 104]
	add	x2, x1, x3
	add	x0, x0, x3
	stp	x2, x0, [x20, 88]
	str	x2, [x19, 184]
	mov	x0, 30408704
	mov	x2, 35651584
	add	x0, x1, x0
	add	x2, x1, x2
	str	x0, [x19, 136]
	mov	x0, 40894464
	add	x0, x1, x0
	stp	x2, x0, [x19, 144]
	mov	x2, 46137344
	add	x2, x1, x2
	mov	x3, 57671680
	mov	x0, 51380224
	add	x0, x1, x0
	stp	x2, x0, [x19, 160]
	mov	x2, 56623104
	add	x2, x1, x2
	add	x1, x1, x3
	stp	x2, x1, [x19, 120]
	mov	w1, 0
	ldp	w3, w2, [x20, 116]
	mul	w2, w3, w2
	bl	memset
	ldp	w3, w2, [x20, 116]
	mov	w1, 0
	ldr	x0, [x19, 160]
	mul	w2, w3, w2
	bl	memset
	ldrsw	x2, [x19, 28]
	mov	w1, 240
	ldr	x0, [x19, 152]
	bl	memset
.L740:
	add	x24, x24, :lo12:__stack_chk_guard
	mov	w0, w25
	ldr	x2, [x29, 184]
	ldr	x1, [x24]
	eor	x1, x2, x1
	cbnz	x1, .L764
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x29, x30, [sp], 192
	ret
	.p2align 3
.L755:
	ldr	x0, [x23]
	cbz	x0, .L749
	bl	dma_buf_put
	str	xzr, [x23]
.L749:
	add	x23, x23, 8
	cmp	x26, x23
	bne	.L755
.L750:
	mov	w25, -12
	b	.L740
	.p2align 3
.L761:
	adrp	x1, .LC23
	mov	x0, x21
	add	x1, x1, :lo12:.LC23
	bl	_dev_err
	b	.L740
	.p2align 3
.L760:
	adrp	x1, .LC21
	mov	x0, x21
	add	x1, x1, :lo12:.LC21
	mov	w25, -19
	bl	_dev_err
	b	.L740
	.p2align 3
.L762:
	adrp	x1, .LC24
	mov	w2, 58720256
	add	x1, x1, :lo12:.LC24
	mov	x0, x21
	mov	w25, -19
	bl	_dev_err
	b	.L740
.L752:
	mov	w25, -19
	b	.L740
.L763:
	adrp	x1, .LC25
	mov	x0, x21
	add	x1, x1, :lo12:.LC25
	mov	w25, -12
	bl	_dev_err
	b	.L740
.L764:
	bl	__stack_chk_fail
	.size	ebc_buffer_manage_init, .-ebc_buffer_manage_init
	.align	2
	.p2align 3,,7
	.type	ebc_lut_table_init, %function
ebc_lut_table_init:
	stp	x29, x30, [sp, -176]!
	adrp	x1, .LC26
	add	x1, x1, :lo12:.LC26
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	mov	x20, x0
	stp	x21, x22, [sp, 32]
	adrp	x19, __stack_chk_guard
	str	x23, [sp, 48]
	add	x0, x19, :lo12:__stack_chk_guard
	ldr	x23, [x20, 96]
	ldr	x2, [x0]
	str	x2, [x29, 168]
	mov	x2,0
	ldr	x21, [x23, 752]
	mov	x0, x21
	bl	of_parse_phandle
	cbz	x0, .L770
	mov	x22, x0
	adrp	x1, .LC27
	add	x2, x29, 68
	add	x1, x1, :lo12:.LC27
	mov	x0, x21
	bl	of_get_property
	ldr	w1, [x29, 68]
	cmp	w1, 0
	ble	.L771
	bl	pvi_wf_add_custom_mode_table
	cbnz	w0, .L770
.L771:
	add	x2, x29, 72
	mov	w1, 0
	mov	x0, x22
	bl	of_address_to_resource
	mov	w21, w0
	cbz	w0, .L779
.L765:
	add	x19, x19, :lo12:__stack_chk_guard
	mov	w0, w21
	ldr	x2, [x29, 168]
	ldr	x1, [x19]
	eor	x1, x2, x1
	cbnz	x1, .L780
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldr	x23, [sp, 48]
	ldp	x29, x30, [sp], 176
	ret
	.p2align 3
.L779:
	ldp	x0, x22, [x29, 72]
	mov	x3, 1
	str	x0, [x20, 40]
	add	x22, x22, x3
	mov	x1, x0
	sub	x22, x22, x0
	str	w22, [x20, 48]
	sxtw	x2, w22
	mov	x0, x23
	bl	devm_memremap
	str	x0, [x20, 200]
	cbz	x0, .L781
	bl	epd_lut_from_mem_init
	tbz	w0, #31, .L765
	ldr	x0, [x20, 96]
	adrp	x1, .LC29
	add	x1, x1, :lo12:.LC29
	bl	_dev_err
	ldr	x0, [x20, 96]
	mov	w2, w22
	ldr	x1, [x20, 200]
	bl	epd_lut_from_file_init
	tbz	w0, #31, .L765
	ldr	x0, [x20, 96]
	mov	w21, -1
	adrp	x1, .LC30
	add	x1, x1, :lo12:.LC30
	bl	_dev_err
	b	.L765
	.p2align 3
.L770:
	mov	w21, -19
	b	.L765
.L781:
	ldr	x0, [x20, 96]
	adrp	x2, .LANCHOR3
	adrp	x1, .LC28
	mov	w3, 3709
	add	x2, x2, :lo12:.LANCHOR3
	add	x1, x1, :lo12:.LC28
	mov	w21, -12
	bl	_dev_err
	b	.L765
.L780:
	bl	__stack_chk_fail
	.size	ebc_lut_table_init, .-ebc_lut_table_init
	.align	2
	.p2align 3,,7
	.type	ebc_lut_update, %function
ebc_lut_update:
	stp	x29, x30, [sp, -80]!
	add	x29, sp, 0
	stp	x21, x22, [sp, 32]
	mov	x21, x0
	stp	x19, x20, [sp, 16]
	mov	w0, 25
	str	x23, [sp, 48]
	adrp	x19, __stack_chk_guard
	str	w0, [x29, 68]
	add	x3, x19, :lo12:__stack_chk_guard
	ldr	x0, [x21, 16]
	ldr	x4, [x3]
	str	x4, [x29, 72]
	mov	x4,0
	mov	w20, w1
	mov	w23, w2
	cbz	x0, .L783
	ldr	x2, [x0, 56]
	add	x1, x29, 68
	blr	x2
	mov	w3, w0
.L784:
	cbnz	w3, .L785
	ldr	w2, [x29, 68]
	add	x22, x21, 216
	ldr	w0, [x22, 624]
	tbnz	w2, #31, .L817
	cmp	w2, 50
	ble	.L788
	tbnz	w0, #31, .L790
	ldr	x0, [x22, 96]
	adrp	x1, .LC32
	add	x1, x1, :lo12:.LC32
	bl	_dev_info
	ldr	w0, [x22, 624]
.L790:
	mov	w2, 50
	str	w2, [x29, 68]
	cmp	w0, 0
	bgt	.L818
	.p2align 2
.L791:
	sub	w1, w20, #1
	cmp	w1, 22
	bls	.L819
.L810:
	mov	w1, 3
	.p2align 2
.L792:
	mov	w4, w23
	mov	w3, 32
	add	x0, x21, 320
	bl	epd_lut_get
	mov	w20, w0
	cbz	w0, .L782
	ldr	x0, [x22, 96]
	adrp	x1, .LC35
	add	x1, x1, :lo12:.LC35
	bl	_dev_err
.L782:
	add	x19, x19, :lo12:__stack_chk_guard
	mov	w0, w20
	ldr	x2, [x29, 72]
	ldr	x1, [x19]
	eor	x1, x2, x1
	cbnz	x1, .L820
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldr	x23, [sp, 48]
	ldp	x29, x30, [sp], 80
	ret
	.p2align 3
.L785:
	add	x22, x21, 216
	ldr	w0, [x22, 624]
	mov	w2, 25
	str	w2, [x29, 68]
	tbnz	w0, #31, .L791
	ldr	x0, [x22, 96]
	mov	w2, w3
	adrp	x1, .LC33
	add	x1, x1, :lo12:.LC33
	bl	_dev_info
	ldr	w0, [x22, 624]
	ldr	w2, [x29, 68]
.L788:
	cmp	w0, 0
	ble	.L791
.L818:
	ldr	x0, [x22, 96]
	adrp	x1, .LC34
	add	x1, x1, :lo12:.LC34
	bl	_dev_info
	sub	w1, w20, #1
	ldr	w2, [x29, 68]
	cmp	w1, 22
	bhi	.L810
.L819:
	adrp	x0, .L794
	add	x0, x0, :lo12:.L794
	ldrb	w0, [x0,w1,uxtw]
	adr	x1, .Lrtx794
	add	x0, x1, w0, sxtb #2
	br	x0
.Lrtx794:
	.section	.rodata
	.align	0
	.align	2
.L794:
	.byte	(.L793 - .Lrtx794) / 4
	.byte	(.L810 - .Lrtx794) / 4
	.byte	(.L795 - .Lrtx794) / 4
	.byte	(.L796 - .Lrtx794) / 4
	.byte	(.L797 - .Lrtx794) / 4
	.byte	(.L798 - .Lrtx794) / 4
	.byte	(.L799 - .Lrtx794) / 4
	.byte	(.L800 - .Lrtx794) / 4
	.byte	(.L801 - .Lrtx794) / 4
	.byte	(.L802 - .Lrtx794) / 4
	.byte	(.L798 - .Lrtx794) / 4
	.byte	(.L803 - .Lrtx794) / 4
	.byte	(.L803 - .Lrtx794) / 4
	.byte	(.L804 - .Lrtx794) / 4
	.byte	(.L805 - .Lrtx794) / 4
	.byte	(.L804 - .Lrtx794) / 4
	.byte	(.L806 - .Lrtx794) / 4
	.byte	(.L810 - .Lrtx794) / 4
	.byte	(.L810 - .Lrtx794) / 4
	.byte	(.L810 - .Lrtx794) / 4
	.byte	(.L810 - .Lrtx794) / 4
	.byte	(.L804 - .Lrtx794) / 4
	.byte	(.L805 - .Lrtx794) / 4
	.text
	.p2align 3
.L817:
	tbnz	w0, #31, .L787
	ldr	x0, [x22, 96]
	adrp	x1, .LC31
	add	x1, x1, :lo12:.LC31
	bl	_dev_info
	ldr	w0, [x22, 624]
.L787:
	mov	w2, 25
	str	w2, [x29, 68]
	b	.L788
	.p2align 3
.L796:
	mov	w1, 5
	b	.L792
	.p2align 3
.L805:
	mov	w1, 2
	b	.L792
	.p2align 3
.L803:
	mov	w1, 7
	b	.L792
	.p2align 3
.L804:
	mov	w1, 1
	b	.L792
	.p2align 3
.L793:
	mov	w1, 10
	b	.L792
	.p2align 3
.L795:
	mov	w1, 4
	b	.L792
	.p2align 3
.L797:
	mov	w1, 6
	b	.L792
	.p2align 3
.L798:
	mov	w1, 8
	b	.L792
	.p2align 3
.L799:
	ldr	w3, [x22, 612]
	mov	w1, 3
	mov	w0, 14
	cmp	w3, 0
	csel	w1, w1, w0, eq
	b	.L792
	.p2align 3
.L800:
	ldr	w3, [x22, 612]
	mov	w1, 4
	mov	w0, 13
	cmp	w3, 0
	csel	w1, w1, w0, eq
	b	.L792
	.p2align 3
.L801:
	mov	w1, 11
	ldr	w23, [x21, 192]
	b	.L792
	.p2align 3
.L802:
	mov	w1, 12
	ldr	w23, [x21, 192]
	b	.L792
	.p2align 3
.L806:
	mov	w1, 0
	b	.L792
	.p2align 3
.L783:
	ldr	x0, [x21, 32]
	add	x1, x29, 68
	bl	thermal_zone_get_temp
	mov	w3, w0
	ldr	w1, [x29, 68]
	mov	w0, 19923
	movk	w0, 0x1062, lsl 16
	smull	x0, w1, w0
	asr	x0, x0, 38
	sub	w0, w0, w1, asr 31
	str	w0, [x29, 68]
	b	.L784
.L820:
	bl	__stack_chk_fail
	.size	ebc_lut_update, .-ebc_lut_update
	.align	2
	.p2align 3,,7
	.type	wf_data_write, %function
wf_data_write:
	stp	x29, x30, [sp, -128]!
	adrp	x1, .LC36
	mov	x0, x2
	add	x1, x1, :lo12:.LC36
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	mov	x19, x3
	stp	x21, x22, [sp, 32]
	stp	x23, x24, [sp, 48]
	stp	x25, x26, [sp, 64]
	stp	x27, x28, [sp, 80]
	bl	strstr
	cbnz	x0, .L840
.L822:
	mov	x0, x19
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	ldp	x29, x30, [sp], 128
	ret
.L840:
	adrp	x1, .LANCHOR0
	adrp	x0, .LC37
	mov	w22, 0
	add	x0, x0, :lo12:.LC37
	ldr	x1, [x1, #:lo12:.LANCHOR0]
	adrp	x24, .LC38
	adrp	x25, .LC39
	ldrb	w23, [x1, 320]
	ldr	x28, [x1, 336]
	sub	w27, w23, #1
	mov	w1, w23
	ubfiz	x27, x27, 10, 32
	add	x27, x27, 1024
	bl	printk
	.p2align 2
.L823:
	mov	w21, w22
	add	x26, x25, :lo12:.LC39
	mov	w20, 0
	.p2align 2
.L825:
	mov	w2, w22
	mov	w1, w20
	add	x0, x24, :lo12:.LC38
	bl	printk
	cbnz	w23, .L824
.L828:
	add	w20, w20, 1
	add	w21, w21, 32
	cmp	w20, 32
	bne	.L825
	add	w22, w22, 1
	cmp	w22, 32
	bne	.L823
	b	.L822
.L824:
	sxtw	x2, w21
	add	x3, x27, x2
	add	x2, x28, x2
	add	x3, x28, x3
.L827:
	ldrb	w1, [x2]
	add	x2, x2, 1024
	mov	x0, x26
	stp	x2, x3, [x29, 104]
	str	x2, [x29, 120]
	bl	printk
	ldp	x3, x2, [x29, 112]
	cmp	x2, x3
	beq	.L828
	b	.L827
	.size	wf_data_write, .-wf_data_write
	.align	2
	.p2align 3,,7
	.type	ebc_debug_level_write, %function
ebc_debug_level_write:
	stp	x29, x30, [sp, -64]!
	adrp	x0, .LANCHOR0
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	adrp	x19, __stack_chk_guard
	stp	x21, x22, [sp, 32]
	add	x1, x19, :lo12:__stack_chk_guard
	mov	x21, x2
	ldr	x22, [x0, #:lo12:.LANCHOR0]
	ldr	x2, [x1]
	str	x2, [x29, 56]
	mov	x2,0
	mov	x20, x3
	add	x2, x29, 52
	mov	w1, 0
	mov	x0, x21
	bl	kstrtouint
	cbnz	w0, .L846
	ldr	w1, [x29, 52]
	mov	x0, x20
	str	w1, [x22, 840]
.L841:
	add	x19, x19, :lo12:__stack_chk_guard
	ldr	x2, [x29, 56]
	ldr	x1, [x19]
	eor	x1, x2, x1
	cbnz	x1, .L847
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 64
	ret
	.p2align 3
.L846:
	ldr	x0, [x22, 312]
	adrp	x1, .LC40
	mov	x2, x21
	add	x1, x1, :lo12:.LC40
	bl	_dev_err
	mov	x0, -1
	b	.L841
.L847:
	bl	__stack_chk_fail
	.size	ebc_debug_level_write, .-ebc_debug_level_write
	.align	2
	.p2align 3,,7
	.type	ebc_debug_level_read, %function
ebc_debug_level_read:
	stp	x29, x30, [sp, -16]!
	adrp	x3, .LANCHOR0
	mov	x0, x2
	adrp	x1, .LC41
	add	x29, sp, 0
	ldr	x2, [x3, #:lo12:.LANCHOR0]
	add	x1, x1, :lo12:.LC41
	ldr	w2, [x2, 840]
	bl	sprintf
	sxtw	x0, w0
	ldp	x29, x30, [sp], 16
	ret
	.size	ebc_debug_level_read, .-ebc_debug_level_read
	.align	2
	.p2align 3,,7
	.type	ebc_state_read, %function
ebc_state_read:
	stp	x29, x30, [sp, -16]!
	adrp	x3, .LANCHOR0
	mov	x0, x2
	adrp	x1, .LC41
	add	x29, sp, 0
	ldr	x2, [x3, #:lo12:.LANCHOR0]
	add	x1, x1, :lo12:.LC41
	ldr	w2, [x2, 672]
	bl	sprintf
	sxtw	x0, w0
	ldp	x29, x30, [sp], 16
	ret
	.size	ebc_state_read, .-ebc_state_read
	.align	2
	.p2align 3,,7
	.type	ebc_version_read, %function
ebc_version_read:
	stp	x29, x30, [sp, -16]!
	mov	x0, x2
	adrp	x1, .LC43
	adrp	x2, .LC42
	add	x29, sp, 0
	add	x2, x2, :lo12:.LC42
	add	x1, x1, :lo12:.LC43
	bl	sprintf
	sxtw	x0, w0
	ldp	x29, x30, [sp], 16
	ret
	.size	ebc_version_read, .-ebc_version_read
	.align	2
	.p2align 3,,7
	.type	pmic_temp_read, %function
pmic_temp_read:
	stp	x29, x30, [sp, -48]!
	adrp	x1, .LANCHOR0
	add	x29, sp, 0
	ldr	x1, [x1, #:lo12:.LANCHOR0]
	stp	x19, x20, [sp, 16]
	adrp	x19, __stack_chk_guard
	add	x0, x19, :lo12:__stack_chk_guard
	mov	x20, x2
	ldr	x2, [x0]
	str	x2, [x29, 40]
	mov	x2,0
	ldr	x0, [x1, 16]
	cbz	x0, .L855
	ldr	x2, [x0, 56]
	add	x1, x29, 36
	blr	x2
.L856:
	ldr	w2, [x29, 36]
	adrp	x1, .LC41
	mov	x0, x20
	add	x1, x1, :lo12:.LC41
	add	x19, x19, :lo12:__stack_chk_guard
	bl	sprintf
	sxtw	x0, w0
	ldr	x2, [x29, 40]
	ldr	x1, [x19]
	eor	x1, x2, x1
	cbnz	x1, .L859
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 48
	ret
	.p2align 3
.L855:
	ldr	x0, [x1, 32]
	add	x1, x29, 36
	bl	thermal_zone_get_temp
	b	.L856
.L859:
	bl	__stack_chk_fail
	.size	pmic_temp_read, .-pmic_temp_read
	.align	2
	.p2align 3,,7
	.type	pmic_name_read, %function
pmic_name_read:
	stp	x29, x30, [sp, -16]!
	adrp	x3, .LANCHOR0
	mov	x0, x2
	adrp	x1, .LC43
	add	x29, sp, 0
	ldr	x2, [x3, #:lo12:.LANCHOR0]
	add	x1, x1, :lo12:.LC43
	ldr	x2, [x2, 16]
	add	x2, x2, 8
	bl	sprintf
	sxtw	x0, w0
	ldp	x29, x30, [sp], 16
	ret
	.size	pmic_name_read, .-pmic_name_read
	.align	2
	.p2align 3,,7
	.type	ebc_buf_state_read, %function
ebc_buf_state_read:
	stp	x29, x30, [sp, -16]!
	mov	x0, x2
	add	x29, sp, 0
	bl	ebc_buf_state_show
	sxtw	x0, w0
	ldp	x29, x30, [sp], 16
	ret
	.size	ebc_buf_state_read, .-ebc_buf_state_read
	.align	2
	.p2align 3,,7
	.type	pmic_vcom_write, %function
pmic_vcom_write:
	stp	x29, x30, [sp, -64]!
	adrp	x0, .LANCHOR0
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	adrp	x19, __stack_chk_guard
	stp	x21, x22, [sp, 32]
	add	x1, x19, :lo12:__stack_chk_guard
	mov	x22, x2
	ldr	x21, [x0, #:lo12:.LANCHOR0]
	ldr	x2, [x1]
	str	x2, [x29, 56]
	mov	x2,0
	mov	x20, x3
	add	x2, x29, 52
	mov	w1, 0
	mov	x0, x22
	bl	kstrtouint
	cbnz	w0, .L873
	ldr	x0, [x21, 16]
	ldr	w1, [x29, 52]
	cbz	x0, .L867
	bl	ebc_pmic_set_vcom
.L868:
	cbnz	w0, .L874
.L864:
	add	x19, x19, :lo12:__stack_chk_guard
	mov	x0, x20
	ldr	x2, [x29, 56]
	ldr	x1, [x19]
	eor	x1, x2, x1
	cbnz	x1, .L875
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 64
	ret
	.p2align 3
.L867:
	ldr	x0, [x21, 24]
	bl	ebc_regulator_set_vcom
	b	.L868
	.p2align 3
.L873:
	ldr	x0, [x21]
	adrp	x1, .LC40
	mov	x2, x22
	add	x1, x1, :lo12:.LC40
	mov	x20, -1
	bl	_dev_err
	b	.L864
	.p2align 3
.L874:
	ldr	x0, [x21]
	adrp	x1, .LC44
	mov	x20, -1
	add	x1, x1, :lo12:.LC44
	bl	_dev_err
	b	.L864
.L875:
	bl	__stack_chk_fail
	.size	pmic_vcom_write, .-pmic_vcom_write
	.align	2
	.p2align 3,,7
	.type	pmic_vcom_read, %function
pmic_vcom_read:
	stp	x29, x30, [sp, -32]!
	adrp	x0, .LANCHOR0
	add	x29, sp, 0
	ldr	x1, [x0, #:lo12:.LANCHOR0]
	str	x19, [sp, 16]
	mov	x19, x2
	ldr	x0, [x1, 16]
	cbz	x0, .L877
	ldr	x1, [x0, 64]
	blr	x1
	mov	w2, w0
	adrp	x1, .LC41
	mov	x0, x19
	add	x1, x1, :lo12:.LC41
	bl	sprintf
	sxtw	x0, w0
	ldr	x19, [sp, 16]
	ldp	x29, x30, [sp], 32
	ret
	.p2align 3
.L877:
	ldr	x0, [x1, 24]
	bl	regulator_get_voltage
	mov	w2, 19923
	adrp	x1, .LC41
	movk	w2, 0x1062, lsl 16
	add	x1, x1, :lo12:.LC41
	smull	x2, w0, w2
	asr	x2, x2, 38
	sub	w2, w2, w0, asr 31
	mov	x0, x19
	bl	sprintf
	sxtw	x0, w0
	ldr	x19, [sp, 16]
	ldp	x29, x30, [sp], 32
	ret
	.size	pmic_vcom_read, .-pmic_vcom_read
	.align	2
	.p2align 3,,7
	.type	waveform_version_read, %function
waveform_version_read:
	stp	x29, x30, [sp, -32]!
	add	x29, sp, 0
	str	x19, [sp, 16]
	mov	x19, x2
	bl	epd_lut_get_wf_version
	mov	x2, x0
	adrp	x1, .LC43
	mov	x0, x19
	add	x1, x1, :lo12:.LC43
	bl	sprintf
	sxtw	x0, w0
	ldr	x19, [sp, 16]
	ldp	x29, x30, [sp], 32
	ret
	.size	waveform_version_read, .-waveform_version_read
	.section	.init.text,"ax",@progbits
	.align	2
	.type	ebc_init, %function
ebc_init:
	stp	x29, x30, [sp, -16]!
	mov	x1, 0
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x29, sp, 0
	bl	__platform_driver_register
	ldp	x29, x30, [sp], 16
	ret
	.size	ebc_init, .-ebc_init
	.text
	.align	2
	.p2align 3,,7
	.type	get_overlay_image_area2.isra.0, %function
get_overlay_image_area2.isra.0:
	stp	x29, x30, [sp, -128]!
	adrp	x5, .LANCHOR0
	mov	x10, x0
	add	x29, sp, 0
	ldr	x5, [x5, #:lo12:.LANCHOR0]
	stp	x19, x20, [sp, 16]
	add	x5, x5, 40
	stp	x5, x0, [x29, 96]
	ldr	x0, [x4, 232]
	stp	x21, x22, [sp, 32]
	stp	x23, x24, [sp, 48]
	stp	x25, x26, [sp, 64]
	stp	x27, x28, [sp, 80]
	ldr	w17, [x4, 84]
	ldp	w7, w21, [x0, 48]
	ldr	w13, [x5, 76]
	ldr	w5, [x0, 56]
	cmp	w7, 0
	add	w6, w7, 7
	csel	w6, w6, w7, lt
	add	w30, w5, 7
	cmp	w5, 0
	asr	w7, w6, 3
	csel	w30, w30, w5, lt
	ldr	w5, [x0, 60]
	cmp	w17, 0
	add	w0, w17, 7
	csel	w0, w0, w17, lt
	asr	w30, w30, 3
	mov	w9, w5
	add	w30, w30, 1
	asr	w5, w0, 3
	ldr	w0, [x4, 80]
	cmp	w30, w5
	mul	w13, w21, w13
	mov	w6, w5
	str	w5, [x29, 116]
	sub	w5, w5, #1
	str	w7, [x29, 124]
	csel	w30, w5, w30, ge
	cmp	w9, w0
	sub	w0, w0, #1
	lsr	w13, w13, 2
	csel	w0, w0, w9, ge
	str	w0, [x29, 120]
	add	x13, x10, x13
	cmp	w21, w0
	bgt	.L884
	mul	w18, w21, w6
	mov	w19, 1
	mov	w16, w19
	lsl	w0, w7, 3
	str	w0, [x29, 112]
	.p2align 2
.L888:
	and	w0, w21, 1
	tbnz	x21, 0, .L889
	ldr	x5, [x29, 96]
	ldr	w13, [x5, 76]
	ldr	x5, [x29, 104]
	mul	w13, w21, w13
	lsr	w13, w13, 2
	add	x13, x5, x13
.L889:
	mul	w17, w21, w17
	ldr	w5, [x29, 124]
	cmp	w5, w30
	sxtw	x17, w17
	bgt	.L902
	cmp	w0, 0
	ldr	w11, [x29, 112]
	mov	w0, 2
	ldr	w9, [x29, 124]
	csel	w20, w0, wzr, ne
	add	w28, w20, 4
	add	w27, w20, 8
	add	w26, w20, 12
	add	w25, w20, 16
	add	w24, w20, 20
	add	w23, w20, 24
	add	w22, w20, 28
	.p2align 2
.L901:
	sxtw	x8, w9
	lsl	x0, x8, 3
	add	x0, x0, x18, sxtw 3
	ldr	x7, [x1, x0]
	ldr	x6, [x2, x0]
	cmp	x7, x6
	beq	.L892
	add	x12, x17, x11, sxtw
	str	w19, [x4, 60]
	eor	x5, x7, x6
	add	x0, x3, x12
	and	x14, x5, 255
	mov	w10, 0
	ldrb	w15, [x3, x12]
	cmp	w15, 0
	ccmp	x14, 0, 4, eq
	beq	.L893
	lsl	x10, x6, 2
	ldr	x14, [x4, 120]
	and	x10, x10, 992
	ubfx	x15, x7, 3, 5
	orr	x10, x10, x15
	ldrb	w10, [x14, x10]
	strb	w19, [x3, x12]
	lsl	w10, w10, w20
.L893:
	ldrb	w12, [x0, 1]
	cmp	w12, 0
	and	x12, x5, 65280
	ccmp	x12, 0, 4, eq
	beq	.L894
	lsr	x12, x6, 6
	ldr	x14, [x4, 120]
	and	x12, x12, 992
	ubfx	x15, x7, 11, 5
	orr	x12, x12, x15
	ldrb	w12, [x14, x12]
	strb	w16, [x0, 1]
	lsl	w12, w12, w28
	orr	w10, w10, w12
.L894:
	ldrb	w12, [x0, 2]
	cmp	w12, 0
	and	x12, x5, 16711680
	ccmp	x12, 0, 4, eq
	beq	.L895
	lsr	x12, x6, 14
	ldr	x14, [x4, 120]
	and	x12, x12, 992
	ubfx	x15, x7, 19, 5
	orr	x12, x12, x15
	ldrb	w12, [x14, x12]
	strb	w16, [x0, 2]
	lsl	w12, w12, w27
	orr	w10, w10, w12
.L895:
	ldrb	w12, [x0, 3]
	tst	x5, 4278190080
	ccmp	w12, 0, 0, ne
	bne	.L896
	lsr	x12, x6, 22
	ldr	x14, [x4, 120]
	and	x12, x12, 992
	lsr	w15, w7, 27
	orr	x12, x12, x15
	ldrb	w12, [x14, x12]
	strb	w16, [x0, 3]
	lsl	w12, w12, w26
	orr	w10, w10, w12
.L896:
	ldrb	w12, [x0, 4]
	cmp	w12, 0
	and	x12, x5, 1095216660480
	ccmp	x12, 0, 4, eq
	beq	.L897
	lsr	x12, x6, 30
	ldr	x14, [x4, 120]
	and	x12, x12, 992
	ubfx	x15, x7, 35, 5
	orr	x12, x12, x15
	ldrb	w12, [x14, x12]
	strb	w16, [x0, 4]
	lsl	w12, w12, w25
	orr	w10, w10, w12
.L897:
	ldrb	w12, [x0, 5]
	cmp	w12, 0
	and	x12, x5, 280375465082880
	ccmp	x12, 0, 4, eq
	beq	.L898
	lsr	x12, x6, 38
	ldr	x14, [x4, 120]
	and	x12, x12, 992
	ubfx	x15, x7, 43, 5
	orr	x12, x12, x15
	ldrb	w12, [x14, x12]
	strb	w16, [x0, 5]
	lsl	w12, w12, w24
	orr	w10, w10, w12
.L898:
	ldrb	w12, [x0, 6]
	tst	x5, 71776119061217280
	ccmp	w12, 0, 0, ne
	bne	.L899
	lsr	x12, x6, 46
	ldr	x14, [x4, 120]
	and	x12, x12, 992
	ubfx	x15, x7, 51, 5
	orr	x12, x12, x15
	ldrb	w12, [x14, x12]
	strb	w16, [x0, 6]
	lsl	w12, w12, w23
	orr	w10, w10, w12
.L899:
	tst	x5, -72057594037927936
	ldrb	w5, [x0, 7]
	ccmp	w5, 0, 0, ne
	bne	.L900
	ldr	x5, [x4, 120]
	lsr	x6, x6, 54
	and	x6, x6, 992
	add	x7, x5, x7, lsr 59
	ldrb	w5, [x7, x6]
	strb	w16, [x0, 7]
	lsl	w0, w5, w22
	orr	w10, w10, w0
.L900:
	ldr	w0, [x13, x8, lsl 2]
	orr	w10, w0, w10
	str	w10, [x13, x8, lsl 2]
.L892:
	add	w9, w9, 1
	add	w11, w11, 8
	cmp	w9, w30
	ble	.L901
.L902:
	ldr	w0, [x29, 116]
	add	w21, w21, 1
	add	w18, w18, w0
	ldr	w0, [x29, 120]
	cmp	w21, w0
	bgt	.L884
	ldr	w17, [x4, 84]
	b	.L888
.L884:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	ldp	x29, x30, [sp], 128
	ret
	.size	get_overlay_image_area2.isra.0, .-get_overlay_image_area2.isra.0
	.align	2
	.p2align 3,,7
	.type	get_one_auto_image2.isra.1, %function
get_one_auto_image2.isra.1:
	ldr	x6, [x1]
	and	w3, w3, 255
	mov	w7, 0
	eor	x8, x6, x0
	and	x9, x8, 255
	cbz	x9, .L929
	lsl	x7, x6, 2
	ldrb	w9, [x2]
	ubfx	x10, x0, 3, 5
	and	x7, x7, 992
	orr	x7, x7, x10
	ldr	x10, [x4]
	add	x7, x10, x7
	lsl	w10, w9, 10
	add	w9, w9, 1
	and	w9, w9, 255
	ldrb	w7, [x7, w10, sxtw]
	cmp	w9, w3
	lsl	w7, w7, w5
	beq	.L968
.L930:
	strb	w9, [x2]
.L929:
	tst	x8, 65280
	beq	.L931
	lsr	x10, x6, 6
	ldrb	w9, [x2, 1]
	ubfx	x11, x0, 11, 5
	and	x10, x10, 992
	orr	x10, x10, x11
	ldr	x11, [x4]
	add	x10, x11, x10
	lsl	w11, w9, 10
	add	w9, w9, 1
	and	w9, w9, 255
	ldrb	w10, [x10, w11, sxtw]
	add	w11, w5, 4
	cmp	w9, w3
	lsl	w10, w10, w11
	orr	w7, w7, w10
	beq	.L969
.L932:
	strb	w9, [x2, 1]
.L931:
	tst	x8, 16711680
	beq	.L933
	lsr	x10, x6, 14
	ldrb	w9, [x2, 2]
	ubfx	x11, x0, 19, 5
	and	x10, x10, 992
	orr	x10, x10, x11
	ldr	x11, [x4]
	add	x10, x11, x10
	lsl	w11, w9, 10
	add	w9, w9, 1
	and	w9, w9, 255
	ldrb	w10, [x10, w11, sxtw]
	add	w11, w5, 8
	cmp	w9, w3
	lsl	w10, w10, w11
	orr	w7, w7, w10
	beq	.L970
.L934:
	strb	w9, [x2, 2]
.L933:
	tst	x8, 4278190080
	beq	.L935
	lsr	x10, x6, 22
	ldrb	w9, [x2, 3]
	lsr	w11, w0, 27
	and	x10, x10, 992
	orr	x10, x10, x11
	ldr	x11, [x4]
	add	x10, x11, x10
	lsl	w11, w9, 10
	add	w9, w9, 1
	and	w9, w9, 255
	ldrb	w10, [x10, w11, sxtw]
	add	w11, w5, 12
	cmp	w9, w3
	lsl	w10, w10, w11
	orr	w7, w7, w10
	beq	.L971
.L936:
	strb	w9, [x2, 3]
.L935:
	tst	x8, 1095216660480
	beq	.L937
	lsr	x10, x6, 30
	ldrb	w9, [x2, 4]
	ubfx	x11, x0, 35, 5
	and	x10, x10, 992
	orr	x10, x10, x11
	ldr	x11, [x4]
	add	x10, x11, x10
	lsl	w11, w9, 10
	add	w9, w9, 1
	and	w9, w9, 255
	ldrb	w10, [x10, w11, sxtw]
	add	w11, w5, 16
	cmp	w9, w3
	lsl	w10, w10, w11
	orr	w7, w7, w10
	beq	.L972
.L938:
	strb	w9, [x2, 4]
.L937:
	tst	x8, 280375465082880
	beq	.L939
	lsr	x10, x6, 38
	ldrb	w9, [x2, 5]
	ubfx	x11, x0, 43, 5
	and	x10, x10, 992
	orr	x10, x10, x11
	ldr	x11, [x4]
	add	x10, x11, x10
	lsl	w11, w9, 10
	add	w9, w9, 1
	and	w9, w9, 255
	ldrb	w10, [x10, w11, sxtw]
	add	w11, w5, 20
	cmp	w9, w3
	lsl	w10, w10, w11
	orr	w7, w7, w10
	beq	.L973
.L940:
	strb	w9, [x2, 5]
.L939:
	tst	x8, 71776119061217280
	beq	.L941
	lsr	x10, x6, 46
	ldrb	w9, [x2, 6]
	ubfx	x11, x0, 51, 5
	and	x10, x10, 992
	orr	x10, x10, x11
	ldr	x11, [x4]
	add	x10, x11, x10
	lsl	w11, w9, 10
	add	w9, w9, 1
	and	w9, w9, 255
	ldrb	w10, [x10, w11, sxtw]
	add	w11, w5, 24
	cmp	w9, w3
	lsl	w10, w10, w11
	orr	w7, w7, w10
	beq	.L974
.L942:
	strb	w9, [x2, 6]
.L941:
	tst	x8, -72057594037927936
	beq	.L943
	ldrb	w8, [x2, 7]
	add	w5, w5, 28
	ldr	x9, [x4]
	ubfiz	x4, x8, 10, 8
	add	x9, x9, x4
	add	w4, w8, 1
	and	w4, w4, 255
	add	x8, x9, x0, lsr 59
	cmp	w4, w3
	lsr	x3, x6, 54
	and	x3, x3, 992
	ldrb	w3, [x8, x3]
	lsl	w5, w3, w5
	orr	w7, w7, w5
	beq	.L975
.L944:
	strb	w4, [x2, 7]
.L943:
	mov	w0, w7
	str	x6, [x1]
	ret
	.p2align 3
.L975:
	and	x6, x6, 72057594037927935
	and	x0, x0, -72057594037927936
	orr	x6, x0, x6
	mov	w4, 0
	b	.L944
	.p2align 3
.L968:
	bfi	x6, x0, 0, 8
	mov	w9, 0
	b	.L930
	.p2align 3
.L969:
	and	x9, x0, 65280
	and	x6, x6, -65281
	orr	x6, x9, x6
	mov	w9, 0
	b	.L932
	.p2align 3
.L970:
	and	x9, x0, 16711680
	and	x6, x6, -16711681
	orr	x6, x9, x6
	mov	w9, 0
	b	.L934
	.p2align 3
.L971:
	and	x9, x0, 4278190080
	and	x6, x6, -4278190081
	orr	x6, x9, x6
	mov	w9, 0
	b	.L936
	.p2align 3
.L972:
	and	x9, x0, 1095216660480
	and	x6, x6, -1095216660481
	orr	x6, x9, x6
	mov	w9, 0
	b	.L938
	.p2align 3
.L973:
	and	x9, x0, 280375465082880
	and	x6, x6, -280375465082881
	orr	x6, x9, x6
	mov	w9, 0
	b	.L940
	.p2align 3
.L974:
	and	x9, x0, 71776119061217280
	and	x6, x6, -71776119061217281
	orr	x6, x9, x6
	mov	w9, 0
	b	.L942
	.size	get_one_auto_image2.isra.1, .-get_one_auto_image2.isra.1
	.align	2
	.p2align 3,,7
	.type	get_auto_image2, %function
get_auto_image2:
	stp	x29, x30, [sp, -128]!
	adrp	x6, .LANCHOR0
	cmp	w5, 2
	add	x29, sp, 0
	stp	x23, x24, [sp, 48]
	ldr	x24, [x6, #:lo12:.LANCHOR0]
	stp	x19, x20, [sp, 16]
	mov	x20, x1
	add	x24, x24, 40
	stp	x21, x22, [sp, 32]
	stp	x25, x26, [sp, 64]
	mov	x19, x4
	stp	x27, x28, [sp, 80]
	mov	x21, x2
	str	x0, [x29, 112]
	add	x0, x4, 60
	ldp	w1, w25, [x24, 76]
	str	x0, [x29, 104]
	mov	x22, x3
	lsr	w0, w1, 3
	str	w0, [x29, 124]
	beq	.L995
	cmp	w5, 3
	mov	x0, 0
	mov	w23, 0
	beq	.L996
.L978:
	ldr	x2, [x29, 112]
	add	x0, x2, x0
	sub	w2, w25, w23
	mul	w2, w2, w1
	mov	w1, 0
	lsr	w2, w2, 2
	bl	memset
	cmp	w23, w25
	bge	.L987
	ldr	w0, [x29, 124]
	add	x13, x19, 120
	mov	w9, 0
	sub	w14, w0, #1
	add	x14, x14, 1
	lsl	x12, x14, 2
	lsl	x14, x14, 3
	.p2align 2
.L985:
	ldr	w7, [x24, 76]
	ldr	x0, [x29, 112]
	mul	w7, w23, w7
	lsr	w7, w7, 2
	add	x26, x0, x7
	ldr	w0, [x29, 124]
	cbz	w0, .L980
	mov	x28, x22
	mov	x15, x21
	mov	x27, x20
	mov	x18, 0
	.p2align 2
.L982:
	ldr	x3, [x27]
	mov	x2, x28
	ldr	x10, [x15]
	mov	x1, x15
	mov	w5, 0
	mov	x4, x13
	mov	x0, x3
	cmp	x3, x10
	beq	.L981
	ldrb	w3, [x19, 56]
	bl	get_one_auto_image2.isra.1
	str	w0, [x26, x18]
	mov	w9, 1
.L981:
	add	x18, x18, 4
	add	x15, x15, 8
	add	x27, x27, 8
	add	x28, x28, 8
	cmp	x18, x12
	bne	.L982
	add	x21, x21, x14
	add	x20, x20, x14
	add	x22, x22, x14
	mov	x18, x21
	mov	x27, x22
	mov	x28, x20
	mov	x15, 0
	.p2align 2
.L984:
	ldr	x3, [x28]
	mov	x1, x18
	ldr	x10, [x18]
	mov	x2, x27
	mov	w5, 2
	mov	x4, x13
	add	x18, x18, 8
	add	x28, x28, 8
	mov	x0, x3
	cmp	x3, x10
	beq	.L983
	ldrb	w3, [x19, 56]
	bl	get_one_auto_image2.isra.1
	ldr	w1, [x26, x15]
	mov	w9, 1
	orr	w0, w1, w0
	str	w0, [x26, x15]
.L983:
	add	x15, x15, 4
	add	x27, x27, 8
	cmp	x15, x12
	bne	.L984
	add	x21, x21, x14
	add	x20, x20, x14
	add	x22, x22, x14
.L980:
	add	w23, w23, 2
	cmp	w25, w23
	bgt	.L985
.L979:
	ldr	x0, [x29, 104]
	str	w9, [x0]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	ldp	x29, x30, [sp], 128
	ret
.L995:
	add	w25, w25, w25, lsr 31
	mov	x0, 0
	asr	w25, w25, 1
	mov	w23, 0
	b	.L978
.L996:
	add	x0, x4, 64
	add	w23, w25, w25, lsr 31
	asr	w23, w23, 1
	str	x0, [x29, 104]
	lsr	w0, w1, 3
	mul	w0, w0, w23
	sbfiz	x0, x0, 3, 32
	add	x20, x20, x0
	add	x21, x2, x0
	mul	w0, w23, w1
	add	x22, x3, x0, uxtw
	lsr	w0, w0, 2
	b	.L978
.L987:
	mov	w9, 0
	b	.L979
	.size	get_auto_image2, .-get_auto_image2
	.align	2
	.p2align 3,,7
	.type	direct_mode_data_change.isra.2, %function
direct_mode_data_change.isra.2:
	adrp	x7, .LANCHOR0
	and	w3, w3, 255
	sub	w4, w3, w4
	cmp	w6, 2
	ldr	x3, [x7, #:lo12:.LANCHOR0]
	lsl	w7, w4, 10
	add	x5, x5, x7, sxtw
	add	x4, x3, 40
	ldp	w7, w3, [x4, 76]
	lsr	w11, w7, 3
	beq	.L1017
	cmp	w6, 3
	mov	w14, w3
	mov	w6, 0
	mov	w12, 0
	beq	.L1018
.L999:
	ldr	w4, [x4, 156]
	cbz	w4, .L1000
	sub	w3, w3, #1
	neg	w15, w7, lsr 2
	sub	w3, w3, w6
	mul	w3, w3, w7
	lsr	w3, w3, 2
	add	x10, x0, x3
.L1003:
	cmp	w12, w14
	bge	.L1011
	sub	w13, w11, #1
	sxtw	x15, w15
	add	x13, x13, 1
	lsl	x13, x13, 3
.L1012:
	mov	x6, 0
	cbz	w11, .L1019
	stp	x29, x30, [sp, -32]!
	add	x29, sp, 0
	str	x19, [sp, 16]
	.p2align 2
.L1008:
	ldr	x0, [x2, x6, lsl 3]
	ldr	x3, [x1, x6, lsl 3]
	lsr	x17, x0, 30
	lsr	x4, x0, 14
	ubfx	x8, x3, 35, 5
	ubfx	x7, x3, 19, 5
	lsr	x30, x0, 22
	lsr	x16, x0, 6
	lsr	x9, x0, 46
	and	x17, x17, 992
	and	x4, x4, 992
	lsr	w19, w3, 27
	orr	x17, x17, x8
	ubfx	x18, x3, 11, 5
	orr	x4, x4, x7
	lsr	x8, x0, 38
	ubfx	x7, x3, 51, 5
	and	x30, x30, 992
	and	x16, x16, 992
	and	x9, x9, 992
	orr	x30, x30, x19
	orr	x16, x16, x18
	orr	x9, x9, x7
	ubfx	x18, x3, 43, 5
	lsl	x7, x0, 2
	and	x8, x8, 992
	orr	x8, x8, x18
	ubfx	x19, x3, 3, 5
	and	x7, x7, 992
	lsr	x0, x0, 54
	ldrb	w18, [x5, x17]
	orr	x7, x7, x19
	ldrb	w17, [x5, x4]
	and	x0, x0, 992
	add	x3, x5, x3, lsr 59
	ldrb	w4, [x5, x30]
	ldrb	w16, [x5, x16]
	ldrb	w9, [x5, x9]
	ldrb	w8, [x5, x8]
	ldrb	w30, [x5, x7]
	lsl	w7, w17, 4
	ldrb	w3, [x3, x0]
	lsl	w0, w18, 8
	orr	w0, w0, w4, lsl 6
	orr	w7, w7, w16, lsl 2
	lsl	w4, w9, 12
	orr	w0, w0, w7
	orr	w4, w4, w8, lsl 10
	orr	w3, w30, w3, lsl 14
	orr	w0, w0, w4
	orr	w0, w0, w3
	strh	w0, [x10, x6, lsl 1]
	add	x6, x6, 1
	cmp	w11, w6
	bgt	.L1008
	add	w12, w12, 1
	add	x1, x1, x13
	add	x2, x2, x13
	add	x10, x10, x15
	cmp	w12, w14
	beq	.L997
.L1020:
	mov	x6, 0
	cbnz	w11, .L1008
	add	w12, w12, 1
	add	x10, x10, x15
	cmp	w12, w14
	bne	.L1020
.L997:
	ldr	x19, [sp, 16]
	ldp	x29, x30, [sp], 32
	ret
.L1019:
	add	w12, w12, 1
	add	x10, x10, x15
	cmp	w12, w14
	bne	.L1012
.L1011:
	ret
.L1000:
	mul	w3, w7, w6
	lsr	w15, w7, 2
	lsr	w3, w3, 2
	add	x10, x0, x3
	b	.L1003
.L1017:
	add	w14, w3, w3, lsr 31
	mov	w6, 0
	asr	w14, w14, 1
	mov	w12, 0
	b	.L999
.L1018:
	add	w12, w3, w3, lsr 31
	asr	w12, w12, 1
	mov	w6, w12
	mul	w8, w11, w12
	sbfiz	x8, x8, 3, 32
	add	x1, x1, x8
	add	x2, x2, x8
	b	.L999
	.size	direct_mode_data_change.isra.2, .-direct_mode_data_change.isra.2
	.align	2
	.p2align 3,,7
	.type	direct_mode_data_change2.isra.3, %function
direct_mode_data_change2.isra.3:
	adrp	x7, .LANCHOR0
	and	w3, w3, 255
	sub	w3, w3, w4
	cmp	w6, 2
	ldr	x4, [x7, #:lo12:.LANCHOR0]
	lsl	w3, w3, 10
	add	x5, x5, x3, sxtw
	ldp	w13, w14, [x4, 116]
	lsr	w9, w13, 3
	beq	.L1045
	mov	w11, 0
	cmp	w6, 3
	beq	.L1046
.L1023:
	lsr	w13, w13, 2
	cmp	w14, w11
	ble	.L1038
.L1049:
	sub	w10, w9, #1
	mul	w12, w13, w11
	add	x10, x10, 1
	lsl	w13, w13, 1
	lsl	x10, x10, 3
.L1039:
	add	x8, x0, x12, sxtw
	cbz	w9, .L1047
	stp	x29, x30, [sp, -48]!
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	.p2align 2
.L1040:
	mov	x7, 0
	.p2align 2
.L1026:
	ldr	x3, [x2, x7, lsl 3]
	ldr	x4, [x1, x7, lsl 3]
	lsr	x20, x3, 30
	lsr	x6, x3, 14
	ubfx	x16, x4, 35, 5
	ubfx	x15, x4, 19, 5
	lsr	x19, x3, 22
	lsr	x18, x3, 6
	lsr	x17, x3, 46
	and	x20, x20, 992
	and	x6, x6, 992
	lsr	w22, w4, 27
	orr	x20, x20, x16
	ubfx	x21, x4, 11, 5
	orr	x6, x6, x15
	lsr	x16, x3, 38
	ubfx	x15, x4, 51, 5
	and	x19, x19, 992
	and	x18, x18, 992
	and	x17, x17, 992
	orr	x19, x19, x22
	orr	x18, x18, x21
	orr	x17, x17, x15
	ubfx	x21, x4, 43, 5
	lsl	x15, x3, 2
	and	x16, x16, 992
	orr	x16, x16, x21
	ubfx	x22, x4, 3, 5
	and	x15, x15, 992
	lsr	x3, x3, 54
	ldrb	w21, [x5, x20]
	orr	x15, x15, x22
	ldrb	w20, [x5, x6]
	and	x3, x3, 992
	add	x4, x5, x4, lsr 59
	ldrb	w6, [x5, x19]
	ldrb	w18, [x5, x18]
	ldrb	w17, [x5, x17]
	ldrb	w16, [x5, x16]
	ldrb	w19, [x5, x15]
	lsl	w15, w20, 8
	ldrb	w4, [x4, x3]
	lsl	w3, w21, 16
	orr	w3, w3, w6, lsl 12
	orr	w15, w15, w18, lsl 4
	lsl	w6, w17, 24
	orr	w3, w3, w15
	orr	w6, w6, w16, lsl 20
	orr	w4, w19, w4, lsl 28
	orr	w3, w3, w6
	orr	w3, w3, w4
	str	w3, [x8, x7, lsl 2]
	add	x7, x7, 1
	cmp	w9, w7
	bgt	.L1026
	add	x1, x1, x10
	add	x2, x2, x10
	mov	x7, 0
	.p2align 2
.L1027:
	ldr	x3, [x2, x7, lsl 3]
	ldr	x4, [x1, x7, lsl 3]
	ldr	w17, [x8, x7, lsl 2]
	lsr	x20, x3, 22
	lsr	x30, x3, 6
	lsr	w16, w4, 27
	ubfx	x15, x4, 11, 5
	lsr	x6, x3, 14
	lsl	x19, x3, 2
	lsr	x18, x3, 38
	and	x20, x20, 992
	and	x30, x30, 992
	ubfx	x22, x4, 19, 5
	orr	x20, x20, x16
	ubfx	x21, x4, 3, 5
	orr	x30, x30, x15
	lsr	x16, x3, 30
	ubfx	x15, x4, 43, 5
	and	x6, x6, 992
	and	x19, x19, 992
	and	x18, x18, 992
	orr	x18, x18, x15
	orr	x6, x6, x22
	orr	x19, x19, x21
	lsr	x15, x3, 46
	ubfx	x21, x4, 35, 5
	and	x16, x16, 992
	lsr	x3, x3, 54
	orr	x16, x16, x21
	ubfx	x22, x4, 51, 5
	and	x3, x3, 992
	add	x4, x5, x4, lsr 59
	and	x15, x15, 992
	ldrb	w21, [x5, x20]
	orr	x15, x15, x22
	ldrb	w20, [x5, x30]
	ldrb	w6, [x5, x6]
	ldrb	w30, [x5, x18]
	ldrb	w19, [x5, x19]
	ldrb	w18, [x5, x16]
	ldrb	w16, [x4, x3]
	lsl	w4, w21, 14
	ldrb	w15, [x5, x15]
	lsl	w3, w20, 6
	orr	w4, w4, w6, lsl 10
	orr	w3, w3, w19, lsl 2
	lsl	w6, w30, 22
	orr	w3, w4, w3
	orr	w6, w6, w18, lsl 18
	lsl	w4, w16, 30
	orr	w3, w3, w6
	orr	w4, w4, w15, lsl 26
	orr	w3, w3, w4
	orr	w3, w17, w3
	str	w3, [x8, x7, lsl 2]
	add	x7, x7, 1
	cmp	w9, w7
	bgt	.L1027
	add	w11, w11, 2
	add	x1, x1, x10
	add	x2, x2, x10
	add	w12, w12, w13
	cmp	w11, w14
	bge	.L1048
.L1028:
	add	x8, x0, x12, sxtw
	cbnz	w9, .L1040
	add	w11, w11, 2
	add	w12, w12, w13
	cmp	w11, w14
	blt	.L1028
.L1048:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 48
	ret
.L1047:
	add	w11, w11, 2
	add	w12, w12, w13
	cmp	w11, w14
	blt	.L1039
	ret
.L1045:
	add	w14, w14, w14, lsr 31
	mov	w11, 0
	asr	w14, w14, 1
	lsr	w13, w13, 2
	cmp	w14, w11
	bgt	.L1049
.L1038:
	ret
.L1046:
	add	w11, w14, w14, lsr 31
	asr	w11, w11, 1
	mul	w3, w9, w11
	sbfiz	x3, x3, 3, 32
	add	x1, x1, x3
	add	x2, x2, x3
	b	.L1023
	.size	direct_mode_data_change2.isra.3, .-direct_mode_data_change2.isra.3
	.align	2
	.p2align 3,,7
	.type	flip.isra.4, %function
flip.isra.4:
	stp	x29, x30, [sp, -48]!
	sxtw	x2, w1
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	mov	x19, x0
	str	x21, [sp, 32]
	ldp	w21, w4, [x0, 132]
	ldr	w3, [x0, 140]
	ldr	w20, [x0, 72]
	add	w21, w21, w4
	ldr	x0, [x0]
	add	w21, w21, w3
	cbz	x0, .L1053
	ldr	x3, [x0, 648]
	adrp	x4, dummy_dma_ops
	add	x4, x4, :lo12:dummy_dma_ops
	cmp	x3, 0
	csel	x3, x4, x3, eq
.L1051:
	ldr	x5, [x3, 88]
	sxtw	x20, w20
	cbz	x5, .L1052
	add	x4, x20, x20, lsl 1
	mov	w3, 1
	add	x4, x19, x4, lsl 3
	ldr	x1, [x4, 32]
	blr	x5
.L1052:
	ldr	x5, [x19, 8]
	mov	w4, 0
	mov	w3, 0
	mov	w2, 0
	mov	x0, x5
	mov	w1, 0
	add	x20, x20, x20, lsl 1
	ldr	x5, [x5, 88]
	add	x20, x19, x20, lsl 3
	blr	x5
	ldr	x1, [x19, 8]
	mov	w2, 0
	mov	x0, x1
	ldr	x3, [x1, 96]
	ldr	w1, [x20, 32]
	blr	x3
	ldr	x3, [x19, 8]
	mov	w1, w21
	mov	w2, 0
	mov	x0, x3
	ldr	x3, [x3, 144]
	blr	x3
	ldr	x2, [x19, 8]
	mov	w1, 1
	mov	x0, x2
	ldr	x2, [x2, 128]
	blr	x2
	ldr	w1, [x19, 72]
	mov	w0, 1
	sub	w0, w0, w1
	str	w0, [x19, 72]
	ldp	x19, x20, [sp, 16]
	ldr	x21, [sp, 32]
	ldp	x29, x30, [sp], 48
	ret
	.p2align 3
.L1053:
	adrp	x3, dummy_dma_ops
	add	x3, x3, :lo12:dummy_dma_ops
	b	.L1051
	.size	flip.isra.4, .-flip.isra.4
	.align	2
	.p2align 3,,7
	.type	direct_mode_data_change_part2.isra.8, %function
direct_mode_data_change_part2.isra.8:
	stp	x29, x30, [sp, -80]!
	adrp	x7, .LANCHOR0
	and	w3, w3, 255
	cmp	w6, 2
	sub	w3, w3, w4
	add	x29, sp, 0
	ldr	x4, [x7, #:lo12:.LANCHOR0]
	stp	x19, x20, [sp, 16]
	lsl	w3, w3, 10
	stp	x21, x22, [sp, 32]
	add	x19, x5, x3, sxtw
	stp	x23, x24, [sp, 48]
	mov	x22, x0
	stp	x25, x26, [sp, 64]
	mov	x24, x1
	mov	x25, x2
	ldp	w9, w23, [x4, 116]
	lsr	w20, w9, 3
	beq	.L1123
	cmp	w6, 3
	beq	.L1061
	lsr	w26, w9, 2
	mov	x0, 0
	mov	w21, 0
.L1060:
	sub	w2, w23, w21
	add	x0, x22, x0
	mov	w1, 0
	mul	w2, w2, w26
	sxtw	x2, w2
	bl	memset
	cmp	w21, w23
	bge	.L1058
	sub	w7, w20, #1
	mul	w8, w21, w26
	add	x7, x7, 1
	lsl	w9, w26, 1
	lsl	x7, x7, 3
	mov	w6, 3
	mov	w5, 12
	.p2align 2
.L1084:
	add	x4, x22, x8, sxtw
	cbz	w20, .L1063
	mov	x11, 0
	.p2align 2
.L1073:
	ldr	x0, [x25, x11, lsl 3]
	ldr	x2, [x24, x11, lsl 3]
	lsr	x3, x0, 14
	lsr	x17, x0, 30
	ubfx	x12, x2, 19, 5
	ubfx	x1, x2, 35, 5
	lsr	x15, x0, 22
	lsr	x14, x0, 46
	and	x3, x3, 992
	and	x17, x17, 992
	lsr	w13, w2, 27
	orr	x3, x3, x12
	and	x15, x15, 992
	lsr	x12, x0, 38
	orr	x17, x17, x1
	and	x14, x14, 992
	ubfx	x1, x2, 51, 5
	lsr	x16, x0, 6
	and	x12, x12, 992
	orr	x15, x15, x13
	orr	x14, x14, x1
	ubfx	x13, x2, 43, 5
	lsl	x1, x0, 2
	eor	x10, x2, x0
	cmp	x2, x0
	ubfx	x30, x2, 11, 5
	and	x1, x1, 992
	and	x16, x16, 992
	orr	x13, x12, x13
	lsr	x0, x0, 54
	ubfx	x12, x2, 3, 5
	and	x18, x10, 255
	orr	x12, x1, x12
	orr	x16, x16, x30
	and	x1, x0, 992
	add	x2, x19, x2, lsr 59
	beq	.L1064
	cmp	x18, 0
	ldrb	w18, [x19, x3]
	csel	w0, w6, wzr, ne
	tst	x10, 65280
	orr	w3, w0, 48
	ldrb	w17, [x19, x17]
	csel	w0, w3, w0, ne
	tst	x10, 16711680
	orr	w30, w0, 768
	ldrb	w3, [x19, x16]
	csel	w0, w30, w0, ne
	tst	x10, 4278190080
	orr	w30, w0, 12288
	ldrb	w16, [x19, x15]
	csel	w0, w30, w0, ne
	tst	x10, 1095216660480
	orr	w15, w0, 196608
	ldrb	w14, [x19, x14]
	csel	w0, w15, w0, ne
	ldrb	w13, [x19, x13]
	tst	x10, 280375465082880
	orr	w15, w0, 3145728
	csel	w0, w15, w0, ne
	ldrb	w2, [x2, x1]
	ldrb	w15, [x19, x12]
	lsl	w1, w18, 8
	lsl	w12, w17, 16
	tst	x10, 71776119061217280
	orr	w1, w1, w3, lsl 4
	orr	w17, w0, 50331648
	orr	w12, w12, w16, lsl 12
	lsl	w3, w14, 24
	csel	w0, w17, w0, ne
	orr	w1, w1, w12
	orr	w3, w3, w13, lsl 20
	tst	x10, -72057594037927936
	orr	w1, w1, w3
	orr	w10, w0, 805306368
	orr	w2, w15, w2, lsl 28
	csel	w0, w10, w0, ne
	orr	w1, w1, w2
	and	w0, w1, w0
	str	w0, [x4, x11, lsl 2]
.L1064:
	add	x11, x11, 1
	cmp	w20, w11
	bgt	.L1073
	add	x24, x24, x7
	add	x25, x25, x7
	mov	x11, 0
	.p2align 2
.L1083:
	ldr	x0, [x25, x11, lsl 3]
	ldr	x2, [x24, x11, lsl 3]
	lsr	x17, x0, 22
	lsr	x16, x0, 6
	lsr	w3, w2, 27
	lsr	x13, x0, 38
	and	x17, x17, 992
	ubfx	x1, x2, 11, 5
	lsr	x15, x0, 14
	lsl	x14, x0, 2
	and	x16, x16, 992
	orr	x17, x17, x3
	and	x13, x13, 992
	ubfx	x3, x2, 43, 5
	ubfx	x30, x2, 19, 5
	ubfx	x12, x2, 3, 5
	and	x15, x15, 992
	and	x14, x14, 992
	orr	x16, x16, x1
	orr	x13, x13, x3
	lsr	x1, x0, 30
	lsr	x3, x0, 46
	eor	x10, x2, x0
	cmp	x2, x0
	and	x1, x1, 992
	orr	x15, x15, x30
	orr	x14, x14, x12
	ubfx	x30, x2, 35, 5
	ubfx	x12, x2, 51, 5
	lsr	x0, x0, 54
	and	x3, x3, 992
	orr	x30, x1, x30
	and	x18, x10, 255
	and	x1, x0, 992
	add	x2, x19, x2, lsr 59
	orr	x12, x3, x12
	beq	.L1074
	cmp	x18, 0
	ldrb	w17, [x19, x17]
	csel	w0, w5, wzr, ne
	tst	x10, 65280
	orr	w3, w0, 192
	ldrb	w16, [x19, x16]
	csel	w0, w3, w0, ne
	tst	x10, 16711680
	orr	w18, w0, 3072
	ldrb	w3, [x19, x15]
	csel	w0, w18, w0, ne
	tst	x10, 4278190080
	orr	w15, w0, 49152
	ldrb	w18, [x19, x14]
	csel	w0, w15, w0, ne
	tst	x10, 1095216660480
	orr	w14, w0, 786432
	ldrb	w15, [x19, x13]
	csel	w0, w14, w0, ne
	ldrb	w13, [x2, x1]
	tst	x10, 280375465082880
	ldrb	w14, [x19, x30]
	orr	w1, w0, 12582912
	ldrb	w2, [x19, x12]
	csel	w0, w1, w0, ne
	lsl	w16, w16, 6
	lsl	w1, w17, 14
	tst	x10, 71776119061217280
	orr	w1, w1, w3, lsl 10
	orr	w17, w0, 201326592
	orr	w3, w16, w18, lsl 2
	lsl	w12, w15, 22
	csel	w0, w17, w0, ne
	orr	w1, w1, w3
	orr	w12, w12, w14, lsl 18
	lsl	w3, w13, 30
	tst	x10, -72057594037927936
	orr	w3, w3, w2, lsl 26
	orr	w10, w0, -1073741824
	orr	w1, w1, w12
	ldr	w2, [x4, x11, lsl 2]
	csel	w0, w10, w0, ne
	orr	w1, w1, w3
	and	w0, w1, w0
	orr	w0, w2, w0
	str	w0, [x4, x11, lsl 2]
.L1074:
	add	x11, x11, 1
	cmp	w20, w11
	bgt	.L1083
	add	x24, x24, x7
	add	x25, x25, x7
.L1063:
	add	w21, w21, 2
	add	w8, w8, w9
	cmp	w23, w21
	bgt	.L1084
.L1058:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x29, x30, [sp], 80
	ret
.L1123:
	add	w23, w23, w23, lsr 31
	lsr	w26, w9, 2
	asr	w23, w23, 1
	mov	x0, 0
	mov	w21, 0
	b	.L1060
.L1061:
	add	w21, w23, w23, lsr 31
	lsr	w26, w9, 2
	asr	w21, w21, 1
	mul	w1, w20, w21
	mul	w0, w21, w26
	sbfiz	x1, x1, 3, 32
	sxtw	x0, w0
	add	x24, x24, x1
	add	x25, x2, x1
	b	.L1060
	.size	direct_mode_data_change_part2.isra.8, .-direct_mode_data_change_part2.isra.8
	.align	2
	.p2align 3,,7
	.type	direct_mode_data_change_part.isra.9, %function
direct_mode_data_change_part.isra.9:
	stp	x29, x30, [sp, -96]!
	adrp	x7, .LANCHOR0
	and	w3, w3, 255
	cmp	w6, 2
	sub	w4, w3, w4
	add	x29, sp, 0
	ldr	x3, [x7, #:lo12:.LANCHOR0]
	stp	x23, x24, [sp, 48]
	lsl	w4, w4, 10
	add	x23, x3, 40
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	mov	x20, x1
	str	x27, [sp, 80]
	mov	x27, x0
	stp	x25, x26, [sp, 64]
	mov	x21, x2
	add	x19, x5, x4, sxtw
	ldp	w10, w0, [x23, 76]
	lsr	w22, w10, 3
	beq	.L1162
	mov	w25, w0
	cmp	w6, 3
	mov	w24, 0
	beq	.L1163
.L1126:
	ldr	w1, [x23, 156]
	lsr	w26, w10, 2
	cbz	w1, .L1127
	sub	w2, w25, w24
	sub	w0, w0, w25
	mov	w1, 0
	mul	w2, w2, w26
	mul	w0, w0, w26
	sxtw	x2, w2
	add	x0, x27, x0
	bl	memset
	ldr	w0, [x23, 80]
	sub	w0, w0, #1
	sub	w0, w0, w24
	mul	w0, w0, w26
	neg	w26, w26
	add	x27, x27, x0
.L1130:
	cmp	w25, w24
	ble	.L1124
	sub	w9, w22, #1
	sxtw	x10, w26
	add	x9, x9, 1
	mov	w8, 3
	lsl	x9, x9, 3
	.p2align 2
.L1129:
	mov	x5, 0
	cbz	w22, .L1142
	.p2align 2
.L1159:
	ldr	x0, [x21, x5, lsl 3]
	ldr	x2, [x20, x5, lsl 3]
	lsr	x15, x0, 30
	lsr	x14, x0, 14
	lsr	x1, x0, 46
	ubfx	x6, x2, 35, 5
	ubfx	x3, x2, 19, 5
	lsr	x13, x0, 22
	lsr	x12, x0, 6
	and	x1, x1, 992
	ubfx	x11, x2, 51, 5
	and	x15, x15, 992
	and	x14, x14, 992
	lsr	w7, w2, 27
	and	x13, x13, 992
	orr	x15, x15, x6
	and	x12, x12, 992
	ubfx	x6, x2, 11, 5
	orr	x14, x14, x3
	orr	x11, x1, x11
	lsr	x3, x0, 38
	lsl	x1, x0, 2
	eor	x4, x2, x0
	cmp	x2, x0
	and	x1, x1, 992
	orr	x13, x13, x7
	orr	x12, x12, x6
	ubfx	x7, x2, 43, 5
	ubfx	x6, x2, 3, 5
	and	x3, x3, 992
	lsr	x0, x0, 54
	orr	x6, x1, x6
	and	x16, x4, 255
	orr	x7, x3, x7
	and	x1, x0, 992
	add	x2, x19, x2, lsr 59
	beq	.L1131
	cmp	x16, 0
	ldrb	w14, [x19, x14]
	csel	w0, w8, wzr, ne
	tst	x4, 65280
	orr	w3, w0, 12
	ldrb	w15, [x19, x15]
	csel	w0, w3, w0, ne
	tst	x4, 16711680
	orr	w16, w0, 48
	ldrb	w3, [x19, x13]
	csel	w0, w16, w0, ne
	tst	x4, 4278190080
	orr	w13, w0, 192
	ldrb	w12, [x19, x12]
	and	w13, w13, 65535
	ldrb	w11, [x19, x11]
	csel	w0, w13, w0, ne
	tst	x4, 1095216660480
	orr	w16, w0, 768
	ldrb	w13, [x19, x6]
	and	w16, w16, 65535
	ldrb	w7, [x19, x7]
	csel	w0, w16, w0, ne
	tst	x4, 280375465082880
	orr	w6, w0, 3072
	ldrb	w2, [x2, x1]
	and	w6, w6, 65535
	lsl	w1, w15, 8
	csel	w0, w6, w0, ne
	lsl	w6, w14, 4
	orr	w14, w0, 12288
	tst	x4, 71776119061217280
	and	w14, w14, 65535
	orr	w1, w1, w3, lsl 6
	csel	w0, w14, w0, ne
	orr	w12, w6, w12, lsl 2
	lsl	w6, w11, 12
	orr	w3, w0, -16384
	orr	w1, w1, w12
	orr	w6, w6, w7, lsl 10
	tst	x4, -72057594037927936
	and	w3, w3, 65535
	orr	w1, w1, w6
	orr	w2, w13, w2, lsl 14
	csel	w0, w3, w0, ne
	orr	w1, w1, w2
	and	w0, w0, w1
	strh	w0, [x27, x5, lsl 1]
.L1131:
	add	x5, x5, 1
	cmp	w22, w5
	bgt	.L1159
	add	x20, x20, x9
	add	x21, x21, x9
.L1142:
	add	w24, w24, 1
	add	x27, x27, x10
	cmp	w25, w24
	bne	.L1129
.L1124:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldr	x27, [sp, 80]
	ldp	x29, x30, [sp], 96
	ret
.L1127:
	sub	w2, w25, w24
	mul	w23, w26, w24
	mov	w1, 0
	mul	w2, w2, w26
	add	x27, x27, x23, sxtw
	mov	x0, x27
	sxtw	x2, w2
	bl	memset
	b	.L1130
.L1162:
	add	w25, w0, w0, lsr 31
	mov	w24, 0
	asr	w25, w25, 1
	b	.L1126
.L1163:
	add	w24, w0, w0, lsr 31
	asr	w24, w24, 1
	mul	w1, w22, w24
	sbfiz	x1, x1, 3, 32
	add	x20, x20, x1
	add	x21, x2, x1
	b	.L1126
	.size	direct_mode_data_change_part.isra.9, .-direct_mode_data_change_part.isra.9
	.align	2
	.p2align 3,,7
	.type	ebc_frame_start, %function
ebc_frame_start:
	stp	x29, x30, [sp, -48]!
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	add	x19, x0, 216
	str	x21, [sp, 32]
	mov	x20, x0
	add	x21, x0, 40
	ldr	w6, [x19, 240]
	cmp	w6, 3
	beq	.L1166
	cmp	w6, 4
	beq	.L1167
	cmp	w6, 1
	beq	.L1197
	ldr	x0, [x19, 216]
	ldr	w1, [x0, 40]
	cmp	w1, 21
	beq	.L1198
	ldrb	w4, [x19, 56]
	str	w4, [x19, 72]
	ldr	x2, [x19, 208]
	ldr	w1, [x21, 164]
	ldr	x5, [x20, 336]
	cbz	w1, .L1190
	ldr	x1, [x0, 16]
	mov	w6, 1
	ldr	x2, [x2, 16]
	mov	w3, w4
	ldr	x0, [x19, 176]
	bl	direct_mode_data_change2.isra.3
.L1191:
	ldr	w4, [x19, 72]
	ldp	x2, x1, [x19, 208]
	sub	w4, w4, #1
	str	w4, [x19, 72]
	ldr	w0, [x21, 164]
	ldrb	w3, [x20, 272]
	ldr	x5, [x20, 336]
	cbz	w0, .L1192
	ldr	x1, [x1, 16]
	mov	w6, 1
	ldr	x2, [x2, 16]
	ldr	x0, [x19, 184]
	bl	direct_mode_data_change2.isra.3
.L1193:
	str	wzr, [x21, 72]
	mov	x0, x21
	ldr	w1, [x20, 248]
	bl	flip.isra.4
.L1164:
	ldp	x19, x20, [sp, 16]
	ldr	x21, [sp, 32]
	ldp	x29, x30, [sp], 48
	ret
	.p2align 3
.L1197:
	ldrb	w4, [x19, 56]
	str	w4, [x19, 72]
	ldr	x1, [x19, 208]
	ldr	w0, [x21, 164]
	cbnz	w0, .L1199
	ldr	x0, [x19, 216]
	mov	w3, w4
	ldr	x2, [x1, 16]
	ldr	x5, [x20, 336]
	ldr	x1, [x0, 16]
	ldr	x0, [x19, 176]
	bl	direct_mode_data_change_part.isra.9
.L1183:
	str	wzr, [x21, 72]
	mov	x0, x21
	ldr	w1, [x20, 248]
	bl	flip.isra.4
	ldr	w4, [x19, 72]
	ldp	x2, x1, [x19, 208]
	sub	w4, w4, #1
	str	w4, [x19, 72]
	ldr	w0, [x21, 164]
	ldrb	w3, [x20, 272]
	ldr	x5, [x20, 336]
	cbz	w0, .L1184
	ldr	x0, [x19, 184]
	mov	w6, 1
	ldr	x1, [x1, 16]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change_part2.isra.8
	ldr	x21, [sp, 32]
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 48
	ret
	.p2align 3
.L1167:
	ldrsw	x2, [x19, 32]
	mov	w1, 0
	ldr	x0, [x19, 176]
	bl	memset
	ldr	w0, [x21, 164]
	cbnz	w0, .L1200
	ldp	x1, x2, [x19, 136]
	mov	x5, x19
	ldp	x3, x4, [x19, 160]
	ldr	x0, [x19, 176]
	bl	get_overlay_image_area
.L1170:
	ldr	w0, [x19, 60]
	cbnz	w0, .L1201
	ldr	w0, [x19, 624]
	cmp	w0, 0
	ble	.L1175
	ldr	x0, [x19, 96]
	adrp	x2, .LANCHOR3
	add	x2, x2, :lo12:.LANCHOR3
	adrp	x1, .LC45
	add	x2, x2, 24
	add	x1, x1, :lo12:.LC45
	bl	_dev_info
.L1175:
	str	wzr, [x19, 52]
.L1204:
	ldp	x19, x20, [sp, 16]
	ldr	x21, [sp, 32]
	ldp	x29, x30, [sp], 48
	ret
	.p2align 3
.L1166:
	ldr	w0, [x21, 164]
	ldp	x1, x2, [x19, 136]
	ldr	x3, [x19, 160]
	cbnz	w0, .L1202
	ldr	x0, [x19, 176]
	mov	w5, 1
	mov	x4, x19
	bl	get_auto_image
	ldr	w0, [x19, 60]
	cbz	w0, .L1178
.L1203:
	ldr	w0, [x21, 164]
	ldp	x1, x2, [x19, 136]
	ldr	x3, [x19, 160]
	cbz	w0, .L1179
	ldr	x0, [x19, 184]
	mov	w5, 1
	mov	x4, x19
	bl	get_auto_image2
	b	.L1193
	.p2align 3
.L1202:
	ldr	x0, [x19, 176]
	mov	w5, 1
	mov	x4, x19
	bl	get_auto_image2
	ldr	w0, [x19, 60]
	cbnz	w0, .L1203
.L1178:
	ldr	w0, [x19, 624]
	cmp	w0, 0
	ble	.L1175
	ldr	x0, [x19, 96]
	adrp	x2, .LANCHOR3
	add	x2, x2, :lo12:.LANCHOR3
	adrp	x1, .LC46
	add	x2, x2, 24
	add	x1, x1, :lo12:.LC46
	bl	_dev_info
	str	wzr, [x19, 52]
	b	.L1204
	.p2align 3
.L1200:
	ldp	x1, x2, [x19, 136]
	mov	x4, x19
	ldr	x3, [x19, 160]
	ldr	x0, [x19, 176]
	bl	get_overlay_image_area2.isra.0
	b	.L1170
	.p2align 3
.L1199:
	ldr	x0, [x19, 216]
	mov	w3, w4
	ldr	x2, [x1, 16]
	ldr	x5, [x20, 336]
	ldr	x1, [x0, 16]
	ldr	x0, [x19, 176]
	bl	direct_mode_data_change_part2.isra.8
	b	.L1183
	.p2align 3
.L1198:
	ldr	w1, [x19, 672]
	str	w1, [x19, 676]
	str	wzr, [x19, 680]
	ldr	x2, [x19, 208]
	ldr	w1, [x21, 164]
	cbnz	w1, .L1205
	ldr	x1, [x0, 16]
	mov	w4, 1
	ldr	x2, [x2, 16]
	mov	x3, x19
	ldr	x0, [x19, 176]
	bl	direct_mode_data_change_full
.L1187:
	ldr	w1, [x19, 672]
	ldr	w0, [x19, 676]
	add	w0, w0, w1
	str	w0, [x19, 676]
	ldp	x2, x1, [x19, 208]
	ldr	w0, [x21, 164]
	cbz	w0, .L1188
	ldr	x1, [x1, 16]
	mov	w4, 1
	ldr	x2, [x2, 16]
	mov	x3, x19
	ldr	x0, [x19, 184]
	bl	direct_mode_data_change_full2
	b	.L1193
	.p2align 3
.L1184:
	ldr	x0, [x19, 184]
	mov	w6, 1
	ldr	x1, [x1, 16]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change_part.isra.9
	ldr	x21, [sp, 32]
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 48
	ret
	.p2align 3
.L1192:
	ldr	x1, [x1, 16]
	mov	w6, 1
	ldr	x2, [x2, 16]
	ldr	x0, [x19, 184]
	bl	direct_mode_data_change.isra.2
	b	.L1193
	.p2align 3
.L1190:
	ldr	x1, [x0, 16]
	mov	w6, 1
	ldr	x2, [x2, 16]
	mov	w3, w4
	ldr	x0, [x19, 176]
	bl	direct_mode_data_change.isra.2
	b	.L1191
	.p2align 3
.L1201:
	str	wzr, [x21, 72]
	mov	x0, x21
	ldr	w1, [x20, 248]
	bl	flip.isra.4
	ldrsw	x2, [x19, 32]
	mov	w1, 0
	ldr	x0, [x19, 184]
	bl	memset
	ldr	w0, [x21, 164]
	cbz	w0, .L1172
	ldp	x1, x2, [x19, 136]
	mov	x4, x19
	ldr	x3, [x19, 160]
	ldr	x0, [x19, 184]
	bl	get_overlay_image_area2.isra.0
	b	.L1164
	.p2align 3
.L1179:
	ldr	x0, [x19, 184]
	mov	w5, 1
	mov	x4, x19
	bl	get_auto_image
	b	.L1193
	.p2align 3
.L1172:
	ldp	x1, x2, [x19, 136]
	mov	x5, x19
	ldp	x3, x4, [x19, 160]
	ldr	x0, [x19, 184]
	bl	get_overlay_image_area
	b	.L1164
	.p2align 3
.L1205:
	ldr	x1, [x0, 16]
	mov	w4, 1
	ldr	x2, [x2, 16]
	mov	x3, x19
	ldr	x0, [x19, 176]
	bl	direct_mode_data_change_full2
	b	.L1187
	.p2align 3
.L1188:
	ldr	x1, [x1, 16]
	mov	w4, 1
	ldr	x2, [x2, 16]
	mov	x3, x19
	ldr	x0, [x19, 184]
	bl	direct_mode_data_change_full
	b	.L1193
	.size	ebc_frame_start, .-ebc_frame_start
	.align	2
	.p2align 3,,7
	.type	ebc_auto_assist_tast_function, %function
ebc_auto_assist_tast_function:
	stp	x29, x30, [sp, -96]!
	adrp	x1, .LANCHOR0
	adrp	x0, __stack_chk_guard
	add	x0, x0, :lo12:__stack_chk_guard
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	adrp	x22, .LANCHOR1
	stp	x23, x24, [sp, 48]
	add	x22, x22, :lo12:.LANCHOR1
	str	x25, [sp, 64]
	add	x20, x22, 328
	ldr	x25, [x1, #:lo12:.LANCHOR0]
	add	x22, x22, 352
	mov	x24, 2
	ldr	x1, [x0]
	str	x1, [x29, 88]
	mov	x1,0
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x23, sp_el0
// 0 "" 2
#NO_APP
	add	x19, x25, 216
	add	x21, x25, 40
	b	.L1218
	.p2align 3
.L1231:
	cmp	w5, 4
	beq	.L1209
	cmp	w5, 1
	beq	.L1229
	ldr	x0, [x19, 216]
	ldr	w1, [x0, 40]
	cmp	w1, 21
	beq	.L1230
	ldr	w4, [x19, 72]
	cbz	w4, .L1212
	ldr	w1, [x21, 164]
	ldrsw	x7, [x21, 72]
	ldrb	w3, [x25, 272]
	add	x7, x7, 22
	ldr	x2, [x19, 208]
	ldr	x5, [x25, 336]
	cbz	w1, .L1217
	ldr	x1, [x0, 16]
	mov	w6, 3
	ldr	x0, [x19, x7, lsl 3]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change2.isra.3
	.p2align 2
.L1212:
	mov	x0, x22
	bl	up
	mov	x0, x20
	bl	up
	bl	schedule
.L1218:
	mov	x0, x20
	bl	down
	str	x24, [x23, 32]
#APP
// 2000 "/home/lyx/rk3566-11-eink/kernel/drivers/gpu/drm/rockchip/ebc-dev/ebc_dev_y8.c" 1
	dmb ish
// 0 "" 2
#NO_APP
	ldr	w5, [x19, 240]
	cmp	w5, 3
	bne	.L1231
	ldr	w0, [x21, 164]
	cbz	w0, .L1213
	ldrsw	x0, [x21, 72]
	mov	x4, x19
	ldp	x1, x2, [x19, 136]
	add	x0, x0, 22
	ldr	x3, [x19, 160]
	ldr	x0, [x19, x0, lsl 3]
	bl	get_auto_image2
	b	.L1212
	.p2align 3
.L1229:
	ldr	w4, [x19, 72]
	cbz	w4, .L1212
	ldr	w0, [x21, 164]
	cbz	w0, .L1214
	ldrsw	x0, [x21, 72]
	mov	w6, 3
	ldp	x2, x1, [x19, 208]
	add	x0, x0, 22
	ldrb	w3, [x25, 272]
	ldr	x5, [x25, 336]
	ldr	x0, [x19, x0, lsl 3]
	ldr	x1, [x1, 16]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change_part2.isra.8
	b	.L1212
	.p2align 3
.L1209:
	ldr	w0, [x21, 164]
	cbz	w0, .L1211
	ldrsw	x0, [x21, 72]
	mov	w6, 3
	ldp	x1, x2, [x19, 136]
	add	x0, x0, 22
	ldp	x3, x4, [x19, 160]
	mov	x5, x19
	ldr	x0, [x19, x0, lsl 3]
	bl	get_overlay_image2
	b	.L1212
	.p2align 3
.L1213:
	ldrsw	x0, [x21, 72]
	mov	x4, x19
	ldp	x1, x2, [x19, 136]
	add	x0, x0, 22
	ldr	x3, [x19, 160]
	ldr	x0, [x19, x0, lsl 3]
	bl	get_auto_image
	b	.L1212
	.p2align 3
.L1211:
	ldrsw	x0, [x21, 72]
	mov	w6, 3
	ldp	x1, x2, [x19, 136]
	add	x0, x0, 22
	ldp	x3, x4, [x19, 160]
	mov	x5, x19
	ldr	x0, [x19, x0, lsl 3]
	bl	get_overlay_image
	b	.L1212
	.p2align 3
.L1230:
	ldrb	w1, [x19, 56]
	ldr	w3, [x19, 84]
	ldr	w4, [x19, 672]
	ldr	w2, [x19, 676]
	madd	w1, w1, w4, w3
	cmp	w2, w1
	bge	.L1212
	ldr	w1, [x21, 164]
	ldrsw	x2, [x21, 72]
	ldr	x5, [x19, 208]
	cbz	w1, .L1216
	ldr	x1, [x0, 16]
	add	x0, x2, 22
	ldr	x2, [x5, 16]
	mov	w4, 3
	mov	x3, x19
	ldr	x0, [x19, x0, lsl 3]
	bl	direct_mode_data_change_full2
	b	.L1212
	.p2align 3
.L1214:
	ldrsw	x0, [x21, 72]
	mov	w6, 3
	ldp	x2, x1, [x19, 208]
	add	x0, x0, 22
	ldrb	w3, [x25, 272]
	ldr	x5, [x25, 336]
	ldr	x0, [x19, x0, lsl 3]
	ldr	x1, [x1, 16]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change_part.isra.9
	b	.L1212
	.p2align 3
.L1217:
	ldr	x1, [x0, 16]
	mov	w6, 3
	ldr	x0, [x19, x7, lsl 3]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change.isra.2
	b	.L1212
	.p2align 3
.L1216:
	ldr	x1, [x0, 16]
	add	x0, x2, 22
	ldr	x2, [x5, 16]
	mov	w4, 3
	mov	x3, x19
	ldr	x0, [x19, x0, lsl 3]
	bl	direct_mode_data_change_full
	b	.L1212
	.size	ebc_auto_assist_tast_function, .-ebc_auto_assist_tast_function
	.align	2
	.p2align 3,,7
	.type	ebc_probe, %function
ebc_probe:
	stp	x29, x30, [sp, -160]!
	add	x29, sp, 0
	stp	x21, x22, [sp, 32]
	add	x22, x0, 16
	stp	x25, x26, [sp, 64]
	adrp	x25, __stack_chk_guard
	stp	x19, x20, [sp, 16]
	add	x0, x25, :lo12:__stack_chk_guard
	stp	x23, x24, [sp, 48]
	stp	x27, x28, [sp, 80]
	str	xzr, [x29, 144]
	ldr	x1, [x0]
	str	x1, [x29, 152]
	mov	x1,0
	mov	x0, x22
	adrp	x1, .LC47
	add	x1, x1, :lo12:.LC47
	bl	nvmem_cell_get
	cmn	x0, #4096
	bhi	.L1239
	add	x1, x29, 144
	mov	x20, x0
	bl	nvmem_cell_read
	mov	x19, x0
	mov	x0, x20
	mov	w20, w19
	bl	nvmem_cell_put
	cmn	x19, #4096
	bhi	.L1232
	ldr	x0, [x29, 144]
	cmp	x0, 2
	bne	.L1348
	ldrb	w0, [x19]
	cmp	w0, 53
	bne	.L1348
	ldrb	w0, [x19, 1]
	cmp	w0, 102
	beq	.L1306
	mov	w1, 3576
	str	w1, [x29, 108]
	cmp	w0, 118
	bne	.L1348
.L1238:
	mov	x0, x19
	bl	kfree
	mov	w2, 32960
	mov	x1, 912
	movk	w2, 0x60, lsl 16
	mov	x0, x22
	bl	devm_kmalloc
	mov	x19, x0
	cbz	x0, .L1239
	adrp	x27, .LANCHOR0
	str	x22, [x19]
	adrp	x1, .LC48
	mov	w2, 0
	str	x0, [x27, #:lo12:.LANCHOR0]
	add	x1, x1, :lo12:.LC48
	ldr	x0, [x22, 752]
	bl	of_parse_phandle
	cbz	x0, .L1349
	bl	of_find_device_by_node
	cbz	x0, .L1242
	ldr	x0, [x0, 200]
	str	x0, [x19, 8]
	cbz	x0, .L1242
	adrp	x1, frame_done_callback
	add	x1, x1, :lo12:frame_done_callback
	str	x1, [x0, 136]
	add	x2, x29, 120
	adrp	x1, .LC50
	add	x1, x1, :lo12:.LC50
	ldr	x0, [x22, 752]
	bl	of_get_property
	mov	x21, x0
	ldrsw	x0, [x29, 120]
	lsr	x0, x0, 2
	str	w0, [x29, 120]
	cmp	w0, 0
	beq	.L1243
	mov	w20, 0
	mov	w26, 0
	ble	.L1253
	adrp	x23, .LC56
	adrp	x24, .LC58
	add	x23, x23, :lo12:.LC56
	add	x24, x24, :lo12:.LC58
	b	.L1333
	.p2align 3
.L1355:
	adrp	x1, .LC59
	mov	x0, x22
	add	x1, x1, :lo12:.LC59
	bl	_dev_warn
.L1250:
	ldr	w0, [x29, 120]
	add	w20, w20, 1
	cmp	w0, w20
	ble	.L1350
.L1333:
	ldr	w0, [x21], 4
	rev	w0, w0
	bl	of_find_node_by_phandle
	cbz	x0, .L1351
	bl	of_find_i2c_device_by_node
	cbz	x0, .L1352
	add	x28, x0, 32
	ldr	x0, [x28, 184]
	str	x0, [x19, 16]
	cbnz	x0, .L1353
	mov	x1, x23
	mov	x0, x28
	bl	devm_regulator_get
	str	x0, [x19, 24]
	cmn	x0, #4096
	bhi	.L1354
	add	x2, x29, 136
	mov	x1, x24
	mov	x0, x28
	bl	device_property_read_string
	cbnz	w0, .L1355
	ldr	x0, [x29, 136]
	bl	thermal_zone_get_zone_by_name
	str	x0, [x19, 32]
	cmn	x0, #4096
	bhi	.L1356
	ldr	w0, [x29, 120]
	add	w20, w20, 1
	mov	w26, 1
	cmp	w0, w20
	bgt	.L1333
.L1350:
	cbnz	w26, .L1248
.L1253:
	adrp	x1, .LC51
	mov	x0, x22
	add	x1, x1, :lo12:.LC51
	mov	w20, -517
	bl	_dev_err
	.p2align 2
.L1232:
	add	x25, x25, :lo12:__stack_chk_guard
	mov	w0, w20
	ldr	x2, [x29, 152]
	ldr	x1, [x25]
	eor	x1, x2, x1
	cbnz	x1, .L1357
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	ldp	x29, x30, [sp], 160
	ret
	.p2align 3
.L1354:
	adrp	x1, .LC57
	mov	x0, x22
	add	x1, x1, :lo12:.LC57
	bl	_dev_warn
	b	.L1250
	.p2align 3
.L1356:
	adrp	x1, .LC60
	mov	x0, x22
	add	x1, x1, :lo12:.LC60
	bl	_dev_err
	b	.L1250
	.p2align 3
.L1351:
	adrp	x1, .LC53
	mov	x0, x22
	add	x1, x1, :lo12:.LC53
	mov	w20, -19
	bl	_dev_err
	b	.L1232
	.p2align 3
.L1352:
	adrp	x1, .LC54
	mov	x0, x22
	add	x1, x1, :lo12:.LC54
	mov	w20, -19
	bl	_dev_err
	b	.L1232
	.p2align 3
.L1353:
	adrp	x1, .LC55
	mov	w2, w20
	add	x1, x1, :lo12:.LC55
	mov	x0, x22
	bl	_dev_info
.L1248:
	add	x21, x19, 216
	ldr	w0, [x29, 108]
	str	x22, [x21, 96]
	add	x23, x19, 40
	adrp	x1, .LC61
	add	x1, x1, :lo12:.LC61
	str	w0, [x21, 688]
	str	x22, [x19, 40]
	ldr	x0, [x19, 8]
	str	x0, [x23, 8]
	mov	x0, x22
	ldr	x2, [x19, 16]
	str	x2, [x23, 16]
	bl	device_property_present
	tst	w0, 255
	beq	.L1254
	mov	w0, 1
	str	w0, [x21, 620]
.L1254:
	ldr	x20, [x19, 40]
	adrp	x1, .LC62
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC62
	add	x2, x19, 116
	ldr	x0, [x20, 752]
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1256
	ldr	x0, [x20, 752]
	adrp	x1, .LC91
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC91
	add	x2, x19, 120
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1256
	ldr	x0, [x20, 752]
	adrp	x1, .LC92
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC92
	add	x2, x19, 124
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1256
	ldr	x0, [x20, 752]
	adrp	x1, .LC93
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC93
	add	x2, x19, 128
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1256
	ldr	x0, [x20, 752]
	adrp	x1, .LC94
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC94
	add	x2, x19, 144
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1256
	ldr	x0, [x20, 752]
	adrp	x1, .LC95
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC95
	add	x2, x19, 148
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1256
	ldr	x0, [x20, 752]
	adrp	x1, .LC96
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC96
	add	x2, x19, 152
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1256
	ldr	x0, [x20, 752]
	adrp	x1, .LC97
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC97
	add	x2, x19, 156
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1256
	ldr	x0, [x20, 752]
	adrp	x1, .LC98
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC98
	add	x2, x19, 160
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1256
	ldr	x0, [x20, 752]
	adrp	x1, .LC99
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC99
	add	x2, x19, 164
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1256
	ldr	x0, [x20, 752]
	adrp	x1, .LC100
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC100
	add	x2, x19, 168
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1256
	ldr	x0, [x20, 752]
	adrp	x1, .LC101
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC101
	add	x2, x19, 172
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1256
	ldr	x0, [x20, 752]
	adrp	x1, .LC102
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC102
	add	x2, x19, 176
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1256
	ldr	x0, [x20, 752]
	adrp	x1, .LC103
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC103
	add	x2, x19, 180
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1256
	ldr	x0, [x20, 752]
	adrp	x1, .LC104
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC104
	add	x2, x19, 184
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1256
	ldr	x0, [x20, 752]
	adrp	x1, .LC105
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC105
	add	x2, x19, 188
	bl	of_property_read_variable_u32_array
	tbz	w0, #31, .L1294
	str	wzr, [x23, 148]
.L1294:
	ldr	x0, [x20, 752]
	adrp	x1, .LC63
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC63
	add	x2, x19, 192
	bl	of_property_read_variable_u32_array
	tbz	w0, #31, .L1295
	str	wzr, [x23, 152]
.L1295:
	ldr	x0, [x20, 752]
	adrp	x1, .LC64
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC64
	add	x2, x19, 196
	bl	of_property_read_variable_u32_array
	tbz	w0, #31, .L1296
	str	wzr, [x23, 156]
.L1296:
	ldr	x0, [x20, 752]
	adrp	x1, .LC65
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC65
	add	x2, x19, 132
	bl	of_property_read_variable_u32_array
	tbz	w0, #31, .L1297
	str	wzr, [x23, 92]
.L1297:
	ldr	x0, [x20, 752]
	adrp	x1, .LC66
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC66
	add	x2, x19, 136
	bl	of_property_read_variable_u32_array
	tbz	w0, #31, .L1298
	str	wzr, [x23, 96]
.L1298:
	ldr	x0, [x20, 752]
	adrp	x1, .LC67
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC67
	add	x2, x19, 200
	bl	of_property_read_variable_u32_array
	tbz	w0, #31, .L1299
	str	wzr, [x23, 160]
.L1299:
	ldr	x0, [x20, 752]
	adrp	x1, .LC68
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC68
	add	x2, x19, 204
	bl	of_property_read_variable_u32_array
	tbz	w0, #31, .L1300
	str	wzr, [x23, 164]
.L1300:
	ldr	x0, [x20, 752]
	adrp	x1, .LC69
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC69
	add	x2, x19, 208
	bl	of_property_read_variable_u32_array
	tbz	w0, #31, .L1301
	str	wzr, [x23, 168]
.L1301:
	ldr	x0, [x20, 752]
	adrp	x1, .LC70
	mov	x4, 0
	mov	x3, 1
	add	x1, x1, :lo12:.LC70
	add	x2, x19, 212
	bl	of_property_read_variable_u32_array
	tbz	w0, #31, .L1302
	str	wzr, [x23, 172]
.L1302:
	ldr	w1, [x23, 80]
	mov	w24, 1
	str	w1, [x21, 80]
	ldr	w0, [x23, 76]
	str	w0, [x21, 84]
	str	w0, [x21, 672]
	str	w24, [x21, 680]
	mul	w1, w1, w0
	mov	x0, x19
	str	w1, [x21, 28]
	lsr	w1, w1, 2
	str	w1, [x21, 32]
	bl	ebc_buffer_manage_init
	mov	w20, w0
	cbnz	w0, .L1358
	mov	x0, x21
	bl	ebc_lut_table_init
	mov	w20, w0
	cbnz	w0, .L1359
	adrp	x0, __cpu_possible_mask
	add	x26, x27, :lo12:.LANCHOR0
	ldrb	w0, [x0, #:lo12:__cpu_possible_mask]
	bl	__sw_hweight64
	str	w0, [x21, 616]
	mov	w1, 99
	adrp	x3, .LC73
	str	w1, [x29, 128]
	add	x3, x3, :lo12:.LC73
	mov	w2, -1
	adrp	x0, ebc_auto_tast_function
	mov	x1, x21
	add	x0, x0, :lo12:ebc_auto_tast_function
	bl	kthread_create_on_node
	str	x0, [x26, 8]
	cmn	x0, #4096
	bhi	.L1360
	mov	w1, w24
	add	x2, x29, 128
	bl	sched_setscheduler_nocheck
	ldr	w0, [x21, 616]
	cmp	w0, 7
	bgt	.L1361
.L1269:
	add	x24, x27, :lo12:.LANCHOR0
	mov	w0, 1
	ldr	x2, [x24, 8]
	add	x1, x2, 48
#APP
// 47 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/atomic_lse.h" 1
	.arch_extension lse
.if 1 == 1
661:
	bl	__ll_sc_atomic_add

662:
.pushsection .altinstructions,"a"
 .word 661b - .
 .word 663f - .
 .hword 5
 .byte 662b-661b
 .byte 664f-663f
.popsection
.pushsection .altinstr_replacement, "a"
663:
	.arch_extension lse
	stadd	w0, [x1]

664:
	.popsection
	.org	. - (664b-663b) + (662b-661b)
	.org	. - (662b-661b) + (664b-663b)
.endif

// 0 "" 2
#NO_APP
	adrp	x3, .LC75
	adrp	x0, ebc_auto_assist_tast_function
	add	x3, x3, :lo12:.LC75
	add	x0, x0, :lo12:ebc_auto_assist_tast_function
	mov	w2, -1
	mov	x1, x21
	bl	kthread_create_on_node
	str	x0, [x24, 16]
	cmn	x0, #4096
	bhi	.L1362
	add	x2, x29, 128
	mov	w1, 1
	bl	sched_setscheduler_nocheck
	ldr	w0, [x21, 616]
	cmp	w0, 7
	bgt	.L1363
.L1271:
	add	x26, x27, :lo12:.LANCHOR0
	mov	w0, 1
	ldr	x2, [x26, 16]
	add	x1, x2, 48
#APP
// 47 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/atomic_lse.h" 1
	.arch_extension lse
.if 1 == 1
661:
	bl	__ll_sc_atomic_add

662:
.pushsection .altinstructions,"a"
 .word 661b - .
 .word 663f - .
 .hword 5
 .byte 662b-661b
 .byte 664f-663f
.popsection
.pushsection .altinstr_replacement, "a"
663:
	.arch_extension lse
	stadd	w0, [x1]

664:
	.popsection
	.org	. - (664b-663b) + (662b-661b)
	.org	. - (662b-661b) + (664b-663b)
.endif

// 0 "" 2
#NO_APP
	mov	w0, 99
	adrp	x3, .LC77
	str	w0, [x29, 128]
	add	x3, x3, :lo12:.LC77
	mov	w2, -1
	mov	x1, x21
	adrp	x0, ebc_thread
	add	x0, x0, :lo12:ebc_thread
	bl	kthread_create_on_node
	mov	x24, x0
	cmn	x0, #4096
	bhi	.L1272
	bl	wake_up_process
	str	x24, [x26, 24]
	mov	x0, x24
	add	x2, x29, 128
	mov	w1, 1
	bl	sched_setscheduler_nocheck
	ldr	w0, [x21, 616]
	cmp	w0, 7
	bgt	.L1364
.L1273:
	add	x27, x27, :lo12:.LANCHOR0
	mov	w0, 1
	ldr	x2, [x27, 24]
	add	x1, x2, 48
#APP
// 47 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/atomic_lse.h" 1
	.arch_extension lse
.if 1 == 1
661:
	bl	__ll_sc_atomic_add

662:
.pushsection .altinstructions,"a"
 .word 661b - .
 .word 663f - .
 .hword 5
 .byte 662b-661b
 .byte 664f-663f
.popsection
.pushsection .altinstr_replacement, "a"
663:
	.arch_extension lse
	stadd	w0, [x1]

664:
	.popsection
	.org	. - (664b-663b) + (662b-661b)
	.org	. - (662b-661b) + (664b-663b)
.endif

// 0 "" 2
#NO_APP
	add	x2, x21, 512
	str	wzr, [x21, 52]
	str	wzr, [x21, 68]
	mov	w27, 1
	stp	wzr, wzr, [x21, 88]
	add	x0, x19, 464
	str	wzr, [x21, 192]
	adrp	x1, .LC78
	str	w27, [x21, 240]
	add	x1, x1, :lo12:.LC78
	str	wzr, [x21, 576]
	adrp	x26, jiffies
	str	wzr, [x21, 580]
	add	x24, x19, 680
	stp	w27, w27, [x2, 76]
	mov	x28, 268435455
	stp	wzr, wzr, [x2, 84]
	str	wzr, [x21, 608]
	str	wzr, [x21, 624]
	ldr	w2, [x19, 904]
	cmp	w2, 3576
	cset	w2, eq
	str	w2, [x21, 604]
	str	w2, [x21, 612]
	stp	xzr, xzr, [x0]
	stp	xzr, xzr, [x0, 16]
	stp	xzr, xzr, [x0, 32]
	stp	xzr, xzr, [x0, 48]
	stp	xzr, xzr, [x0, 64]
	stp	xzr, xzr, [x0, 80]
	stp	xzr, xzr, [x0, 96]
	stp	xzr, xzr, [x0, 112]
	stp	xzr, xzr, [x0, 128]
	stp	xzr, xzr, [x0, 144]
	stp	xzr, xzr, [x0, 160]
	stp	xzr, xzr, [x0, 176]
	stp	xzr, xzr, [x0, 192]
	str	x1, [x19, 464]
	bl	wakeup_source_add
	str	wzr, [x21, 456]
	mov	x4, 0
	mov	x3, 0
	mov	w2, 0
	mov	x0, x24
	adrp	x1, ebc_frame_control_timeout
	add	x1, x1, :lo12:ebc_frame_control_timeout
	bl	init_timer_key
	ldr	x1, [x26, #:lo12:jiffies]
	mov	x0, x24
	add	x24, x19, 736
	add	x1, x1, x28
	bl	mod_timer
	mov	x4, 0
	mov	x3, 0
	mov	w2, 0
	mov	x0, x24
	adrp	x1, ebc_frame_timeout
	add	x1, x1, :lo12:ebc_frame_timeout
	bl	init_timer_key
	ldr	x1, [x26, #:lo12:jiffies]
	mov	x0, x24
	add	x1, x1, x28
	bl	mod_timer
	adrp	x0, saved_command_line
	adrp	x1, .LC79
	stp	wzr, wzr, [x29, 124]
	add	x1, x1, :lo12:.LC79
	ldr	x24, [x0, #:lo12:saved_command_line]
	mov	x0, x24
	bl	strstr
	adrp	x1, .LC80
	mov	x26, x0
	add	x1, x1, :lo12:.LC80
	mov	x0, x24
	bl	strstr
	mov	x28, x0
	cbz	x26, .L1274
	add	x2, x29, 124
	mov	x0, x26
	adrp	x1, .LC81
	add	x1, x1, :lo12:.LC81
	bl	sscanf
	ldr	w2, [x29, 124]
	ldr	x0, [x19, 216]
	cmp	x0, x2, uxtw
	bls	.L1365
.L1274:
	str	wzr, [x29, 108]
	mov	x24, 0
	mov	w27, 0
	mov	x26, 0
	cbz	x28, .L1304
.L1303:
	add	x2, x29, 128
	mov	x0, x28
	adrp	x1, .LC84
	add	x1, x1, :lo12:.LC84
	bl	sscanf
	mov	w27, 0
	ldr	w2, [x29, 128]
	mov	x26, 0
	ldr	x0, [x19, 216]
	cmp	x0, x2, uxtw
	bls	.L1366
.L1278:
	ldr	w0, [x29, 108]
	cbnz	w0, .L1277
.L1304:
	ldr	x0, [x21, 96]
	adrp	x1, .LC87
	add	x1, x1, :lo12:.LC87
	bl	_dev_info
	ldr	x0, [x19, 16]
	cbz	x0, .L1280
	bl	ebc_pmic_verity_vcom
.L1281:
	adrp	x0, .LC88
	add	x0, x0, :lo12:.LC88
	bl	ebc_empty_buf_get
	mov	x28, x0
	ldp	w2, w0, [x19, 116]
	mov	w1, 240
	mul	w2, w2, w0
	ldr	x0, [x28, 16]
	bl	memset
	stp	wzr, wzr, [x28, 48]
	mov	w0, 17
	str	w0, [x28, 40]
	mov	w2, 1
	mov	x0, x28
	ldr	w1, [x19, 116]
	str	w1, [x28, 56]
	ldr	w1, [x19, 120]
	stp	w1, w2, [x28, 60]
	bl	ebc_add_to_dsp_buf_list
.L1282:
	cbnz	w27, .L1367
.L1287:
	ldr	w0, [x21, 88]
	adrp	x23, .LANCHOR1
	cbz	w0, .L1368
.L1292:
	cbz	x24, .L1293
	mov	x0, x24
	bl	kfree
.L1293:
	cbz	x26, .L1276
	mov	x0, x26
	bl	kfree
.L1276:
	str	x19, [x22, 184]
	add	x23, x23, :lo12:.LANCHOR1
	add	x0, x23, 224
	bl	misc_register
	add	x0, x23, 376
	bl	misc_register
	ldr	x0, [x19, 312]
	add	x1, x23, 456
	bl	device_create_file
	ldr	x0, [x19, 312]
	add	x1, x23, 488
	bl	device_create_file
	ldr	x0, [x19, 312]
	add	x1, x23, 520
	bl	device_create_file
	ldr	x0, [x19, 312]
	add	x1, x23, 552
	bl	device_create_file
	ldr	x0, [x19, 312]
	add	x1, x23, 584
	bl	device_create_file
	ldr	x0, [x19, 312]
	add	x1, x23, 616
	bl	device_create_file
	ldr	x0, [x19, 312]
	add	x1, x23, 648
	bl	device_create_file
	ldr	x0, [x19, 312]
	add	x1, x23, 680
	bl	device_create_file
	ldr	x0, [x19, 312]
	add	x1, x23, 712
	bl	device_create_file
	ldr	x0, [x19, 312]
	add	x1, x23, 744
	bl	device_create_file
	ldr	x0, [x21, 96]
	adrp	x2, .LC42
	adrp	x1, .LC90
	add	x2, x2, :lo12:.LC42
	add	x1, x1, :lo12:.LC90
	bl	_dev_info
	b	.L1232
	.p2align 3
.L1256:
	mov	w20, -22
	adrp	x1, .LC108
	mov	w2, w20
	add	x1, x1, :lo12:.LC108
	mov	x0, x22
	bl	_dev_err
	b	.L1232
	.p2align 3
.L1348:
	mov	x0, x19
	mov	w20, -12
	bl	kfree
	b	.L1232
	.p2align 3
.L1239:
	mov	w20, -12
	b	.L1232
	.p2align 3
.L1306:
	mov	w0, 3566
	str	w0, [x29, 108]
	b	.L1238
	.p2align 3
.L1358:
	adrp	x1, .LC71
	mov	x0, x22
	add	x1, x1, :lo12:.LC71
	bl	_dev_err
	b	.L1232
.L1364:
	ldr	x0, [x26, 24]
	adrp	x1, cpu_bit_bitmap+48
	add	x1, x1, :lo12:cpu_bit_bitmap+48
	bl	set_cpus_allowed_ptr
	b	.L1273
.L1368:
	mov	w2, 1
	str	w2, [x21, 88]
	add	x0, x23, :lo12:.LANCHOR1
	mov	w1, w2
	add	x0, x0, 304
	bl	__wake_up_sync
	b	.L1292
.L1365:
	ldr	x0, [x21, 96]
	adrp	x1, .LC82
	add	x1, x1, :lo12:.LC82
	bl	_dev_info
	ldp	w0, w1, [x23, 76]
	mul	w0, w0, w1
	mov	w1, 32960
	movk	w1, 0x60, lsl 16
	lsr	w0, w0, 1
	bl	__kmalloc
	mov	x24, x0
	cbz	x0, .L1369
	ldp	w2, w1, [x23, 76]
	ldr	x4, [x19, 216]
	mul	w2, w2, w1
	ldr	w1, [x29, 124]
	sub	x1, x1, x4
	ldr	x4, [x21, 8]
	lsr	w2, w2, 1
	add	x1, x4, x1
	bl	memcpy
	cbnz	x28, .L1370
	mov	w27, 0
	mov	x26, 0
.L1277:
	adrp	x0, .LC89
	add	x0, x0, :lo12:.LC89
	bl	ebc_empty_buf_get
	mov	x5, x0
	cbz	x0, .L1282
	ldp	w4, w0, [x23, 76]
	mov	x1, 0
	ldr	x2, [x5, 16]
	mul	w4, w4, w0
	lsr	w4, w4, 1
	cbz	w4, .L1285
	.p2align 2
.L1332:
	ldrb	w0, [x24, x1]
	add	x1, x1, 1
	cmp	w4, w1
	and	w3, w0, -16
	lsl	w0, w0, 4
	strb	w0, [x2], 2
	strb	w3, [x2, -1]
	bgt	.L1332
.L1285:
	stp	wzr, wzr, [x5, 48]
	mov	w0, 7
	str	w0, [x5, 40]
	mov	w2, 1
	mov	x0, x5
	ldr	w1, [x23, 76]
	str	w1, [x5, 56]
	ldr	w1, [x23, 80]
	stp	w1, w2, [x5, 60]
	bl	ebc_add_to_dsp_buf_list
	b	.L1282
.L1361:
	ldr	x0, [x26, 8]
	adrp	x1, cpu_bit_bitmap+56
	add	x1, x1, :lo12:cpu_bit_bitmap+56
	bl	set_cpus_allowed_ptr
	b	.L1269
.L1359:
	adrp	x1, .LC72
	mov	x0, x22
	add	x1, x1, :lo12:.LC72
	bl	_dev_err
	b	.L1232
.L1363:
	ldr	x0, [x24, 16]
	adrp	x1, cpu_bit_bitmap+64
	add	x1, x1, :lo12:cpu_bit_bitmap+64
	bl	set_cpus_allowed_ptr
	b	.L1271
.L1242:
	mov	w20, -517
	b	.L1232
.L1367:
	adrp	x0, .LC89
	add	x0, x0, :lo12:.LC89
	bl	ebc_empty_buf_get
	cbz	x0, .L1287
	ldp	w5, w1, [x23, 76]
	mov	x2, 0
	ldr	x3, [x0, 16]
	mul	w5, w5, w1
	lsr	w5, w5, 1
	cbz	w5, .L1291
	.p2align 2
.L1331:
	ldrb	w1, [x26, x2]
	add	x2, x2, 1
	cmp	w5, w2
	and	w4, w1, -16
	lsl	w1, w1, 4
	strb	w1, [x3], 2
	strb	w4, [x3, -1]
	bgt	.L1331
.L1291:
	mov	w1, 7
	stp	wzr, wzr, [x0, 48]
	str	w1, [x0, 40]
	mov	w2, 1
	ldr	w1, [x23, 76]
	str	w1, [x0, 56]
	ldr	w1, [x23, 80]
	stp	w1, w2, [x0, 60]
	bl	ebc_add_to_dsp_buf_list
	b	.L1287
.L1243:
	adrp	x1, .LC52
	mov	x0, x22
	add	x1, x1, :lo12:.LC52
	mov	w20, -22
	bl	_dev_err
	b	.L1232
.L1366:
	ldr	x0, [x21, 96]
	adrp	x1, .LC85
	add	x1, x1, :lo12:.LC85
	bl	_dev_info
	ldp	w0, w1, [x23, 76]
	mul	w0, w0, w1
	mov	w1, 32960
	movk	w1, 0x60, lsl 16
	lsr	w0, w0, 1
	bl	__kmalloc
	mov	x26, x0
	cbz	x0, .L1371
	ldp	w2, w1, [x23, 76]
	mov	w27, 1
	ldr	x3, [x19, 216]
	mul	w2, w2, w1
	ldr	w1, [x29, 128]
	sub	x1, x1, x3
	ldr	x3, [x21, 8]
	lsr	w2, w2, 1
	add	x1, x3, x1
	bl	memcpy
	b	.L1278
.L1360:
	ldr	x0, [x21, 96]
	adrp	x1, .LC74
	add	x1, x1, :lo12:.LC74
	bl	_dev_err
.L1268:
	adrp	x1, .LC107
	mov	x0, x22
	add	x1, x1, :lo12:.LC107
	mov	w20, -1
	bl	_dev_err
	b	.L1232
.L1362:
	ldr	x0, [x21, 96]
	adrp	x1, .LC76
	add	x1, x1, :lo12:.LC76
	bl	_dev_err
	b	.L1268
.L1272:
	ldr	x0, [x21, 96]
	adrp	x1, .LC106
	str	x24, [x26, 24]
	add	x1, x1, :lo12:.LC106
	bl	_dev_err
	b	.L1268
.L1349:
	adrp	x1, .LC49
	mov	x0, x22
	add	x1, x1, :lo12:.LC49
	mov	w20, -19
	bl	_dev_err
	b	.L1232
.L1280:
	ldr	x0, [x19, 24]
	bl	ebc_regulator_verity_vcom
	b	.L1281
.L1357:
	bl	__stack_chk_fail
.L1371:
	ldr	x0, [x21, 96]
	adrp	x1, .LC86
	adrp	x23, .LANCHOR1
	add	x1, x1, :lo12:.LC86
	bl	_dev_err
	b	.L1276
.L1370:
	str	w27, [x29, 108]
	b	.L1303
.L1369:
	ldr	x0, [x21, 96]
	adrp	x1, .LC83
	adrp	x23, .LANCHOR1
	add	x1, x1, :lo12:.LC83
	bl	_dev_err
	b	.L1276
	.size	ebc_probe, .-ebc_probe
	.align	2
	.p2align 3,,7
	.type	auto_frame_state_read, %function
auto_frame_state_read:
	adrp	x0, .LANCHOR0
	ldr	x1, [x0, #:lo12:.LANCHOR0]
	ldp	w0, w4, [x1, 116]
	mul	w4, w4, w0
	cbz	w4, .L1373
	ldr	x5, [x1, 376]
	mov	w1, 0
	ldrb	w3, [x5]
	cbz	w3, .L1376
	b	.L1374
	.p2align 3
.L1378:
	ldrb	w3, [x5, w1, sxtw]
	cbnz	w3, .L1374
.L1376:
	add	w1, w1, 1
	cmp	w1, w4
	bne	.L1378
.L1373:
	adrp	x1, .LC109
	add	x1, x1, :lo12:.LC109
	mov	x0, 2
	ldrh	w3, [x1]
	ldrb	w1, [x1, 2]
	strh	w3, [x2]
	strb	w1, [x2, 2]
	ret
	.p2align 3
.L1374:
	stp	x29, x30, [sp, -16]!
	mov	x0, x2
	adrp	x1, .LC41
	mov	w2, w3
	add	x29, sp, 0
	add	x1, x1, :lo12:.LC41
	bl	sprintf
	sxtw	x0, w0
	ldp	x29, x30, [sp], 16
	ret
	.size	auto_frame_state_read, .-auto_frame_state_read
	.align	2
	.p2align 3,,7
	.global	refresh_new_image
	.type	refresh_new_image, %function
refresh_new_image:
	stp	x29, x30, [sp, -80]!
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	stp	x23, x24, [sp, 48]
	str	x25, [sp, 64]
	ldp	w19, w6, [x5, 80]
	cmp	w6, 0
	add	w12, w6, 7
	csel	w12, w12, w6, lt
	cmp	w19, 0
	ble	.L1388
	asr	w12, w12, 3
	mov	w30, 0
	sub	w18, w12, #1
	mov	x17, 4026531840
	add	x18, x18, 1
	mov	x16, 1030792151040
	lsl	x18, x18, 3
	mov	x15, 263882790666240
	mov	x14, 67553994410557440
	mov	x13, -1152921504606846976
	mov	x24, -2305843009213693952
	mov	x23, 63050394783186944
	mov	x22, 246290604621824
	mov	x21, 962072674304
	mov	x20, 3758096384
	.p2align 2
.L1390:
	mov	x8, 0
	cmp	w12, 0
	ble	.L1455
	.p2align 2
.L1460:
	ldr	x11, [x3, x8, lsl 3]
	ldr	x7, [x4, x8, lsl 3]
	ldr	x6, [x1, x8, lsl 3]
	ldr	x9, [x0, x8, lsl 3]
	ldr	x10, [x2, x8, lsl 3]
	cbnz	x11, .L1391
	and	x5, x6, 240
	cmp	x5, 240
	bne	.L1466
	mov	x5, 255
.L1392:
	and	x7, x6, 61440
	cmp	x7, 61440
	bne	.L1395
	orr	x5, x5, 65280
.L1396:
	and	x7, x6, 15728640
	cmp	x7, 15728640
	bne	.L1399
	orr	x5, x5, 16711680
.L1400:
	and	x7, x6, 4026531840
	cmp	x7, x17
	bne	.L1403
	orr	x5, x5, 4278190080
.L1404:
	and	x7, x6, 1030792151040
	cmp	x7, x16
	bne	.L1407
.L1469:
	orr	x5, x5, 1095216660480
.L1408:
	and	x7, x6, 263882790666240
	cmp	x7, x15
	bne	.L1411
.L1470:
	orr	x5, x5, 280375465082880
.L1412:
	and	x7, x6, 67553994410557440
	cmp	x7, x14
	bne	.L1415
.L1471:
	orr	x5, x5, 71776119061217280
.L1416:
	and	x7, x6, -1152921504606846976
	cmp	x7, x13
	bne	.L1467
.L1463:
	orr	x5, x5, -72057594037927936
.L1420:
	eor	x6, x9, x10
	str	x11, [x4, x8, lsl 3]
	and	x5, x6, x5
	eor	x5, x9, x5
	str	x5, [x0, x8, lsl 3]
	add	x8, x8, 1
	cmp	w12, w8
	bgt	.L1460
	add	x3, x3, x18
	add	x1, x1, x18
	add	x2, x2, x18
	add	x4, x4, x18
	add	x0, x0, x18
.L1455:
	add	w30, w30, 1
	cmp	w19, w30
	bne	.L1390
.L1388:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldr	x25, [sp, 64]
	ldp	x29, x30, [sp], 80
	ret
	.p2align 3
.L1467:
	cbz	x7, .L1464
	and	x9, x9, 72057594037927935
	cmp	x7, x24
	beq	.L1465
	orr	x9, x7, x9
	b	.L1420
	.p2align 3
.L1391:
	and	x25, x11, 255
	mov	x5, 0
	cbnz	x25, .L1423
	and	x5, x6, 240
	and	x7, x7, -256
	cmp	x5, 240
	bne	.L1468
	mov	x5, 255
.L1423:
	tst	x11, 65280
	bne	.L1426
	and	x25, x6, 61440
	and	x7, x7, -65281
	cmp	x25, 61440
	bne	.L1427
	orr	x5, x5, 65280
.L1426:
	tst	x11, 16711680
	bne	.L1430
	and	x25, x6, 15728640
	and	x7, x7, -16711681
	cmp	x25, 15728640
	bne	.L1431
	orr	x5, x5, 16711680
.L1430:
	tst	x11, 4278190080
	bne	.L1434
	and	x25, x6, 4026531840
	and	x7, x7, -4278190081
	cmp	x25, x17
	bne	.L1435
	orr	x5, x5, 4278190080
.L1434:
	tst	x11, 1095216660480
	bne	.L1438
	and	x25, x6, 1030792151040
	and	x7, x7, -1095216660481
	cmp	x25, x16
	bne	.L1439
	orr	x5, x5, 1095216660480
.L1438:
	tst	x11, 280375465082880
	bne	.L1442
	and	x25, x6, 263882790666240
	and	x7, x7, -280375465082881
	cmp	x25, x15
	bne	.L1443
	orr	x5, x5, 280375465082880
.L1442:
	tst	x11, 71776119061217280
	bne	.L1446
	and	x25, x6, 67553994410557440
	and	x7, x7, -71776119061217281
	cmp	x25, x14
	bne	.L1447
	orr	x5, x5, 71776119061217280
.L1446:
	and	x25, x11, -72057594037927936
	mov	x11, x7
	cbnz	x25, .L1420
	and	x6, x6, -1152921504606846976
	and	x11, x7, 72057594037927935
	cmp	x6, x13
	beq	.L1463
	cbz	x6, .L1464
	and	x9, x9, 72057594037927935
	cmp	x6, x24
	beq	.L1465
	orr	x9, x6, x9
	b	.L1420
	.p2align 3
.L1464:
	and	x9, x9, 72057594037927935
	orr	x11, x11, 72057594037927936
	b	.L1420
	.p2align 3
.L1403:
	and	x9, x9, -4278190081
	cbnz	x7, .L1405
	and	x7, x6, 1030792151040
	orr	x11, x11, 16777216
	cmp	x7, x16
	beq	.L1469
	.p2align 2
.L1407:
	and	x9, x9, -1095216660481
	cbnz	x7, .L1409
	and	x7, x6, 263882790666240
	orr	x11, x11, 4294967296
	cmp	x7, x15
	beq	.L1470
	.p2align 2
.L1411:
	and	x9, x9, -280375465082881
	cbnz	x7, .L1413
	and	x7, x6, 67553994410557440
	orr	x11, x11, 1099511627776
	cmp	x7, x14
	beq	.L1471
	.p2align 2
.L1415:
	and	x9, x9, -71776119061217281
	cbnz	x7, .L1417
	orr	x11, x11, 281474976710656
	b	.L1416
	.p2align 3
.L1399:
	and	x9, x9, -16711681
	cbnz	x7, .L1401
	orr	x11, x11, 65536
	b	.L1400
	.p2align 3
.L1395:
	and	x9, x9, -65281
	cbnz	x7, .L1397
	orr	x11, x11, 256
	b	.L1396
	.p2align 3
.L1466:
	cbnz	x5, .L1393
	and	x9, x9, -256
	mov	x11, 1
	b	.L1392
	.p2align 3
.L1405:
	cmp	x7, x20
	beq	.L1472
	orr	x9, x7, x9
	b	.L1404
	.p2align 3
.L1417:
	cmp	x7, x23
	beq	.L1473
	orr	x9, x7, x9
	b	.L1416
	.p2align 3
.L1401:
	cmp	x7, 14680064
	beq	.L1474
	orr	x9, x7, x9
	b	.L1400
	.p2align 3
.L1413:
	cmp	x7, x22
	beq	.L1475
	orr	x9, x7, x9
	b	.L1412
	.p2align 3
.L1397:
	cmp	x7, 57344
	beq	.L1476
	orr	x9, x7, x9
	b	.L1396
	.p2align 3
.L1409:
	cmp	x7, x21
	beq	.L1477
	orr	x9, x7, x9
	b	.L1408
	.p2align 3
.L1393:
	cmp	x5, 224
	beq	.L1478
	and	x9, x9, -256
	orr	x9, x5, x9
	mov	x5, 0
	b	.L1392
	.p2align 3
.L1465:
	orr	x11, x11, 72057594037927936
	orr	x9, x9, -1152921504606846976
	b	.L1420
	.p2align 3
.L1472:
	orr	x11, x11, 16777216
	orr	x9, x9, 4026531840
	b	.L1404
	.p2align 3
.L1478:
	and	x5, x9, -256
	mov	x11, 1
	orr	x9, x5, 240
	mov	x5, 0
	b	.L1392
	.p2align 3
.L1473:
	orr	x11, x11, 281474976710656
	orr	x9, x9, 67553994410557440
	b	.L1416
	.p2align 3
.L1475:
	orr	x11, x11, 1099511627776
	orr	x9, x9, 263882790666240
	b	.L1412
	.p2align 3
.L1474:
	orr	x11, x11, 65536
	orr	x9, x9, 15728640
	b	.L1400
	.p2align 3
.L1476:
	orr	x11, x11, 256
	orr	x9, x9, 61440
	b	.L1396
	.p2align 3
.L1477:
	orr	x11, x11, 4294967296
	orr	x9, x9, 1030792151040
	b	.L1408
.L1468:
	cbz	x5, .L1479
	cmp	x5, 224
	beq	.L1480
	and	x9, x9, -256
	orr	x9, x5, x9
	mov	x5, 0
	b	.L1423
.L1427:
	and	x9, x9, -65281
	cbz	x25, .L1481
	cmp	x25, 57344
	beq	.L1482
	orr	x9, x25, x9
	b	.L1426
.L1431:
	and	x9, x9, -16711681
	cbz	x25, .L1483
	cmp	x25, 14680064
	beq	.L1484
	orr	x9, x25, x9
	b	.L1430
.L1435:
	and	x9, x9, -4278190081
	cbz	x25, .L1485
	cmp	x25, x20
	beq	.L1486
	orr	x9, x25, x9
	b	.L1434
.L1439:
	and	x9, x9, -1095216660481
	cbz	x25, .L1487
	cmp	x25, x21
	beq	.L1488
	orr	x9, x25, x9
	b	.L1438
.L1443:
	and	x9, x9, -280375465082881
	cbz	x25, .L1489
	cmp	x25, x22
	beq	.L1490
	orr	x9, x25, x9
	b	.L1442
.L1447:
	and	x9, x9, -71776119061217281
	cbz	x25, .L1491
	cmp	x25, x23
	beq	.L1492
	orr	x9, x25, x9
	b	.L1446
.L1491:
	orr	x7, x7, 281474976710656
	b	.L1446
.L1489:
	orr	x7, x7, 1099511627776
	b	.L1442
.L1487:
	orr	x7, x7, 4294967296
	b	.L1438
.L1485:
	orr	x7, x7, 16777216
	b	.L1434
.L1483:
	orr	x7, x7, 65536
	b	.L1430
.L1481:
	orr	x7, x7, 256
	b	.L1426
.L1479:
	and	x9, x9, -256
	orr	x7, x7, 1
	b	.L1423
.L1492:
	orr	x7, x7, 281474976710656
	orr	x9, x9, 67553994410557440
	b	.L1446
.L1480:
	and	x5, x9, -256
	orr	x7, x7, 1
	orr	x9, x5, 240
	mov	x5, 0
	b	.L1423
.L1482:
	orr	x7, x7, 256
	orr	x9, x9, 61440
	b	.L1426
.L1484:
	orr	x7, x7, 65536
	orr	x9, x9, 15728640
	b	.L1430
.L1486:
	orr	x7, x7, 16777216
	orr	x9, x9, 4026531840
	b	.L1434
.L1488:
	orr	x7, x7, 4294967296
	orr	x9, x9, 1030792151040
	b	.L1438
.L1490:
	orr	x7, x7, 1099511627776
	orr	x9, x9, 263882790666240
	b	.L1442
	.size	refresh_new_image, .-refresh_new_image
	.align	2
	.p2align 3,,7
	.global	refresh_new_image_auto
	.type	refresh_new_image_auto, %function
refresh_new_image_auto:
	ldp	w14, w4, [x3, 80]
	cmp	w4, 0
	add	w10, w4, 7
	csel	w10, w10, w4, lt
	cmp	w14, 0
	asr	w10, w10, 3
	ble	.L1493
	sub	w12, w10, #1
	mov	w13, 0
	add	x12, x12, 1
	mov	x11, 255
	lsl	x12, x12, 3
	.p2align 2
.L1495:
	cmp	w10, 0
	ble	.L1506
	add	x7, x0, 8
	mov	x5, 0
	.p2align 2
.L1505:
	ldr	x3, [x1, x5, lsl 3]
	ldr	x8, [x7, -8]
	eor	x6, x3, x8
	cmp	x3, x8
	beq	.L1496
	ldr	x4, [x2, x5, lsl 3]
	and	x3, x4, 255
	cmp	x3, 0
	csel	x3, xzr, x11, ne
	tst	x4, 65280
	orr	x9, x3, 65280
	csel	x3, x9, x3, eq
	tst	x4, 16711680
	orr	x9, x3, 16711680
	csel	x3, x9, x3, eq
	tst	x4, 4278190080
	orr	x9, x3, 4278190080
	csel	x3, x9, x3, eq
	tst	x4, 1095216660480
	orr	x9, x3, 1095216660480
	csel	x3, x9, x3, eq
	tst	x4, 280375465082880
	orr	x9, x3, 280375465082880
	csel	x3, x9, x3, eq
	tst	x4, 71776119061217280
	orr	x9, x3, 71776119061217280
	csel	x3, x9, x3, eq
	tst	x4, -72057594037927936
	orr	x4, x3, -72057594037927936
	csel	x3, x4, x3, eq
	and	x3, x6, x3
	eor	x3, x3, x8
	str	x3, [x7, -8]
.L1496:
	add	x5, x5, 1
	add	x7, x7, 8
	cmp	w10, w5
	bgt	.L1505
	add	x0, x0, x12
	add	x2, x2, x12
	add	x1, x1, x12
.L1506:
	add	w13, w13, 1
	cmp	w14, w13
	bne	.L1495
.L1493:
	ret
	.size	refresh_new_image_auto, .-refresh_new_image_auto
	.align	2
	.p2align 3,,7
	.type	ebc_thread, %function
ebc_thread:
	stp	x29, x30, [sp, -176]!
	adrp	x1, .LANCHOR0
	adrp	x0, __stack_chk_guard
	add	x0, x0, :lo12:__stack_chk_guard
	add	x29, sp, 0
	stp	x25, x26, [sp, 64]
	adrp	x26, .LANCHOR1
	ldr	x25, [x1, #:lo12:.LANCHOR0]
	stp	x23, x24, [sp, 48]
	mov	w24, 24
	stp	x27, x28, [sp, 80]
	add	x27, x25, 216
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	ldr	x1, [x0]
	str	x1, [x29, 168]
	mov	x1,0
	add	x0, x25, 40
	str	x0, [x29, 112]
	add	x0, x25, 736
	str	x0, [x29, 120]
	add	x0, x25, 680
	str	x0, [x29, 104]
	.p2align 2
.L1510:
	bl	ebc_osd_buf_get
	mov	x19, x0
	cbz	x0, .L1511
.L1836:
	ldr	x0, [x27, 576]
	cbz	x0, .L1512
	ldr	w0, [x27, 624]
	cmp	w0, 0
	ble	.L1831
	ldr	x0, [x27, 96]
	adrp	x1, .LC110
	add	x1, x1, :lo12:.LC110
	bl	_dev_info
.L1831:
	mov	x0, x19
	bl	ebc_buf_release
	bl	ebc_osd_buf_get
	mov	x19, x0
	cbnz	x0, .L1836
.L1511:
	ldr	w0, [x27, 592]
	str	wzr, [x27, 92]
	cbz	w0, .L1561
	ldr	w0, [x27, 588]
	cbnz	w0, .L1561
	ldr	w0, [x27, 596]
	cbnz	w0, .L1561
.L1562:
	ldr	w0, [x27, 88]
	cbz	w0, .L1837
.L1718:
.L1716:
	str	wzr, [x27, 88]
	b	.L1510
.L1837:
	add	x19, x26, :lo12:.LANCHOR1
	mov	w1, 0
	add	x0, x29, 128
	add	x19, x19, 304
	bl	init_wait_entry
	mov	x20, 15
	mov	w2, 1
	add	x1, x29, 128
	mov	x0, x19
	bl	prepare_to_wait_event
	mov	x3, x0
	ldr	w0, [x27, 88]
	mov	w1, 0
	cmp	w0, 0
	cset	w2, ne
.L1708:
	mov	x0, x20
	orr	w1, w1, w2
	cbnz	w1, .L1707
	cbnz	x3, .L1706
	bl	schedule_timeout
	mov	x20, x0
	mov	w2, 1
	add	x1, x29, 128
	mov	x0, x19
	bl	prepare_to_wait_event
	mov	x3, x0
	ldr	w0, [x27, 88]
	cmp	w0, 0
	cset	w2, ne
	cmp	x20, 0
	cset	w1, eq
	tst	w2, w1
	beq	.L1708
.L1707:
	add	x0, x26, :lo12:.LANCHOR1
	add	x1, x29, 128
	add	x0, x0, 304
	bl	finish_wait
.L1706:
	ldr	w0, [x27, 88]
	cbnz	w0, .L1510
	ldr	w0, [x27, 52]
	cmp	w0, 1
	bne	.L1711
	add	x19, x26, :lo12:.LANCHOR1
	mov	w1, 0
	add	x0, x29, 128
	add	x19, x19, 304
	bl	init_wait_entry
	b	.L1714
	.p2align 3
.L1838:
	ldr	w1, [x27, 88]
	cbnz	w1, .L1712
	cbnz	x0, .L1713
	bl	schedule
.L1714:
	add	x1, x29, 128
	mov	w2, 1
	mov	x0, x19
	bl	prepare_to_wait_event
	ldr	w1, [x27, 52]
	cbnz	w1, .L1838
.L1712:
	add	x0, x26, :lo12:.LANCHOR1
	add	x1, x29, 128
	add	x0, x0, 304
	bl	finish_wait
.L1713:
	bl	ebc_get_dsp_list_enum_num
	cbnz	w0, .L1510
	bl	ebc_get_osd_list_enum_num
	cbnz	w0, .L1510
	ldr	w0, [x27, 52]
	cbz	w0, .L1832
.L1715:
	ldr	w0, [x27, 88]
	cbnz	w0, .L1716
	add	x19, x26, :lo12:.LANCHOR1
	mov	w1, 0
	add	x19, x19, 304
	add	x0, x29, 128
	bl	init_wait_entry
.L1719:
	add	x1, x29, 128
	mov	w2, 1
	mov	x0, x19
	bl	prepare_to_wait_event
	ldr	w1, [x27, 88]
	cbnz	w1, .L1717
	cbnz	x0, .L1716
	bl	schedule
	b	.L1719
	.p2align 3
.L1512:
	ldr	w0, [x27, 240]
	cmp	w0, 2
	beq	.L1517
	cmp	w0, 1
	beq	.L1839
.L1516:
	str	x19, [x27, 232]
	mov	w0, 4
	str	w0, [x27, 240]
	ldr	x0, [x27, 216]
	ldp	w2, w22, [x19, 48]
	ldp	w1, w28, [x19, 56]
	cmp	w2, 0
	ldr	x12, [x0, 16]
	add	w23, w2, 7
	ldr	w0, [x25, 300]
	csel	w23, w23, w2, lt
	add	w14, w1, 7
	cmp	w1, 0
	csel	w14, w14, w1, lt
	add	w16, w0, 7
	cmp	w0, 0
	asr	w14, w14, 3
	csel	w16, w16, w0, lt
	add	w14, w14, 1
	asr	w16, w16, 3
	ldr	w0, [x25, 296]
	cmp	w14, w16
	sub	w1, w16, #1
	csel	w14, w1, w14, ge
	cmp	w0, w28
	sub	w0, w0, #1
	ldr	x8, [x27, 136]
	csel	w28, w0, w28, le
	mul	w0, w22, w16
	ldp	x13, x9, [x27, 160]
	asr	w23, w23, 3
	ldr	x11, [x19, 16]
	sbfiz	x0, x0, 3, 32
	cmp	w22, w28
	add	x12, x12, x0
	add	x11, x11, x0
	add	x8, x8, x0
	add	x13, x13, x0
	add	x9, x9, x0
	bgt	.L1521
	sbfiz	x16, x16, 3, 32
	mov	x21, 4026531840
	mov	x20, 1030792151040
	mov	x19, 263882790666240
	mov	x18, 67553994410557440
	mov	x17, -1152921504606846976
	.p2align 2
.L1522:
	cmp	w23, w14
	mov	w5, w23
	ble	.L1782
	b	.L1556
	.p2align 3
.L1841:
	and	x15, x4, 240
	and	x0, x0, -256
	cmp	x15, 240
	bne	.L1840
	mov	x2, 255
.L1523:
	tst	x1, 65280
	bne	.L1526
	and	x15, x4, 61440
	and	x0, x0, -65281
	cmp	x15, 61440
	bne	.L1527
	orr	x2, x2, 65280
.L1526:
	tst	x1, 16711680
	bne	.L1530
	and	x15, x4, 15728640
	and	x0, x0, -16711681
	cmp	x15, 15728640
	bne	.L1531
	orr	x2, x2, 16711680
.L1530:
	tst	x1, 4278190080
	bne	.L1534
	and	x15, x4, 4026531840
	and	x0, x0, -4278190081
	cmp	x15, x21
	bne	.L1535
	orr	x2, x2, 4278190080
.L1534:
	tst	x1, 1095216660480
	bne	.L1538
	and	x15, x4, 1030792151040
	and	x0, x0, -1095216660481
	cmp	x15, x20
	bne	.L1539
	orr	x2, x2, 1095216660480
.L1538:
	tst	x1, 280375465082880
	bne	.L1542
	and	x15, x4, 263882790666240
	and	x0, x0, -280375465082881
	cmp	x15, x19
	bne	.L1543
	orr	x2, x2, 280375465082880
.L1542:
	tst	x1, 71776119061217280
	bne	.L1546
	and	x15, x4, 67553994410557440
	and	x0, x0, -71776119061217281
	cmp	x15, x18
	bne	.L1547
	orr	x2, x2, 71776119061217280
.L1546:
	tst	x1, -72057594037927936
	bne	.L1550
	and	x4, x4, -1152921504606846976
	and	x0, x0, 72057594037927935
	cmp	x4, x17
	bne	.L1551
	orr	x2, x2, -72057594037927936
.L1550:
	eor	x6, x6, x3
	str	x0, [x7]
	and	x2, x6, x2
	add	w5, w5, 1
	eor	x2, x3, x2
	str	x2, [x10]
	cmp	w5, w14
	bgt	.L1556
.L1782:
	sxtw	x0, w5
	lsl	x7, x0, 3
	add	x10, x8, x7
	add	x7, x9, x7
	ldr	x1, [x13, x0, lsl 3]
	ldr	x3, [x8, x0, lsl 3]
	ldr	x4, [x11, x0, lsl 3]
	ands	x2, x1, 255
	ldr	x6, [x12, x0, lsl 3]
	ldr	x0, [x9, x0, lsl 3]
	beq	.L1841
	mov	x2, 0
	b	.L1523
	.p2align 3
.L1556:
	add	w22, w22, 1
	add	x8, x8, x16
	add	x11, x11, x16
	add	x12, x12, x16
	add	x13, x13, x16
	add	x9, x9, x16
	cmp	w22, w28
	ble	.L1522
.L1521:
	ldr	w0, [x27, 52]
	cbnz	w0, .L1557
	mov	w19, 1
	str	w19, [x27, 52]
	mov	w1, w19
	mov	x0, x25
	bl	ebc_power_set
	mov	w2, 0
	mov	w1, w19
	mov	x0, x25
	bl	ebc_lut_update
	ldr	w2, [x27, 104]
	ldr	w0, [x27, 624]
	strb	w2, [x27, 56]
	lsr	w3, w2, 8
	strb	w3, [x27, 57]
	cmp	w0, 0
	ble	.L1558
	ldr	x0, [x27, 96]
	adrp	x1, .LC112
	and	w3, w3, 255
	and	w2, w2, 255
	add	x1, x1, :lo12:.LC112
	bl	_dev_info
.L1558:
	mov	x0, x25
	bl	ebc_frame_start
.L1559:
	ldr	x0, [x27, 224]
	cbz	x0, .L1560
	bl	ebc_buf_release
.L1560:
	ldr	x0, [x27, 232]
	str	x0, [x27, 224]
	b	.L1510
	.p2align 3
.L1527:
	and	x3, x3, -65281
	cbnz	x15, .L1528
	orr	x0, x0, 256
	b	.L1526
	.p2align 3
.L1535:
	cbnz	x15, .L1536
	and	x3, x3, -4278190081
	orr	x0, x0, 16777216
	b	.L1534
	.p2align 3
.L1840:
	cbnz	x15, .L1524
	and	x3, x3, -256
	orr	x0, x0, 1
	b	.L1523
	.p2align 3
.L1543:
	cbnz	x15, .L1544
	and	x3, x3, -280375465082881
	orr	x0, x0, 1099511627776
	b	.L1542
	.p2align 3
.L1551:
	cbnz	x4, .L1552
	and	x3, x3, 72057594037927935
	orr	x0, x0, 72057594037927936
	b	.L1550
	.p2align 3
.L1539:
	cbnz	x15, .L1540
	and	x3, x3, -1095216660481
	orr	x0, x0, 4294967296
	b	.L1538
	.p2align 3
.L1531:
	and	x3, x3, -16711681
	cbnz	x15, .L1532
	orr	x0, x0, 65536
	b	.L1530
	.p2align 3
.L1547:
	cbnz	x15, .L1548
	and	x3, x3, -71776119061217281
	orr	x0, x0, 281474976710656
	b	.L1546
	.p2align 3
.L1544:
	mov	x30, 246290604621824
	and	x3, x3, -280375465082881
	cmp	x15, x30
	beq	.L1842
	orr	x3, x15, x3
	b	.L1542
	.p2align 3
.L1528:
	cmp	x15, 57344
	beq	.L1843
	orr	x3, x15, x3
	b	.L1526
	.p2align 3
.L1536:
	mov	x30, 3758096384
	and	x3, x3, -4278190081
	cmp	x15, x30
	beq	.L1844
	orr	x3, x15, x3
	b	.L1534
	.p2align 3
.L1524:
	cmp	x15, 224
	beq	.L1845
	bfi	x3, x15, 0, 8
	b	.L1523
	.p2align 3
.L1548:
	mov	x30, 63050394783186944
	and	x3, x3, -71776119061217281
	cmp	x15, x30
	beq	.L1846
	orr	x3, x15, x3
	b	.L1546
	.p2align 3
.L1552:
	mov	x1, -2305843009213693952
	and	x3, x3, 72057594037927935
	cmp	x4, x1
	beq	.L1847
	orr	x3, x4, x3
	b	.L1550
	.p2align 3
.L1540:
	mov	x30, 962072674304
	and	x3, x3, -1095216660481
	cmp	x15, x30
	beq	.L1848
	orr	x3, x15, x3
	b	.L1538
	.p2align 3
.L1532:
	cmp	x15, 14680064
	beq	.L1849
	orr	x3, x15, x3
	b	.L1530
.L1845:
	and	x3, x3, -256
	orr	x0, x0, 1
	orr	x3, x3, 240
	b	.L1523
.L1842:
	orr	x0, x0, 1099511627776
	orr	x3, x3, 263882790666240
	b	.L1542
.L1846:
	orr	x0, x0, 281474976710656
	orr	x3, x3, 67553994410557440
	b	.L1546
.L1844:
	orr	x0, x0, 16777216
	orr	x3, x3, 4026531840
	b	.L1534
.L1848:
	orr	x0, x0, 4294967296
	orr	x3, x3, 1030792151040
	b	.L1538
.L1843:
	orr	x0, x0, 256
	orr	x3, x3, 61440
	b	.L1526
.L1847:
	orr	x0, x0, 72057594037927936
	orr	x3, x3, -1152921504606846976
	b	.L1550
.L1849:
	orr	x0, x0, 65536
	orr	x3, x3, 15728640
	b	.L1530
.L1557:
	adrp	x0, .LANCHOR0
	add	x0, x0, :lo12:.LANCHOR0
	ldr	x0, [x0, 8]
	bl	wake_up_process
	b	.L1559
.L1561:
	bl	ebc_dsp_buf_get
	mov	x19, x0
	cbz	x0, .L1562
	ldr	w2, [x0, 40]
	cmp	w2, 21
	beq	.L1563
	ldr	w0, [x27, 584]
	cbz	w0, .L1850
	ldr	w0, [x27, 240]
	cmp	w0, 2
	beq	.L1569
	cmp	w0, 1
	beq	.L1851
.L1568:
	ldr	x0, [x27, 216]
	ldr	w0, [x0, 40]
	cmp	w0, w2
	beq	.L1572
	ldr	w0, [x27, 52]
	cbnz	w0, .L1725
.L1572:
	mov	w0, 4
	str	x19, [x27, 216]
	str	w0, [x27, 240]
	mov	x5, x27
	ldr	x0, [x27, 136]
	ldr	x1, [x27, 16]
	ldp	x3, x4, [x27, 160]
	ldr	x2, [x19, 16]
	bl	refresh_new_image
	ldr	w0, [x27, 52]
	cbz	w0, .L1852
	ldr	x0, [x27, 216]
	ldr	w0, [x0, 40]
	cmp	w0, 0
	sub	w0, w0, #22
	ccmp	w0, 1, 0, ne
	bhi	.L1723
.L1588:
	ldr	w0, [x27, 460]
	cbnz	w0, .L1853
.L1702:
	mov	w0, 1
	str	w0, [x27, 460]
.L1703:
	ldr	x0, [x27, 216]
	str	x0, [x27, 208]
	b	.L1510
.L1839:
	ldr	w2, [x27, 72]
	cbz	w2, .L1517
	ldr	w0, [x27, 624]
	cmp	w0, 0
	ble	.L1518
	ldr	x0, [x27, 96]
	adrp	x1, .LC111
	add	x1, x1, :lo12:.LC111
	bl	_dev_info
.L1518:
	str	wzr, [x27, 72]
	b	.L1516
.L1517:
	ldr	x0, [x27, 208]
	ldrsw	x2, [x27, 28]
	ldr	x1, [x0, 16]
	ldr	x0, [x27, 144]
	bl	memcpy
	ldr	x0, [x27, 216]
	ldrsw	x2, [x27, 28]
	ldr	x1, [x0, 16]
	ldr	x0, [x27, 136]
	bl	memcpy
	b	.L1516
.L1850:
	ldr	w0, [x27, 240]
	cmp	w0, 4
	beq	.L1854
.L1565:
	ldr	w0, [x27, 460]
	cbnz	w0, .L1591
.L1724:
	str	x19, [x27, 208]
	ldr	w2, [x19, 40]
.L1591:
	cmp	w2, 16
	bgt	.L1593
	cmp	w2, 7
	bge	.L1729
	cmp	w2, 0
	beq	.L1595
	blt	.L1592
	cmp	w2, 2
	bge	.L1596
.L1592:
	ldr	x0, [x27, 96]
	adrp	x1, .LC129
	add	x1, x1, :lo12:.LC129
	bl	_dev_err
	b	.L1831
.L1563:
	ldr	w0, [x27, 460]
	cbz	w0, .L1724
.L1596:
	mov	w20, 1
.L1594:
	ldr	w0, [x27, 52]
	cbz	w0, .L1618
	ldr	w0, [x27, 624]
	cmp	w0, 0
	bgt	.L1619
.L1621:
	add	x21, x26, :lo12:.LANCHOR1
	mov	w1, 0
	add	x0, x29, 128
	add	x21, x21, 304
	bl	init_wait_entry
	b	.L1620
.L1855:
	cbnz	x0, .L1622
	bl	schedule
.L1620:
	add	x1, x29, 128
	mov	w2, 1
	mov	x0, x21
	bl	prepare_to_wait_event
	ldr	w1, [x27, 52]
	cbnz	w1, .L1855
	mov	x0, x21
	add	x1, x29, 128
	bl	finish_wait
.L1624:
.L1622:
	ldr	w0, [x27, 624]
	cmp	w0, 0
	ble	.L1618
	ldr	x0, [x27, 96]
	adrp	x1, .LC114
	add	x1, x1, :lo12:.LC114
	bl	_dev_info
.L1618:
	ldr	w0, [x27, 240]
	sub	w0, w0, #3
	cmp	w0, 1
	bls	.L1856
.L1626:
	ldr	w0, [x19, 40]
	cmp	w0, 6
	sub	w1, w0, #2
	ccmp	w0, 11, 4, ne
	ccmp	w1, 1, 0, ne
	bls	.L1857
	sub	w0, w0, #7
	cmp	w0, 1
	bls	.L1858
.L1629:
	ldr	w0, [x27, 604]
	cbz	w0, .L1642
	ldr	w0, [x19, 40]
	sub	w0, w0, #12
	cmp	w0, 2
	bls	.L1859
.L1642:
	str	wzr, [x27, 600]
	str	wzr, [x27, 608]
.L1646:
	mov	w1, 1
	mov	x0, x25
	bl	ebc_power_set
	str	x19, [x27, 216]
	add	w21, w20, 1
	ldr	w1, [x19, 40]
	cmp	w1, 13
	beq	.L1860
.L1648:
	cmp	w1, 12
	beq	.L1861
	cmp	w1, 14
	bne	.L1649
	ldr	w0, [x27, 604]
	cbnz	w0, .L1862
.L1649:
	mov	w2, w20
	mov	x0, x25
	bl	ebc_lut_update
	ldr	w0, [x27, 104]
	strb	w0, [x27, 56]
.L1651:
	mov	w20, 1
.L1654:
	ldr	w0, [x27, 624]
	cmp	w0, 0
	ble	.L1655
	ldr	x0, [x27, 216]
	adrp	x1, .LC121
	ldrb	w3, [x27, 56]
	add	x1, x1, :lo12:.LC121
	ldr	w2, [x0, 40]
	ldr	x0, [x27, 96]
	bl	_dev_info
.L1655:
	str	w20, [x27, 52]
	mov	x0, x25
	str	w21, [x27, 240]
	bl	ebc_frame_start
	adrp	x0, jiffies
	ldr	x1, [x0, #:lo12:jiffies]
	ldr	x0, [x29, 120]
	add	x1, x1, 900
	bl	mod_timer
	ldr	w0, [x19, 40]
	sub	w0, w0, #12
	cmp	w0, 2
	bls	.L1863
.L1656:
	ldr	w0, [x27, 52]
	cbz	w0, .L1667
.L1867:
	ldr	w0, [x27, 624]
	cmp	w0, 0
	bgt	.L1668
.L1670:
	add	x22, x26, :lo12:.LANCHOR1
	mov	w1, 0
	add	x0, x29, 128
	add	x22, x22, 304
	bl	init_wait_entry
	b	.L1669
.L1864:
	cbnz	x0, .L1671
	bl	schedule
.L1669:
	add	x1, x29, 128
	mov	w2, 1
	mov	x0, x22
	bl	prepare_to_wait_event
	ldr	w1, [x27, 52]
	cbnz	w1, .L1864
.L1673:
	mov	x0, x22
	add	x1, x29, 128
	bl	finish_wait
.L1671:
	ldr	w0, [x27, 72]
	cbnz	w0, .L1865
.L1675:
	ldr	w0, [x19, 40]
	sub	w0, w0, #12
	cmp	w0, 2
	bhi	.L1689
	bl	ebc_get_dsp_list_enum_num
	cbnz	w0, .L1689
	ldr	w0, [x27, 604]
	cbz	w0, .L1689
	ldr	w0, [x27, 600]
	str	wzr, [x27, 88]
	cbnz	w0, .L1866
	ldr	w0, [x27, 608]
	cbz	w0, .L1689
	add	x22, x26, :lo12:.LANCHOR1
	mov	w1, 0
	add	x0, x29, 128
	add	x22, x22, 304
	bl	init_wait_entry
	mov	x23, 3
	mov	w2, 1
	add	x1, x29, 128
	mov	x0, x22
	bl	prepare_to_wait_event
	mov	x3, x0
	ldr	w0, [x27, 88]
	mov	w1, 0
	cmp	w0, 0
	cset	w2, ne
	.p2align 2
.L1700:
	mov	x0, x23
	orr	w1, w1, w2
	cbnz	w1, .L1699
	cbnz	x3, .L1698
	bl	schedule_timeout
	mov	x23, x0
	mov	w2, 1
	add	x1, x29, 128
	mov	x0, x22
	bl	prepare_to_wait_event
	mov	x3, x0
	ldr	w0, [x27, 88]
	cmp	w0, 0
	cset	w2, ne
	cmp	x23, 0
	cset	w1, eq
	tst	w2, w1
	beq	.L1700
.L1699:
	add	x0, x26, :lo12:.LANCHOR1
	add	x1, x29, 128
	add	x0, x0, 304
	bl	finish_wait
.L1698:
	bl	ebc_get_dsp_list_enum_num
	cbnz	w0, .L1689
	ldr	w0, [x27, 624]
	cmp	w0, 0
	ble	.L1701
	ldr	x0, [x27, 96]
	adrp	x1, .LC128
	add	x1, x1, :lo12:.LC128
	bl	_dev_info
.L1701:
	ldr	x0, [x27, 216]
	ldr	w1, [x27, 80]
	ldr	x2, [x27, 152]
	ldr	x3, [x0, 16]
	ldr	w0, [x27, 84]
	bl	update_repair_buf_ghost
	ldr	x0, [x27, 208]
	ldrsw	x2, [x27, 28]
	ldr	x1, [x27, 152]
	ldr	x0, [x0, 16]
	bl	memcpy
	str	wzr, [x27, 608]
	ldr	w0, [x27, 104]
	strb	w0, [x27, 56]
	b	.L1654
.L1863:
	ldr	w0, [x27, 604]
	cbz	w0, .L1656
	ldr	w0, [x27, 608]
	cbz	w0, .L1656
	ldr	w0, [x27, 624]
	cmp	w0, 0
	ble	.L1657
	ldr	x0, [x27, 96]
	adrp	x1, .LC122
	add	x1, x1, :lo12:.LC122
	bl	_dev_info
.L1657:
	ldr	x0, [x27, 216]
	ldp	w13, w11, [x27, 80]
	ldr	w7, [x27, 684]
	cmp	w13, 0
	ldr	x6, [x0, 16]
	ldp	x4, x8, [x27, 144]
	ble	.L1731
	mov	w5, w11
	mov	w10, 0
	mov	w12, 0
.L1666:
	cmp	w11, 0
	ble	.L1659
	sub	w0, w5, w11
	.p2align 2
.L1665:
	ldrb	w2, [x6, w0, sxtw]
	sxtw	x3, w0
	ldrb	w1, [x4, w0, sxtw]
	cmp	w2, w1
	beq	.L1660
	cbz	w7, .L1661
	and	w9, w1, 240
	cmp	w2, w9
	beq	.L1662
	and	w9, w1, 15
	cmp	w7, w9
	ble	.L1663
	add	w1, w1, 1
	mov	w10, 1
	strb	w1, [x4, x3]
	.p2align 2
.L1661:
	strb	w24, [x8, x3]
.L1660:
	add	w0, w0, 1
	cmp	w5, w0
	bne	.L1665
.L1659:
	add	w12, w12, 1
	add	w5, w5, w11
	cmp	w13, w12
	bne	.L1666
	str	w10, [x27, 600]
.L1877:
	ldr	w0, [x27, 52]
	cbnz	w0, .L1867
.L1667:
	ldr	w0, [x27, 624]
	tbnz	w0, #31, .L1671
	ldr	x0, [x27, 96]
	adrp	x1, .LC124
	add	x1, x1, :lo12:.LC124
	bl	_dev_info
	ldr	w0, [x27, 72]
	cbz	w0, .L1675
.L1865:
	ldr	w0, [x27, 624]
	cmp	w0, 0
	ble	.L1676
	ldr	x0, [x27, 96]
	adrp	x1, .LC125
	add	x1, x1, :lo12:.LC125
	bl	_dev_info
.L1676:
	ldr	w0, [x27, 604]
	cbz	w0, .L1677
	ldr	w0, [x19, 40]
	sub	w0, w0, #12
	cmp	w0, 2
	bls	.L1868
.L1677:
	ldr	x0, [x27, 208]
	ldrsw	x2, [x27, 28]
	ldr	x1, [x0, 16]
	ldr	x0, [x27, 144]
	bl	memcpy
	ldr	x0, [x27, 216]
	ldrsw	x2, [x27, 28]
	ldr	x1, [x0, 16]
	ldr	x0, [x27, 136]
	bl	memcpy
	ldr	w0, [x27, 72]
	ldrb	w1, [x27, 56]
	ldr	w2, [x27, 28]
	sub	w1, w1, w0
	ldr	x3, [x27, 160]
	cmp	w2, 0
	mov	x0, 0
	ldp	x5, x4, [x27, 136]
	ble	.L1689
.L1783:
	ldrb	w7, [x4, x0]
	ldrb	w6, [x5, x0]
	cmp	w7, w6
	beq	.L1686
	strb	w1, [x3, x0]
.L1686:
	add	x0, x0, 1
	cmp	w2, w0
	bgt	.L1783
.L1689:
	adrp	x0, jiffies
	ldr	x1, [x0, #:lo12:jiffies]
	mov	x0, 402653184
	add	x1, x1, x0
	ldr	x0, [x29, 120]
	bl	mod_timer
.L1882:
	ldr	w0, [x27, 460]
	cbz	w0, .L1702
.L1853:
	ldr	x0, [x27, 208]
	bl	ebc_buf_release
	b	.L1703
	.p2align 3
.L1663:
	strb	w2, [x4, x3]
	b	.L1661
.L1662:
	and	w10, w1, 15
	cmp	w10, 1
	beq	.L1869
	sub	w1, w1, #1
	mov	w10, 1
	strb	w1, [x4, x3]
	b	.L1661
.L1869:
	mvn	w1, w2
	and	w1, w1, -16
	add	w1, w1, w7
	strb	w1, [x4, x3]
	b	.L1661
.L1866:
	add	x22, x26, :lo12:.LANCHOR1
	mov	w1, 0
	add	x0, x29, 128
	add	x22, x22, 304
	bl	init_wait_entry
	mov	x23, 3
	mov	w2, 1
	add	x1, x29, 128
	mov	x0, x22
	bl	prepare_to_wait_event
	mov	x3, x0
	ldr	w0, [x27, 88]
	mov	w1, 0
	cmp	w0, 0
	cset	w2, ne
.L1694:
	mov	x0, x23
	orr	w1, w1, w2
	cbnz	w1, .L1693
	cbnz	x3, .L1692
	bl	schedule_timeout
	mov	x23, x0
	mov	w2, 1
	add	x1, x29, 128
	mov	x0, x22
	bl	prepare_to_wait_event
	mov	x3, x0
	ldr	w0, [x27, 88]
	cmp	w0, 0
	cset	w2, ne
	cmp	x23, 0
	cset	w1, eq
	tst	w2, w1
	beq	.L1694
.L1693:
	add	x0, x26, :lo12:.LANCHOR1
	add	x1, x29, 128
	add	x0, x0, 304
	bl	finish_wait
.L1692:
	bl	ebc_get_dsp_list_enum_num
	cbnz	w0, .L1689
	ldr	w0, [x27, 624]
	cmp	w0, 0
	ble	.L1695
	ldr	x0, [x27, 96]
	adrp	x1, .LC127
	add	x1, x1, :lo12:.LC127
	bl	_dev_info
.L1695:
	ldr	x0, [x27, 208]
	ldrsw	x2, [x27, 28]
	ldr	x1, [x27, 144]
	ldr	x0, [x0, 16]
	bl	memcpy
	b	.L1654
.L1668:
	ldr	x0, [x27, 96]
	adrp	x1, .LC123
	add	x1, x1, :lo12:.LC123
	bl	_dev_info
	ldr	w0, [x27, 52]
	cbz	w0, .L1671
	b	.L1670
	.p2align 3
.L1857:
	ldr	x0, [x27, 208]
	ldr	w1, [x25, 244]
	ldr	x4, [x19, 16]
	cmp	w1, 0
	ldr	x5, [x0, 16]
	add	w0, w1, 7
	csel	w0, w0, w1, lt
	asr	w0, w0, 3
	cmp	w0, 0
	ble	.L1634
	ldr	x2, [x4]
	ldr	x1, [x5]
	cmp	x2, x1
	bne	.L1629
	sub	w1, w0, #1
	mov	x0, 8
	add	x1, x1, 1
	lsl	x1, x1, 3
	b	.L1631
.L1632:
	ldr	x3, [x4, x0]
	add	x0, x0, 8
	add	x2, x5, x0
	ldr	x2, [x2, -8]
	cmp	x3, x2
	bne	.L1629
.L1631:
	cmp	x1, x0
	bne	.L1632
.L1634:
	ldr	w0, [x27, 624]
	cmp	w0, 0
	ble	.L1641
	ldr	x0, [x27, 96]
	adrp	x1, .LC119
	add	x1, x1, :lo12:.LC119
	bl	_dev_info
.L1641:
	str	x19, [x27, 216]
	b	.L1588
.L1854:
	ldr	w0, [x27, 52]
	cbz	w0, .L1565
	ldr	x0, [x27, 216]
	ldr	w0, [x0, 40]
	cmp	w2, w0
	beq	.L1572
.L1725:
	ldr	w0, [x27, 624]
	cmp	w0, 0
	bgt	.L1574
.L1576:
	add	x20, x26, :lo12:.LANCHOR1
	mov	w1, 0
	add	x0, x29, 128
	add	x20, x20, 304
	bl	init_wait_entry
	b	.L1575
.L1870:
	cbnz	x0, .L1577
	bl	schedule
.L1575:
	add	x1, x29, 128
	mov	w2, 1
	mov	x0, x20
	bl	prepare_to_wait_event
	ldr	w1, [x27, 52]
	cbnz	w1, .L1870
	mov	x0, x20
	add	x1, x29, 128
	bl	finish_wait
.L1579:
.L1577:
	ldr	w0, [x27, 624]
	cmp	w0, 0
	ble	.L1572
	ldr	x0, [x27, 96]
	adrp	x1, .LC114
	add	x1, x1, :lo12:.LC114
	bl	_dev_info
	b	.L1572
.L1593:
	cmp	w2, 21
	beq	.L1596
	ble	.L1871
	cmp	w2, 23
	bgt	.L1592
.L1595:
	ldr	w0, [x27, 240]
	str	x19, [x27, 216]
	sub	w1, w0, #1
	cmp	w1, 1
	bls	.L1872
	cmp	w0, 4
	beq	.L1873
.L1607:
	ldr	x0, [x27, 208]
	ldr	w1, [x19, 40]
	ldr	w0, [x0, 40]
	cmp	w1, w0
	beq	.L1601
	ldr	w0, [x27, 52]
	cbz	w0, .L1601
	ldr	w0, [x27, 624]
	cmp	w0, 0
	bgt	.L1609
.L1611:
	add	x20, x26, :lo12:.LANCHOR1
	mov	w1, 0
	add	x0, x29, 128
	add	x20, x20, 304
	bl	init_wait_entry
	b	.L1610
	.p2align 3
.L1874:
	cbnz	x0, .L1612
	bl	schedule
.L1610:
	add	x1, x29, 128
	mov	w2, 1
	mov	x0, x20
	bl	prepare_to_wait_event
	ldr	w1, [x27, 52]
	cbnz	w1, .L1874
.L1613:
	mov	x0, x20
	add	x1, x29, 128
	bl	finish_wait
.L1614:
.L1612:
	ldr	w0, [x27, 624]
	cmp	w0, 0
	ble	.L1615
	ldr	x0, [x27, 96]
	adrp	x1, .LC114
	add	x1, x1, :lo12:.LC114
	bl	_dev_info
.L1615:
	ldr	x0, [x27, 216]
	ldrsw	x2, [x27, 28]
	ldr	x1, [x0, 16]
	ldr	x0, [x27, 136]
	bl	memcpy
	ldr	w0, [x27, 52]
	mov	w1, 3
	str	w1, [x27, 240]
	cbnz	w0, .L1588
.L1876:
	mov	w1, 1
	str	w1, [x27, 52]
	mov	x0, x25
	bl	ebc_power_set
	ldr	w1, [x19, 40]
	mov	w2, 0
	mov	x0, x25
	bl	ebc_lut_update
	ldr	w2, [x27, 104]
	ldr	w0, [x27, 624]
	strb	w2, [x27, 56]
	cmp	w0, 0
	lsr	w0, w2, 8
	strb	w0, [x27, 57]
	ble	.L1616
	ldr	x0, [x27, 96]
	adrp	x1, .LC118
	and	w2, w2, 255
	add	x1, x1, :lo12:.LC118
	bl	_dev_info
.L1616:
	mov	x0, x25
	bl	ebc_frame_start
	b	.L1588
.L1729:
	mov	w20, 0
	b	.L1594
.L1851:
	ldr	w2, [x27, 72]
	cbz	w2, .L1569
	ldr	w0, [x27, 624]
	cmp	w0, 0
	ble	.L1570
	ldr	x0, [x27, 96]
	adrp	x1, .LC111
	add	x1, x1, :lo12:.LC111
	bl	_dev_info
.L1570:
	str	wzr, [x27, 72]
	ldr	w2, [x19, 40]
	b	.L1568
.L1569:
	ldr	x0, [x27, 208]
	ldrsw	x2, [x27, 28]
	ldr	x1, [x0, 16]
	ldr	x0, [x27, 144]
	bl	memcpy
	ldr	x0, [x27, 216]
	ldrsw	x2, [x27, 28]
	ldr	x1, [x0, 16]
	ldr	x0, [x27, 136]
	bl	memcpy
	ldr	w2, [x19, 40]
	b	.L1568
.L1852:
	mov	w1, 1
	str	w1, [x27, 52]
	mov	x0, x25
	bl	ebc_power_set
	ldr	w1, [x19, 40]
	mov	w2, 0
	mov	x0, x25
	bl	ebc_lut_update
	ldr	w3, [x27, 104]
	ldr	w0, [x27, 624]
	strb	w3, [x27, 56]
	cmp	w0, 0
	lsr	w0, w3, 8
	strb	w0, [x27, 57]
	ble	.L1581
	ldr	x0, [x27, 216]
	adrp	x1, .LC115
	and	w3, w3, 255
	add	x1, x1, :lo12:.LC115
	ldr	w2, [x0, 40]
	ldr	x0, [x27, 96]
	bl	_dev_info
.L1581:
	ldr	x0, [x29, 112]
	ldp	x1, x2, [x27, 136]
	ldp	x3, x4, [x27, 160]
	ldr	w0, [x0, 164]
	cbz	w0, .L1582
	ldr	x0, [x27, 176]
	mov	w6, 1
	mov	x5, x27
	bl	get_overlay_image2
.L1583:
	ldr	w0, [x27, 60]
	cbz	w0, .L1584
	ldr	x0, [x29, 112]
	ldp	x1, x2, [x27, 136]
	ldp	x3, x4, [x27, 160]
	ldr	w0, [x0, 164]
	cbz	w0, .L1585
	ldr	x0, [x27, 184]
	mov	w6, 1
	mov	x5, x27
	bl	get_overlay_image2
.L1586:
	ldr	x0, [x29, 112]
	str	wzr, [x0, 72]
	ldr	w1, [x25, 248]
	bl	flip.isra.4
.L1587:
	ldr	x0, [x27, 216]
	ldr	w0, [x0, 40]
	cmp	w0, 0
	sub	w0, w0, #22
	ccmp	w0, 1, 0, ne
	bls	.L1588
	ldr	w0, [x27, 52]
	cbz	w0, .L1588
.L1723:
	ldr	w0, [x27, 624]
	str	wzr, [x27, 588]
	cmp	w0, 0
	ble	.L1590
	ldr	x0, [x27, 96]
	adrp	x1, .LC117
	add	x1, x1, :lo12:.LC117
	bl	_dev_info
.L1590:
	ldrb	w0, [x27, 56]
	add	w0, w0, w0, lsl 1
	lsl	w0, w0, 2
	bl	__msecs_to_jiffies
	adrp	x1, jiffies
	ldr	x1, [x1, #:lo12:jiffies]
	add	x1, x1, x0
	ldr	x0, [x29, 104]
	bl	mod_timer
	b	.L1588
.L1584:
	mov	w0, 1
	str	wzr, [x27, 52]
	str	w0, [x27, 588]
	ldr	w0, [x27, 624]
	cmp	w0, 0
	ble	.L1588
	ldr	x0, [x27, 96]
	adrp	x1, .LANCHOR3
	add	x2, x1, :lo12:.LANCHOR3
	adrp	x1, .LC116
	add	x2, x2, 40
	add	x1, x1, :lo12:.LC116
	bl	_dev_info
	b	.L1587
.L1582:
	ldr	x0, [x27, 176]
	mov	w6, 1
	mov	x5, x27
	bl	get_overlay_image
	b	.L1583
.L1619:
	ldr	x0, [x27, 96]
	adrp	x1, .LC113
	add	x1, x1, :lo12:.LC113
	bl	_dev_info
	ldr	w0, [x27, 52]
	cbz	w0, .L1622
	b	.L1621
	.p2align 3
.L1859:
	ldr	w0, [x27, 608]
	cbz	w0, .L1875
.L1644:
	ldr	w0, [x27, 600]
	cbz	w0, .L1645
	ldr	x0, [x27, 208]
	add	w21, w20, 1
	ldrsw	x2, [x27, 28]
	ldr	x1, [x27, 144]
	ldr	x0, [x0, 16]
	bl	memcpy
	mov	w1, 1
	mov	x0, x25
	bl	ebc_power_set
	str	x19, [x27, 216]
	ldr	w1, [x19, 40]
	cmp	w1, 13
	bne	.L1648
.L1860:
	ldr	w0, [x27, 604]
	cbz	w0, .L1649
	mov	w1, 12
	mov	w2, w20
	mov	x0, x25
	bl	ebc_lut_update
	ldrb	w0, [x27, 104]
	mov	w1, 2
	strb	w1, [x27, 56]
	mov	w1, 7
	lsr	w0, w0, 1
	sub	w0, w0, #1
	cmp	w0, 8
	csel	w0, w1, w0, ge
	str	w0, [x27, 684]
	b	.L1651
	.p2align 3
.L1601:
	ldr	x1, [x19, 16]
	mov	x3, x27
	ldr	x0, [x27, 136]
	ldr	x2, [x27, 160]
	bl	refresh_new_image_auto
	ldr	w0, [x27, 52]
	mov	w1, 3
	str	w1, [x27, 240]
	cbnz	w0, .L1588
	b	.L1876
.L1574:
	ldr	x0, [x27, 96]
	adrp	x1, .LC113
	add	x1, x1, :lo12:.LC113
	bl	_dev_info
	ldr	w0, [x27, 52]
	cbz	w0, .L1577
	b	.L1576
	.p2align 3
.L1861:
	ldr	w0, [x27, 604]
	cbz	w0, .L1649
	mov	w2, w20
	mov	x0, x25
	bl	ebc_lut_update
	ldrb	w0, [x27, 104]
	mov	w1, 43691
	movk	w1, 0xaaaa, lsl 16
	umull	x0, w0, w1
	mov	w1, 3
	strb	w1, [x27, 56]
	mov	w1, 7
	lsr	x0, x0, 33
	sub	w0, w0, #1
	cmp	w0, 8
	csel	w0, w1, w0, ge
	str	w0, [x27, 684]
	b	.L1651
	.p2align 3
.L1731:
	mov	w10, 0
	str	w10, [x27, 600]
	b	.L1877
.L1856:
	ldr	x0, [x27, 208]
	str	wzr, [x27, 600]
	str	wzr, [x27, 608]
	ldrsw	x2, [x27, 28]
	ldr	x1, [x27, 144]
	ldr	x0, [x0, 16]
	bl	memcpy
	b	.L1626
.L1609:
	ldr	x0, [x27, 96]
	adrp	x1, .LC113
	add	x1, x1, :lo12:.LC113
	bl	_dev_info
	ldr	w0, [x27, 52]
	cbz	w0, .L1612
	b	.L1611
	.p2align 3
.L1858:
	ldr	w0, [x27, 612]
	cbz	w0, .L1633
	ldr	w2, [x27, 28]
	mov	w0, 50
	mov	w1, 34079
	ldr	x4, [x19, 16]
	movk	w1, 0x51eb, lsl 16
	cmp	w2, 0
	mul	w0, w2, w0
	smull	x1, w0, w1
	asr	x1, x1, 40
	sub	w1, w1, w0, asr 31
	ldr	x0, [x27, 208]
	ldr	x5, [x0, 16]
	add	w0, w2, 7
	csel	w0, w0, w2, lt
	asr	w0, w0, 3
	cmp	w0, 0
	ble	.L1634
	mov	x2, 0
	mov	w3, 0
	b	.L1637
	.p2align 3
.L1879:
	cmp	w0, w2
	ble	.L1878
.L1637:
	ldr	x7, [x4, x2, lsl 3]
	ldr	x6, [x5, x2, lsl 3]
	add	x2, x2, 1
	cmp	x7, x6
	cinc	w3, w3, ne
	cmp	w1, w3
	bge	.L1879
	ldr	w0, [x27, 624]
	mov	w20, 1
	cmp	w0, 0
	ble	.L1629
	ldr	x0, [x27, 96]
	adrp	x1, .LC120
	mov	w20, 1
	add	x1, x1, :lo12:.LC120
	bl	_dev_info
	b	.L1629
	.p2align 3
.L1862:
	mov	w1, 12
	mov	w2, w20
	mov	x0, x25
	bl	ebc_lut_update
	ldrb	w0, [x27, 104]
	mov	w1, 4
	strb	w1, [x27, 56]
	mov	w1, 7
	lsr	w0, w0, 2
	sub	w0, w0, #1
	cmp	w0, 8
	csel	w0, w1, w0, ge
	str	w0, [x27, 684]
	b	.L1651
.L1585:
	ldr	x0, [x27, 184]
	mov	w6, 1
	mov	x5, x27
	bl	get_overlay_image
	b	.L1586
.L1871:
	cmp	w2, 17
	bne	.L1592
	b	.L1596
	.p2align 3
.L1873:
	ldr	w0, [x27, 52]
	cbz	w0, .L1601
	ldr	w0, [x27, 624]
	cmp	w0, 0
	bgt	.L1602
.L1604:
	add	x20, x26, :lo12:.LANCHOR1
	mov	w1, 0
	add	x0, x29, 128
	add	x20, x20, 304
	bl	init_wait_entry
	add	x1, x29, 128
	mov	w2, 1
	mov	x0, x20
	bl	prepare_to_wait_event
	ldr	w1, [x27, 52]
	cbz	w1, .L1613
.L1880:
	cbnz	x0, .L1612
	bl	schedule
	add	x1, x29, 128
	mov	w2, 1
	mov	x0, x20
	bl	prepare_to_wait_event
	ldr	w1, [x27, 52]
	cbnz	w1, .L1880
	b	.L1613
	.p2align 3
.L1872:
	ldr	x0, [x27, 208]
	ldrsw	x2, [x27, 28]
	ldr	x1, [x0, 16]
	ldr	x0, [x27, 144]
	bl	memcpy
	b	.L1615
.L1645:
	ldr	x0, [x27, 208]
	ldrsw	x2, [x27, 28]
	ldr	x1, [x0, 16]
	ldr	x0, [x27, 144]
	bl	memcpy
	b	.L1646
.L1878:
	cbz	w3, .L1634
	b	.L1629
.L1633:
	ldr	x0, [x27, 208]
	ldr	w1, [x25, 244]
	ldr	x2, [x19, 16]
	cmp	w1, 0
	ldr	x3, [x0, 16]
	add	w0, w1, 7
	csel	w0, w0, w1, lt
	asr	w0, w0, 3
	cmp	w0, 0
	ble	.L1634
	ldr	x1, [x2]
	ldr	x4, [x3]
	cmp	x4, x1
	bne	.L1629
	sub	w0, w0, #1
	mov	x1, 8
	add	x0, x0, 1
	lsl	x0, x0, 3
	b	.L1639
	.p2align 3
.L1640:
	ldr	x5, [x2, x1]
	add	x1, x1, 8
	add	x4, x3, x1
	ldr	x4, [x4, -8]
	cmp	x5, x4
	bne	.L1629
.L1639:
	cmp	x0, x1
	bne	.L1640
	b	.L1634
.L1602:
	ldr	x0, [x27, 96]
	adrp	x1, .LC113
	add	x1, x1, :lo12:.LC113
	bl	_dev_info
	ldr	w0, [x27, 52]
	cbz	w0, .L1612
	b	.L1604
.L1875:
	ldrsw	x2, [x27, 28]
	mov	w1, 216
	ldr	x0, [x27, 152]
	bl	memset
	mov	w0, 1
	str	w0, [x27, 608]
	b	.L1644
.L1711:
	bl	ebc_get_dsp_list_enum_num
	cbnz	w0, .L1510
	bl	ebc_get_osd_list_enum_num
	cbnz	w0, .L1510
.L1832:
	mov	w1, 0
	mov	x0, x25
	bl	ebc_power_set
	b	.L1715
.L1717:
	mov	x0, x19
	add	x1, x29, 128
	bl	finish_wait
	str	wzr, [x27, 88]
	b	.L1510
.L1868:
	ldr	w0, [x27, 624]
	cmp	w0, 0
	ble	.L1678
	ldr	x0, [x27, 96]
	adrp	x1, .LC126
	add	x1, x1, :lo12:.LC126
	bl	_dev_info
.L1678:
	ldr	w0, [x27, 608]
	cbz	w0, .L1679
	ldr	x0, [x27, 216]
	ldr	w1, [x27, 80]
	ldr	x2, [x27, 152]
	ldr	x3, [x0, 16]
	ldr	w0, [x27, 84]
	bl	update_repair_buf_ghost
.L1679:
	ldr	x0, [x27, 216]
	ldr	w2, [x27, 28]
	ldr	x1, [x27, 152]
	cmp	w2, 0
	ldr	x5, [x0, 16]
	ble	.L1680
	mov	x0, 0
	b	.L1683
	.p2align 3
.L1681:
	cmp	w4, 216
	bne	.L1682
	strb	w3, [x1, x0]
.L1682:
	add	x0, x0, 1
	cmp	w2, w0
	ble	.L1881
.L1683:
	ldrb	w4, [x1, x0]
	ldrb	w3, [x5, x0]
	cmp	w4, 24
	bne	.L1681
	mvn	w3, w3
	and	w3, w3, -16
	strb	w3, [x1, x0]
	add	x0, x0, 1
	cmp	w2, w0
	bgt	.L1683
.L1881:
	ldr	w2, [x27, 28]
	ldr	x1, [x27, 152]
.L1680:
	ldr	x0, [x27, 144]
	sxtw	x2, w2
	bl	memcpy
	ldr	x0, [x27, 216]
	ldrsw	x2, [x27, 28]
	ldr	x1, [x0, 16]
	ldr	x0, [x27, 136]
	bl	memcpy
	str	wzr, [x27, 600]
	adrp	x0, jiffies
	str	wzr, [x27, 608]
	ldr	x1, [x0, #:lo12:jiffies]
	mov	x0, 402653184
	add	x1, x1, x0
	ldr	x0, [x29, 120]
	bl	mod_timer
	b	.L1882
	.size	ebc_thread, .-ebc_thread
	.align	2
	.p2align 3,,7
	.type	ebc_auto_tast_function, %function
ebc_auto_tast_function:
	stp	x29, x30, [sp, -112]!
	adrp	x0, __stack_chk_guard
	add	x0, x0, :lo12:__stack_chk_guard
	add	x29, sp, 0
	stp	x25, x26, [sp, 64]
	adrp	x26, .LANCHOR0
	stp	x19, x20, [sp, 16]
	mov	x25, 2
	stp	x21, x22, [sp, 32]
	stp	x23, x24, [sp, 48]
	adrp	x23, .LANCHOR1
	stp	x27, x28, [sp, 80]
	add	x23, x23, :lo12:.LANCHOR1
	ldr	x22, [x26, #:lo12:.LANCHOR0]
	add	x21, x23, 776
	ldr	x1, [x0]
	str	x1, [x29, 104]
	mov	x1,0
	add	x23, x23, 352
	add	x20, x22, 40
	add	x19, x22, 216
	add	x28, x22, 736
	adrp	x27, jiffies
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x24, sp_el0
// 0 "" 2
#NO_APP
	b	.L1910
	.p2align 3
.L1920:
	cmp	w0, 4
	beq	.L1886
	cmp	w0, 1
	beq	.L1918
	ldr	x0, [x19, 216]
	ldr	w0, [x0, 40]
	cmp	w0, 21
	beq	.L1919
	ldr	w1, [x19, 72]
	mov	x0, x20
	sub	w1, w1, #1
	str	w1, [x19, 72]
	ldr	w1, [x22, 248]
	bl	flip.isra.4
	add	x0, x26, :lo12:.LANCHOR0
	ldr	x0, [x0, 16]
	bl	wake_up_process
	ldr	w4, [x19, 72]
	cbz	w4, .L1892
	ldr	w0, [x20, 164]
	cbz	w0, .L1909
	ldrsw	x0, [x20, 72]
	mov	w6, 2
	ldp	x2, x1, [x19, 208]
	add	x0, x0, 22
	ldrb	w3, [x22, 272]
	ldr	x5, [x22, 336]
	ldr	x0, [x19, x0, lsl 3]
	ldr	x1, [x1, 16]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change2.isra.3
	.p2align 2
.L1892:
	mov	x0, x21
	bl	up
	bl	schedule
.L1910:
	mov	x0, x21
	bl	down
	mov	x0, x23
	bl	down
	str	x25, [x24, 32]
#APP
// 2114 "/home/lyx/rk3566-11-eink/kernel/drivers/gpu/drm/rockchip/ebc-dev/ebc_dev_y8.c" 1
	dmb ish
// 0 "" 2
#NO_APP
	ldr	w0, [x19, 240]
	cmp	w0, 3
	bne	.L1920
	ldr	w0, [x19, 60]
	str	wzr, [x19, 68]
	cbnz	w0, .L1897
	ldr	w0, [x19, 64]
	cbz	w0, .L1898
.L1897:
	ldr	w1, [x22, 248]
	mov	x0, x20
	bl	flip.isra.4
	add	x0, x26, :lo12:.LANCHOR0
	ldr	x0, [x0, 16]
	bl	wake_up_process
	ldr	w0, [x20, 164]
	cbz	w0, .L1899
	ldrsw	x0, [x20, 72]
	mov	w5, 2
	ldp	x1, x2, [x19, 136]
	add	x0, x0, 22
	ldr	x3, [x19, 160]
	mov	x4, x19
	ldr	x0, [x19, x0, lsl 3]
	bl	get_auto_image2
	b	.L1892
	.p2align 3
.L1918:
	ldr	w1, [x19, 72]
	mov	x0, x20
	sub	w1, w1, #1
	str	w1, [x19, 72]
	ldr	w1, [x22, 248]
	bl	flip.isra.4
	add	x0, x26, :lo12:.LANCHOR0
	ldr	x0, [x0, 16]
	bl	wake_up_process
	ldr	w4, [x19, 72]
	cbz	w4, .L1892
	ldr	w0, [x20, 164]
	cbz	w0, .L1904
	ldrsw	x0, [x20, 72]
	mov	w6, 2
	ldp	x2, x1, [x19, 208]
	add	x0, x0, 22
	ldrb	w3, [x22, 272]
	ldr	x5, [x22, 336]
	ldr	x0, [x19, x0, lsl 3]
	ldr	x1, [x1, 16]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change_part2.isra.8
	b	.L1892
	.p2align 3
.L1886:
	ldr	w0, [x19, 76]
	cbz	w0, .L1888
	ldr	w0, [x19, 60]
	str	wzr, [x19, 68]
	str	wzr, [x19, 76]
	cbnz	w0, .L1889
	ldr	w0, [x19, 64]
	cbz	w0, .L1890
.L1889:
	ldr	w1, [x22, 248]
	mov	x0, x20
	bl	flip.isra.4
	add	x0, x26, :lo12:.LANCHOR0
	ldr	x0, [x0, 16]
	bl	wake_up_process
	ldr	w0, [x20, 164]
	cbz	w0, .L1891
	ldrsw	x0, [x20, 72]
	mov	w6, 2
	ldp	x1, x2, [x19, 136]
	add	x0, x0, 22
	ldp	x3, x4, [x19, 160]
	mov	x5, x19
	ldr	x0, [x19, x0, lsl 3]
	bl	get_overlay_image2
	b	.L1892
	.p2align 3
.L1899:
	ldrsw	x0, [x20, 72]
	mov	w5, 2
	ldp	x1, x2, [x19, 136]
	add	x0, x0, 22
	ldr	x3, [x19, 160]
	mov	x4, x19
	ldr	x0, [x19, x0, lsl 3]
	bl	get_auto_image
	b	.L1892
	.p2align 3
.L1888:
	mov	x0, x23
	bl	up
	ldr	w0, [x20, 164]
	cbz	w0, .L1896
	ldrsw	x0, [x20, 72]
	mov	x4, x19
	ldp	x1, x2, [x19, 136]
	add	x0, x0, 22
	ldr	x3, [x19, 160]
	ldr	x0, [x19, x0, lsl 3]
	bl	get_overlay_image_area2.isra.0
	b	.L1892
	.p2align 3
.L1891:
	ldrsw	x0, [x20, 72]
	mov	w6, 2
	ldp	x1, x2, [x19, 136]
	add	x0, x0, 22
	ldp	x3, x4, [x19, 160]
	mov	x5, x19
	ldr	x0, [x19, x0, lsl 3]
	bl	get_overlay_image
	b	.L1892
	.p2align 3
.L1919:
	ldr	w2, [x19, 672]
	mov	x0, x20
	ldr	w1, [x19, 676]
	add	w1, w1, w2
	str	w1, [x19, 676]
	ldr	w1, [x22, 248]
	bl	flip.isra.4
	add	x0, x26, :lo12:.LANCHOR0
	ldr	x0, [x0, 16]
	bl	wake_up_process
	ldrb	w0, [x19, 56]
	ldr	w2, [x19, 84]
	ldr	w3, [x19, 672]
	ldr	w1, [x19, 676]
	madd	w0, w0, w3, w2
	cmp	w1, w0
	blt	.L1906
	mov	w0, 1
	str	w0, [x19, 680]
	b	.L1892
	.p2align 3
.L1904:
	ldrsw	x0, [x20, 72]
	mov	w6, 2
	ldp	x2, x1, [x19, 208]
	add	x0, x0, 22
	ldrb	w3, [x22, 272]
	ldr	x5, [x22, 336]
	ldr	x0, [x19, x0, lsl 3]
	ldr	x1, [x1, 16]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change_part.isra.9
	b	.L1892
	.p2align 3
.L1898:
	mov	x0, x23
	bl	up
	ldr	w0, [x19, 596]
	cbz	w0, .L1921
.L1900:
	ldr	w0, [x20, 164]
	cbz	w0, .L1901
	ldrsw	x0, [x20, 72]
	mov	w5, 1
	ldp	x1, x2, [x19, 136]
	add	x0, x0, 22
	ldr	x3, [x19, 160]
	mov	x4, x19
	ldr	x0, [x19, x0, lsl 3]
	bl	get_auto_image2
.L1902:
	mov	w0, 1
	ldr	x1, [x27, #:lo12:jiffies]
	str	w0, [x19, 68]
	mov	x0, x28
	add	x1, x1, 1
	bl	mod_timer
	b	.L1892
	.p2align 3
.L1909:
	ldrsw	x0, [x20, 72]
	mov	w6, 2
	ldp	x2, x1, [x19, 208]
	add	x0, x0, 22
	ldrb	w3, [x22, 272]
	ldr	x5, [x22, 336]
	ldr	x0, [x19, x0, lsl 3]
	ldr	x1, [x1, 16]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change.isra.2
	b	.L1892
	.p2align 3
.L1890:
	mov	x0, x23
	bl	up
	ldr	w0, [x19, 596]
	cbz	w0, .L1922
.L1893:
	ldr	w0, [x20, 164]
	cbz	w0, .L1894
	ldrsw	x0, [x20, 72]
	mov	w6, 1
	ldp	x1, x2, [x19, 136]
	add	x0, x0, 22
	ldp	x3, x4, [x19, 160]
	mov	x5, x19
	ldr	x0, [x19, x0, lsl 3]
	bl	get_overlay_image2
	b	.L1902
	.p2align 3
.L1896:
	ldrsw	x0, [x20, 72]
	mov	x5, x19
	ldp	x1, x2, [x19, 136]
	add	x0, x0, 22
	ldp	x3, x4, [x19, 160]
	ldr	x0, [x19, x0, lsl 3]
	bl	get_overlay_image_area
	b	.L1892
	.p2align 3
.L1906:
	ldr	w0, [x20, 164]
	cbz	w0, .L1907
	ldrsw	x0, [x20, 72]
	mov	w4, 2
	ldp	x2, x1, [x19, 208]
	add	x0, x0, 22
	mov	x3, x19
	ldr	x0, [x19, x0, lsl 3]
	ldr	x1, [x1, 16]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change_full2
	b	.L1892
	.p2align 3
.L1901:
	ldrsw	x0, [x20, 72]
	mov	w5, 1
	ldp	x1, x2, [x19, 136]
	add	x0, x0, 22
	ldr	x3, [x19, 160]
	mov	x4, x19
	ldr	x0, [x19, x0, lsl 3]
	bl	get_auto_image
	b	.L1902
	.p2align 3
.L1894:
	ldrsw	x0, [x20, 72]
	mov	w6, 1
	ldp	x1, x2, [x19, 136]
	add	x0, x0, 22
	ldp	x3, x4, [x19, 160]
	mov	x5, x19
	ldr	x0, [x19, x0, lsl 3]
	bl	get_overlay_image
	b	.L1902
	.p2align 3
.L1907:
	ldrsw	x0, [x20, 72]
	mov	w4, 2
	ldp	x2, x1, [x19, 208]
	add	x0, x0, 22
	mov	x3, x19
	ldr	x0, [x19, x0, lsl 3]
	ldr	x1, [x1, 16]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change_full
	b	.L1892
	.p2align 3
.L1921:
	ldr	x1, [x19, 216]
	mov	x3, x19
	ldr	x0, [x19, 136]
	ldr	x2, [x19, 160]
	ldr	x1, [x1, 16]
	bl	refresh_new_image_auto
	b	.L1900
	.p2align 3
.L1922:
	ldr	x2, [x19, 216]
	mov	x5, x19
	ldr	x1, [x19, 16]
	ldr	x0, [x19, 136]
	ldp	x3, x4, [x19, 160]
	ldr	x2, [x2, 16]
	bl	refresh_new_image
	b	.L1893
	.size	ebc_auto_tast_function, .-ebc_auto_tast_function
	.data
	.align	3
	.set	.LANCHOR1,. + 0
	.type	ebc_driver, %object
	.size	ebc_driver, 224
ebc_driver:
	.xword	ebc_probe
	.xword	ebc_remove
	.zero	24
	.xword	.LC130
	.zero	32
	.xword	ebc_match
	.zero	64
	.xword	ebc_pm
	.zero	48
	.zero	16
	.type	ebc_misc, %object
	.size	ebc_misc, 80
ebc_misc:
	.word	243
	.zero	4
	.xword	.LC78
	.xword	ebc_ops
	.zero	56
	.type	ebc_thread_wq, %object
	.size	ebc_thread_wq, 24
ebc_thread_wq:
	.word	0
	.zero	4
	.xword	ebc_thread_wq+8
	.xword	ebc_thread_wq+8
	.type	ebc_auto_assist_thread_sem, %object
	.size	ebc_auto_assist_thread_sem, 24
ebc_auto_assist_thread_sem:
	.word	0
	.word	1
	.xword	ebc_auto_assist_thread_sem+8
	.xword	ebc_auto_assist_thread_sem+8
	.type	ebc_assist_finished_flag_sem, %object
	.size	ebc_assist_finished_flag_sem, 24
ebc_assist_finished_flag_sem:
	.word	0
	.word	1
	.xword	ebc_assist_finished_flag_sem+8
	.xword	ebc_assist_finished_flag_sem+8
	.type	waveform_misc, %object
	.size	waveform_misc, 80
waveform_misc:
	.word	244
	.zero	4
	.xword	.LC141
	.xword	waveform_ops
	.zero	56
	.type	dev_attr_waveform_version, %object
	.size	dev_attr_waveform_version, 32
dev_attr_waveform_version:
	.xword	.LC140
	.hword	292
	.zero	6
	.xword	waveform_version_read
	.xword	0
	.type	dev_attr_pmic_name, %object
	.size	dev_attr_pmic_name, 32
dev_attr_pmic_name:
	.xword	.LC139
	.hword	292
	.zero	6
	.xword	pmic_name_read
	.xword	0
	.type	dev_attr_pmic_temp, %object
	.size	dev_attr_pmic_temp, 32
dev_attr_pmic_temp:
	.xword	.LC138
	.hword	292
	.zero	6
	.xword	pmic_temp_read
	.xword	0
	.type	dev_attr_pmic_vcom, %object
	.size	dev_attr_pmic_vcom, 32
dev_attr_pmic_vcom:
	.xword	.LC137
	.hword	420
	.zero	6
	.xword	pmic_vcom_read
	.xword	pmic_vcom_write
	.type	dev_attr_ebc_version, %object
	.size	dev_attr_ebc_version, 32
dev_attr_ebc_version:
	.xword	.LC135
	.hword	292
	.zero	6
	.xword	ebc_version_read
	.xword	0
	.type	dev_attr_ebc_state, %object
	.size	dev_attr_ebc_state, 32
dev_attr_ebc_state:
	.xword	.LC134
	.hword	292
	.zero	6
	.xword	ebc_state_read
	.xword	0
	.type	dev_attr_ebc_buf_state, %object
	.size	dev_attr_ebc_buf_state, 32
dev_attr_ebc_buf_state:
	.xword	.LC133
	.hword	292
	.zero	6
	.xword	ebc_buf_state_read
	.xword	0
	.type	dev_attr_auto_frame_state, %object
	.size	dev_attr_auto_frame_state, 32
dev_attr_auto_frame_state:
	.xword	.LC132
	.hword	292
	.zero	6
	.xword	auto_frame_state_read
	.xword	0
	.type	dev_attr_ebc_debug_level, %object
	.size	dev_attr_ebc_debug_level, 32
dev_attr_ebc_debug_level:
	.xword	.LC136
	.hword	420
	.zero	6
	.xword	ebc_debug_level_read
	.xword	ebc_debug_level_write
	.type	dev_attr_wf_data, %object
	.size	dev_attr_wf_data, 32
dev_attr_wf_data:
	.xword	.LC131
	.hword	128
	.zero	6
	.xword	0
	.xword	wf_data_write
	.type	ebc_auto_thread_sem, %object
	.size	ebc_auto_thread_sem, 24
ebc_auto_thread_sem:
	.word	0
	.word	1
	.xword	ebc_auto_thread_sem+8
	.xword	ebc_auto_thread_sem+8
	.bss
	.align	3
	.set	.LANCHOR0,. + 0
	.type	global_ebc, %object
	.size	global_ebc, 8
global_ebc:
	.zero	8
	.type	ebc_auto_task, %object
	.size	ebc_auto_task, 8
ebc_auto_task:
	.zero	8
	.type	ebc_auto_assist_task, %object
	.size	ebc_auto_assist_task, 8
ebc_auto_assist_task:
	.zero	8
	.type	ebc_task, %object
	.size	ebc_task, 8
ebc_task:
	.zero	8
	.section	.rodata
	.align	3
	.set	.LANCHOR2,. + 0
	.type	__func__.42371, %object
	.size	__func__.42371, 11
__func__.42371:
	.string	"ebc_io_ctl"
	.align	3
	.set	.LANCHOR3,. + 0
	.type	__func__.42740, %object
	.size	__func__.42740, 19
__func__.42740:
	.string	"ebc_lut_table_init"
	.zero	5
	.type	__func__.42015, %object
	.size	__func__.42015, 16
__func__.42015:
	.string	"ebc_frame_start"
	.type	__func__.42008, %object
	.size	__func__.42008, 27
__func__.42008:
	.string	"ebc_overlay_bg_frame_start"
	.zero	5
	.type	ebc_match, %object
	.size	ebc_match, 400
ebc_match:
	.zero	64
	.string	"rockchip,ebc-dev"
	.zero	111
	.zero	8
	.zero	200
	.type	ebc_pm, %object
	.size	ebc_pm, 184
ebc_pm:
	.zero	16
	.xword	ebc_suspend
	.xword	ebc_resume
	.zero	152
	.type	waveform_ops, %object
	.size	waveform_ops, 288
waveform_ops:
	.xword	0
	.zero	80
	.xword	waveform_mmap
	.zero	8
	.xword	waveform_open
	.zero	176
	.type	ebc_ops, %object
	.size	ebc_ops, 288
ebc_ops:
	.xword	0
	.zero	64
	.xword	ebc_io_ctl
	.xword	ebc_io_ctl
	.xword	ebc_mmap
	.zero	8
	.xword	ebc_open
	.zero	8
	.xword	ebc_release
	.zero	160
	.section	.discard.addressable,"aw",@progbits
	.align	3
	.type	__addressable_ebc_init4259, %object
	.size	__addressable_ebc_init4259, 8
__addressable_ebc_init4259:
	.xword	ebc_init
	.section	.exitcall.exit,"aw",@progbits
	.align	3
	.type	__exitcall_ebc_exit, %object
	.size	__exitcall_ebc_exit, 8
__exitcall_ebc_exit:
	.xword	ebc_exit
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align	3
.LC0:
	.string	"device resume\n"
	.zero	1
.LC1:
	.string	"ebc_frame_control_timeout, overlay_bg_update=1\n"
.LC2:
	.string	"ebc hw power on res:%d\n"
.LC3:
	.string	"ebc hw power off res:%d\n"
	.zero	7
.LC4:
	.string	"device suspend\n"
.LC5:
	.string	"%s: argp NULL\n"
	.zero	1
.LC6:
	.string	"enable bg control\n"
	.zero	5
.LC7:
	.string	"disable bg control\n"
	.zero	4
.LC8:
	.string	"enable ebc overlay, you can use osd buf to show something over the system display\n"
	.zero	5
.LC9:
	.string	"disable ebc overlay\n"
	.zero	3
.LC10:
	.string	"EBC_GET_BUFFER_INFO failed\n"
	.zero	4
.LC11:
	.string	"EBC_FB_BLANK\n"
	.zero	2
.LC12:
	.string	"EBC_FB_UNBLANK\n"
.LC13:
	.string	"EBC_ENABLE_REPAIR = %d\n"
.LC14:
	.string	"EBC_SET_FULL_REFRESH_WIDTH = %d\n"
	.zero	7
.LC15:
	.string	"%s: unknown cmd\n"
	.zero	7
.LC16:
	.string	"overlay frame done\n"
	.zero	4
.LC17:
	.string	"auto task break\n"
	.zero	7
.LC18:
	.string	"auto frame done\n"
	.zero	7
.LC19:
	.string	"part task break\n"
	.zero	7
.LC20:
	.string	"frame done\n"
	.zero	4
.LC21:
	.string	"too large resolution, not support\n"
	.zero	5
.LC22:
	.string	"memory-region"
	.zero	2
.LC23:
	.string	"Couldn't address to resource for reserved memory\n"
	.zero	6
.LC24:
	.string	"reserved memory not enough, need 0x%x\n"
	.zero	1
.LC25:
	.string	"Couldn't remap for reserved memory\n"
	.zero	4
.LC26:
	.string	"waveform-region"
.LC27:
	.string	"wf,mode_table"
	.zero	2
.LC28:
	.string	"%s:%d: failed to get mem from reserved\n"
.LC29:
	.string	"Failed to read waveform from mem, we use waveform file from kernel file instead\n"
	.zero	7
.LC30:
	.string	"Failed to read waveform file from kernel, no waveform!!!\n"
	.zero	6
.LC31:
	.string	"temperature = %d, out of range0~50 ,use 25 \n"
	.zero	3
.LC32:
	.string	"temperature = %d, out of range0~50 ,use 50 \n"
	.zero	3
.LC33:
	.string	"ebc_pmic_read_temp failed, ret = %d, use 25 \n"
	.zero	2
.LC34:
	.string	"lut update use temperature = %d\n"
	.zero	7
.LC35:
	.string	"get lut data failed\n"
	.zero	3
.LC36:
	.string	"603893"
	.zero	1
.LC37:
	.string	"lutdata: %d frames\n"
	.zero	4
.LC38:
	.string	"[%d-->%d]: \n"
	.zero	3
.LC39:
	.string	"\001c\0017%d, "
	.zero	7
.LC40:
	.string	"invalid value = %s\n"
	.zero	4
.LC41:
	.string	"%d\n"
	.zero	4
.LC42:
	.string	"7.03_y8"
.LC43:
	.string	"%s\n"
	.zero	4
.LC44:
	.string	"set vcom value failed\n"
	.zero	1
.LC45:
	.string	"%s: overlay no need to update\n"
	.zero	1
.LC46:
	.string	"%s: auto no need to update\n"
	.zero	4
.LC47:
	.string	"cpu-code"
	.zero	7
.LC48:
	.string	"ebc_tcon"
	.zero	7
.LC49:
	.string	"not find ebc tcon\n"
	.zero	5
.LC50:
	.string	"pmic"
	.zero	3
.LC51:
	.string	"Get PMIC deivce failed\n"
.LC52:
	.string	"wrong pmics number\n"
	.zero	4
.LC53:
	.string	"not find pmic node\n"
	.zero	4
.LC54:
	.string	"not find pmic i2c client\n"
	.zero	6
.LC55:
	.string	"use pmic%d\n"
	.zero	4
.LC56:
	.string	"vcom"
	.zero	3
.LC57:
	.string	"Failed to get vcom regulator\n"
	.zero	2
.LC58:
	.string	"thermal-zone"
	.zero	3
.LC59:
	.string	"Failed to get thermal zone name\n"
	.zero	7
.LC60:
	.string	"Failed to get thermal device\n"
	.zero	2
.LC61:
	.string	"ebc-dmc-notify-enable"
	.zero	2
.LC62:
	.string	"panel,width"
	.zero	4
.LC63:
	.string	"panel,panel_color"
	.zero	6
.LC64:
	.string	"panel,mirror"
	.zero	3
.LC65:
	.string	"panel,width-mm"
	.zero	1
.LC66:
	.string	"panel,height-mm"
.LC67:
	.string	"panel,disable_logo"
	.zero	5
.LC68:
	.string	"panel,rearrange"
.LC69:
	.string	"panel,sdoe_mode"
.LC70:
	.string	"panel,sdce_width"
	.zero	7
.LC71:
	.string	"buffer manage init failed\n"
	.zero	5
.LC72:
	.string	"lut table init failed\n"
	.zero	1
.LC73:
	.string	"ebc_task"
	.zero	7
.LC74:
	.string	"failed to create ebc_task thread\n"
	.zero	6
.LC75:
	.string	"ebc_taskup"
	.zero	5
.LC76:
	.string	"failed to create ebc_taskup thread\n"
	.zero	4
.LC77:
	.string	"ebc_thread"
	.zero	5
.LC78:
	.string	"ebc"
	.zero	4
.LC79:
	.string	"ulogo_addr="
	.zero	4
.LC80:
	.string	"klogo_addr="
	.zero	4
.LC81:
	.string	"ulogo_addr=0x%x"
.LC82:
	.string	"have ulogo display, ulogo addr = 0x%x\n"
	.zero	1
.LC83:
	.string	"malloc ulogo buffer failed\n"
	.zero	4
.LC84:
	.string	"klogo_addr=0x%x"
.LC85:
	.string	"need show klogo, klogo addr = 0x%x\n"
	.zero	4
.LC86:
	.string	"malloc klogo buffer failed\n"
	.zero	4
.LC87:
	.string	"no uboot logo, panel init\n"
	.zero	5
.LC88:
	.string	"ebc_dev_reset"
	.zero	2
.LC89:
	.string	"ebc_dev_logo"
	.zero	3
.LC90:
	.string	"rockchip ebc driver %s probe success\n"
	.zero	2
.LC91:
	.string	"panel,height"
	.zero	3
.LC92:
	.string	"panel,vir_width"
.LC93:
	.string	"panel,vir_height"
	.zero	7
.LC94:
	.string	"panel,sdck"
	.zero	5
.LC95:
	.string	"panel,lsl"
	.zero	6
.LC96:
	.string	"panel,lbl"
	.zero	6
.LC97:
	.string	"panel,ldl"
	.zero	6
.LC98:
	.string	"panel,lel"
	.zero	6
.LC99:
	.string	"panel,gdck-sta"
	.zero	1
.LC100:
	.string	"panel,lgonl"
	.zero	4
.LC101:
	.string	"panel,fsl"
	.zero	6
.LC102:
	.string	"panel,fbl"
	.zero	6
.LC103:
	.string	"panel,fdl"
	.zero	6
.LC104:
	.string	"panel,fel"
	.zero	6
.LC105:
	.string	"panel,panel_16bit"
	.zero	6
.LC106:
	.string	"failed to run ebc thread\n"
	.zero	6
.LC107:
	.string	"task init failed\n"
	.zero	6
.LC108:
	.string	"failed to probe panel: %d\n"
	.zero	5
.LC109:
	.string	"0\n"
	.zero	5
.LC110:
	.string	"ebc suspend, drop osd buf\n"
	.zero	5
.LC111:
	.string	"break from part work, frame left = %d\n"
	.zero	1
.LC112:
	.string	"overlay mode start, frame_total=%d, bw_frame = %d\n"
	.zero	5
.LC113:
	.string	"ebc is busy now, waiting prev mode end...\n"
	.zero	5
.LC114:
	.string	"prev refresh mode end\n"
	.zero	1
.LC115:
	.string	"frame start under overlay, mode = %d, framecount = %d\n"
	.zero	1
.LC116:
	.string	"%s: overlay bg no need to update, overlay_bg_update=1\n"
	.zero	1
.LC117:
	.string	"control bg update under overlay mode, overlay_bg_update=0\n"
	.zero	5
.LC118:
	.string	"auto mode start, frame_total=%d\n"
	.zero	7
.LC119:
	.string	"check_part_mode==0, no need refresh\n"
	.zero	3
.LC120:
	.string	"check_diff_percent==2, full refresh\n"
	.zero	3
.LC121:
	.string	"frame start, mode = %d, framecount = %d\n"
	.zero	7
.LC122:
	.string	"update repair buf\n"
	.zero	5
.LC123:
	.string	"waiting frame done\n"
	.zero	4
.LC124:
	.string	"----update repair buf timeout----\n"
	.zero	5
.LC125:
	.string	"break from part work, do something before turn to overlay work\n"
.LC126:
	.string	"quick mode repair buf\n"
	.zero	1
.LC127:
	.string	"no buffer, do repair..........\n"
.LC128:
	.string	"no buffer, do ghost remove..........\n"
	.zero	2
.LC129:
	.string	"ebc buffer mode %d error!!!\n"
	.zero	3
.LC130:
	.string	"ebc-dev"
.LC131:
	.string	"wf_data"
.LC132:
	.string	"auto_frame_state"
	.zero	7
.LC133:
	.string	"ebc_buf_state"
	.zero	2
.LC134:
	.string	"ebc_state"
	.zero	6
.LC135:
	.string	"ebc_version"
	.zero	4
.LC136:
	.string	"ebc_debug_level"
.LC137:
	.string	"pmic_vcom"
	.zero	6
.LC138:
	.string	"pmic_temp"
	.zero	6
.LC139:
	.string	"pmic_name"
	.zero	6
.LC140:
	.string	"waveform_version"
	.zero	7
.LC141:
	.string	"waveform"
	.ident	"GCC: (Linaro GCC 6.3-2017.05) 6.3.1 20170404"
	.section	.note.GNU-stack,"",@progbits

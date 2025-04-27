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
	cbz	x0, .L121
	ldr	x1, [x0, 48]
	blr	x1
.L121:
	ldr	x0, [x19, 320]
	adrp	x1, .LC0
	str	wzr, [x19, 804]
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
	ldr	w1, [x0, 848]
	str	w2, [x0, 812]
	cmp	w1, 0
	ble	.L129
	add	x0, x0, 224
	stp	x29, x30, [sp, -16]!
	adrp	x1, .LC1
	add	x1, x1, :lo12:.LC1
	add	x29, sp, 0
	ldr	x0, [x0, 96]
	bl	_dev_info
	ldp	x29, x30, [sp], 16
	ret
	.p2align 3
.L129:
	ret
	.size	ebc_frame_control_timeout, .-ebc_frame_control_timeout
	.align	2
	.p2align 3,,7
	.type	ebc_power_set, %function
ebc_power_set:
	stp	x29, x30, [sp, -48]!
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	add	x19, x0, 224
	str	x21, [sp, 32]
	ldr	w2, [x19, 192]
	cmp	w2, w1
	beq	.L134
	mov	x20, x0
	mov	w21, w1
	cmp	w1, 1
	ldr	w0, [x19, 620]
	beq	.L155
	cbnz	w0, .L156
	str	w21, [x19, 192]
	ldr	x1, [x20, 8]
	mov	x0, x1
	ldr	x1, [x1, 80]
	blr	x1
	ldr	x0, [x20, 16]
	cbz	x0, .L142
.L160:
	ldr	x2, [x0, 32]
	mov	w1, 0
	mov	w21, 0
	blr	x2
.L143:
	ldr	w0, [x19, 456]
	cbnz	w0, .L157
.L144:
	ldr	w0, [x19, 624]
	cmp	w0, 0
	ble	.L134
	ldr	x0, [x19, 96]
	adrp	x1, .LC3
	mov	w2, w21
	add	x1, x1, :lo12:.LC3
	bl	_dev_info
.L134:
	mov	w0, 0
	ldr	x21, [sp, 32]
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 48
	ret
	.p2align 3
.L155:
	cbnz	w0, .L158
.L136:
	ldr	w0, [x19, 456]
	cbz	w0, .L159
.L137:
	mov	w1, 1
	str	w1, [x19, 192]
	ldr	x0, [x20, 16]
	cbz	x0, .L138
	ldr	x2, [x0, 32]
	mov	w21, 0
	blr	x2
.L139:
	ldr	x2, [x20, 8]
	add	x1, x20, 40
	mov	x0, x2
	ldr	x2, [x2, 72]
	blr	x2
	ldr	w0, [x19, 624]
	cmp	w0, 0
	ble	.L134
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
.L156:
	mov	x0, 0
	bl	ebc_notify
	str	w21, [x19, 192]
	ldr	x1, [x20, 8]
	mov	x0, x1
	ldr	x1, [x1, 80]
	blr	x1
	ldr	x0, [x20, 16]
	cbnz	x0, .L160
.L142:
	ldr	x0, [x20, 24]
	bl	regulator_disable
	mov	w21, w0
	b	.L143
	.p2align 3
.L159:
	mov	w0, 1
	str	w0, [x19, 456]
	add	x0, x20, 472
	bl	__pm_stay_awake
	b	.L137
	.p2align 3
.L158:
	mov	x0, 1
	bl	ebc_notify
	b	.L136
	.p2align 3
.L157:
	str	wzr, [x19, 456]
	add	x0, x20, 472
	bl	__pm_relax
	b	.L144
	.p2align 3
.L138:
	ldr	x0, [x20, 24]
	bl	regulator_enable
	mov	w21, w0
	b	.L139
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
	add	x20, x19, 224
	mov	x0, x19
	bl	ebc_power_set
	mov	w0, 1
	str	w0, [x20, 580]
	ldr	x0, [x19, 16]
	cbz	x0, .L162
	ldr	x1, [x0, 40]
	blr	x1
.L162:
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
	add	x19, x20, 856
	add	x20, x20, 896
.L169:
	ldr	x1, [x19]
	mov	x0, x1
	cbz	x1, .L168
	bl	dma_buf_put
	str	xzr, [x19]
.L168:
	add	x19, x19, 8
	cmp	x19, x20
	bne	.L169
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
	cbz	x0, .L180
	add	x19, x21, 856
	mov	x22, x0
	mov	x20, x0
	add	x21, x21, 896
.L179:
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
	bne	.L179
	mov	w0, 0
	str	xzr, [x23, 104]
	str	x22, [x23, 200]
.L177:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldr	x23, [sp, 48]
	ldp	x29, x30, [sp], 64
	ret
.L180:
	mov	w0, -12
	b	.L177
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
	ldr	x2, [x2, 264]
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
	bls	.L348
	mov	w0, 28693
	cmp	w1, w0
	beq	.L194
	bhi	.L195
	mov	w0, 28688
	cmp	w1, w0
	beq	.L194
	mov	w0, 28690
	cmp	w1, w0
	beq	.L194
	.p2align 2
.L192:
	sub	w1, w1, #28672
	cmp	w1, 25
	bls	.L349
.L197:
	ldr	x0, [x20, 320]
	adrp	x2, .LANCHOR2
	adrp	x1, .LC16
	add	x2, x2, :lo12:.LANCHOR2
	add	x1, x1, :lo12:.LC16
	bl	_dev_err
	.p2align 2
.L343:
	mov	x0, 0
.L191:
	add	x19, x19, :lo12:__stack_chk_guard
	ldr	x2, [x29, 168]
	ldr	x1, [x19]
	eor	x1, x2, x1
	cbnz	x1, .L350
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x29, x30, [sp], 176
	ret
	.p2align 3
.L348:
	mov	w0, 28681
	cmp	w1, w0
	bcs	.L194
	cmp	w1, 28672
	bcc	.L192
	mov	w0, 28675
	cmp	w1, w0
	bls	.L194
	mov	w2, -28678
	add	w0, w1, w2
	cmp	w0, 1
	bhi	.L192
	.p2align 2
.L194:
	cbnz	x22, .L192
	ldr	x0, [x20, 320]
	adrp	x2, .LANCHOR2
	adrp	x1, .LC5
	add	x2, x2, :lo12:.LANCHOR2
	add	x1, x1, :lo12:.LC5
	bl	_dev_err
	mov	x0, -14
	b	.L191
	.p2align 3
.L349:
	adrp	x0, .L199
	add	x0, x0, :lo12:.L199
	ldrh	w0, [x0,w1,uxtw #1]
	adr	x1, .Lrtx199
	add	x0, x1, w0, sxth #2
	br	x0
.Lrtx199:
	.section	.rodata
	.align	0
	.align	2
.L199:
	.2byte	(.L198 - .Lrtx199) / 4
	.2byte	(.L200 - .Lrtx199) / 4
	.2byte	(.L201 - .Lrtx199) / 4
	.2byte	(.L343 - .Lrtx199) / 4
	.2byte	(.L203 - .Lrtx199) / 4
	.2byte	(.L204 - .Lrtx199) / 4
	.2byte	(.L205 - .Lrtx199) / 4
	.2byte	(.L206 - .Lrtx199) / 4
	.2byte	(.L343 - .Lrtx199) / 4
	.2byte	(.L343 - .Lrtx199) / 4
	.2byte	(.L343 - .Lrtx199) / 4
	.2byte	(.L207 - .Lrtx199) / 4
	.2byte	(.L208 - .Lrtx199) / 4
	.2byte	(.L209 - .Lrtx199) / 4
	.2byte	(.L343 - .Lrtx199) / 4
	.2byte	(.L343 - .Lrtx199) / 4
	.2byte	(.L210 - .Lrtx199) / 4
	.2byte	(.L211 - .Lrtx199) / 4
	.2byte	(.L212 - .Lrtx199) / 4
	.2byte	(.L213 - .Lrtx199) / 4
	.2byte	(.L214 - .Lrtx199) / 4
	.2byte	(.L215 - .Lrtx199) / 4
	.2byte	(.L197 - .Lrtx199) / 4
	.2byte	(.L216 - .Lrtx199) / 4
	.2byte	(.L217 - .Lrtx199) / 4
	.2byte	(.L218 - .Lrtx199) / 4
	.text
	.p2align 3
.L195:
	mov	w0, -28695
	add	w0, w1, w0
	cmp	w0, 2
	bls	.L194
	sub	w1, w1, #28672
	cmp	w1, 25
	bhi	.L197
	b	.L349
	.p2align 3
.L203:
	ldr	w0, [x20, 848]
	mov	w1, 1
	str	w1, [x20, 808]
	add	x20, x20, 224
	tbnz	w0, #31, .L343
	ldr	x0, [x20, 96]
	adrp	x1, .LC8
	add	x1, x1, :lo12:.LC8
	bl	_dev_info
	mov	x0, 0
	b	.L191
	.p2align 3
.L204:
	ldr	w0, [x20, 848]
	add	x20, x20, 224
	str	wzr, [x20, 584]
	tbnz	w0, #31, .L343
	ldr	x0, [x20, 96]
	adrp	x1, .LC9
	add	x1, x1, :lo12:.LC9
	bl	_dev_info
	mov	x0, 0
	b	.L191
	.p2align 3
.L205:
	bl	ebc_empty_osd_buf_get
	cbz	x0, .L227
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
	tbnz	x1, 21, .L220
	ldr	x2, [x2]
	mov	x1, x22
	tbz	x2, 26, .L221
.L220:
	sbfx	x1, x22, 0, 56
	and	x1, x1, x22
.L221:
#APP
// 88 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x1, x1, 68
	csel	x0, xzr, x0, hi
	csinv	x1, x1, xzr, cc
	sbcs	xzr, x1, x0
	cset	x1, ls

// 0 "" 2
#NO_APP
	mov	x0, 68
	cbz	x1, .L191
	sbfx	x1, x22, 0, 56
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x2, sp_el0
// 0 "" 2
#NO_APP
	and	x1, x1, x22
	ldr	x2, [x2, 8]
#APP
// 248 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x1, x2
	csel	x3, x22, xzr, eq

// 0 "" 2
// 256 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	mov	x2, x0
	add	x1, x29, 96
	mov	x0, x3
	bl	__arch_copy_to_user
	sxtw	x0, w0
	b	.L191
	.p2align 3
.L206:
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x0, sp_el0
// 0 "" 2
#NO_APP
	ldr	w2, [x0, 52]
	ldr	x1, [x0, 8]
	tbnz	x2, 21, .L240
	ldr	x2, [x0]
	mov	x0, x22
	tbz	x2, 26, .L241
.L240:
	sbfx	x0, x22, 0, 56
	and	x0, x0, x22
.L241:
#APP
// 88 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x0, x0, 68
	csel	x1, xzr, x1, hi
	csinv	x0, x0, xzr, cc
	sbcs	xzr, x0, x1
	cset	x0, ls

// 0 "" 2
#NO_APP
	cbz	x0, .L344
	sbfx	x0, x22, 0, 56
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x1, sp_el0
// 0 "" 2
#NO_APP
	and	x0, x0, x22
	ldr	x2, [x1, 8]
#APP
// 248 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x0, x2
	csel	x1, x22, xzr, eq

// 0 "" 2
// 256 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	mov	x2, 68
	add	x0, x29, 96
	bl	__arch_copy_from_user
	cbnz	x0, .L344
	bl	ebc_osd_buf_clone
	mov	x1, x0
	cbz	x0, .L343
	ldr	w6, [x29, 100]
	add	x20, x20, 224
	ldp	w5, w3, [x29, 116]
	str	w6, [x1, 40]
	ldp	w4, w2, [x29, 124]
	stp	w5, w3, [x1, 48]
	stp	w4, w2, [x1, 56]
	bl	ebc_add_to_osd_buf_list
	ldr	w0, [x20, 92]
	cbnz	w0, .L243
	mov	w0, 1
	str	w0, [x20, 92]
.L243:
	ldr	w0, [x20, 88]
	cbnz	w0, .L343
.L345:
	mov	w2, 1
	str	w2, [x20, 88]
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 304
	mov	w1, w2
	bl	__wake_up_sync
	mov	x0, 0
	b	.L191
	.p2align 3
.L215:
	str	wzr, [x29, 92]
	ldr	w0, [x20, 924]
	cmp	w0, 3576
	bne	.L343
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x0, sp_el0
// 0 "" 2
#NO_APP
	ldr	w2, [x0, 52]
	ldr	x1, [x0, 8]
	tbnz	x2, 21, .L261
	ldr	x2, [x0]
	mov	x0, x22
	tbz	x2, 26, .L262
.L261:
	sbfx	x0, x22, 0, 56
	and	x0, x0, x22
.L262:
#APP
// 88 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x0, x0, 4
	csel	x1, xzr, x1, hi
	csinv	x0, x0, xzr, cc
	sbcs	xzr, x0, x1
	cset	x0, ls

// 0 "" 2
#NO_APP
	cbz	x0, .L344
	sbfx	x0, x22, 0, 56
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x1, sp_el0
// 0 "" 2
#NO_APP
	and	x0, x0, x22
	ldr	x2, [x1, 8]
#APP
// 248 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x0, x2
	csel	x1, x22, xzr, eq

// 0 "" 2
// 256 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	add	x22, x29, 92
	mov	x2, 4
	mov	x0, x22
	bl	__arch_copy_from_user
	mov	x21, x0
	cbnz	x0, .L351
.L264:
	add	x20, x20, 224
	ldr	w0, [x20, 624]
	tbnz	w0, #31, .L265
	ldr	w2, [x29, 92]
	adrp	x1, .LC13
	ldr	x0, [x20, 96]
	add	x1, x1, :lo12:.LC13
	bl	_dev_info
.L265:
	ldr	w0, [x29, 92]
	str	w0, [x20, 604]
	b	.L343
	.p2align 3
.L216:
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x1, sp_el0
// 0 "" 2
#NO_APP
	ldr	w2, [x1, 52]
	ldr	x0, [x1, 8]
	tbnz	x2, 21, .L266
	ldr	x2, [x1]
	mov	x1, x22
	tbz	x2, 26, .L267
.L266:
	sbfx	x1, x22, 0, 56
	and	x1, x1, x22
.L267:
#APP
// 88 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x1, x1, 4
	csel	x0, xzr, x0, hi
	csinv	x1, x1, xzr, cc
	sbcs	xzr, x1, x0
	cset	x1, ls

// 0 "" 2
#NO_APP
	mov	x0, 4
	cbz	x1, .L191
	sbfx	x1, x22, 0, 56
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x2, sp_el0
// 0 "" 2
#NO_APP
	and	x1, x1, x22
	ldr	x2, [x2, 8]
#APP
// 248 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x1, x2
	csel	x3, x22, xzr, eq

// 0 "" 2
// 256 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	mov	x2, x0
	add	x1, x20, 836
	mov	x0, x3
	bl	__arch_copy_to_user
	sxtw	x0, w0
	b	.L191
	.p2align 3
.L214:
	add	x20, x20, 224
	ldr	w0, [x20, 624]
	tbnz	w0, #31, .L258
	ldr	x0, [x20, 96]
	adrp	x1, .LC12
	add	x1, x1, :lo12:.LC12
	bl	_dev_info
.L258:
	ldr	w0, [x20, 576]
	cbnz	w0, .L352
.L259:
	mov	x0, 0
	str	wzr, [x20, 576]
	str	wzr, [x20, 596]
	b	.L191
	.p2align 3
.L207:
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x1, sp_el0
// 0 "" 2
#NO_APP
	ldr	w2, [x1, 52]
	ldr	x0, [x1, 8]
	tbnz	x2, 21, .L244
	ldr	x2, [x1]
	mov	x1, x22
	tbz	x2, 26, .L245
.L244:
	sbfx	x1, x22, 0, 56
	and	x1, x1, x22
.L245:
#APP
// 88 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x1, x1, 4
	csel	x0, xzr, x0, hi
	csinv	x1, x1, xzr, cc
	sbcs	xzr, x1, x0
	cset	x1, ls

// 0 "" 2
#NO_APP
	mov	x0, 4
	cbz	x1, .L191
	sbfx	x1, x22, 0, 56
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x2, sp_el0
// 0 "" 2
#NO_APP
	and	x1, x1, x22
	ldr	x2, [x2, 8]
#APP
// 248 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x1, x2
	csel	x3, x22, xzr, eq

// 0 "" 2
// 256 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	mov	x2, x0
	add	x1, x20, 808
	mov	x0, x3
	bl	__arch_copy_to_user
	sxtw	x0, w0
	b	.L191
	.p2align 3
.L217:
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x0, sp_el0
// 0 "" 2
#NO_APP
	ldr	w2, [x0, 52]
	add	x21, x20, 904
	ldr	x1, [x0, 8]
	tbnz	x2, 21, .L269
	ldr	x2, [x0]
	mov	x0, x22
	tbz	x2, 26, .L270
.L269:
	sbfx	x0, x22, 0, 56
	and	x0, x0, x22
.L270:
#APP
// 88 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x0, x0, 4
	csel	x1, xzr, x1, hi
	csinv	x0, x0, xzr, cc
	sbcs	xzr, x0, x1
	cset	x0, ls

// 0 "" 2
#NO_APP
	cbz	x0, .L271
	sbfx	x0, x22, 0, 56
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x1, sp_el0
// 0 "" 2
#NO_APP
	and	x0, x0, x22
	ldr	x2, [x1, 8]
#APP
// 248 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x0, x2
	csel	x1, x22, xzr, eq

// 0 "" 2
// 256 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	mov	x2, 4
	mov	x0, x21
	bl	__arch_copy_from_user
	mov	x22, x0
	cbnz	x0, .L272
.L274:
	add	x20, x20, 224
	ldr	w0, [x20, 624]
	tbnz	w0, #31, .L343
	ldr	x0, [x20, 96]
	adrp	x1, .LC14
	ldr	w2, [x20, 680]
	add	x1, x1, :lo12:.LC14
	bl	_dev_info
	mov	x0, 0
	b	.L191
	.p2align 3
.L213:
	add	x20, x20, 224
	ldr	w0, [x20, 624]
	tbnz	w0, #31, .L257
	ldr	x0, [x20, 96]
	adrp	x1, .LC11
	add	x1, x1, :lo12:.LC11
	bl	_dev_info
.L257:
	mov	x0, 2
	bl	ebc_notify
	mov	w1, 1
	mov	x0, 0
	str	w1, [x20, 576]
	str	w1, [x20, 596]
	b	.L191
	.p2align 3
.L200:
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x0, sp_el0
// 0 "" 2
#NO_APP
	ldr	w2, [x0, 52]
	ldr	x1, [x0, 8]
	tbnz	x2, 21, .L234
	ldr	x2, [x0]
	mov	x0, x22
	tbz	x2, 26, .L235
.L234:
	sbfx	x0, x22, 0, 56
	and	x0, x0, x22
.L235:
#APP
// 88 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x0, x0, 68
	csel	x1, xzr, x1, hi
	csinv	x0, x0, xzr, cc
	sbcs	xzr, x0, x1
	cset	x0, ls

// 0 "" 2
#NO_APP
	cbz	x0, .L344
	sbfx	x0, x22, 0, 56
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x1, sp_el0
// 0 "" 2
#NO_APP
	and	x0, x0, x22
	ldr	x2, [x1, 8]
#APP
// 248 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x0, x2
	csel	x1, x22, xzr, eq

// 0 "" 2
// 256 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	mov	x2, 68
	add	x0, x29, 96
	bl	__arch_copy_from_user
	cbnz	x0, .L344
	bl	ebc_phy_buf_base_get
	ldrsw	x1, [x29, 96]
	add	x0, x1, x0
	bl	ebc_find_buf_by_phy_addr
	mov	x1, x0
	cbz	x0, .L343
	ldr	w2, [x29, 100]
	add	x20, x20, 224
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
	cbnz	w0, .L343
	b	.L345
	.p2align 3
.L201:
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
	tbnz	x3, 21, .L253
	ldr	x2, [x2]
	mov	x0, x22
	tbz	x2, 26, .L254
.L253:
	sbfx	x0, x22, 0, 56
	and	x0, x0, x22
.L254:
#APP
// 88 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x0, x0, 68
	csel	x1, xzr, x1, hi
	csinv	x0, x0, xzr, cc
	sbcs	xzr, x0, x1
	cset	x0, ls

// 0 "" 2
#NO_APP
	cbnz	x0, .L255
.L256:
	ldr	x0, [x20, 320]
	adrp	x1, .LC10
	add	x1, x1, :lo12:.LC10
	bl	_dev_err
	mov	x0, -14
	b	.L191
	.p2align 3
.L218:
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x0, sp_el0
// 0 "" 2
#NO_APP
	ldr	w2, [x0, 52]
	add	x21, x20, 916
	ldr	x1, [x0, 8]
	tbnz	x2, 21, .L275
	ldr	x2, [x0]
	mov	x0, x22
	tbz	x2, 26, .L276
.L275:
	sbfx	x0, x22, 0, 56
	and	x0, x0, x22
.L276:
#APP
// 88 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x0, x0, 4
	csel	x1, xzr, x1, hi
	csinv	x0, x0, xzr, cc
	sbcs	xzr, x0, x1
	cset	x0, ls

// 0 "" 2
#NO_APP
	cbz	x0, .L277
	sbfx	x0, x22, 0, 56
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x1, sp_el0
// 0 "" 2
#NO_APP
	and	x0, x0, x22
	ldr	x2, [x1, 8]
#APP
// 248 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x0, x2
	csel	x1, x22, xzr, eq

// 0 "" 2
// 256 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	mov	x2, 4
	mov	x0, x21
	bl	__arch_copy_from_user
	mov	x22, x0
	cbnz	x0, .L278
.L280:
	add	x20, x20, 224
	ldr	w0, [x20, 624]
	tbnz	w0, #31, .L343
	ldr	x0, [x20, 96]
	adrp	x1, .LC15
	ldr	w2, [x20, 692]
	add	x1, x1, :lo12:.LC15
	bl	_dev_info
	mov	x0, 0
	b	.L191
	.p2align 3
.L198:
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x0, sp_el0
// 0 "" 2
#NO_APP
	ldr	w2, [x0, 52]
	ldr	x1, [x0, 8]
	tbnz	x2, 21, .L223
	ldr	x2, [x0]
	mov	x0, x22
	tbz	x2, 26, .L224
.L223:
	sbfx	x0, x22, 0, 56
	and	x0, x0, x22
.L224:
#APP
// 88 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x0, x0, 68
	csel	x1, xzr, x1, hi
	csinv	x0, x0, xzr, cc
	sbcs	xzr, x0, x1
	cset	x0, ls

// 0 "" 2
#NO_APP
	cbz	x0, .L344
	lsl	x24, x22, 8
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x0, sp_el0
// 0 "" 2
#NO_APP
	and	x2, x22, x24, asr 8
	ldr	x0, [x0, 8]
#APP
// 248 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x2, x0
	csel	x1, x22, xzr, eq

// 0 "" 2
// 256 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	add	x25, x29, 96
	mov	x2, 68
	mov	x0, x25
	bl	__arch_copy_from_user
	mov	x23, x0
	cbnz	x0, .L226
.L229:
	add	x0, x25, 48
	bl	ebc_empty_buf_get
	mov	x26, x0
	cbz	x0, .L227
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
	tbnz	x0, 21, .L230
	ldr	x2, [x2]
	mov	x0, x22
	tbnz	x2, 26, .L230
.L231:
#APP
// 88 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x0, x0, 68
	csel	x1, xzr, x1, hi
	csinv	x0, x0, xzr, cc
	sbcs	xzr, x0, x1
	cset	x0, ls

// 0 "" 2
#NO_APP
	cbnz	x0, .L232
.L233:
	mov	x0, x26
	bl	ebc_buf_release
	mov	x0, -14
	b	.L191
	.p2align 3
.L208:
	ldr	w0, [x20, 848]
	mov	w1, 1
	str	w1, [x20, 816]
	add	x20, x20, 224
	tbnz	w0, #31, .L343
	ldr	x0, [x20, 96]
	adrp	x1, .LC6
	add	x1, x1, :lo12:.LC6
	bl	_dev_info
	mov	x0, 0
	b	.L191
	.p2align 3
.L211:
	bl	ebc_drop_one_dsp_buf
	cbz	w0, .L343
	.p2align 2
.L344:
	mov	x0, -14
	b	.L191
	.p2align 3
.L212:
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x1, sp_el0
// 0 "" 2
#NO_APP
	ldr	w2, [x1, 52]
	ldr	x0, [x1, 8]
	tbnz	x2, 21, .L247
	ldr	x2, [x1]
	mov	x1, x22
	tbz	x2, 26, .L248
.L247:
	sbfx	x1, x22, 0, 56
	and	x1, x1, x22
.L248:
#APP
// 88 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x1, x1, 4
	csel	x0, xzr, x0, hi
	csinv	x1, x1, xzr, cc
	sbcs	xzr, x1, x0
	cset	x1, ls

// 0 "" 2
#NO_APP
	mov	x0, 4
	cbz	x1, .L191
	sbfx	x1, x22, 0, 56
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x2, sp_el0
// 0 "" 2
#NO_APP
	and	x1, x1, x22
	ldr	x2, [x2, 8]
#APP
// 248 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x1, x2
	csel	x3, x22, xzr, eq

// 0 "" 2
// 256 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	mov	x2, x0
	add	x1, x20, 680
	mov	x0, x3
	bl	__arch_copy_to_user
	sxtw	x0, w0
	b	.L191
	.p2align 3
.L210:
	mov	w0, 1
	str	w0, [x29, 92]
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x1, sp_el0
// 0 "" 2
#NO_APP
	ldr	w2, [x1, 52]
	ldr	x0, [x1, 8]
	tbnz	x2, 21, .L250
	ldr	x2, [x1]
	mov	x1, x22
	tbz	x2, 26, .L251
.L250:
	sbfx	x1, x22, 0, 56
	and	x1, x1, x22
.L251:
#APP
// 88 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		adds	x1, x1, 4
	csel	x0, xzr, x0, hi
	csinv	x1, x1, xzr, cc
	sbcs	xzr, x1, x0
	cset	x1, ls

// 0 "" 2
#NO_APP
	mov	x0, 4
	cbz	x1, .L191
	sbfx	x1, x22, 0, 56
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x2, sp_el0
// 0 "" 2
#NO_APP
	and	x1, x1, x22
	ldr	x2, [x2, 8]
#APP
// 248 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x1, x2
	csel	x3, x22, xzr, eq

// 0 "" 2
// 256 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	mov	x2, x0
	add	x1, x29, 92
	mov	x0, x3
	bl	__arch_copy_to_user
	sxtw	x0, w0
	b	.L191
	.p2align 3
.L209:
	ldr	w0, [x20, 848]
	add	x20, x20, 224
	str	wzr, [x20, 592]
	tbnz	w0, #31, .L343
	ldr	x0, [x20, 96]
	adrp	x1, .LC7
	add	x1, x1, :lo12:.LC7
	bl	_dev_info
	mov	x0, 0
	b	.L191
	.p2align 3
.L230:
	and	x0, x22, x24, asr 8
	b	.L231
	.p2align 3
.L255:
	sbfx	x1, x22, 0, 56
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x0, sp_el0
// 0 "" 2
#NO_APP
	and	x1, x1, x22
	ldr	x2, [x0, 8]
#APP
// 248 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x1, x2
	csel	x0, x22, xzr, eq

// 0 "" 2
// 256 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	mov	x2, 68
	add	x1, x29, 96
	bl	__arch_copy_to_user
	cbz	x0, .L343
	b	.L256
	.p2align 3
.L352:
	mov	x0, 3
	bl	ebc_notify
	b	.L259
	.p2align 3
.L232:
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x0, sp_el0
// 0 "" 2
#NO_APP
	and	x24, x22, x24, asr 8
	ldr	x1, [x0, 8]
#APP
// 248 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
		bics	xzr, x24, x1
	csel	x0, x22, xzr, eq

// 0 "" 2
// 256 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/uaccess.h" 1
	hint #20
// 0 "" 2
#NO_APP
	mov	x2, 68
	mov	x1, x25
	bl	__arch_copy_to_user
	cbz	w0, .L343
	b	.L233
	.p2align 3
.L278:
	sub	x0, x21, x0
	mov	x2, x22
	mov	w1, 0
	add	x0, x0, 4
	bl	memset
	cbz	w22, .L280
	mov	x0, -14
	b	.L191
	.p2align 3
.L272:
	sub	x0, x21, x0
	mov	x2, x22
	mov	w1, 0
	add	x0, x0, 4
	bl	memset
	cbz	w22, .L274
	mov	x0, -14
	b	.L191
	.p2align 3
.L277:
	str	wzr, [x20, 916]
	mov	x0, -14
	b	.L191
.L271:
	mov	x0, -14
	str	wzr, [x20, 904]
	b	.L191
.L227:
	mov	x0, -1
	b	.L191
.L350:
	bl	__stack_chk_fail
.L351:
	sub	x0, x22, x0
	mov	x2, x21
	mov	w1, 0
	add	x0, x0, 4
	bl	memset
	cbz	w21, .L264
	mov	x0, -14
	b	.L191
.L226:
	sub	x0, x25, x0
	mov	x2, x23
	mov	w1, 0
	add	x0, x0, 68
	bl	memset
	cbz	w23, .L229
	mov	x0, -14
	b	.L191
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
	beq	.L508
	cmp	w6, 3
	beq	.L356
	lsr	w13, w1, 2
	mov	x0, 0
	mov	w21, 0
.L355:
	sub	w2, w22, w21
	add	x0, x23, x0
	mov	w1, 0
	str	w13, [x29, 108]
	mul	w2, w2, w13
	sxtw	x2, w2
	bl	memset
	cmp	w21, w22
	bge	.L416
	ldr	w13, [x29, 108]
	sub	w11, w24, #1
	add	x11, x11, 1
	mov	w3, 0
	lsl	x11, x11, 3
	mul	w12, w21, w13
	lsl	w13, w13, 1
	.p2align 2
.L415:
	add	x9, x23, x12, sxtw
	cbz	w24, .L358
	add	x1, x27, 8
	add	x8, x28, 8
	mov	x4, x9
	mov	x7, 0
	.p2align 2
.L386:
	ldr	x2, [x26, x7]
	ldr	x0, [x20, x7]
	cmp	x2, x0
	beq	.L359
	eor	x5, x2, x0
	and	x3, x5, 255
	cbz	x3, .L417
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
	beq	.L509
.L362:
	strb	w3, [x1, -8]
.L360:
	tst	x5, 65280
	beq	.L363
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
	beq	.L510
.L365:
	strb	w3, [x1, -7]
.L363:
	tst	x5, 16711680
	beq	.L366
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
	beq	.L511
.L368:
	strb	w3, [x1, -6]
.L366:
	tst	x5, 4278190080
	beq	.L369
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
	beq	.L512
.L371:
	strb	w3, [x1, -5]
.L369:
	tst	x5, 1095216660480
	beq	.L372
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
	beq	.L513
.L374:
	strb	w3, [x1, -4]
.L372:
	tst	x5, 280375465082880
	beq	.L375
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
	beq	.L514
.L377:
	strb	w3, [x1, -3]
.L375:
	tst	x5, 71776119061217280
	beq	.L378
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
	beq	.L515
.L380:
	strb	w3, [x1, -2]
.L378:
	tst	x5, -72057594037927936
	beq	.L381
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
	beq	.L516
	strb	w5, [x1, -1]
.L381:
	cbnz	w10, .L384
.L385:
	mov	w3, 1
	str	w6, [x4]
.L359:
	add	x7, x7, 8
	add	x1, x1, 8
	add	x8, x8, 8
	add	x4, x4, 4
	cmp	x11, x7
	bne	.L386
	add	x27, x27, x11
	add	x28, x28, x11
	add	x20, x20, x11
	add	x26, x26, x11
	add	x1, x27, 8
	add	x8, x28, 8
	mov	x7, 0
	.p2align 2
.L414:
	ldr	x5, [x26, x7]
	ldr	x0, [x20, x7]
	cmp	x5, x0
	beq	.L387
	eor	x6, x5, x0
	and	x2, x6, 255
	cbz	x2, .L419
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
	beq	.L517
.L390:
	strb	w3, [x1, -8]
.L388:
	tst	x6, 65280
	beq	.L391
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
	beq	.L518
.L393:
	strb	w3, [x1, -7]
.L391:
	tst	x6, 16711680
	beq	.L394
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
	beq	.L519
.L396:
	strb	w3, [x1, -6]
.L394:
	tst	x6, 4278190080
	beq	.L397
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
	beq	.L520
.L399:
	strb	w3, [x1, -5]
.L397:
	tst	x6, 1095216660480
	beq	.L400
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
	beq	.L521
.L402:
	strb	w3, [x1, -4]
.L400:
	tst	x6, 280375465082880
	beq	.L403
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
	beq	.L522
.L405:
	strb	w10, [x1, -3]
.L403:
	tst	x6, 71776119061217280
	beq	.L406
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
	beq	.L523
.L408:
	strb	w10, [x1, -2]
.L406:
	tst	x6, -72057594037927936
	beq	.L409
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
	beq	.L524
	strb	w6, [x1, -1]
.L409:
	cbnz	w4, .L412
.L413:
	ldr	w0, [x9]
	mov	w3, 1
	orr	w2, w0, w2
	str	w2, [x9]
.L387:
	add	x7, x7, 8
	add	x1, x1, 8
	add	x8, x8, 8
	add	x9, x9, 4
	cmp	x11, x7
	bne	.L414
	add	x27, x27, x11
	add	x28, x28, x11
	add	x20, x20, x11
	add	x26, x26, x11
.L358:
	add	w21, w21, 2
	add	w12, w12, w13
	cmp	w22, w21
	bgt	.L415
	str	w3, [x25]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	ldp	x29, x30, [sp], 112
	ret
	.p2align 3
.L516:
	and	x0, x0, 72057594037927935
	and	x2, x2, -72057594037927936
	orr	x0, x2, x0
	strb	wzr, [x1, -1]
.L384:
	str	x0, [x20, x7]
	b	.L385
	.p2align 3
.L515:
	and	x3, x2, 71776119061217280
	and	x0, x0, -71776119061217281
	orr	x0, x3, x0
	mov	w10, 1
	mov	w3, 0
	b	.L380
	.p2align 3
.L513:
	and	x3, x2, 1095216660480
	and	x0, x0, -1095216660481
	orr	x0, x3, x0
	mov	w10, 1
	mov	w3, 0
	b	.L374
	.p2align 3
.L514:
	and	x3, x2, 280375465082880
	and	x0, x0, -280375465082881
	orr	x0, x3, x0
	mov	w10, 1
	mov	w3, 0
	b	.L377
	.p2align 3
.L512:
	and	x3, x2, 4278190080
	and	x0, x0, -4278190081
	orr	x0, x3, x0
	mov	w10, 1
	mov	w3, 0
	b	.L371
	.p2align 3
.L510:
	and	x3, x2, 65280
	and	x0, x0, -65281
	orr	x0, x3, x0
	mov	w10, 1
	mov	w3, 0
	b	.L365
	.p2align 3
.L511:
	and	x3, x2, 16711680
	and	x0, x0, -16711681
	orr	x0, x3, x0
	mov	w10, 1
	mov	w3, 0
	b	.L368
	.p2align 3
.L509:
	bfi	x0, x2, 0, 8
	mov	w3, 0
	mov	w10, 1
	b	.L362
	.p2align 3
.L524:
	and	x0, x0, 72057594037927935
	and	x5, x5, -72057594037927936
	orr	x0, x5, x0
	strb	wzr, [x1, -1]
.L412:
	str	x0, [x20, x7]
	b	.L413
	.p2align 3
.L521:
	and	x3, x5, 1095216660480
	and	x0, x0, -1095216660481
	orr	x0, x3, x0
	mov	w4, 1
	mov	w3, 0
	b	.L402
	.p2align 3
.L522:
	and	x0, x0, -280375465082881
	and	x3, x5, 280375465082880
	orr	x0, x3, x0
	mov	w10, 0
	mov	w4, 1
	b	.L405
	.p2align 3
.L523:
	and	x0, x0, -71776119061217281
	and	x3, x5, 71776119061217280
	orr	x0, x3, x0
	mov	w10, 0
	mov	w4, 1
	b	.L408
	.p2align 3
.L519:
	and	x3, x5, 16711680
	and	x0, x0, -16711681
	orr	x0, x3, x0
	mov	w4, 1
	mov	w3, 0
	b	.L396
	.p2align 3
.L520:
	and	x3, x5, 4278190080
	and	x0, x0, -4278190081
	orr	x0, x3, x0
	mov	w4, 1
	mov	w3, 0
	b	.L399
	.p2align 3
.L518:
	and	x3, x5, 65280
	and	x0, x0, -65281
	orr	x0, x3, x0
	mov	w4, 1
	mov	w3, 0
	b	.L393
	.p2align 3
.L517:
	bfi	x0, x5, 0, 8
	mov	w3, 0
	mov	w4, 1
	b	.L390
	.p2align 3
.L419:
	mov	w2, 0
	mov	w4, 0
	b	.L388
	.p2align 3
.L417:
	mov	w6, 0
	mov	w10, 0
	b	.L360
.L508:
	add	w22, w22, w22, lsr 31
	lsr	w13, w1, 2
	asr	w22, w22, 1
	mov	x0, 0
	mov	w21, 0
	b	.L355
.L356:
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
	b	.L355
.L416:
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
	beq	.L607
	mov	w26, w0
	cmp	w6, 3
	mov	w23, 0
	beq	.L608
.L527:
	ldr	w1, [x22, 156]
	lsr	w13, w13, 2
	cbz	w1, .L528
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
	bge	.L563
.L617:
	sub	w12, w27, #1
	sxtw	x13, w13
	add	x12, x12, 1
	lsl	w11, w27, 1
	lsl	x12, x12, 3
	mov	w3, 0
	.p2align 2
.L530:
	cbz	w27, .L561
	add	x1, x24, 8
	add	x6, x25, 8
	mov	w9, 0
	mov	x7, 0
	.p2align 2
.L559:
	ldr	x2, [x21, x7]
	ldr	x0, [x20, x7]
	cmp	x2, x0
	beq	.L532
	eor	x5, x2, x0
	add	x4, x22, x9, sxtw
	and	x3, x5, 255
	cbz	x3, .L564
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
	beq	.L609
.L535:
	strb	w3, [x1, -8]
.L533:
	tst	x5, 65280
	beq	.L536
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
	beq	.L610
.L538:
	strb	w3, [x1, -7]
.L536:
	tst	x5, 16711680
	beq	.L539
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
	beq	.L611
.L541:
	strb	w3, [x1, -6]
.L539:
	tst	x5, 4278190080
	beq	.L542
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
	beq	.L612
.L544:
	strb	w3, [x1, -5]
.L542:
	strb	w8, [x4]
	tst	x5, 1095216660480
	mov	w8, 0
	beq	.L545
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
	beq	.L613
.L547:
	strb	w3, [x1, -4]
.L545:
	tst	x5, 280375465082880
	beq	.L548
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
	beq	.L614
.L550:
	strb	w10, [x1, -3]
.L548:
	tst	x5, 71776119061217280
	beq	.L551
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
	beq	.L615
.L553:
	strb	w10, [x1, -2]
.L551:
	tst	x5, -72057594037927936
	beq	.L554
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
	beq	.L616
	strb	w5, [x1, -1]
.L554:
	cbnz	w14, .L557
.L558:
	strb	w8, [x4, 1]
	mov	w3, 1
.L532:
	add	w9, w9, 2
	add	x7, x7, 8
	add	x1, x1, 8
	add	x6, x6, 8
	cmp	w9, w11
	bne	.L559
	add	x24, x24, x12
	add	x25, x25, x12
	add	x20, x20, x12
	add	x21, x21, x12
.L561:
	add	w23, w23, 1
	add	x22, x22, x13
	cmp	w26, w23
	bne	.L530
	str	w3, [x28]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	ldp	x29, x30, [sp], 112
	ret
	.p2align 3
.L616:
	and	x0, x0, 72057594037927935
	and	x2, x2, -72057594037927936
	orr	x0, x2, x0
	strb	wzr, [x1, -1]
.L557:
	str	x0, [x20, x7]
	b	.L558
	.p2align 3
.L615:
	and	x0, x0, -71776119061217281
	and	x3, x2, 71776119061217280
	orr	x0, x3, x0
	mov	w10, 0
	mov	w14, 1
	b	.L553
	.p2align 3
.L614:
	and	x0, x0, -280375465082881
	and	x3, x2, 280375465082880
	orr	x0, x3, x0
	mov	w10, 0
	mov	w14, 1
	b	.L550
	.p2align 3
.L612:
	and	x3, x2, 4278190080
	and	x0, x0, -4278190081
	orr	x0, x3, x0
	mov	w14, 1
	mov	w3, 0
	b	.L544
	.p2align 3
.L613:
	and	x3, x2, 1095216660480
	and	x0, x0, -1095216660481
	orr	x0, x3, x0
	mov	w14, 1
	mov	w3, 0
	b	.L547
	.p2align 3
.L611:
	and	x3, x2, 16711680
	and	x0, x0, -16711681
	orr	x0, x3, x0
	mov	w14, 1
	mov	w3, 0
	b	.L541
	.p2align 3
.L609:
	bfi	x0, x2, 0, 8
	mov	w3, 0
	mov	w14, 1
	b	.L535
	.p2align 3
.L610:
	and	x3, x2, 65280
	and	x0, x0, -65281
	orr	x0, x3, x0
	mov	w14, 1
	mov	w3, 0
	b	.L538
	.p2align 3
.L564:
	mov	w8, 0
	mov	w14, 0
	b	.L533
.L528:
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
	blt	.L617
.L563:
	mov	w3, 0
	str	w3, [x28]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	ldp	x29, x30, [sp], 112
	ret
.L607:
	add	w26, w0, w0, lsr 31
	mov	w23, 0
	asr	w26, w26, 1
	b	.L527
.L608:
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
	b	.L527
	.size	get_overlay_image, .-get_overlay_image
	.align	2
	.p2align 3,,7
	.type	is_full_refresh_done, %function
is_full_refresh_done:
	ldp	w4, w2, [x0, 80]
	ldr	w3, [x0, 676]
	cmp	w2, 0
	add	w1, w2, 7
	csel	w1, w1, w2, lt
	ldr	x5, [x0, 160]
	cmp	w3, 3
	asr	w1, w1, 3
	bne	.L629
	add	w3, w4, w4, lsr 31
	ldrb	w6, [x0, 56]
	asr	w3, w3, 1
	mov	w0, 0
	mul	w3, w3, w1
	ldr	x3, [x5, w3, sxtw 3]
	and	x3, x3, 255
	cmp	x3, 255
	ccmp	x3, x6, 0, ne
	bcc	.L631
	mul	w1, w1, w4
	cmp	w2, 0
	add	w3, w2, 15
	csel	w3, w3, w2, lt
	sxtw	x1, w1
	asr	w3, w3, 4
	sub	x1, x1, x3, sxtw
	ldr	x1, [x5, x1, lsl 3]
	and	x1, x1, 255
	cmp	x1, 255
	ccmp	x6, x1, 2, ne
	bls	.L622
	ret
	.p2align 3
.L629:
	mul	w1, w1, w4
	ldrb	w3, [x0, 56]
	add	x1, x5, x1, sxtw 3
	ldrb	w0, [x1, -8]
	cmp	x0, 255
	ccmp	x0, x3, 0, ne
	bcc	.L633
.L622:
	mul	w2, w2, w4
	stp	x29, x30, [sp, -16]!
	mov	w1, 0
	mov	x0, x5
	add	x29, sp, 0
	sxtw	x2, w2
	bl	memset
	mov	w0, 1
	ldp	x29, x30, [sp], 16
	ret
	.p2align 3
.L631:
	ret
	.p2align 3
.L633:
	mov	w0, 0
	ret
	.size	is_full_refresh_done, .-is_full_refresh_done
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
	add	x19, x21, 224
	ldr	w0, [x19, 240]
	cmp	w0, 3
	beq	.L636
	cmp	w0, 4
	beq	.L637
	cmp	w0, 1
	beq	.L684
	ldr	w0, [x19, 72]
	cbnz	w0, .L654
	ldr	w0, [x19, 688]
	cbz	w0, .L654
	ldr	x3, [x21, 8]
.L679:
	mov	x0, x3
	ldr	x3, [x3, 144]
	mov	w2, 0
	mov	w1, 0
	blr	x3
	str	wzr, [x19, 52]
	ldr	w0, [x19, 624]
	cmp	w0, 0
	ble	.L653
	ldr	x0, [x19, 96]
	adrp	x1, .LC21
	add	x1, x1, :lo12:.LC21
	bl	_dev_info
	b	.L653
	.p2align 3
.L684:
	ldr	w0, [x19, 72]
	cbz	w0, .L648
	ldr	w0, [x19, 92]
	cbz	w0, .L654
	ldr	x0, [x19, 216]
	ldr	w1, [x21, 828]
	ldr	w0, [x0, 40]
	cbz	w1, .L650
	sub	w0, w0, #12
	cmp	w0, 2
	bls	.L654
.L650:
	ldr	w1, [x19, 624]
	mov	x0, x21
	cmp	w1, 0
	ble	.L651
	ldr	x0, [x19, 96]
	adrp	x1, .LC20
	add	x1, x1, :lo12:.LC20
	bl	_dev_info
	ldr	x0, [x20, #:lo12:.LANCHOR0]
.L651:
	ldr	x3, [x0, 8]
	b	.L679
	.p2align 3
.L654:
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
.L637:
	ldr	w0, [x19, 60]
	mov	w1, 1
	str	w1, [x19, 76]
	cbnz	w0, .L645
	ldr	w0, [x19, 64]
	cbnz	w0, .L645
	ldr	w0, [x19, 68]
	cbz	w0, .L645
	ldr	w1, [x19, 624]
	mov	x0, x21
	cmp	w1, 0
	ble	.L642
	ldr	x0, [x19, 96]
	adrp	x1, .LC17
	add	x1, x1, :lo12:.LC17
	bl	_dev_info
	ldr	x0, [x20, #:lo12:.LANCHOR0]
.L642:
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
.L681:
	mul	w2, w2, w3
	mov	w1, 0
	sxtw	x2, w2
	bl	memset
.L680:
	adrp	x2, jiffies
	mov	x1, 402653184
	add	x0, x21, 744
	ldr	x2, [x2, #:lo12:jiffies]
	add	x1, x2, x1
	bl	mod_timer
	str	wzr, [x19, 52]
.L653:
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
.L636:
	ldr	w0, [x19, 92]
	cbnz	w0, .L685
	ldr	w0, [x19, 60]
	cbnz	w0, .L645
	ldr	w0, [x19, 64]
	cbnz	w0, .L645
	ldr	w0, [x19, 68]
	cbnz	w0, .L686
.L645:
	add	x20, x20, :lo12:.LANCHOR0
	ldr	x0, [x20, 8]
	bl	wake_up_process
	ldr	x21, [sp, 32]
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 48
	ret
	.p2align 3
.L685:
	ldr	w1, [x19, 624]
	mov	x0, x21
	cmp	w1, 0
	ble	.L644
	ldr	x0, [x19, 96]
	adrp	x1, .LC18
	add	x1, x1, :lo12:.LC18
	bl	_dev_info
	ldr	x0, [x20, #:lo12:.LANCHOR0]
.L644:
	ldr	x3, [x0, 8]
	mov	w2, 0
	mov	w1, 0
	mov	x0, x3
	ldr	x3, [x3, 144]
	blr	x3
	b	.L680
	.p2align 3
.L648:
	ldr	w1, [x19, 92]
	mov	x0, x21
	cbnz	w1, .L650
	ldr	x3, [x0, 8]
	b	.L679
	.p2align 3
.L686:
	ldr	w1, [x19, 624]
	mov	x0, x21
	cmp	w1, 0
	ble	.L647
	ldr	x0, [x19, 96]
	adrp	x1, .LC19
	add	x1, x1, :lo12:.LC19
	bl	_dev_info
	ldr	x0, [x20, #:lo12:.LANCHOR0]
.L647:
	ldr	x3, [x0, 8]
	mov	w2, 0
	mov	w1, 0
	mov	x0, x3
	ldr	x3, [x3, 144]
	blr	x3
	ldp	w3, w2, [x19, 80]
	ldr	x0, [x19, 160]
	b	.L681
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
	ldr	x21, [x19], 224
	ldr	x1, [x0]
	str	x1, [x29, 184]
	mov	x1,0
	ldr	w0, [x19, 28]
	cmp	w0, 5242880
	bgt	.L709
	ldr	x0, [x21, 752]
	adrp	x1, .LC23
	mov	w2, 0
	add	x1, x1, :lo12:.LC23
	bl	of_parse_phandle
	cbz	x0, .L701
	add	x2, x29, 88
	mov	w1, 0
	bl	of_address_to_resource
	mov	w25, w0
	cbnz	w0, .L710
	ldp	x1, x2, [x29, 88]
	str	x1, [x20, 224]
	mov	w0, 58720255
	add	x2, x2, 1
	sub	x2, x2, x1
	str	w2, [x19, 24]
	cmp	w2, w0
	ble	.L711
	mov	x3, 1
	sxtw	x2, w2
	mov	x0, x21
	bl	devm_memremap
	str	x0, [x19, 8]
	mov	x1, x0
	cbz	x0, .L712
	ldr	w2, [x19, 24]
	mov	w4, 4
	ldr	x0, [x20, 224]
	mov	w3, 5242880
	bl	ebc_buf_init
	mov	w25, w0
	cbnz	w0, .L699
	add	x0, x20, 856
	add	x26, x20, 896
	mov	x23, x0
	mov	x22, x0
	mov	x21, 0
	stp	xzr, xzr, [x0]
	stp	xzr, xzr, [x0, 16]
	str	xzr, [x20, 888]
.L697:
	ldr	x0, [x19]
	mov	x1, 5242880
	add	x0, x21, x0
	bl	ebc_get_dma_buf
	cmn	x0, #4096
	bhi	.L704
	str	x0, [x22], 8
	add	x21, x21, 5242880
	cmp	x22, x26
	bne	.L697
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
.L689:
	add	x24, x24, :lo12:__stack_chk_guard
	mov	w0, w25
	ldr	x2, [x29, 184]
	ldr	x1, [x24]
	eor	x1, x2, x1
	cbnz	x1, .L713
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x29, x30, [sp], 192
	ret
	.p2align 3
.L704:
	ldr	x0, [x23]
	cbz	x0, .L698
	bl	dma_buf_put
	str	xzr, [x23]
.L698:
	add	x23, x23, 8
	cmp	x26, x23
	bne	.L704
.L699:
	mov	w25, -12
	b	.L689
	.p2align 3
.L710:
	adrp	x1, .LC24
	mov	x0, x21
	add	x1, x1, :lo12:.LC24
	bl	_dev_err
	b	.L689
	.p2align 3
.L709:
	adrp	x1, .LC22
	mov	x0, x21
	add	x1, x1, :lo12:.LC22
	mov	w25, -19
	bl	_dev_err
	b	.L689
	.p2align 3
.L711:
	adrp	x1, .LC25
	mov	w2, 58720256
	add	x1, x1, :lo12:.LC25
	mov	x0, x21
	mov	w25, -19
	bl	_dev_err
	b	.L689
.L701:
	mov	w25, -19
	b	.L689
.L712:
	adrp	x1, .LC26
	mov	x0, x21
	add	x1, x1, :lo12:.LC26
	mov	w25, -12
	bl	_dev_err
	b	.L689
.L713:
	bl	__stack_chk_fail
	.size	ebc_buffer_manage_init, .-ebc_buffer_manage_init
	.align	2
	.p2align 3,,7
	.type	ebc_lut_table_init, %function
ebc_lut_table_init:
	stp	x29, x30, [sp, -176]!
	adrp	x1, .LC27
	add	x1, x1, :lo12:.LC27
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
	cbz	x0, .L719
	mov	x22, x0
	adrp	x1, .LC28
	add	x2, x29, 68
	add	x1, x1, :lo12:.LC28
	mov	x0, x21
	bl	of_get_property
	ldr	w1, [x29, 68]
	cmp	w1, 0
	ble	.L720
	bl	pvi_wf_add_custom_mode_table
	cbnz	w0, .L719
.L720:
	add	x2, x29, 72
	mov	w1, 0
	mov	x0, x22
	bl	of_address_to_resource
	mov	w21, w0
	cbz	w0, .L728
.L714:
	add	x19, x19, :lo12:__stack_chk_guard
	mov	w0, w21
	ldr	x2, [x29, 168]
	ldr	x1, [x19]
	eor	x1, x2, x1
	cbnz	x1, .L729
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldr	x23, [sp, 48]
	ldp	x29, x30, [sp], 176
	ret
	.p2align 3
.L728:
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
	cbz	x0, .L730
	bl	epd_lut_from_mem_init
	tbz	w0, #31, .L714
	ldr	x0, [x20, 96]
	adrp	x1, .LC30
	add	x1, x1, :lo12:.LC30
	bl	_dev_err
	ldr	x0, [x20, 96]
	mov	w2, w22
	ldr	x1, [x20, 200]
	bl	epd_lut_from_file_init
	tbz	w0, #31, .L714
	ldr	x0, [x20, 96]
	mov	w21, -1
	adrp	x1, .LC31
	add	x1, x1, :lo12:.LC31
	bl	_dev_err
	b	.L714
	.p2align 3
.L719:
	mov	w21, -19
	b	.L714
.L730:
	ldr	x0, [x20, 96]
	adrp	x2, .LANCHOR3
	adrp	x1, .LC29
	mov	w3, 3960
	add	x2, x2, :lo12:.LANCHOR3
	add	x1, x1, :lo12:.LC29
	mov	w21, -12
	bl	_dev_err
	b	.L714
.L729:
	bl	__stack_chk_fail
	.size	ebc_lut_table_init, .-ebc_lut_table_init
	.align	2
	.p2align 3,,7
	.type	ebc_lut_update, %function
ebc_lut_update:
	stp	x29, x30, [sp, -80]!
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	adrp	x19, __stack_chk_guard
	stp	x21, x22, [sp, 32]
	add	x3, x19, :lo12:__stack_chk_guard
	str	x23, [sp, 48]
	mov	x21, x0
	mov	w23, w2
	mov	w2, 25
	mov	w20, w1
	ldr	x1, [x3]
	str	x1, [x29, 72]
	mov	x1,0
	mov	w1, 1
	str	w2, [x29, 68]
	bl	ebc_power_set
	ldr	x0, [x21, 16]
	cbz	x0, .L732
	ldr	x2, [x0, 56]
	add	x1, x29, 68
	blr	x2
	mov	w3, w0
.L733:
	cbnz	w3, .L734
	ldr	w2, [x29, 68]
	add	x22, x21, 224
	ldr	w0, [x22, 624]
	tbnz	w2, #31, .L766
	cmp	w2, 50
	ble	.L737
	tbnz	w0, #31, .L739
	ldr	x0, [x22, 96]
	adrp	x1, .LC33
	add	x1, x1, :lo12:.LC33
	bl	_dev_info
	ldr	w0, [x22, 624]
.L739:
	mov	w2, 50
	str	w2, [x29, 68]
	cmp	w0, 0
	bgt	.L767
	.p2align 2
.L740:
	sub	w1, w20, #1
	cmp	w1, 22
	bls	.L768
.L759:
	mov	w1, 3
	.p2align 2
.L741:
	mov	w4, w23
	mov	w3, 32
	add	x0, x21, 328
	bl	epd_lut_get
	mov	w20, w0
	cbz	w0, .L731
	ldr	x0, [x22, 96]
	adrp	x1, .LC36
	add	x1, x1, :lo12:.LC36
	bl	_dev_err
.L731:
	add	x19, x19, :lo12:__stack_chk_guard
	mov	w0, w20
	ldr	x2, [x29, 72]
	ldr	x1, [x19]
	eor	x1, x2, x1
	cbnz	x1, .L769
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldr	x23, [sp, 48]
	ldp	x29, x30, [sp], 80
	ret
	.p2align 3
.L734:
	add	x22, x21, 224
	ldr	w0, [x22, 624]
	mov	w2, 25
	str	w2, [x29, 68]
	tbnz	w0, #31, .L740
	ldr	x0, [x22, 96]
	mov	w2, w3
	adrp	x1, .LC34
	add	x1, x1, :lo12:.LC34
	bl	_dev_info
	ldr	w0, [x22, 624]
	ldr	w2, [x29, 68]
.L737:
	cmp	w0, 0
	ble	.L740
.L767:
	ldr	x0, [x22, 96]
	adrp	x1, .LC35
	add	x1, x1, :lo12:.LC35
	bl	_dev_info
	sub	w1, w20, #1
	ldr	w2, [x29, 68]
	cmp	w1, 22
	bhi	.L759
.L768:
	adrp	x0, .L743
	add	x0, x0, :lo12:.L743
	ldrb	w0, [x0,w1,uxtw]
	adr	x1, .Lrtx743
	add	x0, x1, w0, sxtb #2
	br	x0
.Lrtx743:
	.section	.rodata
	.align	0
	.align	2
.L743:
	.byte	(.L742 - .Lrtx743) / 4
	.byte	(.L759 - .Lrtx743) / 4
	.byte	(.L744 - .Lrtx743) / 4
	.byte	(.L745 - .Lrtx743) / 4
	.byte	(.L746 - .Lrtx743) / 4
	.byte	(.L747 - .Lrtx743) / 4
	.byte	(.L748 - .Lrtx743) / 4
	.byte	(.L749 - .Lrtx743) / 4
	.byte	(.L750 - .Lrtx743) / 4
	.byte	(.L751 - .Lrtx743) / 4
	.byte	(.L747 - .Lrtx743) / 4
	.byte	(.L752 - .Lrtx743) / 4
	.byte	(.L752 - .Lrtx743) / 4
	.byte	(.L753 - .Lrtx743) / 4
	.byte	(.L754 - .Lrtx743) / 4
	.byte	(.L753 - .Lrtx743) / 4
	.byte	(.L755 - .Lrtx743) / 4
	.byte	(.L759 - .Lrtx743) / 4
	.byte	(.L759 - .Lrtx743) / 4
	.byte	(.L759 - .Lrtx743) / 4
	.byte	(.L759 - .Lrtx743) / 4
	.byte	(.L753 - .Lrtx743) / 4
	.byte	(.L754 - .Lrtx743) / 4
	.text
	.p2align 3
.L766:
	tbnz	w0, #31, .L736
	ldr	x0, [x22, 96]
	adrp	x1, .LC32
	add	x1, x1, :lo12:.LC32
	bl	_dev_info
	ldr	w0, [x22, 624]
.L736:
	mov	w2, 25
	str	w2, [x29, 68]
	b	.L737
	.p2align 3
.L745:
	mov	w1, 5
	b	.L741
	.p2align 3
.L754:
	mov	w1, 2
	b	.L741
	.p2align 3
.L752:
	mov	w1, 7
	b	.L741
	.p2align 3
.L753:
	mov	w1, 1
	b	.L741
	.p2align 3
.L742:
	mov	w1, 10
	b	.L741
	.p2align 3
.L744:
	mov	w1, 4
	b	.L741
	.p2align 3
.L746:
	mov	w1, 6
	b	.L741
	.p2align 3
.L747:
	mov	w1, 8
	b	.L741
	.p2align 3
.L748:
	ldr	w3, [x22, 612]
	mov	w1, 3
	mov	w0, 14
	cmp	w3, 0
	csel	w1, w1, w0, eq
	b	.L741
	.p2align 3
.L749:
	ldr	w3, [x22, 612]
	mov	w1, 4
	mov	w0, 13
	cmp	w3, 0
	csel	w1, w1, w0, eq
	b	.L741
	.p2align 3
.L750:
	mov	w1, 11
	ldr	w23, [x21, 192]
	b	.L741
	.p2align 3
.L751:
	mov	w1, 12
	ldr	w23, [x21, 192]
	b	.L741
	.p2align 3
.L755:
	mov	w1, 0
	b	.L741
	.p2align 3
.L732:
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
	b	.L733
.L769:
	bl	__stack_chk_fail
	.size	ebc_lut_update, .-ebc_lut_update
	.align	2
	.p2align 3,,7
	.type	wf_data_write, %function
wf_data_write:
	stp	x29, x30, [sp, -128]!
	adrp	x1, .LC37
	mov	x0, x2
	add	x1, x1, :lo12:.LC37
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	mov	x19, x3
	stp	x21, x22, [sp, 32]
	stp	x23, x24, [sp, 48]
	stp	x25, x26, [sp, 64]
	stp	x27, x28, [sp, 80]
	bl	strstr
	cbnz	x0, .L789
.L771:
	mov	x0, x19
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	ldp	x29, x30, [sp], 128
	ret
.L789:
	adrp	x1, .LANCHOR0
	adrp	x0, .LC38
	mov	w22, 0
	add	x0, x0, :lo12:.LC38
	ldr	x1, [x1, #:lo12:.LANCHOR0]
	adrp	x24, .LC39
	adrp	x25, .LC40
	ldrb	w23, [x1, 328]
	ldr	x28, [x1, 344]
	sub	w27, w23, #1
	mov	w1, w23
	ubfiz	x27, x27, 10, 32
	add	x27, x27, 1024
	bl	printk
	.p2align 2
.L772:
	mov	w21, w22
	add	x26, x25, :lo12:.LC40
	mov	w20, 0
	.p2align 2
.L774:
	mov	w2, w22
	mov	w1, w20
	add	x0, x24, :lo12:.LC39
	bl	printk
	cbnz	w23, .L773
.L777:
	add	w20, w20, 1
	add	w21, w21, 32
	cmp	w20, 32
	bne	.L774
	add	w22, w22, 1
	cmp	w22, 32
	bne	.L772
	b	.L771
.L773:
	sxtw	x2, w21
	add	x3, x27, x2
	add	x2, x28, x2
	add	x3, x28, x3
.L776:
	ldrb	w1, [x2]
	add	x2, x2, 1024
	mov	x0, x26
	stp	x2, x3, [x29, 104]
	str	x2, [x29, 120]
	bl	printk
	ldp	x3, x2, [x29, 112]
	cmp	x2, x3
	beq	.L777
	b	.L776
	.size	wf_data_write, .-wf_data_write
	.align	2
	.p2align 3,,7
	.type	ori_wf_data_write, %function
ori_wf_data_write:
	stp	x29, x30, [sp, -176]!
	mov	w0, -1
	mov	w1, 32960
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	mov	x19, x2
	stp	x25, x26, [sp, 64]
	adrp	x25, __stack_chk_guard
	stp	x27, x28, [sp, 80]
	add	x4, x25, :lo12:__stack_chk_guard
	stp	x21, x22, [sp, 32]
	mov	x28, x3
	stp	x23, x24, [sp, 48]
	movk	w1, 0x60, lsl 16
	stp	w0, w0, [x29, 128]
	mov	x0, 262144
	ldr	x2, [x4]
	str	x2, [x29, 168]
	mov	x2,0
	mov	w2, 6
	bl	kmalloc_order_trace
	cbz	x0, .L811
	mov	x26, x0
	adrp	x1, .LC37
	mov	x0, x19
	add	x1, x1, :lo12:.LC37
	str	x26, [x29, 152]
	bl	strstr
	cbz	x0, .L793
	add	x3, x29, 132
	add	x2, x29, 128
	mov	x0, x19
	adrp	x1, .LC42
	add	x1, x1, :lo12:.LC42
	bl	sscanf
	ldp	w2, w3, [x29, 128]
	adrp	x19, .LANCHOR3
	add	x1, x19, :lo12:.LANCHOR3
	adrp	x0, .LC43
	add	x1, x1, 24
	add	x0, x0, :lo12:.LC43
	bl	printk
	ldr	w1, [x29, 128]
	cmp	w1, 8
	bhi	.L794
	ldr	w2, [x29, 132]
	cmp	w2, 50
	bls	.L796
.L794:
	add	x1, x19, :lo12:.LANCHOR3
	adrp	x0, .LC45
	add	x1, x1, 24
	add	x0, x0, :lo12:.LC45
	bl	printk
.L790:
	add	x25, x25, :lo12:__stack_chk_guard
	mov	x0, x28
	ldr	x2, [x29, 168]
	ldr	x1, [x25]
	eor	x1, x2, x1
	cbnz	x1, .L812
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	ldp	x29, x30, [sp], 176
	ret
.L796:
	mov	w3, 32
	add	x0, x29, 136
	bl	epd_lut_get_original
	ldrb	w21, [x29, 136]
	adrp	x0, .LC38
	add	x0, x0, :lo12:.LC38
	sub	w27, w21, #1
	mov	w1, w21
	ubfiz	x27, x27, 10, 32
	bl	printk
	add	x0, x27, 1024
	mov	w20, 0
	adrp	x22, .LC39
	adrp	x23, .LC40
	str	x0, [x29, 120]
	.p2align 2
.L797:
	mov	w27, w20
	add	x24, x23, :lo12:.LC40
	mov	w19, 0
	.p2align 2
.L799:
	mov	w2, w20
	mov	w1, w19
	add	x0, x22, :lo12:.LC39
	bl	printk
	cbnz	w21, .L798
.L802:
	add	w19, w19, 1
	add	w27, w27, 32
	cmp	w19, 32
	bne	.L799
	add	w20, w20, 1
	cmp	w20, 32
	bne	.L797
	mov	x0, x26
	bl	kfree
	b	.L790
.L798:
	ldr	x0, [x29, 120]
	sxtw	x2, w27
	add	x4, x0, x2
	add	x2, x26, x2
	add	x4, x26, x4
.L801:
	ldrb	w1, [x2]
	add	x2, x2, 1024
	mov	x0, x24
	stp	x2, x4, [x29, 96]
	str	x2, [x29, 112]
	bl	printk
	ldp	x4, x2, [x29, 104]
	cmp	x2, x4
	beq	.L802
	b	.L801
.L793:
	adrp	x1, .LANCHOR3
	add	x1, x1, :lo12:.LANCHOR3
	adrp	x0, .LC44
	add	x1, x1, 24
	add	x0, x0, :lo12:.LC44
	bl	printk
	b	.L790
.L811:
	adrp	x0, .LC41
	add	x0, x0, :lo12:.LC41
	bl	printk
	b	.L790
.L812:
	bl	__stack_chk_fail
	.size	ori_wf_data_write, .-ori_wf_data_write
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
	cbnz	w0, .L818
	ldr	w1, [x29, 52]
	mov	x0, x20
	str	w1, [x22, 848]
.L813:
	add	x19, x19, :lo12:__stack_chk_guard
	ldr	x2, [x29, 56]
	ldr	x1, [x19]
	eor	x1, x2, x1
	cbnz	x1, .L819
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 64
	ret
	.p2align 3
.L818:
	ldr	x0, [x22, 320]
	adrp	x1, .LC46
	mov	x2, x21
	add	x1, x1, :lo12:.LC46
	bl	_dev_err
	mov	x0, -1
	b	.L813
.L819:
	bl	__stack_chk_fail
	.size	ebc_debug_level_write, .-ebc_debug_level_write
	.align	2
	.p2align 3,,7
	.type	ebc_debug_level_read, %function
ebc_debug_level_read:
	stp	x29, x30, [sp, -16]!
	adrp	x3, .LANCHOR0
	mov	x0, x2
	adrp	x1, .LC47
	add	x29, sp, 0
	ldr	x2, [x3, #:lo12:.LANCHOR0]
	add	x1, x1, :lo12:.LC47
	ldr	w2, [x2, 848]
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
	adrp	x1, .LC47
	add	x29, sp, 0
	ldr	x2, [x3, #:lo12:.LANCHOR0]
	add	x1, x1, :lo12:.LC47
	ldr	w2, [x2, 680]
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
	adrp	x1, .LC49
	adrp	x2, .LC48
	add	x29, sp, 0
	add	x2, x2, :lo12:.LC48
	add	x1, x1, :lo12:.LC49
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
	cbz	x0, .L827
	ldr	x2, [x0, 56]
	add	x1, x29, 36
	blr	x2
.L828:
	ldr	w2, [x29, 36]
	adrp	x1, .LC47
	mov	x0, x20
	add	x1, x1, :lo12:.LC47
	add	x19, x19, :lo12:__stack_chk_guard
	bl	sprintf
	sxtw	x0, w0
	ldr	x2, [x29, 40]
	ldr	x1, [x19]
	eor	x1, x2, x1
	cbnz	x1, .L831
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 48
	ret
	.p2align 3
.L827:
	ldr	x0, [x1, 32]
	add	x1, x29, 36
	bl	thermal_zone_get_temp
	b	.L828
.L831:
	bl	__stack_chk_fail
	.size	pmic_temp_read, .-pmic_temp_read
	.align	2
	.p2align 3,,7
	.type	pmic_name_read, %function
pmic_name_read:
	stp	x29, x30, [sp, -16]!
	adrp	x3, .LANCHOR0
	mov	x0, x2
	adrp	x1, .LC49
	add	x29, sp, 0
	ldr	x2, [x3, #:lo12:.LANCHOR0]
	add	x1, x1, :lo12:.LC49
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
	cbnz	w0, .L845
	ldr	x0, [x21, 16]
	ldr	w1, [x29, 52]
	cbz	x0, .L839
	bl	ebc_pmic_set_vcom
.L840:
	cbnz	w0, .L846
.L836:
	add	x19, x19, :lo12:__stack_chk_guard
	mov	x0, x20
	ldr	x2, [x29, 56]
	ldr	x1, [x19]
	eor	x1, x2, x1
	cbnz	x1, .L847
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 64
	ret
	.p2align 3
.L839:
	ldr	x0, [x21, 24]
	bl	ebc_regulator_set_vcom
	b	.L840
	.p2align 3
.L845:
	ldr	x0, [x21]
	adrp	x1, .LC46
	mov	x2, x22
	add	x1, x1, :lo12:.LC46
	mov	x20, -1
	bl	_dev_err
	b	.L836
	.p2align 3
.L846:
	ldr	x0, [x21]
	adrp	x1, .LC50
	mov	x20, -1
	add	x1, x1, :lo12:.LC50
	bl	_dev_err
	b	.L836
.L847:
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
	cbz	x0, .L849
	ldr	x1, [x0, 64]
	blr	x1
	mov	w2, w0
	adrp	x1, .LC47
	mov	x0, x19
	add	x1, x1, :lo12:.LC47
	bl	sprintf
	sxtw	x0, w0
	ldr	x19, [sp, 16]
	ldp	x29, x30, [sp], 32
	ret
	.p2align 3
.L849:
	ldr	x0, [x1, 24]
	bl	regulator_get_voltage
	mov	w2, 19923
	adrp	x1, .LC47
	movk	w2, 0x1062, lsl 16
	add	x1, x1, :lo12:.LC47
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
	adrp	x1, .LC49
	mov	x0, x19
	add	x1, x1, :lo12:.LC49
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
	bgt	.L856
	mul	w18, w21, w6
	mov	w19, 1
	mov	w16, w19
	lsl	w0, w7, 3
	str	w0, [x29, 112]
	.p2align 2
.L860:
	and	w0, w21, 1
	tbnz	x21, 0, .L861
	ldr	x5, [x29, 96]
	ldr	w13, [x5, 76]
	ldr	x5, [x29, 104]
	mul	w13, w21, w13
	lsr	w13, w13, 2
	add	x13, x5, x13
.L861:
	mul	w17, w21, w17
	ldr	w5, [x29, 124]
	cmp	w5, w30
	sxtw	x17, w17
	bgt	.L874
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
.L873:
	sxtw	x8, w9
	lsl	x0, x8, 3
	add	x0, x0, x18, sxtw 3
	ldr	x7, [x1, x0]
	ldr	x6, [x2, x0]
	cmp	x7, x6
	beq	.L864
	add	x12, x17, x11, sxtw
	str	w19, [x4, 60]
	eor	x5, x7, x6
	add	x0, x3, x12
	and	x14, x5, 255
	mov	w10, 0
	ldrb	w15, [x3, x12]
	cmp	w15, 0
	ccmp	x14, 0, 4, eq
	beq	.L865
	lsl	x10, x6, 2
	ldr	x14, [x4, 120]
	and	x10, x10, 992
	ubfx	x15, x7, 3, 5
	orr	x10, x10, x15
	ldrb	w10, [x14, x10]
	strb	w19, [x3, x12]
	lsl	w10, w10, w20
.L865:
	ldrb	w12, [x0, 1]
	cmp	w12, 0
	and	x12, x5, 65280
	ccmp	x12, 0, 4, eq
	beq	.L866
	lsr	x12, x6, 6
	ldr	x14, [x4, 120]
	and	x12, x12, 992
	ubfx	x15, x7, 11, 5
	orr	x12, x12, x15
	ldrb	w12, [x14, x12]
	strb	w16, [x0, 1]
	lsl	w12, w12, w28
	orr	w10, w10, w12
.L866:
	ldrb	w12, [x0, 2]
	cmp	w12, 0
	and	x12, x5, 16711680
	ccmp	x12, 0, 4, eq
	beq	.L867
	lsr	x12, x6, 14
	ldr	x14, [x4, 120]
	and	x12, x12, 992
	ubfx	x15, x7, 19, 5
	orr	x12, x12, x15
	ldrb	w12, [x14, x12]
	strb	w16, [x0, 2]
	lsl	w12, w12, w27
	orr	w10, w10, w12
.L867:
	ldrb	w12, [x0, 3]
	tst	x5, 4278190080
	ccmp	w12, 0, 0, ne
	bne	.L868
	lsr	x12, x6, 22
	ldr	x14, [x4, 120]
	and	x12, x12, 992
	lsr	w15, w7, 27
	orr	x12, x12, x15
	ldrb	w12, [x14, x12]
	strb	w16, [x0, 3]
	lsl	w12, w12, w26
	orr	w10, w10, w12
.L868:
	ldrb	w12, [x0, 4]
	cmp	w12, 0
	and	x12, x5, 1095216660480
	ccmp	x12, 0, 4, eq
	beq	.L869
	lsr	x12, x6, 30
	ldr	x14, [x4, 120]
	and	x12, x12, 992
	ubfx	x15, x7, 35, 5
	orr	x12, x12, x15
	ldrb	w12, [x14, x12]
	strb	w16, [x0, 4]
	lsl	w12, w12, w25
	orr	w10, w10, w12
.L869:
	ldrb	w12, [x0, 5]
	cmp	w12, 0
	and	x12, x5, 280375465082880
	ccmp	x12, 0, 4, eq
	beq	.L870
	lsr	x12, x6, 38
	ldr	x14, [x4, 120]
	and	x12, x12, 992
	ubfx	x15, x7, 43, 5
	orr	x12, x12, x15
	ldrb	w12, [x14, x12]
	strb	w16, [x0, 5]
	lsl	w12, w12, w24
	orr	w10, w10, w12
.L870:
	ldrb	w12, [x0, 6]
	tst	x5, 71776119061217280
	ccmp	w12, 0, 0, ne
	bne	.L871
	lsr	x12, x6, 46
	ldr	x14, [x4, 120]
	and	x12, x12, 992
	ubfx	x15, x7, 51, 5
	orr	x12, x12, x15
	ldrb	w12, [x14, x12]
	strb	w16, [x0, 6]
	lsl	w12, w12, w23
	orr	w10, w10, w12
.L871:
	tst	x5, -72057594037927936
	ldrb	w5, [x0, 7]
	ccmp	w5, 0, 0, ne
	bne	.L872
	ldr	x5, [x4, 120]
	lsr	x6, x6, 54
	and	x6, x6, 992
	add	x7, x5, x7, lsr 59
	ldrb	w5, [x7, x6]
	strb	w16, [x0, 7]
	lsl	w0, w5, w22
	orr	w10, w10, w0
.L872:
	ldr	w0, [x13, x8, lsl 2]
	orr	w10, w0, w10
	str	w10, [x13, x8, lsl 2]
.L864:
	add	w9, w9, 1
	add	w11, w11, 8
	cmp	w9, w30
	ble	.L873
.L874:
	ldr	w0, [x29, 116]
	add	w21, w21, 1
	add	w18, w18, w0
	ldr	w0, [x29, 120]
	cmp	w21, w0
	bgt	.L856
	ldr	w17, [x4, 84]
	b	.L860
.L856:
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
	cbz	x9, .L901
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
	beq	.L940
.L902:
	strb	w9, [x2]
.L901:
	tst	x8, 65280
	beq	.L903
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
	beq	.L941
.L904:
	strb	w9, [x2, 1]
.L903:
	tst	x8, 16711680
	beq	.L905
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
	beq	.L942
.L906:
	strb	w9, [x2, 2]
.L905:
	tst	x8, 4278190080
	beq	.L907
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
	beq	.L943
.L908:
	strb	w9, [x2, 3]
.L907:
	tst	x8, 1095216660480
	beq	.L909
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
	beq	.L944
.L910:
	strb	w9, [x2, 4]
.L909:
	tst	x8, 280375465082880
	beq	.L911
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
	beq	.L945
.L912:
	strb	w9, [x2, 5]
.L911:
	tst	x8, 71776119061217280
	beq	.L913
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
	beq	.L946
.L914:
	strb	w9, [x2, 6]
.L913:
	tst	x8, -72057594037927936
	beq	.L915
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
	beq	.L947
.L916:
	strb	w4, [x2, 7]
.L915:
	mov	w0, w7
	str	x6, [x1]
	ret
	.p2align 3
.L947:
	and	x6, x6, 72057594037927935
	and	x0, x0, -72057594037927936
	orr	x6, x0, x6
	mov	w4, 0
	b	.L916
	.p2align 3
.L940:
	bfi	x6, x0, 0, 8
	mov	w9, 0
	b	.L902
	.p2align 3
.L941:
	and	x9, x0, 65280
	and	x6, x6, -65281
	orr	x6, x9, x6
	mov	w9, 0
	b	.L904
	.p2align 3
.L942:
	and	x9, x0, 16711680
	and	x6, x6, -16711681
	orr	x6, x9, x6
	mov	w9, 0
	b	.L906
	.p2align 3
.L943:
	and	x9, x0, 4278190080
	and	x6, x6, -4278190081
	orr	x6, x9, x6
	mov	w9, 0
	b	.L908
	.p2align 3
.L944:
	and	x9, x0, 1095216660480
	and	x6, x6, -1095216660481
	orr	x6, x9, x6
	mov	w9, 0
	b	.L910
	.p2align 3
.L945:
	and	x9, x0, 280375465082880
	and	x6, x6, -280375465082881
	orr	x6, x9, x6
	mov	w9, 0
	b	.L912
	.p2align 3
.L946:
	and	x9, x0, 71776119061217280
	and	x6, x6, -71776119061217281
	orr	x6, x9, x6
	mov	w9, 0
	b	.L914
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
	beq	.L967
	cmp	w5, 3
	mov	x0, 0
	mov	w23, 0
	beq	.L968
.L950:
	ldr	x2, [x29, 112]
	add	x0, x2, x0
	sub	w2, w25, w23
	mul	w2, w2, w1
	mov	w1, 0
	lsr	w2, w2, 2
	bl	memset
	cmp	w23, w25
	bge	.L959
	ldr	w0, [x29, 124]
	add	x13, x19, 120
	mov	w9, 0
	sub	w14, w0, #1
	add	x14, x14, 1
	lsl	x12, x14, 2
	lsl	x14, x14, 3
	.p2align 2
.L957:
	ldr	w7, [x24, 76]
	ldr	x0, [x29, 112]
	mul	w7, w23, w7
	lsr	w7, w7, 2
	add	x26, x0, x7
	ldr	w0, [x29, 124]
	cbz	w0, .L952
	mov	x28, x22
	mov	x15, x21
	mov	x27, x20
	mov	x18, 0
	.p2align 2
.L954:
	ldr	x3, [x27]
	mov	x2, x28
	ldr	x10, [x15]
	mov	x1, x15
	mov	w5, 0
	mov	x4, x13
	mov	x0, x3
	cmp	x3, x10
	beq	.L953
	ldrb	w3, [x19, 56]
	bl	get_one_auto_image2.isra.1
	str	w0, [x26, x18]
	mov	w9, 1
.L953:
	add	x18, x18, 4
	add	x15, x15, 8
	add	x27, x27, 8
	add	x28, x28, 8
	cmp	x18, x12
	bne	.L954
	add	x21, x21, x14
	add	x20, x20, x14
	add	x22, x22, x14
	mov	x18, x21
	mov	x27, x22
	mov	x28, x20
	mov	x15, 0
	.p2align 2
.L956:
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
	beq	.L955
	ldrb	w3, [x19, 56]
	bl	get_one_auto_image2.isra.1
	ldr	w1, [x26, x15]
	mov	w9, 1
	orr	w0, w1, w0
	str	w0, [x26, x15]
.L955:
	add	x15, x15, 4
	add	x27, x27, 8
	cmp	x15, x12
	bne	.L956
	add	x21, x21, x14
	add	x20, x20, x14
	add	x22, x22, x14
.L952:
	add	w23, w23, 2
	cmp	w25, w23
	bgt	.L957
.L951:
	ldr	x0, [x29, 104]
	str	w9, [x0]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	ldp	x29, x30, [sp], 128
	ret
.L967:
	add	w25, w25, w25, lsr 31
	mov	x0, 0
	asr	w25, w25, 1
	mov	w23, 0
	b	.L950
.L968:
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
	b	.L950
.L959:
	mov	w9, 0
	b	.L951
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
	beq	.L989
	cmp	w6, 3
	mov	w14, w3
	mov	w6, 0
	mov	w12, 0
	beq	.L990
.L971:
	ldr	w4, [x4, 156]
	cbz	w4, .L972
	sub	w3, w3, #1
	neg	w15, w7, lsr 2
	sub	w3, w3, w6
	mul	w3, w3, w7
	lsr	w3, w3, 2
	add	x10, x0, x3
.L975:
	cmp	w12, w14
	bge	.L983
	sub	w13, w11, #1
	sxtw	x15, w15
	add	x13, x13, 1
	lsl	x13, x13, 3
.L984:
	mov	x6, 0
	cbz	w11, .L991
	stp	x29, x30, [sp, -32]!
	add	x29, sp, 0
	str	x19, [sp, 16]
	.p2align 2
.L980:
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
	bgt	.L980
	add	w12, w12, 1
	add	x1, x1, x13
	add	x2, x2, x13
	add	x10, x10, x15
	cmp	w12, w14
	beq	.L969
.L992:
	mov	x6, 0
	cbnz	w11, .L980
	add	w12, w12, 1
	add	x10, x10, x15
	cmp	w12, w14
	bne	.L992
.L969:
	ldr	x19, [sp, 16]
	ldp	x29, x30, [sp], 32
	ret
.L991:
	add	w12, w12, 1
	add	x10, x10, x15
	cmp	w12, w14
	bne	.L984
.L983:
	ret
.L972:
	mul	w3, w7, w6
	lsr	w15, w7, 2
	lsr	w3, w3, 2
	add	x10, x0, x3
	b	.L975
.L989:
	add	w14, w3, w3, lsr 31
	mov	w6, 0
	asr	w14, w14, 1
	mov	w12, 0
	b	.L971
.L990:
	add	w12, w3, w3, lsr 31
	asr	w12, w12, 1
	mov	w6, w12
	mul	w8, w11, w12
	sbfiz	x8, x8, 3, 32
	add	x1, x1, x8
	add	x2, x2, x8
	b	.L971
	.size	direct_mode_data_change.isra.2, .-direct_mode_data_change.isra.2
	.align	2
	.p2align 3,,7
	.type	is_full_refresh_area.isra.3, %function
is_full_refresh_area.isra.3:
	add	w6, w0, w0, lsr 31
	subs	w4, w4, w6, asr 1
	add	w6, w1, w1, lsr 31
	csneg	w7, w4, w4, pl
	subs	w6, w5, w6, asr 1
	csneg	w8, w6, w6, pl
	cmp	w2, 2
	beq	.L995
	ble	.L1001
	cmp	w2, 3
	beq	.L998
	cmp	w2, 4
	bne	.L994
	cmp	w7, w3
	cset	w0, le
	cmp	w8, w3
	cset	w1, le
	orr	w0, w0, w1
	ret
	.p2align 3
.L998:
	mul	w0, w0, w3
	sdiv	w1, w0, w1
	cmp	w7, w1
	cset	w0, le
	cmp	w8, w3
	cset	w1, le
	and	w0, w0, w1
	ret
	.p2align 3
.L1001:
	cmp	w2, 1
	bne	.L994
	mul	w6, w6, w6
	mul	w3, w3, w3
	madd	w4, w4, w4, w6
	cmp	w3, w4
	cset	w0, ge
	ret
	.p2align 3
.L994:
	cmp	w5, w3
	cset	w0, lt
	ret
	.p2align 3
.L995:
	mul	w0, w0, w3
	add	w7, w7, w8
	sdiv	w1, w0, w1
	cmp	w1, w7
	cset	w0, ge
	cmp	w7, w3
	cset	w1, le
	and	w0, w0, w1
	ret
	.size	is_full_refresh_area.isra.3, .-is_full_refresh_area.isra.3
	.align	2
	.p2align 3,,7
	.type	direct_mode_data_change_full, %function
direct_mode_data_change_full:
	stp	x29, x30, [sp, -64]!
	adrp	x5, .LANCHOR0
	mov	x12, x3
	mov	x18, x2
	add	x29, sp, 0
	ldr	x3, [x5, #:lo12:.LANCHOR0]
	mov	x15, x1
	stp	x21, x22, [sp, 32]
	cmp	w4, 2
	add	x2, x3, 40
	stp	x19, x20, [sp, 16]
	stp	x23, x24, [sp, 48]
	ldp	w20, w1, [x2, 76]
	ldr	x24, [x12, 160]
	lsr	w22, w20, 3
	beq	.L1021
	mov	w21, w1
	cmp	w4, 3
	mov	w14, 0
	beq	.L1022
.L1004:
	ldr	w2, [x2, 156]
	lsr	w20, w20, 2
	cbz	w2, .L1005
	sub	w1, w1, #1
	sub	w1, w1, w14
	mul	w1, w1, w20
	neg	w20, w20
	add	x19, x0, x1
.L1008:
	cmp	w14, w21
	bge	.L1002
	sub	w13, w22, #1
	sxtw	x20, w20
	add	x13, x13, 1
	lsl	x13, x13, 3
	.p2align 2
.L1007:
	mov	x23, x19
	mov	x11, 0
	cbnz	w22, .L1018
	b	.L1016
	.p2align 3
.L1024:
	ldrb	w16, [x24, x11]
.L1010:
	lsr	x7, x9, 30
	lsr	x5, x9, 22
	and	x3, x7, 992
	ubfx	x7, x10, 35, 5
	lsr	x6, x9, 6
	and	x0, x5, 992
	orr	x7, x3, x7
	lsr	w5, w10, 27
	lsr	x3, x9, 38
	lsr	x4, x9, 46
	and	x2, x6, 992
	orr	x5, x0, x5
	ubfx	x6, x10, 11, 5
	and	x0, x3, 992
	ubfx	x3, x10, 43, 5
	lsr	x8, x9, 14
	and	x1, x4, 992
	orr	x6, x2, x6
	ubfx	x4, x10, 51, 5
	lsl	x2, x9, 2
	orr	x3, x0, x3
	ldrb	w0, [x12, 56]
	and	x30, x8, 992
	orr	x4, x1, x4
	ubfx	x8, x10, 19, 5
	and	x2, x2, 992
	ubfx	x1, x10, 3, 5
	lsr	x9, x9, 54
	ubfiz	x17, x16, 10, 8
	orr	x8, x30, x8
	orr	x2, x2, x1
	and	x9, x9, 992
	cmp	w0, w16
	bgt	.L1012
	strh	wzr, [x23]
	add	x11, x11, 8
	add	x23, x23, 2
	cmp	x13, x11
	beq	.L1023
.L1018:
	ldr	x10, [x15, x11]
	mov	w5, w11
	ldr	x9, [x18, x11]
	mov	w4, w14
	ldp	w0, w1, [x12, 80]
	ldr	w2, [x12, 676]
	ldr	w3, [x12, 684]
	bl	is_full_refresh_area.isra.3
	tst	w0, 255
	beq	.L1024
	ldrb	w16, [x24, x11]
	cmp	x16, 255
	bne	.L1010
	str	xzr, [x24, x11]
	mov	w16, 0
	b	.L1010
	.p2align 3
.L1012:
	ldr	x0, [x12, 120]
	add	x23, x23, 2
	add	x0, x0, x17
	add	x10, x0, x10, lsr 59
	ldrb	w7, [x0, x7]
	ldrb	w8, [x0, x8]
	ldrb	w1, [x0, x6]
	ldrb	w5, [x0, x5]
	lsl	w6, w7, 8
	ldrb	w4, [x0, x4]
	ldrb	w3, [x0, x3]
	ldrb	w16, [x0, x2]
	lsl	w0, w8, 4
	ldrb	w2, [x10, x9]
	orr	w0, w0, w1, lsl 2
	orr	w5, w6, w5, lsl 6
	lsl	w4, w4, 12
	orr	w0, w0, w5
	orr	w3, w4, w3, lsl 10
	orr	w1, w16, w2, lsl 14
	orr	w0, w0, w3
	orr	w0, w0, w1
	strh	w0, [x23, -2]
	ldr	x0, [x24, x11]
	add	x0, x0, 1
	str	x0, [x24, x11]
	add	x11, x11, 8
	cmp	x13, x11
	bne	.L1018
.L1023:
	add	x15, x15, x13
	add	x18, x18, x13
	add	x24, x24, x13
.L1016:
	add	w14, w14, 1
	add	x19, x19, x20
	cmp	w21, w14
	bne	.L1007
.L1002:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x29, x30, [sp], 64
	ret
.L1005:
	mul	w19, w14, w20
	add	x19, x0, x19, sxtw
	b	.L1008
.L1021:
	add	w21, w1, w1, lsr 31
	mov	w14, 0
	asr	w21, w21, 1
	b	.L1004
.L1022:
	add	w14, w1, w1, lsr 31
	asr	w14, w14, 1
	mul	w3, w22, w14
	sbfiz	x3, x3, 3, 32
	add	x15, x15, x3
	add	x18, x18, x3
	add	x24, x24, x3
	b	.L1004
	.size	direct_mode_data_change_full, .-direct_mode_data_change_full
	.align	2
	.p2align 3,,7
	.type	direct_mode_data_change_full2, %function
direct_mode_data_change_full2:
	stp	x29, x30, [sp, -80]!
	adrp	x5, .LANCHOR0
	mov	x10, x3
	cmp	w4, 2
	add	x29, sp, 0
	stp	x21, x22, [sp, 32]
	mov	x21, x0
	ldr	x0, [x5, #:lo12:.LANCHOR0]
	stp	x23, x24, [sp, 48]
	mov	x23, x1
	stp	x19, x20, [sp, 16]
	mov	x24, x2
	stp	x25, x26, [sp, 64]
	ldp	w15, w18, [x0, 116]
	ldr	x12, [x3, 160]
	lsr	w19, w15, 3
	beq	.L1052
	mov	w14, 0
	cmp	w4, 3
	beq	.L1053
.L1027:
	lsr	w15, w15, 2
	cmp	w14, w18
	bge	.L1025
	sub	w13, w19, #1
	lsl	w20, w15, 1
	add	x13, x13, 1
	mul	w15, w14, w15
	lsl	x13, x13, 3
	.p2align 2
.L1042:
	add	x22, x21, x15, sxtw
	cbz	w19, .L1029
	mov	x25, 0
	mov	x26, x22
	b	.L1035
	.p2align 3
.L1055:
	ldrb	w16, [x12, x25]
.L1031:
	lsr	x8, x9, 14
	lsr	x7, x9, 30
	and	x1, x8, 992
	lsr	x5, x9, 22
	and	x3, x7, 992
	lsr	x4, x9, 46
	ubfx	x8, x11, 19, 5
	ubfx	x7, x11, 35, 5
	and	x2, x5, 992
	orr	x8, x1, x8
	lsr	w5, w11, 27
	and	x1, x4, 992
	orr	x7, x3, x7
	ubfx	x4, x11, 51, 5
	lsr	x3, x9, 38
	orr	x5, x2, x5
	orr	x4, x1, x4
	and	x2, x3, 992
	lsl	x1, x9, 2
	ubfx	x3, x11, 43, 5
	and	x1, x1, 992
	orr	x3, x2, x3
	ubfx	x2, x11, 3, 5
	lsr	x6, x9, 6
	orr	x2, x2, x1
	ldrb	w1, [x10, 56]
	and	x17, x6, 992
	lsr	x9, x9, 54
	ubfx	x6, x11, 11, 5
	ubfiz	x0, x16, 10, 8
	orr	x6, x17, x6
	and	x9, x9, 992
	cmp	w1, w16
	bgt	.L1033
	str	wzr, [x26]
	add	x25, x25, 8
	add	x26, x26, 4
	cmp	x13, x25
	beq	.L1054
.L1035:
	ldr	x11, [x23, x25]
	mov	w5, w25
	ldr	x9, [x24, x25]
	mov	w4, w14
	ldp	w0, w1, [x10, 80]
	ldr	w2, [x10, 676]
	ldr	w3, [x10, 684]
	bl	is_full_refresh_area.isra.3
	tst	w0, 255
	beq	.L1055
	ldrb	w16, [x12, x25]
	cmp	x16, 255
	bne	.L1031
	str	xzr, [x12, x25]
	mov	w16, 0
	b	.L1031
	.p2align 3
.L1033:
	ldr	x1, [x10, 120]
	add	x25, x25, 8
	add	x26, x26, 4
	cmp	x13, x25
	add	x0, x1, x0
	add	x11, x0, x11, lsr 59
	ldrb	w7, [x0, x7]
	ldrb	w8, [x0, x8]
	ldrb	w1, [x0, x6]
	ldrb	w5, [x0, x5]
	lsl	w6, w7, 16
	ldrb	w4, [x0, x4]
	ldrb	w3, [x0, x3]
	ldrb	w16, [x0, x2]
	lsl	w0, w8, 8
	ldrb	w2, [x11, x9]
	orr	w0, w0, w1, lsl 4
	orr	w5, w6, w5, lsl 12
	lsl	w4, w4, 24
	orr	w0, w0, w5
	orr	w3, w4, w3, lsl 20
	orr	w1, w16, w2, lsl 28
	orr	w0, w0, w3
	orr	w0, w0, w1
	str	w0, [x26, -4]
	bne	.L1035
.L1054:
	add	x25, x12, x13
	add	x23, x23, x13
	add	x24, x24, x13
	mov	x12, 0
	b	.L1041
	.p2align 3
.L1057:
	ldrb	w16, [x25, x12]
.L1037:
	lsr	x8, x9, 6
	lsr	x5, x9, 14
	and	x0, x8, 992
	ubfx	x8, x11, 11, 5
	lsr	x7, x9, 22
	lsl	x6, x9, 2
	lsr	x3, x9, 30
	orr	x8, x0, x8
	and	x0, x5, 992
	ubfx	x5, x11, 19, 5
	and	x1, x7, 992
	lsr	x4, x9, 38
	and	x2, x6, 992
	lsr	w7, w11, 27
	ubfx	x6, x11, 3, 5
	orr	x5, x0, x5
	and	x0, x3, 992
	ubfx	x3, x11, 35, 5
	orr	x7, x1, x7
	orr	x6, x2, x6
	and	x1, x4, 992
	lsr	x2, x9, 46
	ubfx	x4, x11, 43, 5
	orr	x3, x0, x3
	ldrb	w0, [x10, 56]
	orr	x4, x1, x4
	lsr	x9, x9, 54
	and	x2, x2, 992
	ubfx	x1, x11, 51, 5
	ubfiz	x17, x16, 10, 8
	and	x9, x9, 992
	orr	x1, x2, x1
	cmp	w0, w16
	bgt	.L1039
	str	wzr, [x22]
.L1040:
	add	x12, x12, 8
	add	x22, x22, 4
	cmp	x12, x13
	beq	.L1056
.L1041:
	ldr	x11, [x23, x12]
	mov	w5, w12
	ldr	x9, [x24, x12]
	mov	w4, w14
	ldp	w0, w1, [x10, 80]
	ldr	w2, [x10, 676]
	ldr	w3, [x10, 684]
	bl	is_full_refresh_area.isra.3
	tst	w0, 255
	beq	.L1057
	ldrb	w16, [x25, x12]
	cmp	x16, 255
	bne	.L1037
	str	xzr, [x25, x12]
	mov	w16, 0
	b	.L1037
	.p2align 3
.L1056:
	add	x23, x23, x13
	add	x24, x24, x13
	add	x12, x25, x13
.L1029:
	add	w14, w14, 2
	add	w15, w15, w20
	cmp	w18, w14
	bgt	.L1042
.L1025:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x29, x30, [sp], 80
	ret
	.p2align 3
.L1039:
	ldr	x0, [x10, 120]
	ldr	w2, [x22]
	add	x0, x0, x17
	add	x11, x0, x11, lsr 59
	ldrb	w16, [x0, x8]
	ldrb	w8, [x0, x7]
	ldrb	w6, [x0, x6]
	ldrb	w7, [x0, x5]
	ldrb	w5, [x0, x4]
	lsl	w8, w8, 14
	ldrb	w4, [x0, x3]
	ldrb	w3, [x11, x9]
	ldrb	w1, [x0, x1]
	lsl	w0, w16, 6
	orr	w0, w0, w6, lsl 2
	lsl	w5, w5, 22
	orr	w6, w8, w7, lsl 10
	orr	w4, w5, w4, lsl 18
	orr	w0, w0, w6
	lsl	w3, w3, 30
	orr	w0, w0, w4
	orr	w1, w3, w1, lsl 26
	orr	w0, w0, w1
	orr	w0, w2, w0
	str	w0, [x22]
	b	.L1040
.L1052:
	add	w18, w18, w18, lsr 31
	mov	w14, 0
	asr	w18, w18, 1
	b	.L1027
.L1053:
	add	w14, w18, w18, lsr 31
	asr	w14, w14, 1
	mul	w0, w19, w14
	sbfiz	x0, x0, 3, 32
	add	x23, x1, x0
	add	x24, x2, x0
	add	x12, x12, x0
	b	.L1027
	.size	direct_mode_data_change_full2, .-direct_mode_data_change_full2
	.align	2
	.p2align 3,,7
	.type	direct_mode_data_change2.isra.4, %function
direct_mode_data_change2.isra.4:
	adrp	x7, .LANCHOR0
	and	w3, w3, 255
	sub	w3, w3, w4
	cmp	w6, 2
	ldr	x4, [x7, #:lo12:.LANCHOR0]
	lsl	w3, w3, 10
	add	x5, x5, x3, sxtw
	ldp	w13, w14, [x4, 116]
	lsr	w9, w13, 3
	beq	.L1082
	mov	w11, 0
	cmp	w6, 3
	beq	.L1083
.L1060:
	lsr	w13, w13, 2
	cmp	w14, w11
	ble	.L1075
.L1086:
	sub	w10, w9, #1
	mul	w12, w13, w11
	add	x10, x10, 1
	lsl	w13, w13, 1
	lsl	x10, x10, 3
.L1076:
	add	x8, x0, x12, sxtw
	cbz	w9, .L1084
	stp	x29, x30, [sp, -48]!
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	.p2align 2
.L1077:
	mov	x7, 0
	.p2align 2
.L1063:
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
	bgt	.L1063
	add	x1, x1, x10
	add	x2, x2, x10
	mov	x7, 0
	.p2align 2
.L1064:
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
	bgt	.L1064
	add	w11, w11, 2
	add	x1, x1, x10
	add	x2, x2, x10
	add	w12, w12, w13
	cmp	w11, w14
	bge	.L1085
.L1065:
	add	x8, x0, x12, sxtw
	cbnz	w9, .L1077
	add	w11, w11, 2
	add	w12, w12, w13
	cmp	w11, w14
	blt	.L1065
.L1085:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 48
	ret
.L1084:
	add	w11, w11, 2
	add	w12, w12, w13
	cmp	w11, w14
	blt	.L1076
	ret
.L1082:
	add	w14, w14, w14, lsr 31
	mov	w11, 0
	asr	w14, w14, 1
	lsr	w13, w13, 2
	cmp	w14, w11
	bgt	.L1086
.L1075:
	ret
.L1083:
	add	w11, w14, w14, lsr 31
	asr	w11, w11, 1
	mul	w3, w9, w11
	sbfiz	x3, x3, 3, 32
	add	x1, x1, x3
	add	x2, x2, x3
	b	.L1060
	.size	direct_mode_data_change2.isra.4, .-direct_mode_data_change2.isra.4
	.align	2
	.p2align 3,,7
	.type	direct_mode_data_change_part2.isra.9, %function
direct_mode_data_change_part2.isra.9:
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
	beq	.L1152
	cmp	w6, 3
	beq	.L1090
	lsr	w26, w9, 2
	mov	x0, 0
	mov	w21, 0
.L1089:
	sub	w2, w23, w21
	add	x0, x22, x0
	mov	w1, 0
	mul	w2, w2, w26
	sxtw	x2, w2
	bl	memset
	cmp	w21, w23
	bge	.L1087
	sub	w7, w20, #1
	mul	w8, w21, w26
	add	x7, x7, 1
	lsl	w9, w26, 1
	lsl	x7, x7, 3
	mov	w6, 3
	mov	w5, 12
	.p2align 2
.L1113:
	add	x4, x22, x8, sxtw
	cbz	w20, .L1092
	mov	x11, 0
	.p2align 2
.L1102:
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
	beq	.L1093
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
.L1093:
	add	x11, x11, 1
	cmp	w20, w11
	bgt	.L1102
	add	x24, x24, x7
	add	x25, x25, x7
	mov	x11, 0
	.p2align 2
.L1112:
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
	beq	.L1103
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
.L1103:
	add	x11, x11, 1
	cmp	w20, w11
	bgt	.L1112
	add	x24, x24, x7
	add	x25, x25, x7
.L1092:
	add	w21, w21, 2
	add	w8, w8, w9
	cmp	w23, w21
	bgt	.L1113
.L1087:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x29, x30, [sp], 80
	ret
.L1152:
	add	w23, w23, w23, lsr 31
	lsr	w26, w9, 2
	asr	w23, w23, 1
	mov	x0, 0
	mov	w21, 0
	b	.L1089
.L1090:
	add	w21, w23, w23, lsr 31
	lsr	w26, w9, 2
	asr	w21, w21, 1
	mul	w1, w20, w21
	mul	w0, w21, w26
	sbfiz	x1, x1, 3, 32
	sxtw	x0, w0
	add	x24, x24, x1
	add	x25, x2, x1
	b	.L1089
	.size	direct_mode_data_change_part2.isra.9, .-direct_mode_data_change_part2.isra.9
	.align	2
	.p2align 3,,7
	.type	direct_mode_data_change_part.isra.10, %function
direct_mode_data_change_part.isra.10:
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
	beq	.L1191
	mov	w25, w0
	cmp	w6, 3
	mov	w24, 0
	beq	.L1192
.L1155:
	ldr	w1, [x23, 156]
	lsr	w26, w10, 2
	cbz	w1, .L1156
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
.L1159:
	cmp	w25, w24
	ble	.L1153
	sub	w9, w22, #1
	sxtw	x10, w26
	add	x9, x9, 1
	mov	w8, 3
	lsl	x9, x9, 3
	.p2align 2
.L1158:
	mov	x5, 0
	cbz	w22, .L1171
	.p2align 2
.L1188:
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
	beq	.L1160
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
.L1160:
	add	x5, x5, 1
	cmp	w22, w5
	bgt	.L1188
	add	x20, x20, x9
	add	x21, x21, x9
.L1171:
	add	w24, w24, 1
	add	x27, x27, x10
	cmp	w25, w24
	bne	.L1158
.L1153:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldr	x27, [sp, 80]
	ldp	x29, x30, [sp], 96
	ret
.L1156:
	sub	w2, w25, w24
	mul	w23, w26, w24
	mov	w1, 0
	mul	w2, w2, w26
	add	x27, x27, x23, sxtw
	mov	x0, x27
	sxtw	x2, w2
	bl	memset
	b	.L1159
.L1191:
	add	w25, w0, w0, lsr 31
	mov	w24, 0
	asr	w25, w25, 1
	b	.L1155
.L1192:
	add	w24, w0, w0, lsr 31
	asr	w24, w24, 1
	mul	w1, w22, w24
	sbfiz	x1, x1, 3, 32
	add	x20, x20, x1
	add	x21, x2, x1
	b	.L1155
	.size	direct_mode_data_change_part.isra.10, .-direct_mode_data_change_part.isra.10
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
	add	x19, x25, 224
	add	x21, x25, 40
	b	.L1207
	.p2align 3
.L1217:
	cmp	w5, 4
	beq	.L1196
	cmp	w5, 1
	beq	.L1215
	ldr	x0, [x19, 216]
	ldr	w1, [x0, 40]
	cmp	w1, 21
	beq	.L1216
	ldr	w4, [x19, 72]
	cbz	w4, .L1199
	ldr	w1, [x21, 164]
	ldrsw	x7, [x21, 72]
	ldrb	w3, [x25, 280]
	add	x7, x7, 22
	ldr	x2, [x19, 208]
	ldr	x5, [x25, 344]
	cbz	w1, .L1206
	ldr	x1, [x0, 16]
	mov	w6, 3
	ldr	x0, [x19, x7, lsl 3]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change2.isra.4
	.p2align 2
.L1199:
	mov	x0, x22
	bl	up
	mov	x0, x20
	bl	up
	bl	schedule
.L1207:
	mov	x0, x20
	bl	down
	str	x24, [x23, 32]
#APP
// 2120 "/home/lyx/rk3566-11-eink/kernel/drivers/gpu/drm/rockchip/ebc-dev/ebc_dev_y8.c" 1
	dmb ish
// 0 "" 2
#NO_APP
	ldr	w5, [x19, 240]
	cmp	w5, 3
	bne	.L1217
	ldr	w0, [x21, 164]
	cbz	w0, .L1200
	ldrsw	x0, [x21, 72]
	mov	x4, x19
	ldp	x1, x2, [x19, 136]
	add	x0, x0, 22
	ldr	x3, [x19, 160]
	ldr	x0, [x19, x0, lsl 3]
	bl	get_auto_image2
	b	.L1199
	.p2align 3
.L1215:
	ldr	w4, [x19, 72]
	cbz	w4, .L1199
	ldr	w0, [x21, 164]
	cbz	w0, .L1202
	ldrsw	x0, [x21, 72]
	mov	w6, 3
	ldp	x2, x1, [x19, 208]
	add	x0, x0, 22
	ldrb	w3, [x25, 280]
	ldr	x5, [x25, 344]
	ldr	x0, [x19, x0, lsl 3]
	ldr	x1, [x1, 16]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change_part2.isra.9
	b	.L1199
	.p2align 3
.L1196:
	ldr	w0, [x21, 164]
	cbz	w0, .L1198
	ldrsw	x0, [x21, 72]
	mov	w6, 3
	ldp	x1, x2, [x19, 136]
	add	x0, x0, 22
	ldp	x3, x4, [x19, 160]
	mov	x5, x19
	ldr	x0, [x19, x0, lsl 3]
	bl	get_overlay_image2
	b	.L1199
	.p2align 3
.L1200:
	ldrsw	x0, [x21, 72]
	mov	x4, x19
	ldp	x1, x2, [x19, 136]
	add	x0, x0, 22
	ldr	x3, [x19, 160]
	ldr	x0, [x19, x0, lsl 3]
	bl	get_auto_image
	b	.L1199
	.p2align 3
.L1198:
	ldrsw	x0, [x21, 72]
	mov	w6, 3
	ldp	x1, x2, [x19, 136]
	add	x0, x0, 22
	ldp	x3, x4, [x19, 160]
	mov	x5, x19
	ldr	x0, [x19, x0, lsl 3]
	bl	get_overlay_image
	b	.L1199
	.p2align 3
.L1202:
	ldrsw	x0, [x21, 72]
	mov	w6, 3
	ldp	x2, x1, [x19, 208]
	add	x0, x0, 22
	ldrb	w3, [x25, 280]
	ldr	x5, [x25, 344]
	ldr	x0, [x19, x0, lsl 3]
	ldr	x1, [x1, 16]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change_part.isra.10
	b	.L1199
	.p2align 3
.L1206:
	ldr	x1, [x0, 16]
	mov	w6, 3
	ldr	x0, [x19, x7, lsl 3]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change.isra.2
	b	.L1199
	.p2align 3
.L1216:
	mov	x0, x19
	bl	is_full_refresh_done
	tst	w0, 255
	bne	.L1199
	ldr	w0, [x21, 164]
	cbz	w0, .L1205
	ldrsw	x0, [x21, 72]
	mov	w4, 3
	ldp	x2, x1, [x19, 208]
	add	x0, x0, 22
	mov	x3, x19
	ldr	x0, [x19, x0, lsl 3]
	ldr	x1, [x1, 16]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change_full2
	b	.L1199
.L1205:
	ldrsw	x0, [x21, 72]
	mov	w4, 3
	ldp	x2, x1, [x19, 208]
	add	x0, x0, 22
	mov	x3, x19
	ldr	x0, [x19, x0, lsl 3]
	ldr	x1, [x1, 16]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change_full
	b	.L1199
	.size	ebc_auto_assist_tast_function, .-ebc_auto_assist_tast_function
	.align	2
	.p2align 3,,7
	.type	flip.isra.13, %function
flip.isra.13:
	stp	x29, x30, [sp, -80]!
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	mov	x19, x0
	stp	x23, x24, [sp, 48]
	mov	x23, x1
	stp	x21, x22, [sp, 32]
	stp	x25, x26, [sp, 64]
	ldp	w21, w1, [x0, 132]
	ldr	w22, [x0, 172]
	ldrsw	x20, [x0, 72]
	add	w21, w21, w1
	ldr	w0, [x0, 140]
	add	w21, w21, w0
	cbnz	w22, .L1230
	ldr	x0, [x19]
	ldrsw	x2, [x23]
	cbz	x0, .L1222
.L1231:
	ldr	x1, [x0, 648]
	adrp	x3, dummy_dma_ops
	add	x3, x3, :lo12:dummy_dma_ops
	cmp	x1, 0
	csel	x1, x3, x1, eq
.L1220:
	ldr	x4, [x1, 88]
	cbz	x4, .L1221
	add	x1, x20, x20, lsl 1
	mov	w3, 1
	add	x1, x19, x1, lsl 3
	ldr	x1, [x1, 32]
	blr	x4
.L1221:
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
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x29, x30, [sp], 80
	ret
	.p2align 3
.L1230:
	ldp	w26, w2, [x19, 76]
	add	x25, x20, x20, lsl 1
	ldr	w0, [x19, 168]
	add	x25, x19, x25, lsl 3
	sub	w2, w2, w0
	ldr	x1, [x25, 24]
	mul	w24, w26, w0
	add	w0, w22, w0
	mul	w2, w2, w26
	mul	w0, w0, w26
	lsr	w24, w24, 2
	lsr	w2, w2, 2
	lsr	w0, w0, 2
	add	x0, x1, x0
	add	x1, x1, x24
	bl	memmove
	mul	w2, w22, w26
	ldr	x0, [x25, 24]
	mov	w1, 0
	add	x0, x0, x24
	lsr	w2, w2, 2
	bl	memset
	ldr	x0, [x19]
	ldrsw	x2, [x23]
	cbnz	x0, .L1231
.L1222:
	adrp	x1, dummy_dma_ops
	add	x1, x1, :lo12:dummy_dma_ops
	b	.L1220
	.size	flip.isra.13, .-flip.isra.13
	.align	2
	.p2align 3,,7
	.type	ebc_frame_start, %function
ebc_frame_start:
	stp	x29, x30, [sp, -48]!
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	add	x19, x0, 224
	str	x21, [sp, 32]
	mov	x20, x0
	add	x21, x0, 40
	ldr	w6, [x19, 240]
	cmp	w6, 3
	beq	.L1234
	cmp	w6, 4
	beq	.L1235
	cmp	w6, 1
	beq	.L1272
	ldr	x0, [x19, 216]
	ldr	w1, [x0, 40]
	cmp	w1, 21
	beq	.L1273
	ldrb	w4, [x19, 56]
	str	w4, [x19, 72]
	ldr	x2, [x19, 208]
	ldr	w1, [x21, 164]
	ldr	x5, [x20, 344]
	cbz	w1, .L1262
	ldr	x1, [x0, 16]
	mov	w3, w4
	ldr	x2, [x2, 16]
	mov	w6, 1
	ldr	x0, [x19, 176]
	bl	direct_mode_data_change2.isra.4
	ldr	w4, [x19, 72]
	ldp	x2, x1, [x19, 208]
	sub	w4, w4, #1
	str	w4, [x19, 72]
	ldr	w0, [x21, 164]
	ldrb	w3, [x20, 280]
	ldr	x5, [x20, 344]
	cbz	w0, .L1264
.L1280:
	ldr	x1, [x1, 16]
	mov	w6, 1
	ldr	x2, [x2, 16]
	ldr	x0, [x19, 184]
	bl	direct_mode_data_change2.isra.4
	b	.L1265
	.p2align 3
.L1272:
	ldrb	w4, [x19, 56]
	str	w4, [x19, 72]
	ldr	x1, [x19, 208]
	ldr	w0, [x21, 164]
	cbz	w0, .L1250
	ldr	x0, [x19, 216]
	mov	w3, w4
	ldr	x2, [x1, 16]
	ldr	x5, [x20, 344]
	ldr	x1, [x0, 16]
	ldr	x0, [x19, 176]
	bl	direct_mode_data_change_part2.isra.9
	ldr	w4, [x19, 72]
	ldp	x2, x1, [x19, 208]
	sub	w4, w4, #1
	str	w4, [x19, 72]
	ldr	w0, [x21, 164]
	ldrb	w3, [x20, 280]
	ldr	x5, [x20, 344]
	cbz	w0, .L1252
.L1279:
	ldr	x1, [x1, 16]
	mov	w6, 1
	ldr	x2, [x2, 16]
	ldr	x0, [x19, 184]
	bl	direct_mode_data_change_part2.isra.9
	b	.L1265
	.p2align 3
.L1235:
	ldrsw	x2, [x19, 32]
	mov	w1, 0
	ldr	x0, [x19, 176]
	bl	memset
	ldr	w0, [x21, 164]
	cbnz	w0, .L1274
	ldp	x1, x2, [x19, 136]
	mov	x5, x19
	ldp	x3, x4, [x19, 160]
	ldr	x0, [x19, 176]
	bl	get_overlay_image_area
.L1238:
	ldr	w0, [x19, 60]
	cbnz	w0, .L1275
	ldr	w0, [x19, 624]
	cmp	w0, 0
	ble	.L1243
	ldr	x0, [x19, 96]
	adrp	x2, .LANCHOR3
	add	x2, x2, :lo12:.LANCHOR3
	adrp	x1, .LC51
	add	x2, x2, 48
	add	x1, x1, :lo12:.LC51
	bl	_dev_info
.L1243:
	str	wzr, [x19, 52]
.L1278:
	ldp	x19, x20, [sp, 16]
	ldr	x21, [sp, 32]
	ldp	x29, x30, [sp], 48
	ret
	.p2align 3
.L1234:
	ldr	w0, [x21, 164]
	ldp	x1, x2, [x19, 136]
	ldr	x3, [x19, 160]
	cbnz	w0, .L1276
	ldr	x0, [x19, 176]
	mov	w5, 1
	mov	x4, x19
	bl	get_auto_image
	ldr	w0, [x19, 60]
	cbz	w0, .L1246
.L1277:
	ldr	w0, [x21, 164]
	ldp	x1, x2, [x19, 136]
	ldr	x3, [x19, 160]
	cbz	w0, .L1247
	ldr	x0, [x19, 184]
	mov	w5, 1
	mov	x4, x19
	bl	get_auto_image2
	.p2align 2
.L1265:
	str	wzr, [x21, 72]
	add	x1, x20, 256
	mov	x0, x21
	bl	flip.isra.13
.L1232:
	ldp	x19, x20, [sp, 16]
	ldr	x21, [sp, 32]
	ldp	x29, x30, [sp], 48
	ret
	.p2align 3
.L1276:
	ldr	x0, [x19, 176]
	mov	w5, 1
	mov	x4, x19
	bl	get_auto_image2
	ldr	w0, [x19, 60]
	cbnz	w0, .L1277
.L1246:
	ldr	w0, [x19, 624]
	cmp	w0, 0
	ble	.L1243
	ldr	x0, [x19, 96]
	adrp	x2, .LANCHOR3
	add	x2, x2, :lo12:.LANCHOR3
	adrp	x1, .LC52
	add	x2, x2, 48
	add	x1, x1, :lo12:.LC52
	bl	_dev_info
	str	wzr, [x19, 52]
	b	.L1278
	.p2align 3
.L1274:
	ldp	x1, x2, [x19, 136]
	mov	x4, x19
	ldr	x3, [x19, 160]
	ldr	x0, [x19, 176]
	bl	get_overlay_image_area2.isra.0
	b	.L1238
	.p2align 3
.L1250:
	ldr	x0, [x19, 216]
	mov	w3, w4
	ldr	x2, [x1, 16]
	ldr	x5, [x20, 344]
	ldr	x1, [x0, 16]
	ldr	x0, [x19, 176]
	bl	direct_mode_data_change_part.isra.10
	ldr	w4, [x19, 72]
	ldp	x2, x1, [x19, 208]
	sub	w4, w4, #1
	str	w4, [x19, 72]
	ldr	w0, [x21, 164]
	ldrb	w3, [x20, 280]
	ldr	x5, [x20, 344]
	cbnz	w0, .L1279
.L1252:
	ldr	x1, [x1, 16]
	mov	w6, 1
	ldr	x2, [x2, 16]
	ldr	x0, [x19, 184]
	bl	direct_mode_data_change_part.isra.10
	b	.L1265
	.p2align 3
.L1262:
	ldr	x1, [x0, 16]
	mov	w3, w4
	ldr	x2, [x2, 16]
	mov	w6, 1
	ldr	x0, [x19, 176]
	bl	direct_mode_data_change.isra.2
	ldr	w4, [x19, 72]
	ldp	x2, x1, [x19, 208]
	sub	w4, w4, #1
	str	w4, [x19, 72]
	ldr	w0, [x21, 164]
	ldrb	w3, [x20, 280]
	ldr	x5, [x20, 344]
	cbnz	w0, .L1280
.L1264:
	ldr	x1, [x1, 16]
	mov	w6, 1
	ldr	x2, [x2, 16]
	ldr	x0, [x19, 184]
	bl	direct_mode_data_change.isra.2
	b	.L1265
	.p2align 3
.L1275:
	str	wzr, [x21, 72]
	add	x1, x20, 256
	mov	x0, x21
	bl	flip.isra.13
	ldrsw	x2, [x19, 32]
	mov	w1, 0
	ldr	x0, [x19, 184]
	bl	memset
	ldr	w0, [x21, 164]
	cbz	w0, .L1240
	ldp	x1, x2, [x19, 136]
	mov	x4, x19
	ldr	x3, [x19, 160]
	ldr	x0, [x19, 184]
	bl	get_overlay_image_area2.isra.0
	b	.L1232
	.p2align 3
.L1247:
	ldr	x0, [x19, 184]
	mov	w5, 1
	mov	x4, x19
	bl	get_auto_image
	b	.L1265
	.p2align 3
.L1240:
	ldp	x1, x2, [x19, 136]
	mov	x5, x19
	ldp	x3, x4, [x19, 160]
	ldr	x0, [x19, 184]
	bl	get_overlay_image_area
	b	.L1232
	.p2align 3
.L1273:
	ldp	w3, w2, [x19, 80]
	mov	w1, 255
	ldr	x0, [x19, 160]
	mul	w2, w2, w3
	sxtw	x2, w2
	bl	memset
	ldr	w1, [x19, 692]
	ldr	w0, [x19, 680]
	cmp	w1, 4
	ldr	w2, [x19, 84]
	csel	w1, w1, wzr, ls
	str	w0, [x19, 672]
	str	w1, [x19, 676]
	cmp	w0, 0
	str	wzr, [x19, 688]
	ccmp	w0, w2, 0, gt
	ble	.L1257
	mov	w0, w2
	str	w2, [x19, 672]
.L1257:
	str	w0, [x19, 684]
	ldp	x2, x1, [x19, 208]
	ldr	w0, [x21, 164]
	cbz	w0, .L1258
	ldr	x1, [x1, 16]
	mov	w4, 1
	ldr	x2, [x2, 16]
	mov	x3, x19
	ldr	x0, [x19, 176]
	bl	direct_mode_data_change_full2
.L1259:
	ldr	w1, [x19, 672]
	ldr	w0, [x19, 684]
	add	w0, w0, w1
	str	w0, [x19, 684]
	ldp	x2, x1, [x19, 208]
	ldr	w0, [x21, 164]
	cbz	w0, .L1260
	ldr	x1, [x1, 16]
	mov	w4, 1
	ldr	x2, [x2, 16]
	mov	x3, x19
	ldr	x0, [x19, 184]
	bl	direct_mode_data_change_full2
	b	.L1265
	.p2align 3
.L1258:
	ldr	x1, [x1, 16]
	mov	w4, 1
	ldr	x2, [x2, 16]
	mov	x3, x19
	ldr	x0, [x19, 176]
	bl	direct_mode_data_change_full
	b	.L1259
	.p2align 3
.L1260:
	ldr	x1, [x1, 16]
	mov	w4, 1
	ldr	x2, [x2, 16]
	mov	x3, x19
	ldr	x0, [x19, 184]
	bl	direct_mode_data_change_full
	b	.L1265
	.size	ebc_frame_start, .-ebc_frame_start
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
	stp	x27, x28, [sp, 80]
	add	x1, x25, :lo12:__stack_chk_guard
	stp	x19, x20, [sp, 16]
	adrp	x27, .LC48
	stp	x23, x24, [sp, 48]
	add	x2, x27, :lo12:.LC48
	mov	x0, x22
	str	xzr, [x29, 144]
	ldr	x3, [x1]
	str	x3, [x29, 152]
	mov	x3,0
	adrp	x1, .LC53
	add	x1, x1, :lo12:.LC53
	bl	_dev_info
	adrp	x1, .LC54
	mov	x0, x22
	add	x1, x1, :lo12:.LC54
	bl	nvmem_cell_get
	cmn	x0, #4096
	bhi	.L1399
	add	x1, x29, 144
	mov	x19, x0
	bl	nvmem_cell_read
	mov	x20, x0
	mov	x0, x19
	bl	nvmem_cell_put
	cmn	x20, #4096
	bhi	.L1400
	ldr	x0, [x29, 144]
	cmp	x0, 2
	bne	.L1398
	ldrb	w0, [x20]
	cmp	w0, 53
	bne	.L1398
	ldrb	w0, [x20, 1]
	cmp	w0, 102
	beq	.L1358
	mov	w1, 3576
	str	w1, [x29, 104]
	cmp	w0, 118
	bne	.L1398
.L1287:
	mov	x0, x20
	bl	kfree
	mov	w2, 32960
	mov	x1, 928
	movk	w2, 0x60, lsl 16
	mov	x0, x22
	bl	devm_kmalloc
	mov	x19, x0
	cbz	x0, .L1360
	adrp	x2, .LANCHOR0
	str	x22, [x19]
	adrp	x1, .LC58
	add	x1, x1, :lo12:.LC58
	str	x0, [x2, #:lo12:.LANCHOR0]
	mov	w2, 0
	ldr	x0, [x22, 752]
	bl	of_parse_phandle
	cbz	x0, .L1401
	bl	of_find_device_by_node
	cbz	x0, .L1290
	ldr	x0, [x0, 200]
	str	x0, [x19, 8]
	cbz	x0, .L1290
	adrp	x1, frame_done_callback
	add	x1, x1, :lo12:frame_done_callback
	str	x1, [x0, 136]
	add	x2, x29, 120
	adrp	x1, .LC60
	add	x1, x1, :lo12:.LC60
	ldr	x0, [x22, 752]
	bl	of_get_property
	mov	x21, x0
	ldrsw	x0, [x29, 120]
	lsr	x0, x0, 2
	str	w0, [x29, 120]
	cmp	w0, 0
	beq	.L1291
	mov	w20, 0
	mov	w26, 0
	ble	.L1301
	adrp	x23, .LC66
	adrp	x24, .LC68
	add	x23, x23, :lo12:.LC66
	add	x24, x24, :lo12:.LC68
	b	.L1384
	.p2align 3
.L1407:
	adrp	x1, .LC69
	mov	x0, x22
	add	x1, x1, :lo12:.LC69
	bl	_dev_warn
.L1298:
	ldr	w0, [x29, 120]
	add	w20, w20, 1
	cmp	w0, w20
	ble	.L1402
.L1384:
	ldr	w0, [x21], 4
	rev	w0, w0
	bl	of_find_node_by_phandle
	cbz	x0, .L1403
	bl	of_find_i2c_device_by_node
	cbz	x0, .L1404
	add	x28, x0, 32
	ldr	x0, [x28, 184]
	str	x0, [x19, 16]
	cbnz	x0, .L1405
	mov	x1, x23
	mov	x0, x28
	bl	devm_regulator_get
	str	x0, [x19, 24]
	cmn	x0, #4096
	bhi	.L1406
	add	x2, x29, 136
	mov	x1, x24
	mov	x0, x28
	bl	device_property_read_string
	cbnz	w0, .L1407
	ldr	x0, [x29, 136]
	bl	thermal_zone_get_zone_by_name
	str	x0, [x19, 32]
	cmn	x0, #4096
	bhi	.L1408
	ldr	w0, [x29, 120]
	add	w20, w20, 1
	mov	w26, 1
	cmp	w0, w20
	bgt	.L1384
.L1402:
	cbnz	w26, .L1296
.L1301:
	adrp	x1, .LC61
	mov	x0, x22
	add	x1, x1, :lo12:.LC61
	mov	w20, -517
	bl	_dev_err
	b	.L1281
	.p2align 3
.L1406:
	adrp	x1, .LC67
	mov	x0, x22
	add	x1, x1, :lo12:.LC67
	bl	_dev_warn
	b	.L1298
	.p2align 3
.L1408:
	adrp	x1, .LC70
	mov	x0, x22
	add	x1, x1, :lo12:.LC70
	bl	_dev_err
	b	.L1298
	.p2align 3
.L1403:
	adrp	x1, .LC63
	mov	x0, x22
	add	x1, x1, :lo12:.LC63
	mov	w20, -19
	bl	_dev_err
	.p2align 2
.L1281:
	add	x25, x25, :lo12:__stack_chk_guard
	mov	w0, w20
	ldr	x2, [x29, 152]
	ldr	x1, [x25]
	eor	x1, x2, x1
	cbnz	x1, .L1409
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	ldp	x29, x30, [sp], 160
	ret
	.p2align 3
.L1404:
	adrp	x1, .LC64
	mov	x0, x22
	add	x1, x1, :lo12:.LC64
	mov	w20, -19
	bl	_dev_err
	b	.L1281
	.p2align 3
.L1405:
	adrp	x1, .LC65
	mov	w2, w20
	add	x1, x1, :lo12:.LC65
	mov	x0, x22
	bl	_dev_info
.L1296:
	add	x21, x19, 224
	ldr	w0, [x29, 104]
	str	x22, [x21, 96]
	add	x23, x19, 40
	adrp	x1, .LC71
	add	x1, x1, :lo12:.LC71
	str	w0, [x21, 700]
	str	x22, [x19, 40]
	ldr	x0, [x19, 8]
	str	x0, [x23, 8]
	mov	x0, x22
	ldr	x2, [x19, 16]
	str	x2, [x23, 16]
	bl	device_property_present
	tst	w0, 255
	beq	.L1302
	mov	w0, 1
	str	w0, [x21, 620]
.L1302:
	ldr	x20, [x19, 40]
	adrp	x1, .LC72
	mov	x4, 0
	add	x1, x1, :lo12:.LC72
	mov	x3, 1
	add	x2, x19, 116
	ldr	x0, [x20, 752]
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1304
	ldr	x0, [x20, 752]
	adrp	x1, .LC103
	mov	x4, 0
	add	x1, x1, :lo12:.LC103
	mov	x3, 1
	add	x2, x19, 120
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1304
	ldr	x0, [x20, 752]
	adrp	x1, .LC104
	mov	x4, 0
	add	x1, x1, :lo12:.LC104
	mov	x3, 1
	add	x2, x19, 124
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1304
	ldr	x0, [x20, 752]
	adrp	x1, .LC105
	mov	x4, 0
	add	x1, x1, :lo12:.LC105
	mov	x3, 1
	add	x2, x19, 128
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1304
	ldr	x0, [x20, 752]
	adrp	x1, .LC106
	mov	x4, 0
	add	x1, x1, :lo12:.LC106
	mov	x3, 1
	add	x2, x19, 144
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1304
	ldr	x0, [x20, 752]
	adrp	x1, .LC107
	mov	x4, 0
	add	x1, x1, :lo12:.LC107
	mov	x3, 1
	add	x2, x19, 148
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1304
	ldr	x0, [x20, 752]
	adrp	x1, .LC108
	mov	x4, 0
	add	x1, x1, :lo12:.LC108
	mov	x3, 1
	add	x2, x19, 152
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1304
	ldr	x0, [x20, 752]
	adrp	x1, .LC109
	mov	x4, 0
	add	x1, x1, :lo12:.LC109
	mov	x3, 1
	add	x2, x19, 156
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1304
	ldr	x0, [x20, 752]
	adrp	x1, .LC110
	mov	x4, 0
	add	x1, x1, :lo12:.LC110
	mov	x3, 1
	add	x2, x19, 160
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1304
	ldr	x0, [x20, 752]
	adrp	x1, .LC111
	mov	x4, 0
	add	x1, x1, :lo12:.LC111
	mov	x3, 1
	add	x2, x19, 164
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1304
	ldr	x0, [x20, 752]
	adrp	x1, .LC112
	mov	x4, 0
	add	x1, x1, :lo12:.LC112
	mov	x3, 1
	add	x2, x19, 168
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1304
	ldr	x0, [x20, 752]
	adrp	x1, .LC113
	mov	x4, 0
	add	x1, x1, :lo12:.LC113
	mov	x3, 1
	add	x2, x19, 172
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1304
	ldr	x0, [x20, 752]
	adrp	x1, .LC114
	mov	x4, 0
	add	x1, x1, :lo12:.LC114
	mov	x3, 1
	add	x2, x19, 176
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1304
	ldr	x0, [x20, 752]
	adrp	x1, .LC115
	mov	x4, 0
	add	x1, x1, :lo12:.LC115
	mov	x3, 1
	add	x2, x19, 180
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1304
	ldr	x0, [x20, 752]
	adrp	x1, .LC116
	mov	x4, 0
	add	x1, x1, :lo12:.LC116
	mov	x3, 1
	add	x2, x19, 184
	bl	of_property_read_variable_u32_array
	tbnz	w0, #31, .L1304
	ldr	x0, [x20, 752]
	adrp	x1, .LC117
	mov	x4, 0
	add	x1, x1, :lo12:.LC117
	mov	x3, 1
	add	x2, x19, 188
	bl	of_property_read_variable_u32_array
	tbz	w0, #31, .L1344
	str	wzr, [x23, 148]
.L1344:
	ldr	x0, [x20, 752]
	adrp	x1, .LC73
	mov	x4, 0
	add	x1, x1, :lo12:.LC73
	mov	x3, 1
	add	x2, x19, 192
	bl	of_property_read_variable_u32_array
	tbz	w0, #31, .L1345
	str	wzr, [x23, 152]
.L1345:
	ldr	x0, [x20, 752]
	adrp	x1, .LC74
	mov	x4, 0
	add	x1, x1, :lo12:.LC74
	mov	x3, 1
	add	x2, x19, 196
	bl	of_property_read_variable_u32_array
	tbz	w0, #31, .L1346
	str	wzr, [x23, 156]
.L1346:
	ldr	x0, [x20, 752]
	adrp	x1, .LC75
	mov	x4, 0
	add	x1, x1, :lo12:.LC75
	mov	x3, 1
	add	x2, x19, 132
	bl	of_property_read_variable_u32_array
	tbz	w0, #31, .L1347
	str	wzr, [x23, 92]
.L1347:
	ldr	x0, [x20, 752]
	adrp	x1, .LC76
	mov	x4, 0
	add	x1, x1, :lo12:.LC76
	mov	x3, 1
	add	x2, x19, 136
	bl	of_property_read_variable_u32_array
	tbz	w0, #31, .L1348
	str	wzr, [x23, 96]
.L1348:
	ldr	x0, [x20, 752]
	adrp	x1, .LC77
	mov	x4, 0
	add	x1, x1, :lo12:.LC77
	mov	x3, 1
	add	x2, x19, 200
	bl	of_property_read_variable_u32_array
	tbz	w0, #31, .L1349
	str	wzr, [x23, 160]
.L1349:
	ldr	x0, [x20, 752]
	adrp	x1, .LC78
	mov	x4, 0
	add	x1, x1, :lo12:.LC78
	mov	x3, 1
	add	x2, x19, 204
	bl	of_property_read_variable_u32_array
	tbz	w0, #31, .L1350
	str	wzr, [x23, 164]
.L1350:
	ldr	x0, [x20, 752]
	adrp	x1, .LC79
	mov	x4, 0
	add	x1, x1, :lo12:.LC79
	mov	x3, 1
	add	x2, x19, 216
	bl	of_property_read_variable_u32_array
	tbz	w0, #31, .L1351
	str	wzr, [x23, 176]
.L1351:
	ldr	x0, [x20, 752]
	adrp	x1, .LC80
	mov	x4, 0
	add	x1, x1, :lo12:.LC80
	mov	x3, 1
	add	x2, x19, 220
	bl	of_property_read_variable_u32_array
	tbz	w0, #31, .L1352
	str	wzr, [x23, 180]
.L1352:
	ldr	x0, [x20, 752]
	adrp	x1, .LC81
	mov	x4, 0
	add	x1, x1, :lo12:.LC81
	mov	x3, 1
	add	x2, x19, 208
	bl	of_property_read_variable_u32_array
	tbz	w0, #31, .L1353
	str	wzr, [x23, 168]
.L1353:
	ldr	x0, [x20, 752]
	adrp	x1, .LC82
	mov	x4, 0
	add	x1, x1, :lo12:.LC82
	mov	x3, 1
	add	x2, x19, 212
	bl	of_property_read_variable_u32_array
	tbz	w0, #31, .L1354
	str	wzr, [x23, 172]
.L1354:
	ldr	w1, [x23, 80]
	mov	w24, 1
	str	w1, [x21, 80]
	ldr	w0, [x23, 76]
	str	w0, [x21, 84]
	str	w0, [x21, 680]
	str	w24, [x21, 688]
	mul	w1, w1, w0
	mov	x0, x19
	str	w1, [x21, 28]
	lsr	w1, w1, 2
	str	w1, [x21, 32]
	bl	ebc_buffer_manage_init
	mov	w20, w0
	cbnz	w0, .L1410
	mov	x0, x21
	bl	ebc_lut_table_init
	mov	w20, w0
	cbnz	w0, .L1411
	adrp	x0, __cpu_possible_mask
	ldrb	w0, [x0, #:lo12:__cpu_possible_mask]
	bl	__sw_hweight64
	str	w0, [x21, 616]
	mov	w0, 99
	str	w0, [x29, 128]
	adrp	x0, .LANCHOR0
	add	x26, x0, :lo12:.LANCHOR0
	adrp	x3, .LC85
	mov	w2, -1
	add	x3, x3, :lo12:.LC85
	mov	x1, x21
	adrp	x0, ebc_auto_tast_function
	add	x0, x0, :lo12:ebc_auto_tast_function
	bl	kthread_create_on_node
	str	x0, [x26, 8]
	cmn	x0, #4096
	bhi	.L1412
	mov	w1, w24
	add	x2, x29, 128
	bl	sched_setscheduler_nocheck
	ldr	w0, [x21, 616]
	cmp	w0, 7
	bgt	.L1413
.L1319:
	adrp	x0, .LANCHOR0
	add	x24, x0, :lo12:.LANCHOR0
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
	adrp	x3, .LC87
	adrp	x0, ebc_auto_assist_tast_function
	add	x3, x3, :lo12:.LC87
	add	x0, x0, :lo12:ebc_auto_assist_tast_function
	mov	w2, -1
	mov	x1, x21
	bl	kthread_create_on_node
	str	x0, [x24, 16]
	cmn	x0, #4096
	bhi	.L1414
	add	x2, x29, 128
	mov	w1, 1
	bl	sched_setscheduler_nocheck
	ldr	w0, [x21, 616]
	cmp	w0, 7
	bgt	.L1415
.L1321:
	adrp	x0, .LANCHOR0
	add	x24, x0, :lo12:.LANCHOR0
	mov	w0, 1
	ldr	x2, [x24, 16]
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
	adrp	x3, .LC89
	str	w0, [x29, 128]
	add	x3, x3, :lo12:.LC89
	mov	w2, -1
	mov	x1, x21
	adrp	x0, ebc_thread
	add	x0, x0, :lo12:ebc_thread
	bl	kthread_create_on_node
	mov	x26, x0
	cmn	x0, #4096
	bhi	.L1322
	bl	wake_up_process
	str	x26, [x24, 24]
	mov	x0, x26
	add	x2, x29, 128
	mov	w1, 1
	bl	sched_setscheduler_nocheck
	ldr	w0, [x21, 616]
	cmp	w0, 7
	bgt	.L1416
.L1323:
	adrp	x0, .LANCHOR0
	add	x28, x0, :lo12:.LANCHOR0
	mov	w0, 1
	ldr	x2, [x28, 24]
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
	add	x0, x21, 512
	str	wzr, [x21, 52]
	str	wzr, [x21, 68]
	mov	w28, 1
	stp	wzr, wzr, [x21, 88]
	adrp	x1, .LC90
	str	wzr, [x21, 192]
	add	x1, x1, :lo12:.LC90
	str	w28, [x21, 240]
	adrp	x26, jiffies
	str	wzr, [x21, 576]
	add	x24, x19, 688
	str	wzr, [x21, 580]
	stp	w28, w28, [x0, 76]
	stp	wzr, wzr, [x0, 84]
	str	wzr, [x21, 608]
	str	wzr, [x21, 624]
	ldr	w0, [x19, 924]
	cmp	w0, 3576
	cset	w0, eq
	str	w0, [x21, 604]
	str	w0, [x21, 612]
	add	x0, x19, 472
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
	str	x1, [x19, 472]
	bl	wakeup_source_add
	str	wzr, [x21, 456]
	mov	x4, 0
	mov	x3, 0
	mov	w2, 0
	mov	x0, x24
	adrp	x1, ebc_frame_control_timeout
	add	x1, x1, :lo12:ebc_frame_control_timeout
	bl	init_timer_key
	mov	x5, 268435455
	ldr	x1, [x26, #:lo12:jiffies]
	str	x5, [x29, 104]
	mov	x0, x24
	add	x1, x1, x5
	add	x24, x19, 744
	bl	mod_timer
	mov	x3, 0
	mov	x4, 0
	mov	w2, 0
	mov	x0, x24
	adrp	x1, ebc_frame_timeout
	add	x1, x1, :lo12:ebc_frame_timeout
	bl	init_timer_key
	ldr	x5, [x29, 104]
	mov	x0, x24
	ldr	x1, [x26, #:lo12:jiffies]
	add	x1, x1, x5
	bl	mod_timer
	stp	wzr, wzr, [x29, 124]
	adrp	x0, saved_command_line
	adrp	x1, .LC91
	add	x1, x1, :lo12:.LC91
	ldr	x24, [x0, #:lo12:saved_command_line]
	mov	x0, x24
	bl	strstr
	adrp	x1, .LC92
	mov	x26, x0
	add	x1, x1, :lo12:.LC92
	mov	x0, x24
	bl	strstr
	mov	x3, x0
	cbz	x26, .L1324
	add	x2, x29, 124
	str	x3, [x29, 104]
	mov	x0, x26
	adrp	x1, .LC93
	add	x1, x1, :lo12:.LC93
	bl	sscanf
	ldr	w2, [x29, 124]
	ldr	x0, [x19, 224]
	ldr	x3, [x29, 104]
	cmp	x0, x2, uxtw
	bls	.L1417
.L1324:
	str	wzr, [x29, 104]
	mov	x24, 0
	mov	w28, 0
	mov	x26, 0
	cbz	x3, .L1356
.L1355:
	add	x2, x29, 128
	mov	x0, x3
	adrp	x1, .LC96
	add	x1, x1, :lo12:.LC96
	bl	sscanf
	mov	w28, 0
	ldr	w2, [x29, 128]
	mov	x26, 0
	ldr	x0, [x19, 224]
	cmp	x0, x2, uxtw
	bls	.L1418
.L1328:
	ldr	w0, [x29, 104]
	cbnz	w0, .L1327
.L1356:
	ldr	x0, [x21, 96]
	adrp	x1, .LC99
	add	x1, x1, :lo12:.LC99
	bl	_dev_info
	ldr	x0, [x19, 16]
	cbz	x0, .L1330
	bl	ebc_pmic_verity_vcom
.L1331:
	adrp	x0, .LC100
	add	x0, x0, :lo12:.LC100
	bl	ebc_empty_buf_get
	mov	x3, x0
	ldp	w2, w0, [x19, 116]
	mov	w1, 240
	str	x3, [x29, 104]
	mul	w2, w2, w0
	ldr	x0, [x3, 16]
	bl	memset
	ldr	x3, [x29, 104]
	mov	w0, 17
	mov	w2, 1
	str	w0, [x3, 40]
	mov	x0, x3
	stp	wzr, wzr, [x3, 48]
	ldr	w1, [x19, 116]
	str	w1, [x3, 56]
	ldr	w1, [x19, 120]
	stp	w1, w2, [x3, 60]
	bl	ebc_add_to_dsp_buf_list
.L1332:
	cbnz	w28, .L1419
.L1337:
	ldr	w0, [x21, 88]
	adrp	x23, .LANCHOR1
	cbz	w0, .L1420
.L1342:
	cbz	x24, .L1343
	mov	x0, x24
	bl	kfree
.L1343:
	cbz	x26, .L1326
	mov	x0, x26
	bl	kfree
.L1326:
	str	x19, [x22, 184]
	add	x23, x23, :lo12:.LANCHOR1
	add	x0, x23, 224
	bl	misc_register
	add	x0, x23, 376
	bl	misc_register
	ldr	x0, [x19, 320]
	add	x1, x23, 456
	bl	device_create_file
	ldr	x0, [x19, 320]
	add	x1, x23, 488
	bl	device_create_file
	ldr	x0, [x19, 320]
	add	x1, x23, 520
	bl	device_create_file
	ldr	x0, [x19, 320]
	add	x1, x23, 552
	bl	device_create_file
	ldr	x0, [x19, 320]
	add	x1, x23, 584
	bl	device_create_file
	ldr	x0, [x19, 320]
	add	x1, x23, 616
	bl	device_create_file
	ldr	x0, [x19, 320]
	add	x1, x23, 648
	bl	device_create_file
	ldr	x0, [x19, 320]
	add	x1, x23, 680
	bl	device_create_file
	ldr	x0, [x19, 320]
	add	x1, x23, 712
	bl	device_create_file
	ldr	x0, [x19, 320]
	add	x1, x23, 744
	bl	device_create_file
	ldr	x0, [x19, 320]
	add	x1, x23, 776
	bl	device_create_file
	ldr	x0, [x21, 96]
	adrp	x1, .LC102
	add	x2, x27, :lo12:.LC48
	add	x1, x1, :lo12:.LC102
	bl	_dev_info
	b	.L1281
	.p2align 3
.L1304:
	mov	w20, -22
	adrp	x1, .LC120
	mov	w2, w20
	add	x1, x1, :lo12:.LC120
	mov	x0, x22
	bl	_dev_err
	b	.L1281
	.p2align 3
.L1398:
	mov	x0, x20
	bl	kfree
	mov	x0, x22
	adrp	x1, .LC57
	mov	w20, -12
	add	x1, x1, :lo12:.LC57
	bl	_dev_err
	b	.L1281
	.p2align 3
.L1399:
	adrp	x1, .LC55
	mov	x0, x22
	add	x1, x1, :lo12:.LC55
	mov	w20, -12
	bl	_dev_err
	b	.L1281
	.p2align 3
.L1358:
	mov	w0, 3566
	str	w0, [x29, 104]
	b	.L1287
	.p2align 3
.L1400:
	adrp	x1, .LC56
	mov	x0, x22
	add	x1, x1, :lo12:.LC56
	bl	_dev_err
	b	.L1281
	.p2align 3
.L1410:
	adrp	x1, .LC83
	mov	x0, x22
	add	x1, x1, :lo12:.LC83
	bl	_dev_err
	b	.L1281
.L1416:
	ldr	x0, [x24, 24]
	adrp	x1, cpu_bit_bitmap+48
	add	x1, x1, :lo12:cpu_bit_bitmap+48
	bl	set_cpus_allowed_ptr
	b	.L1323
.L1420:
	mov	w2, 1
	str	w2, [x21, 88]
	add	x0, x23, :lo12:.LANCHOR1
	mov	w1, w2
	add	x0, x0, 304
	bl	__wake_up_sync
	b	.L1342
.L1417:
	ldr	x0, [x21, 96]
	adrp	x1, .LC94
	add	x1, x1, :lo12:.LC94
	bl	_dev_info
	ldp	w0, w1, [x23, 76]
	mul	w0, w0, w1
	mov	w1, 32960
	movk	w1, 0x60, lsl 16
	lsr	w0, w0, 1
	bl	__kmalloc
	ldr	x3, [x29, 104]
	mov	x24, x0
	cbz	x0, .L1421
	ldp	w2, w1, [x23, 76]
	str	x3, [x29, 104]
	ldr	x4, [x19, 224]
	mul	w2, w2, w1
	ldr	w1, [x29, 124]
	sub	x1, x1, x4
	ldr	x4, [x21, 8]
	lsr	w2, w2, 1
	add	x1, x4, x1
	bl	memcpy
	ldr	x3, [x29, 104]
	cbnz	x3, .L1422
	mov	w28, 0
	mov	x26, 0
.L1327:
	adrp	x0, .LC101
	add	x0, x0, :lo12:.LC101
	bl	ebc_empty_buf_get
	mov	x5, x0
	cbz	x0, .L1332
	ldp	w4, w0, [x23, 76]
	mov	x1, 0
	ldr	x2, [x5, 16]
	mul	w4, w4, w0
	lsr	w4, w4, 1
	cbz	w4, .L1335
	.p2align 2
.L1383:
	ldrb	w0, [x24, x1]
	add	x1, x1, 1
	cmp	w4, w1
	and	w3, w0, -16
	lsl	w0, w0, 4
	strb	w0, [x2], 2
	strb	w3, [x2, -1]
	bgt	.L1383
.L1335:
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
	b	.L1332
.L1413:
	ldr	x0, [x26, 8]
	adrp	x1, cpu_bit_bitmap+56
	add	x1, x1, :lo12:cpu_bit_bitmap+56
	bl	set_cpus_allowed_ptr
	b	.L1319
.L1411:
	adrp	x1, .LC84
	mov	x0, x22
	add	x1, x1, :lo12:.LC84
	bl	_dev_err
	b	.L1281
.L1415:
	ldr	x0, [x24, 16]
	adrp	x1, cpu_bit_bitmap+64
	add	x1, x1, :lo12:cpu_bit_bitmap+64
	bl	set_cpus_allowed_ptr
	b	.L1321
.L1290:
	mov	w20, -517
	b	.L1281
.L1419:
	adrp	x0, .LC101
	add	x0, x0, :lo12:.LC101
	bl	ebc_empty_buf_get
	mov	x5, x0
	cbz	x0, .L1337
	ldp	w4, w0, [x23, 76]
	mov	x1, 0
	ldr	x2, [x5, 16]
	mul	w4, w4, w0
	lsr	w4, w4, 1
	cbz	w4, .L1341
	.p2align 2
.L1382:
	ldrb	w0, [x26, x1]
	add	x1, x1, 1
	cmp	w4, w1
	and	w3, w0, -16
	lsl	w0, w0, 4
	strb	w0, [x2], 2
	strb	w3, [x2, -1]
	bgt	.L1382
.L1341:
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
	b	.L1337
.L1360:
	mov	w20, -12
	b	.L1281
.L1418:
	ldr	x0, [x21, 96]
	adrp	x1, .LC97
	add	x1, x1, :lo12:.LC97
	bl	_dev_info
	ldp	w0, w1, [x23, 76]
	mul	w0, w0, w1
	mov	w1, 32960
	movk	w1, 0x60, lsl 16
	lsr	w0, w0, 1
	bl	__kmalloc
	mov	x26, x0
	cbz	x0, .L1423
	ldp	w2, w1, [x23, 76]
	mov	w28, 1
	ldr	x3, [x19, 224]
	mul	w2, w2, w1
	ldr	w1, [x29, 128]
	sub	x1, x1, x3
	ldr	x3, [x21, 8]
	lsr	w2, w2, 1
	add	x1, x3, x1
	bl	memcpy
	b	.L1328
.L1291:
	adrp	x1, .LC62
	mov	x0, x22
	add	x1, x1, :lo12:.LC62
	mov	w20, -22
	bl	_dev_err
	b	.L1281
.L1412:
	ldr	x0, [x21, 96]
	adrp	x1, .LC86
	add	x1, x1, :lo12:.LC86
	bl	_dev_err
.L1318:
	adrp	x1, .LC119
	mov	x0, x22
	add	x1, x1, :lo12:.LC119
	mov	w20, -1
	bl	_dev_err
	b	.L1281
.L1414:
	ldr	x0, [x21, 96]
	adrp	x1, .LC88
	add	x1, x1, :lo12:.LC88
	bl	_dev_err
	b	.L1318
.L1322:
	ldr	x0, [x21, 96]
	adrp	x1, .LC118
	str	x26, [x24, 24]
	add	x1, x1, :lo12:.LC118
	bl	_dev_err
	b	.L1318
.L1401:
	adrp	x1, .LC59
	mov	x0, x22
	add	x1, x1, :lo12:.LC59
	mov	w20, -19
	bl	_dev_err
	b	.L1281
.L1330:
	ldr	x0, [x19, 24]
	bl	ebc_regulator_verity_vcom
	b	.L1331
.L1409:
	bl	__stack_chk_fail
.L1423:
	ldr	x0, [x21, 96]
	adrp	x1, .LC98
	adrp	x23, .LANCHOR1
	add	x1, x1, :lo12:.LC98
	bl	_dev_err
	b	.L1326
.L1422:
	str	w28, [x29, 104]
	b	.L1355
.L1421:
	ldr	x0, [x21, 96]
	adrp	x1, .LC95
	adrp	x23, .LANCHOR1
	add	x1, x1, :lo12:.LC95
	bl	_dev_err
	b	.L1326
	.size	ebc_probe, .-ebc_probe
	.align	2
	.p2align 3,,7
	.type	auto_frame_state_read, %function
auto_frame_state_read:
	adrp	x0, .LANCHOR0
	ldr	x1, [x0, #:lo12:.LANCHOR0]
	ldp	w0, w4, [x1, 116]
	mul	w4, w4, w0
	cbz	w4, .L1425
	ldr	x5, [x1, 384]
	mov	w1, 0
	ldrb	w3, [x5]
	cbz	w3, .L1428
	b	.L1426
	.p2align 3
.L1430:
	ldrb	w3, [x5, w1, sxtw]
	cbnz	w3, .L1426
.L1428:
	add	w1, w1, 1
	cmp	w1, w4
	bne	.L1430
.L1425:
	adrp	x1, .LC121
	add	x1, x1, :lo12:.LC121
	mov	x0, 2
	ldrh	w3, [x1]
	ldrb	w1, [x1, 2]
	strh	w3, [x2]
	strb	w1, [x2, 2]
	ret
	.p2align 3
.L1426:
	stp	x29, x30, [sp, -16]!
	mov	x0, x2
	adrp	x1, .LC47
	mov	w2, w3
	add	x29, sp, 0
	add	x1, x1, :lo12:.LC47
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
	stp	x25, x26, [sp, 64]
	ldp	w30, w6, [x5, 80]
	cmp	w6, 0
	add	w16, w6, 7
	csel	w16, w16, w6, lt
	cmp	w30, 0
	ble	.L1440
	asr	w16, w16, 3
	mov	w18, 0
	sub	w17, w16, #1
	mov	x15, 4026531840
	add	x17, x17, 1
	mov	x14, 1030792151040
	lsl	x17, x17, 3
	mov	x13, 263882790666240
	mov	x12, 67553994410557440
	mov	x11, -1152921504606846976
	mov	x23, -2305843009213693952
	mov	x22, 63050394783186944
	mov	x21, 246290604621824
	mov	x20, 962072674304
	mov	x19, 3758096384
	.p2align 2
.L1442:
	mov	x10, 0
	cmp	w16, 0
	bgt	.L1512
	b	.L1509
	.p2align 3
.L1521:
	and	x6, x8, 240
	and	x5, x7, 255
	cmp	x6, 240
	bne	.L1444
	cmp	x5, 240
	mov	x6, 255
	cset	x5, eq
.L1445:
	and	x9, x8, 61440
	and	x25, x7, 65280
	cmp	x9, 61440
	bne	.L1448
	orr	x9, x5, 256
	cmp	x25, 61440
	orr	x6, x6, 65280
	csel	x5, x9, x5, eq
.L1449:
	and	x9, x8, 15728640
	and	x25, x7, 16711680
	cmp	x9, 15728640
	bne	.L1452
	orr	x9, x5, 65536
	cmp	x25, 15728640
	orr	x6, x6, 16711680
	csel	x5, x9, x5, eq
.L1453:
	and	x9, x8, 4026531840
	and	x25, x7, 4278190080
	cmp	x9, x15
	bne	.L1456
	orr	x9, x5, 16777216
	cmp	x25, x15
	orr	x6, x6, 4278190080
	csel	x5, x9, x5, eq
.L1457:
	and	x9, x8, 1030792151040
	and	x25, x7, 1095216660480
	cmp	x9, x14
	bne	.L1460
.L1522:
	orr	x9, x5, 4294967296
	cmp	x25, x14
	orr	x6, x6, 1095216660480
	csel	x5, x9, x5, eq
.L1461:
	and	x9, x8, 263882790666240
	and	x25, x7, 280375465082880
	cmp	x9, x13
	bne	.L1464
	orr	x9, x5, 1099511627776
	cmp	x25, x13
	orr	x6, x6, 280375465082880
	csel	x5, x9, x5, eq
.L1465:
	and	x9, x8, 67553994410557440
	and	x25, x7, 71776119061217280
	cmp	x9, x12
	bne	.L1468
	orr	x9, x5, 281474976710656
	cmp	x25, x12
	orr	x6, x6, 71776119061217280
	csel	x5, x9, x5, eq
.L1469:
	and	x8, x8, -1152921504606846976
	and	x9, x7, -72057594037927936
	cmp	x8, x11
	bne	.L1504
.L1515:
	orr	x8, x5, 72057594037927936
	cmp	x9, x11
	orr	x6, x6, -72057594037927936
	csel	x5, x8, x5, eq
.L1473:
	eor	x7, x24, x7
	str	x5, [x4, x10, lsl 3]
	and	x6, x7, x6
	eor	x6, x24, x6
	str	x6, [x0, x10, lsl 3]
	add	x10, x10, 1
	cmp	w16, w10
	ble	.L1520
.L1512:
	ldr	x9, [x3, x10, lsl 3]
	ldr	x5, [x4, x10, lsl 3]
	ldr	x8, [x1, x10, lsl 3]
	ldr	x24, [x0, x10, lsl 3]
	ldr	x7, [x2, x10, lsl 3]
	cbz	x9, .L1521
	and	x25, x9, 255
	mov	x6, 0
	cbnz	x25, .L1476
	and	x6, x8, 240
	and	x5, x5, -256
	and	x25, x7, 255
	cmp	x6, 240
	bne	.L1477
	orr	x6, x5, 1
	cmp	x25, 240
	csel	x5, x6, x5, eq
	mov	x6, 255
.L1476:
	tst	x9, 65280
	bne	.L1480
	and	x25, x8, 61440
	and	x5, x5, -65281
	cmp	x25, 61440
	and	x26, x7, 65280
	bne	.L1481
	cmp	x26, 61440
	orr	x25, x5, 256
	orr	x6, x6, 65280
	csel	x5, x25, x5, eq
.L1480:
	tst	x9, 16711680
	bne	.L1484
	and	x25, x8, 15728640
	and	x5, x5, -16711681
	cmp	x25, 15728640
	and	x26, x7, 16711680
	bne	.L1485
	cmp	x26, 15728640
	orr	x25, x5, 65536
	orr	x6, x6, 16711680
	csel	x5, x25, x5, eq
.L1484:
	tst	x9, 4278190080
	bne	.L1488
	and	x25, x8, 4026531840
	and	x5, x5, -4278190081
	cmp	x25, x15
	and	x26, x7, 4278190080
	bne	.L1489
	cmp	x26, x15
	orr	x25, x5, 16777216
	orr	x6, x6, 4278190080
	csel	x5, x25, x5, eq
.L1488:
	tst	x9, 1095216660480
	bne	.L1492
	and	x25, x8, 1030792151040
	and	x5, x5, -1095216660481
	cmp	x25, x14
	and	x26, x7, 1095216660480
	bne	.L1493
	cmp	x26, x14
	orr	x25, x5, 4294967296
	orr	x6, x6, 1095216660480
	csel	x5, x25, x5, eq
.L1492:
	tst	x9, 280375465082880
	bne	.L1496
	and	x25, x8, 263882790666240
	and	x5, x5, -280375465082881
	cmp	x25, x13
	and	x26, x7, 280375465082880
	bne	.L1497
	cmp	x26, x13
	orr	x25, x5, 1099511627776
	orr	x6, x6, 280375465082880
	csel	x5, x25, x5, eq
.L1496:
	tst	x9, 71776119061217280
	bne	.L1500
	and	x25, x8, 67553994410557440
	and	x5, x5, -71776119061217281
	cmp	x25, x12
	and	x26, x7, 71776119061217280
	bne	.L1501
	cmp	x26, x12
	orr	x25, x5, 281474976710656
	orr	x6, x6, 71776119061217280
	csel	x5, x25, x5, eq
.L1500:
	tst	x9, -72057594037927936
	bne	.L1473
	and	x8, x8, -1152921504606846976
	and	x5, x5, 72057594037927935
	and	x9, x7, -72057594037927936
	cmp	x8, x11
	beq	.L1515
	.p2align 2
.L1504:
	and	x24, x24, 72057594037927935
	cbnz	x8, .L1505
	eor	x7, x24, x7
	orr	x5, x5, 72057594037927936
	and	x6, x7, x6
	str	x5, [x4, x10, lsl 3]
	eor	x6, x24, x6
	str	x6, [x0, x10, lsl 3]
	add	x10, x10, 1
	cmp	w16, w10
	bgt	.L1512
	.p2align 2
.L1520:
	add	x3, x3, x17
	add	x1, x1, x17
	add	x2, x2, x17
	add	x4, x4, x17
	add	x0, x0, x17
.L1509:
	add	w18, w18, 1
	cmp	w30, w18
	bne	.L1442
.L1440:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x29, x30, [sp], 80
	ret
	.p2align 3
.L1468:
	and	x24, x24, -71776119061217281
	cbnz	x9, .L1470
	orr	x5, x5, 281474976710656
	b	.L1469
	.p2align 3
.L1464:
	and	x24, x24, -280375465082881
	cbnz	x9, .L1466
	orr	x5, x5, 1099511627776
	b	.L1465
	.p2align 3
.L1456:
	and	x24, x24, -4278190081
	cbnz	x9, .L1458
	and	x9, x8, 1030792151040
	orr	x5, x5, 16777216
	and	x25, x7, 1095216660480
	cmp	x9, x14
	beq	.L1522
	.p2align 2
.L1460:
	and	x24, x24, -1095216660481
	cbnz	x9, .L1462
	orr	x5, x5, 4294967296
	b	.L1461
	.p2align 3
.L1452:
	and	x24, x24, -16711681
	cbnz	x9, .L1454
	orr	x5, x5, 65536
	b	.L1453
	.p2align 3
.L1448:
	and	x24, x24, -65281
	cbnz	x9, .L1450
	orr	x5, x5, 256
	b	.L1449
	.p2align 3
.L1444:
	cbnz	x6, .L1446
	and	x24, x24, -256
	mov	x5, 1
	b	.L1445
	.p2align 3
.L1505:
	cmp	x8, x23
	beq	.L1523
	orr	x24, x8, x24
	b	.L1473
	.p2align 3
.L1446:
	cmp	x6, 224
	beq	.L1524
	and	x24, x24, -256
	mov	x5, 0
	orr	x24, x6, x24
	mov	x6, 0
	b	.L1445
	.p2align 3
.L1470:
	cmp	x9, x22
	beq	.L1525
	orr	x24, x9, x24
	b	.L1469
	.p2align 3
.L1466:
	cmp	x9, x21
	beq	.L1526
	orr	x24, x9, x24
	b	.L1465
	.p2align 3
.L1454:
	cmp	x9, 14680064
	beq	.L1527
	orr	x24, x9, x24
	b	.L1453
	.p2align 3
.L1462:
	cmp	x9, x20
	beq	.L1528
	orr	x24, x9, x24
	b	.L1461
	.p2align 3
.L1458:
	cmp	x9, x19
	beq	.L1529
	orr	x24, x9, x24
	b	.L1457
	.p2align 3
.L1450:
	cmp	x9, 57344
	beq	.L1530
	orr	x24, x9, x24
	b	.L1449
	.p2align 3
.L1523:
	orr	x5, x5, 72057594037927936
	orr	x24, x24, -1152921504606846976
	b	.L1473
	.p2align 3
.L1530:
	orr	x5, x5, 256
	orr	x24, x24, 61440
	b	.L1449
	.p2align 3
.L1524:
	and	x6, x24, -256
	mov	x5, 1
	orr	x24, x6, 240
	mov	x6, 0
	b	.L1445
	.p2align 3
.L1526:
	orr	x5, x5, 1099511627776
	orr	x24, x24, 263882790666240
	b	.L1465
	.p2align 3
.L1525:
	orr	x5, x5, 281474976710656
	orr	x24, x24, 67553994410557440
	b	.L1469
	.p2align 3
.L1528:
	orr	x5, x5, 4294967296
	orr	x24, x24, 1030792151040
	b	.L1461
	.p2align 3
.L1527:
	orr	x5, x5, 65536
	orr	x24, x24, 15728640
	b	.L1453
	.p2align 3
.L1529:
	orr	x5, x5, 16777216
	orr	x24, x24, 4026531840
	b	.L1457
.L1477:
	cbz	x6, .L1531
	cmp	x6, 224
	beq	.L1532
	and	x24, x24, -256
	orr	x24, x6, x24
	mov	x6, 0
	b	.L1476
.L1497:
	and	x24, x24, -280375465082881
	cbz	x25, .L1533
	cmp	x25, x21
	beq	.L1534
	orr	x24, x25, x24
	b	.L1496
.L1501:
	and	x24, x24, -71776119061217281
	cbz	x25, .L1535
	cmp	x25, x22
	beq	.L1536
	orr	x24, x25, x24
	b	.L1500
.L1481:
	and	x24, x24, -65281
	cbz	x25, .L1537
	cmp	x25, 57344
	beq	.L1538
	orr	x24, x25, x24
	b	.L1480
.L1485:
	and	x24, x24, -16711681
	cbz	x25, .L1539
	cmp	x25, 14680064
	beq	.L1540
	orr	x24, x25, x24
	b	.L1484
.L1489:
	and	x24, x24, -4278190081
	cbz	x25, .L1541
	cmp	x25, x19
	beq	.L1542
	orr	x24, x25, x24
	b	.L1488
.L1493:
	and	x24, x24, -1095216660481
	cbz	x25, .L1543
	cmp	x25, x20
	beq	.L1544
	orr	x24, x25, x24
	b	.L1492
.L1543:
	orr	x5, x5, 4294967296
	b	.L1492
.L1541:
	orr	x5, x5, 16777216
	b	.L1488
.L1539:
	orr	x5, x5, 65536
	b	.L1484
.L1537:
	orr	x5, x5, 256
	b	.L1480
.L1535:
	orr	x5, x5, 281474976710656
	b	.L1500
.L1533:
	orr	x5, x5, 1099511627776
	b	.L1496
.L1531:
	and	x24, x24, -256
	orr	x5, x5, 1
	b	.L1476
.L1544:
	orr	x5, x5, 4294967296
	orr	x24, x24, 1030792151040
	b	.L1492
.L1532:
	and	x6, x24, -256
	orr	x5, x5, 1
	orr	x24, x6, 240
	mov	x6, 0
	b	.L1476
.L1534:
	orr	x5, x5, 1099511627776
	orr	x24, x24, 263882790666240
	b	.L1496
.L1536:
	orr	x5, x5, 281474976710656
	orr	x24, x24, 67553994410557440
	b	.L1500
.L1538:
	orr	x5, x5, 256
	orr	x24, x24, 61440
	b	.L1480
.L1540:
	orr	x5, x5, 65536
	orr	x24, x24, 15728640
	b	.L1484
.L1542:
	orr	x5, x5, 16777216
	orr	x24, x24, 4026531840
	b	.L1488
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
	ble	.L1545
	sub	w12, w10, #1
	mov	w13, 0
	add	x12, x12, 1
	mov	x11, 255
	lsl	x12, x12, 3
	.p2align 2
.L1547:
	cmp	w10, 0
	ble	.L1558
	add	x7, x0, 8
	mov	x5, 0
	.p2align 2
.L1557:
	ldr	x3, [x1, x5, lsl 3]
	ldr	x8, [x7, -8]
	eor	x6, x3, x8
	cmp	x3, x8
	beq	.L1548
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
.L1548:
	add	x5, x5, 1
	add	x7, x7, 8
	cmp	w10, w5
	bgt	.L1557
	add	x0, x0, x12
	add	x2, x2, x12
	add	x1, x1, x12
.L1558:
	add	w13, w13, 1
	cmp	w14, w13
	bne	.L1547
.L1545:
	ret
	.size	refresh_new_image_auto, .-refresh_new_image_auto
	.align	2
	.p2align 3,,7
	.type	ebc_thread, %function
ebc_thread:
	stp	x29, x30, [sp, -208]!
	adrp	x1, .LANCHOR0
	adrp	x0, __stack_chk_guard
	add	x0, x0, :lo12:__stack_chk_guard
	add	x29, sp, 0
	stp	x25, x26, [sp, 64]
	stp	x27, x28, [sp, 80]
	stp	x19, x20, [sp, 16]
	ldr	x27, [x1, #:lo12:.LANCHOR0]
	stp	x21, x22, [sp, 32]
	stp	x23, x24, [sp, 48]
	add	x26, x27, 224
	ldr	x1, [x0]
	str	x1, [x29, 200]
	mov	x1,0
	add	x0, x27, 40
	str	x0, [x29, 144]
	add	x0, x27, 256
	str	x0, [x29, 136]
	add	x0, x27, 744
	str	x0, [x29, 152]
	add	x0, x27, 688
	str	x0, [x29, 128]
	.p2align 2
.L1562:
	bl	ebc_osd_buf_get
	mov	x19, x0
	cbz	x0, .L1563
.L1972:
	ldr	x0, [x26, 576]
	cbz	x0, .L1564
	ldr	w0, [x26, 624]
	cmp	w0, 0
	ble	.L1959
	ldr	x0, [x26, 96]
	adrp	x1, .LC122
	add	x1, x1, :lo12:.LC122
	bl	_dev_info
.L1959:
	mov	x0, x19
	bl	ebc_buf_release
	bl	ebc_osd_buf_get
	mov	x19, x0
	cbnz	x0, .L1972
.L1563:
	ldr	w0, [x26, 592]
	str	wzr, [x26, 92]
	cbz	w0, .L1621
	ldr	w0, [x26, 588]
	cbnz	w0, .L1621
	ldr	w0, [x26, 596]
	cbnz	w0, .L1621
.L1622:
	ldr	w0, [x26, 88]
	cbz	w0, .L1973
.L1807:
.L1805:
	str	wzr, [x26, 88]
	b	.L1562
.L1973:
	mov	w1, 0
	add	x0, x29, 160
	bl	init_wait_entry
	mov	x20, 15
	adrp	x0, .LANCHOR1
	add	x19, x0, :lo12:.LANCHOR1
	add	x19, x19, 304
	mov	w2, 1
	add	x1, x29, 160
	mov	x0, x19
	bl	prepare_to_wait_event
	mov	x3, x0
	ldr	w0, [x26, 88]
	mov	w2, 0
	cmp	w0, 0
	cset	w1, ne
.L1797:
	mov	x0, x20
	orr	w1, w1, w2
	cbnz	w1, .L1796
	cbnz	x3, .L1795
	bl	schedule_timeout
	mov	x20, x0
	mov	w2, 1
	add	x1, x29, 160
	mov	x0, x19
	bl	prepare_to_wait_event
	mov	x3, x0
	ldr	w0, [x26, 88]
	cmp	w0, 0
	cset	w1, ne
	cmp	x20, 0
	cset	w2, eq
	tst	w1, w2
	beq	.L1797
.L1796:
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 304
	add	x1, x29, 160
	bl	finish_wait
.L1795:
	ldr	w0, [x26, 88]
	cbnz	w0, .L1562
	ldr	w0, [x26, 52]
	cmp	w0, 1
	bne	.L1800
	add	x0, x29, 160
	mov	w1, 0
	bl	init_wait_entry
	adrp	x0, .LANCHOR1
	add	x19, x0, :lo12:.LANCHOR1
	add	x19, x19, 304
	b	.L1803
	.p2align 3
.L1974:
	ldr	w1, [x26, 88]
	cbnz	w1, .L1801
	cbnz	x0, .L1802
	bl	schedule
.L1803:
	add	x1, x29, 160
	mov	w2, 1
	mov	x0, x19
	bl	prepare_to_wait_event
	ldr	w1, [x26, 52]
	cbnz	w1, .L1974
.L1801:
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 304
	add	x1, x29, 160
	bl	finish_wait
.L1802:
	bl	ebc_get_dsp_list_enum_num
	cbnz	w0, .L1562
	bl	ebc_get_osd_list_enum_num
	cbnz	w0, .L1562
	ldr	w0, [x26, 52]
	cbz	w0, .L1961
.L1804:
	ldr	w0, [x26, 88]
	cbnz	w0, .L1805
	add	x0, x29, 160
	mov	w1, 0
	bl	init_wait_entry
	adrp	x0, .LANCHOR1
	add	x19, x0, :lo12:.LANCHOR1
	add	x19, x19, 304
.L1808:
	add	x1, x29, 160
	mov	w2, 1
	mov	x0, x19
	bl	prepare_to_wait_event
	ldr	w1, [x26, 88]
	cbnz	w1, .L1806
	cbnz	x0, .L1805
	bl	schedule
	b	.L1808
	.p2align 3
.L1564:
	ldr	w0, [x26, 240]
	cmp	w0, 2
	beq	.L1571
	cmp	w0, 1
	beq	.L1975
.L1568:
	str	x19, [x26, 232]
	mov	w0, 4
	str	w0, [x26, 240]
	ldr	x0, [x26, 216]
	ldp	w2, w22, [x19, 48]
	ldp	w1, w24, [x19, 56]
	cmp	w2, 0
	ldr	x12, [x0, 16]
	add	w23, w2, 7
	ldr	w0, [x27, 308]
	csel	w23, w23, w2, lt
	add	w14, w1, 7
	cmp	w1, 0
	csel	w14, w14, w1, lt
	add	w21, w0, 7
	cmp	w0, 0
	asr	w14, w14, 3
	csel	w21, w21, w0, lt
	add	w14, w14, 1
	asr	w21, w21, 3
	ldr	w0, [x27, 304]
	cmp	w14, w21
	sub	w1, w21, #1
	csel	w14, w1, w14, ge
	cmp	w0, w24
	sub	w0, w0, #1
	ldr	x8, [x26, 136]
	csel	w24, w0, w24, le
	mul	w0, w22, w21
	ldp	x13, x9, [x26, 160]
	asr	w23, w23, 3
	ldr	x11, [x19, 16]
	sbfiz	x0, x0, 3, 32
	cmp	w22, w24
	add	x12, x12, x0
	add	x11, x11, x0
	add	x8, x8, x0
	add	x13, x13, x0
	add	x9, x9, x0
	bgt	.L1580
	sbfiz	x21, x21, 3, 32
	mov	x20, 4026531840
	mov	x28, 3758096384
	mov	x19, 1030792151040
	mov	x25, 962072674304
	mov	x18, 263882790666240
	mov	x17, 67553994410557440
	mov	x16, -1152921504606846976
	.p2align 2
.L1581:
	cmp	w23, w14
	mov	w5, w23
	ble	.L1890
	b	.L1616
	.p2align 3
.L1976:
	and	x1, x15, 240
	and	x0, x0, -256
	cmp	x1, 240
	and	x30, x3, 255
	bne	.L1583
	mov	x2, x0
	cmp	x30, 240
	orr	x0, x0, 1
	csel	x0, x0, x2, eq
	mov	x2, 255
.L1582:
	tst	x6, 65280
	bne	.L1586
	and	x1, x15, 61440
	and	x0, x0, -65281
	cmp	x1, 61440
	and	x30, x3, 65280
	bne	.L1587
	cmp	x30, 61440
	orr	x1, x0, 256
	orr	x2, x2, 65280
	csel	x0, x1, x0, eq
.L1586:
	tst	x6, 16711680
	bne	.L1590
	and	x1, x15, 15728640
	and	x0, x0, -16711681
	cmp	x1, 15728640
	and	x30, x3, 16711680
	bne	.L1591
	cmp	x30, 15728640
	orr	x1, x0, 65536
	orr	x2, x2, 16711680
	csel	x0, x1, x0, eq
.L1590:
	tst	x6, 4278190080
	bne	.L1594
	and	x1, x15, 4026531840
	and	x0, x0, -4278190081
	cmp	x1, x20
	and	x30, x3, 4278190080
	bne	.L1595
	cmp	x30, x20
	orr	x1, x0, 16777216
	orr	x2, x2, 4278190080
	csel	x0, x1, x0, eq
.L1594:
	tst	x6, 1095216660480
	bne	.L1598
	and	x1, x15, 1030792151040
	and	x0, x0, -1095216660481
	cmp	x1, x19
	and	x30, x3, 1095216660480
	bne	.L1599
	cmp	x30, x19
	orr	x1, x0, 4294967296
	orr	x2, x2, 1095216660480
	csel	x0, x1, x0, eq
.L1598:
	tst	x6, 280375465082880
	bne	.L1602
	and	x1, x15, 263882790666240
	and	x0, x0, -280375465082881
	cmp	x1, x18
	and	x30, x3, 280375465082880
	bne	.L1603
	cmp	x30, x18
	orr	x1, x0, 1099511627776
	orr	x2, x2, 280375465082880
	csel	x0, x1, x0, eq
.L1602:
	tst	x6, 71776119061217280
	bne	.L1606
	and	x1, x15, 67553994410557440
	and	x0, x0, -71776119061217281
	cmp	x1, x17
	and	x30, x3, 71776119061217280
	bne	.L1607
	cmp	x30, x17
	orr	x1, x0, 281474976710656
	orr	x2, x2, 71776119061217280
	csel	x0, x1, x0, eq
.L1606:
	tst	x6, -72057594037927936
	bne	.L1610
	and	x1, x15, -1152921504606846976
	and	x0, x0, 72057594037927935
	cmp	x1, x16
	and	x6, x3, -72057594037927936
	bne	.L1611
	cmp	x6, x16
	orr	x1, x0, 72057594037927936
	orr	x2, x2, -72057594037927936
	csel	x0, x1, x0, eq
.L1610:
	str	x0, [x10]
	eor	x0, x3, x7
	and	x0, x0, x2
	add	w5, w5, 1
	eor	x0, x7, x0
	str	x0, [x4]
	cmp	w5, w14
	bgt	.L1616
.L1890:
	sxtw	x1, w5
	lsl	x0, x1, 3
	add	x4, x8, x0
	add	x10, x9, x0
	ldr	x6, [x13, x1, lsl 3]
	ldr	x7, [x8, x1, lsl 3]
	ldr	x15, [x11, x1, lsl 3]
	ands	x2, x6, 255
	ldr	x3, [x12, x1, lsl 3]
	ldr	x0, [x9, x1, lsl 3]
	beq	.L1976
	mov	x2, 0
	b	.L1582
	.p2align 3
.L1616:
	add	w22, w22, 1
	add	x8, x8, x21
	add	x11, x11, x21
	add	x12, x12, x21
	add	x13, x13, x21
	add	x9, x9, x21
	cmp	w22, w24
	ble	.L1581
.L1580:
	ldr	w0, [x26, 52]
	cbnz	w0, .L1617
	mov	w1, 1
	str	w1, [x26, 52]
	mov	w2, 0
	mov	x0, x27
	bl	ebc_lut_update
	ldr	w2, [x26, 104]
	ldr	w0, [x26, 624]
	strb	w2, [x26, 56]
	lsr	w3, w2, 8
	strb	w3, [x26, 57]
	cmp	w0, 0
	ble	.L1618
	ldr	x0, [x26, 96]
	adrp	x1, .LC125
	and	w3, w3, 255
	and	w2, w2, 255
	add	x1, x1, :lo12:.LC125
	bl	_dev_info
.L1618:
	mov	x0, x27
	bl	ebc_frame_start
.L1619:
	ldr	x0, [x26, 224]
	cbz	x0, .L1620
	bl	ebc_buf_release
.L1620:
	ldr	x0, [x26, 232]
	str	x0, [x26, 224]
	b	.L1562
	.p2align 3
.L1587:
	and	x7, x7, -65281
	cbnz	x1, .L1588
	orr	x0, x0, 256
	b	.L1586
	.p2align 3
.L1595:
	and	x7, x7, -4278190081
	cbnz	x1, .L1596
	orr	x0, x0, 16777216
	b	.L1594
	.p2align 3
.L1583:
	cbnz	x1, .L1584
	and	x7, x7, -256
	orr	x0, x0, 1
	b	.L1582
	.p2align 3
.L1603:
	cbnz	x1, .L1604
	and	x7, x7, -280375465082881
	orr	x0, x0, 1099511627776
	b	.L1602
	.p2align 3
.L1611:
	cbnz	x1, .L1612
	and	x7, x7, 72057594037927935
	orr	x0, x0, 72057594037927936
	b	.L1610
	.p2align 3
.L1599:
	and	x7, x7, -1095216660481
	cbnz	x1, .L1600
	orr	x0, x0, 4294967296
	b	.L1598
	.p2align 3
.L1591:
	and	x7, x7, -16711681
	cbnz	x1, .L1592
	orr	x0, x0, 65536
	b	.L1590
	.p2align 3
.L1607:
	cbnz	x1, .L1608
	and	x7, x7, -71776119061217281
	orr	x0, x0, 281474976710656
	b	.L1606
	.p2align 3
.L1604:
	mov	x30, 246290604621824
	and	x7, x7, -280375465082881
	cmp	x1, x30
	beq	.L1977
	orr	x7, x1, x7
	b	.L1602
	.p2align 3
.L1588:
	cmp	x1, 57344
	beq	.L1978
	orr	x7, x1, x7
	b	.L1586
	.p2align 3
.L1596:
	cmp	x1, x28
	beq	.L1979
	orr	x7, x1, x7
	b	.L1594
	.p2align 3
.L1584:
	cmp	x1, 224
	beq	.L1980
	bfi	x7, x1, 0, 8
	b	.L1582
	.p2align 3
.L1608:
	mov	x30, 63050394783186944
	and	x7, x7, -71776119061217281
	cmp	x1, x30
	beq	.L1981
	orr	x7, x1, x7
	b	.L1606
	.p2align 3
.L1612:
	mov	x6, -2305843009213693952
	and	x7, x7, 72057594037927935
	cmp	x1, x6
	beq	.L1982
	orr	x7, x1, x7
	b	.L1610
	.p2align 3
.L1600:
	cmp	x1, x25
	beq	.L1983
	orr	x7, x1, x7
	b	.L1598
	.p2align 3
.L1592:
	cmp	x1, 14680064
	beq	.L1984
	orr	x7, x1, x7
	b	.L1590
.L1980:
	and	x7, x7, -256
	orr	x0, x0, 1
	orr	x7, x7, 240
	b	.L1582
.L1977:
	orr	x0, x0, 1099511627776
	orr	x7, x7, 263882790666240
	b	.L1602
.L1981:
	orr	x0, x0, 281474976710656
	orr	x7, x7, 67553994410557440
	b	.L1606
.L1979:
	orr	x0, x0, 16777216
	orr	x7, x7, 4026531840
	b	.L1594
.L1983:
	orr	x0, x0, 4294967296
	orr	x7, x7, 1030792151040
	b	.L1598
.L1978:
	orr	x0, x0, 256
	orr	x7, x7, 61440
	b	.L1586
.L1982:
	orr	x0, x0, 72057594037927936
	orr	x7, x7, -1152921504606846976
	b	.L1610
.L1984:
	orr	x0, x0, 65536
	orr	x7, x7, 15728640
	b	.L1590
.L1617:
	adrp	x0, .LANCHOR0
	add	x0, x0, :lo12:.LANCHOR0
	ldr	x0, [x0, 8]
	bl	wake_up_process
	b	.L1619
.L1621:
	bl	ebc_dsp_buf_get
	mov	x19, x0
	cbz	x0, .L1622
	ldr	w2, [x0, 40]
	cmp	w2, 21
	beq	.L1623
	ldr	w0, [x26, 584]
	cbz	w0, .L1985
	ldr	w0, [x26, 240]
	cmp	w0, 2
	beq	.L1629
	cmp	w0, 1
	beq	.L1986
.L1628:
	ldr	x0, [x26, 216]
	ldr	w0, [x0, 40]
	cmp	w0, w2
	beq	.L1632
	ldr	w0, [x26, 52]
	cbnz	w0, .L1822
.L1632:
	mov	w0, 4
	str	x19, [x26, 216]
	str	w0, [x26, 240]
	mov	x5, x26
	ldr	x0, [x26, 136]
	ldr	x1, [x26, 16]
	ldp	x3, x4, [x26, 160]
	ldr	x2, [x19, 16]
	bl	refresh_new_image
	ldr	w0, [x26, 52]
	cbz	w0, .L1987
	ldr	x0, [x26, 216]
	ldr	w0, [x0, 40]
	cmp	w0, 0
	sub	w0, w0, #22
	ccmp	w0, 1, 0, ne
	bhi	.L1820
.L1648:
	ldr	w0, [x26, 460]
	cbnz	w0, .L1988
.L1791:
	mov	w0, 1
	str	w0, [x26, 460]
.L1792:
	ldr	x0, [x26, 216]
	str	x0, [x26, 208]
	b	.L1562
.L1975:
	ldr	w2, [x26, 72]
	cbz	w2, .L1569
	ldr	w0, [x26, 624]
	cmp	w0, 0
	ble	.L1570
	ldr	x0, [x26, 96]
	adrp	x1, .LC123
	add	x1, x1, :lo12:.LC123
	bl	_dev_info
.L1570:
	str	wzr, [x26, 72]
	b	.L1568
.L1571:
	ldr	x0, [x26, 208]
	ldrsw	x2, [x26, 28]
	ldr	x1, [x0, 16]
	ldr	x0, [x26, 144]
	bl	memcpy
	ldr	x0, [x26, 216]
	ldrsw	x2, [x26, 28]
	ldr	x1, [x0, 16]
	ldr	x0, [x26, 136]
	bl	memcpy
	b	.L1568
.L1569:
	ldr	w0, [x26, 604]
	cbz	w0, .L1571
	ldr	w0, [x26, 600]
	cbnz	w0, .L1572
	ldr	w0, [x26, 608]
	cbz	w0, .L1571
.L1572:
	ldr	w0, [x26, 624]
	cmp	w0, 0
	ble	.L1573
	ldr	x0, [x26, 96]
	adrp	x1, .LC124
	add	x1, x1, :lo12:.LC124
	bl	_dev_info
.L1573:
	ldr	x0, [x26, 216]
	ldr	w2, [x26, 28]
	ldr	x1, [x26, 152]
	cmp	w2, 0
	ldr	x5, [x0, 16]
	ble	.L1574
	mov	x4, 0
.L1577:
	ldrb	w3, [x5, x4]
	ldrb	w0, [x1, x4]
	cmp	w0, 8
	mvn	w0, w3
	and	w0, w0, -16
	csel	w0, w0, w3, ne
	strb	w0, [x1, x4]
	add	x4, x4, 1
	cmp	w2, w4
	bgt	.L1577
	ldr	w2, [x26, 28]
	ldr	x1, [x26, 152]
.L1574:
	ldr	x0, [x26, 144]
	sxtw	x2, w2
	bl	memcpy
	ldr	x0, [x26, 216]
	ldrsw	x2, [x26, 28]
	ldr	x1, [x0, 16]
	ldr	x0, [x26, 136]
	bl	memcpy
	str	wzr, [x26, 600]
	str	wzr, [x26, 608]
	b	.L1568
.L1985:
	ldr	w0, [x26, 240]
	cmp	w0, 4
	beq	.L1989
.L1625:
	ldr	w0, [x26, 460]
	cbnz	w0, .L1651
.L1821:
	str	x19, [x26, 208]
	ldr	w2, [x19, 40]
.L1651:
	cmp	w2, 16
	bgt	.L1653
	cmp	w2, 7
	bge	.L1826
	cmp	w2, 0
	beq	.L1655
	blt	.L1652
	cmp	w2, 2
	bge	.L1656
.L1652:
	ldr	x0, [x26, 96]
	adrp	x1, .LC144
	add	x1, x1, :lo12:.LC144
	bl	_dev_err
	b	.L1959
.L1623:
	ldr	w0, [x26, 460]
	cbz	w0, .L1821
.L1656:
	mov	w20, 1
.L1654:
	ldr	w0, [x26, 52]
	cbz	w0, .L1686
	ldr	w0, [x26, 624]
	cmp	w0, 0
	bgt	.L1687
.L1689:
	add	x0, x29, 160
	mov	w1, 0
	bl	init_wait_entry
	adrp	x0, .LANCHOR1
	add	x21, x0, :lo12:.LANCHOR1
	add	x21, x21, 304
	b	.L1688
.L1990:
	cbnz	x0, .L1690
	bl	schedule
.L1688:
	add	x1, x29, 160
	mov	w2, 1
	mov	x0, x21
	bl	prepare_to_wait_event
	ldr	w1, [x26, 52]
	cbnz	w1, .L1990
	mov	x0, x21
	add	x1, x29, 160
	bl	finish_wait
.L1692:
.L1690:
	ldr	w0, [x26, 624]
	cmp	w0, 0
	ble	.L1686
	ldr	x0, [x26, 96]
	adrp	x1, .LC127
	add	x1, x1, :lo12:.LC127
	bl	_dev_info
.L1686:
	ldr	w0, [x26, 240]
	sub	w0, w0, #3
	cmp	w0, 1
	bls	.L1991
.L1694:
	ldr	w6, [x19, 40]
	cmp	w6, 11
	sub	w0, w6, #2
	ccmp	w6, 6, 4, ne
	ccmp	w0, 1, 0, ne
	bls	.L1992
	sub	w0, w6, #7
	cmp	w0, 1
	bls	.L1993
.L1697:
	add	w20, w20, 1
.L1709:
	ldr	w0, [x27, 828]
	cbnz	w0, .L1994
.L1711:
	cmp	w20, 2
	str	wzr, [x26, 600]
	cset	w2, eq
	str	wzr, [x26, 608]
.L1714:
	str	x19, [x26, 216]
	ldr	w1, [x19, 40]
	cmp	w1, 13
	beq	.L1995
.L1722:
	cmp	w1, 12
	beq	.L1996
	cmp	w1, 14
	bne	.L1723
	ldr	w0, [x26, 604]
	cbnz	w0, .L1997
.L1723:
	mov	x0, x27
	bl	ebc_lut_update
	ldr	w0, [x26, 104]
	strb	w0, [x26, 56]
.L1724:
	ldr	w0, [x27, 828]
	cbz	w0, .L1726
	ldr	w0, [x19, 40]
	sub	w0, w0, #12
	cmp	w0, 2
	bls	.L1998
.L1726:
	adrp	x0, .LC136
	add	x21, x0, :lo12:.LC136
.L1767:
	ldr	w0, [x26, 624]
	cmp	w0, 0
	ble	.L1728
	ldr	x0, [x26, 216]
	mov	x1, x21
	ldrb	w4, [x26, 104]
	ldrb	w3, [x26, 56]
	ldr	w2, [x0, 40]
	ldr	x0, [x26, 96]
	bl	_dev_info
.L1728:
	mov	w0, 1
	str	w20, [x26, 240]
	str	w0, [x26, 52]
	mov	x0, x27
	bl	ebc_frame_start
	adrp	x0, jiffies
	ldr	x1, [x0, #:lo12:jiffies]
	ldr	x0, [x29, 152]
	add	x1, x1, 900
	bl	mod_timer
	ldr	w11, [x27, 828]
	cbz	w11, .L1729
	ldr	w0, [x19, 40]
	sub	w0, w0, #12
	cmp	w0, 2
	bls	.L1999
.L1729:
	ldr	w0, [x26, 52]
	cbz	w0, .L1744
.L2008:
	ldr	w0, [x26, 624]
	cmp	w0, 0
	bgt	.L1745
.L1747:
	add	x0, x29, 160
	mov	w1, 0
	bl	init_wait_entry
	adrp	x0, .LANCHOR1
	add	x22, x0, :lo12:.LANCHOR1
	add	x22, x22, 304
	b	.L1746
.L2000:
	cbnz	x0, .L1748
	bl	schedule
.L1746:
	add	x1, x29, 160
	mov	w2, 1
	mov	x0, x22
	bl	prepare_to_wait_event
	ldr	w1, [x26, 52]
	cbnz	w1, .L2000
.L1750:
	mov	x0, x22
	add	x1, x29, 160
	bl	finish_wait
.L1748:
	ldr	w0, [x26, 72]
	cbnz	w0, .L2001
.L1752:
	ldr	w0, [x27, 828]
	cbnz	w0, .L2002
.L1759:
	adrp	x0, jiffies
	ldr	x1, [x0, #:lo12:jiffies]
	mov	x0, 402653184
	add	x1, x1, x0
	ldr	x0, [x29, 152]
	bl	mod_timer
	ldr	w0, [x26, 460]
	cbz	w0, .L1791
.L1988:
	ldr	x0, [x26, 208]
	bl	ebc_buf_release
	b	.L1792
.L1993:
	ldr	w0, [x26, 612]
	cbz	w0, .L1701
	ldr	w2, [x26, 28]
	mov	w0, 50
	mov	w1, 34079
	ldr	x4, [x19, 16]
	movk	w1, 0x51eb, lsl 16
	cmp	w2, 0
	mul	w0, w2, w0
	smull	x1, w0, w1
	asr	x1, x1, 40
	sub	w0, w1, w0, asr 31
	ldr	x1, [x26, 208]
	ldr	x5, [x1, 16]
	add	w1, w2, 7
	csel	w1, w1, w2, lt
	asr	w1, w1, 3
	cmp	w1, 0
	ble	.L1702
	mov	x2, 0
	mov	w3, 0
	b	.L1705
	.p2align 3
.L2004:
	cmp	w1, w2
	ble	.L2003
.L1705:
	ldr	x8, [x4, x2, lsl 3]
	ldr	x7, [x5, x2, lsl 3]
	add	x2, x2, 1
	cmp	x8, x7
	cinc	w3, w3, ne
	cmp	w0, w3
	bge	.L2004
	ldr	w0, [x26, 624]
	mov	w20, 2
	cmp	w0, 0
	ble	.L1709
	ldr	x0, [x26, 96]
	adrp	x1, .LC133
	add	x1, x1, :lo12:.LC133
	mov	w20, 2
	bl	_dev_info
	ldr	w0, [x27, 828]
	ldr	w6, [x19, 40]
	cbz	w0, .L1711
.L1994:
	sub	w6, w6, #12
	cmp	w6, 2
	bls	.L2005
	ldr	w0, [x26, 608]
	cbz	w0, .L1711
	ldr	w0, [x26, 624]
	cmp	w0, 0
	ble	.L1721
	ldr	x0, [x26, 96]
	adrp	x1, .LC135
	add	x1, x1, :lo12:.LC135
	bl	_dev_info
.L1721:
	mov	w0, 21
	str	w0, [x19, 40]
	str	wzr, [x26, 600]
	mov	w2, 1
	str	wzr, [x26, 608]
	mov	w20, 2
	str	x19, [x26, 216]
	ldr	w1, [x19, 40]
	cmp	w1, 13
	bne	.L1722
.L1995:
	ldr	w0, [x26, 604]
	cbz	w0, .L1723
	mov	w1, 14
	mov	x0, x27
	bl	ebc_lut_update
	ldr	w2, [x26, 104]
	mov	w0, 2
	strb	w0, [x26, 56]
	mov	w1, 21846
	and	w0, w2, 255
	movk	w1, 0x5555, lsl 16
	sub	w0, w0, #6
	ubfx	x2, x2, 1, 7
	strb	w2, [x26, 697]
	smull	x1, w0, w1
	lsr	x1, x1, 32
	sub	w0, w1, w0, asr 31
	strb	w0, [x26, 696]
	b	.L1724
	.p2align 3
.L1999:
	ldr	w0, [x26, 608]
	cbz	w0, .L1729
	ldr	w0, [x26, 624]
	cmp	w0, 0
	ble	.L1730
	ldr	x0, [x26, 96]
	adrp	x1, .LC137
	add	x1, x1, :lo12:.LC137
	bl	_dev_info
	ldr	w11, [x26, 604]
.L1730:
	ldr	x0, [x26, 216]
	ldp	w22, w14, [x26, 80]
	ldrsb	w15, [x26, 696]
	ldrsb	w17, [x26, 697]
	cmp	w22, 0
	ldp	x8, x6, [x26, 136]
	ldr	x7, [x26, 152]
	ldr	x10, [x0, 16]
	ble	.L1829
	mov	w9, w14
	neg	w12, w15
	neg	w23, w17
	mov	w24, 0
	mov	w13, 0
	mov	w16, 1
	mov	w18, -16
	.p2align 2
.L1743:
	cmp	w14, 0
	ble	.L1732
	sub	w0, w9, w14
	b	.L1742
	.p2align 3
.L1734:
	sub	w1, w1, #1
	mov	w28, -1
	cmp	w25, 0
	sxtb	w1, w1
	mov	w2, w28
	ble	.L2006
.L1739:
	cmp	w12, w28
	beq	.L1740
	cmp	w11, 1
	ble	.L2007
.L1741:
	orr	w3, w3, 1
	mov	w24, 1
	strb	w3, [x6, x4]
.L1738:
	strb	w1, [x8, x4]
	strb	w2, [x7, x4]
.L1733:
	add	w0, w0, 1
	cmp	w0, w9
	beq	.L1732
.L1742:
	ldrb	w5, [x10, w0, sxtw]
	sxtw	x4, w0
	ldrb	w3, [x6, w0, sxtw]
	cmp	w5, w3
	beq	.L1733
	cmp	w5, 240
	ldrsb	w25, [x7, w0, sxtw]
	ldrsb	w1, [x8, w0, sxtw]
	bne	.L1734
	add	w2, w25, 1
	cmp	w25, 0
	and	w2, w2, 255
	add	w1, w1, 1
	csel	w2, w2, w16, ge
	sxtb	w1, w1
	sxtb	w2, w2
	cmp	w15, w2
	beq	.L1736
	cmp	w11, 1
	ccmp	w17, w1, 0, le
	bgt	.L1741
.L1736:
	strb	w18, [x6, x4]
	b	.L1738
	.p2align 3
.L2007:
	cmp	w1, w23
	bgt	.L1741
.L1740:
	strb	w5, [x6, x4]
	b	.L1738
	.p2align 3
.L2006:
	add	w2, w25, w28
	sxtb	w2, w2
	mov	w28, w2
	b	.L1739
	.p2align 3
.L1732:
	add	w13, w13, 1
	add	w9, w9, w14
	cmp	w22, w13
	bne	.L1743
	str	w24, [x26, 600]
.L2018:
	ldr	w0, [x26, 52]
	cbnz	w0, .L2008
.L1744:
	ldr	w0, [x26, 624]
	tbnz	w0, #31, .L1748
	ldr	x0, [x26, 96]
	adrp	x1, .LC139
	add	x1, x1, :lo12:.LC139
	bl	_dev_info
	ldr	w0, [x26, 72]
	cbz	w0, .L1752
.L2001:
	ldr	w0, [x26, 624]
	cmp	w0, 0
	ble	.L1753
	ldr	x0, [x26, 96]
	adrp	x1, .LC140
	add	x1, x1, :lo12:.LC140
	bl	_dev_info
.L1753:
	ldr	x0, [x26, 208]
	ldrsw	x2, [x26, 28]
	ldr	x1, [x0, 16]
	ldr	x0, [x26, 144]
	bl	memcpy
	ldr	x0, [x26, 216]
	ldrsw	x2, [x26, 28]
	ldr	x1, [x0, 16]
	ldr	x0, [x26, 136]
	bl	memcpy
	ldrsw	x2, [x26, 28]
	mov	w1, 0
	ldr	x0, [x26, 160]
	bl	memset
	ldr	w0, [x26, 72]
	ldrb	w1, [x26, 56]
	ldr	w2, [x26, 28]
	sub	w1, w1, w0
	ldr	x3, [x26, 160]
	cmp	w2, 0
	mov	x0, 0
	ldp	x5, x4, [x26, 136]
	ble	.L1759
.L1891:
	ldrb	w7, [x4, x0]
	ldrb	w6, [x5, x0]
	cmp	w7, w6
	beq	.L1755
	strb	w1, [x3, x0]
.L1755:
	add	x0, x0, 1
	cmp	w2, w0
	bgt	.L1891
	b	.L1759
.L2002:
	ldr	w0, [x19, 40]
	sub	w0, w0, #12
	cmp	w0, 2
	bhi	.L1759
	ldr	w0, [x26, 600]
	cbz	w0, .L2009
	bl	ebc_get_dsp_list_enum_num
	cbnz	w0, .L1759
	str	wzr, [x26, 88]
	mov	w1, 0
	add	x0, x29, 160
	mov	x22, 3
	bl	init_wait_entry
	adrp	x0, .LANCHOR1
	add	x23, x0, :lo12:.LANCHOR1
	add	x23, x23, 304
	mov	w2, 1
	add	x1, x29, 160
	mov	x0, x23
	bl	prepare_to_wait_event
	mov	x3, x0
	ldr	w0, [x26, 88]
	mov	w2, 0
	cmp	w0, 0
	cset	w1, ne
	.p2align 2
.L1765:
	mov	x0, x22
	orr	w1, w1, w2
	cbnz	w1, .L1764
	cbnz	x3, .L1763
	bl	schedule_timeout
	mov	x22, x0
	mov	w2, 1
	add	x1, x29, 160
	mov	x0, x23
	bl	prepare_to_wait_event
	mov	x3, x0
	ldr	w0, [x26, 88]
	cmp	w0, 0
	cset	w1, ne
	cmp	x22, 0
	cset	w2, eq
	tst	w1, w2
	beq	.L1765
.L1764:
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 304
	add	x1, x29, 160
	bl	finish_wait
.L1763:
	bl	ebc_get_dsp_list_enum_num
	cbnz	w0, .L1759
	ldr	w0, [x26, 624]
	cmp	w0, 0
	ble	.L1766
	ldr	x0, [x26, 96]
	adrp	x1, .LC141
	add	x1, x1, :lo12:.LC141
	bl	_dev_info
.L1766:
	ldr	x0, [x26, 208]
	ldrsw	x2, [x26, 28]
	ldr	x1, [x26, 144]
	ldr	x0, [x0, 16]
	bl	memcpy
	b	.L1767
.L1745:
	ldr	x0, [x26, 96]
	adrp	x1, .LC138
	add	x1, x1, :lo12:.LC138
	bl	_dev_info
	ldr	w0, [x26, 52]
	cbz	w0, .L1748
	b	.L1747
	.p2align 3
.L1992:
	ldr	x0, [x26, 208]
	ldr	w1, [x27, 252]
	ldr	x4, [x19, 16]
	cmp	w1, 0
	ldr	x5, [x0, 16]
	add	w0, w1, 7
	csel	w0, w0, w1, lt
	asr	w0, w0, 3
	cmp	w0, 0
	ble	.L1702
	ldr	x2, [x4]
	ldr	x1, [x5]
	cmp	x2, x1
	bne	.L1697
	sub	w1, w0, #1
	mov	x0, 8
	add	x1, x1, 1
	lsl	x1, x1, 3
	b	.L1699
.L1700:
	ldr	x3, [x4, x0]
	add	x0, x0, 8
	add	x2, x5, x0
	ldr	x2, [x2, -8]
	cmp	x3, x2
	bne	.L1697
.L1699:
	cmp	x1, x0
	bne	.L1700
.L1702:
	ldr	w0, [x26, 624]
	cmp	w0, 0
	ble	.L1815
	ldr	x0, [x26, 96]
	adrp	x1, .LC132
	add	x1, x1, :lo12:.LC132
	bl	_dev_info
.L1815:
	str	x19, [x26, 216]
	b	.L1648
.L1653:
	cmp	w2, 21
	beq	.L1656
	ble	.L2010
	cmp	w2, 23
	bgt	.L1652
.L1655:
	ldr	w0, [x26, 240]
	str	x19, [x26, 216]
	cmp	w0, 1
	beq	.L2011
	cmp	w0, 2
	beq	.L1960
	cmp	w0, 4
	beq	.L2012
.L1675:
	ldr	x0, [x26, 208]
	ldr	w1, [x19, 40]
	ldr	w0, [x0, 40]
	cmp	w1, w0
	beq	.L1669
	ldr	w0, [x26, 52]
	cbz	w0, .L1669
	ldr	w0, [x26, 624]
	cmp	w0, 0
	bgt	.L1677
.L1679:
	add	x0, x29, 160
	mov	w1, 0
	bl	init_wait_entry
	adrp	x0, .LANCHOR1
	add	x20, x0, :lo12:.LANCHOR1
	add	x20, x20, 304
	b	.L1678
	.p2align 3
.L2013:
	cbnz	x0, .L1680
	bl	schedule
.L1678:
	add	x1, x29, 160
	mov	w2, 1
	mov	x0, x20
	bl	prepare_to_wait_event
	ldr	w1, [x26, 52]
	cbnz	w1, .L2013
.L1681:
	mov	x0, x20
	add	x1, x29, 160
	bl	finish_wait
	b	.L1680
	.p2align 3
.L1826:
	mov	w20, 0
	b	.L1654
.L1989:
	ldr	w0, [x26, 52]
	cbz	w0, .L1625
	ldr	x0, [x26, 216]
	ldr	w0, [x0, 40]
	cmp	w2, w0
	beq	.L1632
.L1822:
	ldr	w0, [x26, 624]
	cmp	w0, 0
	bgt	.L1634
.L1636:
	add	x0, x29, 160
	mov	w1, 0
	bl	init_wait_entry
	adrp	x0, .LANCHOR1
	add	x20, x0, :lo12:.LANCHOR1
	add	x20, x20, 304
	b	.L1635
.L2014:
	cbnz	x0, .L1637
	bl	schedule
.L1635:
	add	x1, x29, 160
	mov	w2, 1
	mov	x0, x20
	bl	prepare_to_wait_event
	ldr	w1, [x26, 52]
	cbnz	w1, .L2014
	mov	x0, x20
	add	x1, x29, 160
	bl	finish_wait
.L1639:
.L1637:
	ldr	w0, [x26, 624]
	cmp	w0, 0
	ble	.L1632
	ldr	x0, [x26, 96]
	adrp	x1, .LC127
	add	x1, x1, :lo12:.LC127
	bl	_dev_info
	b	.L1632
.L1987:
	mov	w0, 1
	str	w0, [x26, 52]
	mov	w2, 0
	mov	x0, x27
	ldr	w1, [x19, 40]
	bl	ebc_lut_update
	ldr	w3, [x26, 104]
	ldr	w0, [x26, 624]
	strb	w3, [x26, 56]
	cmp	w0, 0
	lsr	w0, w3, 8
	strb	w0, [x26, 57]
	ble	.L1641
	ldr	x0, [x26, 216]
	adrp	x1, .LC128
	and	w3, w3, 255
	add	x1, x1, :lo12:.LC128
	ldr	w2, [x0, 40]
	ldr	x0, [x26, 96]
	bl	_dev_info
.L1641:
	ldr	x0, [x29, 144]
	ldp	x1, x2, [x26, 136]
	ldp	x3, x4, [x26, 160]
	ldr	w0, [x0, 164]
	cbz	w0, .L1642
	ldr	x0, [x26, 176]
	mov	w6, 1
	mov	x5, x26
	bl	get_overlay_image2
.L1643:
	ldr	w0, [x26, 60]
	cbz	w0, .L1644
	ldr	x0, [x29, 144]
	ldp	x1, x2, [x26, 136]
	ldp	x3, x4, [x26, 160]
	ldr	w0, [x0, 164]
	cbz	w0, .L1645
	ldr	x0, [x26, 184]
	mov	w6, 1
	mov	x5, x26
	bl	get_overlay_image2
.L1646:
	ldp	x1, x0, [x29, 136]
	str	wzr, [x0, 72]
	bl	flip.isra.13
.L1647:
	ldr	x0, [x26, 216]
	ldr	w0, [x0, 40]
	cmp	w0, 0
	sub	w0, w0, #22
	ccmp	w0, 1, 0, ne
	bls	.L1648
	ldr	w0, [x26, 52]
	cbz	w0, .L1648
.L1820:
	ldr	w0, [x26, 624]
	str	wzr, [x26, 588]
	cmp	w0, 0
	ble	.L1650
	ldr	x0, [x26, 96]
	adrp	x1, .LC130
	add	x1, x1, :lo12:.LC130
	bl	_dev_info
.L1650:
	ldrb	w0, [x26, 56]
	add	w0, w0, w0, lsl 1
	lsl	w0, w0, 2
	bl	__msecs_to_jiffies
	adrp	x1, jiffies
	ldr	x1, [x1, #:lo12:jiffies]
	add	x1, x1, x0
	ldr	x0, [x29, 128]
	bl	mod_timer
	b	.L1648
.L1986:
	ldr	w2, [x26, 72]
	cbz	w2, .L1629
	ldr	w0, [x26, 624]
	cmp	w0, 0
	ble	.L1630
	ldr	x0, [x26, 96]
	adrp	x1, .LC123
	add	x1, x1, :lo12:.LC123
	bl	_dev_info
.L1630:
	str	wzr, [x26, 72]
	ldr	w2, [x19, 40]
	b	.L1628
.L2005:
	ldr	w0, [x26, 600]
	cbnz	w0, .L2015
	ldr	w0, [x26, 608]
	cbnz	w0, .L1715
	ldr	x0, [x26, 208]
	ldr	w2, [x27, 252]
	ldr	x4, [x19, 16]
	cmp	w2, 0
	ldr	x1, [x0, 16]
	add	w0, w2, 7
	csel	w0, w0, w2, lt
	asr	w0, w0, 3
	cmp	w0, 0
	ble	.L1716
	ldr	x3, [x1]
	ldr	x5, [x4]
	cmp	x5, x3
	bne	.L1717
	sub	w0, w0, #1
	mov	x3, 8
	add	x0, x0, 1
	lsl	x0, x0, 3
	b	.L1719
.L1720:
	ldr	x6, [x4, x3]
	add	x3, x3, 8
	add	x5, x1, x3
	ldr	x5, [x5, -8]
	cmp	x6, x5
	bne	.L1717
.L1719:
	cmp	x0, x3
	bne	.L1720
.L1716:
	ldr	w0, [x26, 624]
	cmp	w0, 0
	ble	.L1815
	ldr	x0, [x26, 96]
	adrp	x1, .LC134
	add	x1, x1, :lo12:.LC134
	bl	_dev_info
	str	x19, [x26, 216]
	b	.L1648
	.p2align 3
.L1629:
	ldr	x0, [x26, 208]
	ldrsw	x2, [x26, 28]
	ldr	x1, [x0, 16]
	ldr	x0, [x26, 144]
	bl	memcpy
	ldr	x0, [x26, 216]
	ldrsw	x2, [x26, 28]
	ldr	x1, [x0, 16]
	ldr	x0, [x26, 136]
	bl	memcpy
	ldr	w2, [x19, 40]
	b	.L1628
.L1644:
	mov	w0, 1
	str	wzr, [x26, 52]
	str	w0, [x26, 588]
	ldr	w0, [x26, 624]
	cmp	w0, 0
	ble	.L1648
	ldr	x0, [x26, 96]
	adrp	x1, .LANCHOR3
	add	x2, x1, :lo12:.LANCHOR3
	adrp	x1, .LC129
	add	x2, x2, 64
	add	x1, x1, :lo12:.LC129
	bl	_dev_info
	b	.L1647
.L1642:
	ldr	x0, [x26, 176]
	mov	w6, 1
	mov	x5, x26
	bl	get_overlay_image
	b	.L1643
.L1687:
	ldr	x0, [x26, 96]
	adrp	x1, .LC126
	add	x1, x1, :lo12:.LC126
	bl	_dev_info
	ldr	w0, [x26, 52]
	cbz	w0, .L1690
	b	.L1689
	.p2align 3
.L1634:
	ldr	x0, [x26, 96]
	adrp	x1, .LC126
	add	x1, x1, :lo12:.LC126
	bl	_dev_info
	ldr	w0, [x26, 52]
	cbz	w0, .L1637
	b	.L1636
	.p2align 3
.L1998:
	ldr	w0, [x26, 608]
	cbnz	w0, .L1817
	ldrsw	x2, [x26, 28]
	mov	w1, 0
	ldr	x0, [x26, 152]
	bl	memset
	ldrsw	x2, [x26, 28]
	mov	w1, 0
	ldr	x0, [x26, 136]
	bl	memset
.L1817:
	mov	w0, 1
	str	w0, [x26, 608]
	b	.L1726
.L1996:
	ldr	w0, [x26, 604]
	cbz	w0, .L1723
	mov	w1, 14
	mov	x0, x27
	bl	ebc_lut_update
	ldr	w0, [x26, 104]
	mov	w1, 3
	mov	w2, 43691
	strb	w1, [x26, 56]
	and	w1, w0, 255
	movk	w2, 0xaaaa, lsl 16
	and	w0, w0, 255
	sub	w0, w0, #6
	umull	x1, w1, w2
	cmp	w0, 0
	lsr	x1, x1, 33
	strb	w1, [x26, 697]
	add	w1, w0, 3
	csel	w0, w1, w0, lt
	asr	w0, w0, 2
	strb	w0, [x26, 696]
	b	.L1724
	.p2align 3
.L1645:
	ldr	x0, [x26, 184]
	mov	w6, 1
	mov	x5, x26
	bl	get_overlay_image
	b	.L1646
.L2009:
	ldr	w0, [x26, 608]
	cbz	w0, .L1759
	bl	ebc_get_dsp_list_enum_num
	cbnz	w0, .L1759
	str	wzr, [x26, 88]
	mov	w1, 0
	add	x0, x29, 160
	mov	x20, 3
	bl	init_wait_entry
	adrp	x0, .LANCHOR1
	add	x19, x0, :lo12:.LANCHOR1
	add	x19, x19, 304
	mov	w2, 1
	add	x1, x29, 160
	mov	x0, x19
	bl	prepare_to_wait_event
	mov	x3, x0
	ldr	w0, [x26, 88]
	mov	w1, 0
	cmp	w0, 0
	cset	w2, ne
.L1771:
	mov	x0, x20
	orr	w1, w1, w2
	cbnz	w1, .L1770
	cbnz	x3, .L1769
	bl	schedule_timeout
	mov	x20, x0
	mov	w2, 1
	add	x1, x29, 160
	mov	x0, x19
	bl	prepare_to_wait_event
	mov	x3, x0
	ldr	w0, [x26, 88]
	cmp	w0, 0
	cset	w2, ne
	cmp	x20, 0
	cset	w1, eq
	tst	w2, w1
	beq	.L1771
.L1770:
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 304
	add	x1, x29, 160
	bl	finish_wait
.L1769:
	bl	ebc_get_dsp_list_enum_num
	cbnz	w0, .L1759
	ldr	w0, [x26, 624]
	cmp	w0, 0
	ble	.L1772
	ldr	x0, [x26, 96]
	adrp	x1, .LC142
	add	x1, x1, :lo12:.LC142
	bl	_dev_info
.L1772:
	ldp	w28, w21, [x26, 80]
	ldr	x0, [x26, 216]
	sub	w28, w28, #1
	cmp	w28, 1
	ldp	x20, x24, [x26, 144]
	ldr	x23, [x0, 16]
	ble	.L1773
	sub	w4, w21, #1
	mov	w0, w28
	mov	w1, 1
	mov	w28, w4
	mov	x6, x26
	add	w25, w21, 1
	sub	w3, w21, #2
	mov	x5, x27
	mov	w26, w1
	mov	w4, w0
.L1775:
	cmp	w28, 1
	add	w27, w3, w25
	mov	w19, w25
	ble	.L1784
	str	w28, [x29, 124]
	mov	w28, w26
	mov	w26, w25
	mov	x25, x5
	b	.L1783
	.p2align 3
.L1778:
	add	w19, w19, 1
	cmp	w19, w27
	beq	.L2016
.L1783:
	ldrb	w0, [x24, w19, sxtw]
	sxtw	x22, w19
	cbz	w0, .L1778
	ldrb	w1, [x23, w19, sxtw]
	str	x6, [x29, 104]
	stp	w3, w4, [x29, 112]
	str	w1, [x29, 120]
	bl	prandom_u32
	uxtw	x0, w0
	add	x0, x0, x0, lsl 1
	ldr	w1, [x29, 120]
	lsr	x0, x0, 32
	ldr	x6, [x29, 104]
	lsl	w0, w0, 4
	cmp	w1, 240
	sub	w1, w0, #88
	strb	w1, [x20, w19, sxtw]
	ldp	w3, w4, [x29, 112]
	bne	.L1778
	sub	w1, w19, w21
	ldrb	w2, [x24, w1, sxtw]
	cbnz	w2, .L1780
	ldrb	w2, [x23, w1, sxtw]
	cmp	w2, 240
	bne	.L1780
	sub	w2, w0, #40
	strb	w2, [x20, w1, sxtw]
.L1780:
	add	w1, w19, w21
	ldrb	w2, [x24, w1, sxtw]
	cbnz	w2, .L1781
	ldrb	w2, [x23, w1, sxtw]
	cmp	w2, 240
	bne	.L1781
	sub	w2, w0, #40
	strb	w2, [x20, w1, sxtw]
.L1781:
	sub	x1, x22, #1
	ldrb	w2, [x24, x1]
	cbnz	w2, .L1782
	ldrb	w2, [x23, x1]
	cmp	w2, 240
	bne	.L1782
	sub	w2, w0, #40
	strb	w2, [x20, x1]
.L1782:
	add	x1, x22, 1
	ldrb	w2, [x24, x1]
	cbnz	w2, .L1778
	ldrb	w2, [x23, x1]
	cmp	w2, 240
	bne	.L1778
	sub	w0, w0, #40
	strb	w0, [x20, x1]
	add	w19, w19, 1
	cmp	w19, w27
	bne	.L1783
.L2016:
	mov	x5, x25
	mov	w25, w26
	mov	w26, w28
	ldr	w28, [x29, 124]
.L1784:
	add	w26, w26, 1
	add	w25, w25, w21
	cmp	w26, w4
	bne	.L1775
	ldr	x20, [x6, 144]
	mov	x27, x5
	mov	x26, x6
.L1773:
	ldr	x0, [x26, 208]
	mov	x1, x20
	ldrsw	x2, [x26, 28]
	ldr	x0, [x0, 16]
	bl	memcpy
	mov	w0, 13
	strb	w0, [x26, 56]
	mov	w0, 1
	str	w0, [x26, 52]
	ldr	w0, [x26, 624]
	cmp	w0, 0
	ble	.L1785
	ldr	x0, [x26, 216]
	adrp	x1, .LC143
	mov	w3, 13
	add	x1, x1, :lo12:.LC143
	ldr	w2, [x0, 40]
	ldr	x0, [x26, 96]
	bl	_dev_info
.L1785:
	mov	x0, x27
	bl	ebc_frame_start
	adrp	x0, jiffies
	ldr	x1, [x0, #:lo12:jiffies]
	ldr	x0, [x29, 152]
	add	x1, x1, 900
	bl	mod_timer
	ldr	w0, [x26, 624]
	cmp	w0, 0
	ble	.L1786
	ldr	x0, [x26, 96]
	adrp	x1, .LC138
	add	x1, x1, :lo12:.LC138
	bl	_dev_info
.L1786:
	ldr	w0, [x26, 52]
	cbnz	w0, .L2017
.L1789:
.L1787:
	str	wzr, [x26, 608]
	b	.L1759
	.p2align 3
.L1829:
	mov	w24, 0
	str	w24, [x26, 600]
	b	.L2018
.L1997:
	mov	x0, x27
	bl	ebc_lut_update
	ldr	w2, [x26, 104]
	mov	w0, 4
	strb	w0, [x26, 56]
	mov	w1, 26215
	and	w0, w2, 255
	movk	w1, 0x6666, lsl 16
	sub	w0, w0, #6
	ubfx	x2, x2, 2, 6
	strb	w2, [x26, 697]
	smull	x1, w0, w1
	asr	x1, x1, 33
	sub	w0, w1, w0, asr 31
	strb	w0, [x26, 696]
	b	.L1724
.L1715:
	ldr	x0, [x26, 208]
	ldr	w2, [x26, 28]
	ldr	x1, [x0, 16]
.L1717:
	ldr	x0, [x26, 144]
	sxtw	x2, w2
	bl	memcpy
	cmp	w20, 2
	cset	w2, eq
	b	.L1714
.L2015:
	ldr	x0, [x26, 208]
	ldrsw	x2, [x26, 28]
	ldr	x1, [x26, 144]
	ldr	x0, [x0, 16]
	bl	memcpy
	cmp	w20, 2
	cset	w2, eq
	b	.L1714
.L1991:
	ldr	x0, [x26, 208]
	str	wzr, [x26, 600]
	str	wzr, [x26, 608]
	ldrsw	x2, [x26, 28]
	ldr	x1, [x26, 144]
	ldr	x0, [x0, 16]
	bl	memcpy
	b	.L1694
.L1669:
	ldr	x1, [x19, 16]
	mov	x3, x26
	ldr	x0, [x26, 136]
	ldr	x2, [x26, 160]
	bl	refresh_new_image_auto
.L1666:
	ldr	w0, [x26, 52]
	mov	w1, 3
	str	w1, [x26, 240]
	cbnz	w0, .L1648
	mov	w0, 1
	str	w0, [x26, 52]
	mov	w2, 0
	mov	x0, x27
	ldr	w1, [x19, 40]
	bl	ebc_lut_update
	ldr	w2, [x26, 104]
	ldr	w0, [x26, 624]
	strb	w2, [x26, 56]
	cmp	w0, 0
	lsr	w0, w2, 8
	strb	w0, [x26, 57]
	ble	.L1684
	ldr	x0, [x26, 96]
	adrp	x1, .LC131
	and	w2, w2, 255
	add	x1, x1, :lo12:.LC131
	bl	_dev_info
.L1684:
	mov	x0, x27
	bl	ebc_frame_start
	b	.L1648
.L2012:
	ldr	w0, [x26, 52]
	cbz	w0, .L1669
	ldr	w0, [x26, 624]
	cmp	w0, 0
	bgt	.L1670
.L1672:
	add	x0, x29, 160
	mov	w1, 0
	bl	init_wait_entry
	adrp	x0, .LANCHOR1
	add	x20, x0, :lo12:.LANCHOR1
	add	x20, x20, 304
	b	.L1671
	.p2align 3
.L2019:
	cbnz	x0, .L1680
	bl	schedule
.L1671:
	add	x1, x29, 160
	mov	w2, 1
	mov	x0, x20
	bl	prepare_to_wait_event
	ldr	w1, [x26, 52]
	cbnz	w1, .L2019
	b	.L1681
	.p2align 3
.L1960:
	ldr	x0, [x26, 208]
	ldrsw	x2, [x26, 28]
	ldr	x1, [x0, 16]
	ldr	x0, [x26, 144]
	bl	memcpy
.L1683:
	ldr	x0, [x26, 216]
	ldrsw	x2, [x26, 28]
	ldr	x1, [x0, 16]
	ldr	x0, [x26, 136]
	bl	memcpy
	b	.L1666
.L2011:
	ldr	w0, [x26, 604]
	cbz	w0, .L1960
	ldr	w0, [x26, 600]
	cbnz	w0, .L1660
	ldr	w0, [x26, 608]
	cbz	w0, .L1960
.L1660:
	ldr	w0, [x26, 624]
	cmp	w0, 0
	mov	x0, x19
	ble	.L1661
	ldr	x0, [x26, 96]
	adrp	x1, .LC124
	add	x1, x1, :lo12:.LC124
	bl	_dev_info
	ldr	x0, [x26, 216]
.L1661:
	ldr	w2, [x26, 28]
	ldr	x5, [x0, 16]
	cmp	w2, 0
	ldr	x1, [x26, 152]
	ble	.L1662
	mov	x4, 0
.L1665:
	ldrb	w3, [x5, x4]
	ldrb	w0, [x1, x4]
	cmp	w0, 8
	mvn	w0, w3
	and	w0, w0, -16
	csel	w0, w0, w3, ne
	strb	w0, [x1, x4]
	add	x4, x4, 1
	cmp	w2, w4
	bgt	.L1665
	ldr	w2, [x26, 28]
	ldr	x1, [x26, 152]
.L1662:
	ldr	x0, [x26, 144]
	sxtw	x2, w2
	bl	memcpy
	ldr	x0, [x26, 216]
	ldrsw	x2, [x26, 28]
	ldr	x1, [x0, 16]
	ldr	x0, [x26, 136]
	bl	memcpy
	str	wzr, [x26, 600]
	str	wzr, [x26, 608]
	b	.L1666
.L1677:
	ldr	x0, [x26, 96]
	adrp	x1, .LC126
	add	x1, x1, :lo12:.LC126
	bl	_dev_info
	ldr	w0, [x26, 52]
	cbnz	w0, .L1679
.L1682:
.L1680:
	ldr	w0, [x26, 624]
	cmp	w0, 0
	ble	.L1683
	ldr	x0, [x26, 96]
	adrp	x1, .LC127
	add	x1, x1, :lo12:.LC127
	bl	_dev_info
	b	.L1683
	.p2align 3
.L2010:
	cmp	w2, 17
	bne	.L1652
	b	.L1656
	.p2align 3
.L2003:
	cbnz	w3, .L1697
	b	.L1702
.L1670:
	ldr	x0, [x26, 96]
	adrp	x1, .LC126
	add	x1, x1, :lo12:.LC126
	bl	_dev_info
	ldr	w0, [x26, 52]
	cbz	w0, .L1680
	b	.L1672
.L2017:
	add	x0, x29, 160
	mov	w1, 0
	bl	init_wait_entry
	adrp	x0, .LANCHOR1
	add	x19, x0, :lo12:.LANCHOR1
	add	x19, x19, 304
.L1790:
	add	x1, x29, 160
	mov	w2, 1
	mov	x0, x19
	bl	prepare_to_wait_event
	ldr	w1, [x26, 52]
	cbz	w1, .L1788
	cbnz	x0, .L1787
	bl	schedule
	b	.L1790
.L1800:
	bl	ebc_get_dsp_list_enum_num
	cbnz	w0, .L1562
	bl	ebc_get_osd_list_enum_num
	cbnz	w0, .L1562
.L1961:
	mov	w1, 0
	mov	x0, x27
	bl	ebc_power_set
	b	.L1804
.L1806:
	mov	x0, x19
	add	x1, x29, 160
	bl	finish_wait
	str	wzr, [x26, 88]
	b	.L1562
.L1701:
	ldr	x0, [x26, 208]
	ldr	w1, [x27, 252]
	ldr	x2, [x19, 16]
	cmp	w1, 0
	ldr	x3, [x0, 16]
	add	w0, w1, 7
	csel	w0, w0, w1, lt
	asr	w0, w0, 3
	cmp	w0, 0
	ble	.L1702
	ldr	x1, [x2]
	ldr	x4, [x3]
	cmp	x4, x1
	bne	.L1697
	sub	w0, w0, #1
	mov	x1, 8
	add	x0, x0, 1
	lsl	x0, x0, 3
	b	.L1707
	.p2align 3
.L1708:
	ldr	x5, [x2, x1]
	add	x1, x1, 8
	add	x4, x3, x1
	ldr	x4, [x4, -8]
	cmp	x5, x4
	bne	.L1697
.L1707:
	cmp	x0, x1
	bne	.L1708
	b	.L1702
.L1788:
	mov	x0, x19
	add	x1, x29, 160
	bl	finish_wait
	b	.L1787
	.size	ebc_thread, .-ebc_thread
	.align	2
	.p2align 3,,7
	.type	ebc_auto_tast_function, %function
ebc_auto_tast_function:
	stp	x29, x30, [sp, -112]!
	adrp	x0, __stack_chk_guard
	add	x0, x0, :lo12:__stack_chk_guard
	add	x29, sp, 0
	stp	x23, x24, [sp, 48]
	adrp	x24, .LANCHOR0
	stp	x19, x20, [sp, 16]
	mov	x23, 2
	stp	x21, x22, [sp, 32]
	adrp	x21, .LANCHOR1
	stp	x25, x26, [sp, 64]
	add	x21, x21, :lo12:.LANCHOR1
	ldr	x26, [x24, #:lo12:.LANCHOR0]
	add	x20, x21, 808
	stp	x27, x28, [sp, 80]
	add	x21, x21, 352
	add	x19, x26, 40
	add	x27, x26, 224
	ldr	x1, [x0]
	str	x1, [x29, 104]
	mov	x1,0
	add	x25, x26, 256
	add	x28, x26, 744
#APP
// 19 "/home/lyx/rk3566-11-eink/kernel/arch/arm64/include/asm/current.h" 1
	mrs x22, sp_el0
// 0 "" 2
#NO_APP
	b	.L2047
	.p2align 3
.L2057:
	cmp	w0, 4
	beq	.L2023
	cmp	w0, 1
	beq	.L2055
	ldr	x0, [x27, 216]
	ldr	w0, [x0, 40]
	cmp	w0, 21
	beq	.L2056
	ldr	w2, [x27, 72]
	mov	x1, x25
	mov	x0, x19
	sub	w2, w2, #1
	str	w2, [x27, 72]
	bl	flip.isra.13
	add	x0, x24, :lo12:.LANCHOR0
	ldr	x0, [x0, 16]
	bl	wake_up_process
	ldr	w4, [x27, 72]
	cbz	w4, .L2029
	ldr	w0, [x19, 164]
	cbz	w0, .L2046
	ldrsw	x0, [x19, 72]
	mov	w6, 2
	ldp	x2, x1, [x27, 208]
	add	x0, x0, 22
	ldrb	w3, [x26, 280]
	ldr	x5, [x26, 344]
	ldr	x0, [x27, x0, lsl 3]
	ldr	x1, [x1, 16]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change2.isra.4
	.p2align 2
.L2029:
	mov	x0, x20
	bl	up
	bl	schedule
.L2047:
	mov	x0, x20
	bl	down
	mov	x0, x21
	bl	down
	str	x23, [x22, 32]
#APP
// 2234 "/home/lyx/rk3566-11-eink/kernel/drivers/gpu/drm/rockchip/ebc-dev/ebc_dev_y8.c" 1
	dmb ish
// 0 "" 2
#NO_APP
	ldr	w0, [x27, 240]
	cmp	w0, 3
	bne	.L2057
	ldr	w0, [x27, 60]
	str	wzr, [x27, 68]
	cbnz	w0, .L2034
	ldr	w0, [x27, 64]
	cbz	w0, .L2035
.L2034:
	mov	x1, x25
	mov	x0, x19
	bl	flip.isra.13
	add	x0, x24, :lo12:.LANCHOR0
	ldr	x0, [x0, 16]
	bl	wake_up_process
	ldr	w0, [x19, 164]
	cbz	w0, .L2036
	ldrsw	x0, [x19, 72]
	mov	w5, 2
	ldp	x1, x2, [x27, 136]
	add	x0, x0, 22
	ldr	x3, [x27, 160]
	mov	x4, x27
	ldr	x0, [x27, x0, lsl 3]
	bl	get_auto_image2
	b	.L2029
	.p2align 3
.L2055:
	ldr	w2, [x27, 72]
	mov	x1, x25
	mov	x0, x19
	sub	w2, w2, #1
	str	w2, [x27, 72]
	bl	flip.isra.13
	add	x0, x24, :lo12:.LANCHOR0
	ldr	x0, [x0, 16]
	bl	wake_up_process
	ldr	w4, [x27, 72]
	cbz	w4, .L2029
	ldr	w0, [x19, 164]
	cbz	w0, .L2041
	ldrsw	x0, [x19, 72]
	mov	w6, 2
	ldp	x2, x1, [x27, 208]
	add	x0, x0, 22
	ldrb	w3, [x26, 280]
	ldr	x5, [x26, 344]
	ldr	x0, [x27, x0, lsl 3]
	ldr	x1, [x1, 16]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change_part2.isra.9
	b	.L2029
	.p2align 3
.L2023:
	ldr	w0, [x27, 76]
	cbz	w0, .L2025
	ldr	w0, [x27, 60]
	str	wzr, [x27, 68]
	str	wzr, [x27, 76]
	cbnz	w0, .L2026
	ldr	w0, [x27, 64]
	cbz	w0, .L2027
.L2026:
	mov	x1, x25
	mov	x0, x19
	bl	flip.isra.13
	add	x0, x24, :lo12:.LANCHOR0
	ldr	x0, [x0, 16]
	bl	wake_up_process
	ldr	w0, [x19, 164]
	cbz	w0, .L2028
	ldrsw	x0, [x19, 72]
	mov	w6, 2
	ldp	x1, x2, [x27, 136]
	add	x0, x0, 22
	ldp	x3, x4, [x27, 160]
	mov	x5, x27
	ldr	x0, [x27, x0, lsl 3]
	bl	get_overlay_image2
	b	.L2029
	.p2align 3
.L2036:
	ldrsw	x0, [x19, 72]
	mov	w5, 2
	ldp	x1, x2, [x27, 136]
	add	x0, x0, 22
	ldr	x3, [x27, 160]
	mov	x4, x27
	ldr	x0, [x27, x0, lsl 3]
	bl	get_auto_image
	b	.L2029
	.p2align 3
.L2025:
	mov	x0, x21
	bl	up
	ldr	w0, [x19, 164]
	cbz	w0, .L2033
	ldrsw	x0, [x19, 72]
	mov	x4, x27
	ldp	x1, x2, [x27, 136]
	add	x0, x0, 22
	ldr	x3, [x27, 160]
	ldr	x0, [x27, x0, lsl 3]
	bl	get_overlay_image_area2.isra.0
	b	.L2029
	.p2align 3
.L2028:
	ldrsw	x0, [x19, 72]
	mov	w6, 2
	ldp	x1, x2, [x27, 136]
	add	x0, x0, 22
	ldp	x3, x4, [x27, 160]
	mov	x5, x27
	ldr	x0, [x27, x0, lsl 3]
	bl	get_overlay_image
	b	.L2029
	.p2align 3
.L2056:
	ldr	w3, [x27, 672]
	mov	x1, x25
	ldr	w2, [x27, 684]
	mov	x0, x19
	add	w2, w2, w3
	str	w2, [x27, 684]
	bl	flip.isra.13
	add	x0, x24, :lo12:.LANCHOR0
	ldr	x0, [x0, 16]
	bl	wake_up_process
	mov	x0, x27
	bl	is_full_refresh_done
	tst	w0, 255
	beq	.L2043
	mov	w0, 1
	str	w0, [x27, 688]
	b	.L2029
	.p2align 3
.L2041:
	ldrsw	x0, [x19, 72]
	mov	w6, 2
	ldp	x2, x1, [x27, 208]
	add	x0, x0, 22
	ldrb	w3, [x26, 280]
	ldr	x5, [x26, 344]
	ldr	x0, [x27, x0, lsl 3]
	ldr	x1, [x1, 16]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change_part.isra.10
	b	.L2029
	.p2align 3
.L2035:
	mov	x0, x21
	bl	up
	ldr	w0, [x27, 596]
	cbz	w0, .L2058
.L2037:
	ldr	w0, [x19, 164]
	cbz	w0, .L2038
	ldrsw	x0, [x19, 72]
	mov	w5, 1
	ldp	x1, x2, [x27, 136]
	add	x0, x0, 22
	ldr	x3, [x27, 160]
	mov	x4, x27
	ldr	x0, [x27, x0, lsl 3]
	bl	get_auto_image2
.L2039:
	adrp	x1, jiffies
	mov	w0, 1
	str	w0, [x27, 68]
	mov	x0, x28
	ldr	x1, [x1, #:lo12:jiffies]
	add	x1, x1, 1
	bl	mod_timer
	b	.L2029
	.p2align 3
.L2046:
	ldrsw	x0, [x19, 72]
	mov	w6, 2
	ldp	x2, x1, [x27, 208]
	add	x0, x0, 22
	ldrb	w3, [x26, 280]
	ldr	x5, [x26, 344]
	ldr	x0, [x27, x0, lsl 3]
	ldr	x1, [x1, 16]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change.isra.2
	b	.L2029
	.p2align 3
.L2027:
	mov	x0, x21
	bl	up
	ldr	w0, [x27, 596]
	cbz	w0, .L2059
.L2030:
	ldr	w0, [x19, 164]
	cbz	w0, .L2031
	ldrsw	x0, [x19, 72]
	mov	w6, 1
	ldp	x1, x2, [x27, 136]
	add	x0, x0, 22
	ldp	x3, x4, [x27, 160]
	mov	x5, x27
	ldr	x0, [x27, x0, lsl 3]
	bl	get_overlay_image2
	b	.L2039
	.p2align 3
.L2033:
	ldrsw	x0, [x19, 72]
	mov	x5, x27
	ldp	x1, x2, [x27, 136]
	add	x0, x0, 22
	ldp	x3, x4, [x27, 160]
	ldr	x0, [x27, x0, lsl 3]
	bl	get_overlay_image_area
	b	.L2029
	.p2align 3
.L2043:
	ldr	w0, [x19, 164]
	cbz	w0, .L2044
	ldrsw	x0, [x19, 72]
	mov	w4, 2
	ldp	x2, x1, [x27, 208]
	add	x0, x0, 22
	mov	x3, x27
	ldr	x0, [x27, x0, lsl 3]
	ldr	x1, [x1, 16]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change_full2
	b	.L2029
	.p2align 3
.L2038:
	ldrsw	x0, [x19, 72]
	mov	w5, 1
	ldp	x1, x2, [x27, 136]
	add	x0, x0, 22
	ldr	x3, [x27, 160]
	mov	x4, x27
	ldr	x0, [x27, x0, lsl 3]
	bl	get_auto_image
	b	.L2039
	.p2align 3
.L2031:
	ldrsw	x0, [x19, 72]
	mov	w6, 1
	ldp	x1, x2, [x27, 136]
	add	x0, x0, 22
	ldp	x3, x4, [x27, 160]
	mov	x5, x27
	ldr	x0, [x27, x0, lsl 3]
	bl	get_overlay_image
	b	.L2039
	.p2align 3
.L2044:
	ldrsw	x0, [x19, 72]
	mov	w4, 2
	ldp	x2, x1, [x27, 208]
	add	x0, x0, 22
	mov	x3, x27
	ldr	x0, [x27, x0, lsl 3]
	ldr	x1, [x1, 16]
	ldr	x2, [x2, 16]
	bl	direct_mode_data_change_full
	b	.L2029
	.p2align 3
.L2058:
	ldr	x1, [x27, 216]
	mov	x3, x27
	ldr	x0, [x27, 136]
	ldr	x2, [x27, 160]
	ldr	x1, [x1, 16]
	bl	refresh_new_image_auto
	b	.L2037
	.p2align 3
.L2059:
	ldr	x2, [x27, 216]
	mov	x5, x27
	ldr	x1, [x27, 16]
	ldr	x0, [x27, 136]
	ldp	x3, x4, [x27, 160]
	ldr	x2, [x2, 16]
	bl	refresh_new_image
	b	.L2030
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
	.xword	.LC145
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
	.xword	.LC90
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
	.xword	.LC157
	.xword	waveform_ops
	.zero	56
	.type	dev_attr_waveform_version, %object
	.size	dev_attr_waveform_version, 32
dev_attr_waveform_version:
	.xword	.LC156
	.hword	292
	.zero	6
	.xword	waveform_version_read
	.xword	0
	.type	dev_attr_pmic_name, %object
	.size	dev_attr_pmic_name, 32
dev_attr_pmic_name:
	.xword	.LC155
	.hword	292
	.zero	6
	.xword	pmic_name_read
	.xword	0
	.type	dev_attr_pmic_temp, %object
	.size	dev_attr_pmic_temp, 32
dev_attr_pmic_temp:
	.xword	.LC154
	.hword	292
	.zero	6
	.xword	pmic_temp_read
	.xword	0
	.type	dev_attr_pmic_vcom, %object
	.size	dev_attr_pmic_vcom, 32
dev_attr_pmic_vcom:
	.xword	.LC153
	.hword	420
	.zero	6
	.xword	pmic_vcom_read
	.xword	pmic_vcom_write
	.type	dev_attr_ebc_version, %object
	.size	dev_attr_ebc_version, 32
dev_attr_ebc_version:
	.xword	.LC151
	.hword	292
	.zero	6
	.xword	ebc_version_read
	.xword	0
	.type	dev_attr_ebc_state, %object
	.size	dev_attr_ebc_state, 32
dev_attr_ebc_state:
	.xword	.LC150
	.hword	292
	.zero	6
	.xword	ebc_state_read
	.xword	0
	.type	dev_attr_ebc_buf_state, %object
	.size	dev_attr_ebc_buf_state, 32
dev_attr_ebc_buf_state:
	.xword	.LC149
	.hword	292
	.zero	6
	.xword	ebc_buf_state_read
	.xword	0
	.type	dev_attr_auto_frame_state, %object
	.size	dev_attr_auto_frame_state, 32
dev_attr_auto_frame_state:
	.xword	.LC148
	.hword	292
	.zero	6
	.xword	auto_frame_state_read
	.xword	0
	.type	dev_attr_ebc_debug_level, %object
	.size	dev_attr_ebc_debug_level, 32
dev_attr_ebc_debug_level:
	.xword	.LC152
	.hword	420
	.zero	6
	.xword	ebc_debug_level_read
	.xword	ebc_debug_level_write
	.type	dev_attr_wf_data, %object
	.size	dev_attr_wf_data, 32
dev_attr_wf_data:
	.xword	.LC147
	.hword	128
	.zero	6
	.xword	0
	.xword	wf_data_write
	.type	dev_attr_ori_wf_data, %object
	.size	dev_attr_ori_wf_data, 32
dev_attr_ori_wf_data:
	.xword	.LC146
	.hword	128
	.zero	6
	.xword	0
	.xword	ori_wf_data_write
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
	.type	__func__.42769, %object
	.size	__func__.42769, 11
__func__.42769:
	.string	"ebc_io_ctl"
	.align	3
	.set	.LANCHOR3,. + 0
	.type	__func__.43182, %object
	.size	__func__.43182, 19
__func__.43182:
	.string	"ebc_lut_table_init"
	.zero	5
	.type	__func__.43138, %object
	.size	__func__.43138, 18
__func__.43138:
	.string	"ori_wf_data_write"
	.zero	6
	.type	__func__.42391, %object
	.size	__func__.42391, 16
__func__.42391:
	.string	"ebc_frame_start"
	.type	__func__.42384, %object
	.size	__func__.42384, 27
__func__.42384:
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
	.type	__addressable_ebc_init4518, %object
	.size	__addressable_ebc_init4518, 8
__addressable_ebc_init4518:
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
	.string	"EBC_SET_FULL_REFRESH_TYPE = %d\n"
.LC16:
	.string	"%s: unknown cmd\n"
	.zero	7
.LC17:
	.string	"overlay frame done\n"
	.zero	4
.LC18:
	.string	"auto task break\n"
	.zero	7
.LC19:
	.string	"auto frame done\n"
	.zero	7
.LC20:
	.string	"part task break\n"
	.zero	7
.LC21:
	.string	"frame done\n"
	.zero	4
.LC22:
	.string	"too large resolution, not support\n"
	.zero	5
.LC23:
	.string	"memory-region"
	.zero	2
.LC24:
	.string	"Couldn't address to resource for reserved memory\n"
	.zero	6
.LC25:
	.string	"reserved memory not enough, need 0x%x\n"
	.zero	1
.LC26:
	.string	"Couldn't remap for reserved memory\n"
	.zero	4
.LC27:
	.string	"waveform-region"
.LC28:
	.string	"wf,mode_table"
	.zero	2
.LC29:
	.string	"%s:%d: failed to get mem from reserved\n"
.LC30:
	.string	"Failed to read waveform from mem, we use waveform file from kernel file instead\n"
	.zero	7
.LC31:
	.string	"Failed to read waveform file from kernel, no waveform!!!\n"
	.zero	6
.LC32:
	.string	"temperature = %d, out of range0~50 ,use 25 \n"
	.zero	3
.LC33:
	.string	"temperature = %d, out of range0~50 ,use 50 \n"
	.zero	3
.LC34:
	.string	"ebc_pmic_read_temp failed, ret = %d, use 25 \n"
	.zero	2
.LC35:
	.string	"lut update use temperature = %d\n"
	.zero	7
.LC36:
	.string	"get lut data failed\n"
	.zero	3
.LC37:
	.string	"603893"
	.zero	1
.LC38:
	.string	"lutdata: %d frames\n"
	.zero	4
.LC39:
	.string	"[%d-->%d]: \n"
	.zero	3
.LC40:
	.string	"\001c\0017%d, "
	.zero	7
.LC41:
	.string	"malloc wf_table buffer failed\n"
	.zero	1
.LC42:
	.string	"603893 %d %d"
	.zero	3
.LC43:
	.string	"%s: wf mode %d on temp %d\n"
	.zero	5
.LC44:
	.string	"%s: err code\n"
	.zero	2
.LC45:
	.string	"%s: err lut_type or temp\n"
	.zero	6
.LC46:
	.string	"invalid value = %s\n"
	.zero	4
.LC47:
	.string	"%d\n"
	.zero	4
.LC48:
	.string	"7.11_y8"
.LC49:
	.string	"%s\n"
	.zero	4
.LC50:
	.string	"set vcom value failed\n"
	.zero	1
.LC51:
	.string	"%s: overlay no need to update\n"
	.zero	1
.LC52:
	.string	"%s: auto no need to update\n"
	.zero	4
.LC53:
	.string	"rockchip ebc driver %s probe\n"
	.zero	2
.LC54:
	.string	"cpu-code"
	.zero	7
.LC55:
	.string	"no chip info\n"
	.zero	2
.LC56:
	.string	"read chip info failed\n"
	.zero	1
.LC57:
	.string	"chip err\n"
	.zero	6
.LC58:
	.string	"ebc_tcon"
	.zero	7
.LC59:
	.string	"not find ebc tcon\n"
	.zero	5
.LC60:
	.string	"pmic"
	.zero	3
.LC61:
	.string	"Get PMIC device failed\n"
.LC62:
	.string	"wrong pmics number\n"
	.zero	4
.LC63:
	.string	"not find pmic node\n"
	.zero	4
.LC64:
	.string	"not find pmic i2c client\n"
	.zero	6
.LC65:
	.string	"use pmic%d\n"
	.zero	4
.LC66:
	.string	"vcom"
	.zero	3
.LC67:
	.string	"Failed to get vcom regulator\n"
	.zero	2
.LC68:
	.string	"thermal-zone"
	.zero	3
.LC69:
	.string	"Failed to get thermal zone name\n"
	.zero	7
.LC70:
	.string	"Failed to get thermal device\n"
	.zero	2
.LC71:
	.string	"ebc-dmc-notify-enable"
	.zero	2
.LC72:
	.string	"panel,width"
	.zero	4
.LC73:
	.string	"panel,panel_color"
	.zero	6
.LC74:
	.string	"panel,mirror"
	.zero	3
.LC75:
	.string	"panel,width-mm"
	.zero	1
.LC76:
	.string	"panel,height-mm"
.LC77:
	.string	"panel,disable_logo"
	.zero	5
.LC78:
	.string	"panel,rearrange"
.LC79:
	.string	"panel,sdoe_mode"
.LC80:
	.string	"panel,sdce_width"
	.zero	7
.LC81:
	.string	"panel,gds"
	.zero	6
.LC82:
	.string	"panel,gdl"
	.zero	6
.LC83:
	.string	"buffer manage init failed\n"
	.zero	5
.LC84:
	.string	"lut table init failed\n"
	.zero	1
.LC85:
	.string	"ebc_task"
	.zero	7
.LC86:
	.string	"failed to create ebc_task thread\n"
	.zero	6
.LC87:
	.string	"ebc_taskup"
	.zero	5
.LC88:
	.string	"failed to create ebc_taskup thread\n"
	.zero	4
.LC89:
	.string	"ebc_thread"
	.zero	5
.LC90:
	.string	"ebc"
	.zero	4
.LC91:
	.string	"ulogo_addr="
	.zero	4
.LC92:
	.string	"klogo_addr="
	.zero	4
.LC93:
	.string	"ulogo_addr=0x%x"
.LC94:
	.string	"have ulogo display, ulogo addr = 0x%x\n"
	.zero	1
.LC95:
	.string	"malloc ulogo buffer failed\n"
	.zero	4
.LC96:
	.string	"klogo_addr=0x%x"
.LC97:
	.string	"need show klogo, klogo addr = 0x%x\n"
	.zero	4
.LC98:
	.string	"malloc klogo buffer failed\n"
	.zero	4
.LC99:
	.string	"no uboot logo, panel init\n"
	.zero	5
.LC100:
	.string	"ebc_dev_reset"
	.zero	2
.LC101:
	.string	"ebc_dev_logo"
	.zero	3
.LC102:
	.string	"rockchip ebc driver %s probe success\n"
	.zero	2
.LC103:
	.string	"panel,height"
	.zero	3
.LC104:
	.string	"panel,vir_width"
.LC105:
	.string	"panel,vir_height"
	.zero	7
.LC106:
	.string	"panel,sdck"
	.zero	5
.LC107:
	.string	"panel,lsl"
	.zero	6
.LC108:
	.string	"panel,lbl"
	.zero	6
.LC109:
	.string	"panel,ldl"
	.zero	6
.LC110:
	.string	"panel,lel"
	.zero	6
.LC111:
	.string	"panel,gdck-sta"
	.zero	1
.LC112:
	.string	"panel,lgonl"
	.zero	4
.LC113:
	.string	"panel,fsl"
	.zero	6
.LC114:
	.string	"panel,fbl"
	.zero	6
.LC115:
	.string	"panel,fdl"
	.zero	6
.LC116:
	.string	"panel,fel"
	.zero	6
.LC117:
	.string	"panel,panel_16bit"
	.zero	6
.LC118:
	.string	"failed to run ebc thread\n"
	.zero	6
.LC119:
	.string	"task init failed\n"
	.zero	6
.LC120:
	.string	"failed to probe panel: %d\n"
	.zero	5
.LC121:
	.string	"0\n"
	.zero	5
.LC122:
	.string	"ebc suspend, drop osd buf\n"
	.zero	5
.LC123:
	.string	"break from part work, frame left = %d\n"
	.zero	1
.LC124:
	.string	"break from fast mode, process it\n"
	.zero	6
.LC125:
	.string	"overlay mode start, frame_total=%d, bw_frame = %d\n"
	.zero	5
.LC126:
	.string	"ebc is busy now, waiting prev mode end...\n"
	.zero	5
.LC127:
	.string	"prev refresh mode end\n"
	.zero	1
.LC128:
	.string	"frame start under overlay, mode = %d, framecount = %d\n"
	.zero	1
.LC129:
	.string	"%s: overlay bg no need to update, overlay_bg_update=1\n"
	.zero	1
.LC130:
	.string	"control bg update under overlay mode, overlay_bg_update=0\n"
	.zero	5
.LC131:
	.string	"auto mode start, frame_total=%d\n"
	.zero	7
.LC132:
	.string	"check_part_mode==0, no need refresh\n"
	.zero	3
.LC133:
	.string	"check_diff_percent==2, full refresh\n"
	.zero	3
.LC134:
	.string	"fast check_part_mode==0, no need refresh\n"
	.zero	6
.LC135:
	.string	"change from fast mode and not complete, force full\n"
	.zero	4
.LC136:
	.string	"frame start, mode = %d, framecount = %d vs %d\n"
	.zero	1
.LC137:
	.string	"update repair buf\n"
	.zero	5
.LC138:
	.string	"waiting frame done\n"
	.zero	4
.LC139:
	.string	"----update repair buf timeout----\n"
	.zero	5
.LC140:
	.string	"break from part work, do something before turn to overlay work\n"
.LC141:
	.string	"no buffer, do repair..........\n"
.LC142:
	.string	"no buffer, do last ghost remove..........\n"
	.zero	5
.LC143:
	.string	"frame start, mode = %d, framecount = %d\n"
	.zero	7
.LC144:
	.string	"ebc buffer mode %d error!!!\n"
	.zero	3
.LC145:
	.string	"ebc-dev"
.LC146:
	.string	"ori_wf_data"
	.zero	4
.LC147:
	.string	"wf_data"
.LC148:
	.string	"auto_frame_state"
	.zero	7
.LC149:
	.string	"ebc_buf_state"
	.zero	2
.LC150:
	.string	"ebc_state"
	.zero	6
.LC151:
	.string	"ebc_version"
	.zero	4
.LC152:
	.string	"ebc_debug_level"
.LC153:
	.string	"pmic_vcom"
	.zero	6
.LC154:
	.string	"pmic_temp"
	.zero	6
.LC155:
	.string	"pmic_name"
	.zero	6
.LC156:
	.string	"waveform_version"
	.zero	7
.LC157:
	.string	"waveform"
	.ident	"GCC: (Linaro GCC 6.3-2017.05) 6.3.1 20170404"
	.section	.note.GNU-stack,"",@progbits

// SPDX-License-Identifier: GPL-2.0
/*
 * Copyright (c) 2020 Rockchip Electronics Co. Ltd.
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
	mov	w2, 229
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
	mov	w2, 236
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
	bhi	.L83
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
	ldr	x0, [x0, #:lo12:.LANCHOR0]
	ldrb	w0, [x0, 16]
	cmp	w0, 35
	beq	.L52
	bhi	.L53
	cmp	w0, 18
	beq	.L68
	bls	.L84
	cmp	w0, 22
	bne	.L85
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 36
	ldrb	w0, [x0, x1]
	ret
	.p2align 3
.L53:
	cmp	w0, 72
	beq	.L59
	bls	.L86
	cmp	w0, 84
	beq	.L61
	cmp	w0, 114
	bne	.L51
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 86
	ldrb	w0, [x0, x1]
	ret
	.p2align 3
.L84:
	cmp	w0, 9
	bne	.L51
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 16
	ldrb	w0, [x0, x1]
	ret
	.p2align 3
.L61:
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 76
	ldrb	w0, [x0, x1]
	ret
	.p2align 3
.L59:
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 66
	ldrb	w0, [x0, x1]
	ret
	.p2align 3
.L68:
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 26
	ldrb	w0, [x0, x1]
	ret
	.p2align 3
.L52:
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 56
	ldrb	w0, [x0, x1]
	ret
	.p2align 3
.L85:
	cmp	w0, 25
	beq	.L58
.L51:
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 96
	ldrb	w0, [x0, x1]
	ret
	.p2align 3
.L86:
	cmp	w0, 67
	bne	.L51
.L58:
	adrp	x0, .LANCHOR1
	add	x0, x0, :lo12:.LANCHOR1
	add	x0, x0, 46
	ldrb	w0, [x0, x1]
	ret
.L83:
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
	cbz	x5, .L127
	cbz	x0, .L156
.L89:
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
	beq	.L157
	str	w3, [x2, 4]
	cmp	w23, 10
	beq	.L124
.L123:
	add	x0, x25, :lo12:.LANCHOR0
	ldrb	w6, [x5, 38]
	ldr	x1, [x22, 16]
	str	x1, [x0, 8]
	cbz	w6, .L92
	ldrb	w0, [x5, 48]
	cmp	w20, w0
	ble	.L129
	add	x2, x5, 49
	mov	w19, 0
	b	.L94
	.p2align 3
.L95:
	ldrb	w3, [x2], 1
	cmp	w20, w3
	ble	.L125
.L94:
	add	w19, w19, 1
	cmp	w6, w19
	bne	.L95
.L92:
	sub	w19, w6, #1
.L125:
	mov	w0, w23
	bl	get_wf_mode_index
	mov	w1, w19
	and	w0, w0, 255
	bl	get_wf_frm_num
	tbnz	w0, #31, .L122
	cmp	w23, 7
	beq	.L158
	cmp	w23, 1
	beq	.L159
	sub	w1, w23, #5
	cmp	w1, 1
	bls	.L160
	sub	w1, w23, #11
	cmp	w1, 1
	bls	.L161
	sub	w1, w23, #13
	cmp	w1, 1
	bls	.L162
.L99:
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
	str	w26, [x2, 16]
	smull	x0, w3, w1
	lsr	x0, x0, 32
	sub	w0, w0, w3, asr 31
	cmp	w24, w0
	bne	.L124
	mov	w0, 0
.L164:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x29, x30, [sp], 80
	ret
	.p2align 3
.L124:
	ldr	x1, [x22, 24]
	add	x0, x25, :lo12:.LANCHOR0
	str	x1, [x0, 8]
	bl	epd_overlay_lut
	ldr	x1, [x25, #:lo12:.LANCHOR0]
	ldrb	w3, [x1, 38]
	cbz	w3, .L118
	ldrb	w2, [x1, 48]
	cmp	w20, w2
	ble	.L130
	add	x1, x1, 49
	mov	w19, 0
	b	.L120
	.p2align 3
.L121:
	ldrb	w2, [x1], 1
	cmp	w20, w2
	ble	.L126
.L120:
	add	w19, w19, 1
	cmp	w3, w19
	bne	.L121
.L118:
	sub	w19, w3, #1
.L126:
	bl	get_wf_mode_index
	and	w0, w0, 255
	mov	w1, w19
	bl	get_wf_frm_num
	mov	w1, w0
	tbnz	w0, #31, .L122
	ldrb	w2, [x22]
	add	x21, x21, :lo12:.LANCHOR2
	mov	w0, 0
	orr	w1, w2, w1, lsl 8
	str	w20, [x21, 8]
	str	w1, [x22]
.L87:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x29, x30, [sp], 80
	ret
	.p2align 3
.L157:
	ldr	w0, [x2, 12]
	cmp	w0, w23
	beq	.L163
.L91:
	add	x0, x21, :lo12:.LANCHOR2
	cmp	w23, 10
	str	w3, [x0, 4]
	bne	.L123
	mov	w0, 0
	b	.L164
	.p2align 3
.L159:
	mov	w2, 0
	ldr	x3, [x22, 16]
	cbz	w0, .L105
	.p2align 2
.L142:
	lsl	w1, w2, 10
	add	w2, w2, 1
	add	x1, x3, x1, sxtw
	cmp	w0, w2
	ldrb	w4, [x1, 960]
	strb	w4, [x1, 928]
	bne	.L142
.L105:
	add	x3, x3, 4096
	mov	w1, 1
	strb	w1, [x3]
	strb	w1, [x3, 1024]
	strb	w1, [x3, 2048]
	strb	w1, [x3, 958]
	mov	w1, 2
	strb	w1, [x3, 990]
	strb	w1, [x3, 2014]
	strb	w1, [x3, 3038]
	strb	w1, [x3, 1982]
	strb	w1, [x3, 3006]
	b	.L99
.L161:
	ldr	x4, [x22, 16]
	cbz	w0, .L99
	mov	w2, 0
	.p2align 2
.L112:
	lsl	w1, w2, 10
	add	w2, w2, 1
	add	x1, x4, x1, sxtw
	cmp	w0, w2
	ldrb	w3, [x1, 30]
	strb	wzr, [x1, 989]
	strb	w3, [x1, 31]
	strb	w3, [x1, 29]
	cbz	w26, .L111
	strb	wzr, [x1, 1021]
	strb	wzr, [x1, 1022]
.L111:
	bne	.L112
	b	.L99
	.p2align 3
.L158:
	mov	w3, 0
	ldr	x4, [x22, 16]
	cbz	w0, .L101
	.p2align 2
.L141:
	lsl	w1, w3, 10
	add	w3, w3, 1
	add	x2, x4, x1, sxtw
	cmp	w0, w3
	ldrb	w5, [x2, 960]
	strb	w5, [x2, 928]
	strb	w5, [x4, w1, sxtw]
	ldrb	w1, [x2, 30]
	strb	w1, [x2, 990]
	bne	.L141
.L101:
	mov	w1, 1
	strb	w1, [x4, 958]
	mov	w1, 2
	strb	w1, [x4, 1982]
	strb	w1, [x4, 3006]
	b	.L99
	.p2align 3
.L156:
	ldr	x6, [x0, 16]
	cbnz	x6, .L89
	mov	w0, -22
	b	.L87
	.p2align 3
.L160:
	mov	w2, 0
	ldr	x4, [x22, 16]
	cbz	w0, .L99
	.p2align 2
.L143:
	lsl	w1, w2, 10
	add	w2, w2, 1
	add	x1, x4, x1, sxtw
	cmp	w0, w2
	ldrb	w3, [x1, 30]
	strb	w3, [x1, 31]
	strb	w3, [x1, 29]
	bne	.L143
	b	.L99
	.p2align 3
.L163:
	add	x0, x25, :lo12:.LANCHOR0
	ldr	w0, [x0, 16]
	cmp	w0, w4
	bne	.L91
	mov	w0, 0
	b	.L164
.L129:
	mov	w19, 0
	b	.L125
.L130:
	mov	w19, 0
	b	.L126
.L162:
	mov	w2, 0
	ldr	x4, [x22, 16]
	cbz	w0, .L116
	.p2align 2
.L144:
	lsl	w1, w2, 10
	add	w2, w2, 1
	add	x1, x4, x1, sxtw
	cbz	w26, .L114
	ldrb	w3, [x1, 990]
	strb	w3, [x1, 989]
	strb	wzr, [x1, 990]
	strb	w3, [x1, 1021]
	strb	w3, [x1, 957]
.L114:
	ldrb	w3, [x1, 30]
	cmp	w0, w2
	strb	wzr, [x1, 958]
	strb	wzr, [x1, 1022]
	strb	w3, [x1, 31]
	strb	w3, [x1, 29]
	strb	w3, [x1, 61]
	bne	.L144
.L116:
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
	b	.L99
.L127:
	mov	w0, -19
	b	.L87
.L122:
	adrp	x0, .LC4
	add	x0, x0, :lo12:.LC4
	bl	printk
	mov	w0, -5
	b	.L87
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
	cbz	x1, .L202
	mov	w0, -16
.L165:
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 32
	ret
.L202:
	ldrb	w1, [x0, 16]
	mov	x20, x0
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
	bl	printk
	ldrb	w1, [x20, 16]
	cmp	w1, 32
	beq	.L168
	bls	.L203
	cmp	w1, 72
	beq	.L168
	bhi	.L172
	cmp	w1, 35
	beq	.L171
	cmp	w1, 67
	beq	.L168
.L167:
	ldrb	w2, [x20, 22]
	adrp	x0, .LC6
	add	x0, x0, :lo12:.LC6
	bl	printk
	mov	w0, -8
	b	.L165
.L172:
	cmp	w1, 84
	beq	.L171
	cmp	w1, 114
	bne	.L167
.L168:
	adrp	x0, .LANCHOR2
	mov	w1, 32
	str	w1, [x0, #:lo12:.LANCHOR2]
.L171:
	str	x20, [x19, #:lo12:.LANCHOR0]
	mov	w0, 0
	b	.L165
.L203:
	cmp	w1, 22
	beq	.L168
	bhi	.L170
	cmp	w1, 9
	beq	.L171
	cmp	w1, 18
	beq	.L171
	b	.L167
.L170:
	sub	w0, w1, #24
	cmp	w0, 1
	bhi	.L167
	b	.L168
	.size	pvi_wf_input, .-pvi_wf_input
	.align	2
	.p2align 3,,7
	.global	pvi_wf_get_version
	.type	pvi_wf_get_version, %function
pvi_wf_get_version:
	adrp	x0, .LANCHOR0
	add	x3, x0, :lo12:.LANCHOR0
	ldr	x1, [x0, #:lo12:.LANCHOR0]
	cbz	x1, .L206
	add	x1, x1, 65
	add	x2, x3, 24
	mov	x0, x2
	ldp	x4, x5, [x1]
	stp	x4, x5, [x3, 24]
	ldr	x3, [x1, 16]
	str	x3, [x2, 16]
	ldr	x1, [x1, 23]
	str	x1, [x2, 23]
	strb	wzr, [x2, 31]
	ret
	.p2align 3
.L206:
	mov	x0, 0
	ret
	.size	pvi_wf_get_version, .-pvi_wf_get_version
	.global	pvi_mode_table
	.section	.rodata
	.align	3
	.set	.LANCHOR1,. + 0
	.type	__func__.16869, %object
	.size	__func__.16869, 15
__func__.16869:
	.string	"get_wf_frm_num"
	.zero	1
	.type	pvi_mode_table, %object
	.size	pvi_mode_table, 90
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
	.zero	1
	.byte	0
	.byte	1
	.byte	7
	.byte	3
	.byte	3
	.byte	5
	.byte	6
	.byte	4
	.byte	5
	.zero	1
	.byte	0
	.byte	1
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	4
	.byte	6
	.byte	5
	.zero	1
	.byte	0
	.byte	1
	.byte	7
	.byte	2
	.byte	3
	.byte	4
	.byte	5
	.byte	6
	.byte	4
	.zero	1
	.byte	0
	.byte	1
	.byte	5
	.byte	2
	.byte	3
	.byte	3
	.byte	3
	.byte	4
	.byte	3
	.zero	1
	.byte	0
	.byte	1
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	4
	.byte	6
	.byte	4
	.zero	1
	.byte	0
	.byte	1
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	4
	.byte	5
	.byte	4
	.zero	1
	.byte	0
	.byte	1
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	11
	.byte	6
	.byte	10
	.zero	1
	.byte	0
	.byte	1
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	5
	.byte	6
	.byte	4
	.zero	1
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
	.type	sftemp.16928, %object
	.size	sftemp.16928, 4
sftemp.16928:
	.word	-1
	.type	stype.16927, %object
	.size	stype.16927, 4
stype.16927:
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
	.type	fix.16929, %object
	.size	fix.16929, 4
fix.16929:
	.zero	4
	.zero	4
	.type	spi_id_buffer.16955, %object
	.size	spi_id_buffer.16955, 32
spi_id_buffer.16955:
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

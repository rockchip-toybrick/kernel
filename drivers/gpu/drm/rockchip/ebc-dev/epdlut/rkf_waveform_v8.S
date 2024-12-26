// SPDX-License-Identifier: GPL-2.0
/*
 * Copyright (c) 2020-2024 Rockchip Electronics Co., Ltd.
 *
 * Author: Zorro Liu <zorro.liu@rock-chips.com>
 */

	.arch armv8-a
	.file	"rkf_waveform.c"
	.text
	.align	2
	.p2align 3,,7
	.type	get_wf_level, %function
get_wf_level:
	cmp	w1, 0
	mov	w3, 50
	csel	w1, w1, wzr, ge
	mov	w4, 1
	cmp	w1, w3
	mov	x2, 0
	csel	w1, w1, w3, le
	b	.L2
	.p2align 3
.L12:
	cmp	w1, w3
	blt	.L4
	cmp	w4, 51
	beq	.L11
.L7:
	add	x2, x2, 1
	add	w4, w4, 1
.L2:
	add	x5, x0, x2
	mov	w6, w2
	cbz	x2, .L3
	ldrb	w3, [x0, x2]
	ldrb	w5, [x5, -1]
	cmp	w5, w3
	bls	.L12
.L4:
	sub	w0, w6, #1
	ret
	.p2align 3
.L11:
	mov	w0, 0
	ret
.L3:
	ldrb	w3, [x0]
	cmp	w1, w3
	bge	.L7
	mov	w6, 0
	b	.L4
	.size	get_wf_level, .-get_wf_level
	.align	2
	.p2align 3,,7
	.type	decode_wf_data, %function
decode_wf_data:
	stp	x29, x30, [sp, -48]!
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	uxtw	x20, w1
	mov	w1, 32960
	str	x21, [sp, 32]
	movk	w1, 0x60, lsl 16
	mov	x21, x0
	mov	x0, x20
	bl	__kmalloc
	mov	x19, x0
	cbz	x0, .L14
	mov	x2, x20
	add	x1, x21, 4
	bl	memcpy
.L14:
	mov	x0, x19
	ldr	x21, [sp, 32]
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 48
	ret
	.size	decode_wf_data, .-decode_wf_data
	.align	2
	.p2align 3,,7
	.type	rkf_lut_init_wf_table.isra.2, %function
rkf_lut_init_wf_table.isra.2:
	cmp	w2, 0
	ble	.L28
	sub	w9, w2, #1
	mov	w7, 512
	add	x9, x9, 1
	mov	x8, 0
	lsl	x9, x9, 6
.L24:
	ldr	x5, [x0]
	lsl	w6, w8, 4
	add	x5, x5, x8
	.p2align 2
.L21:
	mov	w4, w6
	mov	w3, 0
	.p2align 2
.L22:
	ldr	w2, [x5]
	lsr	w2, w2, w3
	and	w2, w2, 3
	strb	w2, [x1, w4, uxtw]
	add	w3, w3, 2
	add	w4, w4, 1
	cmp	w3, 32
	bne	.L22
	add	w6, w6, 32
	add	x5, x5, 4
	cmp	w7, w6
	bne	.L21
	add	x8, x8, 64
	add	w7, w7, 1024
	cmp	x9, x8
	bne	.L24
.L28:
	mov	w0, 0
	ret
	.size	rkf_lut_init_wf_table.isra.2, .-rkf_lut_init_wf_table.isra.2
	.align	2
	.p2align 3,,7
	.type	parse_wf_gray16.isra.4, %function
parse_wf_gray16.isra.4:
	stp	x29, x30, [sp, -32]!
	adrp	x3, .LANCHOR0
	cmp	w2, 3
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	mov	x20, x0
	ldr	x7, [x3, #:lo12:.LANCHOR0]
	beq	.L31
	bls	.L49
	cmp	w2, 5
	beq	.L36
	bcc	.L37
	add	x0, x7, 532
	add	x8, x7, 2132
	cmp	w2, 6
	beq	.L39
	mov	x0, 0
	b	.L30
	.p2align 3
.L49:
	cmp	w2, 1
	beq	.L33
	add	x0, x7, 148
	add	x8, x7, 596
	bhi	.L50
.L39:
	bl	get_wf_level
	ldr	w0, [x8, w0, uxtw 2]
	add	x0, x7, x0
.L30:
	adrp	x1, .LANCHOR1
	ldrb	w19, [x0]
	ldr	w1, [x1, #:lo12:.LANCHOR1]
	lsl	w2, w19, 1
	mul	w1, w1, w1
	mul	w1, w2, w1
	lsr	w1, w1, 3
	bl	decode_wf_data
	str	x0, [x20]
	cmp	x0, 0
	mov	w0, -22
	csel	w0, w19, w0, ne
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 32
	ret
	.p2align 3
.L37:
	add	x0, x7, 340
	add	x8, x7, 1364
	b	.L39
	.p2align 3
.L50:
	add	x0, x7, 212
	add	x8, x7, 852
	b	.L39
	.p2align 3
.L36:
	add	x0, x7, 404
	add	x8, x7, 1620
	b	.L39
	.p2align 3
.L33:
	add	x0, x7, 468
	add	x8, x7, 1876
	b	.L39
	.p2align 3
.L31:
	add	x0, x7, 276
	add	x8, x7, 1108
	b	.L39
	.size	parse_wf_gray16.isra.4, .-parse_wf_gray16.isra.4
	.align	2
	.p2align 3,,7
	.type	parse_wf_data, %function
parse_wf_data:
	stp	x29, x30, [sp, -48]!
	mov	w3, w1
	cmp	w3, 3
	mov	w1, w2
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	mov	x20, x0
	stp	x21, x22, [sp, 32]
	beq	.L56
	bls	.L90
	cmp	w3, 5
	beq	.L58
	bcc	.L59
	cmp	w3, 6
	beq	.L60
	cmp	w3, 7
	bne	.L88
	adrp	x0, .LANCHOR0
	ldr	x7, [x0, #:lo12:.LANCHOR0]
	add	x0, x7, 532
	bl	get_wf_level
	add	x0, x7, x0, uxtw 2
	adrp	x1, .LANCHOR1
	ldr	w2, [x0, 2132]
	ldr	w1, [x1, #:lo12:.LANCHOR1]
.L89:
	ldrb	w19, [x7, x2]
	mul	w1, w1, w1
	add	x0, x7, x2
	lsl	w2, w19, 1
	mul	w1, w2, w1
	lsr	w1, w1, 3
	bl	decode_wf_data
	str	x0, [x20, 8]
	cbz	x0, .L88
	mov	w0, w19
.L91:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 48
	ret
.L90:
	cmp	w3, 1
	beq	.L55
	bhi	.L56
	adrp	x0, .LANCHOR0
	ldr	x7, [x0, #:lo12:.LANCHOR0]
	add	x0, x7, 148
	bl	get_wf_level
	add	x0, x7, x0, uxtw 2
	ldr	w1, [x0, 596]
	add	x0, x7, x1
	ldrb	w19, [x7, x1]
	add	w21, w19, 15
	lsr	w21, w21, 4
	lsl	w1, w21, 2
	bl	decode_wf_data
	mov	x22, x0
	cbz	x0, .L88
	lsl	w0, w21, 10
	mov	w1, 32960
	movk	w1, 0x60, lsl 16
	sxtw	x0, w0
	bl	__kmalloc
	cbz	x0, .L63
	cbz	w21, .L64
	mov	x8, 0
.L68:
	ldr	w7, [x22, x8, lsl 2]
	lsl	w1, w8, 8
	mov	w6, 0
	.p2align 2
.L67:
	asr	w5, w7, w6
	and	w5, w5, 3
	mov	w3, w5
	mov	w2, 0
	.p2align 2
.L65:
	lsl	w4, w5, w2
	add	w2, w2, 2
	orr	w3, w3, w4
	cmp	w2, 32
	bne	.L65
	add	w2, w1, 16
	.p2align 2
.L66:
	str	w3, [x0, w1, sxtw 2]
	add	w1, w1, 1
	cmp	w1, w2
	bne	.L66
	add	w6, w6, 2
	cmp	w6, 32
	bne	.L67
	add	x8, x8, 1
	cmp	w21, w8
	bgt	.L68
.L64:
	str	x0, [x20, 8]
	mov	x0, x22
	bl	kfree
	mov	w0, w19
	b	.L91
.L56:
	mov	w2, 2
	add	x0, x20, 8
	bl	parse_wf_gray16.isra.4
	cmp	w0, 0
	csinv	w0, w0, wzr, ge
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 48
	ret
.L60:
	mov	w2, 5
	add	x0, x0, 8
	bl	parse_wf_gray16.isra.4
	cmp	w0, 0
	csinv	w0, w0, wzr, ge
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 48
	ret
.L58:
	mov	w2, 4
	add	x0, x0, 8
	bl	parse_wf_gray16.isra.4
	cmp	w0, 0
	csinv	w0, w0, wzr, ge
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 48
	ret
.L59:
	mov	w2, 3
	add	x0, x0, 8
	bl	parse_wf_gray16.isra.4
	cmp	w0, 0
	csinv	w0, w0, wzr, ge
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 48
	ret
.L63:
	str	xzr, [x20, 8]
	mov	x0, x22
	bl	kfree
.L88:
	mov	w0, -1
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 48
	ret
.L55:
	adrp	x0, .LANCHOR0
	ldr	x7, [x0, #:lo12:.LANCHOR0]
	add	x0, x7, 468
	bl	get_wf_level
	add	x0, x7, x0, uxtw 2
	adrp	x1, .LANCHOR1
	ldr	w2, [x0, 1876]
	ldr	w1, [x1, #:lo12:.LANCHOR1]
	b	.L89
	.size	parse_wf_data, .-parse_wf_data
	.align	2
	.p2align 3,,7
	.global	rkf_wf_input
	.type	rkf_wf_input, %function
rkf_wf_input:
	stp	x29, x30, [sp, -64]!
	add	x29, sp, 0
	stp	x21, x22, [sp, 32]
	adrp	x22, .LANCHOR0
	stp	x19, x20, [sp, 16]
	mov	w21, -16
	ldr	x1, [x22, #:lo12:.LANCHOR0]
	stp	x23, x24, [sp, 48]
	cbnz	x1, .L92
	add	x20, x0, 20
	mov	x19, x0
	adrp	x1, .LC0
	mov	x2, 8
	add	x1, x1, :lo12:.LC0
	mov	x0, x20
	bl	strncmp
	cbz	w0, .L115
	adrp	x1, .LC1
	mov	x2, 8
	add	x1, x1, :lo12:.LC1
	mov	x0, x20
	bl	strncmp
	cbz	w0, .L116
	adrp	x0, .LC7
	mov	w21, -1
	add	x0, x0, :lo12:.LC7
	bl	printk
.L92:
	mov	w0, w21
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x29, x30, [sp], 64
	ret
.L115:
	adrp	x1, .LANCHOR1
	mov	w0, 16
	mov	w2, w0
	str	w0, [x1, #:lo12:.LANCHOR1]
.L95:
	mov	x1, x20
	adrp	x0, .LC2
	add	x0, x0, :lo12:.LC2
	bl	printk
	adrp	x1, .LC3
	mov	x2, 12
	add	x1, x1, :lo12:.LC3
	add	x0, x19, 4
	bl	strncmp
	mov	w21, w0
	cbnz	w0, .L117
	ldr	w20, [x19]
	cmp	w20, 1048576
	bgt	.L105
	add	x7, x22, :lo12:.LANCHOR0
	ldr	w23, [x19, w20, sxtw]
	add	x24, x7, 8
	mov	x2, 1024
	mov	w1, 0
	mov	x0, x24
	bl	memset
	mov	w5, 3511
	mov	x7, x24
	mov	x6, 0
	movk	w5, 0x4c1, lsl 16
	.p2align 2
.L101:
	lsl	w1, w6, 22
	mov	w2, 8
	mov	w0, 0
	.p2align 2
.L100:
	eor	w4, w1, w0
	eor	w3, w5, w0, lsl 1
	cmp	w4, 0
	lsl	w0, w0, 1
	csel	w0, w0, w3, ge
	lsl	w1, w1, 1
	subs	w2, w2, #1
	bne	.L100
	str	w0, [x6, x7]
	add	x6, x6, 4
	cmp	x6, 1024
	bne	.L101
	cbz	w20, .L102
	add	x3, x22, :lo12:.LANCHOR0
	mov	x1, 0
	add	x3, x3, 8
	.p2align 2
.L103:
	ldrb	w0, [x19, x1]
	add	x1, x1, 1
	cmp	w20, w1
	eor	w0, w0, w2, lsr 24
	ldr	w0, [x3, x0, lsl 2]
	eor	w2, w0, w2, lsl 8
	bhi	.L103
.L102:
	cmp	w23, w2
	bne	.L118
	str	x19, [x22, #:lo12:.LANCHOR0]
	mov	w0, w21
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x29, x30, [sp], 64
	ret
.L118:
	adrp	x0, .LC6
	mov	w1, w23
	add	x0, x0, :lo12:.LC6
	bl	printk
.L105:
	adrp	x0, .LC8
	mov	w21, -1
	add	x0, x0, :lo12:.LC8
	bl	printk
	b	.L92
.L117:
	adrp	x0, .LC4
	add	x0, x0, :lo12:.LC4
	bl	printk
	mov	w21, -1
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
	bl	printk
	b	.L92
.L116:
	adrp	x1, .LANCHOR1
	mov	w0, 32
	mov	w2, w0
	str	w0, [x1, #:lo12:.LANCHOR1]
	b	.L95
	.size	rkf_wf_input, .-rkf_wf_input
	.align	2
	.p2align 3,,7
	.global	rkf_wf_get_version
	.type	rkf_wf_get_version, %function
rkf_wf_get_version:
	adrp	x0, .LANCHOR0
	ldr	x1, [x0, #:lo12:.LANCHOR0]
	add	x0, x1, 84
	cmp	x1, 0
	csel	x0, x0, xzr, ne
	ret
	.size	rkf_wf_get_version, .-rkf_wf_get_version
	.align	2
	.p2align 3,,7
	.global	rkf_wf_get_lut
	.type	rkf_wf_get_lut, %function
rkf_wf_get_lut:
	stp	x29, x30, [sp, -64]!
	adrp	x4, .LANCHOR0
	add	x29, sp, 0
	stp	x21, x22, [sp, 32]
	mov	x21, x0
	ldr	x0, [x4, #:lo12:.LANCHOR0]
	stp	x19, x20, [sp, 16]
	str	x23, [sp, 48]
	cbz	x0, .L169
	cbz	x21, .L170
	mov	w22, w1
	adrp	x19, .LANCHOR1
	add	x1, x19, :lo12:.LANCHOR1
	mov	w20, w2
	cmp	w22, 8
	str	w3, [x1, 4]
	beq	.L175
	cmp	w22, 12
	beq	.L172
	cmp	w22, 11
	beq	.L173
	cmp	w22, 13
	beq	.L174
	cmp	w22, 14
	beq	.L175
	mov	w0, 26215
	movk	w0, 0x6666, lsl 16
	smull	x23, w2, w0
	asr	x23, x23, 33
	sub	w23, w23, w2, asr 31
	ldr	w2, [x1, 8]
	smull	x0, w2, w0
	asr	x0, x0, 33
	sub	w0, w0, w2, asr 31
	cmp	w23, w0
	beq	.L210
	cmp	w22, 10
	bne	.L161
.L162:
	ldr	x0, [x21, 8]
	cbz	x0, .L159
	bl	kfree
	str	xzr, [x21, 8]
.L159:
	bl	epd_overlay_lut
	mov	w1, w0
	mov	w2, w20
	mov	x0, x21
	bl	parse_wf_data
	mov	w10, w0
	tbnz	w0, #31, .L160
	ldr	x1, [x21, 24]
	mov	w2, w0
	add	x0, x21, 8
	add	x19, x19, :lo12:.LANCHOR1
	bl	rkf_lut_init_wf_table.isra.2
	str	w20, [x19, 8]
	ldrb	w1, [x21]
	mov	w0, 0
	orr	w10, w1, w10, lsl 8
	str	w10, [x21]
.L122:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldr	x23, [sp, 48]
	ldp	x29, x30, [sp], 64
	ret
.L210:
	ldr	w0, [x1, 12]
	cmp	w22, w0
	beq	.L158
	cmp	w22, 10
	beq	.L158
.L161:
	ldr	x0, [x21, 8]
	cbz	x0, .L127
	bl	kfree
	str	xzr, [x21, 8]
.L127:
	mov	w2, w20
	mov	w1, w22
	mov	x0, x21
	bl	parse_wf_data
	mov	w10, w0
	tbnz	w0, #31, .L160
	cbnz	w22, .L129
	ldr	x1, [x21, 16]
	mov	w2, w0
	add	x0, x21, 8
	bl	rkf_lut_init_wf_table.isra.2
.L149:
	add	x3, x19, :lo12:.LANCHOR1
	mov	w0, 26215
	movk	w0, 0x6666, lsl 16
	ldr	w1, [x21]
	ldr	w2, [x3, 8]
	and	w1, w1, 65280
	orr	w10, w1, w10
	str	w22, [x3, 12]
	str	w10, [x21]
	smull	x0, w2, w0
	asr	x0, x0, 33
	sub	w0, w0, w2, asr 31
	cmp	w0, w23
	bne	.L162
.L158:
	mov	w0, 0
.L212:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldr	x23, [sp, 48]
	ldp	x29, x30, [sp], 64
	ret
.L129:
	ldr	w12, [x19, #:lo12:.LANCHOR1]
	ldr	x4, [x21, 16]
	cbz	w0, .L132
	lsl	w13, w12, 1
	mov	w15, 0
	sxtw	x13, w13
	mov	w14, 0
	lsr	x13, x13, 5
	lsl	x16, x13, 2
.L134:
	sxtw	x7, w15
	lsl	w9, w14, 10
	mov	x5, 0
	mov	w11, 0
	ldr	x8, [x21, 8]
	mul	x7, x7, x16
	cbz	w12, .L137
	.p2align 2
.L185:
	add	w6, w9, w12
	mov	w3, w9
	mov	w2, 0
	.p2align 2
.L135:
	lsr	w1, w2, 5
	and	w0, w2, 30
	add	x1, x1, x5
	add	w2, w2, 2
	add	x1, x8, x1, lsl 2
	ldr	w1, [x1, x7]
	lsr	w0, w1, w0
	and	w0, w0, 3
	strb	w0, [x4, w3, uxtw]
	add	w3, w3, 1
	cmp	w6, w3
	bne	.L135
	add	w11, w11, 1
	add	w9, w9, 32
	add	x5, x5, x13
	cmp	w11, w12
	bne	.L185
.L137:
	add	w14, w14, 1
	add	w15, w15, w12
	cmp	w10, w14
	bne	.L134
.L132:
	cmp	w12, 32
	beq	.L211
.L138:
	cmp	w22, 7
	bne	.L146
	ldr	x4, [x21, 16]
	cbz	w10, .L147
.L163:
	mov	w1, 0
.L148:
	lsl	w3, w1, 10
	add	w1, w1, 1
	add	x0, x4, x3, sxtw
	cmp	w10, w1
	ldrb	w2, [x0, 960]
	strb	w2, [x4, w3, sxtw]
	strb	w2, [x0, 96]
	ldrb	w2, [x0, 30]
	strb	w2, [x0, 990]
	strb	w2, [x0, 126]
	bgt	.L148
.L147:
	sub	w0, w10, #2
	mov	w1, 2
	lsl	w0, w0, 10
	add	x4, x4, x0, sxtw
	strb	w1, [x4, 830]
	b	.L149
.L175:
	mov	w22, 3
.L124:
	add	x2, x19, :lo12:.LANCHOR1
	mov	w0, 26215
	movk	w0, 0x6666, lsl 16
	ldr	w1, [x2, 8]
	smull	x23, w20, w0
	asr	x23, x23, 33
	smull	x0, w1, w0
	sub	w23, w23, w20, asr 31
	asr	x0, x0, 33
	sub	w0, w0, w1, asr 31
	cmp	w0, w23
	bne	.L161
	ldr	w0, [x2, 12]
	cmp	w22, w0
	bne	.L161
	mov	w0, 0
	b	.L212
.L172:
	mov	w22, 6
	b	.L124
.L146:
	cmp	w22, 1
	beq	.L213
.L150:
	sub	w0, w22, #5
	cmp	w0, 1
	bhi	.L149
	mov	w1, 0
	ldr	x3, [x21, 16]
	cbz	w10, .L149
.L183:
	lsl	w0, w1, 10
	add	w1, w1, 1
	add	x0, x3, x0, sxtw
	cmp	w10, w1
	ldrb	w2, [x0, 30]
	strb	w2, [x0, 31]
	strb	w2, [x0, 29]
	bne	.L183
	b	.L149
.L173:
	mov	w22, 5
	b	.L124
.L211:
	add	x0, x19, :lo12:.LANCHOR1
	ldr	w0, [x0, 4]
	cmp	w0, 16
	bne	.L138
	mov	w7, 0
	mov	w8, 0
	cbz	w10, .L214
.L184:
	mov	w5, w7
	mov	w6, 0
	.p2align 2
.L142:
	lsr	w3, w6, 1
	mov	w0, 0
	add	w3, w7, w3, lsl 5
	.p2align 2
.L141:
	add	w2, w0, w5
	add	w1, w3, w0, lsr 1
	add	w0, w0, 2
	cmp	w0, 32
	ldrb	w2, [x4, w2, uxtw]
	strb	w2, [x4, w1, uxtw]
	bne	.L141
	add	w6, w6, 2
	add	w5, w5, 64
	cmp	w6, 32
	bne	.L142
	add	w8, w8, 1
	add	w7, w7, 1024
	cmp	w10, w8
	bne	.L184
	cmp	w22, 7
	bne	.L146
	ldr	x4, [x21, 16]
	b	.L163
.L174:
	mov	w22, 4
	b	.L124
.L213:
	mov	w2, 0
	ldr	x1, [x21, 16]
	cbz	w10, .L154
.L182:
	lsl	w3, w2, 10
	add	w2, w2, 1
	add	x0, x1, x3, sxtw
	cmp	w10, w2
	ldrb	w4, [x0, 960]
	strb	w4, [x1, w3, sxtw]
	ldrb	w3, [x0, 30]
	strb	w3, [x0, 990]
	bne	.L182
	mov	w3, 0
.L153:
	lsl	w0, w3, 10
	add	w3, w3, 2
	add	x0, x1, x0, sxtw
	cmp	w2, w3
	ldrb	w4, [x0, 960]
	strb	w4, [x0, 96]
	ldrb	w4, [x0, 30]
	strb	w4, [x0, 126]
	bgt	.L153
.L154:
	sub	w0, w10, #2
	mov	w2, 2
	lsl	w0, w0, 10
	add	x0, x1, x0, sxtw
	strb	w2, [x0, 830]
	b	.L149
.L214:
	cmp	w22, 7
	bne	.L215
	ldr	x4, [x21, 16]
	b	.L147
.L170:
	mov	w0, -22
	b	.L122
.L160:
	adrp	x0, .LC9
	add	x0, x0, :lo12:.LC9
	bl	printk
	mov	w0, -5
	b	.L122
.L169:
	mov	w0, -19
	b	.L122
.L215:
	cmp	w22, 1
	bne	.L150
	ldr	x1, [x21, 16]
	b	.L154
	.size	rkf_wf_get_lut, .-rkf_wf_get_lut
	.data
	.align	2
	.set	.LANCHOR1,. + 0
	.type	maxpic, %object
	.size	maxpic, 4
maxpic:
	.word	16
	.type	need_pic, %object
	.size	need_pic, 4
need_pic:
	.word	16
	.type	sftemp.17077, %object
	.size	sftemp.17077, 4
sftemp.17077:
	.word	-1
	.type	stype.17076, %object
	.size	stype.17076, 4
stype.17076:
	.word	15
	.bss
	.align	3
	.set	.LANCHOR0,. + 0
	.type	global_waveform, %object
	.size	global_waveform, 8
global_waveform:
	.zero	8
	.type	crc32_table, %object
	.size	crc32_table, 1024
crc32_table:
	.zero	1024
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align	3
.LC0:
	.string	"rkf:v1.0"
	.zero	7
.LC1:
	.string	"rkf:v2.0"
	.zero	7
.LC2:
	.string	"rkf: input waveform version: %s, gray level: %d\n"
	.zero	7
.LC3:
	.string	"rkf waveform"
	.zero	3
.LC4:
	.string	"rkf: check format failed\n"
	.zero	6
.LC5:
	.string	"rkf: failed to check RKF file format\n"
	.zero	2
.LC6:
	.string	"[EINK]: waveform crc err readcrc = %x crccheck = %x\n"
	.zero	3
.LC7:
	.string	"rkf: failed to check RKF file version\n"
	.zero	1
.LC8:
	.string	"rkf: failed to check crc RKF waveform\n"
	.zero	1
.LC9:
	.string	"rkf waveform get frame number failed\n"
	.ident	"GCC: (Linaro GCC 6.3-2017.05) 6.3.1 20170404"
	.section	.note.GNU-stack,"",@progbits

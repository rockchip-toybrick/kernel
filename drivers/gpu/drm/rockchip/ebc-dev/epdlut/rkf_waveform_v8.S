// SPDX-License-Identifier: GPL-2.0
/*
 * Copyright (c) 2020 Rockchip Electronics Co. Ltd.
 *
 * Author: Zorro Liu <zorro.liu@rock-chips.com>
 */

	.arch armv8-a
	.file	"rkf_waveform.c"
	.text
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
	cbz	x0, .L2
	mov	x2, x20
	add	x1, x21, 4
	bl	memcpy
.L2:
	mov	x0, x19
	ldr	x21, [sp, 32]
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 48
	ret
	.size	decode_wf_data, .-decode_wf_data
	.align	2
	.p2align 3,,7
	.type	rkf_lut_init_wf_table.isra.1, %function
rkf_lut_init_wf_table.isra.1:
	cmp	w2, 0
	ble	.L17
	sub	w9, w2, #1
	mov	w7, 512
	add	x9, x9, 1
	mov	x8, 0
	lsl	x9, x9, 6
.L13:
	ldr	x5, [x0]
	lsl	w6, w8, 4
	add	x5, x5, x8
	.p2align 2
.L10:
	mov	w4, w6
	mov	w3, 0
	.p2align 2
.L11:
	ldr	w2, [x5]
	lsr	w2, w2, w3
	and	w2, w2, 3
	strb	w2, [x1, w4, uxtw]
	add	w3, w3, 2
	add	w4, w4, 1
	cmp	w3, 32
	bne	.L11
	add	w6, w6, 32
	add	x5, x5, 4
	cmp	w7, w6
	bne	.L10
	add	x8, x8, 64
	add	w7, w7, 1024
	cmp	x9, x8
	bne	.L13
.L17:
	mov	w0, 0
	ret
	.size	rkf_lut_init_wf_table.isra.1, .-rkf_lut_init_wf_table.isra.1
	.align	2
	.p2align 3,,7
	.type	rkf_lut_init_wf_table_32.isra.2, %function
rkf_lut_init_wf_table_32.isra.2:
	cmp	w2, 0
	ble	.L27
	sub	w9, w2, #1
	mov	w7, 1024
	add	x9, x9, 1
	mov	x8, 0
	lsl	x9, x9, 6
.L23:
	ldr	x6, [x0]
	lsl	w5, w8, 4
	add	x6, x6, x8
	.p2align 2
.L20:
	mov	w3, 0
	.p2align 2
.L21:
	add	w4, w5, w3
	ldr	w2, [x6]
	lsr	w2, w2, w3
	and	w2, w2, 3
	strb	w2, [x1, w4, uxtw]
	add	w3, w3, 2
	cmp	w3, 32
	bne	.L21
	add	w5, w5, 64
	add	x6, x6, 4
	cmp	w7, w5
	bne	.L20
	add	x8, x8, 64
	add	w7, w7, 1024
	cmp	x9, x8
	bne	.L23
.L27:
	mov	w0, 0
	ret
	.size	rkf_lut_init_wf_table_32.isra.2, .-rkf_lut_init_wf_table_32.isra.2
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
	ldr	x0, [x3, #:lo12:.LANCHOR0]
	beq	.L30
	bls	.L52
	cmp	w2, 5
	beq	.L35
	bcc	.L36
	add	x4, x0, 532
	add	x5, x0, 2132
	cmp	w2, 6
	beq	.L38
	mov	x0, 0
	b	.L29
	.p2align 3
.L52:
	cmp	w2, 1
	beq	.L32
	add	x4, x0, 148
	add	x5, x0, 596
	bhi	.L53
.L38:
	cmp	w1, 0
	mov	w3, 50
	csel	w1, w1, wzr, ge
	mov	x2, 0
	cmp	w1, w3
	csel	w1, w1, w3, le
	b	.L41
	.p2align 3
.L39:
	add	x2, x2, 1
	cmp	x2, 50
	beq	.L54
.L41:
	ldrb	w3, [x4, x2]
	cmp	w1, w3
	bge	.L39
	lsl	x2, x2, 2
.L40:
	ldr	w1, [x5, x2]
	add	x0, x0, x1
.L29:
	ldrb	w19, [x0]
	lsl	w1, w19, 6
	bl	decode_wf_data
	str	x0, [x20]
	cmp	x0, 0
	mov	w0, -22
	csel	w0, w19, w0, ne
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 32
	ret
	.p2align 3
.L54:
	mov	x2, 0
	b	.L40
.L36:
	add	x4, x0, 340
	add	x5, x0, 1364
	b	.L38
.L53:
	add	x4, x0, 212
	add	x5, x0, 852
	b	.L38
.L35:
	add	x4, x0, 404
	add	x5, x0, 1620
	b	.L38
.L32:
	add	x4, x0, 468
	add	x5, x0, 1876
	b	.L38
.L30:
	add	x4, x0, 276
	add	x5, x0, 1108
	b	.L38
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
	beq	.L60
	bls	.L107
	cmp	w3, 5
	beq	.L62
	bcc	.L63
	cmp	w3, 6
	beq	.L64
	cmp	w3, 7
	bne	.L104
	adrp	x2, .LANCHOR0
	cmp	w1, 0
	csel	w1, w1, wzr, ge
	mov	w0, 50
	ldr	x4, [x2, #:lo12:.LANCHOR0]
	cmp	w1, w0
	csel	w1, w1, w0, le
	mov	x0, 0
	add	x3, x4, 532
	add	x5, x4, 2132
	b	.L82
	.p2align 3
.L80:
	add	x0, x0, 1
	cmp	x0, 50
	beq	.L105
.L82:
	ldrb	w2, [x3, x0]
	cmp	w1, w2
	bge	.L80
.L106:
	lsl	x0, x0, 2
.L81:
	ldr	w1, [x5, x0]
	add	x0, x4, x1
	ldrb	w19, [x4, x1]
	lsl	w1, w19, 6
	bl	decode_wf_data
	str	x0, [x20, 8]
	cbz	x0, .L104
	mov	w0, w19
.L109:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 48
	ret
.L107:
	cmp	w3, 1
	beq	.L59
	bhi	.L60
	adrp	x2, .LANCHOR0
	cmp	w1, 0
	csel	w1, w1, wzr, ge
	mov	w0, 50
	ldr	x4, [x2, #:lo12:.LANCHOR0]
	cmp	w1, w0
	csel	w1, w1, w0, le
	mov	x0, 0
	add	x3, x4, 148
	add	x5, x4, 596
	b	.L68
	.p2align 3
.L66:
	add	x0, x0, 1
	cmp	x0, 50
	beq	.L108
.L68:
	ldrb	w2, [x3, x0]
	cmp	w1, w2
	bge	.L66
	lsl	x0, x0, 2
.L67:
	ldr	w1, [x5, x0]
	add	x0, x4, x1
	ldrb	w19, [x4, x1]
	add	w21, w19, 15
	lsr	w21, w21, 4
	lsl	w1, w21, 2
	bl	decode_wf_data
	mov	x22, x0
	cbz	x0, .L104
	lsl	w0, w21, 10
	mov	w1, 32960
	movk	w1, 0x60, lsl 16
	sxtw	x0, w0
	bl	__kmalloc
	cbz	x0, .L70
	cbz	w21, .L71
	mov	x8, 0
.L75:
	ldr	w7, [x22, x8, lsl 2]
	lsl	w1, w8, 8
	mov	w6, 0
	.p2align 2
.L74:
	asr	w5, w7, w6
	and	w5, w5, 3
	mov	w3, w5
	mov	w2, 0
	.p2align 2
.L72:
	lsl	w4, w5, w2
	add	w2, w2, 2
	orr	w3, w3, w4
	cmp	w2, 32
	bne	.L72
	add	w2, w1, 16
	.p2align 2
.L73:
	str	w3, [x0, w1, sxtw 2]
	add	w1, w1, 1
	cmp	w1, w2
	bne	.L73
	add	w6, w6, 2
	cmp	w6, 32
	bne	.L74
	add	x8, x8, 1
	cmp	w21, w8
	bgt	.L75
.L71:
	str	x0, [x20, 8]
	mov	x0, x22
	bl	kfree
	mov	w0, w19
	b	.L109
.L60:
	mov	w2, 2
	add	x0, x20, 8
	bl	parse_wf_gray16.isra.4
	cmp	w0, 0
	csinv	w0, w0, wzr, ge
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 48
	ret
.L64:
	mov	w2, 5
	add	x0, x0, 8
	bl	parse_wf_gray16.isra.4
	cmp	w0, 0
	csinv	w0, w0, wzr, ge
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 48
	ret
.L62:
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
	adrp	x2, .LANCHOR0
	cmp	w1, 0
	csel	w1, w1, wzr, ge
	mov	w0, 50
	ldr	x4, [x2, #:lo12:.LANCHOR0]
	cmp	w1, w0
	csel	w1, w1, w0, le
	mov	x0, 0
	add	x3, x4, 468
	add	x5, x4, 1876
	b	.L78
	.p2align 3
.L110:
	add	x0, x0, 1
	cmp	x0, 50
	beq	.L105
.L78:
	ldrb	w2, [x3, x0]
	cmp	w1, w2
	bge	.L110
	b	.L106
.L70:
	str	xzr, [x20, 8]
	mov	x0, x22
	bl	kfree
.L104:
	mov	w0, -1
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 48
	ret
.L63:
	mov	w2, 3
	add	x0, x0, 8
	bl	parse_wf_gray16.isra.4
	cmp	w0, 0
	csinv	w0, w0, wzr, ge
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 48
	ret
.L105:
	mov	x0, 0
	b	.L81
.L108:
	mov	x0, 0
	b	.L67
	.size	parse_wf_data, .-parse_wf_data
	.align	2
	.p2align 3,,7
	.global	rkf_wf_input
	.type	rkf_wf_input, %function
rkf_wf_input:
	stp	x29, x30, [sp, -64]!
	add	x29, sp, 0
	stp	x23, x24, [sp, 48]
	adrp	x23, .LANCHOR0
	stp	x19, x20, [sp, 16]
	mov	w19, -16
	ldr	x1, [x23, #:lo12:.LANCHOR0]
	stp	x21, x22, [sp, 32]
	cbnz	x1, .L111
	mov	x21, x0
	adrp	x1, .LC0
	mov	x2, 12
	add	x1, x1, :lo12:.LC0
	add	x0, x0, 4
	bl	strncmp
	mov	w19, w0
	cbnz	w0, .L131
	ldr	w22, [x21]
	cmp	w22, 262144
	bgt	.L121
	add	x20, x23, :lo12:.LANCHOR0
	ldr	w24, [x21, w22, sxtw]
	add	x20, x20, 8
	mov	x2, 1024
	mov	w1, 0
	mov	x0, x20
	bl	memset
	mov	w5, 3511
	mov	x7, x20
	mov	x6, 0
	movk	w5, 0x4c1, lsl 16
	.p2align 2
.L117:
	lsl	w1, w6, 22
	mov	w2, 8
	mov	w0, 0
	.p2align 2
.L116:
	eor	w4, w1, w0
	eor	w3, w5, w0, lsl 1
	cmp	w4, 0
	lsl	w0, w0, 1
	csel	w0, w0, w3, ge
	lsl	w1, w1, 1
	subs	w2, w2, #1
	bne	.L116
	str	w0, [x6, x7]
	add	x6, x6, 4
	cmp	x6, 1024
	bne	.L117
	cbz	w22, .L118
	add	x3, x23, :lo12:.LANCHOR0
	mov	x1, 0
	add	x3, x3, 8
	.p2align 2
.L119:
	ldrb	w0, [x21, x1]
	add	x1, x1, 1
	cmp	w22, w1
	eor	w0, w0, w2, lsr 24
	ldr	w0, [x3, x0, lsl 2]
	eor	w2, w0, w2, lsl 8
	bhi	.L119
.L118:
	cmp	w24, w2
	bne	.L132
	adrp	x0, .LC5
	add	x1, x21, 20
	add	x0, x0, :lo12:.LC5
	bl	printk
	str	x21, [x23, #:lo12:.LANCHOR0]
.L111:
	mov	w0, w19
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x29, x30, [sp], 64
	ret
.L132:
	adrp	x0, .LC3
	mov	w1, w24
	add	x0, x0, :lo12:.LC3
	bl	printk
.L121:
	mov	w19, -1
	adrp	x0, .LC4
	add	x0, x0, :lo12:.LC4
	bl	printk
	mov	w0, w19
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x29, x30, [sp], 64
	ret
.L131:
	adrp	x0, .LC1
	add	x0, x0, :lo12:.LC1
	bl	printk
	mov	w19, -1
	adrp	x0, .LC2
	add	x0, x0, :lo12:.LC2
	bl	printk
	b	.L111
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
	stp	x29, x30, [sp, -80]!
	adrp	x5, .LANCHOR0
	add	x29, sp, 0
	stp	x19, x20, [sp, 16]
	mov	x19, x0
	ldr	x0, [x5, #:lo12:.LANCHOR0]
	stp	x21, x22, [sp, 32]
	stp	x23, x24, [sp, 48]
	str	x25, [sp, 64]
	cbz	x0, .L167
	cbz	x19, .L168
	mov	w20, w1
	mov	w22, w2
	mov	w24, w3
	mov	w25, w4
	cmp	w1, 8
	beq	.L173
	cmp	w1, 12
	beq	.L170
	cmp	w1, 11
	beq	.L171
	cmp	w1, 13
	beq	.L172
	cmp	w1, 14
	beq	.L173
	adrp	x23, .LANCHOR1
	mov	w0, 26215
	movk	w0, 0x6666, lsl 16
	add	x2, x23, :lo12:.LANCHOR1
	ldr	w1, [x23, #:lo12:.LANCHOR1]
	smull	x21, w22, w0
	smull	x0, w1, w0
	asr	x21, x21, 33
	sub	w21, w21, w22, asr 31
	asr	x0, x0, 33
	sub	w0, w0, w1, asr 31
	cmp	w21, w0
	beq	.L195
	cmp	w20, 10
	beq	.L166
	b	.L165
	.p2align 3
.L173:
	mov	w20, 3
.L138:
	adrp	x23, .LANCHOR1
	mov	w0, 26215
	movk	w0, 0x6666, lsl 16
	add	x2, x23, :lo12:.LANCHOR1
	ldr	w1, [x23, #:lo12:.LANCHOR1]
	smull	x21, w22, w0
	smull	x0, w1, w0
	asr	x21, x21, 33
	sub	w21, w21, w22, asr 31
	asr	x0, x0, 33
	sub	w0, w0, w1, asr 31
	cmp	w0, w21
	beq	.L196
.L165:
	ldr	x0, [x19, 8]
	cbz	x0, .L141
	bl	kfree
	str	xzr, [x19, 8]
.L141:
	mov	w2, w22
	mov	w1, w20
	mov	x0, x19
	bl	parse_wf_data
	mov	w10, w0
	tbnz	w0, #31, .L162
	mov	w2, w0
	cmp	w24, 32
	add	x0, x19, 8
	ldr	x1, [x19, 16]
	beq	.L197
	bl	rkf_lut_init_wf_table.isra.1
.L144:
	cmp	w20, 7
	beq	.L198
	cmp	w20, 1
	beq	.L199
	sub	w0, w20, #5
	cmp	w0, 1
	bls	.L200
	sub	w0, w20, #11
	cmp	w0, 1
	bls	.L201
.L147:
	ldr	w2, [x23, #:lo12:.LANCHOR1]
	mov	w0, 26215
	ldr	w1, [x19]
	movk	w0, 0x6666, lsl 16
	and	w1, w1, 65280
	orr	w10, w1, w10
	smull	x0, w2, w0
	add	x1, x23, :lo12:.LANCHOR1
	str	w10, [x19]
	asr	x0, x0, 33
	str	w20, [x1, 4]
	sub	w0, w0, w2, asr 31
	cmp	w0, w21
	beq	.L160
.L166:
	ldr	x0, [x19, 8]
	cbz	x0, .L161
	bl	kfree
	str	xzr, [x19, 8]
.L161:
	bl	epd_overlay_lut
	mov	w1, w0
	mov	w2, w22
	mov	x0, x19
	bl	parse_wf_data
	mov	w10, w0
	tbnz	w0, #31, .L162
	mov	w2, w0
	cmp	w24, 32
	add	x0, x19, 8
	ldr	x1, [x19, 24]
	beq	.L202
	bl	rkf_lut_init_wf_table.isra.1
.L164:
	ldrb	w1, [x19]
	mov	w0, 0
	str	w22, [x23, #:lo12:.LANCHOR1]
	orr	w10, w1, w10, lsl 8
	str	w10, [x19]
.L136:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldr	x25, [sp, 64]
	ldp	x29, x30, [sp], 80
	ret
	.p2align 3
.L195:
	ldr	w0, [x2, 4]
	cmp	w20, w0
	beq	.L160
	cmp	w20, 10
	bne	.L165
.L160:
	mov	w0, 0
.L203:
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldr	x25, [sp, 64]
	ldp	x29, x30, [sp], 80
	ret
	.p2align 3
.L196:
	ldr	w0, [x2, 4]
	cmp	w20, w0
	bne	.L165
	mov	w0, 0
	b	.L203
	.p2align 3
.L202:
	bl	rkf_lut_init_wf_table_32.isra.2
	b	.L164
	.p2align 3
.L171:
	mov	w20, 5
	b	.L138
	.p2align 3
.L201:
	ldr	x3, [x19, 16]
	cbz	w10, .L147
	mov	w1, 0
	.p2align 2
.L159:
	lsl	w0, w1, 10
	add	w1, w1, 1
	add	x0, x3, x0, sxtw
	cmp	w10, w1
	ldrb	w2, [x0, 30]
	strb	wzr, [x0, 989]
	strb	w2, [x0, 31]
	strb	w2, [x0, 29]
	cbz	w25, .L158
	strb	wzr, [x0, 1021]
	strb	wzr, [x0, 1022]
.L158:
	bne	.L159
	b	.L147
	.p2align 3
.L170:
	mov	w20, 6
	b	.L138
	.p2align 3
.L198:
	mov	w1, 0
	ldr	x4, [x19, 16]
	cbz	w10, .L149
	.p2align 2
.L182:
	lsl	w2, w1, 10
	add	w1, w1, 1
	add	x0, x4, x2, sxtw
	cmp	w10, w1
	ldrb	w3, [x0, 960]
	strb	w3, [x0, 928]
	strb	w3, [x4, w2, sxtw]
	ldrb	w2, [x0, 30]
	strb	w2, [x0, 990]
	bne	.L182
.L149:
	mov	w0, 2
	mov	w1, 1
	strb	w0, [x4, 1982]
	strb	w1, [x4, 958]
	strb	w0, [x4, 3006]
	b	.L147
	.p2align 3
.L197:
	bl	rkf_lut_init_wf_table_32.isra.2
	b	.L144
	.p2align 3
.L199:
	mov	w1, 0
	ldr	x2, [x19, 16]
	cbz	w10, .L153
	.p2align 2
.L183:
	lsl	w0, w1, 10
	add	w1, w1, 1
	add	x0, x2, x0, sxtw
	cmp	w10, w1
	ldrb	w3, [x0, 960]
	strb	w3, [x0, 928]
	bne	.L183
.L153:
	add	x2, x2, 4096
	mov	w0, 2
	mov	w1, 1
	strb	w0, [x2, 990]
	strb	w1, [x2]
	strb	w1, [x2, 1024]
	strb	w0, [x2, 2014]
	strb	w1, [x2, 2048]
	strb	w0, [x2, 3038]
	strb	w1, [x2, 958]
	strb	w0, [x2, 1982]
	strb	w0, [x2, 3006]
	b	.L147
	.p2align 3
.L172:
	mov	w20, 4
	b	.L138
	.p2align 3
.L200:
	mov	w1, 0
	ldr	x3, [x19, 16]
	cbz	w10, .L147
	.p2align 2
.L184:
	lsl	w0, w1, 10
	add	w1, w1, 1
	add	x0, x3, x0, sxtw
	cmp	w10, w1
	ldrb	w2, [x0, 30]
	strb	w2, [x0, 31]
	strb	w2, [x0, 29]
	bne	.L184
	b	.L147
.L167:
	mov	w0, -19
	b	.L136
.L168:
	mov	w0, -22
	b	.L136
.L162:
	adrp	x0, .LC6
	add	x0, x0, :lo12:.LC6
	bl	printk
	mov	w0, -5
	b	.L136
	.size	rkf_wf_get_lut, .-rkf_wf_get_lut
	.data
	.align	2
	.set	.LANCHOR1,. + 0
	.type	sftemp.17058, %object
	.size	sftemp.17058, 4
sftemp.17058:
	.word	-1
	.type	stype.17057, %object
	.size	stype.17057, 4
stype.17057:
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
	.string	"rkf waveform"
	.zero	3
.LC1:
	.string	"rkf: check format failed\n"
	.zero	6
.LC2:
	.string	"rkf: failed to check RKF file format\n"
	.zero	2
.LC3:
	.string	"[EINK]: waveform crc err readcrc = %x crccheck = %x\n"
	.zero	3
.LC4:
	.string	"rkf: failed to check crc RKF waveform\n"
	.zero	1
.LC5:
	.string	"rkf file version: %s\n"
	.zero	2
.LC6:
	.string	"rkf waveform get frame number failed\n"
	.ident	"GCC: (Linaro GCC 6.3-2017.05) 6.3.1 20170404"
	.section	.note.GNU-stack,"",@progbits

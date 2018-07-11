;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.7.1 #10455 (MINGW64)
;--------------------------------------------------------
	.module gb
	.optsdcc -mgbz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _vblank_happened
	.globl _scroll_y
	.globl _scroll_x
	.globl _old_joy0
	.globl _joy0
	.globl _obj_slot
	.globl _vram_transfer_buffer
	.globl _vram_transfer_size
	.globl _obj
	.globl _vblank_isr
	.globl _lcd_stat_isr
	.globl _timer_isr
	.globl _serial_isr
	.globl _joypad_isr
	.globl _init_gameboy
	.globl _fastcpy
	.globl _fill
	.globl _set_bg_chr
	.globl _set_bg_map
	.globl _set_bg_map_tile
	.globl _update_bg_map_tile
	.globl _set_obj_chr
	.globl _set_obj
	.globl _copy_to_oam_obj
	.globl _read_joypad
	.globl _key_push
	.globl _key_hold
	.globl _key_release
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_obj::
	.ds 160
_vram_transfer_size::
	.ds 1
_vram_transfer_buffer::
	.ds 80
_obj_slot::
	.ds 1
_joy0::
	.ds 1
_old_joy0::
	.ds 1
_scroll_x::
	.ds 1
_scroll_y::
	.ds 1
_vblank_happened::
	.ds 1
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;src/gb.c:20: void vblank_isr() __interrupt {
;	---------------------------------
; Function vblank_isr
; ---------------------------------
_vblank_isr::
	ei
	push	af
	push bc
	push de
	push hl
;src/gb.c:50: __endasm;
	di
	call	0xFF80 ;24 + (160 * 4) cycles = 664 cycles
	ei
	ld	a, (_vram_transfer_size) ;48 + (100 * 20) cycles
	or	a ;= 1648 max (16 Bytes)
	jr	z, 0$
	ld	e, a
	ld	hl, #_vram_transfer_buffer ;48
	        1$:
	ld a, (hl+)
	ld	c, a
	ld	a, (hl+)
	ld	b, a
	ld	a, (hl+)
	ld	a, (hl+)
	ld	(bc), a
	dec	e
	jr	nz, 1$
	xor	a
	ld	(_vram_transfer_size), a ;100 * 20
	    0$:
	ld a, (_scroll_x)
	ld	(0xFF43), a
	ld	a, (_scroll_y)
	ld	(0xFF42), a
;src/gb.c:51: vblank_happened = true;
	ld	hl, #_vblank_happened
	ld	(hl), #0x01
;src/gb.c:52: }
	pop	hl
	pop de
	pop bc
	pop af
	ret
;src/gb.c:53: void lcd_stat_isr() __interrupt {;}
;	---------------------------------
; Function lcd_stat_isr
; ---------------------------------
_lcd_stat_isr::
	ei
	push	af
	push bc
	push de
	push hl
	pop	hl
	pop de
	pop bc
	pop af
	ret
;src/gb.c:54: void timer_isr() __critical __interrupt {;}
;	---------------------------------
; Function timer_isr
; ---------------------------------
_timer_isr::
	push	af
	push bc
	push de
	push hl
	pop	hl
	pop de
	pop bc
	pop af
	reti
;src/gb.c:55: void serial_isr() __interrupt {;}
;	---------------------------------
; Function serial_isr
; ---------------------------------
_serial_isr::
	ei
	push	af
	push bc
	push de
	push hl
	pop	hl
	pop de
	pop bc
	pop af
	ret
;src/gb.c:56: void joypad_isr() __interrupt {;}
;	---------------------------------
; Function joypad_isr
; ---------------------------------
_joypad_isr::
	ei
	push	af
	push bc
	push de
	push hl
	pop	hl
	pop de
	pop bc
	pop af
	ret
;src/gb.c:58: void init_gameboy() __naked {
;	---------------------------------
; Function init_gameboy
; ---------------------------------
_init_gameboy::
;src/gb.c:76: __endasm;
	.globl	_main
	    1$:
	ld hl, #0xC000 ;clear ((uint8_t*)0xC000) at
	ld	de, #0x2000 ;0xC000 - 0xDFFF
	xor	a
	    0$:
	ld (hl+), a
	dec	de
	cp	e
	jr	nz, 0$
	cp	d
	jr	nz, 0$
	ld	sp, #0xE000 ;Stack points to RAM
	jp	_main ;actual start address
;src/gb.c:77: }
;src/gb.c:79: void fastcpy(void* _dst, void* _src, uint16_t _size){
;	---------------------------------
; Function fastcpy
; ---------------------------------
_fastcpy::
;src/gb.c:113: __endasm;
	dst	= 2
	src	= 4
	size	= 6
	ldhl	sp, #size ;bc = _size
	ld	a, (hl+)
	ld	b, (hl)
	ld	c, a
	xor	a
	or	b
	or	c
	jr	z, 1$
	ldhl	sp, #src ;de = _src
	ld	a, (hl+)
	ld	d, (hl)
	ld	e, a
	ldhl	sp, #dst ;hl = _dst
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	        0$:
	ld a, (de) ;for(;bc > 0; bc--) *(hl++) = *(de++)
	ld	(hl+), a
	inc	de
	dec	bc
	xor	a
	or	b
	or	c
	jr	nz, 0$
	        1$:
;src/gb.c:114: }
	ret
;src/gb.c:116: void fill(void* _dst, uint8_t _val, uint16_t _size){
;	---------------------------------
; Function fill
; ---------------------------------
_fill::
;src/gb.c:147: __endasm;
	dst	= 2
	val	= 4
	size	= 5
	ldhl	sp, #size ;bc = size
	ld	a, (hl+)
	ld	b, (hl)
	ld	c, a
	xor	a
	or	b
	or	c
	jr	z, 1$
	ldhl	sp, #val ;e = val
	ld	e, (hl)
	ldhl	sp, #dst ;hl = dst
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	        0$:
	ld a, e ;for() *(hl++) = e
	ld	(hl+), a
	dec	bc
	xor	a
	or	b
	or	c
	jr	nz, 0$
	        1$:
;src/gb.c:148: }
	ret
;src/gb.c:150: void set_bg_chr(uint8_t* _data, uint16_t _addr, uint16_t _size){
;	---------------------------------
; Function set_bg_chr
; ---------------------------------
_set_bg_chr::
	add	sp, #-2
;src/gb.c:151: fastcpy(BG_CHR + _addr, _data, _size);
	ldhl	sp,#4
	ld	a, (hl+)
	ld	e, (hl)
	ldhl	sp,#0
	ld	(hl+), a
	ld	(hl), e
	ldhl	sp,#(7 - 1)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	hl, #0x8000
	add	hl, de
	ld	c, l
	ld	b, h
	ldhl	sp,#8
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	push	hl
	ldhl	sp,#2
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	push	hl
	push	bc
	call	_fastcpy
	add	sp, #6
;src/gb.c:152: }
	add	sp, #2
	ret
;src/gb.c:154: void set_bg_map(uint8_t* _data, uint16_t _addr, uint16_t _size){
;	---------------------------------
; Function set_bg_map
; ---------------------------------
_set_bg_map::
	add	sp, #-2
;src/gb.c:155: fastcpy(BG_MAP + _addr, _data, _size);
	ldhl	sp,#4
	ld	a, (hl+)
	ld	e, (hl)
	ldhl	sp,#0
	ld	(hl+), a
	ld	(hl), e
	ldhl	sp,#(7 - 1)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	hl, #0x9800
	add	hl, de
	ld	c, l
	ld	b, h
	ldhl	sp,#8
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	push	hl
	ldhl	sp,#2
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	push	hl
	push	bc
	call	_fastcpy
	add	sp, #6
;src/gb.c:156: }
	add	sp, #2
	ret
;src/gb.c:158: void set_bg_map_tile(uint16_t _addr, uint8_t _tile){
;	---------------------------------
; Function set_bg_map_tile
; ---------------------------------
_set_bg_map_tile::
;src/gb.c:159: *reg(BG_MAP + _addr) = _tile;
	ldhl	sp,#(3 - 1)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	hl, #0x9800
	add	hl, de
	ld	c, l
	ld	b, h
	ldhl	sp,#4
	ld	a, (hl)
	ld	(bc), a
;src/gb.c:160: }
	ret
;src/gb.c:162: void update_bg_map_tile(uint16_t _addr, uint8_t _tile){
;	---------------------------------
; Function update_bg_map_tile
; ---------------------------------
_update_bg_map_tile::
	add	sp, #-2
;src/gb.c:163: vram_transfer_buffer[(vram_transfer_size << 2) + 0] = (BG_MAP_ADDR + _addr) & 0xFF;
	ld	hl, #_vram_transfer_size
	ld	a, (hl)
	add	a, a
	add	a, a
	ld	c, a
	rla
	sbc	a, a
	ld	b, a
	ld	hl, #_vram_transfer_buffer
	add	hl, bc
	ld	c, l
	ld	b, h
	ldhl	sp,#4
	ld	a, (hl)
	ld	(bc), a
;src/gb.c:164: vram_transfer_buffer[(vram_transfer_size << 2) + 1] = ((BG_MAP_ADDR + _addr) >> 8) & 0xFF;
	ld	hl, #_vram_transfer_size
	ld	a, (hl)
	add	a, a
	add	a, a
	inc	a
	ld	c, a
	rla
	sbc	a, a
	ld	b, a
	ld	hl, #_vram_transfer_buffer
	add	hl, bc
	ld	c, l
	ld	b, h
	ldhl	sp,#(5 - 1)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	hl, #0x9800
	add	hl, de
	inc	sp
	inc	sp
	push	hl
	ldhl	sp,#1
	ld	e, (hl)
	ld	d, #0x00
	ld	a, e
	ld	(bc), a
;src/gb.c:165: vram_transfer_buffer[(vram_transfer_size << 2) + 2] = 0x00;
	ld	hl, #_vram_transfer_size
	ld	a, (hl)
	add	a, a
	add	a, a
	inc	a
	inc	a
	ld	c, a
	rla
	sbc	a, a
	ld	b, a
	ld	hl, #_vram_transfer_buffer
	add	hl, bc
	ld	c, l
	ld	b, h
	xor	a, a
	ld	(bc), a
;src/gb.c:166: vram_transfer_buffer[(vram_transfer_size << 2) + 3] = _tile;
	ld	hl, #_vram_transfer_size
	ld	a, (hl)
	add	a, a
	add	a, a
	inc	a
	inc	a
	inc	a
	ld	c, a
	rla
	sbc	a, a
	ld	b, a
	ld	hl, #_vram_transfer_buffer
	add	hl, bc
	ld	c, l
	ld	b, h
	ldhl	sp,#6
	ld	a, (hl)
	ld	(bc), a
;src/gb.c:167: vram_transfer_size++;
	ld	hl, #_vram_transfer_size
	inc	(hl)
;src/gb.c:168: }
	add	sp, #2
	ret
;src/gb.c:170: void set_obj_chr(uint8_t* _data, uint16_t _addr, uint16_t _size){
;	---------------------------------
; Function set_obj_chr
; ---------------------------------
_set_obj_chr::
	add	sp, #-2
;src/gb.c:171: fastcpy(OBJ_CHR + _addr, _data, _size);
	ldhl	sp,#4
	ld	a, (hl+)
	ld	e, (hl)
	ldhl	sp,#0
	ld	(hl+), a
	ld	(hl), e
	ldhl	sp,#(7 - 1)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	hl, #0x8000
	add	hl, de
	ld	c, l
	ld	b, h
	ldhl	sp,#8
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	push	hl
	ldhl	sp,#2
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	push	hl
	push	bc
	call	_fastcpy
	add	sp, #6
;src/gb.c:172: }
	add	sp, #2
	ret
;src/gb.c:174: void set_obj(obj_t* _obj, uint8_t _x, uint8_t _y, uint8_t _tile, uint8_t _attr){
;	---------------------------------
; Function set_obj
; ---------------------------------
_set_obj::
	add	sp, #-2
;src/gb.c:175: _obj->x     = _x;
	ldhl	sp,#4
	ld	a, (hl+)
	ld	e, (hl)
	ldhl	sp,#0
	ld	(hl+), a
	ld	(hl), e
	pop	bc
	push	bc
	inc	bc
	ldhl	sp,#6
	ld	a, (hl)
	ld	(bc), a
;src/gb.c:176: _obj->y     = _y;
	pop	de
	push	de
	inc	hl
	ld	a, (hl)
	ld	(de), a
;src/gb.c:177: _obj->tile  = _tile;
	pop	bc
	push	bc
	inc	bc
	inc	bc
	inc	hl
	ld	a, (hl)
	ld	(bc), a
;src/gb.c:178: _obj->attr  = _attr;
	pop	bc
	push	bc
	inc	bc
	inc	bc
	inc	bc
	inc	hl
	ld	a, (hl)
	ld	(bc), a
;src/gb.c:179: }
	add	sp, #2
	ret
;src/gb.c:181: uint8_t copy_to_oam_obj(obj_t* _obj, uint8_t _slot){
;	---------------------------------
; Function copy_to_oam_obj
; ---------------------------------
_copy_to_oam_obj::
;src/gb.c:217: __endasm;
	obj	= 2
	slot	= 4
	ldhl	sp, #obj
	ld	a, (hl+)
	ld	d, (hl)
	ld	e, a
	ldhl	sp, #slot
	ld	l, (hl)
	ld	h, #0
	add	hl, hl
	add	hl, hl
	ld	bc, #_obj
	add	hl, bc
	ld	a, (de) ;copy Y
	inc	de
	add	#16
	ld	(hl+), a
	ld	a, (de) ;copy X
	inc	de
	add	#8
	ld	(hl+), a
	ld	a, (de) ;copy Tile
	inc	de
	ld	(hl+), a
	ld	a, (de) ;copy Attr
	ld	(hl), a
	ldhl	sp, #slot
	ld	e, (hl)
	inc	e
;src/gb.c:218: }
	ret
;src/gb.c:220: void read_joypad(){
;	---------------------------------
; Function read_joypad
; ---------------------------------
_read_joypad::
;src/gb.c:247: __endasm;
	ld	hl, #0xFF00
	ld	a, (_joy0)
	ld	(_old_joy0), a
	ld	(hl), #0x20
	ld	c, (hl)
	ld	c, (hl)
	ld	c, (hl)
	ld	a, (hl)
	swap	a
	and	#0xF0
	ld	b, a
	ld	(hl), #0x10
	ld	c, (hl)
	ld	c, (hl)
	ld	c, (hl)
	ld	a, (hl)
	and	#0x0F
	or	b
	ld	(hl), #0x30
	cpl
	ld	(_joy0), a
;src/gb.c:248: }
	ret
;src/gb.c:249: bool key_push(uint8_t _key){return (!(old_joy0 & _key) && (joy0 & _key));}
;	---------------------------------
; Function key_push
; ---------------------------------
_key_push::
	ld	hl, #_old_joy0
	ld	a, (hl)
	ldhl	sp,#2
	and	a,(hl)
	jr	NZ,00103$
	ld	hl, #_joy0
	ld	a, (hl)
	ldhl	sp,#2
	and	a,(hl)
	jr	NZ,00104$
00103$:
	xor	a, a
	jr	00105$
00104$:
	ld	a, #0x01
00105$:
	ld	e, a
	ret
;src/gb.c:250: bool key_hold(uint8_t _key){return (joy0 & _key);}
;	---------------------------------
; Function key_hold
; ---------------------------------
_key_hold::
	ld	hl, #_joy0
	ld	a, (hl)
	ldhl	sp,#2
	and	a, (hl)
	ld	c, a
	xor	a, a
	cp	a, c
	rla
	ld	e, a
	ret
;src/gb.c:251: bool key_release(uint8_t _key){return ((old_joy0 & _key) && !(joy0 & _key));}
;	---------------------------------
; Function key_release
; ---------------------------------
_key_release::
	ld	hl, #_old_joy0
	ld	a, (hl)
	ldhl	sp,#2
	and	a,(hl)
	jr	Z,00103$
	ld	hl, #_joy0
	ld	a, (hl)
	ldhl	sp,#2
	and	a,(hl)
	jr	Z,00104$
00103$:
	xor	a, a
	jr	00105$
00104$:
	ld	a, #0x01
00105$:
	ld	e, a
	ret
	.area _CODE
	.area _CABS (ABS)

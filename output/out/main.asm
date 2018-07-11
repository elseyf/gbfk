;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.7.1 #10455 (MINGW64)
;--------------------------------------------------------
	.module main
	.optsdcc -mgbz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _key_hold
	.globl _key_push
	.globl _read_joypad
	.globl _copy_to_oam_obj
	.globl _set_obj
	.globl _set_win_map_tile
	.globl _update_bg_map_tile
	.globl _set_bg_map_tile
	.globl _set_bg_chr
	.globl _fill
	.globl _fastcpy
	.globl _set_win_map_select
	.globl _set_bg_map_select
	.globl _cursor_obj
	.globl _bf_screen_out_y
	.globl _bf_screen_out_x
	.globl _bf_cell
	.globl _bf_cell_p
	.globl _bf_pc
	.globl _bf_instr
	.globl _bf_instr_p
	.globl _run_interpreter
	.globl _bf_hello_world
	.globl _bf_instruction_char
	.globl _ob1_palette
	.globl _ob0_palette
	.globl _bg_palette
	.globl _inc_bf_instr_p
	.globl _dec_bf_instr_p
	.globl _inc_bf_cell_p
	.globl _dec_bf_cell_p
	.globl _inc_bf_pc
	.globl _dec_bf_pc
	.globl _bf_editor
	.globl _bf_editor_update_instr
	.globl _bf_editor_redraw_instr
	.globl _bf_clear_screen
	.globl _bf_interpreter
	.globl _bf_get_char
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_run_interpreter::
	.ds 1
_bf_instr_p::
	.ds 2
_bf_instr::
	.ds 2048
_bf_pc::
	.ds 2
_bf_cell_p::
	.ds 2
_bf_cell::
	.ds 2048
_bf_screen_out_x::
	.ds 1
_bf_screen_out_y::
	.ds 1
_cursor_obj::
	.ds 4
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
;src/main.c:92: void main(){
;	---------------------------------
; Function main
; ---------------------------------
_main::
	add	sp, #-8
;src/gb.h:135: inline void disable_display(){while((*reg(REG_LCD_STAT) & LCD_STAT_MODE_FLAG) != 1); *reg(REG_LCDC) &= ~LCDC_DISPLAY_ENABLE;}
00118$:
	ld	de, #0xff41
	ld	a,(de)
	ld	c, a
	ld	b, #0x00
	ld	a, c
	and	a, #0x03
	ld	c, a
	ld	b, #0x00
	ld	a, c
	dec	a
	or	a, b
	jr	NZ,00118$
	ld	de, #0xff40
	ld	a,(de)
	res	7, a
	ld	hl, #0xff40
	ld	(hl), a
;src/main.c:94: ei();
	ei
;src/main.c:95: fastcpy(HRAM, oam_dma_wait, oam_dma_wait_size);
	ld	hl, #_oam_dma_wait_size
	ld	c, (hl)
	ld	b, #0x00
	push	bc
	ld	hl, #_oam_dma_wait
	push	hl
	ld	hl, #0xff80
	push	hl
	call	_fastcpy
	add	sp, #6
;src/main.c:97: vblank_happened = false;
	ld	hl, #_vblank_happened
	ld	(hl), #0x00
;src/gb.h:129: inline void enable_int(uint8_t _int){*reg(REG_INT) |= _int;}
	ld	de, #0xffff
	ld	a,(de)
	set	0, a
	ld	hl, #0xffff
	ld	(hl), a
;src/main.c:100: set_bg_pal(bg_palette);
	ld	hl, #_bg_palette
	ld	a, (hl)
;src/gb.h:152: inline void set_bg_pal(uint8_t _data){*reg(REG_BGP) = _data;}
	ld	hl, #0xff47
	ld	(hl), a
;src/main.c:101: set_obj_pal0(ob0_palette);
	ld	hl, #_ob0_palette
	ld	a, (hl)
;src/gb.h:153: inline void set_obj_pal0(uint8_t _data){*reg(REG_OBP0) = _data;}
	ld	hl, #0xff48
	ld	(hl), a
;src/main.c:102: set_obj_pal1(ob1_palette);
	ld	hl, #_ob1_palette
	ld	a, (hl)
;src/gb.h:154: inline void set_obj_pal1(uint8_t _data){*reg(REG_OBP1) = _data;}
	ld	hl, #0xff49
	ld	(hl), a
;src/main.c:104: set_bg_map_select(false);
	xor	a, a
	push	af
	inc	sp
	call	_set_bg_map_select
	inc	sp
;src/main.c:105: set_win_map_select(true);
	ld	a, #0x01
	push	af
	inc	sp
	call	_set_win_map_select
	inc	sp
;src/main.c:106: set_bg_chr(bg_tiles, 0x0000, sizeof(bg_tiles));
	ld	hl, #0x1000
	push	hl
	ld	h, #0x00
	push	hl
	ld	hl, #_bg_tiles
	push	hl
	call	_set_bg_chr
	add	sp, #6
;src/main.c:107: fill(BG_MAP, ' ', 0x0400);
	ld	hl, #0x0400
	push	hl
	ld	a, #0x20
	push	af
	inc	sp
	ld	h, #0x98
	push	hl
	call	_fill
	add	sp, #5
;src/main.c:108: fill(WIN_MAP, ' ' + 0x80, 0x0400);
	ld	hl, #0x0400
	push	hl
	ld	a, #0xa0
	push	af
	inc	sp
	ld	h, #0x9c
	push	hl
	call	_fill
	add	sp, #5
;src/main.c:109: {   uint8_t _x = 0, _y = 0;
	ld	c, #0x00
	ldhl	sp,#7
	ld	(hl), #0x00
;src/main.c:110: for(uint16_t i = 0xA0; i < 0x100; i++){
	dec	hl
	dec	hl
	ld	(hl), #0xa0
	inc	hl
	ld	(hl), #0x00
00134$:
	ldhl	sp,#5
	ld	a, (hl)
	sub	a, #0x00
	inc	hl
	ld	a, (hl)
	sbc	a, #0x01
	jp	NC, 00105$
;src/main.c:111: set_win_map_tile_xy(_x + BF_KEYBOARD_X, _y + BF_KEYBOARD_Y, i);
	ldhl	sp,#5
	ld	b, (hl)
	ld	a, c
	inc	a
	dec	hl
	ld	(hl), a
;src/gb.h:165: inline void set_win_map_tile_xy(uint8_t _x, uint8_t _y, uint8_t _tile){set_win_map_tile((_y << 5) + _x, _tile);}
	ldhl	sp,#7
	ld	e, (hl)
	ld	d, #0x00
	sla	e
	rl	d
	sla	e
	rl	d
	sla	e
	rl	d
	sla	e
	rl	d
	sla	e
	rl	d
	inc	sp
	inc	sp
	push	de
	ldhl	sp,#4
	ld	a, (hl-)
	dec	hl
	ld	(hl+), a
	ld	(hl), #0x00
	pop	de
	push	de
	dec	hl
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	add	hl, de
	ld	a, l
	ld	d, h
	ldhl	sp,#2
	ld	(hl+), a
	ld	(hl), d
	push	bc
	push	bc
	inc	sp
	dec	hl
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	push	hl
	call	_set_win_map_tile
	add	sp, #3
	pop	bc
;src/main.c:112: if(++_x >= BF_KEYBOARD_W){
	inc	c
	ld	a, c
	sub	a, #0x12
	jr	C,00135$
;src/main.c:113: _x = 0;
	ld	c, #0x00
;src/main.c:114: if(++_y >= BF_KEYBOARD_H)
	ldhl	sp,#7
	inc	(hl)
	ld	a, (hl)
	sub	a, #0x06
	jr	C,00135$
;src/main.c:115: _y = 0;
	ld	(hl), #0x00
00135$:
;src/main.c:110: for(uint16_t i = 0xA0; i < 0x100; i++){
	ldhl	sp,#5
	inc	(hl)
	jp	NZ,00134$
	inc	hl
	inc	(hl)
	jp	00134$
00105$:
;src/gb.h:173: inline void set_bg_scroll(uint8_t _sx, uint8_t _sy){scroll_x = _sx; scroll_y = _sy;}
	ld	hl, #_scroll_x
	ld	(hl), #0x00
	ld	hl, #_scroll_y
	ld	(hl), #0x00
;src/gb.h:174: inline void set_win_offset(uint8_t _ox, uint8_t _oy){offset_x = _ox + 7; offset_y = _oy;}
	ld	hl, #_offset_x
	ld	(hl), #0x07
	ld	hl, #_offset_y
	ld	(hl), #0x90
;src/gb.h:136: inline void enable_bg(){*reg(REG_LCDC) |= LCDC_BG_ENABLE;}
	ld	de, #0xff40
	ld	a,(de)
	ld	c, a
	ld	b, #0x00
	set	0, c
	ld	hl, #0xff40
	ld	(hl), c
;src/gb.h:138: inline void enable_win(){*reg(REG_LCDC) |= LCDC_WIN_ENABLE;}
	ld	de, #0xff40
	ld	a,(de)
	ld	c, a
	ld	b, #0x00
	set	5, c
	ld	l, #0x40
	ld	(hl), c
;src/gb.h:140: inline void enable_obj(){*reg(REG_LCDC) |= LCDC_OBJ_ENABLE;}
	ld	de, #0xff40
	ld	a,(de)
	ld	c, a
	ld	b, #0x00
	set	1, c
	ld	l, #0x40
	ld	(hl), c
;src/gb.h:134: inline void enable_display(){*reg(REG_LCDC) |= LCDC_DISPLAY_ENABLE;}
	ld	de, #0xff40
	ld	a,(de)
	ld	c, a
	ld	b, #0x00
	set	7, c
	ld	l, #0x40
	ld	(hl), c
;src/main.c:127: bf_instr_p = 0;
	ld	hl, #_bf_instr_p
	ld	(hl), #0x00
	inc	hl
	ld	(hl), #0x00
;src/main.c:128: for(uint16_t i = 0;i < sizeof(bf_instr); i++) bf_instr[i] = 0;
	ld	bc, #0x0000
00137$:
	ld	a, b
	sub	a, #0x08
	jr	NC,00106$
	ld	hl, #_bf_instr
	add	hl, bc
	ld	a, l
	ld	d, h
	ldhl	sp,#2
	ld	(hl+), a
	ld	(hl), d
	dec	hl
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	ld	(hl), #0x00
	inc	bc
	jr	00137$
00106$:
;src/main.c:129: bf_pc = 0;
	ld	hl, #_bf_pc
	ld	(hl), #0x00
	inc	hl
	ld	(hl), #0x00
;src/main.c:130: bf_cell_p = 0;
	ld	hl, #_bf_cell_p
	ld	(hl), #0x00
	inc	hl
	ld	(hl), #0x00
;src/main.c:131: for(uint16_t i = 0;i < sizeof(bf_cell); i++) bf_cell[i] = 0;
	ld	bc, #0x0000
00140$:
	ld	a, b
	sub	a, #0x08
	jr	NC,00107$
	ld	hl, #_bf_cell
	add	hl, bc
	ld	a, l
	ld	d, h
	ldhl	sp,#2
	ld	(hl+), a
	ld	(hl), d
	dec	hl
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	ld	(hl), #0x00
	inc	bc
	jr	00140$
00107$:
;src/main.c:132: bf_screen_out_x = 0;
	ld	hl, #_bf_screen_out_x
	ld	(hl), #0x00
;src/main.c:133: bf_screen_out_y = 0;
	ld	hl, #_bf_screen_out_y
	ld	(hl), #0x00
;src/main.c:134: run_interpreter = false;
	ld	hl, #_run_interpreter
	ld	(hl), #0x00
;src/main.c:136: fastcpy(&bf_instr, &bf_hello_world, sizeof(bf_hello_world));
	ld	hl, #0x0075
	push	hl
	ld	hl, #_bf_hello_world
	push	hl
	ld	hl, #_bf_instr
	push	hl
	call	_fastcpy
	add	sp, #6
;src/main.c:137: bf_editor_redraw_instr();
	call	_bf_editor_redraw_instr
;src/main.c:139: set_obj(&cursor_obj, 0, 0, 0x7F, 0);
	ld	hl, #0x007f
	push	hl
	ld	l, #0x00
	push	hl
	ld	hl, #_cursor_obj
	push	hl
	call	_set_obj
	add	sp, #6
;src/main.c:142: while(!vblank_happened) halt();
00108$:
	ld	hl, #_vblank_happened
	bit	0, (hl)
	jr	NZ,00110$
	halt
	jr	00108$
00110$:
;src/main.c:143: vblank_happened = false;
	ld	hl, #_vblank_happened
	ld	(hl), #0x00
;src/main.c:144: obj_slot = 0;
	ld	hl, #_obj_slot
	ld	(hl), #0x00
;src/main.c:146: read_joypad();
	call	_read_joypad
;src/main.c:148: if(run_interpreter)
	ld	hl, #_run_interpreter
	bit	0, (hl)
	jr	Z,00113$
;src/main.c:149: for(uint8_t i = 0; run_interpreter && (i < BF_INSTR_PER_FRAME); i++) bf_interpreter();
	ld	c, #0x00
00144$:
	ld	hl, #_run_interpreter
	bit	0, (hl)
	jr	Z,00114$
	ld	a, c
	sub	a, #0x0a
	jr	NC,00114$
	push	bc
	call	_bf_interpreter
	pop	bc
	inc	c
	jr	00144$
00113$:
;src/main.c:151: bf_editor();
	call	_bf_editor
00114$:
;src/main.c:153: fill((void*)(((uint16_t)obj) + (obj_slot << 2)), 0xFF, sizeof(obj) - (obj_slot << 2));
	ld	hl, #_obj_slot
	ld	c, (hl)
	ld	b, #0x00
	sla	c
	rl	b
	sla	c
	rl	b
	ld	de, #0x00a0
	ld	a, e
	sub	a, c
	ld	e, a
	ld	a, d
	sbc	a, b
	ldhl	sp,#3
	ld	(hl-), a
	ld	(hl), e
	dec	hl
	dec	hl
	ld	(hl), #<(_obj)
	inc	hl
	ld	(hl), #>(_obj)
	pop	hl
	push	hl
	add	hl, bc
	ld	c, l
	ld	b, h
	ldhl	sp,#2
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	push	hl
	ld	a, #0xff
	push	af
	inc	sp
	push	bc
	call	_fill
	add	sp, #5
	jp	00108$
;src/main.c:155: }
	add	sp, #8
	ret
_bg_palette:
	.db #0xe4	; 228
_ob0_palette:
	.db #0xe4	; 228
_ob1_palette:
	.db #0x27	; 39
_bf_instruction_char:
	.db #0x3e	; 62
	.db #0x3c	; 60
	.db #0x2b	; 43
	.db #0x2d	; 45
	.db #0x2e	; 46
	.db #0x2c	; 44
	.db #0x5b	; 91
	.db #0x5d	; 93
	.db #0x20	; 32
_bf_hello_world:
	.ascii "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++"
	.ascii "++++..+++.>>.<-.<.+++.------.--------.>>+.>++.[+]+[>,.<]"
	.db 0x00
;src/main.c:157: void inc_bf_instr_p(){if(bf_instr_p < (sizeof(bf_instr) - 1)) bf_instr_p++;}
;	---------------------------------
; Function inc_bf_instr_p
; ---------------------------------
_inc_bf_instr_p::
	ld	hl, #_bf_instr_p
	ld	a, (hl)
	sub	a, #0xff
	inc	hl
	ld	a, (hl)
	sbc	a, #0x07
	ret	NC
	ld	hl, #_bf_instr_p
	inc	(hl)
	ret	NZ
	inc	hl
	inc	(hl)
	ret
;src/main.c:158: void dec_bf_instr_p(){if(bf_instr_p > 0) bf_instr_p--;}
;	---------------------------------
; Function dec_bf_instr_p
; ---------------------------------
_dec_bf_instr_p::
	ld	hl, #_bf_instr_p + 1
	ld	a, (hl-)
	or	a, (hl)
	ret	Z
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	dec	de
	dec	hl
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ret
;src/main.c:159: void inc_bf_cell_p(){bf_cell_p = (bf_cell_p + 1) % (sizeof(bf_cell) - 1);}
;	---------------------------------
; Function inc_bf_cell_p
; ---------------------------------
_inc_bf_cell_p::
	ld	hl, #_bf_cell_p + 1
	dec	hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	bc
	ld	hl, #0x07ff
	push	hl
	push	bc
	call	__moduint
	add	sp, #4
	ld	hl, #_bf_cell_p
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ret
;src/main.c:160: void dec_bf_cell_p(){bf_cell_p = (bf_cell_p - 1) % (sizeof(bf_cell) - 1);}
;	---------------------------------
; Function dec_bf_cell_p
; ---------------------------------
_dec_bf_cell_p::
	ld	hl, #_bf_cell_p + 1
	dec	hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	dec	bc
	ld	hl, #0x07ff
	push	hl
	push	bc
	call	__moduint
	add	sp, #4
	ld	hl, #_bf_cell_p
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ret
;src/main.c:161: void inc_bf_pc(){bf_pc = (bf_pc + 1) % (sizeof(bf_instr) - 1);}
;	---------------------------------
; Function inc_bf_pc
; ---------------------------------
_inc_bf_pc::
	ld	hl, #_bf_pc + 1
	dec	hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	bc
	ld	hl, #0x07ff
	push	hl
	push	bc
	call	__moduint
	add	sp, #4
	ld	hl, #_bf_pc
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ret
;src/main.c:162: void dec_bf_pc(){bf_pc = (bf_pc - 1) % (sizeof(bf_instr) - 1);}
;	---------------------------------
; Function dec_bf_pc
; ---------------------------------
_dec_bf_pc::
	ld	hl, #_bf_pc + 1
	dec	hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	dec	bc
	ld	hl, #0x07ff
	push	hl
	push	bc
	call	__moduint
	add	sp, #4
	ld	hl, #_bf_pc
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ret
;src/main.c:164: void bf_editor(){
;	---------------------------------
; Function bf_editor
; ---------------------------------
_bf_editor::
	add	sp, #-3
;src/main.c:186: if(!(key_hold(KEY_A) || key_hold(KEY_B))){
	ld	a, #0x01
	push	af
	inc	sp
	call	_key_hold
	inc	sp
	bit	0, e
	jp	NZ, 00149$
	ld	a, #0x02
	push	af
	inc	sp
	call	_key_hold
	inc	sp
	bit	0, e
	jp	NZ, 00149$
;src/main.c:187: if(key_push(KEY_UP))            for(uint8_t i = 0; i < BF_EDITOR_W; i++) dec_bf_instr_p();
	ld	a, #0x40
	push	af
	inc	sp
	call	_key_push
	inc	sp
	bit	0, e
	jr	Z,00119$
	ld	c, #0x00
00154$:
	ld	a, c
	sub	a, #0x14
	jp	NC, 00150$
	push	bc
	call	_dec_bf_instr_p
	pop	bc
	inc	c
	jr	00154$
00119$:
;src/main.c:188: else if(key_push(KEY_DOWN))     for(uint8_t i = 0; i < BF_EDITOR_W; i++) inc_bf_instr_p();
	ld	a, #0x80
	push	af
	inc	sp
	call	_key_push
	inc	sp
	bit	0, e
	jr	Z,00116$
	ld	c, #0x00
00157$:
	ld	a, c
	sub	a, #0x14
	jp	NC, 00150$
	push	bc
	call	_inc_bf_instr_p
	pop	bc
	inc	c
	jr	00157$
00116$:
;src/main.c:189: else if(key_push(KEY_LEFT))     dec_bf_instr_p();
	ld	a, #0x20
	push	af
	inc	sp
	call	_key_push
	inc	sp
	bit	0, e
	jr	Z,00113$
	call	_dec_bf_instr_p
	jp	00150$
00113$:
;src/main.c:190: else if(key_push(KEY_RIGHT))    inc_bf_instr_p();
	ld	a, #0x10
	push	af
	inc	sp
	call	_key_push
	inc	sp
	bit	0, e
	jr	Z,00110$
	call	_inc_bf_instr_p
	jp	00150$
00110$:
;src/main.c:191: else if(key_push(KEY_START)){
	ld	a, #0x08
	push	af
	inc	sp
	call	_key_push
	inc	sp
	bit	0, e
	jr	Z,00107$
;src/main.c:192: run_interpreter = true;
	ld	hl, #_run_interpreter
	ld	(hl), #0x01
;src/main.c:193: bf_pc = 0;
	ld	hl, #_bf_pc
	ld	(hl), #0x00
	inc	hl
	ld	(hl), #0x00
;src/main.c:194: bf_cell_p = 0;
	ld	hl, #_bf_cell_p
	ld	(hl), #0x00
	inc	hl
	ld	(hl), #0x00
;src/main.c:195: for(uint16_t i = 0;i < sizeof(bf_cell); i++) bf_cell[i] = 0;
	ld	bc, #0x0000
00160$:
	ld	a, b
	sub	a, #0x08
	jr	NC,00103$
	ld	hl, #_bf_cell
	add	hl, bc
	inc	sp
	inc	sp
	push	hl
	pop	hl
	push	hl
	ld	(hl), #0x00
	inc	bc
	jr	00160$
00103$:
;src/main.c:196: bf_screen_out_x = 0;
	ld	hl, #_bf_screen_out_x
	ld	(hl), #0x00
;src/main.c:197: bf_screen_out_y = 0;
	ld	hl, #_bf_screen_out_y
	ld	(hl), #0x00
;src/main.c:198: bf_clear_screen();
	call	_bf_clear_screen
	jp	00150$
00107$:
;src/main.c:200: else if(key_push(KEY_SELECT)){
	ld	a, #0x04
	push	af
	inc	sp
	call	_key_push
	inc	sp
	bit	0, e
	jp	Z, 00150$
;src/main.c:201: bf_instr[bf_instr_p] = bf_instruction_char[BF_NOP];
	ld	a, #<(_bf_instr)
	ld	hl, #_bf_instr_p
	add	a, (hl)
	ld	c, a
	ld	a, #>(_bf_instr)
	inc	hl
	adc	a, (hl)
	ld	b, a
	ld	de, #_bf_instruction_char+8
	ld	a, (de)
	ld	(bc), a
;src/main.c:202: update_bg_map_tile_xy(bf_instr_p % BF_EDITOR_W, bf_instr_p / BF_EDITOR_W, bf_instruction_char[BF_NOP]);
	ld	a, (de)
	ldhl	sp,#2
	ld	(hl), a
	ld	hl, #0x0014
	push	hl
	ld	hl, #_bf_instr_p
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	push	hl
	call	__divuint
	add	sp, #4
	ld	c, e
	push	bc
	ld	hl, #0x0014
	push	hl
	ld	hl, #_bf_instr_p
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	push	hl
	call	__moduint
	add	sp, #4
	pop	bc
;src/gb.h:161: inline void update_bg_map_tile_xy(uint8_t _x, uint8_t _y, uint8_t _tile){update_bg_map_tile((_y << 5) + _x, _tile);}
	ld	b, #0x00
	sla	c
	rl	b
	sla	c
	rl	b
	sla	c
	rl	b
	sla	c
	rl	b
	sla	c
	rl	b
	ldhl	sp,#0
	ld	(hl), e
	inc	hl
	ld	(hl), #0x00
	pop	hl
	push	hl
	add	hl, bc
	ld	c, l
	ld	b, h
	ldhl	sp,#2
	ld	a, (hl)
	push	af
	inc	sp
	push	bc
	call	_update_bg_map_tile
	add	sp, #3
;src/main.c:203: dec_bf_instr_p();
	call	_dec_bf_instr_p
	jp	00150$
00149$:
;src/main.c:206: else if(key_hold(KEY_A)){
	ld	a, #0x01
	push	af
	inc	sp
	call	_key_hold
	inc	sp
	bit	0, e
	jp	Z, 00146$
;src/main.c:207: if(key_push(KEY_UP)){
	ld	a, #0x40
	push	af
	inc	sp
	call	_key_push
	inc	sp
	bit	0, e
	jr	Z,00130$
;src/main.c:208: bf_editor_update_instr(BF_PLUS);
	ld	a, #0x02
	push	af
	inc	sp
	call	_bf_editor_update_instr
	inc	sp
	jp	00150$
00130$:
;src/main.c:210: else if(key_push(KEY_DOWN)){
	ld	a, #0x80
	push	af
	inc	sp
	call	_key_push
	inc	sp
	bit	0, e
	jr	Z,00127$
;src/main.c:211: bf_editor_update_instr(BF_MINUS);
	ld	a, #0x03
	push	af
	inc	sp
	call	_bf_editor_update_instr
	inc	sp
	jp	00150$
00127$:
;src/main.c:213: else if(key_push(KEY_LEFT)){
	ld	a, #0x20
	push	af
	inc	sp
	call	_key_push
	inc	sp
	bit	0, e
	jr	Z,00124$
;src/main.c:214: bf_editor_update_instr(BF_LEFT);
	ld	a, #0x01
	push	af
	inc	sp
	call	_bf_editor_update_instr
	inc	sp
	jp	00150$
00124$:
;src/main.c:216: else if(key_push(KEY_RIGHT)){
	ld	a, #0x10
	push	af
	inc	sp
	call	_key_push
	inc	sp
	bit	0, e
	jp	Z, 00150$
;src/main.c:217: bf_editor_update_instr(BF_RIGHT);
	xor	a, a
	push	af
	inc	sp
	call	_bf_editor_update_instr
	inc	sp
	jp	00150$
00146$:
;src/main.c:220: else if(key_hold(KEY_B)){
	ld	a, #0x02
	push	af
	inc	sp
	call	_key_hold
	inc	sp
	bit	0, e
	jp	Z, 00150$
;src/main.c:221: if(key_push(KEY_UP)){
	ld	a, #0x40
	push	af
	inc	sp
	call	_key_push
	inc	sp
	bit	0, e
	jr	Z,00141$
;src/main.c:222: bf_editor_update_instr(BF_DOT);
	ld	a, #0x04
	push	af
	inc	sp
	call	_bf_editor_update_instr
	inc	sp
	jp	00150$
00141$:
;src/main.c:224: else if(key_push(KEY_DOWN)){
	ld	a, #0x80
	push	af
	inc	sp
	call	_key_push
	inc	sp
	bit	0, e
	jr	Z,00138$
;src/main.c:225: bf_editor_update_instr(BF_COMMA);
	ld	a, #0x05
	push	af
	inc	sp
	call	_bf_editor_update_instr
	inc	sp
	jr	00150$
00138$:
;src/main.c:227: else if(key_push(KEY_LEFT)){
	ld	a, #0x20
	push	af
	inc	sp
	call	_key_push
	inc	sp
	bit	0, e
	jr	Z,00135$
;src/main.c:228: bf_editor_update_instr(BF_BRACKET_LEFT);
	ld	a, #0x06
	push	af
	inc	sp
	call	_bf_editor_update_instr
	inc	sp
	jr	00150$
00135$:
;src/main.c:230: else if(key_push(KEY_RIGHT)){
	ld	a, #0x10
	push	af
	inc	sp
	call	_key_push
	inc	sp
	bit	0, e
	jr	Z,00150$
;src/main.c:231: bf_editor_update_instr(BF_BRACKET_RIGHT);
	ld	a, #0x07
	push	af
	inc	sp
	call	_bf_editor_update_instr
	inc	sp
00150$:
;src/main.c:235: set_obj(&cursor_obj, (bf_instr_p % BF_EDITOR_W) * 8, (bf_instr_p / BF_EDITOR_W) * 8, 0x7F, 0);
	ld	hl, #0x0014
	push	hl
	ld	hl, #_bf_instr_p
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	push	hl
	call	__divuint
	add	sp, #4
	ld	a, e
	add	a, a
	add	a, a
	add	a, a
	ld	b, a
	push	bc
	ld	hl, #0x0014
	push	hl
	ld	hl, #_bf_instr_p
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	push	hl
	call	__moduint
	add	sp, #4
	pop	bc
	ld	a, e
	add	a, a
	add	a, a
	add	a, a
	ld	d, a
	ld	hl, #0x007f
	push	hl
	push	bc
	inc	sp
	push	de
	inc	sp
	ld	hl, #_cursor_obj
	push	hl
	call	_set_obj
	add	sp, #6
;src/main.c:236: obj_slot = copy_to_oam_obj(&cursor_obj, obj_slot);
	ld	hl, #_obj_slot
	ld	a, (hl)
	push	af
	inc	sp
	ld	hl, #_cursor_obj
	push	hl
	call	_copy_to_oam_obj
	add	sp, #3
	ld	hl, #_obj_slot
	ld	(hl), e
;src/main.c:237: }
	add	sp, #3
	ret
;src/main.c:239: void bf_editor_update_instr(uint8_t _instr){
;	---------------------------------
; Function bf_editor_update_instr
; ---------------------------------
_bf_editor_update_instr::
	add	sp, #-3
;src/main.c:240: bf_instr[bf_instr_p] = bf_instruction_char[_instr];
	ld	de, #_bf_instr
	ld	hl, #_bf_instr_p
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	add	hl, de
	inc	sp
	inc	sp
	push	hl
	ld	de, #_bf_instruction_char
	ldhl	sp,#5
	ld	l, (hl)
	ld	h, #0x00
	add	hl, de
	ld	c, l
	ld	b, h
	ld	a, (bc)
	pop	hl
	push	hl
	ld	(hl), a
;src/main.c:241: update_bg_map_tile_xy(bf_instr_p % BF_EDITOR_W, bf_instr_p / BF_EDITOR_W, bf_instruction_char[_instr]);
	ld	a, (bc)
	ldhl	sp,#2
	ld	(hl), a
	ld	hl, #0x0014
	push	hl
	ld	hl, #_bf_instr_p
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	push	hl
	call	__divuint
	add	sp, #4
	ld	c, e
	push	bc
	ld	hl, #0x0014
	push	hl
	ld	hl, #_bf_instr_p
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	push	hl
	call	__moduint
	add	sp, #4
	pop	bc
;src/gb.h:161: inline void update_bg_map_tile_xy(uint8_t _x, uint8_t _y, uint8_t _tile){update_bg_map_tile((_y << 5) + _x, _tile);}
	ld	b, #0x00
	sla	c
	rl	b
	sla	c
	rl	b
	sla	c
	rl	b
	sla	c
	rl	b
	sla	c
	rl	b
	ldhl	sp,#0
	ld	(hl), e
	inc	hl
	ld	(hl), #0x00
	pop	hl
	push	hl
	add	hl, bc
	ld	c, l
	ld	b, h
	ldhl	sp,#2
	ld	a, (hl)
	push	af
	inc	sp
	push	bc
	call	_update_bg_map_tile
	add	sp, #3
;src/main.c:242: bf_instr_p++;
	ld	hl, #_bf_instr_p
	inc	(hl)
	jr	NZ,00106$
	inc	hl
	inc	(hl)
00106$:
;src/main.c:243: }
	add	sp, #3
	ret
;src/main.c:245: void bf_editor_redraw_instr(){
;	---------------------------------
; Function bf_editor_redraw_instr
; ---------------------------------
_bf_editor_redraw_instr::
	add	sp, #-7
;src/gb.h:135: inline void disable_display(){while((*reg(REG_LCD_STAT) & LCD_STAT_MODE_FLAG) != 1); *reg(REG_LCDC) &= ~LCDC_DISPLAY_ENABLE;}
00103$:
	ld	de, #0xff41
	ld	a,(de)
	ld	c, a
	ld	b, #0x00
	ld	a, c
	and	a, #0x03
	ld	c, a
	ld	b, #0x00
	ld	a, c
	dec	a
	or	a, b
	jr	NZ,00103$
	ld	de, #0xff40
	ld	a,(de)
	res	7, a
	ld	hl, #0xff40
	ld	(hl), a
;src/main.c:247: for(uint8_t i = 0; i < BF_EDITOR_H; i++){
	ldhl	sp,#6
	ld	(hl), #0x00
00113$:
	ldhl	sp,#6
	ld	a, (hl)
	sub	a, #0x12
	jp	NC, 00102$
;src/main.c:248: for(uint8_t j = 0; j < BF_EDITOR_W; j++){
	dec	hl
	ld	(hl), #0x00
00110$:
	ldhl	sp,#5
	ld	a, (hl)
	sub	a, #0x14
	jp	NC, 00114$
;src/main.c:249: set_bg_map_tile_xy(j, i, bf_instr[(i * BF_EDITOR_W) + j]);
	inc	hl
	ld	a, (hl)
	ldhl	sp,#0
	ld	(hl+), a
	ld	(hl), #0x00
	pop	bc
	push	bc
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, hl
	ld	c, l
	ld	b, h
	ldhl	sp,#5
	ld	a, (hl)
	ldhl	sp,#2
	ld	(hl+), a
	ld	(hl), #0x00
	dec	hl
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	add	hl, bc
	ld	c, l
	ld	b, h
	ld	hl, #_bf_instr
	add	hl, bc
	ld	c, l
	ld	b, h
	ld	a, (bc)
	ldhl	sp,#4
	ld	(hl), a
;src/gb.h:159: inline void set_bg_map_tile_xy(uint8_t _x, uint8_t _y, uint8_t _tile){set_bg_map_tile((_y << 5) + _x, _tile);}
	pop	bc
	push	bc
	sla	c
	rl	b
	sla	c
	rl	b
	sla	c
	rl	b
	sla	c
	rl	b
	sla	c
	rl	b
	dec	hl
	dec	hl
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	add	hl, bc
	ld	c, l
	ld	b, h
	ldhl	sp,#4
	ld	a, (hl)
	push	af
	inc	sp
	push	bc
	call	_set_bg_map_tile
	add	sp, #3
;src/main.c:248: for(uint8_t j = 0; j < BF_EDITOR_W; j++){
	ldhl	sp,#5
	inc	(hl)
	jp	00110$
00114$:
;src/main.c:247: for(uint8_t i = 0; i < BF_EDITOR_H; i++){
	ldhl	sp,#6
	inc	(hl)
	jp	00113$
00102$:
;src/gb.h:134: inline void enable_display(){*reg(REG_LCDC) |= LCDC_DISPLAY_ENABLE;}
	ld	de, #0xff40
	ld	a,(de)
	ld	c, a
	ld	b, #0x00
	set	7, c
	ld	hl, #0xff40
	ld	(hl), c
;src/main.c:252: enable_display();
;src/main.c:253: }
	add	sp, #7
	ret
;src/main.c:255: void bf_clear_screen(){
;	---------------------------------
; Function bf_clear_screen
; ---------------------------------
_bf_clear_screen::
	add	sp, #-4
;src/gb.h:135: inline void disable_display(){while((*reg(REG_LCD_STAT) & LCD_STAT_MODE_FLAG) != 1); *reg(REG_LCDC) &= ~LCDC_DISPLAY_ENABLE;}
00103$:
	ld	de, #0xff41
	ld	a,(de)
	ld	c, a
	ld	b, #0x00
	ld	a, c
	and	a, #0x03
	ld	c, a
	ld	b, #0x00
	ld	a, c
	dec	a
	or	a, b
	jr	NZ,00103$
	ld	de, #0xff40
	ld	a,(de)
	res	7, a
	ld	hl, #0xff40
	ld	(hl), a
;src/main.c:257: for(uint8_t i = 0; i < BF_EDITOR_H; i++){
	ldhl	sp,#3
	ld	(hl), #0x00
00113$:
	ldhl	sp,#3
	ld	a, (hl)
	sub	a, #0x12
	jp	NC, 00102$
;src/main.c:258: for(uint8_t j = 0; j < BF_EDITOR_W; j++){
	dec	hl
	ld	(hl), #0x00
00110$:
	ldhl	sp,#2
	ld	a, (hl)
	sub	a, #0x14
	jp	NC, 00114$
;src/gb.h:159: inline void set_bg_map_tile_xy(uint8_t _x, uint8_t _y, uint8_t _tile){set_bg_map_tile((_y << 5) + _x, _tile);}
	inc	hl
	ld	c, (hl)
	ld	b, #0x00
	sla	c
	rl	b
	sla	c
	rl	b
	sla	c
	rl	b
	sla	c
	rl	b
	sla	c
	rl	b
	dec	hl
	ld	a, (hl-)
	dec	hl
	ld	(hl+), a
	ld	(hl), #0x00
	pop	hl
	push	hl
	add	hl, bc
	ld	c, l
	ld	b, h
	ld	a, #0x20
	push	af
	inc	sp
	push	bc
	call	_set_bg_map_tile
	add	sp, #3
;src/main.c:258: for(uint8_t j = 0; j < BF_EDITOR_W; j++){
	ldhl	sp,#2
	inc	(hl)
	jp	00110$
00114$:
;src/main.c:257: for(uint8_t i = 0; i < BF_EDITOR_H; i++){
	ldhl	sp,#3
	inc	(hl)
	jp	00113$
00102$:
;src/gb.h:134: inline void enable_display(){*reg(REG_LCDC) |= LCDC_DISPLAY_ENABLE;}
	ld	de, #0xff40
	ld	a,(de)
	ld	c, a
	ld	b, #0x00
	set	7, c
	ld	hl, #0xff40
	ld	(hl), c
;src/main.c:262: enable_display();
;src/main.c:263: }
	add	sp, #4
	ret
;src/main.c:265: void bf_interpreter(){
;	---------------------------------
; Function bf_interpreter
; ---------------------------------
_bf_interpreter::
	add	sp, #-3
;src/main.c:266: if(key_push(KEY_START)){
	ld	a, #0x08
	push	af
	inc	sp
	call	_key_push
	inc	sp
	ld	c, e
	bit	0, c
	jr	Z,00134$
;src/main.c:267: bf_editor_redraw_instr();
	call	_bf_editor_redraw_instr
;src/main.c:268: run_interpreter = false;
	ld	hl, #_run_interpreter
	ld	(hl), #0x00
	jp	00145$
00134$:
;src/main.c:271: switch(bf_instr[bf_pc]){
	ld	a, #<(_bf_instr)
	ld	hl, #_bf_pc
	add	a, (hl)
	ld	c, a
	ld	a, #>(_bf_instr)
	inc	hl
	adc	a, (hl)
	ld	b, a
	ld	a, (bc)
	cp	a, #0x20
	jp	Z,00131$
	cp	a, #0x2b
	jr	Z,00103$
	cp	a, #0x2c
	jp	Z,00110$
	cp	a, #0x2d
	jr	Z,00104$
	cp	a, #0x2e
	jp	Z,00105$
	cp	a, #0x3c
	jr	Z,00102$
	cp	a, #0x3e
	jr	Z,00101$
	cp	a, #0x5b
	jp	Z,00111$
	sub	a, #0x5d
	jp	Z,00120$
	jp	00131$
;src/main.c:272: case '>':
00101$:
;src/main.c:273: inc_bf_cell_p();
	call	_inc_bf_cell_p
;src/main.c:274: inc_bf_pc();
	call	_inc_bf_pc
;src/main.c:275: break;
	jp	00145$
;src/main.c:276: case '<':
00102$:
;src/main.c:277: dec_bf_cell_p();
	call	_dec_bf_cell_p
;src/main.c:278: inc_bf_pc();
	call	_inc_bf_pc
;src/main.c:279: break;
	jp	00145$
;src/main.c:280: case '+':
00103$:
;src/main.c:281: bf_cell[bf_cell_p]++;
	ld	a, #<(_bf_cell)
	ld	hl, #_bf_cell_p
	add	a, (hl)
	ld	c, a
	ld	a, #>(_bf_cell)
	inc	hl
	adc	a, (hl)
	ld	b, a
	ld	a, (bc)
	inc	a
	ld	(bc), a
;src/main.c:282: inc_bf_pc();
	call	_inc_bf_pc
;src/main.c:283: break;
	jp	00145$
;src/main.c:284: case '-':
00104$:
;src/main.c:285: bf_cell[bf_cell_p]--;
	ld	a, #<(_bf_cell)
	ld	hl, #_bf_cell_p
	add	a, (hl)
	ld	c, a
	ld	a, #>(_bf_cell)
	inc	hl
	adc	a, (hl)
	ld	b, a
	ld	a, (bc)
	dec	a
	ld	(bc), a
;src/main.c:286: inc_bf_pc();
	call	_inc_bf_pc
;src/main.c:287: break;
	jp	00145$
;src/main.c:288: case '.':
00105$:
;src/main.c:289: update_bg_map_tile_xy(bf_screen_out_x, bf_screen_out_y, bf_cell[bf_cell_p]);
	ld	a, #<(_bf_cell)
	ld	hl, #_bf_cell_p
	add	a, (hl)
	ld	c, a
	ld	a, #>(_bf_cell)
	inc	hl
	adc	a, (hl)
	ld	b, a
	ld	a, (bc)
	ldhl	sp,#2
	ld	(hl), a
	ld	hl, #_bf_screen_out_y
	ld	c, (hl)
	ld	hl, #_bf_screen_out_x
	ld	e, (hl)
;src/gb.h:161: inline void update_bg_map_tile_xy(uint8_t _x, uint8_t _y, uint8_t _tile){update_bg_map_tile((_y << 5) + _x, _tile);}
	ld	b, #0x00
	sla	c
	rl	b
	sla	c
	rl	b
	sla	c
	rl	b
	sla	c
	rl	b
	sla	c
	rl	b
	ldhl	sp,#0
	ld	(hl), e
	inc	hl
	ld	(hl), #0x00
	pop	hl
	push	hl
	add	hl, bc
	ld	c, l
	ld	b, h
	ldhl	sp,#2
	ld	a, (hl)
	push	af
	inc	sp
	push	bc
	call	_update_bg_map_tile
	add	sp, #3
;src/main.c:290: bf_screen_out_x++;
	ld	hl, #_bf_screen_out_x
	inc	(hl)
;src/main.c:291: if(bf_screen_out_x >= BF_EDITOR_W){
	ld	a, (hl)
	sub	a, #0x14
	jr	C,00109$
;src/main.c:292: bf_screen_out_x = 0;
	ld	(hl), #0x00
;src/main.c:293: bf_screen_out_y++;
	ld	hl, #_bf_screen_out_y
	inc	(hl)
;src/main.c:294: if(bf_screen_out_y >= BF_EDITOR_H){
	ld	a, (hl)
	sub	a, #0x12
	jr	C,00109$
;src/main.c:295: bf_screen_out_x = 0;
	ld	hl, #_bf_screen_out_x
	ld	(hl), #0x00
00109$:
;src/main.c:298: inc_bf_pc();
	call	_inc_bf_pc
;src/main.c:299: break;
	jp	00145$
;src/main.c:300: case ',':
00110$:
;src/main.c:301: bf_cell[bf_cell_p] = bf_get_char();
	ld	a, #<(_bf_cell)
	ld	hl, #_bf_cell_p
	add	a, (hl)
	ld	c, a
	ld	a, #>(_bf_cell)
	inc	hl
	adc	a, (hl)
	ld	b, a
	push	bc
	call	_bf_get_char
	ld	a, e
	pop	bc
	ld	(bc), a
;src/main.c:302: inc_bf_pc();
	call	_inc_bf_pc
;src/main.c:303: break;
	jp	00145$
;src/main.c:304: case '[':
00111$:
;src/main.c:305: inc_bf_pc();
	call	_inc_bf_pc
;src/main.c:306: if(bf_cell[bf_cell_p] == 0){
	ld	a, #<(_bf_cell)
	ld	hl, #_bf_cell_p
	add	a, (hl)
	ld	c, a
	ld	a, #>(_bf_cell)
	inc	hl
	adc	a, (hl)
	ld	b, a
	ld	a, (bc)
	or	a, a
	jp	NZ, 00145$
;src/main.c:307: for(uint16_t _bracket_c = 1; (_bracket_c > 0) && (bf_pc < sizeof(bf_instr)); inc_bf_pc()){
	ld	bc, #0x0001
00139$:
	ld	a, b
	or	a, c
	jp	Z, 00145$
	ld	hl, #_bf_pc
	ld	a, (hl)
	sub	a, #0x00
	inc	hl
	ld	a, (hl)
	sbc	a, #0x08
	jp	NC, 00145$
;src/main.c:308: if(bf_instr[bf_pc] == '[')      _bracket_c++;
	ld	de, #_bf_instr
	ld	hl, #_bf_pc
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	add	hl, de
	inc	sp
	inc	sp
	push	hl
	pop	de
	push	de
	ld	a,(de)
	cp	a, #0x5b
	jr	NZ,00115$
	inc	bc
	jr	00140$
00115$:
;src/main.c:309: else if(bf_instr[bf_pc] == ']') _bracket_c--;
	sub	a, #0x5d
	jr	NZ,00140$
	dec	bc
00140$:
;src/main.c:307: for(uint16_t _bracket_c = 1; (_bracket_c > 0) && (bf_pc < sizeof(bf_instr)); inc_bf_pc()){
	push	bc
	call	_inc_bf_pc
	pop	bc
	jp	00139$
;src/main.c:313: case ']':
00120$:
;src/main.c:314: if(bf_cell[bf_cell_p] == 0) inc_bf_pc();
	ld	a, #<(_bf_cell)
	ld	hl, #_bf_cell_p
	add	a, (hl)
	ld	c, a
	ld	a, #>(_bf_cell)
	inc	hl
	adc	a, (hl)
	ld	b, a
	ld	a, (bc)
	or	a, a
	jr	NZ,00128$
	call	_inc_bf_pc
	jp	00145$
00128$:
;src/main.c:316: dec_bf_pc();
	call	_dec_bf_pc
;src/main.c:317: for(uint16_t _bracket_c = 1; (_bracket_c > 0) && (bf_pc < sizeof(bf_instr)); dec_bf_pc()){
	ld	bc, #0x0001
00143$:
	ld	a, b
	or	a, c
	jp	Z, 00126$
	ld	hl, #_bf_pc
	ld	a, (hl)
	sub	a, #0x00
	inc	hl
	ld	a, (hl)
	sbc	a, #0x08
	jr	NC,00126$
;src/main.c:318: if(bf_instr[bf_pc] == ']')      _bracket_c++;
	ld	de, #_bf_instr
	ld	hl, #_bf_pc
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	add	hl, de
	inc	sp
	inc	sp
	push	hl
	pop	de
	push	de
	ld	a,(de)
	cp	a, #0x5d
	jr	NZ,00124$
	inc	bc
	jr	00144$
00124$:
;src/main.c:319: else if(bf_instr[bf_pc] == '[') _bracket_c--;
	sub	a, #0x5b
	jr	NZ,00144$
	dec	bc
00144$:
;src/main.c:317: for(uint16_t _bracket_c = 1; (_bracket_c > 0) && (bf_pc < sizeof(bf_instr)); dec_bf_pc()){
	push	bc
	call	_dec_bf_pc
	pop	bc
	jp	00143$
00126$:
;src/main.c:321: inc_bf_pc();
	call	_inc_bf_pc
;src/main.c:322: inc_bf_pc();
	call	_inc_bf_pc
;src/main.c:324: break;
	jr	00145$
;src/main.c:326: default:
00131$:
;src/main.c:328: inc_bf_pc();
	call	_inc_bf_pc
;src/main.c:330: }
00145$:
;src/main.c:332: }
	add	sp, #3
	ret
;src/main.c:334: uint8_t bf_get_char(){
;	---------------------------------
; Function bf_get_char
; ---------------------------------
_bf_get_char::
	add	sp, #-6
;src/main.c:337: for(uint8_t i = 0; i <= ((BF_KEYBOARD_Y + BF_KEYBOARD_H) * 8); i += 4){
	ld	c, #0x00
00139$:
	ld	a, #0x30
	sub	a, c
	jr	C,00104$
;src/main.c:338: set_win_offset(0, 144 - i);
	ld	b, c
	ld	a, #0x90
	sub	a, b
	ld	hl, #_offset_y
	ld	(hl), a
;src/gb.h:174: inline void set_win_offset(uint8_t _ox, uint8_t _oy){offset_x = _ox + 7; offset_y = _oy;}
	ld	hl, #_offset_x
	ld	(hl), #0x07
;src/main.c:339: while(!vblank_happened) halt();
00101$:
	ld	hl, #_vblank_happened
	bit	0, (hl)
	jr	NZ,00103$
	halt
	jr	00101$
00103$:
;src/main.c:340: vblank_happened = false;
	ld	hl, #_vblank_happened
	ld	(hl), #0x00
;src/main.c:337: for(uint8_t i = 0; i <= ((BF_KEYBOARD_Y + BF_KEYBOARD_H) * 8); i += 4){
	inc	c
	inc	c
	inc	c
	inc	c
	jr	00139$
00104$:
;src/gb.h:174: inline void set_win_offset(uint8_t _ox, uint8_t _oy){offset_x = _ox + 7; offset_y = _oy;}
	ld	hl, #_offset_x
	ld	(hl), #0x07
	ld	hl, #_offset_y
	ld	(hl), #0x60
;src/main.c:344: _cx = 0; _cy = 0; _char = 0;
	ldhl	sp,#5
	ld	(hl), #0x00
	dec	hl
	ld	(hl), #0x00
;src/main.c:346: while(!vblank_happened) halt();
00105$:
	ld	hl, #_vblank_happened
	bit	0, (hl)
	jr	NZ,00107$
	halt
	jr	00105$
00107$:
;src/main.c:347: vblank_happened = false;
	ld	hl, #_vblank_happened
	ld	(hl), #0x00
;src/main.c:348: obj_slot = 0;
	ld	hl, #_obj_slot
	ld	(hl), #0x00
;src/main.c:349: read_joypad();
	call	_read_joypad
;src/main.c:351: if(key_push(KEY_UP))    if(_cy > 0)                                     _cy--;
	ld	a, #0x40
	push	af
	inc	sp
	call	_key_push
	inc	sp
	bit	0, e
	jr	Z,00111$
	ldhl	sp,#4
	ld	a, (hl)
	or	a, a
	jr	Z,00111$
	dec	(hl)
00111$:
;src/main.c:352: if(key_push(KEY_DOWN))  if((_cy + BF_KEYBOARD_Y) < (BF_KEYBOARD_H - 1)) _cy++;
	ld	a, #0x80
	push	af
	inc	sp
	call	_key_push
	inc	sp
	bit	0, e
	jr	Z,00115$
	ldhl	sp,#4
	ld	c, (hl)
	ld	b, #0x00
	ld	a, c
	sub	a, #0x05
	ld	a, b
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	NC,00115$
	inc	(hl)
00115$:
;src/main.c:353: if(key_push(KEY_LEFT))  if(_cx > 0)                                     _cx--;
	ld	a, #0x20
	push	af
	inc	sp
	call	_key_push
	inc	sp
	bit	0, e
	jr	Z,00119$
	ldhl	sp,#5
	ld	a, (hl)
	or	a, a
	jr	Z,00119$
	dec	(hl)
00119$:
;src/main.c:354: if(key_push(KEY_RIGHT)) if((_cx + BF_KEYBOARD_X) < BF_KEYBOARD_W) _cx++;
	ld	a, #0x10
	push	af
	inc	sp
	call	_key_push
	inc	sp
	bit	0, e
	jr	Z,00123$
	ldhl	sp,#5
	ld	c, (hl)
	ld	b, #0x00
	inc	bc
	ld	a, c
	sub	a, #0x12
	ld	a, b
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	NC,00123$
	inc	(hl)
00123$:
;src/main.c:355: if(key_push(KEY_A) || key_push(KEY_START))                          break;
	ld	a, #0x01
	push	af
	inc	sp
	call	_key_push
	inc	sp
;src/main.c:357: set_obj(&cursor_obj, (_cx + BF_KEYBOARD_X) * 8, 144 - ((BF_KEYBOARD_Y + BF_KEYBOARD_H) * 8) + ((_cy + BF_KEYBOARD_Y) * 8), 0x7F, 0x10);
	ldhl	sp,#4
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
;src/main.c:355: if(key_push(KEY_A) || key_push(KEY_START))                          break;
	bit	0, e
	jp	NZ, 00129$
	push	bc
	ld	a, #0x08
	push	af
	inc	sp
	call	_key_push
	inc	sp
	pop	bc
	bit	0, e
	jp	NZ, 00129$
;src/main.c:357: set_obj(&cursor_obj, (_cx + BF_KEYBOARD_X) * 8, 144 - ((BF_KEYBOARD_Y + BF_KEYBOARD_H) * 8) + ((_cy + BF_KEYBOARD_Y) * 8), 0x7F, 0x10);
	ld	a, c
	add	a, a
	add	a, a
	add	a, a
	add	a, #0x60
	ld	d, a
	ld	a, b
	inc	a
	add	a, a
	add	a, a
	add	a, a
	ld	b, a
	ld	hl, #0x107f
	push	hl
	push	de
	inc	sp
	push	bc
	inc	sp
	ld	hl, #_cursor_obj
	push	hl
	call	_set_obj
	add	sp, #6
;src/main.c:358: obj_slot = copy_to_oam_obj(&cursor_obj, obj_slot);
	ld	hl, #_obj_slot
	ld	a, (hl)
	push	af
	inc	sp
	ld	hl, #_cursor_obj
	push	hl
	call	_copy_to_oam_obj
	add	sp, #3
	ld	hl, #_obj_slot
	ld	(hl), e
;src/main.c:360: fill((void*)(((uint16_t)obj) + (obj_slot << 2)), 0xFF, sizeof(obj) - (obj_slot << 2));
	ld	c, (hl)
	ld	b, #0x00
	sla	c
	rl	b
	sla	c
	rl	b
	ld	de, #0x00a0
	ld	a, e
	sub	a, c
	ld	e, a
	ld	a, d
	sbc	a, b
	ldhl	sp,#3
	ld	(hl-), a
	ld	(hl), e
	dec	hl
	dec	hl
	ld	(hl), #<(_obj)
	inc	hl
	ld	(hl), #>(_obj)
	pop	hl
	push	hl
	add	hl, bc
	ld	c, l
	ld	b, h
	ldhl	sp,#2
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	push	hl
	ld	a, #0xff
	push	af
	inc	sp
	push	bc
	call	_fill
	add	sp, #5
	jp	00105$
00129$:
;src/main.c:362: _char = ' ' + ((_cy * BF_KEYBOARD_W) + _cx);
	ld	a, c
	add	a, a
	add	a, a
	add	a, a
	add	a, c
	add	a, a
	add	a, b
	add	a, #0x20
	ld	c, a
;src/main.c:363: obj_slot = 0;
	ld	hl, #_obj_slot
	ld	(hl), #0x00
;src/main.c:364: fill((void*)(((uint16_t)obj) + (obj_slot << 2)), 0xFF, sizeof(obj) - (obj_slot << 2));
	ld	de, #_obj
	push	bc
	ld	hl, #0x00a0
	push	hl
	ld	a, #0xff
	push	af
	inc	sp
	push	de
	call	_fill
	add	sp, #5
	pop	bc
;src/main.c:366: for(uint8_t i = (144 - ((BF_KEYBOARD_Y + BF_KEYBOARD_H) * 8)); i <= 144; i += 4){
	ld	b, #0x60
00142$:
	ld	a, #0x90
	sub	a, b
	jr	C,00133$
;src/gb.h:174: inline void set_win_offset(uint8_t _ox, uint8_t _oy){offset_x = _ox + 7; offset_y = _oy;}
	ld	hl, #_offset_x
	ld	(hl), #0x07
	ld	hl, #_offset_y
	ld	(hl), b
;src/main.c:368: while(!vblank_happened) halt();
00130$:
	ld	hl, #_vblank_happened
	bit	0, (hl)
	jr	NZ,00132$
	halt
	jr	00130$
00132$:
;src/main.c:369: vblank_happened = false;
	ld	hl, #_vblank_happened
	ld	(hl), #0x00
;src/main.c:366: for(uint8_t i = (144 - ((BF_KEYBOARD_Y + BF_KEYBOARD_H) * 8)); i <= 144; i += 4){
	inc	b
	inc	b
	inc	b
	inc	b
	jr	00142$
00133$:
;src/gb.h:174: inline void set_win_offset(uint8_t _ox, uint8_t _oy){offset_x = _ox + 7; offset_y = _oy;}
	ld	hl, #_offset_x
	ld	(hl), #0x07
	ld	hl, #_offset_y
	ld	(hl), #0x90
;src/main.c:373: return _char;
	ld	e, c
;src/main.c:374: }
	add	sp, #6
	ret
	.area _CODE
	.area _CABS (ABS)

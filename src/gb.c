/**
 * GameBoy Hardware Abstraction Layer, by el_seyf
 * Contains functions and defines for GameBoy Hardware
*/

#pragma disable_warning 59

#include <stdint.h>
#include <stdbool.h>
#include "gb.h"

obj_t               obj[40];
uint8_t             vram_transfer_size;
uint8_t             vram_transfer_buffer[4 * MAX_BYTES_PER_VBLANK];
uint8_t             obj_slot;
uint8_t             joy0, old_joy0;
uint8_t             scroll_x, scroll_y;
uint8_t             offset_x, offset_y;
volatile bool       vblank_happened;

void vblank_isr() __interrupt {
    __asm
        //VBlank is 4560 cycles long
        di
        call HRAM_OAM_DMA_ROUTINE           ;24 + (160 * 4) cycles = 664 cycles
        ei
        
        ld a, (_vram_transfer_size)         ;48 + (100 * MAX_BYTES_PER_VBLANK) cycles
        or a                                ;= 1648 max (16 Bytes)
        jr z, 0$
            ld e, a
            ld hl, #_vram_transfer_buffer   ;48
            
        1$: ld a, (hl+)
            ld c, a
            ld a, (hl+)
            ld b, a
            ld a, (hl+)
            
            ld a, (hl+)
            ld (bc), a
            
            dec e
            jr nz, 1$
            xor a
            ld (_vram_transfer_size), a     ;100 * MAX_BYTES_PER_VBLANK
    0$: ld a, (_scroll_x)
        ld (REG_BG_SCX), a
        ld a, (_scroll_y)
        ld (REG_BG_SCY), a
        ld a, (_offset_x)
        ld (REG_WX), a
        ld a, (_offset_y)
        ld (REG_WY), a
    __endasm;
    vblank_happened = true;
}
void lcd_stat_isr() __interrupt {;}
void timer_isr() __critical __interrupt {;}
void serial_isr() __interrupt {;}
void joypad_isr() __interrupt {;}

void init_gameboy() __naked {
    //This function is called at startup
    __asm
        .globl ROM_START_ADDR
        
    1$: ld hl, #0xC000          ;clear WRAM at
        ld de, #0x2000          ;0xC000 - 0xDFFF
        xor a
    0$: ld (hl+), a
        dec de
        cp e
        jr nz, 0$
            cp d
            jr nz, 0$
        
        ld sp, #0xE000          ;Stack points to RAM
        
        jp ROM_START_ADDR       ;actual start address
    __endasm;
}

void set_bg_map_select(bool _offset){
    if(_offset) *reg(REG_LCDC) |= LCDC_BG_MAP_SELECT;
    else        *reg(REG_LCDC) &= ~LCDC_BG_MAP_SELECT;
}
void set_win_map_select(bool _offset){
    if(_offset) *reg(REG_LCDC) |= LCDC_WIN_MAP_SELECT;
    else        *reg(REG_LCDC) &= ~LCDC_WIN_MAP_SELECT;
}


void fastcpy(void* _dst, void* _src, uint16_t _size){
    _dst = _dst; _src = _src; _size = _size;
    __asm
        dst = 2
        src = 4
        size = 6
        
        ldhl sp, #size          ;bc = _size
        ld a, (hl+)
        ld b, (hl)
        ld c, a
        xor a
        or b
        or c
        jr z, 1$
            ldhl sp, #src       ;de = _src
            ld a, (hl+)
            ld d, (hl)
            ld e, a
            
            ldhl sp, #dst       ;hl = _dst
            ld a, (hl+)
            ld h, (hl)
            ld l, a
            
        0$: ld a, (de)          ;for(;bc > 0; bc--) *(hl++) = *(de++)
            ld (hl+), a
            inc de
            dec bc
            xor a
            or b
            or c
            jr nz, 0$
        1$:
    __endasm;
}

void fill(void* _dst, uint8_t _val, uint16_t _size){
    _dst = _dst; _val = _val; _size = _size;
    __asm
        dst = 2
        val = 4
        size = 5
        
        ldhl sp, #size          ;bc = size
        ld a, (hl+)
        ld b, (hl)
        ld c, a
        xor a
        or b
        or c
        jr z, 1$
            ldhl sp, #val       ;e = val
            ld e, (hl)
            
            ldhl sp, #dst       ;hl = dst
            ld a, (hl+)
            ld h, (hl)
            ld l, a
            
        0$: ld a, e             ;for() *(hl++) = e
            ld (hl+), a
            dec bc
            xor a
            or b
            or c
            jr nz, 0$
        1$:
    __endasm;
}

void set_bg_chr(uint8_t* _data, uint16_t _addr, uint16_t _size){
    fastcpy(BG_CHR + _addr, _data, _size);
}

void set_bg_map(uint8_t* _data, uint16_t _addr, uint16_t _size){
    fastcpy(BG_MAP + _addr, _data, _size);
}

void set_bg_map_tile(uint16_t _addr, uint8_t _tile){
    *reg(BG_MAP + _addr) = _tile;
}

void update_bg_map_tile(uint16_t _addr, uint8_t _tile){
    vram_transfer_buffer[(vram_transfer_size << 2) + 0] = (BG_MAP_ADDR + _addr) & 0xFF;
    vram_transfer_buffer[(vram_transfer_size << 2) + 1] = ((BG_MAP_ADDR + _addr) >> 8) & 0xFF;
    vram_transfer_buffer[(vram_transfer_size << 2) + 2] = 0x00;
    vram_transfer_buffer[(vram_transfer_size << 2) + 3] = _tile;
    vram_transfer_size++;
}

void set_win_map(uint8_t* _data, uint16_t _addr, uint16_t _size){
    fastcpy(WIN_MAP + _addr, _data, _size);
}

void set_win_map_tile(uint16_t _addr, uint8_t _tile){
    *reg(WIN_MAP + _addr) = _tile;
}

void update_win_map_tile(uint16_t _addr, uint8_t _tile){
    vram_transfer_buffer[(vram_transfer_size << 2) + 0] = (WIN_MAP_ADDR + _addr) & 0xFF;
    vram_transfer_buffer[(vram_transfer_size << 2) + 1] = ((WIN_MAP_ADDR + _addr) >> 8) & 0xFF;
    vram_transfer_buffer[(vram_transfer_size << 2) + 2] = 0x00;
    vram_transfer_buffer[(vram_transfer_size << 2) + 3] = _tile;
    vram_transfer_size++;
}

void set_obj_chr(uint8_t* _data, uint16_t _addr, uint16_t _size){
    fastcpy(OBJ_CHR + _addr, _data, _size);
}

void set_obj(obj_t* _obj, uint8_t _x, uint8_t _y, uint8_t _tile, uint8_t _attr){
    _obj->x     = _x;
    _obj->y     = _y;
    _obj->tile  = _tile;
    _obj->attr  = _attr;
}

uint8_t copy_to_oam_obj(obj_t* _obj, uint8_t _slot){
    _obj = _obj; _slot = _slot;
    __asm
        obj = 2
        slot = 4
        
        ldhl sp, #obj
        ld a, (hl+)
        ld d, (hl)
        ld e, a
        
        ldhl sp, #slot
        ld l, (hl)
        ld h, #0
        add hl, hl
        add hl, hl
        ld bc, #_obj
        add hl, bc
        
        ld a, (de)      ;copy Y
        inc de
        add #16
        ld (hl+), a
        ld a, (de)      ;copy X
        inc de
        add #8
        ld (hl+), a
        ld a, (de)      ;copy Tile
        inc de
        ld (hl+), a
        ld a, (de)      ;copy Attr
        ld (hl), a
        
        ldhl sp, #slot
        ld e, (hl)
        inc e
    __endasm;
}

void read_joypad(){
    __asm
        ld hl, #REG_JOY0
        
        ld a, (_joy0)
        ld (_old_joy0), a
        
        ld (hl), #KEY_DIR
        ld c, (hl)
        ld c, (hl)
        ld c, (hl)
        ld a, (hl)
        swap a
        and #0xF0
        ld b, a
        
        ld (hl), #KEY_BTN
        ld c, (hl)
        ld c, (hl)
        ld c, (hl)
        ld a, (hl)
        and #0x0F
        or b
        
        ld (hl), #KEY_OFF
        cpl
        ld (_joy0), a
    __endasm;
}
bool key_push(uint8_t _key){return (!(old_joy0 & _key) && (joy0 & _key));}
bool key_hold(uint8_t _key){return (joy0 & _key);}
bool key_release(uint8_t _key){return ((old_joy0 & _key) && !(joy0 & _key));}

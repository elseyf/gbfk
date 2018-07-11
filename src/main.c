/**
 * gbfk - Brainf*ck Interpreter for GameBoy, by el_seyf
 * Allows to program end execute BF programs
 *
 * Instruction Mapping:
 * Hold nothing:
 *      UP:     cursor up
 *    DOWN:     cursor down
 *    LEFT:     cursor left
 *   RIGHT:     cursor right
 *   START:     Execute/Exit Program
 *  SELECT:     Erase Char
 *
 * Put instruction:
 * Hold A:
 *      UP:     +: Cell increase
 *    DOWN:     -: Cell decrease
 *    LEFT:     <: Cell address decrease
 *   RIGHT:     >: Cell address increase
 *
 * Hold B:
 *      UP:     .: Output Cell
 *    DOWN:     ,: Input Char
 *    LEFT:     ]: Bracket left
 *   RIGHT:     [: Bracket right
 *
*/

//Disable "Constant Overflow"-Warning
#pragma disable_warning 158

#include <stdint.h>
#include <stdbool.h>
#include "gb.h"

const uint8_t bg_palette = 0xE4;
const uint8_t ob0_palette = 0xE4;
const uint8_t ob1_palette = 0x27;

#define BF_EDITOR_W     20
#define BF_EDITOR_H     18

#define BF_KEYBOARD_X   1
#define BF_KEYBOARD_Y   0
#define BF_KEYBOARD_W   18
#define BF_KEYBOARD_H   6
//#define BF_KEYBOARD

#define BF_INSTR_PER_FRAME  10

const uint8_t bf_instruction_char[9] = {'>', '<', '+', '-', '.', ',', '[', ']', ' '};
#define BF_RIGHT            0
#define BF_LEFT             1
#define BF_PLUS             2
#define BF_MINUS            3
#define BF_DOT              4
#define BF_COMMA            5
#define BF_BRACKET_LEFT     6
#define BF_BRACKET_RIGHT    7
#define BF_NOP              8

bool run_interpreter;

uint16_t bf_instr_p;
uint8_t bf_instr[2048];
uint16_t bf_pc;

uint16_t bf_cell_p;
uint8_t bf_cell[2048];
uint8_t bf_screen_out_x, bf_screen_out_y;

obj_t cursor_obj;

const uint8_t bf_hello_world[] =
    "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---"
    ".+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."
    "[+]+[>,.<]";

void inc_bf_instr_p();
void dec_bf_instr_p();
void inc_bf_cell_p();
void dec_bf_cell_p();
void inc_bf_pc();
void dec_bf_pc();
void bf_editor();
void bf_editor_update_instr(uint8_t _instr);
void bf_editor_redraw_instr();
void bf_clear_screen();
void bf_interpreter();
uint8_t bf_get_char();

void main(){
    disable_display();
    ei();
    fastcpy(HRAM, oam_dma_wait, oam_dma_wait_size);
    
    vblank_happened = false;
    enable_int(VBLANK_INT);
    
    set_bg_pal(bg_palette);
    set_obj_pal0(ob0_palette);
    set_obj_pal1(ob1_palette);
    
    set_bg_map_select(false);
    set_win_map_select(true);
    set_bg_chr(bg_tiles, 0x0000, sizeof(bg_tiles));
    fill(BG_MAP, ' ', 0x0400);
    fill(WIN_MAP, ' ' + 0x80, 0x0400);
    {   uint8_t _x = 0, _y = 0;
        for(uint16_t i = 0xA0; i < 0x100; i++){
            set_win_map_tile_xy(_x + BF_KEYBOARD_X, _y + BF_KEYBOARD_Y, i);
            if(++_x >= BF_KEYBOARD_W){
                _x = 0;
                if(++_y >= BF_KEYBOARD_H)
                    _y = 0;
            }
        }
    }
    set_bg_scroll(0, 0);
    set_win_offset(0, 144);
    
    enable_bg();
    enable_win();
    enable_obj();
    enable_display();
    
    bf_instr_p = 0;
    for(uint16_t i = 0;i < sizeof(bf_instr); i++) bf_instr[i] = 0;
    bf_pc = 0;
    bf_cell_p = 0;
    for(uint16_t i = 0;i < sizeof(bf_cell); i++) bf_cell[i] = 0;
    bf_screen_out_x = 0;
    bf_screen_out_y = 0;
    run_interpreter = false;
    
    fastcpy(&bf_instr, &bf_hello_world, sizeof(bf_hello_world));
    bf_editor_redraw_instr();
    
    set_obj(&cursor_obj, 0, 0, 0x7F, 0);
    
    while(1){
        while(!vblank_happened) halt();
        vblank_happened = false;
        obj_slot = 0;
        
        read_joypad();
        
        if(run_interpreter)
            for(uint8_t i = 0; run_interpreter && (i < BF_INSTR_PER_FRAME); i++) bf_interpreter();
        else
            bf_editor();
        
        fill((void*)(((uint16_t)obj) + (obj_slot << 2)), 0xFF, sizeof(obj) - (obj_slot << 2));
    }
}

void inc_bf_instr_p(){if(bf_instr_p < (sizeof(bf_instr) - 1)) bf_instr_p++;}
void dec_bf_instr_p(){if(bf_instr_p > 0) bf_instr_p--;}
void inc_bf_cell_p(){bf_cell_p = (bf_cell_p + 1) % (sizeof(bf_cell) - 1);}
void dec_bf_cell_p(){bf_cell_p = (bf_cell_p - 1) % (sizeof(bf_cell) - 1);}
void inc_bf_pc(){bf_pc = (bf_pc + 1) % (sizeof(bf_instr) - 1);}
void dec_bf_pc(){bf_pc = (bf_pc - 1) % (sizeof(bf_instr) - 1);}

void bf_editor(){
    /* Instruction Mapping:
     * Hold nothing:
     *      UP:     cursor up
     *    DOWN:     cursor down
     *    LEFT:     cursor left
     *   RIGHT:     cursor right
     *
     * Put instruction:
     * Hold A:
     *      UP:     +: Cell increase
     *    DOWN:     -: Cell decrease
     *    LEFT:     <: Cell address decrease
     *   RIGHT:     >: Cell address increase
     *
     * Hold B:
     *      UP:     .: Output Cell
     *    DOWN:     ,: Input Char
     *    LEFT:     ]: Bracket left
     *   RIGHT:     [: Bracket right
    */
    
    if(!(key_hold(KEY_A) || key_hold(KEY_B))){
        if(key_push(KEY_UP))            for(uint8_t i = 0; i < BF_EDITOR_W; i++) dec_bf_instr_p();
        else if(key_push(KEY_DOWN))     for(uint8_t i = 0; i < BF_EDITOR_W; i++) inc_bf_instr_p();
        else if(key_push(KEY_LEFT))     dec_bf_instr_p();
        else if(key_push(KEY_RIGHT))    inc_bf_instr_p();
        else if(key_push(KEY_START)){
            run_interpreter = true;
            bf_pc = 0;
            bf_cell_p = 0;
            for(uint16_t i = 0;i < sizeof(bf_cell); i++) bf_cell[i] = 0;
            bf_screen_out_x = 0;
            bf_screen_out_y = 0;
            bf_clear_screen();
        }
        else if(key_push(KEY_SELECT)){
            bf_instr[bf_instr_p] = bf_instruction_char[BF_NOP];
            update_bg_map_tile_xy(bf_instr_p % BF_EDITOR_W, bf_instr_p / BF_EDITOR_W, bf_instruction_char[BF_NOP]);
            dec_bf_instr_p();
        }
    }
    else if(key_hold(KEY_A)){
        if(key_push(KEY_UP)){
            bf_editor_update_instr(BF_PLUS);
        }
        else if(key_push(KEY_DOWN)){
            bf_editor_update_instr(BF_MINUS);
        }
        else if(key_push(KEY_LEFT)){
            bf_editor_update_instr(BF_LEFT);
        }
        else if(key_push(KEY_RIGHT)){
            bf_editor_update_instr(BF_RIGHT);
        }
    }
    else if(key_hold(KEY_B)){
        if(key_push(KEY_UP)){
            bf_editor_update_instr(BF_DOT);
        }
        else if(key_push(KEY_DOWN)){
            bf_editor_update_instr(BF_COMMA);
        }
        else if(key_push(KEY_LEFT)){
            bf_editor_update_instr(BF_BRACKET_LEFT);
        }
        else if(key_push(KEY_RIGHT)){
            bf_editor_update_instr(BF_BRACKET_RIGHT);
        }
    }
    
    set_obj(&cursor_obj, (bf_instr_p % BF_EDITOR_W) * 8, (bf_instr_p / BF_EDITOR_W) * 8, 0x7F, 0);
    obj_slot = copy_to_oam_obj(&cursor_obj, obj_slot);
}

void bf_editor_update_instr(uint8_t _instr){
    bf_instr[bf_instr_p] = bf_instruction_char[_instr];
    update_bg_map_tile_xy(bf_instr_p % BF_EDITOR_W, bf_instr_p / BF_EDITOR_W, bf_instruction_char[_instr]);
    bf_instr_p++;
}

void bf_editor_redraw_instr(){
    disable_display();
    for(uint8_t i = 0; i < BF_EDITOR_H; i++){
        for(uint8_t j = 0; j < BF_EDITOR_W; j++){
            set_bg_map_tile_xy(j, i, bf_instr[(i * BF_EDITOR_W) + j]);
        }
    }
    enable_display();
}

void bf_clear_screen(){
    disable_display();
    for(uint8_t i = 0; i < BF_EDITOR_H; i++){
        for(uint8_t j = 0; j < BF_EDITOR_W; j++){
            set_bg_map_tile_xy(j, i, ' ');
        }
    }
    enable_display();
}

void bf_interpreter(){
    if(key_push(KEY_START)){
        bf_editor_redraw_instr();
        run_interpreter = false;
    }
    else{
        switch(bf_instr[bf_pc]){
            case '>':
                inc_bf_cell_p();
                inc_bf_pc();
                break;
            case '<':
                dec_bf_cell_p();
                inc_bf_pc();
                break;
            case '+':
                bf_cell[bf_cell_p]++;
                inc_bf_pc();
                break;
            case '-':
                bf_cell[bf_cell_p]--;
                inc_bf_pc();
                break;
            case '.':
                update_bg_map_tile_xy(bf_screen_out_x, bf_screen_out_y, bf_cell[bf_cell_p]);
                bf_screen_out_x++;
                if(bf_screen_out_x >= BF_EDITOR_W){
                    bf_screen_out_x = 0;
                    bf_screen_out_y++;
                    if(bf_screen_out_y >= BF_EDITOR_H){
                        bf_screen_out_x = 0;
                    }
                }
                inc_bf_pc();
                break;
            case ',':
                bf_cell[bf_cell_p] = bf_get_char();
                inc_bf_pc();
                break;
            case '[':
                inc_bf_pc();
                if(bf_cell[bf_cell_p] == 0){
                    for(uint16_t _bracket_c = 1; (_bracket_c > 0) && (bf_pc < sizeof(bf_instr)); inc_bf_pc()){
                        if(bf_instr[bf_pc] == '[')      _bracket_c++;
                        else if(bf_instr[bf_pc] == ']') _bracket_c--;
                    }
                }
                break;
            case ']':
                if(bf_cell[bf_cell_p] == 0) inc_bf_pc();
                else{
                    dec_bf_pc();
                    for(uint16_t _bracket_c = 1; (_bracket_c > 0) && (bf_pc < sizeof(bf_instr)); dec_bf_pc()){
                        if(bf_instr[bf_pc] == ']')      _bracket_c++;
                        else if(bf_instr[bf_pc] == '[') _bracket_c--;
                    }
                    inc_bf_pc();
                    inc_bf_pc();
                }
                break;
            case ' ':
            default:
                //Do nothing...
                inc_bf_pc();
                break;
        }
    }
}

uint8_t bf_get_char(){
    uint8_t _cx, _cy, _char;
    
    for(uint8_t i = 0; i <= ((BF_KEYBOARD_Y + BF_KEYBOARD_H) * 8); i += 4){
        set_win_offset(0, 144 - i);
        while(!vblank_happened) halt();
        vblank_happened = false;
    }
    set_win_offset(0, 144 - ((BF_KEYBOARD_Y + BF_KEYBOARD_H) * 8));
    
    _cx = 0; _cy = 0; _char = 0;
    while(1){
        while(!vblank_happened) halt();
        vblank_happened = false;
        obj_slot = 0;
        read_joypad();
        
        if(key_push(KEY_UP))    if(_cy > 0)                                     _cy--;
        if(key_push(KEY_DOWN))  if((_cy + BF_KEYBOARD_Y) < (BF_KEYBOARD_H - 1)) _cy++;
        if(key_push(KEY_LEFT))  if(_cx > 0)                                     _cx--;
        if(key_push(KEY_RIGHT)) if((_cx + BF_KEYBOARD_X) < BF_KEYBOARD_W) _cx++;
        if(key_push(KEY_A) || key_push(KEY_START))                          break;
        
        set_obj(&cursor_obj, (_cx + BF_KEYBOARD_X) * 8, 144 - ((BF_KEYBOARD_Y + BF_KEYBOARD_H) * 8) + ((_cy + BF_KEYBOARD_Y) * 8), 0x7F, 0x10);
        obj_slot = copy_to_oam_obj(&cursor_obj, obj_slot);
        
        fill((void*)(((uint16_t)obj) + (obj_slot << 2)), 0xFF, sizeof(obj) - (obj_slot << 2));
    }
    _char = ' ' + ((_cy * BF_KEYBOARD_W) + _cx);
    obj_slot = 0;
    fill((void*)(((uint16_t)obj) + (obj_slot << 2)), 0xFF, sizeof(obj) - (obj_slot << 2));
    
    for(uint8_t i = (144 - ((BF_KEYBOARD_Y + BF_KEYBOARD_H) * 8)); i <= 144; i += 4){
        set_win_offset(0, i);
        while(!vblank_happened) halt();
        vblank_happened = false;
    }
    set_win_offset(0, 144);
    
    return _char;
}




#pragma once

#include <stdint.h>

typedef uint16_t Bitset;

typedef Bitset Board[10];
enum Move { Up, Down, Left, Right };

extern "C" {
    void new_game(Board);
/*     void spawn_square(Board); */
/*     void apply_move(Board, Move); */
/* // extern "C" void available_moves(Board) */
    Bitset free_squares(Board);
    uint64_t nth_one(uint64_t x, uint64_t n); 
};


bits 64

	;; Bitsets by exponent(1 through 1024, not 2 thtrough 2048). 16 bits to match board size.
%define bitset_stride 2
%define max_exponent 10

struc state
	resw max_exponent
endstruc

	;; External functions
extern rand

	;; Exported functions
global new_game
global spawn_square
global apply_move
global peek_move
global available_moves
global free_squares
global nth_one
global modulus

	;; For readability
%define return rax
%define accum rax
%define arg1 rcx
%define arg2 rdx
%define arg3 r8
%define arg4 r9
%define zero(x) xor x, x

.code

	;; Name: free_squares
	;; Arg1: Pointer to board
	;; Returns: Bitset of empty squares
	;; Uses:
	;; rdx - Current exponent
%define hit_positions ax
%define empty_mask rdx
%define current_exponent r8
free_squares:
	zero(return)
	zero(current_exponent)
.loop:
	or hit_positions, word ptr [ arg1 + bitset_stride * current_exponent ]
	;; Have we considered all exponents?
	inc current_exponent
	cmp current_exponent, max_exponent
	jl .loop
	;; We accumulate a list of hit positions, so invert to get empty squares
	not return
	ret
%undef hit_positions
%undef empty_mask
%undef current_exponent

	;; Name: new_game
	;; Arg1: Pointer to board
new_game:
	%assign i 0
	%rep 8
	mov word [arg1 + i * bitsetstride], 0
	%assign i i+1
	%endrep
	jmp spawn_square

	;; Name: spawn_square
	;; Arg1: Pointer to board
	;; Uses:
	;; * r8 - Exponent randomly chosen to fill the square
	;; * r9 - Index of square to fill
	;; * r10 - Bitset of available squares
	;; * r11 - Random number
	;; * r12 - Copy of Arg1
%define chosen_exponent r8
%define idx_square r9
%define available_squares r10
%define random_number r11
%define board_pointer r12
spawn_square:
	mov board_pointer, Arg1

	;; Determine free squares
	call free_squares
	mov available_squares, return
	
	zero(chosen_exponent)

	call rand
	mov random_number, rax
	;; Use one bit of entropy to determine 1 or 2 to fill the square
	shr random_number, 1
	adc chosen_exponent, 0

	;; Map random number to random available square index
	zero(rdx)
	div rand
	mov idx_square, rdx
	
	;; Determine index of location to place
	mov arg1, available_squares
	mov arg2, idx_square
	call nth_one
	mov idx_square, return

	;; Place the square
	mov rax, 1
	shl rax, idx_square
	or word ptr [ board_pointer + bitset_stride * chosen_exponent ], rax
	
	ret
%undef chosen_exponent
%undef idx_square
%undef available_squares
%undef random_number
%undef board_pointer
	;; Name: nth_one
	;; Arg1: Integer
	;; Arg2: n
	;; Returns: 0-based index of nth set bit in Arg1.
	;; Uses:
	;; * r8 - Holds index of lowest bit
	;; * r9 - Holds index counter
	;; Notes:
	;; * If n >= num bits set in Arg1, then returns index of highest bit ;

%define idx_lowest r8
%define idx_count r9
nth_one:
	zero(idx_count)
	zero(return)
.loop:
	bsf idx_lowest, arg1
	jz .exit
	add return, idx_lowest
	
	cmp idx_count, arg2
	jge .exit
	
	inc idx_count
	shr arg1, idx_lowest
	jmp loop
.exit:	
	ret
%undef idx_lowest
%undef idx_count


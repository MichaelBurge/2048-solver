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
	or hit_positions, word [ arg1 + bitset_stride * current_exponent ]
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
	mov word [arg1 + i * bitset_stride], 0
	%assign i i+1
	%endrep
	jmp spawn_square

	;; Name: spawn_square
	;; Arg1: Pointer to board
	;; Uses:
	;; * r8 - Exponent randomly chosen to fill the square
	;; * rcx - Index of square to fill
	;; * r10 - Bitset of available squares
	;; * r11 - Random number
	;; * r12 - Copy of Arg1
	;; * r13 - Number of available squares
%define chosen_exponent r8
%define idx_square rcx
%define available_squares r10
%define random_number r11
%define board_pointer r12
%define num_available_squares r13
spawn_square:
	mov board_pointer, arg1

	;; Determine free squares
	call free_squares
	mov available_squares, return
	
	zero(chosen_exponent)

	call rand
	mov random_number, return
	;; Use one bit of entropy to determine 1 or 2 to fill the square
	shr random_number, 1
	adc chosen_exponent, 0

	;; Map random number to random available square index
	popcnt num_available_squares, available_squares
	zero(rdx)
	div num_available_squares
	mov idx_square, rdx	; rdx is the remainder
	
	;; Determine index of location to place
	mov arg1, available_squares
	mov arg2, idx_square
	call nth_one
	mov idx_square, return

	;; Place the square
	mov ax, 1
	shl ax, cl
	or word [ board_pointer + bitset_stride * chosen_exponent ], ax
	
	ret
%undef chosen_exponent
%undef idx_square
%undef available_squares
%undef random_number
%undef board_pointer
%undef num_available_squares
	;; Name: nth_one
	;; Arg1: Integer
	;; Arg2: n
	;; Returns: 0-based index of nth set bit in Arg1.
	;; Uses:
	;; * rcx - Holds index of lowest bit
	;; * r8 - Arg1 as its repeatedly shifted right
	;; * r9 - Holds index counter
	;; Notes:
	;; * If n >= num bits set in Arg1, then returns index of highest bit ;

%define idx_lowest rcx
%define idx_count r9
nth_one:
	zero(idx_count)
	zero(return)
	mov r8, arg1
.loop:
	bsf idx_lowest, r8
	jz .exit
	inc idx_lowest
	add return, idx_lowest
	
	cmp idx_count, arg2
	jge .exit
	
	shr r8, cl
	inc idx_count
	jmp .loop
.exit:
	dec return
	ret
%undef idx_lowest
%undef idx_count


% Play connect-four / eventually quarto
int: n = 4;
set of int: LEN = 1..n;
array[int,int] of int: board_start = array2d(LEN, LEN,
[|9,10,0,0|
  1,2,0,0|
  0,3,0,0|
  0,0,0,0|]);
set of int: PDOMAIN = 0..16;

set of int: WHITE = {9, 10, 11, 12, 13, 14, 15, 16};
set of int: BLACK = {1, 2, 3, 4, 5, 6, 7, 8};
set of int: TALL  = {5, 6, 7, 8, 13, 14, 15, 16};
set of int: SHORT = {1, 2, 3, 4, 9, 10, 11, 12};
set of int: SQUARE= {3, 4, 7, 8, 11, 12, 15, 16};
set of int: CIRCLE= {1, 2, 5, 6, 9, 10, 13, 14};
set of int: HOLLOW= {2, 4, 6, 8, 10, 12, 14, 16};
set of int: WHOLE = {1, 3, 5, 7, 9, 11, 13, 15};
array[1..8] of set of int: attributes = [WHITE, BLACK, TALL, SHORT, SQUARE, CIRCLE, HOLLOW, WHOLE];


set of int: MYPIECES = {11, 12, 13, 14, 15, 16};
array[LEN,LEN] of var PDOMAIN: board;
var 0..n: L;

% Count number of pieces in-a-row in array a starting from index i
function var int: n_in_row(array[LEN] of var int: a, int: i, set of int: ATTRIBUTE, bool: first_run) =
    if i == length(a) then
    0
    else % There are at least two pieces of the right color in a row
        if a[i] in ATTRIBUTE /\ a[i+1] in ATTRIBUTE then
            if first_run == true then
                2 + n_in_row(a, i+1, ATTRIBUTE, false)
            else
                1 + n_in_row(a, i+1, ATTRIBUTE, false)
            endif
        else
            0
        endif
    endif;

% Count number of pieces of type color in-a-row in array a
function var int: n_in_row_array(array[LEN] of var int: a, set of int: ATTRIBUTE) =
    max (i in LEN) (n_in_row(a, i, ATTRIBUTE, true));
    
function var int: max_in_row_board(array[LEN,LEN] of var int: b, set of int: ATTRIBUTE) =
    let {var int: max_horizontal = max (r in LEN) (n_in_row_array(row(b,r), ATTRIBUTE));
         var int: max_vertical   = max (c in LEN) (n_in_row_array(col(b,c), ATTRIBUTE));
         var int: max_diagonal1  = (n_in_row_array([b[r,c]|r,c in LEN where r == c], ATTRIBUTE));
         var int: max_diagonal2  = (n_in_row_array([b[r,c]|r,c in LEN where (r + c) == (length(col(b,1)) + 1)], ATTRIBUTE));} in
    max( array1d(1..4, [max_horizontal,
                        max_vertical,
                        max_diagonal1,
                        max_diagonal2]));
    

% Fill initiall board
constraint forall(r,c in LEN)(
    if board_start[c,r] > 0 then
        board[c,r] = board_start[c,r]
    else
        true
    endif
);

% Number of empty slots should be one less comparing to the start board.
constraint sum ([1 | r,c in LEN where board[r,c] == 0]) +1 == sum([1 | r,c in LEN where board_start[r,c] == 0]);
% Number of slots of selected color should be one more comparing to the start board.
constraint sum ([1 | r,c in LEN where board[r,c] in MYPIECES]) == 1+ sum([1 | r,c in LEN where board_start[r,c] in MYPIECES]);

constraint max (ATT in attributes) (max_in_row_board(board, ATT)) >= L;

solve maximize L;

output 
["Intial board:\n"]
++
[show_int(1,board_start[r,c]) ++ if c mod n == 0 then "\n" else " " endif | r,c in LEN]
++
["Board:\n"]
++
[show_int(1,board[r,c]) ++ if c mod n == 0 then "\n" else " " endif | r,c in LEN]
++
["\nL: " ++ show_int(1,L)];
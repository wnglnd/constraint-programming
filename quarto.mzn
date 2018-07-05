% Play quarto
% INSTRUCTIONS:
% * Set handed_piece to be the piece handed by the opponent.
% * The board_start should be updated after each round to
%   match the actual board layout.
%
% There is a deficiency when the handed piece can not be
% placed to improve the score (compared to board_start)
% i.e. the opponent has done a good job in selecting the piece.
% When this ouccurs, the peice will be placed randomly it seems.
% An improvement would be to try to block the opponent or
% at least place the piece where it later is possible to form
% four-in-a-row.
% 
% Pieces:
%         1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16
% WHITE   0  0  0  0  0  0  0  0  1  1  1  1  1  1  1  1
% TALL    0  0  0  0  1  1  1  1  0  0  0  0  1  1  1  1
% SQUARE  0  0  1  1  0  0  1  1  0  0  1  1  0  0  1  1
% HOLLOW  0  1  0  1  0  1  0  1  0  1  0  1  0  1  0  1


% Parameters
int: board_width = 4;
set of int: LEN = 1..board_width;
array[int,int] of int: board_start = array2d(LEN, LEN,
[|9,10,0,0|
  1,2,0,0|
  0,3,0,0|
  0,0,0,0|]);
set of int: PIECES = 0..16;
set of int: WHITE = {9, 10, 11, 12, 13, 14, 15, 16};
set of int: BLACK = {1, 2, 3, 4, 5, 6, 7, 8};
set of int: TALL  = {5, 6, 7, 8, 13, 14, 15, 16};
set of int: SHORT = {1, 2, 3, 4, 9, 10, 11, 12};
set of int: SQUARE= {3, 4, 7, 8, 11, 12, 15, 16};
set of int: CIRCLE= {1, 2, 5, 6, 9, 10, 13, 14};
set of int: HOLLOW= {2, 4, 6, 8, 10, 12, 14, 16};
set of int: FILLED = {1, 3, 5, 7, 9, 11, 13, 15};
array[1..8] of set of int: attributes = [WHITE, BLACK, TALL, SHORT, SQUARE, CIRCLE, HOLLOW, FILLED];
array[1..8] of string: attributes_str = ["WHITE", "BLACK", "TALL", "SHORT", "SQUARE", "CIRCLE", "HOLLOW", "FILLED"];

% Piece handed by opponent
int: handed_piece = 12;

% Decision variables
array[LEN,LEN] of var PIECES: board;
var 0..board_width: L;


% Count number of integers from set ATTRIBUTE in-a-row in array a starting from index i
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

% Search array for maximum number of integers in-a-row coming from set ATTRIBUTE
function var int: n_in_row_array(array[LEN] of var int: a, set of int: ATTRIBUTE) =
    max (i in LEN) (n_in_row(a, i, ATTRIBUTE, true));
    
% Search board horizontally, vertically and on both diagonals for highest score 
% where all integers must be in set ATTRIBUTE.
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

% Ensure that the piece handed by the opponent are not already on the board
constraint assert(forall(r,c in LEN) (board_start[r,c] != handed_piece), "INPUT ERROR: handed piece already on the board!");

% Number of empty slots should be one less comparing to the start board.
constraint sum ([1 | r,c in LEN where board[r,c] == 0]) +1 == sum([1 | r,c in LEN where board_start[r,c] == 0]);
% handed_piece should be placed on the board
constraint exists (r,c in LEN) (board[r,c] == handed_piece);
% Search board for highest score for each of the attributes
array[1..8] of var 0..4: points_per_attribute = [max_in_row_board(board, ATT) | ATT in attributes];
% Maximize any of the attributes
constraint max (points_per_attribute) >= L;
solve maximize L;

output
["Intial board:\n"]
++
[show_int(1,board_start[r,c]) ++ if c mod board_width == 0 then "\n" else " " endif | r,c in LEN]
++
["\nMove:\n"]
++
[show_int(1,board[r,c] - board_start[r,c]) ++ if c mod board_width == 0 then "\n" else " " endif | r,c in LEN]
++
["Strongest attribute: " ++ attributes_str[arg_max(fix(points_per_attribute))]]
++
[if handed_piece in attributes[arg_max(fix(points_per_attribute))] then "\nHanded piece is in strongest attribute" else "\nHanded piece is NOT in strongest attribute" endif]
++
["\n\nBoard after move:\n"]
++
[show_int(1,board[r,c]) ++ if c mod board_width == 0 then "\n" else " " endif | r,c in LEN]
++
["\nL: " ++ show_int(1,L)];
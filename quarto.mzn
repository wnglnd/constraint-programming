% Play connect-four / eventually quarto
int: n = 4;
set of int: LEN = 1..n;
array[int,int] of int: board_start = array2d(LEN, LEN,
[|0,0,1,0|
  0,1,0,0|
  1,0,0,0|
  1,1,1,2|]);
set of int: PDOMAIN = 0..2;
array[LEN,LEN] of var PDOMAIN: board;
var 0..n: L;

function var int: n_in_row(array[LEN] of var int: a, int: i, int: color, bool: first_run) =
    if i == length(a) then
    0
    else % There are at least two pieces of the right color in a row
        if a[i] == color /\ a[i] == a[i+1] then
            if first_run == true then
                2 + n_in_row(a, i+1, color, false)
            else
                1 + n_in_row(a, i+1, color, false)
            endif
        else
            0
        endif
    endif;

function var int: n_in_row_array(array[LEN] of var int: a, int: color) =
    max (i in LEN) (n_in_row(a, i, color, true));
    
function var int: max_in_row_board(array[LEN,LEN] of var int: b, int: color) =
    let {var int: max_horizontal = max (r in LEN) (n_in_row_array(row(b,r), color));
         var int: max_vertical   = max (c in LEN) (n_in_row_array(col(b,c), color));
         var int: max_diagonal1  = (n_in_row_array([b[r,c]|r,c in LEN where r == c], color));
         var int: max_diagonal2  = (n_in_row_array([b[r,c]|r,c in LEN where (r + c) == (length(col(b,1)) + 1)], color));} in
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

constraint max_in_row_board(board, 1) > L;

solve maximize L;

output ["Board:\n"]  ++
[show_int(1,board[r,c]) ++ if c mod n == 0 then "\n" else " " endif | r,c in LEN] ++
["\nL: " ++ show_int(1,L)];
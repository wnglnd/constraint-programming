% Array
int: n = 4;
set of int: LEN = 1..n;
array[int,int] of int: b = array2d(LEN, LEN,
[|0,0,1,0|
  0,1,0,0|
  1,0,0,0|
  1,1,1,0|]);
bool: first_run = true;

function int: n_in_row(array[LEN] of int: a, int: len, int: i, int: color, bool: first_run) =
    if i == len then
    0
    else
        if a[i] == color then
            if a[i] == a[i+1] then
                if first_run == true then
                    2 + n_in_row(a, len, i+1, color, false)
                else
                    1 + n_in_row(a, len, i+1, color, false)
                endif
            else
                0
            endif
        else
            0
        endif
    endif;

function int: n_in_row_array(array[LEN] of int: a, int: len, int: color) =
    max (i in LEN) (n_in_row(a, n, i, color, true));
    
function int: max_in_row_board(array[LEN,LEN] of int: b, int: width, int: color) =
    max( array1d(1..4, [max (r in LEN) (n_in_row_array([b[r,c]|c in LEN], width, color)),  % Horizontal
                        max (c in LEN) (n_in_row_array([b[r,c]|r in LEN], width, color)),  % Vertical
                                       (n_in_row_array([b[r,c]|r,c in LEN where r == c], width, color)),  % Diagonal
                                       (n_in_row_array([b[r,c]|r,c in LEN where (r + c) == (width + 1)], width, color))])); % Diagonal
    

var int: points = max_in_row_board(b, n, 1);



solve maximize points;

output [show_int(2, points)];

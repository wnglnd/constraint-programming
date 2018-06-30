% Array
int: n = 9;
set of int: LEN = 1..n;
array[LEN] of int: a = [1, 1, 1, 0, 0, 0, 1, 1, 1];
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

var int: points = max (i in LEN) (n_in_row(a, n, i, 1, true));

solve maximize points;

output [show_int(2, points)];

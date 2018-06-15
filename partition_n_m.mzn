int: n = 9;
array[1..n] of int: z = [-1, 6, 8, 9, 10, -100, 78, 0, 1];

array[1..n] of var 0..1: x1;
array[1..n] of var 0..1: x2;

constraint forall ([x1[i] + x2[i] = 1 | i in 1..n]);

solve minimize ([x1[i] * z[i]|i in 1..n]) - ([x1[i] * z[i]|i in 1..n]);
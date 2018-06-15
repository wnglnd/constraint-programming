int: S = 9;  %Sources
array[1..S] of int: sources = [1, 2, 3, 4, 5, 6, 7, 8, 9];
int: G = 3;   %Groups
array[1..G] of int: demands = [17, 20, 10];
var 0.0..100.0: L;  %Try to minimize this

array[1..G, 1..S] of var 0..1: X;

%Each source can only be used by one group
constraint
  forall(s in 1..S)
    (sum([X[i, s] | i in 1..G]) <= 1);
    
%Each group's assigned sources should not differ
%by more than L from that group's demand.
constraint
  forall(g in 1..G)
    (abs( sum( [X[g,i] * sources[i] | i in 1..S]) - demands[g]) < L);
    
solve minimize L;
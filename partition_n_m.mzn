int: S = 9;  %Sources
set of int: SOURCES = 1..S;
array[SOURCES] of int: sources = [1, 2, 3, 4, 5, 6, 7, 8, 9];
int: G = 3;   %Groups
set of int: GROUPS = 1..G;
array[GROUPS] of int: demands = [17, 20, 10];
var 0.0..100.0: L;  %Try to minimize this


array[GROUPS, SOURCES] of var 0..1: X;

%Each source can only be used by one group
constraint
  forall(s in SOURCES)
    (sum([X[g, s] | g in GROUPS]) <= 1);
    
%Each group's assigned sources should not differ
%by more than L from that group's demand.
constraint
  forall(g in GROUPS)
    (abs( sum( [X[g,s] * sources[s] | s in SOURCES]) - demands[g]) < L);
    
solve minimize L;


output [ if s == 1 then "\nGroup " ++ show_int(2, g) ++ ": " else "" endif ++
         show_int(2, X[g,s] * sources[s]) ++
         if s == S then " = " ++ show_int(2, sum (s in SOURCES) (X[g,s] * sources[s])) ++ " (demanded: " ++ show_int(2, demands[g]) ++ ")" else "" endif
         | g in GROUPS, s in SOURCES
];

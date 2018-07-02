%   SCANIA
% +  POWER
% ========
%     NICE
include "alldifferent.mzn";

var 1..4: E;
var 1..4: C;
var 1..4: I;
var 1..4: N;

constraint alldifferent([E,C,I,N]);

constraint        100*E + 10*C + I +
                  100*I + 10*C + E =
         1000*N + 100*C + 10*E + I;

solve satisfy;

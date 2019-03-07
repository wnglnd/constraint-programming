include "cumulative.mzn";

enum OBJECTS;
enum TASKS;

array[OBJECTS, TASKS] of int: durations; % durations
array[OBJECTS] of int: handlers_required; % number of handlers required
array[OBJECTS] of int: lifts_required; % number of lifts required

int: time_available;
int: handlers_available;
int: lifts_available;
int: no_tasks;

array[OBJECTS, TASKS] of var 0..time_available: start;
var 0..time_available: end;


constraint cumulative(start[..,stairs], durations[..,stairs], handlers_required, handlers_available);

constraint cumulative(start[..,lifter], durations[..,lifter], lifts_required, lifts_available);

constraint forall(o in OBJECTS)(
             forall(i,j in TASKS where i < j) (
               start[o,i] + durations[o,i] <= start[o,j]
             )
);
               
constraint max(o in OBJECTS)(start[o,lifter] + durations[o,lifter]) <= end;

solve minimize end;

output
["Start times: \n"]
++
[ show_int(3, start[i,j]) ++ 
  if j == no_tasks then "\n" else " " endif |
  i in OBJECTS, j in TASKS]
++
["\nEnd time: " ++ show_int(3, end)]
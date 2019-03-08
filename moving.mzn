% Moving - a scheduling problem.
%
% This problem deals with resource planning and scheduling.
% In particular it looks into how to move objects down some stairs
% (requiering handlers) and then lifting them onto a truck
% (requiering space on a tail lift). The stairs must come before
% the tail lift.
%
% The solution variable is the starting time for each object
% for each of the tasks (stairs and lift).
% 
% Extended from the example describing "cumulative" in the MiniZinc handbook:
% https://www.minizinc.org/doc-2.2.0/en/predicates.html#cumulative

include "cumulative.mzn";

enum OBJECTS;
enum TASKS;

array[OBJECTS, TASKS] of int: durations; % durations
array[OBJECTS] of int: handlers_required; % number of handlers required per object
array[OBJECTS] of int: lifts_required; % tail lift space required per object
int: time_available;
int: handlers_available;
int: lifts_available;
int: no_tasks;

array[OBJECTS, TASKS] of var 0..time_available: start;
var 0..time_available: end;

% The objects must not over consume the shared resources
constraint cumulative(start[..,stairs], durations[..,stairs], handlers_required, handlers_available);
constraint cumulative(start[..,lifter], durations[..,lifter], lifts_required, lifts_available);
% The starting time of the stairs must come before the lift
constraint forall(o in OBJECTS)(
             forall(i,j in TASKS where i < j) (
               start[o,i] + durations[o,i] <= start[o,j]
             )
);
% The last object's end time must be less than "end"
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
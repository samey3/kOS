// kp = 1, ki = 0, kd = 0
//Set these later

// Create a loop with default parameters
// maxoutput = maximum number value
// minoutput = minimum number value
SET PID TO PIDLOOP().

// Other constructors include:
SET PID TO PIDLOOP(KP).
SET PID TO PIDLOOP(KP, KI, KD).
// you must specify both minimum and maximum output directly.
SET PID TO PIDLOOP(KP, KI, KD, MINOUTPUT, MAXOUTPUT).

// remember to update both minimum and maximum output if the value changes symmetrically
SET LIMIT TO 0.5.
SET PID:MAXOUTPUT TO LIMIT.
SET PID:MINOUTPUT TO -LIMIT.

// call the update suffix to get the output
SET OUT TO PID:UPDATE(TIME:SECONDS, IN).

// you can also get the output value later from the PIDLoop object
SET OUT TO PID:OUTPUT.
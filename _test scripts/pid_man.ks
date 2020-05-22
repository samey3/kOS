//Implement some kind of tune-PID function, that tunes each component as the PID works
//Based on some kind of expression

CLEARSCREEN.
RCS ON.
LOCAL deadBand IS 0.05.

LOCAL targVessel IS VESSEL("PMM-1").

LOCAL LOCK targVec TO targVessel:FACING:VECTOR*10.
LOCAL LOCK targPos TO targVessel:POSITION + targVec.
LOCK diffVec TO (targPos - SHIP:POSITION).
LOCAL posVecDraw IS 0.

//LOCK STEERING TO SHIP:FACING.
LOCK STEERING TO LOOKDIRUP(-targVessel:FACING:VECTOR, targVessel:FACING:TOPVECTOR).


SET wn TO 3.//0.5. //5, 15 not bad, lots of thrusting though. Deadzone? 5, 25?
SET zeta TO 4.//7.
SET Kp TO wn^2 * ship:mass.
SET Kd TO 2 * ship:mass * zeta * wn.
SET Ki TO 0.01.

LOCAL pidX IS PIDLOOP(Kp, Ki, Kd).
	SET pidX:SETPOINT TO 0.
	SET pidX:MAXOUTPUT TO 1.
	SET pidX:MINOUTPUT TO -1.
	LOCK diffX TO (VDOT(SHIP:FACING:FOREVECTOR, diffVec)).
	LOCAL tX IS 0.		
LOCAL pidY IS PIDLOOP(Kp, Ki, Kd).
	SET pidY:SETPOINT TO 0.
	SET pidY:MAXOUTPUT TO 1.
	SET pidY:MINOUTPUT TO -1.
	LOCK diffY TO (VDOT(SHIP:FACING:TOPVECTOR, diffVec)).
	LOCAL tY IS 0.		
LOCAL pidZ IS PIDLOOP(Kp, Ki, Kd).
	SET pidZ:SETPOINT TO 0.
	SET pidZ:MAXOUTPUT TO 1.
	SET pidZ:MINOUTPUT TO -1.
	LOCK diffZ TO (VDOT(SHIP:FACING:STARVECTOR, diffVec)).
	LOCAL tZ IS 0.		

UNTIL(FALSE){
	CLEARSCREEN.
	SET posVecDraw TO VECDRAW(targVessel:POSITION, targVec, BLUE, "Target position", 1, TRUE, 0.5).
	PRINT("X-diff : " + diffX).
	PRINT("Y-diff : " + diffY).
	PRINT("Z-diff : " + diffZ).
	PRINT("tX : " + tX).
	PRINT("tY : " + tY).
	PRINT("tZ : " + tZ).
	SET tX TO -pidX:UPDATE(TIME:SECONDS, diffX). IF(ABS(diffX) < deadBand){ SET tX TO 0. }
	SET tY TO -pidY:UPDATE(TIME:SECONDS, diffY). IF(ABS(diffY) < deadBand){ SET tY TO 0. }
	SET tZ TO -pidZ:UPDATE(TIME:SECONDS, diffZ). IF(ABS(diffZ) < deadBand){ SET tZ TO 0. }
	
	SET SHIP:CONTROL:FORE TO tX/4.
	SET SHIP:CONTROL:TOP TO tY/2.
	SET SHIP:CONTROL:STARBOARD TO tZ/2.
	WAIT 0.01.
}
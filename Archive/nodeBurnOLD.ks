//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _timeToBurn_Maximum. 
	PARAMETER _burnDV.
	PARAMETER _dirVector IS V(0,0,0).
	
	LOCAL velFuture IS VELOCITYAT(SHIP, TIME:SECONDS + _timeToBurn_Maximum).
	
	IF _dirVector = 1 {
		LOCK _dirVector_set TO PROGRADE.
		SET expectedVector TO velFuture:ORBIT + velFuture:ORBIT:NORMALIZED*_burnDV.
	}
	ELSE IF _dirVector = 2 {
		LOCK _dirVector_set TO RETROGRADE.
		SET expectedVector TO velFuture:ORBIT - velFuture:ORBIT:NORMALIZED*_burnDV.
	}
	ELSE IF _dirVector = 3 {
		LOCK _dirVector_set TO (-VELOCITY:SURFACE):DIRECTION. //Surface retrograde
		SET expectedVector TO velFuture:SURFACE - velFuture:SURFACE:NORMALIZED*_burnDV.
	}
	ELSE IF _dirVector = 4 { //LHR motion up (Normal). Was previously up
		//Ship onto target : Ascending
		//Target onto ship : Descending
		SHIP:ANGULARMOMENTUM:NORMALIZED.
		LOCK _dirVector_set TO UP.
	}
	ELSE IF _dirVector = 5 { //LHR motion down (Anti-normal)
	
	}
	ELSE IF _dirVector = 6 { //Raise inclination in Normal-direction

	}
	ELSE IF _dirVector = 7 { //Lower inclination in Anti-Normal direction
		
	}
	ELSE
	{
		SET _dirVector_set TO _dirVector:DIRECTION.
		SET expectedVector TO velFuture:ORBIT + _dirVector:NORMALIZED*_burnDV.
	}

	
	IF _dirVector = 1 {
		LOCK _dirVector_set TO VELOCITY:ORBIT:DIRECTION. } //Orbit prograde
	ELSE IF _dirVector = 2 {
		LOCK _dirVector_set TO -VELOCITY:ORBIT:DIRECTION. } //Orbit retrograde
	ELSE IF _dirVector = 3 {
		LOCK _dirVector_set TO VELOCITY:SURFACE:DIRECTION. } //Surface prograde
	ELSE IF _dirVector = 4 {
		LOCK _dirVector_set TO -VELOCITY:SURFACE:DIRECTION. } //Surface retrograde
	ELSE IF _dirVector = 5 {
		LOCK _dirVector_set TO VCRS(VELOCITY:ORBIT, UP:VECTOR). } //Radial 'up' (LH)
	ELSE IF _dirVector = 6 {
		LOCK _dirVector_set TO VCRS(UP:VECTOR, VELOCITY:ORBIT). } //Radial 'down' (LH)
	ELSE IF _dirVector = 7 {
		LOCK _dirVector_set TO VCRS(VCRS(VELOCITY:ORBIT, UP:VECTOR), VELOCITY:ORBIT). } //Normal 'out' (LH)
	ELSE IF _dirVector = 8 {
		LOCK _dirVector_set TO VCRS(VELOCITY:ORBIT, VCRS(VELOCITY:ORBIT, UP:VECTOR)). } //Normal 'in' (LH)
	
	
	
	
	
	
	
	
	ELSE IF _dirVector = 3 {
		LOCK _dirVector_set TO (-VELOCITY:SURFACE):DIRECTION. //Surface retrograde
	
	SAS ON.
	RCS ON.
	SET controlStick to SHIP:CONTROL.


//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/


	SET base_acceleration TO SHIP:AVAILABLETHRUST / SHIP:MASS. //Mass in metric tonnes	
		LOCK required_thrust TO base_acceleration * SHIP:MASS.
		LOCK thrustPercent TO required_thrust / SHIP:AVAILABLETHRUST.
		
	SET burnTime TO _burnDV / base_acceleration.
	

//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	SET startTime TO TIME:SECONDS + _timeToBurn_Maximum.
	PRINT("start time : " + startTime).
	PRINT("time left : " + (startTime - TIME:SECONDS)).
	LOCK time2 TO TIME:SECONDS.
	LOCK timeLeft TO (startTime - time2).

	KUNIVERSE:TIMEWARP:WARPTO(TIME:SECONDS + (timeLeft - (burnTime/2 + 20))).
	WAIT UNTIL WARP = 0 and SHIP:UNPACKED.
	UNTIL timeLeft < (burnTime/2 + 20){
		CLEARSCREEN.
		PRINT "Running burn sub-script....".
		PRINT " ".
		PRINT "Burn DV 				: " + _burnDV  + " m/s".
		PRINT "Vessel deceleration 	: " + base_acceleration + " m/s^2".
		PRINT "Burn time 			: " + burnTime  + " s".
		PRINT " ".
		PRINT "Time to orientation  : " + (timeLeft - burnTime/2 - 20) + " s".
		PRINT "Time to burn  		: " + (timeLeft - burnTime/2) + " s".
		WAIT 0.1.
	} //Gives 20 seconds for the craft to rotate to the heading
	
	CLEARSCREEN.
	PRINT "Orientating for burn...".	
	LOCK STEERING TO smoothRotate(_dirVector_set).
	
	IF burnTime > 1
	{
		UNTIL timeLeft <= burnTime/2 {
			PRINT "Running burn sub-script....".
			PRINT " ".
			PRINT "Burn DV 				: " + _burnDV  + " m/s".
			PRINT "Vessel deceleration 	: " + base_acceleration + " m/s^2".
			PRINT "Burn time 			: " + burnTime  + " s".
			PRINT " ".
			PRINT "Orientating . . .".
			PRINT "Time to burn  		: " + (timeLeft - burnTime/2) + " s".
			WAIT 0.1.
			CLEARSCREEN.
		}
		LOCK THROTTLE TO thrustPercent. //Max deceleration
			
		WAIT burnTime - 1. //Linear deceleration
			LOCAL timer IS TIME:SECONDS + 2.
			LOCK THROTTLE TO 0.5*thrustPercent*(timer - TIME:SECONDS).
			
		WAIT 2.
	}
	ELSE
	{
		UNTIL timeLeft <= burnTime/2 {
			PRINT "Running burn sub-script....".
			PRINT " ".
			PRINT "Burn DV 				: " + _burnDV  + " m/s".
			PRINT "Vessel deceleration 	: " + base_acceleration + " m/s^2".
			PRINT "Burn time 			: " + burnTime  + " s".
			PRINT " ".
			PRINT "Orientating . . .".
			PRINT "Time to burn  		: " + (timeLeft - burnTime/2) + " s".
			WAIT 0.1.
			CLEARSCREEN.
		}
		
		LOCAL timer IS TIME:SECONDS + burnTime*2.
		LOCK THROTTLE TO 0.5*thrustPercent*(timer - TIME:SECONDS)/burnTime.

		WAIT 2*burnTime.
	}
	
	LOCK THROTTLE TO 0.		

	//IF(_dirVector <> 4){
		//RUN cancelVelocity(expectedVector, 0.05).
	//}
	
	RCS OFF.
	SET SHIP:CONTROL:NEUTRALIZE to TRUE.
	
	WAIT 0.5.

	
//------------------------------------------------------------------------------------------------------\
//												FUNCTIONS												|
//------------------------------------------------------------------------------------------------------/
		

FUNCTION smoothRotate {
    PARAMETER dir.
    LOCAL spd IS max(SHIP:ANGULARMOMENTUM:MAG/10,4).
    LOCAL curF IS SHIP:FACING:FOREVECTOR.
    LOCAL curR IS SHIP:FACING:TOPVECTOR.
    LOCAL rotR IS R(0,0,0).
    IF VANG(dir:FOREVECTOR,curF) < 90{SET rotR TO ANGLEAXIS(min(0.5,VANG(dir:TOPVECTOR,curR)/spd),VCRS(curR,dir:TOPVECTOR)).}
    RETURN LOOKDIRUP(ANGLEAXIS(min(2,VANG(dir:FOREVECTOR,curF)/spd),VCRS(curF,dir:FOREVECTOR))*curF,rotR*curR).
}
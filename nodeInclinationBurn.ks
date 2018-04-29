//This is for burns that are a short distance away generally.
//The heading vector will drift if it is a long time until the burn point, unless you are using a KSP-inherent heading (e.g. prograde, radial, etc.)


//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _timeToBurn_Maximum. 
	PARAMETER _inclinationChange IS 0.
	GLOBAL returnVal IS 0.
	
	LOCAL velFuture IS VELOCITYAT(SHIP, TIME:SECONDS + _timeToBurn_Maximum).
	LOCAL up_Vector IS VCRS(velFuture:ORBIT, POSITIONAT(SHIP, TIME:SECONDS + _timeToBurn_Maximum) - POSITIONAT(BODY, TIME:SECONDS + _timeToBurn_Maximum)):NORMALIZED. //'Up' vector
	LOCAL expectedVector IS (up_Vector*(TAN(_inclinationChange)*velFuture:ORBIT:MAG) + velFuture:ORBIT):NORMALIZED * velFuture:ORBIT:MAG.

	LOCAL thrustVector IS expectedVector - velFuture:ORBIT.
	LOCAL _burnDV IS thrustVector:MAG.
	SET _dirVector_set TO thrustVector:DIRECTION.

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
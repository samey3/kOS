

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _warpTime IS 60. 
	

//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/


//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	SET startTime TO TIME:SECONDS + _timeToBurn_Maximum.
	LOCK timeLeft TO startTime - TIME:SECONDS.

	
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
		WAIT UNTIL timeLeft <= burnTime/2.
		
		LOCAL timer IS TIME:SECONDS + burnTime*2.
		LOCK THROTTLE TO 0.5*thrustPercent*(timer - TIME:SECONDS)/burnTime.

		WAIT 2*burnTime.
	}
	
	LOCK THROTTLE TO 0.	
	RCS OFF.
	SET SHIP:CONTROL:NEUTRALIZE to TRUE.

	
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
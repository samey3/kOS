CLEARSCREEN.

//PARAMETER landingCoordinates.
	
	LOCK STEERING TO smoothRotate(RETROGRADE).
	RCS ON.

	//--------------------------------------------------------//
	//--------------------Ship calculations-------------------//

	
	SET legDistance TO 0.
	SET partList TO SHIP:PARTS.
	FOR PART IN partList
	{			
		IF (PART:POSITION - SHIP:POSITION):MAG > legDistance {
			SET legDistance TO (PART:POSITION - SHIP:POSITION):MAG.   //Finds the part farthest from the vessel center
		}
	}

	
//--------------------------------------------------------//
//------------------------Coasting------------------------//
	
	
	LOCK shipAltitude TO SHIP:ALTITUDE - SHIP:GEOPOSITION:TERRAINHEIGHT - legDistance.
	//LOCK shipAltitude TO SHIP:ALTITUDE - landingCoordinates:TERRAINHEIGHT - legDistance.
	
	UNTIL shipAltitude < 3000 {
		CLEARSCREEN.
		PRINT "LAT 					: " + SHIP:GEOPOSITION:LAT.
		PRINT "LNG 					: " + SHIP:GEOPOSITION:LNG.
		PRINT "---------------------------".
		PRINT "Altitude : " + shipAltitude.
		WAIT 0.1.
	}
	LOCK STEERING TO smoothRotate(UP).
	
	
//--------------------------------------------------------//
//--------------------Burn calculations-------------------//
		
		
	//Calculate time to landing
	LOCAL Ag IS (SHIP:BODY:MU / (shipAltitude + SHIP:BODY:RADIUS)^2).
	LOCAL Vf IS SQRT(VERTICALSPEED^2 + 2*Ag*shipAltitude).
	LOCAL timeLand IS shipAltitude/Vf - 0.5.

	//Calculate thrust and burn time required
	SET base_acceleration TO SHIP:AVAILABLETHRUST / SHIP:MASS. //Mass in metric tonnes	
		LOCK required_thrust TO base_acceleration * SHIP:MASS.
		LOCK thrustPercent TO required_thrust / SHIP:AVAILABLETHRUST.		
		//SET burnTime TO Vf / base_acceleration.	
		LOCK burnTime TO VERTICALSPEED / base_acceleration.
	
	SET startTime TO TIME:SECONDS + timeLand. //Impact time
	LOCK timeLeft TO startTime - TIME:SECONDS - 0.5.
	
	
//--------------------------------------------------------//
//----------------------Wait for burn---------------------//


	//UNTIL timeLeft <= burnTime/2 {
	required_thrust - Ag*SHIP:MASS
	LOCK burnTime to -SHIP:VELOCITY:SURFACE:MAG / (required_thrust/SHIP:MASS - Ag).
	UNTIL shipAltitude <= ABS((-SHIP:VELOCITY:SURFACE:MAG^2)/(2*(required_thrust/SHIP:MASS - Ag))) {
		CLEARSCREEN.
		PRINT "Burn distance      : " + (-SHIP:VELOCITY:SURFACE:MAG^2)/(2*(required_thrust/SHIP:MASS - Ag)).
		PRINT "Ship altitude : " + shipAltitude.
		WAIT 0.1.
	}
		
		
//--------------------------------------------------------//
//-----------------------SUICIDE BURN---------------------//	
		
		
	LOCK THROTTLE TO thrustPercent. //Max deceleration
				
	WAIT burnTime - 1. //Linear deceleration
		GEAR ON.
		LOCAL timer IS TIME:SECONDS + 2.
		LOCK THROTTLE TO 0.5*thrustPercent*(timer - TIME:SECONDS).				
		WAIT 2.
			
	LOCK THROTTLE TO 0.	
	RCS OFF.
	SET SHIP:CONTROL:NEUTRALIZE to TRUE.
	
	PRINT "LANDED!".
	
		
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
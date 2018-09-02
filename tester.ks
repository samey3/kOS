@lazyglobal OFF.
//Allows its functions to be called
//runoncepath("processing/processRequest.ks").


PRINT(TARGET:UP:VECTOR).
wait 5.

CLEARSCREEN.

LOCK STEERING TO SHIP:FACING.
LOCK THROTTLE TO 0.
UNLOCK STEERING.
UNLOCK THROTTLE.





runoncepath("lib/impactProperties.ks").
//Impact properties
LOCAL _coordinates IS TARGET:GEOPOSITION.
LOCAL stopAltitude IS 10000.
LOCAL timeToImpact IS getImpactTime(_coordinates:TERRAINHEIGHT + stopAltitude).

//Burn properties
LOCAL base_acceleration IS SHIP:AVAILABLETHRUST/SHIP:MASS. //Mass in metric tonnes
LOCK thrustPercent TO (base_acceleration*SHIP:MASS)/SHIP:AVAILABLETHRUST.	
LOCK horizontalVelocity TO SHIP:VELOCITY:SURFACE - ((SHIP:VELOCITY:SURFACE*T)/(TARGET:POSITION - SHIP:BODY:POSITION):NORMALIZED:MAG^2)*(TARGET:POSITION - SHIP:BODY:POSITION):NORMALIZED.
LOCK burnTime TO horizontalVelocity:MAG/base_acceleration.
		
LOCK horizontalDistance TO (TARGET:POSITION - SHIP:POSITION) - (((TARGET:POSITION - SHIP:POSITION)*(TARGET:POSITION - SHIP:BODY:POSITION):NORMALIZED)/(TARGET:POSITION - SHIP:BODY:POSITION):NORMALIZED:MAG^2)*(TARGET:POSITION - SHIP:BODY:POSITION):NORMALIZED.	

	
	
	
	
//Wait until time, perform burn
LOCK STEERING TO smoothRotate((-horizontalVelocity):DIRECTION).
LOCK Vi TO base_acceleration*burnTime.

UNTIL((horizontalDistance:MAG) <= (Vi*burnTime/2)){
	SET timeToImpact TO getImpactTime(_coordinates:TERRAINHEIGHT + stopAltitude).	
	CLEARSCREEN.
	PRINT("Horizontal distance : " + horizontalDistance:MAG).	
	PRINT("Stopping distance   : " + (Vi*burnTime/2)).
}
LOCK THROTTLE TO thrustPercent.
LOCAL timer IS TIME:SECONDS + burnTime.
LOCAL horizontalVelocity_init IS horizontalVelocity.
UNTIL (TIME:SECONDS >= timer OR VANG(horizontalVelocity, horizontalVelocity_init) >= 3){
	CLEARSCREEN.
	PRINT("Horizontal velocity : " + horizontalVelocity:MAG).
}
LOCK THROTTLE TO 0.









//Suicide burn
LOCK STEERING TO smoothRotate((-SHIP:VELOCITY:SURFACE):DIRECTION).
LOCAL effective_acceleration IS base_acceleration - SHIP:BODY:MU/(TARGET:POSITION - SHIP:BODY:POSITION):MAG^2.
LOCK stopTime TO SHIP:VELOCITY:SURFACE:MAG/effective_acceleration.
LOCK stopDistance TO (SHIP:VELOCITY:SURFACE:MAG*stopTime/2).
UNTIL (((SHIP:POSITION - SHIP:BODY:POSITION):MAG - SHIP:BODY:RADIUS - TARGET:GEOPOSITION:TERRAINHEIGHT) <= (stopDistance + 5)) { //Assume 3m from kOS module to landing legs
	CLEARSCREEN.
	PRINT("Stopping distance : " + stopDistance).
	PRINT("distance to burn : " + ((ALT:RADAR - 5) - stopDistance)).
	PRINT("Stop time : " + stopTime).
	PRINT("Effective acceleration : " + effective_acceleration).
}
LOCK THROTTLE TO thrustPercent.
LOCAL stopTime2 IS stopTime. //Unlocks it, but keeps it set
GEAR ON.
WAIT stopTime2.
LOCK THROTTLE TO 0.
LOCK STEERING TO smoothRotate(SHIP:UP).
WAIT 5.
PRINT("Landed.").




FUNCTION smoothRotate {
		PARAMETER dir.
		LOCAL spd IS max(SHIP:ANGULARMOMENTUM:MAG/10,4).
		LOCAL curF IS SHIP:FACING:FOREVECTOR.
		LOCAL curR IS SHIP:FACING:TOPVECTOR.
		LOCAL rotR IS R(0,0,0).
		IF VANG(dir:FOREVECTOR,curF) < 90{SET rotR TO ANGLEAXIS(min(0.5,VANG(dir:TOPVECTOR,curR)/spd),VCRS(curR,dir:TOPVECTOR)).}
		RETURN LOOKDIRUP(ANGLEAXIS(min(2,VANG(dir:FOREVECTOR,curF)/spd),VCRS(curF,dir:FOREVECTOR))*curF,rotR*curR).
	}
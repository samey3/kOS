RUNONCEPATH("lib/scriptManagement.ks").	//Sets all default values, no SAS/RCS, removes nodes, etc...
RUNONCEPATH("lib/config.ks"). 			//Loading steering config
//RUNONCEPATH("lib/gameControl.ks"). 	//Warp
//RUNONCEPATH("lib/shipControl.ks"). 	//Adaptive lighting, vessel height
//RUNONCEPATH("lib/lambert.ks").		//Calculations
RUNONCEPATH("lib/math.ks"). 			//Functions, vector methods, coordinate conversion



//For our flying scripts, what do we want?

//1. Takeoff (with specific runway direction?)
//2. Fly to coordinates (turn as fast as possible or gradually? Optional limit on speed?)
//3. Land (with specific runway direction?). Likely involves fly to coordinates to line up first
//4. Taxi (e.g. to runway, and face specific direction?)

//Main functions:
//1. Takeoff
	//N/A?
//2. Fly to point
	//
//3. Land (runway coords[start/end?])
	//Fly to point(coords, alt, velocity)[use airbrakes to reduce velocity as well]
//4. Taxi
	//N/A? Path-finding? More of a ground operations function I think.
	
//Intermediate functions:
//1. Fly to point

//Basic functions:


CLEARVECDRAWS().

configureVessel("F22-Takeoff").

SET runwayVec TO projectToPlane(SHIP:FACING:VECTOR, UP:VECTOR).
SET takeoffVector TO runwayVec*ANGLEAXIS(5, VCRS(runwayVec, UP:VECTOR)).

SET initCoords TO LATLNG(-0.04859836, -74.7248366). //SHIP:GEOPOSITION.


SET runEndCoords TO LATLNG(-0.04859836, -74.4950446).

SET targPos1 TO KERBIN:GEOPOSITIONOF(initCoords:POSITION - (runEndCoords:POSITION - initCoords:POSITION):NORMALIZED*11000). //:ALTITUDEPOSITION(5000).
SET targPos2 TO KERBIN:GEOPOSITIONOF(initCoords:POSITION - (runEndCoords:POSITION - initCoords:POSITION):NORMALIZED*6000). //:ALTITUDEPOSITION(3000).
SET targPos3 TO KERBIN:GEOPOSITIONOF(initCoords:POSITION - (runEndCoords:POSITION - initCoords:POSITION):NORMALIZED*3000). //:ALTITUDEPOSITION(1000).
SET targPos4 TO KERBIN:GEOPOSITIONOF(initCoords:POSITION - (runEndCoords:POSITION - initCoords:POSITION):NORMALIZED*800). //:ALTITUDEPOSITION(200).
SET targPos5 TO runEndCoords. //:ALTITUDEPOSITION(70).


SET posQueue TO QUEUE().
posQueue:PUSH(targPos1).
posQueue:PUSH(targPos2).
posQueue:PUSH(targPos3).
posQueue:PUSH(targPos4).
posQueue:PUSH(targPos5).

SET altQueue TO QUEUE().
altQueue:PUSH(5000).
altQueue:PUSH(3000).
altQueue:PUSH(1000).
altQueue:PUSH(400).
altQueue:PUSH(400). //70

LOCK targPos TO posQueue:PEEK():ALTITUDEPOSITION(altQueue:PEEK()).


LOCK STEERING TO takeoffVector.

BRAKES ON.
STAGE.

LOCK THROTTLE TO 1.
WAIT 3.
BRAKES OFF.

UNTIL(SHIP:STATUS = "FLYING"){
	PRINT("Current speed: " + GROUNDSPEED).
	//PRINT("Takeoff speed: fuk if I know yet").
	
	WAIT 0.01.
	CLEARSCREEN.	
}


GEAR OFF.

WAIT 5.
configureVessel("F22-Flight").

//Set target KSC, altitude 3km

SET wn TO 1.
SET zeta TO 3.
SET Kp TO wn^2 * ship:mass.
SET Kd TO 2 * ship:mass * zeta * wn.
SET Ki TO 0.0.

SET Kp TO 1.5.
SET Kd TO 0.05.
SET Ki TO 0.08.

SET PID TO PIDLOOP(Kp, Ki, Kd).

//SET PID:SETPOINT TO (90 - VANG((targPos - SHIP:POSITION), UP:VECTOR)).
SET PID:SETPOINT TO 0.
SET PID:MAXOUTPUT TO 90.
SET PID:MINOUTPUT TO -90.

//LOCK reqPitch TO PID:UPDATE(TIME:SECONDS, (90 - VANG(SHIP:FACING:VECTOR, UP:VECTOR))).
//LOCK reqPitch TO PID:UPDATE(TIME:SECONDS, (90 - VANG(SHIP:VELOCITY:SURFACE, UP:VECTOR))).
LOCK reqPitch TO PID:UPDATE(TIME:SECONDS, VANG((targPos - SHIP:POSITION), UP:VECTOR) - VANG(SHIP:VELOCITY:SURFACE, UP:VECTOR)).
LOCK reqHeadingVec TO projectToPlane((targPos - SHIP:POSITION), UP:VECTOR).
//LOCK STEERING TO reqHeadingVec*ANGLEAXIS(reqPitch, VCRS(reqHeadingVec, UP:VECTOR)).


UNTIL(FALSE){
	//SET PID:SETPOINT TO (90 - VANG((targPos - SHIP:POSITION), UP:VECTOR)).
	
	SET VD TO VECDRAWARGS(SHIP:POSITION, (targPos - SHIP:POSITION), RED, "Dir vec", 1, TRUE).
	SET SV TO VECDRAWARGS(SHIP:POSITION, reqHeadingVec*ANGLEAXIS(reqPitch, VCRS(reqHeadingVec, UP:VECTOR)), YELLOW, "Steer vec", 1, TRUE).
	
	SET PV TO VECDRAWARGS(posQueue:PEEK():POSITION, (posQueue:PEEK():ALTITUDEPOSITION(altQueue:PEEK()) - posQueue:PEEK():POSITION):NORMALIZED*altQueue:PEEK(), WHITE, "", 1, TRUE, 20).
	
	PRINT("Cur pitch: " + (90 - VANG(SHIP:FACING:VECTOR, UP:VECTOR))).
	PRINT("Dir pitch: " + (90 - VANG((targPos - SHIP:POSITION), UP:VECTOR))).
	PRINT("Try pitch: " + reqPitch).
	
	LOCK steerVec TO reqHeadingVec*ANGLEAXIS(reqPitch, VCRS(reqHeadingVec, UP:VECTOR)).
	LOCK upHead TO projectToPlane(-SHIP:FACING:VECTOR, steerVec).
	
	SET HV TO VECDRAWARGS(SHIP:POSITION, upHead:NORMALIZED*50, BLUE, "Top vec", 1, TRUE).
	
	LOCK STEERING TO LOOKDIRUP(steerVec, getHeadVec()).
	
	IF(VANG(SHIP:FACING:VECTOR, steerVec) < 20){
		LOCK THROTTLE TO 0.8.
	}
	ELSE{ LOCK THROTTLE TO 0.30. }
	
	IF((targPos - SHIP:POSITION):MAG < 300){
		posQueue:PUSH(posQueue:POP()).
		altQueue:PUSH(altQueue:POP()).
		PID:RESET().
	}
	
	//IF(AG1){
	//	AG1 OFF.
	//	SET STEERINGMANAGER:PITCHTORQUEFACTOR TO STEERINGMANAGER:PITCHTORQUEFACTOR + 0.1.
	//}
	//IF(AG2){
	//	AG2 OFF.
	//	SET STEERINGMANAGER:PITCHTORQUEFACTOR TO STEERINGMANAGER:PITCHTORQUEFACTOR - 0.1.
	//}
	//PRINT("PTF: " + STEERINGMANAGER:PITCHTORQUEFACTOR).
	
	WAIT 0.01.
	CLEARSCREEN.
}




FUNCTION getHeadVec{
	SET headVec TO projectToPlane(-SHIP:FACING:VECTOR, steerVec).
	SET refVec TO SHIP:FACING:TOPVECTOR.
		IF(VANG(SHIP:FACING:VECTOR, steerVec) < 5){ SET refVec TO UP:VECTOR. } //If less than 5 degrees from desired heading vector, prefer upwards facing orientation
		
	IF(VANG(headVec, refVec) > 90) { RETURN -headVec. }
	ELSE{ RETURN headVec. }
}

//iF GREATER THAN 10 DEGREES, whichever is closest rot
//If less than 10 degrees, upwards





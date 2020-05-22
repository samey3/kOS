	CLEARSCREEN.
	

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _flyLocation.
	PARAMETER _flyAltitude.
	PARAMETER _flySpeed.
	PARAMETER _maxError.
	PARAMETER _landing IS FALSE.
	
	
//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/


	RUNONCEPATH("lib/eventListener.ks").
	//RUNONCEPATH("lib/gameControl.ks").
	RUNONCEPATH("lib/math.ks").	


//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/	
	
	
	//Steering PID
	//LOCAL Sp IS 1.5.
	//LOCAL Sd IS 0.04.
	//LOCAL Si IS 0.07.
	LOCAL Sp IS 5.
	LOCAL Sd IS 0.04.
	LOCAL Si IS 0.07.	//This seems to build up over time on long turns, and then overshoots
	LOCAL steerPID IS PIDLOOP(Sp, Si, Sd).
		SET steerPID:SETPOINT TO 0.
		SET steerPID:MAXOUTPUT TO (CHOOSE 89.9 IF _landing = FALSE ELSE 45).
		SET steerPID:MINOUTPUT TO -89.9.
		
	//Speed PID
	LOCAL Tp IS 0.5.
	LOCAL Td IS 1.
	LOCAL Ti IS 0.00.	
	LOCAL throttlePID IS PIDLOOP(Tp, Ti, Td).
		SET throttlePID:SETPOINT TO _flySpeed.
		SET throttlePID:MAXOUTPUT TO (CHOOSE 1 IF NOT _flySpeed = 0 ELSE 0).
		SET throttlePID:MINOUTPUT TO 0.
		
	//The target point to fly to
	LOCK targetPoint TO _flyLocation:ALTITUDEPOSITION(_flyAltitude).
	
	//Pitch, heading, and steering
	LOCK reqPitch TO steerPID:UPDATE(TIME:SECONDS, VANG((targetPoint - SHIP:POSITION), UP:VECTOR) - VANG(SHIP:VELOCITY:SURFACE, UP:VECTOR)).
	LOCK reqHeadingVec TO projectToPlane((targetPoint - SHIP:POSITION), UP:VECTOR).
	LOCK steerVec TO reqHeadingVec*ANGLEAXIS(reqPitch, VCRS(reqHeadingVec, UP:VECTOR)).
	
	//Throttle
	//LOCK reqThrottle TO throttlePID:UPDATE(TIME:SECONDS, GROUNDSPEED).
	LOCK reqThrottle TO throttlePID:UPDATE(TIME:SECONDS, SHIP:VELOCITY:SURFACE:MAG).
	//LOCK BRAKES TO (GROUNDSPEED > _flySpeed).
	LOCK BRAKES TO (SHIP:VELOCITY:SURFACE:MAG > _flySpeed).
		

//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/
		
	STEERINGMANAGER:RESETPIDS().	
	//SET STEERINGMANAGER:PITCHPID:KI TO 0.	
	//SET STEERINGMANAGER:YAWPID:KI TO 0.	
	//SET STEERINGMANAGER:ROLLPID:KI TO 0.
	SET STEERINGMANAGER:ROLLPID:KD TO 0.1.
		
	//Lock the steering and throttle
	LOCK STEERING TO LOOKDIRUP(steerVec, getRoofVec()).
	LOCK THROTTLE TO reqThrottle.
	
	UNTIL((SHIP:POSITION - targetPoint):MAG < _maxError OR (_landing = TRUE AND SHIP:STATUS = "LANDED")){
		//Draw the vectors
		SET VD TO VECDRAWARGS(SHIP:POSITION, (targetPoint - SHIP:POSITION), RED, "Dir vec", 1, TRUE).
		SET SV TO VECDRAWARGS(SHIP:POSITION, (reqHeadingVec*ANGLEAXIS(reqPitch, VCRS(reqHeadingVec, UP:VECTOR))):NORMALIZED*20, YELLOW, "Steer vec", 1, TRUE).
		SET PV TO VECDRAWARGS(_flyLocation:POSITION, (_flyLocation:ALTITUDEPOSITION(_flyAltitude) - _flyLocation:POSITION):NORMALIZED*_flyAltitude, WHITE, "", 1, TRUE, 20).
		
		PRINT("Cur pitch: " + (90 - VANG(SHIP:FACING:VECTOR, UP:VECTOR))).
		PRINT("Dir pitch: " + (90 - VANG((targetPoint - SHIP:POSITION), UP:VECTOR))).
		PRINT("Try pitch: " + reqPitch).
		
		IF(AG1){
			AG1 OFF.
			configureVessel("F22-Flight").
		}
		
		WAIT 0.01.
		CLEARSCREEN.
	}
		

//--------------------------------------------------------------------------\
//								Program end					   				|
//--------------------------------------------------------------------------/

	
	//UNLOCK targetPoint.
	//UNLOCK reqPitch.
	//UNLOCK reqHeadingVec.
	//UNLOCK steerVec.

	
//--------------------------------------------------------------------------\
//								Functions					   				|
//--------------------------------------------------------------------------/


	//Used to get the top-vector for steering using LOOKDIRUP
	FUNCTION getRoofVec{
		//IF(_landing = TRUE){
		//	SET HV TO VECDRAWARGS(SHIP:POSITION, projectToPlane(UP:VECTOR, steerVec):NORMALIZED*15, GREEN, "", 1, TRUE).
		//	RETURN projectToPlane(UP:VECTOR, steerVec).
		//}
		LOCAL minVal IS 3.
	
		LOCAL refVec IS (CHOOSE UP:VECTOR IF (VANG(SHIP:FACING:VECTOR, steerVec) < 5) ELSE SHIP:FACING:TOPVECTOR). //If less than 5 degrees from desired heading vector, prefer upwards facing orientation
		LOCAL faceVec IS projectToPlane(-SHIP:FACING:VECTOR, steerVec).
			
		//IF(VANG(SHIP:FACING:VECTOR, steerVec) < 5){ RETURN UP:VECTOR. }
		//IF(VANG(SHIP:FACING:VECTOR, steerVec) < 5){ RETURN SHIP:FACING:TOPVECTOR. }
		//ELSE IF(VANG(faceVec, refVec) > 90) { RETURN -faceVec. }		
		//ELSE{ RETURN faceVec. }
		
		IF(_landing = TRUE){
			SET refVec TO UP:VECTOR.
			SET minVal TO 1.
		}
		
		IF(_landing = FALSE){
			IF(VANG(SHIP:FACING:VECTOR, steerVec) < minVal){ SET HV TO VECDRAWARGS(SHIP:POSITION, SHIP:FACING:TOPVECTOR:NORMALIZED*15, GREEN, "HV", 1, TRUE). RETURN SHIP:FACING:TOPVECTOR. }
			ELSE IF(VANG(faceVec, refVec) > 90) { SET HV TO VECDRAWARGS(SHIP:POSITION, -faceVec:NORMALIZED*15, WHITE, "HV", 1, TRUE). RETURN -faceVec. }		
			ELSE{ SET HV TO VECDRAWARGS(SHIP:POSITION, faceVec:NORMALIZED*15, BLUE, "HV", 1, TRUE). RETURN faceVec. }
		}
		ELSE{
			LOCAL HVec IS -projectToPlane(SHIP:VELOCITY:SURFACE, steerVec):NORMALIZED.
			IF(VANG(HVec, UP:VECTOR) > 90){
				SET HVec TO HVec - 2*UP:VECTOR*(HVec*UP:VECTOR).
			}
			
			//Now remove half of its 'horizontal' length to halve the roll amount (unless inverted)
			LOCAL crossVec IS VCRS(SHIP:FACING:TOPVECTOR, steerVec).
			IF(VANG(SHIP:FACING:TOPVECTOR, UP:VECTOR) < 60){
				//SET HVec TO HVec - 0.5*crossVec*(HVec*crossVec).
			}
			
			IF(VANG(SHIP:FACING:VECTOR, steerVec) < minVal){ SET HV TO VECDRAWARGS(SHIP:POSITION, SHIP:FACING:TOPVECTOR:NORMALIZED*15, GREEN, "HV", 1, TRUE). RETURN SHIP:FACING:TOPVECTOR. }
			ELSE { SET HV TO VECDRAWARGS(SHIP:POSITION, HVec:NORMALIZED*15, WHITE, "HV", 1, TRUE). RETURN HVec. }
		}		
	}

	//Evaluates the PID to maintain a set speed
	FUNCTION getThrottle {
		IF(VANG(SHIP:FACING:VECTOR, steerVec) < 20){ RETURN 1. }
		ELSE{ RETURN 0.50. }
	}

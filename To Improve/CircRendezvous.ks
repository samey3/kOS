CLEARSCREEN.

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _TC_Param IS 0. 
	IF _TC_Param <> 0 {
		SET _targetCraft TO _TC_Param.
	}
	ELSE IF _TC_Param = 0 AND HASTARGET = True {
		SET _targetCraft TO TARGET.
	}
	ELSE {
		PRINT "No target is selected.".
		PRINT "Shutting down . . .".
		SHUTDOWN.
	}

	
	//Add check for if the apo and peri are not the same, and a correction
	
	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/
	
	
	//Negative is ahead CCW (Longitude wise, not necessairily velocity. Add a multiplier of -1 incase retrograde orbit?)	
	LOCAL sepAngle IS addLongitude(SHIP:GEOPOSITION:LNG, -_targetCraft:GEOPOSITION:LNG).	
	IF sepAngle < 0 {
		SET sepAngle TO (sepAngle + 360) * 2*CONSTANT():PI / 360. //Accounts for the negative and switches to radians
	}
	ELSE{
		SET sepAngle TO sepAngle * 2*CONSTANT():PI / 360. //Switches to radians
	}
	
	LOCAL orbitAngularVelocity IS 2*CONSTANT():PI/_targetCraft:ORBIT:PERIOD.
	LOCAL reqPeriod IS (sepAngle / orbitAngularVelocity) + _targetCraft:ORBIT:PERIOD.
		
	LOCAL req_periapsis IS PERIAPSIS + SHIP:BODY:RADIUS.
	LOCAL req_apoapsis IS 2*(((reqPeriod / (2*CONSTANT():PI))^2 * SHIP:BODY:MU)^(1/3)) - req_periapsis.	
	LOCAL req_SMA IS (req_apoapsis + req_periapsis)/2.	
	LOCAL req_eccentricity IS (req_apoapsis - req_periapsis) / (req_apoapsis + req_periapsis).
	LOCAL req_apoapsisVelocity IS SQRT(((1 - req_eccentricity) / (1 + req_eccentricity)) * (SHIP:BODY:MU / req_SMA)).
	
	LOCAL req_periapsisVelocity IS SQRT(((1 + req_eccentricity) / (1 - req_eccentricity)) * (SHIP:BODY:MU / req_SMA)).	
	LOCAL periapsis_baseVelocity IS VELOCITYAT(SHIP,TIME:SECONDS + ETA:PERIAPSIS):ORBIT:MAG.
	
	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/
	
	//Initial circular rendezvous
	RUN nodeBurn(ETA:PERIAPSIS, req_periapsisVelocity - periapsis_baseVelocity, 1). 
	
	WAIT 1.
	KUNIVERSE:TIMEWARP:WARPTO(TIME:SECONDS + ETA:APOAPSIS).
	WAIT ETA:APOAPSIS.
	
	WAIT UNTIL WARP = 0 and SHIP:UNPACKED.
	WAIT 2.

	RUN nodeBurn(ETA:PERIAPSIS, req_periapsisVelocity - periapsis_baseVelocity, 2).

	//Linear rendezvous
	IF((SHIP:POSITION - _targetCraft:POSITION):MAG > 200){
		LOCK targetVector TO (_targetCraft:POSITION - SHIP:POSITION).
		LOCK relative_Velocity_Vector TO (SHIP:VELOCITY:ORBIT - _targetCraft:VELOCITY:ORBIT).
		
		RUN nodeBurn(20, relative_Velocity_Vector:MAG, -relative_Velocity_Vector). //Cancels current velocity
		
		//WAIT UNTIL ag1.
				
		RUN nodeBurn(20, (targetVector:MAG - 200)/250, targetVector). //Boosts towards target
		
		//Calculates distance needed to stop 200 meters from target
		SET base_acceleration TO SHIP:AVAILABLETHRUST / SHIP:MASS. //Mass in metric tonnes
		SET relative_Velocity_Vector TO (SHIP:VELOCITY:ORBIT - _targetCraft:VELOCITY:ORBIT).
		SET thrust_time TO (relative_Velocity_Vector:MAG / base_acceleration).
		SET distance_start TO (relative_Velocity_Vector:MAG*thrust_time + 0.5*base_acceleration*thrust_time^2).		
		SET timeStart TO ((targetVector:MAG - distance_start) / relative_Velocity_Vector:MAG).
		
		RUN nodeBurn(timeStart, relative_Velocity_Vector:MAG, -relative_Velocity_Vector). //Deceleration burn
	}


//------------------------------------------------------------------------------------------------------\
//												FUNCTIONS												|
//------------------------------------------------------------------------------------------------------/


//______________________________________________________________
//							Smooth rotation						|
//______________________________________________________________|


FUNCTION smoothRotate {
    PARAMETER dir.
    LOCAL spd IS max(SHIP:ANGULARMOMENTUM:MAG/10,4).
    LOCAL curF IS SHIP:FACING:FOREVECTOR.
    LOCAL curR IS SHIP:FACING:TOPVECTOR.
    LOCAL rotR IS R(0,0,0).
    IF VANG(dir:FOREVECTOR,curF) < 90{SET rotR TO ANGLEAXIS(min(0.5,VANG(dir:TOPVECTOR,curR)/spd),VCRS(curR,dir:TOPVECTOR)).}
    RETURN LOOKDIRUP(ANGLEAXIS(min(2,VANG(dir:FOREVECTOR,curF)/spd),VCRS(curF,dir:FOREVECTOR))*curF,rotR*curR).
}


//______________________________________________________________
//							Add longitudes						|
//______________________________________________________________|


FUNCTION addLongitude {
	PARAMETER longitude.
	PARAMETER angle.
	
	LOCAL longNew IS longitude + angle.
	IF longNew > 180 {
		UNTIL longNew < 0 {
			SET longNew TO longNew - 180.
		}
	}	
	ELSE IF longNew < -180 {
		UNTIL longNew > 0 {
			SET longNew TO longNew + 180.
		}
	}
	RETURN longNew.
}
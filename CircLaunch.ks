CLEARSCREEN.


//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


PARAMETER targetCraft IS selectEntity("ORBITING").


//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/


LOCAL targetAltitude IS targetCraft:PERIAPSIS.
LOCAL targetInclination IS 90.


//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


//--------------------------------------------------------\\
//						Launch sequence					  ||
//--------------------------------------------------------//


	PRINT "Launch sequence:".
	FROM {local countdown is 3.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
		PRINT countdown.
		WAIT 1. // pauses the script here for 1 second.
	}

	LOCK STEERING TO smoothRotate(up).
	STAGE.
	PRINT "Liftoff".
	LOCK THROTTLE TO 1.
	
	
//--------------------------------------------------------\\
//						Gravity turn					  ||				
//--------------------------------------------------------//


	LOCK shipAltitude TO SHIP:ALTITUDE - SHIP:GEOPOSITION:TERRAINHEIGHT.
	LOCK Ag TO (SHIP:BODY:MU / (shipAltitude + SHIP:BODY:RADIUS)^2).
	LOCK Fg TO Ag*SHIP:MASS.


	WAIT UNTIL verticalspeed > 40.
		CLEARSCREEN.
		GEAR OFF.
		PRINT "Commencing gravity turn.".	
	
	LOCK THROTTLE TO 1.
	UNTIL (apoapsis/targetAltitude) >= 1 { //apoapsis >= targetAltitude. Its in this form to prevent a NaN error due to negative square rooting
		IF (apoapsis/targetAltitude - 0.95) >= 0  AND (apoapsis/targetAltitude) < 0.99 { //Was 1 - apo/targ > 0) as well?
			CLEARSCREEN.
			WAIT 0.1.
			LOCK THROTTLE TO (Fg / (SHIP:AVAILABLETHRUST / SHIP:MASS) * ((40 * (1 - apoapsis/targetAltitude))^0.5 / 1.4142 * 3)) + 0.01. //+1% throttle
		}
		ELSE
		{		 
			LOCK THROTTLE TO (Fg / (SHIP:AVAILABLETHRUST / SHIP:MASS) * 3).	
		}		

		LOCK STEERING TO smoothRotate(HEADING(targetInclination,90 - 77*(apoapsis/targetAltitude))). //    The rocket can turn 77/90 of the full way
	}
	LOCK THROTTLE TO 0.
	LOCK STEERING TO smoothRotate(PROGRADE).
	WAIT 1.
	
//--------------------------------------------------------\\
//						Circularization					  ||				
//--------------------------------------------------------//

	//This completes the orbit
	//WAIT UNTIL ETA:APOAPSIS < 40.
		LOCAL burnAmount IS VELOCITYAT(targetCraft,TIME:SECONDS + ETA:APOAPSIS):ORBIT:MAG - VELOCITYAT(SHIP,TIME:SECONDS + ETA:APOAPSIS):ORBIT:MAG.
		LOCAL burnTime IS burnAmount / (SHIP:AVAILABLETHRUST / SHIP:MASS).
		RUN nodeBurn(ETA:APOAPSIS + (burnTime / 2),burnAmount, 1).
		
	//WAIT UNTIL ETA:PERIAPSIS < 40.
		SET req_periapsis TO (PERIAPSIS + SHIP:BODY:RADIUS).
		SET req_apoapsis TO (targetCraft:APOAPSIS + SHIP:BODY:RADIUS).
		SET req_SMA TO (req_apoapsis + req_periapsis)/2.	
		SET req_eccentricity TO (req_apoapsis - req_periapsis) / (req_apoapsis + req_periapsis).	
		SET req_periapsisVelocity TO SQRT(((1 + req_eccentricity) / (1 - req_eccentricity)) * (SHIP:BODY:MU / req_SMA)).
	
		LOCAL burnAmount IS req_periapsisVelocity - VELOCITYAT(SHIP,TIME:SECONDS + ETA:PERIAPSIS):ORBIT:MAG.
		LOCAL burnTime IS burnAmount / (SHIP:AVAILABLETHRUST / SHIP:MASS).
		IF (burnAmount > 0){
			RUN nodeBurn(ETA:PERIAPSIS,burnAmount, 1).
		}
		ELSE {
			RUN nodeBurn(ETA:PERIAPSIS,-burnAmount, 2).
		}
		
	//WAIT UNTIL ETA:APOAPSIS < 40.
		SET req_periapsis TO (targetCraft:PERIAPSIS + SHIP:BODY:RADIUS).
		SET req_apoapsis TO (APOAPSIS + SHIP:BODY:RADIUS).
		SET req_SMA TO (req_apoapsis + req_periapsis)/2.	
		SET req_eccentricity TO (req_apoapsis - req_periapsis) / (req_apoapsis + req_periapsis).	
		SET req_apoapsisVelocity TO SQRT(((1 - req_eccentricity) / (1 + req_eccentricity)) * (SHIP:BODY:MU / req_SMA)).	
	
		LOCAL burnAmount IS req_apoapsisVelocity - VELOCITYAT(SHIP,TIME:SECONDS + ETA:APOAPSIS):ORBIT:MAG.
		LOCAL burnTime IS burnAmount / (SHIP:AVAILABLETHRUST / SHIP:MASS).
		IF (burnAmount > 0){
			RUN nodeBurn(ETA:APOAPSIS,burnAmount, 1).
		}
		ELSE {
			RUN nodeBurn(ETA:APOAPSIS,-burnAmount, 2).
		}
		
		//SET req_apoapsisVelocity TO SQRT(((1 - req_eccentricity) / (1 + req_eccentricity)) * (SHIP:BODY:MU / req_SMA)).	
//------------------------------------------------------------------------------------------------------\
//												FUNCTIONS												|
//------------------------------------------------------------------------------------------------------/


//Vector heading smoother
FUNCTION smoothRotate {
    PARAMETER dir.
    LOCAL spd IS max(SHIP:ANGULARMOMENTUM:MAG/10,4).
    LOCAL curF IS SHIP:FACING:FOREVECTOR.
    LOCAL curR IS SHIP:FACING:TOPVECTOR.
    LOCAL rotR IS R(0,0,0).
    IF VANG(dir:FOREVECTOR,curF) < 90{SET rotR TO ANGLEAXIS(min(0.5,VANG(dir:TOPVECTOR,curR)/spd),VCRS(curR,dir:TOPVECTOR)).}
    RETURN LOOKDIRUP(ANGLEAXIS(min(2,VANG(dir:FOREVECTOR,curF)/spd),VCRS(curF,dir:FOREVECTOR))*curF,rotR*curR).
}



FUNCTION selectEntity {
	PARAMETER entLocatation IS "LANDED".
	SET entities TO LIST().
	
	LIST TARGETS IN entityList.
		FOR ENTITY IN entityList
		{										
			IF SHIP:BODY:NAME = ENTITY:BODY:NAME AND (ENTITY:STATUS = entLocatation){
				entities:ADD(ENTITY).
			}
		}
	

	LOCAL listIndex IS 0.
	LOCAL chosen IS "False".
	
	ag1 OFF.
	ag2 OFF.
	ag3 OFF.
	
	UNTIL chosen = True {
		PRINT "Select a " + entLocatation + " entity.".
		PRINT "Use action group 1 to move up the list.".
		PRINT "Use action group 2 to move down the list.".
		PRINT "Use action group 3 to confirm target".
		PRINT " ".
		PRINT entities.
		PRINT " ".
		PRINT "Target entity: [" + listIndex + "] " + entities[listIndex].
		
		WAIT UNTIL ag1 = "True" OR ag2 = "True" OR ag3 = "True".	
			IF ag1 = "True" AND listIndex > 0{ 
				SET listIndex TO listIndex - 1. 
			}
			IF ag2 = "True" AND listIndex < (entities:LENGTH - 1){ 
				SET listIndex TO listIndex + 1.
			}
			IF ag3 = "True" { 
				SET chosen TO True. 
			}
			
			CLEARSCREEN.
			
			ag1 OFF.
			ag2 OFF.
			ag3 OFF.
	}	
	
	RETURN entities[listIndex].
}

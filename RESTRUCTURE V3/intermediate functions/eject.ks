	@lazyglobal OFF.
	CLEARSCREEN.
	

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _body.

	
//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/
	
	
	RUNONCEPATH("RESTRUCTURE V3/lib/gameControl.ks").
	RUNONCEPATH("RESTRUCTURE V3/lib/orbitProperties.ks").
	
	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	//Don't forget to recreate this reject of an ejector.
	//Can rework missionBuilder to also peek the next. Can use Lambert solver to find the required ejection velocity.
	//CAN MAKE IT SOMEWHAT BAD AND JUST USE EXECUTE NODE TO GO DIRECTLY ONTO THAT TRAJECTORY.
	
	//----------------------------------------------------\
	//Set the required ejection velocity---------------------|	
		LOCAL maneuverTime IS TIME:SECONDS + ETA:PERIAPSIS.		
		LOCAL speed IS 1.10*SQRT(2*SHIP:BODY:MU/(SHIP:ORBIT:PERIAPSIS + SHIP:BODY:RADIUS)).
		LOCAL r_velocity IS speed*VELOCITYAT(SHIP, maneuverTime):ORBIT:NORMALIZED.
		
	//Perform the burn
		LOCAL resNode IS nodeFromDesiredVector(maneuverTime, r_velocity).
		RUNPATH("RESTRUCTURE V3/basic functions/executeNode.ks", resNode).
		
	//Warps to the ejection
		IF(SHIP:ORBIT:HASNEXTPATCH){
			warpTime(SHIP:ORBIT:NEXTPATCHETA + 30).
		}
	
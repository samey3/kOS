	@lazyglobal OFF.
	CLEARSCREEN.
	

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _body.

	
//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/
	
	
	RUNONCEPATH("lib/gameControl.ks").
	RUNONCEPATH("lib/orbitProperties.ks").
	
	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	//----------------------------------------------------\
	//Set the required ejection velocity------------------|	
		LOCAL maneuverTime IS TIME:SECONDS + ETA:PERIAPSIS.		
		LOCAL speed IS 1.10*SQRT(2*SHIP:BODY:MU/(SHIP:ORBIT:PERIAPSIS + SHIP:BODY:RADIUS)).
		LOCAL r_velocity IS speed*VELOCITYAT(SHIP, maneuverTime):ORBIT:NORMALIZED.
		
	//Perform the burn
		LOCAL resNode IS nodeFromDesiredVector(maneuverTime, r_velocity).
		RUNPATH("mission operations/basic functions/executeNode.ks", resNode).
		
	//Warps to the ejection
		IF(SHIP:ORBIT:HASNEXTPATCH){
			warpTime(TIME:SECONDS + SHIP:ORBIT:NEXTPATCHETA + 30).
		}
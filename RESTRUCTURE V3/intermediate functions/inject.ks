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


	//----------------------------------------------------\
	//Perform the intercept burn--------------------------|	
		RUNPATH("RESTRUCTURE V3/intermediate functions/refineOrbit.ks", _body, 1).
	
	//----------------------------------------------------\
	//Warp to the intercept-------------------------------|	
		//How to get it to look further ahead? It has an intercept, but too far back to show. Patches?
		//IF(SHIP:ORBIT:HASNEXTPATCH){
		//	warpTime(SHIP:ORBIT:NEXTPATCHETA + 30).
		//}
		//ELSE {
			//Warp to the next closest
			//warpTime(MIN(ETA:PERIAPSIS, ETA:APOAPSIS) + 5).
			//Attempt to warp to patch again
			//IF(SHIP:ORBIT:HASNEXTPATCH){
			//	warpTime(SHIP:ORBIT:NEXTPATCHETA + 30).
			//}
			//ELSE {
			//	PRINT("Error in injection.").
			//	REBOOT.
			//}
		//}
		
		UNTIL (SHIP:ORBIT:HASNEXTPATCH){
			RUNPATH("RESTRUCTURE V3/intermediate functions/refineOrbit.ks", _body, 1).
		}
		warpTime(SHIP:ORBIT:NEXTPATCHETA + 30).
	
	//----------------------------------------------------\
	//Set the required entry velocity---------------------|	
		LOCAL maneuverTime IS TIME:SECONDS + 180. //3 minutes into the SOI
	
		//Get the position and planar velocity at the time
			LOCAL s_pos IS (POSITIONAT(SHIP, maneuverTime) - SHIP:BODY:POSITION). //POSITIONAT(SHIP:BODY, maneuverTime)).
			LOCAL s_planarVel IS projectToPlane(VELOCITYAT(SHIP, maneuverTime):ORBIT, s_pos).
		
		//Get the required velocity of the vessel at that time
			LOCAL r_apoapsis IS s_pos:MAG.
			LOCAL r_periapsis IS SHIP:BODY:RADIUS + 20000.
			IF(SHIP:BODY:ATM:EXISTS){
				SET r_periapsis TO r_periapsis + SHIP:BODY:ATM:HEIGHT*2.
			}
			
			LOCAL sma IS (r_periapsis + r_apoapsis)/2.		
			LOCAL speed IS SQRT(SHIP:BODY:MU*(2/r_apoapsis - 1/sma)).
	
		//Get the resultant vector
			LOCAL r_velocity IS speed*s_planarVel:NORMALIZED.

		//Perform the burn
			LOCAL resNode IS nodeFromDesiredVector(maneuverTime, r_velocity).
			RUNPATH("RESTRUCTURE V3/basic functions/executeNode.ks", resNode).
	@lazyglobal OFF.
	CLEARSCREEN.
	

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _currentBody.
	PARAMETER _targetBody.

	
//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/
	
	
	RUNONCEPATH("lib/gameControl.ks"). //Warp
	//RUNONCEPATH("lib/orbitProperties.ks"). //Node from vector
	RUNONCEPATH("lib/lambert.ks").
	
	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	LOCAL res IS LEXICON().
	SET res TO getInterceptNode(_currentBody, _targetBody).

	//Convert node to vector
	//Record the time in another variable for later?
	
	//LOCAL ejectionVector IS finalVectorFromNode(res). //reqs orbit properties
	//Can also get the change vector
	
	
	//Use this vector in finding ejection.
	//Base timing 1/2 period before to 1/2 period after time given by node.
	
	
	
	//nodeFromVector(res["t"], res["dv1"]). //Returns a maneuver node at this time
	//nodeFromVector(res["t"] + res["dt"], res["dv2"]). //Second, completion maneuver
	
	//Executes the node
	//RUNPATH("mission operations/basic functions/executeNode.ks", NODE(res["t"], res["radial"], res["normal"], res["prograde"])).	
	
	
	//----------------------------------------------------\
	//Set the required ejection velocity------------------|	
	//	LOCAL maneuverTime IS TIME:SECONDS + ETA:PERIAPSIS.		
	//	LOCAL speed IS 1.10*SQRT(2*SHIP:BODY:MU/(SHIP:ORBIT:PERIAPSIS + SHIP:BODY:RADIUS)).
	//	LOCAL r_velocity IS speed*VELOCITYAT(SHIP, maneuverTime):ORBIT:NORMALIZED.
	//	
	//Perform the burn
	//	LOCAL resNode IS nodeFromDesiredVector(maneuverTime, r_velocity).
	//	RUNPATH("mission operations/basic functions/executeNode.ks", resNode).
	//	
	//Warps to the ejection
	//	IF(SHIP:ORBIT:HASNEXTPATCH){
	//		warpTime(TIME:SECONDS + SHIP:ORBIT:NEXTPATCHETA + 30).
	//	}
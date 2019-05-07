@lazyglobal OFF.
RUNONCEPATH("lib/config.ks").
RUNONCEPATH("lib/gameControl.ks").
RUNONCEPATH("lib/lambert.ks").
RUNONCEPATH("lib/math.ks").

CLEARSCREEN.
LOCK STEERING TO SHIP:FACING.
LOCK THROTTLE TO 0.
UNLOCK STEERING.
UNLOCK THROTTLE.

//configureVessel().

LOCAL orbitLex IS LEXICON().
	SET orbitLex["semimajoraxis"] TO 1686750.
	SET orbitLex["eccentricity"] TO 0.60.
	SET orbitLex["inclination"] TO 10.
	SET orbitLex["longitudeofascendingnode"] TO 30.
	SET orbitLex["argumentofperiapsis"] TO 20.
	SET orbitLex["trueanomaly"] TO 60.
	
	

//RUNPATH("mission operations/missionBuilder.ks", SHIP:BODY, "land", 0, 0).
//RUNPATH("mission operations/missionBuilder.ks", SHIP:BODY, "land", LATLNG(20.5829, -146.5116), 0).
//RUNPATH("mission operations/missionBuilder.ks", SHIP:BODY, "orbit", 0, orbitLex).
//RUNPATH("mission operations/missionBuilder.ks", MINMUS, "orbit", 0, orbitLex).
//RUNPATH("mission operations/missionBuilder.ks", MOHO, "orbit", 0, orbitLex).
//RUNPATH("mission operations/missionBuilder.ks"). //No parameters given, serves selection-GUI instead

//RUNPATH("mission operations/missionBuilder.ks", MOHO, "orbit", 0, orbitLex).
//RUNPATH("mission operations/missionBuilder.ks", MOHO, "orbit", 0, orbitLex).
//RUNPATH("mission operations/missionBuilder.ks", MOHO, "orbit", 0, orbitLex).
//RUNPATH("mission operations/missionBuilder.ks", MOHO, "orbit", 0, orbitLex).



//Make sure the warp stuff is working



//PRINT ("Show : " + tester:MU).
//PRINT ("Show : " + tester:TYPE).

//RUNONCEPATH("lib/impactProperties.ks").
//LOCAL CdTimesA IS 26.

//LOCAL pred_vec IS 0.
//LOCAL traj_vec IS 0.

//UNTIL FALSE{
//	LOCAL testPred IS testPredict(CdTimesA, SHIP:GEOPOSITION:TERRAINHEIGHT, SHIP):POSITION.
//	SET pred_vec TO VECDRAWARGS(SHIP:POSITION, testPred, RED, "Predicted", 1, TRUE).
//
//	LOCAL trajPred IS getImpactCoords(SHIP:GEOPOSITION:TERRAINHEIGHT):POSITION.
//	SET traj_vec TO VECDRAWARGS(SHIP:POSITION, trajPred, YELLOW, "Trajectories", 1, TRUE).
//}



IF(1 = 0){
	SET orbitLex["semimajoraxis"] TO TARGET:ORBIT:SEMIMAJORAXIS.
	SET orbitLex["eccentricity"] TO TARGET:ORBIT:ECCENTRICITY.
	SET orbitLex["inclination"] TO TARGET:ORBIT:INCLINATION.
	SET orbitLex["longitudeofascendingnode"] TO TARGET:ORBIT:LONGITUDEOFASCENDINGNODE.
	SET orbitLex["argumentofperiapsis"] TO TARGET:ORBIT:ARGUMENTOFPERIAPSIS.
	SET orbitLex["trueanomaly"] TO 60.

	
	RUNONCEPATH("lib/lambert.ks").
	RUNONCEPATH("lib/orbitProperties.ks").
	LOCAL res IS getTransferNode(SHIP, orbitLex).
	//LOCAL res IS getInterceptNode(SHIP, MUN).
	PRINT res.

	//LOCAL one IS nodeFromVector(res["t"], res["dv1"]).
	//LOCAL two IS nodeFromVector(res["t"] + res["dt"], res["dv2"]).

	//PRINT("One : " + one).
	//PRINT("Two : " + two).

	RUNPATH("mission operations/basic functions/executeNode.ks", NODE(res["t"], res["radial_1"], res["normal_1"], res["prograde_1"])).
	RUNPATH("mission operations/basic functions/executeNode.ks", NODE(res["t"] + res["dt"], res["radial_2"], res["normal_2"], res["prograde_2"])).

	//RUNPATH("mission operations/basic functions/executeNode.ks", one).
	//RUNPATH("mission operations/basic functions/executeNode.ks", two).
		//RUNPATH("mission operations/basic functions/executeNode.ks", NODE(res["t"], res["radial"], res["normal"], res["prograde"])).

}







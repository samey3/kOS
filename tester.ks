@lazyglobal OFF.
RUNONCEPATH("RESTRUCTURE V3/lib/config.ks").
RUNONCEPATH("RESTRUCTURE V3/lib/gameControl.ks").
RUNONCEPATH("RESTRUCTURE V3/lib/lambert.ks").
RUNONCEPATH("RESTRUCTURE V3/lib/math.ks").

CLEARSCREEN.
LOCK STEERING TO SHIP:FACING.
LOCK THROTTLE TO 0.
UNLOCK STEERING.
UNLOCK THROTTLE.

configureVessel().
//RUNONCEPATH("Land.ks", 0). //LATLNG(-0.0972078366335618,-74.5576783933035)



//PRINT("Select a target to intercept").
//WAIT UNTIL(HASTARGET).
//	LOCAL res IS getInterceptNode(SHIP, TARGET, TRUE, TRUE, TIME:SECONDS).
//	PRINT("Time to burn : " + res["t"]).
//	PRINT("Radial : " + res["radial"]).
//	PRINT("Normal : " + res["normal"]).
//	PRINT("Prograde : " + res["prograde"]).

//LOCAL res IS getTransferNode(138037287.2, 0.96080697440296, 35.149, 32.582735, 49.72152, 78.57519).
//LOCAL res IS getTransferNode(13803728.2, 0.96080697440296, 35.149, 32.582735, 49.72152, 78.57519).
//RUNPATH ("basic_functions/executeNode.ks", NODE(res["t"], res["radial"], res["normal"], res["prograde"])).
//WAIT 1.
//warpTime(res["dt"] - 1).
//dt is the time to the intercept




LOCAL orbitLex IS LEXICON().
	SET orbitLex["semimajoraxis"] TO 1686750.
	SET orbitLex["eccentricity"] TO 0.60.
	SET orbitLex["inclination"] TO 10.
	SET orbitLex["longitudeofascendingnode"] TO 30.
	SET orbitLex["argumentofperiapsis"] TO 20.
	SET orbitLex["trueanomaly"] TO RANDOM(). //Random point away from 0.

//RUNPATH("RESTRUCTURE V3/missionBuilder.ks", kerbin, "land", LATLNG(-0.0972078366335618,-74.5576783933035), orbitLex).
//RUNPATH("RESTRUCTURE V3/missionBuilder.ks", kerbin, "orbit", 0, orbitLex).
//RUNPATH("RESTRUCTURE V3/missionBuilder.ks").



RUNPATH("RESTRUCTURE V3/missionBuilder.ks", LAYTHE, "land", LATLNG(-0.3955,-158.3569), orbitLex).




//RUNONCEPATH("RESTRUCTURE V3/lib/shipControl.ks").
//LOCAL lowest IS test(SHIP, 1).

//LOCAL testVec1 IS VECDRAWARGS(SHIP:POSITION, -(SHIP:FACING:VECTOR:NORMALIZED)*ALT:RADAR,RED,"Radar altitude",1,TRUE).
//LOCAL testVec2 IS VECDRAWARGS(SHIP:POSITION, (SHIP:FACING:VECTOR:NORMALIZED),YELLOW,"Calc",1,TRUE).

//PRINT("Alt : " + ALTITUDE).
//PRINT("Calc : " + lowest).

//LOCK res TO distanceSubmerged(SHIP).

//UNTIL (ag1){
//	CLEARSCREEN.
//	PRINT(res).
//	WAIT 0.1.
//}


IF(0){


	LOCAL res IS getInterceptNode(SHIP, TARGET, TRUE, TRUE, TIME:SECONDS).
	RUNPATH ("basic_functions/executeNode.ks", NODE(res["t"], res["radial"], res["normal"], res["prograde"])).


	WAIT UNTIL (1 = 0).

	UNTIL (1 = 1){
		CLEARSCREEN.
		
		PRINT("SMA : " + SHIP:ORBIT:SEMIMAJORAXIS).
		PRINT("ECC : " + SHIP:ORBIT:ECCENTRICITY).
		
		WAIT 0.1.
	}


	LOCAL res1 IS getInterceptNode(SHIP:BODY, DUNA, TRUE, TRUE, TIME:SECONDS).
		LOCAL ejectMagnitude IS SQRT(res1["radial"]^2 + res1["normal"]^2 + res1["prograde"]^2).
		LOCAL ejectPeriapsis IS (APOAPSIS + SHIP:BODY:RADIUS).
		LOCAL ejectSMA IS ((2/SHIP:BODY:SOIRADIUS) - ((ejectMagnitude^2)/SHIP:BODY:MU))^(-1).
		LOCAL ejectEcc IS 1 - ejectPeriapsis/ejectSMA.
		
		SET ejectEcc TO 0.9. //9397.3
		SET ejectSMA TO ejectPeriapsis/(1 - ejectEcc).
		SET ejectMagnitude TO SQRT(SHIP:BODY:MU*((2/SHIP:BODY:SOIRADIUS) - (1/ejectSMA))).
		
		PRINT("Mag : " + ejectMagnitude).
		PRINT("Per : " + ejectPeriapsis).
		PRINT("SMA : " + ejectSMA).
		PRINT("Ecc : " + ejectEcc).
		WAIT 3.
		
	LOCAL res IS getTransferNode(ejectSMA, ejectEcc, 0, 0, 0, 0).
	//SMA, ecc, inc, lan, arg, true
	RUNPATH ("basic_functions/executeNode.ks", NODE(res["t"], res["radial"], res["normal"], res["prograde"])).
	WAIT 1.
	warpTime(res["dt"] - 1).
}



//LOCAL ejectMagnitude IS 100.
//LOCAL ejectPeriapsis IS (APOAPSIS + SHIP:BODY:RADIUS).
//LOCAL ejectSMA IS ((2/SHIP:BODY:SOIRADIUS) - ((ejectMagnitude^2)/SHIP:BODY:MU))^(-1).
//LOCAL ejectEcc IS 1 - ejectPeriapsis/ejectSMA.
//True anom or something?

//Perhaps just iterate around for now, find the closest matching ejection to which ever direction



//For now just eject forward/backward as soon as possible, and then Lambert.
//As we cannot take advantage of the Oberth effect at the moment, might as well make it simple.





//How to do proper transfer orbits?

//If same parent body, can do a regular lambert solve (How to not intercept the DIRECT CENTER of a body though? Perhaps take orbital velocity, and desired distance from center, and find a time offset)
//If up a level, say you're orbiting sun and you want to go to moon, must solve the same issue with center intercept, just twice in a row. (If you can get one, the other is simple)

//Going down a level may be simple, as is transfering if you take a simple approach
//->E.g. eject, then solve lambert for same level intercept

//However, efficient ejection/transfer is harder.
//Perhaps lambert solve using your parent body, and then when near the time you must do that meaneuver, find the resultant velocity (host + lambert change).
//This will be the required velocity at the instant of leaving the parent body's SOI.
//Thus, can solve to find a lambert transfer to this ejection trajectory (Can eject anywhere on your orbit, as long as the 'radius' is the SOI edge (r) and velocity at edge is the required (v))


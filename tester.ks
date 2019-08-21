RUNONCEPATH("lib/scriptManagement.ks").	
RUNONCEPATH("lib/config.ks").
RUNONCEPATH("lib/gameControl.ks").
RUNONCEPATH("lib/shipControl.ks").
RUNONCEPATH("lib/lambert.ks").
RUNONCEPATH("lib/math.ks").


//configureVessel().

LOCAL orbitLex IS LEXICON().
	SET orbitLex["semimajoraxis"] TO 168675000.
	SET orbitLex["eccentricity"] TO 0.60.
	SET orbitLex["inclination"] TO 56.
	SET orbitLex["longitudeofascendingnode"] TO 30.
	SET orbitLex["argumentofperiapsis"] TO 20.
	SET orbitLex["trueanomaly"] TO 60.
	
	

//RUNPATH("operations/mission operations/missionBuilder.ks", SHIP:BODY, "land", 0, 0).
//RUNPATH("operations/mission operations/missionBuilder.ks", SHIP:BODY, "land", LATLNG(20.5829, -146.5116), 0).
//RUNPATH("operations/mission operations/missionBuilder.ks", JOOL, "orbit", 0, orbitLex).
//RUNPATH("operations/mission operations/missionBuilder.ks", MINMUS, "orbit", 0, orbitLex).
//RUNPATH("operations/mission operations/missionBuilder.ks", MOHO, "orbit", 0, orbitLex).
//RUNPATH("operations/mission operations/missionBuilder.ks"). //No parameters given, serves selection-GUI instead

//RUNPATH("operations/mission operations/missionBuilder.ks", MOHO, "orbit", 0, orbitLex).
//RUNPATH("operations/mission operations/missionBuilder.ks", MOHO, "orbit", 0, orbitLex).
//RUNPATH("operations/mission operations/missionBuilder.ks", MOHO, "orbit", 0, orbitLex).
//RUNPATH("operations/mission operations/missionBuilder.ks", MOHO, "orbit", 0, orbitLex).
//RUNPATH("operations/mission operations/missionBuilder.ks", MOHO, "orbit", 0, orbitLex).




//RUNPATH("_operation scenarios/mun_lander.ks").
//RUNPATH("_operation scenarios/launch_station.ks").
//RUNPATH("_operation scenarios/launch_science.ks").
//RUNPATH("_operation scenarios/orbit_ike.ks").
//RUNPATH("_operation scenarios/test_actions.ks").
RUNPATH("_operation scenarios/mun_lander.ks").


//4.3 COM shift, 1.3 probe to port
//0.3 to center of port, 0.4 to tip?


//LOCAL targVessel IS VESSEL("PMM-2").
//LOCAL targVessel IS TARGET.
//LOCAL myPort IS SHIP:PARTSTAGGED("p1")[0].
//LOCAL targPort IS targVessel:PARTSTAGGED("p1")[0].
//THIS IS THE CORRECT CODE FOR THE OFFSET, IT GAVE THE EXACT SEPARATION
//LOCAL offset IS targVessel:FACING:FOREVECTOR*((myPort:POSITION - SHIP:POSITION):MAG + (targPort:POSITION - targVessel:POSITION):MAG + 0).
//LOCAL faceDir IS LOOKDIRUP(-targVessel:FACING:FOREVECTOR, targVessel:FACING:TOPVECTOR).

//PRINT((myPort:POSITION - SHIP:POSITION):MAG). //2.38
//PRINT((targPort:POSITION - targVessel:POSITION):MAG). //2.31
//PRINT(offset:MAG). //9.69
//WAIT 5. //Reads 4.7


//RUNPATH("operations/mission operations/basic functions/moveToPoint4.ks", targVessel, targVessel:FACING:VECTOR*100). //, SHIP, faceDir).
LOCAL parameterLex IS LEXICON().
	SET parameterLex["entity"] TO TARGET.

RUNPATH("operations/mission operations/main functions/dock.ks", parameterLex).




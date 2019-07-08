RUNONCEPATH("lib/scriptManagement.ks").	
RUNONCEPATH("lib/config.ks").
RUNONCEPATH("lib/gameControl.ks").
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


RUNONCEPATH("lib/gui.ks").
PRINT(showGUI("master")).













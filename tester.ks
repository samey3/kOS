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

configureVessel().

LOCAL orbitLex IS LEXICON().
	SET orbitLex["semimajoraxis"] TO 1686750.
	SET orbitLex["eccentricity"] TO 0.60.
	SET orbitLex["inclination"] TO 10.
	SET orbitLex["longitudeofascendingnode"] TO 30.
	SET orbitLex["argumentofperiapsis"] TO 20.
	SET orbitLex["trueanomaly"] TO 60.


//RUNPATH("mission operations/missionBuilder.ks", SHIP:BODY, "land", 0, 0). 
//RUNPATH("mission operations/missionBuilder.ks", SHIP:BODY, "orbit", 0, orbitLex). 
RUNPATH("mission operations/missionBuilder.ks"). //No parameters given, serves selection-GUI instead




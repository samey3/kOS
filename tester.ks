@lazyglobal OFF.
RUNONCEPATH("lib/config.ks").


CLEARSCREEN.
LOCK STEERING TO SHIP:FACING.
LOCK THROTTLE TO 0.
UNLOCK STEERING.
UNLOCK THROTTLE.


//configureVessel().
//RUNONCEPATH("Land.ks", 1). //LATLNG(-0.0972078366335618,-74.5576783933035)



RUNONCEPATH("lib/lambert.ks").


PRINT("Select a target to intercept").
WAIT UNTIL(HASTARGET).
	//LOCAL res IS lambert(SHIP, TARGET).
	LOCAL res IS lambert(SHIP, TARGET, TRUE, TRUE, TIME:SECONDS).
	PRINT("Time to burn : " + res["t"]).
	PRINT("Radial : " + res["radial"]).
	PRINT("Normal : " + res["normal"]).
	PRINT("Prograde : " + res["prograde"]).
	
ADD NODE(res["t"], res["radial"], res["normal"], res["prograde"]).
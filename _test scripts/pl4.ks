RUNONCEPATH("lib/math.ks").
CLEARSCREEN.
LIST SENSORS IN SENSELIST.
FOR S IN SENSELIST { //Turns all sensors on
	PRINT "Turning on Sensor: " + S:TYPE.
	S:TOGGLE().
}
LOCAL timeStep IS 2.
LOCAL maxIterations IS 1.
LOCAL Cdrag IS 0.2. //Cd, 0.2 for most parts? Can iterate beforehand and find the actual. I'm assuming its a weighted-average sort of thing?
LOCAL curPos IS SHIP:BODY:POSITION. //Gives a vector from the ship to the body? //SHIP:POSITION.
LOCAL curAlt IS SHIP:ALTITUDE.
LOCAL curVel IS SHIP:VELOCITY:SURFACE.
//Iteration counter
LOCAL i IS 0.
LOCK dragOpp TO (SHIP:SENSORS:ACC - SHIP:SENSORS:GRAV).
LOCAL initVel IS 0.
LOCAL afterVel IS 0.


UNTIL(FALSE){
	 //Leave it as this or mag? This currently gives the proper vector. Find which is more efficient


	SET curPos TO SHIP:BODY:POSITION.
	SET curAlt TO SHIP:ALTITUDE.
	SET curVel TO SHIP:VELOCITY:SURFACE.
	IF(SHIP:ORBIT:PERIAPSIS < SHIP:BODY:ATM:HEIGHT){
		FROM{ SET i TO 0. } UNTIL (i = maxIterations OR curPos:MAG < SHIP:BODY:RADIUS) STEP { SET i TO i + 1. } DO {
			SET CdA TO (CHOOSE 3.282 IF SHIP:VELOCITY:SURFACE:MAG > 300 ELSE 2.58).
		}
	}
}
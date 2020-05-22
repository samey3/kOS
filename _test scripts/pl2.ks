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



//p=ρRT
//Can get pressure and temperature at an altitude
//density = ALTPRES/(R*ALTTEMP)
//Can use CONSTANT:IdealGas
//density = ALTPRES/(CONSTANT:IdealGas*ALTTEMP)

UNTIL(FALSE){
	 //Leave it as this or mag? This currently gives the proper vector. Find which is more efficient


	SET curPos TO SHIP:BODY:POSITION.
	SET curAlt TO SHIP:ALTITUDE.
	SET curVel TO SHIP:VELOCITY:SURFACE.
	IF(SHIP:ORBIT:PERIAPSIS < SHIP:BODY:ATM:HEIGHT){
		//FROM{ SET i TO 0. } UNTIL (i = maxIterations OR curPos:MAG < SHIP:BODY:RADIUS) STEP { SET i TO i + 1. } DO {		
			//Calc dynamic pressure q
			//SET p TO 1.221*CONSTANT:E^(-SHIP:ALTITUDE/5000).
			
			//SET q TO 0.5*p*SHIP:VELOCITY:SURFACE:MAG^2.
			
			//Calculate 'surface area'. If the ship mass doesnt change on descent, can move this outside?)
			//SET surfaceArea TO SHIP:MASS*0.008. //KSP uses this?
			
			//Calculate drag
			//SET dragV TO -Cdrag*surfaceArea*q*SHIP:VELOCITY:SURFACE:NORMALIZED.
		
			
			//SET DV TO VECDRAWARGS(SHIP:POSITION, dragV, RED, "DV", 1, TRUE).
			//PRINT p. //0.0097 - 1.221
			//PRINT q. //14689 - 27756
			//PRINT surfaceArea. //0.038 - 0.038
			//WAIT 5.
			//WAIT 0.1.
		//}
		
		
		set Speed to SHIP:VELOCITY:SURFACE:MAG.
		
		set p_1 to altitude / ((-1)*5000).
		set p to 1.221 * (2.7183^p_1).
		SET p TO 1.223125*CONSTANT:E^(-altitude/5000)/1000. //In kPa
		//SET p TO SHIP:BODY:ATM:ALTITUDEPRESSURE(altitude)*Constant:AtmToKPa/(CONSTANT:IdealGas*SHIP:BODY:ATM:ALTITUDETEMPERATURE(altitude)).
		set q to 0.5*p*(Speed^2).
		
		set A to mass*.008.
		
		set Drag to 0.2*A*q.
		
		
		
		SET initVel TO SHIP:VELOCITY:SURFACE:MAG.
		WAIT 0.1.
		SET afterVel TO SHIP:VELOCITY:SURFACE:MAG.
		
		
		
		//SET Fg TO CONSTANT:G*SHIP:BODY:MASS/(SHIP:POSITION - SHIP:BODY:POSITION):MAG^2.

		CLEARSCREEN.

		//SET DOV TO VECDRAWARGS(SHIP:POSITION, dragOpp/SHIP:MASS, BLUE, "SENS", 1, TRUE).
		//SET DFV TO VECDRAWARGS(SHIP:POSITION, dragV/SHIP:MASS, RED, "ALGO", 1, TRUE).
		
		//PRINT "Algo: " + dragV:mag/SHIP:MASS.
		
		
		//New q calculation?
		//q = 1/2 * density * vel^2
		//Fd = q * Cd * A

		PRINT "Algo q: " + q. //Returns Pa
		PRINT "Ship q: " + SHIP:q*constant:ATMtokPa. //Returns kPa
		PRINT "Algo: " + Drag/SHIP:MASS.
		PRINT "Sensor: " + dragOpp:MAG/SHIP:MASS.
		PRINT("Rate : " + (afterVel - initVel)*10).
		WAIT 0.01.
	}
	ELSE{
		PRINT("Will not impact.").
		WAIT 0.01.
		CLEARSCREEN.
	}
}
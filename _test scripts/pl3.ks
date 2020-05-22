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

LOCAL dryAirConst IS CONSTANT:IDEALGAS/SHIP:BODY:ATM:MOLARMASS. //287.058

//Temperature code here but it's nasty
//https://github.com/NathanKell/AeroGUI/blob/master/AeroGUI/AeroGUI.cs
//Just use a rough prediction

UNTIL(FALSE){
	 //Leave it as this or mag? This currently gives the proper vector. Find which is more efficient


	SET curPos TO SHIP:BODY:POSITION.
	SET curAlt TO SHIP:ALTITUDE.
	SET curVel TO SHIP:VELOCITY:SURFACE.
	IF(SHIP:ORBIT:PERIAPSIS < SHIP:BODY:ATM:HEIGHT){
		
		
		SET Speed TO SHIP:VELOCITY:SURFACE:MAG.
		
		set p_1 to altitude / ((-1)*5000).
		set p to 1.221 * (2.7183^p_1).
		//SET p TO 1.223125*CONSTANT:E^(-altitude/5000)/1000. //In kPa
		SET p TO SHIP:BODY:ATM:ALTITUDEPRESSURE(altitude)*Constant:AtmToKPa/(dryAirConst*SHIP:BODY:ATM:ALTITUDETEMPERATURE(altitude)).
		set q to 0.5*p*(Speed^2).
		
		set A to mass*.008.
		
		
		//Use R (8.314) and the molar mass from atmo?
		
		//SET q TO SHIP:Q*CONSTANT:ATMTOKPA.
		//BOTH Q WORK
		//Its just Cd and A?
		//Requires Q in Pa
		
		//3.282 fast
		//2.580 not moving?
		
		//CdA is a function of altitude (pressure) and velocity?
		//Thus A constant, Cd changing
		
		//set Drag to 0.2*A*q.
		SET CdA TO (CHOOSE 3.282 IF SHIP:VELOCITY:SURFACE:MAG > 300 ELSE 2.58).
		set Drag to CdA*q. 
		
		PRINT "p: " + p.
		
		PRINT SHIP:BODY:ATM:ALTITUDEPRESSURE(altitude)*constant:ATMtokPa*1000.
		PRINT SHIP:BODY:ATM:ALTITUDETEMPERATURE(altitude).
		PRINT SHIP:BODY:ATM:MOLARMASS.
		PRINT SHIP:BODY:ATM:ADIABATICINDEX.

		PRINT "Algo q: " + q. //Returns Pa
		PRINT "Ship q: " + SHIP:q*constant:ATMtokPa. //Returns kPa
		PRINT "Algo: " + Drag. //kN
		PRINT "Sensor: " + dragOpp:MAG*SHIP:MASS. //kN
		PRINT("Rate : " + (afterVel - initVel)*10).
		WAIT 0.01.
		CLEARSCREEN.
	}
}
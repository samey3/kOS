RUNONCEPATH("lib/math.ks").

CLEARSCREEN.


//Prefer recaculation of e.g. drag manually rather than requiring a lock, because that runs in background every tick, more than we need.
//Use velocity:surface for drag?

//Whats more efficient:
//Calculating dragF as a scalar and combining with retrograde vector?
//Or calculating it directly as a vector as currently?

//Does removing SHIP: from stuff make it faster?


//I suspect it has actually updated to a more realistic atmosphere though
//Remember we are using this to predict for an orbit we are not currently on, while in retrograde position.
//Thus can use current mass and what not?

LOCAL timeStep IS 2.
LOCAL maxIterations IS 50.
//Targ terrain height, replace the end check in the for loop?


//If the current method of calculating density does not work, use this?
//p=ρRT
//Can get pressure and temperature at an altitude
//density = ALTPRES/(R*ALTTEMP)
//Can use CONSTANT:IdealGas

//Drag
//Based on old atmo? I'm not sure. Use this for now and change later if needed.
//KSP uses density = density0 * ealtitude/-5000 for atmo density
//Where  DENSITY0 = 1.221 kg/m3
LOCAL Cdrag IS 0.2. //Cd, 0.2 for most parts? Can iterate beforehand and find the actual. I'm assuming its a weighted-average sort of thing?


LOCAL DragMassConst IS -SHIP:MASS*0.004884. //For faster drag calculation
LOCAL GravMassConst IS CONSTANT:G*SHIP:BODY:MASS*SHIP:MASS. //For faster grav calculation


LOCAL curPos IS SHIP:BODY:POSITION. //Gives a vector from the ship to the body? //SHIP:POSITION.
LOCAL curAlt IS SHIP:ALTITUDE.
LOCAL curVel IS SHIP:VELOCITY:SURFACE.

//Iteration counter
LOCAL i IS 0.

UNTIL(FALSE){
	//Calc dynamic pressure q
	//SET p TO 1.221*CONSTANT:E^(-SHIP:ALTITUDE/5000).
	//SET q TO 0.5*p*SHIP:VELOCITY:SURFACE:MAG^2.
	
	//Calculate 'surface area'. If the ship mass doesnt change on descent, can move this outside?)
	//SET surfaceArea TO SHIP:MASS*0.008. //KSP uses this?
	
	//Calculate drag
	//SET dragF TO surfaceArea*q*SHIP:VELOCITY:SURFACE. //Leave it as this or mag? This currently gives the proper vector. Find which is more efficient
	
	//All in one
	//SET dragF TO SHIP:MASS*0.004884*CONSTANT:E^(-SHIP:ALTITUDE/5000)*SHIP:VELOCITY:SURFACE:MAG^2*SHIP:VELOCITY:SURFACE.
	
	//Have a variable that holds position or altitude and use it when determining to stop?	
	
	SET curPos TO SHIP:BODY:POSITION.
	SET curAlt TO SHIP:ALTITUDE.
	SET curVel TO SHIP:VELOCITY:SURFACE.
	IF(SHIP:ORBIT:PERIAPSIS < SHIP:BODY:ATM:HEIGHT){
		FROM{ SET i TO 0. } UNTIL (i = maxIterations OR curPos:MAG < SHIP:BODY:RADIUS) STEP { SET i TO i + 1. } DO {
			//Find the force of drag
			IF((curPos:MAG - SHIP:BODY:RADIUS) > SHIP:BODY:ATM:HEIGHT){
				SET dragV TO V(0, 0, 0).
			}
			ELSE{
				SET dragV TO DragMassConst*CONSTANT:E^(-curAlt/5000)*curVel:mag^2*curVel.
			}
			

			//Find force of gravity
			SET gravV TO curPos:NORMALIZED*GravMassConst/curPos:MAG^2.
			
			//Calculate the new velocity and position
			SET curVel TO curVel - timeStep*(dragV + gravV)/SHIP:MASS. //Subtract because initial vector is ship to body center?
			SET curPos TO curPos - curVel.
			
			SET GV TO VECDRAWARGS(SHIP:POSITION, gravV, GREEN, "GV", 1, TRUE).
			SET DV TO VECDRAWARGS(SHIP:POSITION, dragV, RED, "DV", 1, TRUE).
			SET HV TO VECDRAWARGS(SHIP:POSITION, curPos, BLUE, "HV", 1, TRUE).
			WAIT 0.1.
		}
		
		//Now its less than the radius, find the impact position
		SET initialPos TO SHIP:BODY:GEOPOSITIONOF(curPos).
		SET finalPos TO SHIP:BODY:GEOPOSITIONLATLNG(initialPos:LAT, wrap360(initialPos:LNG + i*timeStep/SHIP:BODY:ROTATIONPERIOD)).
		
		
		CLEARSCREEN.
		PRINT dragV:mag.
		PRINT("Impact" + char(10) + "Lat: " + finalPos:LAT + char(10) + "Lng: " + finalPos:LNG).
		WAIT 0.01.
	}
	ELSE{
		PRINT("Will not impact.").
		WAIT 0.01.
		CLEARSCREEN.
	}
}
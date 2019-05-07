	@lazyglobal OFF.
	CLEARSCREEN.
	

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _body.

	
//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/
	
	
	RUNONCEPATH("lib/gameControl.ks").
	RUNONCEPATH("lib/orbitProperties.ks").
	
	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	//----------------------------------------------------\
	//Perform the intercept burn--------------------------|	
		RUNPATH("mission operations/intermediate functions/setOrbit.ks", _body, TRUE, FALSE, TRUE).
		PRINT("REG WARP").
		WAIT 3.
		//setOrbit will warp until it has a patch
		warpTime(TIME:SECONDS + SHIP:ORBIT:NEXTPATCHETA + 30, FALSE).
		
		
	
	//----------------------------------------------------\
	//Set the required entry velocity---------------------|	
		LOCAL maneuverTime IS TIME:SECONDS + 30. //180. //3 minutes into the SOI
		
		//Get the radii
		LOCAL positionVector IS -(POSITIONAT(SHIP, maneuverTime) - POSITIONAT(SHIP:BODY, maneuverTime)).
		LOCAL r IS positionVector:MAG.
		LOCAL rp IS SHIP:BODY:RADIUS + 20000.
			IF(SHIP:BODY:ATM:EXISTS){ SET rp TO rp + SHIP:BODY:ATM:HEIGHT*2. } //If atmosphere, add extra height

		//Get the orbit parameters
		LOCAL vel IS VELOCITYAT(SHIP, maneuverTime):ORBIT:MAG.
		LOCAL sma IS ((2/r - (vel^2)/SHIP:BODY:MU)^(-1)).
		LOCAL ecc IS (1 - rp/sma).
		LOCAL ta IS ARCCOS((sma*(1 - ecc^2) - r)/(ecc*r)).
		LOCAL fpa IS ARCTAN((ecc*SIN(ta))/(1 + ecc*COS(ta))).

		//Now need a vector with that angle
		LOCAL axis IS VCRS(VCRS(positionVector, SHIP:BODY:ANGULARVEL), positionVector).
		LOCAL r_velocity IS (positionVector:NORMALIZED*vel)*ANGLEAXIS(-(90 - ABS(fpa)), axis).
	
		LOCAL resNode IS nodeFromDesiredVector(maneuverTime, r_velocity).
		RUNPATH("mission operations/basic functions/executeNode.ks", resNode).
		
		//Now perform the capture burn
		LOCAL r_speed IS 0.80*SQRT(2*SHIP:BODY:MU/(SHIP:BODY:RADIUS + SHIP:ORBIT:PERIAPSIS)). //Sets to 80% of the escape velocity
		SET r_velocity TO r_speed*VELOCITYAT(SHIP, TIME:SECONDS + ETA:PERIAPSIS):ORBIT:NORMALIZED.
	
		SET resNode TO nodeFromDesiredVector(TIME:SECONDS + ETA:PERIAPSIS, r_velocity).
		RUNPATH("mission operations/basic functions/executeNode.ks", resNode).
	
	
		//REWRITE THIS ALL UP HERE TO MATCH COMMENTING FORMAT
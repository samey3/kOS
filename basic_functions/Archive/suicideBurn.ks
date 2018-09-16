	@lazyglobal OFF.
	runoncepath("lib/shipControl.ks").
	CLEARSCREEN.

	//Can run a small modVelocity on two axis? To remove horizontal velocity.
	
	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/


	//Take period of orbit, find the meanAnomaly difference for say 60 seconds,
	//Then get the time to that meanAnomaly, and warp to it.



	LOCAL altitude IS (SHIP:POSITION - SHIP:GEOPOSITION:POSITION):MAG.
	//Do this better? The gravity variance has an effect.
	//Or, make it stop somewhat off of the ground and hover down.
	//Use full 1/2 to 3/4 altitude?
	LOCAL grav_acceleration IS SHIP:BODY:MU/((SHIP:BODY:RADIUS + altitude*(0))^2). //(3/4)
	LOCAL base_acceleration IS -SHIP:AVAILABLETHRUST/SHIP:MASS.
	LOCAL effective_acceleration IS (base_acceleration + grav_acceleration).
	LOCAL v_f IS 5.
	//Setting v_f doesn't exactly work properly when grav is not constant.	
		
	LOCAL v_i1 IS -VERTICALSPEED.	
	LOCAL v_i2 IS SQRT((2*effective_acceleration*grav_acceleration*altitude + effective_acceleration*v_i1^2 - grav_acceleration*v_f^2)/(effective_acceleration - grav_acceleration)).
	LOCAL timeToBurn IS (v_i2 - v_i1)/grav_acceleration.
	
	//We trick nodeBurn a bit instead of making a script that will only be used once.
	//Our effective acceleration is lower than actual, so we boost up the DV it thinks its burning.
	LOCAL dv_nodeBurn IS (v_i2/effective_acceleration)*base_acceleration. 
	LOCAL burnTime IS ABS(dv_nodeBurn/base_acceleration).
		
		
		
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	SAS ON.
	LOCK STEERING TO smoothRotate((-SHIP:VELOCITY:SURFACE):DIRECTION).
	LOCAL timer IS TIME:SECONDS + timeToBurn.
	UNTIL(TIME:SECONDS >= timer){
		CLEARSCREEN.
		PRINT("Time to burn : " + (timer - TIME:SECONDS)).
	}

	GEAR ON.
	RUNPATH ("basic_functions/nodeBurn.ks", 0, dv_nodeBurn, 4). //timeToBurn + burnTime/2
	
	
	
	SET timer TO TIME:SECONDS + burnTime.
	LOCK thrustPercent TO (base_acceleration * SHIP:MASS) / SHIP:AVAILABLETHRUST.
	LOCK THROTTLE TO thrustPercent.
	UNTIL (TIME:SECONDS >= timer OR (-VERTICALSPEED) <= v_f){
		PRINT("Time left : " + (timer - TIME:SECONDS)).
	}
	LOCK THROTTLE TO 0.
	
	
	
	SAS ON.
	LOCK STEERING TO smoothRotate(SHIP:UP).
	
	WAIT 3.
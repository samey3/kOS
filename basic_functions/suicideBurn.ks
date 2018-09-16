	@lazyglobal OFF.
	CLEARSCREEN.	
	//For atmosphere, need to take into account drag deceleration
	
//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/

	
	//This is used if you are trying to land on an object
	PARAMETER _onCraft IS 0.
	

//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/
	
	
	RUNONCEPATH("lib/shipControl.ks").

	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/


	//WHERE IS THIS _coordinates VARIABLE COMING FROM??????
	LOCAL LOCK planeNormalVector TO (SHIP:POSITION - BODY:POSITION).
	//Perhaps add a parameter, and can use own geoposition as a default?
	LOCAL LOCK horizontalVector TO projectToPlane((_coordinates:POSITION - SHIP:POSITION), planeNormalVector).	

	//Ship and landing heights
	LOCAL shipHeight IS findCraftHeight(SHIP) + 1. //Landing legs position is at the top? So doesn't get the full length. Could we perhaps just take the top of the target and use that for distance?
	//LOCAL landingHeight IS 0. //Additional distance above the surface
	LOCAL targetHeightAdded IS FALSE.
	
	//Descent properties
	LOCAL LOCK altitude TO (SHIP:POSITION - SHIP:BODY:POSITION):MAG.
	LOCK distanceLeft TO (SHIP:POSITION - SHIP:BODY:POSITION):MAG - SHIP:BODY:RADIUS.
	IF(SHIP:GEOPOSITION:TERRAINHEIGHT > 0){
		LOCK distanceLeft TO (SHIP:POSITION - SHIP:BODY:POSITION):MAG - SHIP:BODY:RADIUS - SHIP:GEOPOSITION:TERRAINHEIGHT.
	}	
	LOCAL LOCK v_i TO -VERTICALSPEED.
	LOCAL v_f IS 0.

	//Acceleration properties
	LOCAL base_acceleration IS (-SHIP:AVAILABLETHRUST/SHIP:MASS)*0.90. //Makes estimates with 90% avaiable thrust, so it may increase throttle later if needed
	LOCAL effective_acceleration IS base_acceleration + SHIP:BODY:MU/(altitude^2).
	LOCAL LOCK stopDistance TO ((v_f^2 - v_i^2)/(2*effective_acceleration)) + shipHeight. //5 ship height
		
	//Sets up the RCS thrusters
	LOCAL rcsLimiter IS (SHIP:MASS/2.6).
	LOCAL rcsList IS LIST().
	FOR part IN SHIP:PARTS {
		FOR module IN part:modules {
			IF (module = "ModuleRCSFX") { rcsList:ADD(part:getmodule("ModuleRCSFX")). } //Maybe shouldn't limit them to 25 here? Also depends on velocity difference
		}
	}	
	//Why is this 30???
	FOR block IN rcsList {
		block:SETFIELD("thrust limiter", rcsLimiter*100). //30
	}
		

//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	//OR
	//Why don't we find the acceleration of the RCS thrusters, and over time of 0.1s, find the total change.
	//Vary thrust based on enough to cancel out any velocity.


	//ALT RADAR NEEDS TO BE SWITCHED OUT
	//Perhaps water landings are messed up because its taking radar to ground and not sea level?

	//Uses the prediction for deciding when to start the burn
	RCS ON.
	LOCK STEERING TO smoothRotate((-SHIP:VELOCITY:SURFACE):DIRECTION, 0.05).
	UNTIL(distanceLeft <= (stopDistance + ABS(VERTICALSPEED*0.02))){
		CLEARSCREEN.
		PRINT("ALT : " + distanceLeft).
		PRINT("base_acceleration : " + base_acceleration).
		PRINT("effective_acceleration : " + effective_acceleration).
		PRINT("stopDistance : " + stopDistance).
		PRINT("v_i : " + v_i).
		PRINT("Distance to burn : " + (distanceLeft - (stopDistance + ABS(VERTICALSPEED*0.02)))).
		PRINT("Ship height : " + shipHeight).
		
		RUNPATH("basic_functions/modVelocityPlane_iterative.ks", V(0,0,0), planeNormalVector, rcsList:LENGTH).
		//RUNPATH ("basic_functions/modPositionPlane_iterative.ks", _onCraft, V(0,0,0), planeNormalVector).
		
		
		//If landing on a target, adds the targets height to the shipHeight once it is unpacked
		IF(_onCraft <> 0 AND targetHeightAdded = FALSE AND _onCraft:UNPACKED){
			SET shipHeight TO shipHeight + findCraftHeight(_onCraft).
			SET targetHeightAdded TO TRUE.
		}
	}	

	//Varies the thrust required the descent
	LOCK Ar TO ((v_f^2 - v_i^2)/(2*(distanceLeft - shipHeight))).
	LOCK max_acceleration TO -SHIP:AVAILABLETHRUST/SHIP:MASS + SHIP:BODY:MU/(altitude^2).
	LOCK thrustPercent TO Ar/max_acceleration.
	
	LOCK THROTTLE TO thrustPercent.
	GEAR ON.
	UNTIL (v_i < 0.5){
		CLEARSCREEN.
		PRINT("Ar : " + Ar).
		PRINT("Max : " + max_acceleration).
		PRINT("Ship height : " + shipHeight).
		
		RUNPATH("basic_functions/modVelocityPlane_iterative.ks", V(0,0,0), planeNormalVector, rcsList:LENGTH).
		//RUNPATH ("basic_functions/modPositionPlane_iterative.ks", _onCraft, V(0,0,0), planeNormalVector).
		
		//If landing on a target, adds the targets height to the shipHeight once it is unpacked
		IF(_onCraft <> 0 AND targetHeightAdded = FALSE AND _onCraft:UNPACKED){
			//If terrainHeight < 0, assume in ocean. Assume roughly half submerged
			IF(_onCraft:GEOPOSITION:TERRAINHEIGHT > 0){
				SET shipHeight TO shipHeight + findCraftHeight(_onCraft). } 
			ELSE {
				SET shipHeight TO shipHeight + findCraftHeight(_onCraft)/3. }
				
			SET targetHeightAdded TO TRUE.
		}
	}
	LOCK THROTTLE TO 0.
	LOCK STEERING TO smoothRotate(SHIP:UP).
	RCS OFF.
	WAIT 1.
	
	
//--------------------------------------------------------------------------\
//								Program end					   				|
//--------------------------------------------------------------------------/

FOR block IN rcsList {
	block:SETFIELD("thrust limiter", 100).
}	
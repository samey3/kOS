	@lazyglobal OFF.
	CLEARSCREEN.	
	//For atmosphere, need to take into account drag deceleration
	
//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/

	
	//This is used if you are trying to land on an object
	PARAMETER _landObject IS 0.
	

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
	LOCAL shipHeight IS findCraftHeight(SHIP) - 9. //Landing legs position is at the top? So doesn't get the full length. Could we perhaps just take the top of the target and use that for distance?
	//LOCAL landingHeight IS 0. //Additional distance above the surface
	LOCAL targetHeightAdded IS FALSE.
	
	//Descent properties
	LOCK distanceLeft TO (SHIP:POSITION - SHIP:BODY:POSITION):MAG - SHIP:BODY:RADIUS - MAX(SHIP:GEOPOSITION:TERRAINHEIGHT, 0).
	//IF(SHIP:GEOPOSITION:TERRAINHEIGHT > 0){
	//	LOCK distanceLeft TO (SHIP:POSITION - SHIP:BODY:POSITION):MAG - SHIP:BODY:RADIUS - SHIP:GEOPOSITION:TERRAINHEIGHT.
	//}
	LOCAL LOCK altitude TO (SHIP:POSITION - SHIP:BODY:POSITION):MAG.	
	LOCAL LOCK v_i TO -VERTICALSPEED.
	LOCAL v_f IS 0.

	//Acceleration properties
	LOCAL base_acceleration IS (-SHIP:AVAILABLETHRUST/SHIP:MASS)*0.90. //Makes estimates with 90% avaiable thrust, so it may increase throttle later if needed
	LOCAL effective_acceleration IS base_acceleration + SHIP:BODY:MU/(altitude^2).
	LOCAL LOCK stopDistance TO ((v_f^2 - v_i^2)/(2*effective_acceleration)) + shipHeight - 3. //5 ship height
		
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
	
	//Target properties
	LOCAL landingCoordinates IS 0.
	IF(_landObject <> 0 AND _landObject:ISTYPE("Vessel")){
		SET landingCoordinates TO _landObject:GEOPOSITION. 
	}
	ELSE IF (_landObject <> 0){
		SET landingCoordinates TO _landObject. }
		
	
		

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
	LOCK STEERING TO ((-SHIP:VELOCITY:SURFACE):DIRECTION).
	
	//IF(landingCoordinates <> 0){	
		LOCK STEERING TO (-ADDONS:TR:PLANNEDVECTOR):DIRECTION.
		ADDONS:TR:SETTARGET(landingCoordinates).
		LOCK STEERING TO (-ADDONS:TR:CORRECTEDVECTOR):DIRECTION.
		
		//LOCK STEERING TO ((-ADDONS:TR:PLANNEDVECTOR) + 100*(-(ADDONS:TR:CORRECTEDVECTOR - ADDONS:TR:PLANNEDVECTOR))):DIRECTION.	
		LOCAL LOCK impactDif TO (landingCoordinates:POSITION - ADDONS:TR:IMPACTPOS:POSITION).	
		LOCK STEERING TO smoothRotate((30*(-ADDONS:TR:PLANNEDVECTOR:NORMALIZED) - SQRT(impactDif:MAG)*impactDif:NORMALIZED):DIRECTION, 30). //Actually works
		//LOCK STEERING TO (45*(-ADDONS:TR:PLANNEDVECTOR:NORMALIZED) - (45*(SQRT(impactDif:MAG)/(SQRT(impactDif:MAG) + 10)))*impactDif:NORMALIZED):DIRECTION.		
	//}
	LOCAL t1 IS 0.
	LOCAL t2 IS 0.
	LOCAL t3 IS 0.
	
	UNTIL(distanceLeft <= (stopDistance + ABS(VERTICALSPEED*0.02))){
		CLEARSCREEN.
		PRINT("ALT : " + distanceLeft).
		PRINT("base_acceleration : " + base_acceleration).
		PRINT("effective_acceleration : " + effective_acceleration).
		PRINT("stopDistance : " + stopDistance).
		PRINT("v_i : " + v_i).
		PRINT("Distance to burn : " + (distanceLeft - (stopDistance + ABS(VERTICALSPEED*0.02)))).
		PRINT("Ship height : " + shipHeight).
		
		//RUNPATH("basic_functions/modVelocityPlane_iterative.ks", V(0,0,0), planeNormalVector, rcsList:LENGTH).		
		//If _landObject, do this instead vvv
		//RUNPATH("basic_functions/modImpact_iterative.ks", V(0,0,0), _coordinates, rcsList:LENGTH).		
			
		SET t1 TO VECDRAWARGS(SHIP:POSITION, 45*(-ADDONS:TR:PLANNEDVECTOR:NORMALIZED),RED,"Planned",1,TRUE).
		SET t2 TO VECDRAWARGS(SHIP:POSITION, (45*(SQRT(impactDif:MAG)/(SQRT(impactDif:MAG) + 10)))*impactDif:NORMALIZED,GREEN,"Mod",1,TRUE).
		SET t3 TO VECDRAWARGS(SHIP:POSITION, (45*(-ADDONS:TR:PLANNEDVECTOR:NORMALIZED) - (45*(SQRT(impactDif:MAG)/(SQRT(impactDif:MAG) + 10)))*impactDif:NORMALIZED),YELLOW,"Result",1,TRUE).
	}	

	//Varies the thrust required the descent
	LOCK Ar TO ((v_f^2 - v_i^2)/(2*(distanceLeft - shipHeight))).
	LOCK max_acceleration TO -SHIP:AVAILABLETHRUST/SHIP:MASS + SHIP:BODY:MU/(altitude^2).
	LOCK thrustPercent TO Ar/max_acceleration.
	
	LOCK THROTTLE TO thrustPercent.
	IF(landingCoordinates <> 0 AND projectToPlane((landingCoordinates:POSITION - SHIP:POSITION), planeNormalVector):MAG < 200){
		LOCK STEERING TO (50*(-ADDONS:TR:PLANNEDVECTOR:NORMALIZED) + SQRT(impactDif:MAG)*impactDif:NORMALIZED):DIRECTION.
	}
	ELSE {
		//If too far from the target, abort and land at current location
		LOCK STEERING TO SRFRETROGRADE.
	}
	
	
	GEAR ON.
	UNTIL (v_i < 0.5){
		CLEARSCREEN.
		PRINT("Ar : " + Ar).
		PRINT("Max : " + max_acceleration).
		PRINT("Ship height : " + shipHeight).
		
		//RUNPATH("basic_functions/modVelocityPlane_iterative.ks", V(0,0,0), planeNormalVector, rcsList:LENGTH).
		//RUNPATH ("basic_functions/modPositionPlane_iterative.ks", _landObject, V(0,0,0), planeNormalVector).
		
		//If landing on a target, adds the targets height to the shipHeight once it is unpacked
		IF(_landObject <> 0 AND _landObject:ISTYPE("Vessel") AND targetHeightAdded = FALSE AND _landObject:UNPACKED){
			//If terrainHeight < 0, assume in ocean. Assume roughly half submerged
			IF(_landObject:GEOPOSITION:TERRAINHEIGHT > 0){
				SET shipHeight TO shipHeight + findCraftHeight(_landObject). } 
			ELSE {
				SET shipHeight TO shipHeight + findCraftHeight(_landObject)/3. }
				
			SET targetHeightAdded TO TRUE.
		}
	}
	LOCK THROTTLE TO 0.
	LOCK STEERING TO (SHIP:UP).
	RCS OFF.
	WAIT 1.
	
	
//--------------------------------------------------------------------------\
//								Program end					   				|
//--------------------------------------------------------------------------/

FOR block IN rcsList {
	block:SETFIELD("thrust limiter", 100).
}	
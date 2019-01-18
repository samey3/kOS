	@lazyglobal OFF.
	CLEARSCREEN.

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _toVector.	
	PARAMETER _planeNormalVector.
	PARAMETER timeToPoint IS 0.
	PARAMETER timeLimit IS 0.
	
	
//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/


	RUNONCEPATH("lib/shipControl.ks").
	RUNONCEPATH("lib/math.ks").
	
	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/		
			
			
		//LOCAL LOCK planeNormalVector TO (_coordinates:POSITION - BODY:POSITION).
		//LOCAL LOCK horizontalVector TO projectToPlane((_coordinates:POSITION - SHIP:POSITION), _planeNormalVector).
		LOCAL LOCK horizontalVelocity TO projectToPlane(SHIP:VELOCITY:SURFACE, _planeNormalVector).			
			
	//--------------------------------------\
	//VECTORS-------------------------------|		
						
		//Custom axis		
		LOCAL LOCK Xa TO SHIP:FACING:FOREVECTOR.
		LOCAL LOCK Ya TO SHIP:FACING:TOPVECTOR.
		LOCAL LOCK Za TO SHIP:FACING:STARVECTOR.

		//To desired velocity and relative velocity vectors (custom axis)
		LOCAL LOCK differenceVector TO (projectToPlane(_toVector, _planeNormalVector) - horizontalVelocity). //projectToPlane(SHIP:VELOCITY:SURFACE, _planeNormalVector)).
		LOCAL LOCK c_diffVector TO V(VDOT(differenceVector,Xa),VDOT(differenceVector,Ya),VDOT(differenceVector,Za)).

	//--------------------------------------\
	//RCS-----------------------------------|
	
		//RCS max thrust limit
		LOCAL rcsLimiter IS (SHIP:MASS/2.6).

		//Sets up the RCS thrusters
		LOCAL rcsList IS LIST().
		FOR part IN SHIP:PARTS {
			FOR module IN part:modules {
				IF (module = "ModuleRCSFX") { rcsList:ADD(part:getmodule("ModuleRCSFX")). } //Maybe shouldn't limit them to 25 here? Also depends on velocity difference
			}
		}	
		FOR block IN rcsList {
			//block:SETFIELD("thrust limiter", rcsLimiter*10).
		}
		
		//RCS parameters
		LOCAL total_rcs_thrust IS rcsList:LENGTH*0.15/2. //kN. Can set to the length of the list because each thruster is only 1kN
		LOCAL base_acceleration IS total_rcs_thrust / SHIP:MASS.
			LOCAL LOCK thrustPercent TO ((base_acceleration * SHIP:MASS) / total_rcs_thrust).
			LOCAL minDiff IS ((0.05*base_acceleration)/thrustPercent). //Based on minimal possible thrust, how close a velocity value should be obtained to the desired one
			
		//Axis difference status
		LOCAL rcsX IS True.
		LOCAL rcsY IS True.
		LOCAL rcsZ IS True.
		
		//Drawn vectors
		LOCAL wv IS 0.
		LOCAL dv IS 0.
	

//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	//Disables user control
	SET CONTROLSTICK to SHIP:CONTROL.
	LOCK STEERING TO smoothRotate(SHIP:FACING).
	SAS ON.
	RCS ON.	


	//Warp to time
	IF(timeToPoint <> 0){
		KUNIVERSE:TIMEWARP:WARPTO(TIME:SECONDS + timeToPoint).
		WAIT UNTIL WARP = 0 and SHIP:UNPACKED.
	}
	
	//Low speed difference reduction
	LOCAL startTime IS 0.
	IF(timeLimit <> 0){
		SET startTime TO (TIME:SECONDS + timeLimit). 
	}
	//For high speed difference reduction
	LOCAL modeString IS "(high speed)".
	//Breaks when using a when???
	//This is first loop through mod, and only if setting apoapsis first?
	
	UNTIL ((rcsX = False AND rcsY = False AND rcsZ = False) OR ((timeLimit <> 0) AND ((TIME:SECONDS - startTime) >= 0))){	
		IF (modeString <> "(low speed)" AND c_diffVector:MAG <= 0.1) {
			SET modeString TO "(low speed)".
			FOR block IN rcsList {
				block:SETFIELD("thrust limiter", rcsLimiter*30). }
		}
		
		IF(c_diffVector:X > ABS(minDiff/2)) {
			//SET SHIP:CONTROL:FORE TO thrustPercent*(c_diffVector:X/base_acceleration). SET rcsX TO TRUE. 
			SET SHIP:CONTROL:FORE TO thrustPercent*sign(c_diffVector:X). SET rcsX TO TRUE. 
			}
		ELSE {
			SET rcsX TO FALSE. }
	
		IF(c_diffVector:Y > ABS(minDiff/2)) {
			//SET SHIP:CONTROL:TOP TO thrustPercent*(c_diffVector:Y/base_acceleration). SET rcsY TO TRUE. 
			SET SHIP:CONTROL:TOP TO thrustPercent*sign(c_diffVector:Y). SET rcsY TO TRUE. 
			}
		ELSE {
			SET rcsY TO FALSE. }
	
		IF(c_diffVector:Z > ABS(minDiff/2)) {
			//SET SHIP:CONTROL:STARBOARD TO thrustPercent*(c_diffVector:Z/base_acceleration). SET rcsZ TO TRUE. 
			SET SHIP:CONTROL:STARBOARD TO thrustPercent*sign(c_diffVector:Z). SET rcsZ TO TRUE. 
			}
		ELSE {
			SET rcsZ TO FALSE. }
	
	
		CLEARSCREEN.
		PRINT ("Reducing velocity difference. . . " + modeString).
		PRINT "---------------------------------------------".
		PRINT "X: " + c_diffVector:X.
		PRINT "Y: " + c_diffVector:Y.
		PRINT "Z: " + c_diffVector:Z.	
		SET wv TO VECDRAWARGS(SHIP:POSITION, horizontalVelocity*5,RED,"horizontal velocity",1,TRUE).
		//SET dv TO VECDRAWARGS(SHIP:POSITION, horizontalVector,RED,"Horizontal vector",1,TRUE).
	}	
	
	//Stop thrusters, revert limiter changes
	SET SHIP:CONTROL:FORE TO 0.
	SET SHIP:CONTROL:TOP TO 0.
	SET SHIP:CONTROL:STARBOARD TO 0.
	FOR block IN rcsList {
		block:SETFIELD("thrust limiter", 100).
	}	

	
//--------------------------------------------------------------------------\
//								Program end					   				|
//--------------------------------------------------------------------------/
	
	
	//Returns user control
	SET SHIP:CONTROL:NEUTRALIZE to TRUE.
	SAS OFF.
	RCS OFF.
	
	//Unlock all variables		
	UNLOCK Xa.
	UNLOCK Ya.
	UNLOCK Za.
	UNLOCK c_relVel.
	UNLOCK c_diffVector.	
	UNLOCK thrustPercent.
	UNLOCK STEERING.
	UNLOCK THROTTLE.
	
	WAIT 1.
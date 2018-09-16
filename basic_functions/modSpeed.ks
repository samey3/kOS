	CLEARSCREEN.

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER toSpeed.	
	PARAMETER timeToPoint IS 0.
	PARAMETER timeLimit IS 5.
	
	
//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/


	RUNONCEPATH("lib/shipControl.ks").
	
	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/		
			
			
	//--------------------------------------\
	//VECTORS-------------------------------|		
						
		//Custom axis		
		LOCAL LOCK Xa TO SHIP:FACING:FOREVECTOR.
		LOCAL LOCK Ya TO SHIP:FACING:TOPVECTOR.
		LOCAL LOCK Za TO SHIP:FACING:STARVECTOR.

		//To desired velocity and relative velocity vectors (custom axis)
		LOCAL LOCK toVector TO V(VDOT(SHIP:VELOCITY:ORBIT,Xa),VDOT(SHIP:VELOCITY:ORBIT,Ya),VDOT(SHIP:VELOCITY:ORBIT,Za)):NORMALIZED*toSpeed.
		LOCAL LOCK c_relVel TO V(VDOT((SHIP:VELOCITY:ORBIT),Xa),VDOT((SHIP:VELOCITY:ORBIT),Ya),VDOT((SHIP:VELOCITY:ORBIT),Za)).
		LOCAL LOCK differenceVec TO (toVector - c_relVel).	
		
		//Minor changes, nearly identical to modVelocity.
		//Modified toVector and c_relVel. toVector is just orbital velocity normalized, times the desired speed.
		//c_relVel measures its orbital velocity relative to the body.
		//Changed minDiff to 0. should always use a time limit for now.
		
		
	//--------------------------------------\
	//RCS-----------------------------------|
	
		//RCS max thrust limit
		LOCAL rcsLimiter IS (SHIP:MASS/2.6).

		//Sets up the RCS thrusters
		SET rcsList TO LIST().
		LIST parts IN partList.
		FOR part IN partList {
			FOR module IN part:modules {
				IF (module = "ModuleRCSFX") { rcsList:ADD(part:getmodule("ModuleRCSFX")). } //Maybe shouldn't limit them to 25 here? Also depends on velocity difference
			}
		}	
		FOR block IN rcsList {
			block:SETFIELD("thrust limiter", rcsLimiter*10).
		}
		
		//RCS parameters
		SET total_rcs_thrust TO rcsList:LENGTH*0.35/2. //kN. Can set to the length of the list because each thruster is only 1kN
		SET base_acceleration TO total_rcs_thrust / SHIP:MASS.
			LOCAL LOCK thrustPercent TO ((base_acceleration * SHIP:MASS) / total_rcs_thrust).
			LOCAL minDiff IS 0. //((0.05*base_acceleration)/thrustPercent). //Based on minimal possible thrust, how close a velocity value should be obtained to the desired one
			
		//Axis difference status
		LOCAL rcsX IS True.
		LOCAL rcsY IS True.
		LOCAL rcsZ IS True.
	

//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	//Disables user control
	SET CONTROLSTICK to SHIP:CONTROL.
	LOCK STEERING TO smoothRotate(SHIP:FACING).
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
	
	
	//Maybe try running thrust at 100%, but scale down the thrust limiter as it approaches?
	
	
	UNTIL ((rcsX = False AND rcsY = False AND rcsZ = False) OR ((timeLimit <> 0) AND ((TIME:SECONDS - startTime) >= timeLimit))){	
		IF (modeString <> "(low speed)" AND differenceVec:MAG <= 0.02) {
			SET modeString TO "(low speed)".
			FOR block IN rcsList {
				block:SETFIELD("thrust limiter", rcsLimiter*1). }
		}
		
		IF(differenceVec:X > minDiff OR differenceVec:X < -minDiff) {
			SET SHIP:CONTROL:FORE TO thrustPercent*(differenceVec:X/base_acceleration)*40. SET rcsX TO TRUE. }
		ELSE {
			SET rcsX TO FALSE. }
	
		IF(differenceVec:Y > minDiff OR differenceVec:Y < -minDiff) {
			SET SHIP:CONTROL:TOP TO thrustPercent*(differenceVec:Y/base_acceleration)*40. SET rcsY TO TRUE. }
		ELSE {
			SET rcsY TO FALSE. }
	
		IF(differenceVec:Z > minDiff OR differenceVec:Z < -minDiff) {
			SET SHIP:CONTROL:STARBOARD TO thrustPercent*(differenceVec:Z/base_acceleration)*40. SET rcsZ TO TRUE. }
		ELSE {
			SET rcsZ TO FALSE. }
	
	
		CLEARSCREEN.
		PRINT ("Reducing velocity difference. . . " + modeString).
		PRINT "---------------------------------------------".
		PRINT "X: " + differenceVec:X.
		PRINT "Y: " + differenceVec:Y.
		PRINT "Z: " + differenceVec:Z.	
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
	RCS OFF.
	
	//Unlock all variables		
	UNLOCK Xa.
	UNLOCK Ya.
	UNLOCK Za.
	UNLOCK c_relVel.
	UNLOCK differenceVec.	
	UNLOCK thrustPercent.
	UNLOCK STEERING.
	UNLOCK THROTTLE.
	
	WAIT 1.
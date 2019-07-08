	CLEARSCREEN.

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER hostObj.
	PARAMETER toVector.	
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

		LOCAL LOCK normalVec TO (hostObj:POSITION - BODY:POSITION).
			
		LOCAL LOCK positionVec TO (hostObj:POSITION - SHIP:POSITION).
		LOCAL LOCK toVelVec TO projectToPlane(positionVec:NORMALIZED*(positionVec:MAG/10), normalVec).		
		
			
			
	//--------------------------------------\
	//VECTORS-------------------------------|		
						
		//Custom axis		
		LOCAL LOCK Xa TO SHIP:FACING:FOREVECTOR.
		LOCAL LOCK Ya TO SHIP:FACING:TOPVECTOR.
		LOCAL LOCK Za TO SHIP:FACING:STARVECTOR.

		//To desired velocity and relative velocity vectors (custom axis)
		//LOCAL toVector IS V(VDOT(toVector,Xa),VDOT(toVector,Ya),VDOT(toVector,Za)).
		//LOCAL LOCK c_relVel TO V(VDOT((SHIP:VELOCITY:ORBIT - hostObj:VELOCITY:ORBIT),Xa),VDOT((SHIP:VELOCITY:ORBIT - hostObj:VELOCITY:ORBIT),Ya),VDOT((SHIP:VELOCITY:ORBIT - hostObj:VELOCITY:ORBIT),Za)).
		//LOCAL LOCK differenceVec TO (toVector - c_relVel).	

		
		//toVector
		LOCAL LOCK differenceVector TO (toVelVec - (SHIP:VELOCITY:ORBIT - hostObj:VELOCITY:ORBIT)).
		LOCAL LOCK differenceVec TO V(VDOT(differenceVector,Xa),VDOT(differenceVector,Ya),VDOT(differenceVector,Za)).

		
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
			//block:SETFIELD("thrust limiter", rcsLimiter*10).
		}
		
		//RCS parameters
		SET total_rcs_thrust TO rcsList:LENGTH*0.35/2. //kN. Can set to the length of the list because each thruster is only 1kN
		SET base_acceleration TO total_rcs_thrust / SHIP:MASS.
			LOCAL LOCK thrustPercent TO ((base_acceleration * SHIP:MASS) / total_rcs_thrust).
			LOCAL minDiff IS ((0.05*base_acceleration)/thrustPercent). //Based on minimal possible thrust, how close a velocity value should be obtained to the desired one
			
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
	
	UNTIL ((rcsX = False AND rcsY = False AND rcsZ = False) OR ((timeLimit <> 0) AND ((TIME:SECONDS - startTime) >= timeLimit))){	
		IF (modeString <> "(low speed)" AND differenceVec:MAG <= 0.2) {
			SET modeString TO "(low speed)".
			FOR block IN rcsList {
				//block:SETFIELD("thrust limiter", rcsLimiter*10). 
			}
		}
		
		IF(differenceVec:X > minDiff OR differenceVec:X < -minDiff) {
			//SET SHIP:CONTROL:FORE TO thrustPercent*(differenceVec:X/base_acceleration). SET rcsX TO TRUE. }
			SET SHIP:CONTROL:FORE TO thrustPercent*(differenceVec:NORMALIZED:X/2). SET rcsX TO TRUE. }
		ELSE {
			//SET rcsX TO FALSE. 
			}
	
		IF(differenceVec:Y > minDiff OR differenceVec:Y < -minDiff) {
			//SET SHIP:CONTROL:TOP TO thrustPercent*(differenceVec:Y/base_acceleration). SET rcsY TO TRUE. }
			SET SHIP:CONTROL:TOP TO thrustPercent*(differenceVec:NORMALIZED:Y). SET rcsY TO TRUE. }
		ELSE {
			//SET rcsY TO FALSE. 
			}
	
		IF(differenceVec:Z > minDiff OR differenceVec:Z < -minDiff) {
			//SET SHIP:CONTROL:STARBOARD TO thrustPercent*(differenceVec:Z/base_acceleration). SET rcsZ TO TRUE. }
			SET SHIP:CONTROL:STARBOARD TO thrustPercent*(differenceVec:NORMALIZED:Z). SET rcsZ TO TRUE. }
		ELSE {
			//SET rcsZ TO FALSE. 
			}
	
	
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
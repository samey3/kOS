//Imports smoothRotate
runoncepath("lib/shipControl.ks").


FUNCTION nodeBurn {
		CLEARSCREEN.

	//--------------------------------------------------------------------------\
	//								Parameters					   				|
	//--------------------------------------------------------------------------/


		PARAMETER _timeToPeak. 
		PARAMETER _burnDV.
		PARAMETER _dirVector IS V(0,0,0).
		
		
	//--------------------------------------------------------------------------\
	//							 Reboot conditions					   			|
	//--------------------------------------------------------------------------/
		
		
		//Finds the likely available deltaV
		LOCAL totalISP IS 0. LOCAL numEngines IS 0. LIST ENGINES IN eng_list.
		FOR e IN eng_list {
			IF(e:IGNITION){
				SET totalISP TO totalISP + e:ISP.
				SET numEngines TO numEngines + 1.
			}
		}
		LOCAL delta_v IS 9.80665*(totalISP/numEngines)*LN(SHIP:WETMASS/SHIP:DRYMASS).
		
		IF(SHIP:AVAILABLETHRUST = 0) {PRINT("No thrust").}
		IF(_dirVector = V(0,0,0)) {PRINT("No vector").}
		IF(delta_v < _burnDV) {PRINT("No DV").}
		
		IF(SHIP:AVAILABLETHRUST = 0 OR _dirVector = V(0,0,0) OR delta_v < _burnDV){	
			PRINT ("Operation conditions not met ( " + SCRIPTPATH():NAME + " ).").
			PRINT ("Rebooting. . ."). 
			WAIT 3. REBOOT.
		}
		
		
	//--------------------------------------------------------------------------\
	//								Variables					   				|
	//--------------------------------------------------------------------------/


		//Heading direction
		LOCAL orbNormal IS VCRS(SHIP:POSITION - SHIP:BODY:POSITION, SHIP:VELOCITY:ORBIT).	
		IF _dirVector = 1 {
			LOCK t_vec TO SHIP:VELOCITY:ORBIT. } //Orbit prograde
		ELSE IF _dirVector = 2 {
			LOCK t_vec TO -SHIP:VELOCITY:ORBIT. } //Orbit retrograde
		ELSE IF _dirVector = 3 {
			LOCK t_vec TO SHIP:VELOCITY:SURFACE. } //Surface prograde
		ELSE IF _dirVector = 4 {
			LOCK t_vec TO -SHIP:VELOCITY:SURFACE. } //Surface retrograde
		ELSE IF _dirVector = 5 {
			LOCK t_vec TO -orbNormal. } //Radial 'up' (LH)
		ELSE IF _dirVector = 6 {
			LOCK t_vec TO orbNormal. } //Radial 'down' (LH)
		ELSE IF _dirVector = 7 {
			LOCK t_vec TO VCRS(-orbNormal, VELOCITY:ORBIT). } //Normal 'out' (LH)
		ELSE IF _dirVector = 8 {
			LOCK t_vec TO VCRS(orbNormal, VELOCITY:ORBIT). } //Normal 'in' (LH)
		ELSE {
			SET t_vec TO _dirVector. } //Custom direction (Must predict ahead of time)

		
		//Burn parameters
		SET base_acceleration TO SHIP:AVAILABLETHRUST / SHIP:MASS. //Mass in metric tonnes	
			SET burnTime TO _burnDV / base_acceleration.
			LOCK thrustPercent TO (base_acceleration * SHIP:MASS) / SHIP:AVAILABLETHRUST.
			
			
		//Burn timing
		SET startTime TO TIME:SECONDS + _timeToPeak.
		LOCK timeLeft TO (startTime - TIME:SECONDS).
		
		//Wait time for info
		LOCAL waitTime IS 1.
		
		
		//Expected final vector
		//This won't work properly on longer burns
		//LOCAL velFuture IS VELOCITYAT(SHIP, TIME:SECONDS + _timeToPeak). // + burnTime/2
		//LOCAL expectedVector IS velFuture:ORBIT + t_vec*_burnDV. //Need to find the expected vector at Apo + 1/2 burnTime


	//--------------------------------------------------------------------------\
	//								Program run					   				|
	//--------------------------------------------------------------------------/


		//Disables user control
		SET CONTROLSTICK to SHIP:CONTROL. 
		SAS ON.
		RCS OFF. //ON.
		WAIT waitTime. //Incase ship was moving
		
		
		//Warp to the position,
		PRINT("     Node-burn subscript     ").
		PRINT("-----------------------------").
		PRINT("Warping to burn position. . .").
		KUNIVERSE:TIMEWARP:WARPTO(startTime - waitTime - (burnTime/2 + 20)).
		WAIT UNTIL WARP = 0 and SHIP:UNPACKED.
		
		
		//(TRIGGER) Once there are 20 seconds until the start of the burn, orientate
		WHEN (timeLeft <= (burnTime/2 + 20)) THEN { LOCK STEERING TO smoothRotate(t_vec:DIRECTION). }
		
		//Display info until the burn starts
		UNTIL timeLeft <= burnTime/2{
			CLEARSCREEN.
			PRINT "Node-burn subscript".
			PRINT "--------------------".
			PRINT "ΔV 					: " + (ROUND(_burnDV*10)/10)  + " m/s".
			PRINT "Burn time 			: " + (ROUND(burnTime*10)/10)  + " s".
			PRINT " ".
			IF(timeLeft > (burnTime/2 + 20)){
				PRINT "Time to orientation  : " + (ROUND((timeLeft - burnTime/2 - 20)*10)/10) + " s". }
			ELSE {
				PRINT "Time to orientation	: Orientating . . .". }		
			PRINT "Time to burn  		: " + (ROUND((timeLeft - burnTime/2)*10)/10) + " s".
			
			SET bv TO VECDRAWARGS(SHIP:POSITION, t_vec:NORMALIZED*10,RED,"Thrust vector",1,TRUE).
			
			WAIT 0.1.
		}
		
		
		//Perform the burn
		LOCK THROTTLE TO thrustPercent. 

		IF(burnTime > 1.5){
			WAIT burnTime - 1.
				//Throttles down linearly for the last 2 seconds
				LOCAL timer IS TIME:SECONDS + 2.
				LOCK THROTTLE TO 0.5*thrustPercent*(timer - TIME:SECONDS).		
				WAIT 2.		
		}
		ELSE {
			WAIT burnTime.
		}	
		LOCK THROTTLE TO 0.	
		
		
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
		UNLOCK differenceVec.	
		UNLOCK thrustPercent.
		UNLOCK STEERING.
		UNLOCK THROTTLE.
		
		//Remove drawn vectors
		CLEARVECDRAWS().
		
		WAIT 1.
}

FUNCTION nodeInclinationBurn {
		CLEARSCREEN.

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _timeToPeak. 
	PARAMETER _inclinationChange.
	
	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/

	
	LOCAL velFuture IS VELOCITYAT(SHIP, TIME:SECONDS + _timeToPeak).
	LOCAL orbNormal IS VCRS(SHIP:POSITION - SHIP:BODY:POSITION, SHIP:VELOCITY:ORBIT):NORMALIZED.
	LOCAL e_vec IS (-orbNormal*(TAN(_inclinationChange)*velFuture:ORBIT:MAG) + velFuture:ORBIT):NORMALIZED * velFuture:ORBIT:MAG.
		IF(_inclinationChange < 0){
			//SET e_vec TO -e_vec. 
			//WORKED FINE BEFORE COMMENTING???
			
			//This function needs fixing, its not entirely accurate, 0.7 degrees???? off and such sometimes.
		}

	LOCAL t_vec IS (e_vec - velFuture:ORBIT).
	LOCAL _burnDV IS t_vec:MAG.
	
	
	//For info display
	LOCAL waitTime IS 3.
	

//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	SET ev TO VECDRAWARGS(SHIP:POSITION, e_vec:NORMALIZED*10,BLUE,"Inclined vector",1,TRUE).
	SET cv TO VECDRAWARGS(SHIP:POSITION, velFuture:ORBIT:NORMALIZED*10,GREEN,"Current vector",1,TRUE).
	
	PRINT("   Modifying orbit inclination   ").
	PRINT("---------------------------------").
	PRINT("(+ is above the plane in LHR up)").
	PRINT(" ").
	PRINT("Inclination change : " + ROUND(_inclinationChange*10)/10 + " degrees").	
	WAIT waitTime.
	
	//Calls the nodeBurn
	nodeBurn(_timeToPeak - waitTime, (e_vec - velFuture:ORBIT):MAG, (e_vec - velFuture:ORBIT)).
	
	
//--------------------------------------------------------------------------\
//								Program end					   				|
//--------------------------------------------------------------------------/


	//Remove drawn vectors
	CLEARVECDRAWS().
}


FUNCTION modSpeed {
		CLEARSCREEN.

	//--------------------------------------------------------------------------\
	//								Parameters					   				|
	//--------------------------------------------------------------------------/


		PARAMETER toSpeed.	
		PARAMETER timeToPoint IS 0.
		PARAMETER timeLimit IS 5.
		
		
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
		SAS OFF.
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
}

FUNCTION modVelocity {
		CLEARSCREEN.

	//--------------------------------------------------------------------------\
	//								Parameters					   				|
	//--------------------------------------------------------------------------/


		PARAMETER hostObj.
		PARAMETER toVector.	
		PARAMETER timeToPoint IS 0.
		PARAMETER timeLimit IS 0.
		
		
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
			SET toVector TO V(VDOT(toVector,Xa),VDOT(toVector,Ya),VDOT(toVector,Za)).
			LOCAL LOCK c_relVel TO V(VDOT((SHIP:VELOCITY:ORBIT - hostObj:VELOCITY:ORBIT),Xa),VDOT((SHIP:VELOCITY:ORBIT - hostObj:VELOCITY:ORBIT),Ya),VDOT((SHIP:VELOCITY:ORBIT - hostObj:VELOCITY:ORBIT),Za)).
			LOCAL LOCK differenceVec TO (toVector - c_relVel).	

			
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
		
		UNTIL ((rcsX = False AND rcsY = False AND rcsZ = False) OR ((timeLimit <> 0) AND ((TIME:SECONDS - startTime) >= timeLimit))){	
			IF (modeString <> "(low speed)" AND differenceVec:MAG <= 0.2) {
				SET modeString TO "(low speed)".
				FOR block IN rcsList {
					block:SETFIELD("thrust limiter", rcsLimiter*10). }
			}
			
			IF(differenceVec:X > minDiff OR differenceVec:X < -minDiff) {
				SET SHIP:CONTROL:FORE TO thrustPercent*(differenceVec:X/base_acceleration). SET rcsX TO TRUE. }
			ELSE {
				SET rcsX TO FALSE. }
		
			IF(differenceVec:Y > minDiff OR differenceVec:Y < -minDiff) {
				SET SHIP:CONTROL:TOP TO thrustPercent*(differenceVec:Y/base_acceleration). SET rcsY TO TRUE. }
			ELSE {
				SET rcsY TO FALSE. }
		
			IF(differenceVec:Z > minDiff OR differenceVec:Z < -minDiff) {
				SET SHIP:CONTROL:STARBOARD TO thrustPercent*(differenceVec:Z/base_acceleration). SET rcsZ TO TRUE. }
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
		SAS OFF.
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
}
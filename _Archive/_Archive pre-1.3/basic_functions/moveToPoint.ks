	CLEARSCREEN.

//---------------------------------------------------------------------------------\
//				  					Parameters									   |
//---------------------------------------------------------------------------------/


	PARAMETER hostObj.
	PARAMETER hostToPointVec. //Vector extending from host object
	PARAMETER faceDir IS 0. //Direction to face during move (Default 0 is current facing).
	
	
//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/


	RUNONCEPATH("lib/shipControl.ks").
	

//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/


	//-----------------------------------------\
	//Find vessel root-------------------------|
		LOCAL shipRoot IS hostObj.
		IF(hostObj:ISTYPE("Part")) {
			SET shipRoot TO hostObj:SHIP.
		}


	//-----------------------------------------\
	//Custom axis------------------------------|
		LOCAL LOCK Xa TO SHIP:FACING:FOREVECTOR.
		LOCAL LOCK Ya TO SHIP:FACING:TOPVECTOR.
		LOCAL LOCK Za TO SHIP:FACING:STARVECTOR.


	//-----------------------------------------\
	//Relative position vectors----------------|
		LOCAL LOCK toPointVector TO (hostObj:POSITION + hostToPointVec) - SHIP:POSITION.
		LOCAL LOCK c_toPointVector TO V(VDOT(toPointVector,Xa),VDOT(toPointVector,Ya),VDOT(toPointVector,Za)). //Custom axis
	
	
	//-----------------------------------------\
	//RCS--------------------------------------|
	
		//Movement
		SET rcsList TO SHIP:PARTSNAMED("RCSBlock").	
		SET total_rcs_thrust TO rcsList:LENGTH/2. //kN. Can set to the length of the list because each thruster is only 1kN
		SET base_acceleration TO total_rcs_thrust / SHIP:MASS. //Mass in metric tonnes	
		LOCAL LOCK thrustPercent TO ((base_acceleration * SHIP:MASS) / total_rcs_thrust).
		IF(toPointVector:MAG < 10){
			SET moveSpeed TO SQRT(2*base_acceleration*toPointVector:MAG*(3/8)). }
		ELSE{
			SET moveSpeed TO SQRT(0.2*toPointVector:MAG*base_acceleration).	}
			
		SET thrustTime TO moveSpeed/base_acceleration.
				
		//RCS blocks and thrust limits
		SET rcsList TO list().
		LIST PARTS IN partList.
		FOR part IN partList
		{
			FOR module IN PART:MODULES
			{
				IF module = "ModuleRCSFX"
				{
					rcsList:ADD(PART:GETMODULE("ModuleRCSFX")).
				}
			}
		}
	
	
	//-----------------------------------------\
	//Relative velocity------------------------|
	
		//Gets the relative velocity vectors
		LOCAL LOCK relVel TO (SHIP:VELOCITY:ORBIT - shipRoot:VELOCITY:ORBIT).
		LOCAL LOCK c_relVel TO V(VDOT(relVel,Xa),VDOT(relVel,Ya),VDOT(relVel,Za)).	

		//Difference variables
		LOCAL LOCK differenceVec TO (c_toPointVector:NORMALIZED*moveSpeed - c_relVel).
		SET correctionAcceleration TO base_acceleration*0.05.
	
		//Distance to deceleration start
		LOCAL distStart IS 0.5*base_acceleration*thrustTime^2. //This was a SET before, but this likely works better?
	
	
	//-----------------------------------------\
	//Drawn vectors----------------------------|
		
		SET htp TO VECDRAWARGS(hostObj:POSITION, hostToPointVec,YELLOW,"Host vector",1,TRUE).
		SET stp TO VECDRAWARGS(SHIP:POSITION, toPointVector,RED,"Ship vector",1,TRUE).
	
	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	//-----------------------------------------\
	//Output header info-----------------------|
		PRINT("     Move-to point subscript     ").
		PRINT("---------------------------------").
		PRINT("Distance : " + (ROUND(toPointVector:MAG*10)/10) + " meters").


	//-----------------------------------------\
	//Reduce relative velocity, orientate------|
		RUNPATH("basic_functions/modVelocity.ks", shipRoot, V(0,0,0)).
		IF(faceDir = 0){
			SET dir TO SHIP:FACING.
			LOCK STEERING TO smoothRotate(dir).
			WAIT UNTIL SHIP:ANGULARMOMENTUM:MAG < 0.1.
		}
		ELSE IF (faceDir = 1){
			LOCK STEERING TO smoothRotate(LOOKDIRUP(((hostObj:POSITION + hostToPointVec)-SHIP:POSITION), shipRoot:FACING:TOPVECTOR)). //targetCraft
			WAIT UNTIL VECTORANGLE(SHIP:FACING:VECTOR,((hostObj:POSITION + hostToPointVec)-SHIP:POSITION)) < 0.3 AND SHIP:ANGULARMOMENTUM:MAG < 0.025.
			//SET dir TO SHIP:FACING.
			//LOCK STEERING TO smoothRotate(dir).
		}
		RUNPATH("basic_functions/modVelocity.ks", shipRoot, V(0,0,0)).
	
	
	//-----------------------------------------\
	//Disable user control, enable systems-----|
		SET CONTROLSTICK to SHIP:CONTROL. 
		SAS ON.
		RCS ON.
	
	
//---------------------------------------------\
//				  	Accelerate				   |
//---------------------------------------------/


	SET SHIP:CONTROL:FORE TO thrustPercent*c_toPointVector:NORMALIZED:X/2. 
	SET SHIP:CONTROL:TOP TO thrustPercent*c_toPointVector:NORMALIZED:Y.
	SET SHIP:CONTROL:STARBOARD TO thrustPercent*c_toPointVector:NORMALIZED:Z.
	WAIT thrustTime.
	SET SHIP:CONTROL:FORE TO 0. 
	SET SHIP:CONTROL:TOP TO 0.
	SET SHIP:CONTROL:STARBOARD TO 0.
	

//---------------------------------------------\
//				  Maintain velocity			   |
//---------------------------------------------/
		

	//Sets the thrust limit for all RCS blocks
	FOR block IN rcsList {
		block:SETFIELD("thrust limiter", 10).
	}
	
	//Manage velocity until deceleration distance
	UNTIL (toPointVector:MAG <= distStart) {	
		if(differenceVec:X > 0) {
			SET SHIP:CONTROL:FORE TO thrustPercent*(differenceVec:X/correctionAcceleration). SET rcsX TO TRUE. }
		ELSE IF(differenceVec:X < 0) {
			SET SHIP:CONTROL:FORE TO thrustPercent*(differenceVec:X/correctionAcceleration). SET rcsX TO TRUE. }

		if(differenceVec:Y > 0) {
			SET SHIP:CONTROL:TOP TO thrustPercent*(differenceVec:Y/correctionAcceleration). SET rcsY TO TRUE. }
		ELSE IF(differenceVec:Y < 0) {
			SET SHIP:CONTROL:TOP TO thrustPercent*(differenceVec:Y/correctionAcceleration). SET rcsY TO TRUE. }

		if(differenceVec:Z > 0) {
			SET SHIP:CONTROL:STARBOARD TO thrustPercent*(differenceVec:Z/correctionAcceleration). SET rcsZ TO TRUE. }
		ELSE IF(differenceVec:Z < 0) {
			SET SHIP:CONTROL:STARBOARD TO thrustPercent*(differenceVec:Z/correctionAcceleration). SET rcsZ TO TRUE. }
			
			
		//Output info to terminal
		CLEARSCREEN.
		PRINT("     Move-to point subscript     ").
		PRINT("---------------------------------").
		PRINT("Distance to deceleration : " + (ROUND((toPointVector:MAG - distStart)*10)/10) + " m").
		PRINT(" ").
		PRINT "Difference components".
		PRINT "-----------------------------------------".
		PRINT "X: " + differenceVec:X.
		PRINT "Y: " + differenceVec:Y.
		PRINT "Z: " + differenceVec:Z.
			
		//Resets the vectors
		SET htp TO VECDRAWARGS(hostObj:POSITION, hostToPointVec,YELLOW,"Host vector",1,TRUE).
		SET stp TO VECDRAWARGS(SHIP:POSITION, toPointVector,RED,"Ship vector",1,TRUE).
	}

	
	//Resets all RCS block thrust limiters
	FOR block IN rcsList {
		block:SETFIELD("thrust limiter", 100).
	}
	
	
//---------------------------------------------\
//				  	Decelerate				   |
//---------------------------------------------/
	
	
	//Output info to terminal
	CLEARSCREEN.
	PRINT("~~~~~Move-to point subscript~~~~~").
	PRINT("---------------------------------").
	PRINT("Decelerating. . . . . . . . . . .").

	LOCK STEERING TO smoothRotate(SHIP:FACING).
	SET SHIP:CONTROL:FORE TO -thrustPercent*c_toPointVector:NORMALIZED:X/2. 
	SET SHIP:CONTROL:TOP TO -thrustPercent*c_toPointVector:NORMALIZED:Y.
	SET SHIP:CONTROL:STARBOARD TO -thrustPercent*c_toPointVector:NORMALIZED:Z.
	WAIT thrustTime.
	SET SHIP:CONTROL:FORE TO 0. 
	SET SHIP:CONTROL:TOP TO 0.
	SET SHIP:CONTROL:STARBOARD TO 0.
	
	//If not docking, cancel relative velocity
	if(hostToPointVec:MAG > 4){
		RUNPATH("basic_functions/modVelocity.ks", shipRoot, V(0,0,0)). }	
	
	
//--------------------------------------------------------------------------\
//								Program end					   				|
//--------------------------------------------------------------------------/	
	
	
	//Outputs the error distance to the desired point
	CLEARSCREEN.
	PRINT("~~~~~Move-to point subscript~~~~~").
	PRINT("---------------------------------").
	PRINT("Error distance : " + (ROUND((((hostObj:POSITION + hostToPointVec) - SHIP:POSITION):MAG)*100)/100) + " meters").
	
	//Returns user control
	SET SHIP:CONTROL:NEUTRALIZE to TRUE.
	SAS OFF.
	RCS OFF.
	
	//Unlock all variables		
	UNLOCK Xa.
	UNLOCK Ya.
	UNLOCK Za.	
	UNLOCK toPointVector.
	UNLOCK c_toPointVector.	
	UNLOCK thrustPercent.
	UNLOCK relVel.
	UNLOCK c_relVel.	
	UNLOCK differenceVec.
	UNLOCK distStart.	
	UNLOCK STEERING.
	UNLOCK THROTTLE.
	
	//Remove drawn vectors
	CLEARVECDRAWS().
	
	WAIT 1.
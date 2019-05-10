	@lazyglobal OFF.
	CLEARSCREEN.

//---------------------------------------------------------------------------------\
//				  					Parameters									   |
//---------------------------------------------------------------------------------/


	PARAMETER hostObj.
	PARAMETER hostToPointVec. //Vector extending from host object
	PARAMETER faceDir IS 0. //Direction to face during move (Default 0 is current facing).
	

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
		LOCAL rcsList IS SHIP:PARTSNAMED("RCSBlock").	
		LOCAL total_rcs_thrust IS rcsList:LENGTH/2. //kN. Can set to the length of the list because each thruster is only 1kN
		LOCAL base_acceleration IS total_rcs_thrust / SHIP:MASS. //Mass in metric tonnes	
		LOCAL LOCK thrustPercent TO ((base_acceleration * SHIP:MASS) / total_rcs_thrust).
		LOCAL moveSpeed IS 0.
		IF(toPointVector:MAG < 10){
			SET moveSpeed TO SQRT(2*base_acceleration*toPointVector:MAG*(3/8)). }
		ELSE{
			SET moveSpeed TO SQRT(0.2*toPointVector:MAG*base_acceleration).	}
			
		LOCAL thrustTime IS moveSpeed/base_acceleration.
				
		//RCS blocks and thrust limits
		SET rcsList TO LIST().
		LOCAL partList IS LIST().
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
		LOCAL correctionAcceleration IS base_acceleration*0.05.
	
		//Distance to deceleration start
		LOCAL distStart IS 0.5*base_acceleration*thrustTime^2. //This was a SET before, but this likely works better?
	
	
	//-----------------------------------------\
	//Drawn vectors----------------------------|
	
		LOCAL contTime IS 0.
		LOCAL htp IS 0.
		LOCAL stp IS 0.

	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	//-----------------------------------------\
	//Disable user control, enable systems-----|
		SET CONTROLSTICK to SHIP:CONTROL.
		LOCAL initFace IS SHIP:FACING. //Redundant, remove this on the next cleanup
		LOCK faceDirection TO initFace.
		LOCK STEERING TO faceDirection.

	//-----------------------------------------\
	//Output header info-----------------------|
		PRINT("      Mission Ops - Dock      ").
		PRINT("------------------------------").
		PRINT("Distance : " + (ROUND(toPointVector:MAG*10)/10) + " meters").
		
	//-----------------------------------------\
	//Draw vectors-----------------------------|
		SET htp TO VECDRAWARGS(hostObj:POSITION, hostToPointVec, YELLOW, "Host vector", 1, TRUE).
		SET stp TO VECDRAWARGS(SHIP:POSITION, toPointVector, RED, "Ship vector", 1, TRUE).
	
	//-----------------------------------------\
	//Reduce relative velocity, orientate------|
		RUNPATH("mission operations/basic functions/modVelocity.ks", shipRoot, V(0,0,0)).
		RCS ON.
		IF(faceDir = 0){
			WAIT UNTIL SHIP:ANGULARMOMENTUM:MAG < 0.1.
		}
		ELSE IF (faceDir = 1){
			LOCK faceDirection TO LOOKDIRUP(((hostObj:POSITION + hostToPointVec)-SHIP:POSITION), shipRoot:FACING:TOPVECTOR). //targetCraft
			LOCK STEERING TO faceDirection.
			WAIT UNTIL VECTORANGLE(SHIP:FACING:VECTOR,((hostObj:POSITION + hostToPointVec)-SHIP:POSITION)) < 0.3 AND SHIP:ANGULARMOMENTUM:MAG < 0.025.
		}
		RUNPATH("mission operations/basic functions/modVelocity.ks", shipRoot, V(0,0,0)).
		

//---------------------------------------------\
//				  	Accelerate				   |
//---------------------------------------------/

	RCS ON.
	LOCK STEERING TO faceDirection.
	
	SET SHIP:CONTROL:FORE TO thrustPercent*c_toPointVector:NORMALIZED:X/2. 
	SET SHIP:CONTROL:TOP TO thrustPercent*c_toPointVector:NORMALIZED:Y.
	SET SHIP:CONTROL:STARBOARD TO thrustPercent*c_toPointVector:NORMALIZED:Z.

	SET contTime TO TIME:SECONDS + thrustTime.
	UNTIL (TIME:SECONDS >= contTime){
		//Redraw the vectors
		SET htp TO VECDRAWARGS(hostObj:POSITION, hostToPointVec, YELLOW, "Host vector", 1, TRUE).
		SET stp TO VECDRAWARGS(SHIP:POSITION, toPointVector, RED, "Ship vector", 1, TRUE).
	}

	SET SHIP:CONTROL:FORE TO 0. 
	SET SHIP:CONTROL:TOP TO 0.
	SET SHIP:CONTROL:STARBOARD TO 0.
	

//---------------------------------------------\
//				  Maintain velocity			   |
//---------------------------------------------/
		

	//Sets the thrust limit for all RCS blocks
	setRCSThrust(rcsList, 10).
	
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
		PRINT("      Mission Ops - Dock      ").
		PRINT("------------------------------").
		PRINT("Distance to deceleration : " + (ROUND((toPointVector:MAG - distStart)*10)/10) + " m").
		PRINT(" ").
		PRINT "Difference components".
		PRINT("------------------------------").
		PRINT "X: " + differenceVec:X.
		PRINT "Y: " + differenceVec:Y.
		PRINT "Z: " + differenceVec:Z.
			
		//Redraws the vectors
		SET htp TO VECDRAWARGS(hostObj:POSITION, hostToPointVec,YELLOW,"Host vector",1,TRUE).
		SET stp TO VECDRAWARGS(SHIP:POSITION, toPointVector,RED,"Ship vector",1,TRUE).
	}

	
	//Resets all RCS block thrust limiters
	setRCSThrust(rcsList, 100).
	
//---------------------------------------------\
//				  	Decelerate				   |
//---------------------------------------------/
	
	
	//Output info to terminal
	CLEARSCREEN.
	PRINT("      Mission Ops - Dock      ").
	PRINT("------------------------------").
	PRINT("Decelerating . . . . . . . . .").

	LOCK STEERING TO SHIP:FACING.
	SET SHIP:CONTROL:FORE TO -thrustPercent*c_toPointVector:NORMALIZED:X/2. 
	SET SHIP:CONTROL:TOP TO -thrustPercent*c_toPointVector:NORMALIZED:Y.
	SET SHIP:CONTROL:STARBOARD TO -thrustPercent*c_toPointVector:NORMALIZED:Z.
	
	SET contTime TO TIME:SECONDS + thrustTime.
	UNTIL (TIME:SECONDS >= contTime){
		//Redraw the vectors
		SET htp TO VECDRAWARGS(hostObj:POSITION, hostToPointVec, YELLOW, "Host vector", 1, TRUE).
		SET stp TO VECDRAWARGS(SHIP:POSITION, toPointVector, RED, "Ship vector", 1, TRUE).
	}
	
	SET SHIP:CONTROL:FORE TO 0. 
	SET SHIP:CONTROL:TOP TO 0.
	SET SHIP:CONTROL:STARBOARD TO 0.
	
	//If not docking, cancel relative velocity
	if(hostToPointVec:MAG > 4){
		RUNPATH("mission operations/basic functions/modVelocity.ks", shipRoot, V(0,0,0)). }	
	
	
//--------------------------------------------------------------------------\
//								Program end					   				|
//--------------------------------------------------------------------------/	
	
	
	//Outputs the error distance to the desired point
	CLEARSCREEN.
	PRINT("      Mission Ops - Dock      ").
	PRINT("------------------------------").
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
	
	
	
//--------------------------------------------------------------------------\
//								Functions					   				|
//--------------------------------------------------------------------------/
	
	
	//Set RCS thrust (0-100)
	FUNCTION setRCSThrust{
		PARAMETER _rcsList.
		PARAMETER _thrustValue.
		FOR block IN _rcsList {
			block:SETFIELD("thrust limiter", _thrustValue).
		}
	}
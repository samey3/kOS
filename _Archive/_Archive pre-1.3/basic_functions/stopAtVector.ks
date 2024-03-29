	@lazyglobal OFF.
	CLEARSCREEN.
	//Changed init from 0.90 to 0.80 to aid with bigger vessels
	//If in atmo, need to take into account drag deceleration with your ship deceleration
	
//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/

	
	PARAMETER _coordinates.
	PARAMETER _lockToRetrograde IS FALSE. //If true, lock to retrograde. If false, lock to -horizontalVelocity
	
	
//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/


	RUNONCEPATH("lib/shipControl.ks").
	RUNONCEPATH("lib/math.ks").
	
	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/


	//Relative properties
	LOCAL LOCK planeNormalVector TO (_coordinates:POSITION - BODY:POSITION).
	LOCAL LOCK horizontalVector TO projectToPlane((_coordinates:POSITION - SHIP:POSITION), planeNormalVector).
	
	LOCAL initialHorizontalVector IS projectToPlane((_coordinates:POSITION - SHIP:POSITION), planeNormalVector):NORMALIZED.
		LOCAL LOCK horizontalSpeed TO scalarProjection(SHIP:VELOCITY:SURFACE, initialHorizontalVector).
		LOCAL LOCK horizontalDistance TO scalarProjection((_coordinates:POSITION - SHIP:POSITION), initialHorizontalVector).

			
	LOCAL LOCK horizontalVelocity TO projectToPlane(SHIP:VELOCITY:SURFACE, planeNormalVector).
	
	//Steering properties
	LOCAL LOCK steeringScale TO 90*(ABS(COS(VANG(SHIP:VELOCITY:SURFACE, horizontalVelocity) + 0.5)) + ABS(SIN((VANG(SHIP:VELOCITY:SURFACE, horizontalVelocity) + 0.5)/2)) - 0.125).
	LOCAL LOCK test2 TO -(horizontalVector:DIRECTION*ANGLEAXIS(-(90 - steeringScale), VCRS(SRFPROGRADE:VECTOR, horizontalVector))):VECTOR.
	
	
	//Acceleration properties
	LOCAL base_acceleration IS (-SHIP:AVAILABLETHRUST/SHIP:MASS)*0.80. //Was working with 1.1 for atmosphere?	
	//LOCAL LOCK stopDistance TO (-(horizontalVelocity:MAG^2)/(2*base_acceleration)). //Work with 90% of the base_acceleration so that it can throttle up if need be
	LOCAL LOCK stopDistance TO (-(horizontalVelocity:MAG^2)/(2*base_acceleration)). //Work with 90% of the base_acceleration so that it can throttle up if need be
	
	//Drawn vectors
	LOCAL wv IS 0.
	LOCAL dv IS 0.
	LOCAL STEERV IS 0.
	LOCAL STEERV2 IS 0.
	
	
	//TEST
	//REPLACE THE 4 (WAS RCSLIST:LENGTH)
	LOCAL LOCK axisVector TO VCRS((SHIP:POSITION - BODY:POSITION), horizontalVector).
	LOCAL LOCK requiredHorizontalTrajectory TO horizontalVector:NORMALIZED*horizontalVelocity:MAG.
	
	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/





	//NEED TO DO
	//Recreate something for stopAtVector so it is not to the side
	//Perhaps modTrajectory again? Why isn't it working for non-atmo?
	//Perhaps modTrajectory might actually work decently on atmo bodies.



	//Make a proper orbital version? They all don't need RCS correction, perhaps make two distinct scripts.




	//Can run an iterative modTrajectory or something inside of these so that it doesn't go off.

	
	//If in atmo, can use DROGUE CHUTES HERE, AND CUT THEM AFTER THE FIRST SECTION
	
	//Until it gets to burn start
	RCS ON.	
	IF(_lockToRetrograde){
		//LOCK STEERING TO smoothRotate(-(horizontalVector:DIRECTION*ANGLEAXIS(-ABS(90 - steeringScale), VCRS(SRFPROGRADE:VECTOR, horizontalVector)))).		
		//LOCK STEERING TO smoothRotate(-(horizontalVector:DIRECTION*ANGLEAXIS(-30, VCRS(SRFPROGRADE:VECTOR, horizontalVector)))).		
				
		//LOCK STEERING TO smoothRotate(test2:DIRECTION).		
		LOCK STEERING TO (RETROGRADE). //Could probably use STFRETROGRADE if we predict using coordinates
		
		//LOCK STEERING TO smoothRotate((-(horizontalVector:NORMALIZED + (SIN(ABS(90 - steeringScale))/SIN(ABS(steeringScale)))*projectToPlane(SRFPROGRADE:VECTOR, horizontalVector):NORMALIZED)):DIRECTION).	
	}
	ELSE {
		LOCK STEERING TO ((-horizontalVelocity):DIRECTION).
	}
	
	
	
	
	//LOCK STEERING TO (-ADDONS:TR:PLANNEDVECTOR):DIRECTION.
	//ADDONS:TR:SETTARGET(_coordinates).
	//LOCK STEERING TO (-ADDONS:TR:CORRECTEDVECTOR):DIRECTION.
	//WAIT UNTIL (1 = 0).
	
	
	
	
	UNTIL (horizontalDistance <= stopDistance){		
		CLEARSCREEN.
		PRINT("Stop distance : " + stopDistance).
		PRINT("Distance to burn : " + (horizontalDistance - stopDistance)).
		SET wv TO VECDRAWARGS(_coordinates:POSITION, planeNormalVector:NORMALIZED*ALT:RADAR,GREEN,"Landing position",1,TRUE).
		SET dv TO VECDRAWARGS(SHIP:POSITION, horizontalVector,RED,"Horizontal vector",1,TRUE).
		SET STEERV TO VECDRAWARGS(SHIP:POSITION, test2:NORMALIZED*100,BLUE,"Steering",1,TRUE).		
		
		//REPLACE THE 4 (WAS RCSLIST:LENGTH)
		//RUNPATH("basic_functions/modTrajectory_iterative.ks", _coordinates).
		
		//Either of these works pretty well?
		//Improve one for more accuracy at higher latitudes
		//modVelocityPlane slightly better, maybe because it has no limiter and is constantly thrusting?
		//RUNPATH("basic_functions/modVelocityAxis_iterative.ks", V(0,0,0), axisVector, 4).
		RUNPATH("basic_functions/modVelocityPlane_iterative.ks", requiredHorizontalTrajectory, planeNormalVector, 4). //Matches the surface velocity
		
		
		//RUNPATH("basic_functions/modImpact_iterative.ks", _coordinates, 4). 
	}
	
	//Thrust properties
	LOCAL LOCK Ar TO (-((horizontalVelocity:MAG)^2)/(2*horizontalDistance)).
	LOCK max_acceleration TO -(SHIP:AVAILABLETHRUST*ABS(COS(VANG(SHIP:FACING:VECTOR, horizontalVelocity))))/SHIP:MASS.
	LOCAL LOCK thrustPercent TO Ar/max_acceleration.
	
	//Start burning
	LOCK THROTTLE TO thrustPercent.
	UNTIL (horizontalSpeed <= 0.05 OR horizontalDistance < 0){
		CLEARSCREEN.		
		PRINT("Distance left : " + horizontalDistance).
		PRINT("Steering scale : " + steeringScale).
		SET wv TO VECDRAWARGS(_coordinates:POSITION, planeNormalVector:NORMALIZED*ALT:RADAR,GREEN,"Landing position",1,TRUE).
		SET dv TO VECDRAWARGS(SHIP:POSITION, horizontalVector,RED,"Horizontal vector",1,TRUE).
		SET STEERV TO VECDRAWARGS(SHIP:POSITION, test2:NORMALIZED*100,BLUE,"Steering",1,TRUE).
		SET STEERV2 TO VECDRAWARGS(SHIP:POSITION, -((horizontalVector:DIRECTION*ANGLEAXIS(-30, VCRS(SRFPROGRADE:VECTOR, horizontalVector)))):VECTOR:NORMALIZED*100,WHITE,"2",1,TRUE).
		
		//REPLACE THE 4 (WAS RCSLIST:LENGTH)
		IF(horizontalDistance > 500){
			//RUNPATH("basic_functions/modTrajectory_iterative.ks", _coordinates). 
			
			//RUNPATH("basic_functions/modVelocityAxis_iterative.ks", V(0,0,0), axisVector, 4).
			RUNPATH("basic_functions/modVelocityPlane_iterative.ks", requiredHorizontalTrajectory, planeNormalVector, 4). 
		}
	}
	LOCK THROTTLE TO 0.
	RCS OFF.
	
	
	//The given vector gets projected into the plane, ship tries to match the projected velocity
	//RUNPATH("basic_functions/modVelocity_plane.ks", V(0,0,0), planeNormalVector, 0, 15).

	//It has some weird acceleration in the irection of planetary rotation as it descends.
	//If anything, wouldn't it be decelerating?


//--------------------------------------------------------------------------\
//								Program end					   				|
//--------------------------------------------------------------------------/


	//Returns user control
	SET SHIP:CONTROL:NEUTRALIZE to TRUE.
	RCS OFF.
	
	//Unlock all	
	UNLOCK STEERING.
	UNLOCK THROTTLE.
	//UNLOCK ALL.

	CLEARVECDRAWS().
	WAIT 1.
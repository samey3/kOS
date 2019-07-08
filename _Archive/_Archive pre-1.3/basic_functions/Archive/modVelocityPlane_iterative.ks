	@lazyglobal OFF.

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _toVector.	
	PARAMETER _planeNormalVector.
	PARAMETER _listLength.
	
	
//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/


	RUNONCEPATH("lib/math.ks").
	
	//Do this, combined with making its velocity point towards the position.
	
	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/		
			
			
	//--------------------------------------\
	//VECTORS-------------------------------|		
						
		//Custom axis		
		LOCAL Xa IS SHIP:FACING:FOREVECTOR.
		LOCAL Ya IS SHIP:FACING:TOPVECTOR.
		LOCAL Za IS SHIP:FACING:STARVECTOR.

		//To desired velocity and relative velocity vectors (custom axis)
		LOCAL differenceVector IS (projectToPlane(_toVector, _planeNormalVector) - projectToPlane(SHIP:VELOCITY:SURFACE, _planeNormalVector)).
		LOCAL c_diffVector IS V(VDOT(differenceVector,Xa),VDOT(differenceVector,Ya),VDOT(differenceVector,Za)).

	//--------------------------------------\
	//RCS-----------------------------------|
	
		//RCS max thrust limit
		LOCAL rcsLimiter IS (SHIP:MASS/2.6).

		//RCS parameters
		LOCAL total_rcs_thrust IS _listLength*0.15/2. //kN. Can set to the length of the list because each thruster is only 1kN
		LOCAL base_acceleration IS total_rcs_thrust / SHIP:MASS.
			LOCAL LOCK thrustPercent TO ((base_acceleration * SHIP:MASS) / total_rcs_thrust).
			LOCAL minDiff IS 0.05*base_acceleration. //Based on minimal possible thrust, how close a velocity value should be obtained to the desired one
			
		LOCAL waitTime IS 0.1.

//--------------------------------------------------------------------------\
//								Program run					   				| v=at
//--------------------------------------------------------------------------/

	//IF(c_diffVector:X > ABS(minDiff/2)) {
		//SET SHIP:CONTROL:FORE TO thrustPercent*(c_diffVector:X/base_acceleration).
		//SET SHIP:CONTROL:FORE TO sign(c_diffVector:X).
		SET SHIP:CONTROL:FORE TO sign(c_diffVector:X/(base_acceleration*waitTime)).
	//	}

	//IF(c_diffVector:Y > ABS(minDiff/2)) {
		//SET SHIP:CONTROL:TOP TO thrustPercent*(c_diffVector:Y/base_acceleration).
		//SET SHIP:CONTROL:TOP TO sign(c_diffVector:Y).
		SET SHIP:CONTROL:TOP TO sign(c_diffVector:Y/(base_acceleration*waitTime)).
	//	}

	//IF(c_diffVector:Z > ABS(minDiff/2)) {
		//SET SHIP:CONTROL:STARBOARD TO thrustPercent*(c_diffVector:Z/base_acceleration).
		//SET SHIP:CONTROL:STARBOARD TO sign(c_diffVector:Z).
		SET SHIP:CONTROL:STARBOARD TO sign(c_diffVector:Z/(base_acceleration*waitTime)).
	//	}

		
	WAIT waitTime.
	//Stop thrusters, revert limiter changes
	SET SHIP:CONTROL:FORE TO 0.
	SET SHIP:CONTROL:TOP TO 0.
	SET SHIP:CONTROL:STARBOARD TO 0.	
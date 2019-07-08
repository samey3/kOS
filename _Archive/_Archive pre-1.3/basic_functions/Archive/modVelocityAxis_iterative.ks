	@lazyglobal OFF.

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _toVector.	
	PARAMETER _axisVector.
	PARAMETER _listLength.
	
	
//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/


	RUNONCEPATH("lib/math.ks").
	
	
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
		LOCAL differenceVector IS ((_toVector*_axisVector) - (SHIP:VELOCITY:SURFACE*_axisVector))*_axisVector.
		LOCAL c_diffVector IS V(VDOT(differenceVector,Xa),VDOT(differenceVector,Ya),VDOT(differenceVector,Za)).

	//--------------------------------------\
	//RCS-----------------------------------|
	
		//RCS max thrust limit
		LOCAL rcsLimiter IS (SHIP:MASS/2.6).

		//RCS parameters
		LOCAL total_rcs_thrust IS _listLength*0.15/2. //kN. Can set to the length of the list because each thruster is only 1kN
		LOCAL base_acceleration IS total_rcs_thrust / SHIP:MASS.
			LOCAL minDiff IS 0.05*base_acceleration. //Based on minimal possible thrust, how close a velocity value should be obtained to the desired one
			
	

//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/

	IF(c_diffVector:X > ABS(minDiff/2)) {
		//SET SHIP:CONTROL:FORE TO thrustPercent*(c_diffVector:X/base_acceleration). SET rcsX TO TRUE. 
		SET SHIP:CONTROL:FORE TO sign(c_diffVector:X).
		}

	IF(c_diffVector:Y > ABS(minDiff/2)) {
		//SET SHIP:CONTROL:TOP TO thrustPercent*(c_diffVector:Y/base_acceleration). SET rcsY TO TRUE. 
		SET SHIP:CONTROL:TOP TO sign(c_diffVector:Y).
		}

	IF(c_diffVector:Z > ABS(minDiff/2)) {
		//SET SHIP:CONTROL:STARBOARD TO thrustPercent*(c_diffVector:Z/base_acceleration). SET rcsZ TO TRUE. 
		SET SHIP:CONTROL:STARBOARD TO sign(c_diffVector:Z).
		}

		
	WAIT 0.1.
	//Stop thrusters, revert limiter changes
	SET SHIP:CONTROL:FORE TO 0.
	SET SHIP:CONTROL:TOP TO 0.
	SET SHIP:CONTROL:STARBOARD TO 0.	

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _host.
	PARAMETER _posVector.	
	PARAMETER _planeNormal.

	
//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/


	RUNONCEPATH("lib/shipControl.ks").
	RUNONCEPATH("lib/math.ks").
	
	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/		

	
	//--------------------------------------\
	//RCS-----------------------------------|
	
		//RCS max thrust limit
		LOCAL rcsLimiter IS (SHIP:MASS/2.6).

		//RCS parameters
		//LIST LENGTH FOR 4
		LOCAL total_rcs_thrust IS 4*0.35/2. //kN. Can set to the length of the list because each thruster is only 1kN
		LOCAL base_acceleration IS total_rcs_thrust / SHIP:MASS.
			LOCAL thrustPercent IS ((base_acceleration * SHIP:MASS) / total_rcs_thrust).
			LOCAL minDiff IS 0.05*base_acceleration. //Based on minimal possible thrust, how close a velocity value should be obtained to the desired one
			
			
	//--------------------------------------\
	//VECTORS-------------------------------|	
	
		LOCAL positionVec IS (_host:POSITION - SHIP:POSITION).
		LOCAL toVelVec IS projectToPlane(positionVec:NORMALIZED*(positionVec:MAG/1), _planeNormal). //1 normal	
		//LOCAL toVelVec IS projectToPlane(positionVec:NORMALIZED*(base_acceleration*0.1), _planeNormal).	
		//LOCAL toVelVec IS projectToPlane(2*base_acceleration*positionVec, _planeNormal).	
						
		//Custom axis		
		LOCAL Xa IS SHIP:FACING:FOREVECTOR.
		LOCAL Ya IS SHIP:FACING:TOPVECTOR.
		LOCAL Za IS SHIP:FACING:STARVECTOR.


		LOCAL differenceVector IS (toVelVec - (SHIP:VELOCITY:ORBIT - _host:VELOCITY:ORBIT)).
		LOCAL differenceVec IS V(VDOT(differenceVector,Xa),VDOT(differenceVector,Ya),VDOT(differenceVector,Za)).


//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	IF(ABS(differenceVec:X) > 0) { //minDiff
		SET SHIP:CONTROL:FORE TO sign(differenceVec:X). }
		//SET SHIP:CONTROL:FORE TO thrustPercent*(differenceVec:NORMALIZED:X/2). }

	IF(ABS(differenceVec:Y) > 0) {
		SET SHIP:CONTROL:TOP TO sign(differenceVec:Y).  }
		//SET SHIP:CONTROL:TOP TO thrustPercent*(differenceVec:NORMALIZED:Y). }

	IF(ABS(differenceVec:Z) > 0) {
		SET SHIP:CONTROL:STARBOARD TO sign(differenceVec:Z).  }
		//SET SHIP:CONTROL:STARBOARD TO thrustPercent*(differenceVec:NORMALIZED:Z). }

	WAIT 0.1.
	
	//Stop thrusters, revert limiter changes
	SET SHIP:CONTROL:FORE TO 0.
	SET SHIP:CONTROL:TOP TO 0.
	SET SHIP:CONTROL:STARBOARD TO 0.
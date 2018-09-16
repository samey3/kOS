	@lazyglobal OFF.

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	//Modify the trajectory to head towards this geoposition
	PARAMETER _geoposition.	
	PARAMETER _listLength IS 4.
	
	
//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/


	RUNONCEPATH("lib/math.ks").
	
	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/		
			
			
	//--------------------------------------\
	//Required trajectory-------------------|	
	
		LOCAL shipVector IS (SHIP:POSITION - BODY:POSITION).
		LOCAL coordinatesVector IS projectToPlane(_geoposition:POSITION - SHIP:POSITION, shipVector).
		LOCAL impactVector IS projectToPlane(SHIP:VELOCITY:SURFACE, shipVector).
		LOCAL angleDifference IS VANG(projectToPlane(coordinatesVector, shipVector), projectToPlane(SHIP:VELOCITY:SURFACE, shipVector)).
		LOCAL requiredVector IS ANGLEAXIS(angleDifference, VCRS(impactVector, coordinatesVector))*SHIP:VELOCITY:SURFACE.	
			
			
	//--------------------------------------\
	//VECTORS-------------------------------|		
						
		//Custom axis		
		LOCAL Xa IS SHIP:FACING:FOREVECTOR.
		LOCAL Ya IS SHIP:FACING:TOPVECTOR.
		LOCAL Za IS SHIP:FACING:STARVECTOR.

		LOCAL differenceVector IS (requiredVector - SHIP:VELOCITY:SURFACE).
		LOCAL c_diffVector IS V(VDOT(differenceVector,Xa),VDOT(differenceVector,Ya),VDOT(differenceVector,Za)).
		
		
	//--------------------------------------\
	//RCS-----------------------------------|
	
		//RCS max thrust limit
		LOCAL rcsLimiter IS (SHIP:MASS/2.6).

		//RCS parameters
		LOCAL total_rcs_thrust IS _listLength*0.05/2. //kN. Can set to the length of the list because each thruster is only 1kN
		LOCAL base_acceleration IS total_rcs_thrust / SHIP:MASS.
			LOCAL minDiff IS 0.05*base_acceleration. //Based on minimal possible thrust, how close a velocity value should be obtained to the desired one
	

//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	IF(c_diffVector:X > minDiff OR c_diffVector:X < -minDiff) {
		SET SHIP:CONTROL:FORE TO sign(c_diffVector:X). }

	IF(c_diffVector:Y > minDiff OR c_diffVector:Y < -minDiff) {
		SET SHIP:CONTROL:TOP TO sign(c_diffVector:X). }

	IF(c_diffVector:Z > minDiff OR c_diffVector:Z < -minDiff) {
		SET SHIP:CONTROL:STARBOARD TO sign(c_diffVector:X). }

	WAIT 0.1.
	
	//Stop thrusters, revert limiter changes
	SET SHIP:CONTROL:FORE TO 0.
	SET SHIP:CONTROL:TOP TO 0.
	SET SHIP:CONTROL:STARBOARD TO 0.



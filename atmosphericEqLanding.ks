	CLEARSCREEN.

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _coordinates.


//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/


	


//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	//If it is in orbit, circularize first
	IF(SHIP:ORBIT:PERIAPSIS > (SHIP:BODY:RADIUS + SHIP:BODY:ATM:HEIGHT)SHIP:ORBIT:ECCENTRICITY > 0.01){
		RUNPATH ("basic_functions/circularize.ks", SHIP:ORBIT:PERIAPSIS, FALSE).
	}
	
	//Set a point ahead of the landing spot to maintain trajectory for.
	//Once some point is reached? Start burn and set target to actual.
	//Maintain corrections
	//Thus, we need a script that tilts to maintain corrections at several points.
	//Need a part that burns.
	//Lets just do 10 degrees ahead.
	
	UNTIL(FALSE){
		//Need longitudinal travel direction?
		//Or, if difference is in same direction as velocity... lean backwards, etc.
		
		//Take required vector, add a 10 degree tilt at most? scale it how?
	}

	
	
	//Can predict time to periapsis once lowered.
	//How much should we lower?
	
	
	
	
	//THIS CAN BE SPLIT INTO TWO PROGRAMS.
	//A boost back, that happens immediately after staging,
	//And one that is already in orbit.
	
	//Boostback.
	//Assuming similar to orbit, but no need for predicting initial dip into atmosphere
	//First stage the craft, and soon after, do an initial burn to get lontigude difference to 10 degrees ahea.
	//(Regardless if you're past/behind the landing point already)
	//After, continue like orbit, and second burn once above point to drop down.
	//Continue with atmospheric corrections.
	
	
	//Orbit.
	//Lower periapsis, so when you get to it youwill be 10 degrees ahead roughly.
	//Lower it to exactly 0? Or some set amount of distance you'd like above the target.
	//Ideally, last burn at 5-7km above the point.
	//Set 5km periapsis.




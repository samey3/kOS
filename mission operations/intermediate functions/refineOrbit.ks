//More like refining to the values you feed it. Of course, refining takes multiple iterations.
//Sorta counts?
	@lazyglobal OFF.
	CLEARSCREEN.	
	
	
//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _orbitObject.
	PARAMETER _maxRefinements IS 1.


//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/

	
	RUNONCEPATH("lib/math.ks").
	RUNONCEPATH("lib/lambert.ks").
	

//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	//How can you make it check whether the current orbit is sufficient? (and thus avoid massive wait times)
	LOCAL res IS LEXICON().
	FROM { LOCAL itr IS _maxRefinements. } UNTIL itr = 0 STEP { SET itr TO (itr - 1). } DO {
		
		//Orbit is within acceptable parameters (< 3% on all parameters)
		IF(isAcceptable(_orbitObject)){
			BREAK.
		}
		
		//Gets the node
		IF(_orbitObject:ISTYPE("orbitable")){
			SET res TO getInterceptNode(SHIP, _orbitObject).
		}
		ELSE IF (_orbitObject:ISTYPE("lexicon")){
			SET res TO getTransferNode(SHIP, _orbitObject).
		}
		
		//Time to burn is too long, break. (Will be fixed when we expose the timing-bounds of the lambert solver)
		IF((res["t"] - TIME:SECONDS) > 30*SHIP:ORBIT:PERIOD){
			BREAK.
		}
		
		//Executes the node
		RUNPATH("mission operations/basic functions/executeNode.ks", NODE(res["t"], res["radial"], res["normal"], res["prograde"])).	
		
		
		//AND THEN HERE
		//We get the orbit parameters, and find what the velocity vector is at that time and match it.
		//We use 'dt' here (is is time from the burn, or from now?)
		
		//And then repeat as necessary
	}
	
	
//--------------------------------------------------------------------------\
//								Functions					   				|
//--------------------------------------------------------------------------/


	FUNCTION isAcceptable {
		//Take a vessel/lexicon of orbit parameters as input
		PARAMETER _orbitObject.
	
		//Set up local variables
		LOCAL sma IS 0.
		LOCAL inc IS 0.
		LOCAL ecc IS 0.
		LOCAL lan IS 0.
		LOCAL argp IS 0.

		//Gets the parameters of the target orbit
		IF(_orbitObject:ISTYPE("vessel")){
			SET sma TO _orbitObject:ORBIT:SEMIMAJORAXIS.
			SET inc TO _orbitObject:ORBIT:INCLINATION.
			SET ecc TO _orbitObject:ORBIT:ECCENTRICITY.
			SET lan TO _orbitObject:ORBIT:LONGITUDEOFASCENDINGNODE.
			SET argp TO _orbitObject:ORBIT:ARGUMENTOFPERIAPSIS.
		}
		ELSE IF (_orbitObject:ISTYPE("lexicon")){
			SET sma TO _orbitObject["semimajoraxis"].
			SET inc TO _orbitObject["inclination"].
			SET ecc TO _orbitObject["eccentricity"].
			SET lan TO _orbitObject["longitudeofascendingnode"].
			SET argp TO _orbitObject["argumentofperiapsis"]..
		}
		
		//If the difference of each parameter is less than 3%, return true
		IF((percentDifference(SHIP:ORBIT:SEMIMAJORAXIS, sma) < 0.01
			AND percentDifference(SHIP:ORBIT:INCLINATION, inc) < 0.01
			AND percentDifference(SHIP:ORBIT:ECCENTRICITY, ecc) < 0.01
			AND (percentDifference(SHIP:ORBIT:LONGITUDEOFASCENDINGNODE, lan) < 0.01 OR inc < 0.5)
			AND percentDifference(SHIP:ORBIT:ARGUMENTOFPERIAPSIS, argp) < 0.01
		)){
			RETURN TRUE.
		}
		ELSE {
			RETURN FALSE.
		}
	}
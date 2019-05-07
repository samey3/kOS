	@lazyglobal OFF.
	CLEARSCREEN.	
	
	
//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _orbitObject.
	PARAMETER _matchTrueAnomaly IS FALSE.
	PARAMETER _untilAcceptable IS FALSE.
	PARAMETER _warpUntilPatch IS FALSE. //This can be removed, however makes the user think more about what they are attempting to do


//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/

	
	RUNONCEPATH("lib/math.ks").
	RUNONCEPATH("lib/lambert.ks").
	RUNONCEPATH("lib/orbitProperties.ks").
	RUNONCEPATH("lib/gameControl.ks").
	
	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/


	//Set the return variable for the node lexicon result
	LOCAL res IS LEXICON().
	
	//Get the list of bodies
	LOCAL bodyList IS LIST().
	LIST BODIES IN bodyList.
	

//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	//Until the orbit is acceptable (unless _untilAcceptable is FALSE)
	UNTIL(FALSE){
		//If the orbit is acceptable, break (placed here incase it is already acceptable, UNTIL will run once by default)
		IF(isAcceptable(_orbitObject, _matchTrueAnomaly)){ BREAK. }
	
		//Gets the node
		IF(_orbitObject:ISTYPE("orbitable")){
			SET res TO getInterceptNode(SHIP, _orbitObject). //Take time parameters here
		}
		ELSE IF (_orbitObject:ISTYPE("lexicon")){
			SET res TO getTransferNode(SHIP, _orbitObject).
		}
		
		//Time to burn is too long, break. (Will be fixed when we expose the timing-bounds of the lambert solver)
		IF((res["t"] - TIME:SECONDS) > 30*SHIP:ORBIT:PERIOD){
			BREAK.
		}
			
		//Execute the first maneuver
		RUNPATH("mission operations/basic functions/executeNode.ks", NODE(res["t"], res["radial_1"], res["normal_1"], res["prograde_1"])).
			
		//If the target orbit/object is NOT a body, perform second maneuver
		IF (NOT bodyList:CONTAINS(_orbitObject)){
			RUNPATH("mission operations/basic functions/executeNode.ks", NODE(res["t"] + res["dt"], res["radial_2"], res["normal_2"], res["prograde_2"])).
		}
			
		//If only performing the maneuvers once, break here
		IF(NOT _untilAcceptable){ BREAK. }
	}
	

	//If we are intercepting with a body, and currently does not have a patch, warp until it has a patch
	IF(bodyList:CONTAINS(_orbitObject) AND _warpUntilPatch AND (NOT SHIP:ORBIT:HASNEXTPATCH)){
		warpTime(res["t"] + res["dt"], TRUE).
		PRINT("Finished patch find").
		WAIT 3.
	}
	
	
//--------------------------------------------------------------------------\
//								Functions					   				|
//--------------------------------------------------------------------------/


	FUNCTION isAcceptable {
	
		//Take a vessel/lexicon of orbit parameters as input
		PARAMETER _orbitObject.
		PARAMETER _matchTrueAnomaly.
	
		//Set up local variables
		LOCAL sma IS 0.
		LOCAL inc IS 0.
		LOCAL ecc IS 0.
		LOCAL lan IS 0.
		LOCAL argp IS 0.
		LOCAL tanm IS 0.

		//Gets the parameters of the target orbit
		IF(_orbitObject:ISTYPE("vessel")){
			SET sma TO _orbitObject:ORBIT:SEMIMAJORAXIS.
			SET inc TO _orbitObject:ORBIT:INCLINATION.
			SET ecc TO _orbitObject:ORBIT:ECCENTRICITY.
			SET lan TO _orbitObject:ORBIT:LONGITUDEOFASCENDINGNODE.
			SET argp TO _orbitObject:ORBIT:ARGUMENTOFPERIAPSIS.
			SET tanm TO _orbitObject:ORBIT:TRUEANOMALY.
		}
		ELSE IF (_orbitObject:ISTYPE("lexicon")){
			SET sma TO _orbitObject["semimajoraxis"].
			SET inc TO _orbitObject["inclination"].
			SET ecc TO _orbitObject["eccentricity"].
			SET lan TO _orbitObject["longitudeofascendingnode"].
			SET argp TO _orbitObject["argumentofperiapsis"].
			SET tanm TO _orbitObject["trueanomaly"].
		}
		
		
		//PRINT(percentDifference(SHIP:ORBIT:SEMIMAJORAXIS, sma) < 0.01).
		//PRINT(scalarDifference(SHIP:ORBIT:INCLINATION, inc) < 0.01).
		//PRINT("SHOW : " + (scalarDifference(SHIP:ORBIT:INCLINATION, inc) < 0.01)).
		//PRINT("SHOW : " + SHIP:ORBIT:INCLINATION).
		//PRINT("SHOW : " + inc).
		//PRINT(scalarDifference(SHIP:ORBIT:ECCENTRICITY, ecc) < 0.01).
		//PRINT("SHOW : " + (scalarDifference(SHIP:ORBIT:ECCENTRICITY, ecc) < 0.001)).
		//PRINT("SHOW : " + SHIP:ORBIT:ECCENTRICITY).
		//PRINT("SHOW : " + ecc).
		//PRINT((scalarDifference(SHIP:ORBIT:LONGITUDEOFASCENDINGNODE, lan) < 0.01 OR inc < 0.5)).
		//PRINT((scalarDifference(SHIP:ORBIT:ARGUMENTOFPERIAPSIS, argp) < 0.01 OR ecc < 0.05)).
		//PRINT((NOT _matchTrueAnomaly OR scalarDifference(SHIP:ORBIT:TRUEANOMALY, tanm) < 0.01)).
		//WAIT 5.
		
		
		//If the difference of each parameter is less than 1%, or 0.01 degrees, return true
		IF((percentDifference(SHIP:ORBIT:SEMIMAJORAXIS, sma) < 0.01 //Will be large numbers, thus percentDifference is appropriate
			AND scalarDifference(SHIP:ORBIT:INCLINATION, inc) < 0.01
			AND scalarDifference(SHIP:ORBIT:ECCENTRICITY, ecc) < 0.001
			AND (scalarDifference(SHIP:ORBIT:LONGITUDEOFASCENDINGNODE, lan) < 0.01 OR inc < 0.5) //If under half a degree of inclination, ignore
			AND (scalarDifference(SHIP:ORBIT:ARGUMENTOFPERIAPSIS, argp) < 0.01 OR ecc < 0.05) //If nearly circular, ignore
			AND (NOT _matchTrueAnomaly OR scalarDifference(SHIP:ORBIT:TRUEANOMALY, tanm) < 0.01)
		)){
			RETURN TRUE.
		}
		ELSE {
			RETURN FALSE.
		}
	}
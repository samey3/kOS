RUNONCEPATH("lib/processing/processRequest.ks").

FUNCTION request{

}

FUNCTION findPath {

}

//Will need to return the value after modifying the time-to, as it takes 10+ seconds to calculate
FUNCTION solveLambert {
	PARAMETER mu.
	PARAMETER r1.
	PARAMETER v1.
	PARAMETER r2.
	PARAMETER v2.
	PARAMETER tMin.
	PARAMETER tMax.
	PARAMETER tStep.
	PARAMETER dtMin.
	PARAMETER dtMax.
	PARAMETER dtStep.
	PARAMETER allowLob.
	PARAMETER optArrival.
	
	//Records the start time
	LOCAL timeStart IS TIME:SECONDS.
	
	//Submits the job request
	LOCAL res IS lambertOptimize(mu, r1, v1, r2, v2, tMin, tMax, tStep, dtMin, dtMax, dtStep, allowLob, optArrival).
		
	//Modify the time to burn
	//SET res["t"] TO res["t"] - (TIME:SECONDS - timeStart).
	
	//Return the result
	RETURN res.
}
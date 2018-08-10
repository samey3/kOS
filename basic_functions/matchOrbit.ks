	CLEARSCREEN.

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _targetCraft IS TARGET.
	//LOCAL target_inclination IS getAscendingInclination(_targetCraft). //This returned weird values?

	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/


	GLOBAL returnVal IS 0.
	
	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	//Change our vessel to an equatorial orbit
	IF(SHIP:ORBIT:INCLINATION > 0.1) {
		RUNPATH ("basic_functions/timeToAscending.ks", SHIP).
		RUNPATH ("basic_functions/nodeInclinationBurn.ks", returnVal, -SHIP:ORBIT:INCLINATION).  //Because its the ascending node (ours goes 'above'), we must 'drop' our inclination
	}


	//First get into a circular, equatiorial orbit at a radius of the target's periapsis
	RUNPATH ("basic_functions/circularize.ks", _targetCraft:ORBIT:PERIAPSIS + _targetCraft:ORBIT:BODY:RADIUS, TRUE).

	
	//Gets the time to the relative ascending node, then sets its inclination at that time
	//Why did this function give time to the descending node instead?
	IF(_targetCraft:ORBIT:INCLINATION > 0.1) {
		RUNPATH ("basic_functions/timeToRelativeDescending.ks", _targetCraft).
		RUNPATH ("basic_functions/nodeInclinationBurn.ks", returnVal, _targetCraft:ORBIT:INCLINATION). 
	} //Because its the ascending node (ours goes 'above'), we must 'drop' our inclination
	
	
	//At the point where the target orbit's periapsis touches the ships orbit, we increase our apoapsis to match
	RUNPATH ("basic_functions/timeToRelativePeriapsis.ks", _targetCraft).
	RUNPATH ("basic_functions/circularManeuver.ks", _targetCraft:ORBIT:APOAPSIS + _targetCraft:ORBIT:BODY:RADIUS, returnVal, TRUE).
	
	
	
	//Fine tuning
	//Improves inclination
	IF(_targetCraft:ORBIT:INCLINATION  - SHIP:ORBIT:INCLINATION > 0.05) {
		RUNPATH ("basic_functions/timeToRelativeDescending.ks", _targetCraft).
		RUNPATH ("basic_functions/nodeInclinationBurn.ks", returnVal, _targetCraft:ORBIT:INCLINATION  - SHIP:ORBIT:INCLINATION). 
	} //Because its the ascending node (ours goes 'above'), we must 'drop' our inclination
	//Improves periapsis and apoapsis
	RUNPATH ("basic_functions/setApoapsis.ks", _targetCraft:ORBIT:APOAPSIS + _targetCraft:ORBIT:BODY:RADIUS, TRUE). //TRUE
	RUNPATH ("basic_functions/setPeriapsis.ks", _targetCraft:ORBIT:PERIAPSIS + _targetCraft:ORBIT:BODY:RADIUS, TRUE). //When TRUE, started boosting like mad
	
	

//If no target
//get LAN, warp to it, match difference using VANG
//set periapsis first, then apoapsis

//If target, can check if it is craft or contract.
//if contract, if it has :ORBIT then treat like craft, else pass it into no target
//Otherwise, use :ORBIT stuff

//First make circular orbit at radius equal to the target craft's periapsis







//	PARAMETER _targetCraft IS TARGET.

//PRINT "Mun apo : " + _targetCraft:ORBIT:APOAPSIS.
//WAIT 20.

//	GLOBAL returnVal IS 0. //Used for retrieving values from run functions, as return values from such scripts are not supported yet.


//	LOCAL ascendingInclination IS getAscendingInclination(_targetCraft).
//	RUNPATH ("basic_functions/timeToRelativeAscending.ks", _targetCraft).
//	RUNPATH ("basic_functions/nodeInclinationBurn.ks", returnVal, -ascendingInclination). //CHANGED IT TO NEGATIVE INCLINATION HERE, ACTUALLY FIX IT

//	RUNPATH ("basic_functions/timeToRelativePeriapsis.ks", _targetCraft).
//	RUNPATH ("basic_functions/maneuverCircular.ks", _targetCraft:ORBIT:APOAPSIS + _targetCraft:ORBIT:BODY:RADIUS, returnVal).

//Just added this part while\ drunko  fucked. Remove it before doing fixes
//RUN maneuverApoapsis(_targetCraft:ORBIT:APOAPSIS + _targetCraft:ORBIT:BODY:RADIUS).

//	RUN rendezvous(100, _targetCraft).
//	RUN dock2(_targetCraft).

//RUN nodeInclinationBurn(returnVal, -ascendingInclination).
//Vector between these two, shipvel_vector + inclination_degrees
//Vel->Position

//Current ship velocity
//target velocity
//Both at the ascending node
//The difference is the burn amount?
//RUN nodeBurn(timeAsc, 100,6).


FUNCTION getAscendingInclination {
	PARAMETER _TC.
	LOCAL shipAngularVelocity IS VCRS(SHIP:POSITION - BODY:POSITION, SHIP:VELOCITY:ORBIT).
	LOCAL targetAngularVelocity IS VCRS(_TC:POSITION - BODY:POSITION, _TC:VELOCITY:ORBIT).
	LOCAL ascendingInclination IS VANG(targetAngularVelocity, shipAngularVelocity). //kOS uses LHR instead of RHR	
	RETURN ascendingInclination.
}
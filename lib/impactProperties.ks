//Have the two 'current' ones just return the trajectories mod values instead if there is an atmosphere.

//-----------------------------------------------------------------------------------------------------------
// 	Name: getImpactTime
//	Parameters : 
//		- Reference altitude (altitude above sea-level)
//	
//-----------------------------------------------------------------------------------------------------------
FUNCTION getImpactTime{

	//--------------------------------------------------------------------------\
	//								Parameters					   				|
	//--------------------------------------------------------------------------/


		PARAMETER _refAltitude IS 0.
		
		
	//--------------------------------------------------------------------------\
	//								Variables					   				|
	//--------------------------------------------------------------------------/	
		

		//Perhaps make other lib that does not include radius, this one is specialized for a reason.
		LOCAL intersectAltitude TO SHIP:BODY:RADIUS + _refAltitude.
		LOCAL positionVector IS (SHIP:POSITION - BODY:POSITION).
		LOCAL momentumVector IS VCRS(positionVector, SHIP:VELOCITY:ORBIT).
		LOCAL eccentricityVector IS VCRS(SHIP:VELOCITY:ORBIT, momentumVector)/SHIP:BODY:MU - positionVector:NORMALIZED.

		
	//--------------------------------------------------------------------------\
	//							 Check conditions					   			|
	//--------------------------------------------------------------------------/


		IF((SHIP:BODY:RADIUS + SHIP:ORBIT:PERIAPSIS) > intersectAltitude){
			PRINT("Orbit will never impact.").
			RETURN -1.
		}
		
	//--------------------------------------------------------------------------\
	//							   Function run					   				|
	//--------------------------------------------------------------------------/
	
	
		//Impact angle
		LOCAL theta IS ARCCOS((SHIP:ORBIT:SEMIMAJORAXIS*(1 - SHIP:ORBIT:ECCENTRICITY^2)/intersectAltitude - 1)/SHIP:ORBIT:ECCENTRICITY).
					
		//Orbital parameters
		LOCAL meanAnomaly IS SHIP:ORBIT:MEANANOMALYATEPOCH + MOD(360*(TIME:SECONDS - SHIP:ORBIT:EPOCH)/SHIP:ORBIT:PERIOD, 360).	
		LOCAL meanSpeed IS 360/SHIP:ORBIT:PERIOD.
			
		//Impact parameters	
		LOCAL trueAnomaly_impact IS theta.
		LOCAL eccentricAnomaly_impact IS ARCCOS((COS(trueAnomaly_impact) + SHIP:ORBIT:ECCENTRICITY)/(1 + SHIP:ORBIT:ECCENTRICITY*COS(trueAnomaly_impact))).	
		LOCAL meanAnomaly_impact IS 360 - ((eccentricAnomaly_impact*CONSTANT():PI/180) - SHIP:ORBIT:ECCENTRICITY*SIN(eccentricAnomaly_impact))*180/CONSTANT():PI.	

		//Time
		LOCAL timeToImpact IS ((meanAnomaly_impact - meanAnomaly)/meanSpeed).

		RETURN timeToImpact.
}


//-----------------------------------------------------------------------------------------------------------
// 	Name: getImpactCoords
//	Parameters : 
//		- Reference altitude (altitude above sea-level)
//	
//-----------------------------------------------------------------------------------------------------------
FUNCTION getImpactCoords{


	//--------------------------------------------------------------------------\
	//								Parameters					   				|
	//--------------------------------------------------------------------------/
	
	
		PARAMETER _refAltitude IS 0.
		
		
	//--------------------------------------------------------------------------\
	//								Variables					   				|
	//--------------------------------------------------------------------------/
	
	
		LOCAL intersectAltitude TO SHIP:BODY:RADIUS + _refAltitude.
		LOCAL positionVector IS (SHIP:POSITION - BODY:POSITION).
		LOCAL momentumVector IS VCRS(positionVector, SHIP:VELOCITY:ORBIT).
		LOCAL eccentricityVector IS VCRS(SHIP:VELOCITY:ORBIT, momentumVector)/SHIP:BODY:MU - positionVector:NORMALIZED.

		
	//--------------------------------------------------------------------------\
	//							 Check conditions					   			|
	//--------------------------------------------------------------------------/	
		
		
		IF((SHIP:BODY:RADIUS + SHIP:ORBIT:PERIAPSIS) > intersectAltitude){
			PRINT("Orbit will never impact.").
			RETURN -1.
		}
	
	
	//--------------------------------------------------------------------------\
	//							   Function run					   				|
	//--------------------------------------------------------------------------/
	
	
		//Impact angle
		LOCAL theta IS ARCCOS((SHIP:ORBIT:SEMIMAJORAXIS*(1 - SHIP:ORBIT:ECCENTRICITY^2)/intersectAltitude - 1)/SHIP:ORBIT:ECCENTRICITY).
			
		//Orbital parameters
		LOCAL meanAnomaly IS SHIP:ORBIT:MEANANOMALYATEPOCH + MOD(360*(TIME:SECONDS - SHIP:ORBIT:EPOCH)/SHIP:ORBIT:PERIOD, 360).	
		LOCAL meanSpeed IS 360/SHIP:ORBIT:PERIOD.
		LOCAL trueAnomaly_impact IS theta.
		LOCAL eccentricAnomaly_impact IS ARCCOS((COS(trueAnomaly_impact) + SHIP:ORBIT:ECCENTRICITY)/(1 + SHIP:ORBIT:ECCENTRICITY*COS(trueAnomaly_impact))).	
		LOCAL meanAnomaly_impact IS 360 - ((eccentricAnomaly_impact*CONSTANT():PI/180) - SHIP:ORBIT:ECCENTRICITY*SIN(eccentricAnomaly_impact))*180/CONSTANT():PI.	

		//Time
		LOCAL timeToImpact IS ((meanAnomaly_impact - meanAnomaly)/meanSpeed).
		LOCAL timeRotateLng IS timeToImpact*(360/SHIP:BODY:ROTATIONPERIOD).
		
		//Intercept location
		LOCAL inclination IS SHIP:ORBIT:INCLINATION.
		IF(VANG(VCRS(SHIP:BODY:ANGULARVEL, momentumVector), eccentricityVector) >= 90){
			SET inclination TO -inclination.
		}
		LOCAL interceptVector IS (ANGLEAXIS(-trueAnomaly_impact, momentumVector)*eccentricityVector).
		LOCAL interceptCoordinates IS SHIP:BODY:GEOPOSITIONOF(SHIP:BODY:POSITION + interceptVector).
		LOCAL impactCoordinates IS (interceptCoordinates:LNG - timeRotateLng).
		
		RETURN LATLNG(interceptCoordinates:LAT, impactCoordinates).
}


//-----------------------------------------------------------------------------------------------------------
// 	Name: findImpactCoords
//	Parameters : 
//		- Periapsis
//		- Reference altitude (altitude above sea-level)
//		- Inclination
//		- Mean anomaly shift from current mean anomaly
//
//	This function is meant to be used with iteration in order 
//	to find the parameters to deorbit with to hit a target location
//
//-----------------------------------------------------------------------------------------------------------
FUNCTION predictImpactCoords{

	//--------------------------------------------------------------------------\
	//								Parameters					   				|
	//--------------------------------------------------------------------------/
	
	
		PARAMETER _periapsis.
		PARAMETER _refAltitude IS 0.
		PARAMETER _inclination IS 0.	
		PARAMETER _meanShift IS 0.
	
	
	//--------------------------------------------------------------------------\
	//								Variables					   				|
	//--------------------------------------------------------------------------/
	
	
		//Current orbital parameters
		LOCAL intersectAltitude TO SHIP:BODY:RADIUS + _refAltitude.
		LOCAL positionVector IS (SHIP:POSITION - BODY:POSITION).
		LOCAL velocityVector IS SHIP:VELOCITY:ORBIT.		
		LOCAL eccentricityVector IS -(ANGLEAXIS(_meanShift, SHIP:BODY:ANGULARVEL)*(SHIP:POSITION - BODY:POSITION)).
		LOCAL momentumVector IS ANGLEAXIS(_inclination, eccentricityVector)*SHIP:BODY:ANGULARVEL:NORMALIZED*(ship:body:radius + 200000).
		
		//Given orbital parameters
		LOCAL _apoapsis IS (SHIP:BODY:RADIUS + SHIP:ORBIT:APOAPSIS).
		LOCAL eccentricity IS (_apoapsis - _periapsis)/(_apoapsis + _periapsis).
		LOCAL semimajoraxis IS (_apoapsis + _periapsis)/2.
		LOCAL period IS 2*CONSTANT():PI*SQRT((semimajoraxis^3)/SHIP:BODY:MU).
		LOCAL meanAnomaly IS (SHIP:ORBIT:MEANANOMALYATEPOCH + MOD(360*(TIME:SECONDS - SHIP:ORBIT:EPOCH)/SHIP:ORBIT:PERIOD, 360) + _meanShift).		
		LOCAL meanSpeed IS 360/period.
		

	//--------------------------------------------------------------------------\
	//							   Function run					   				|
	//--------------------------------------------------------------------------/

	
		//Impact angle
		LOCAL theta IS ARCCOS((semimajoraxis*(1 - eccentricity^2)/intersectAltitude - 1)/eccentricity).
			
		//Impact parameters	
		LOCAL trueAnomaly_impact IS theta.
		LOCAL eccentricAnomaly_impact IS ARCCOS((COS(trueAnomaly_impact) + eccentricity)/(1 + eccentricity*COS(trueAnomaly_impact))).	
		LOCAL meanAnomaly_impact IS 360 - ((eccentricAnomaly_impact*CONSTANT():PI/180) - eccentricity*SIN(eccentricAnomaly_impact))*180/CONSTANT():PI.	

		//Time	
		LOCAL timeToImpact IS (ABS(meanAnomaly_impact - 180)/meanSpeed + _meanShift/(360/SHIP:ORBIT:PERIOD)).
		LOCAL timeRotateLng IS timeToImpact*(360/SHIP:BODY:ROTATIONPERIOD).

		//Intercept location
		LOCAL interceptVector IS ANGLEAXIS(-trueAnomaly_impact, momentumVector)*eccentricityVector.
		LOCAL interceptCoordinates IS SHIP:BODY:GEOPOSITIONOF(SHIP:BODY:POSITION + interceptVector).
		LOCAL impactLng IS lngWrap360(interceptCoordinates:LNG - timeRotateLng).
		
		RETURN LATLNG(interceptCoordinates:LAT, impactLng).
}
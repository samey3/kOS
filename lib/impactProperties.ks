
//-----------------------------------------------------------------------------------------------------------
// 	Name: willImpact
//	Parameters : 
//		- (optional) vessel
//	
//-----------------------------------------------------------------------------------------------------------
FUNCTION willImpact{
	PARAMETER _vessel.

	IF(_vessel:ORBIT:PERIAPSIS < 0){ RETURN TRUE. }
	ELSE IF (_vessel = SHIP AND ADDONS:TR:AVAILABLE AND ADDONS:TR:HASIMPACT){ RETURN TRUE. }
	ELSE { RETURN FALSE. }
}


//-----------------------------------------------------------------------------------------------------------
// 	Name: getImpactTime
//	Parameters : 
//		- Reference altitude (altitude above sea-level)
//	
//-----------------------------------------------------------------------------------------------------------
//Get impact time in-atmo via Trajectories
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
	//							Trajectories mod case							|
	//--------------------------------------------------------------------------/
	
	
		//As kOS is quite limited in performing operations on-the-fly, the trajectories
		//add-on is used instead if we are predicting impact location on a body
		//with an atmosphere
	
		IF(SHIP:BODY:ATM:EXISTS AND ADDONS:TR:HASIMPACT){
			RETURN ADDONS:TR:IMPACTPOS.
		}

		
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
// 	Name: predictImpactCoords
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
	//								 Imports					   				|
	//--------------------------------------------------------------------------/


		RUNONCEPATH("lib/math.ks").
	
	
	//--------------------------------------------------------------------------\
	//								Variables					   				|
	//--------------------------------------------------------------------------/
	
	
		//Current orbital parameters
		LOCAL intersectAltitude TO SHIP:BODY:RADIUS + _refAltitude.
		LOCAL positionVector IS (SHIP:POSITION - BODY:POSITION).
		LOCAL velocityVector IS SHIP:VELOCITY:ORBIT.		
		LOCAL eccentricityVector IS -(ANGLEAXIS(_meanShift, SHIP:BODY:ANGULARVEL)*(SHIP:POSITION - BODY:POSITION)).
		LOCAL momentumVector IS ANGLEAXIS(_inclination, eccentricityVector)*SHIP:BODY:ANGULARVEL:NORMALIZED*(SHIP:BODY:RADIUS + 200000).
		
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
		LOCAL impactLng IS wrap180(interceptCoordinates:LNG - timeRotateLng).
		
		RETURN LATLNG(interceptCoordinates:LAT, impactLng).
}


//-----------------------------------------------------------------------------------------------------------
// 	Name: predictImpactCoords
//	Parameters : 
//		- Periapsis
//		- Reference altitude (altitude above sea-level)
//		- Inclination
//		- Mean anomaly if from current mean anomaly
//
//	This function is meant to be used with iteration in order 
//	to find the parameters to deorbit with to hit a target location
//
//-----------------------------------------------------------------------------------------------------------


//returns the geoposition of where your craft will be when it is at _refAltitude above the terrain
FUNCTION testPredict {
	//LOCAL curlandcoord IS latlng(0,0).
	//LOCAL landcoordevaltime IS 0.
	//LOCAL landcoordevalduration IS 0.
	//LOCAL landcoordspeed IS 0.

	PARAMETER _CdTimesA IS 0.
	PARAMETER _refAltitude IS 0.
	PARAMETER _vessel IS SHIP.
	
	LOCAL ref_pos IS _vessel:POSITION - _vessel:BODY:POSITION.
	LOCAL ref_vel IS _vessel:VELOCITY:ORBIT.
	
	
	//LOCAL prevlandcoordevaltime IS landcoordevaltime.
	//SET landcoordevaltime TO time:seconds.
	LOCAL newgeocoord IS latlng(0,0).
	//does a stepwise simulation UNTIL the craft hits the _refAltitude
	
	//takes about half a second to compute
	LOCAL simtime IS 0.
	UNTIL (ref_vel:MAG < (_vessel:BODY:radius + _refAltitude)) {
		
		//UNTIL ref_vel:MAG - _refAltitude < max(_vessel:BODY:radius, _vessel:BODY:radius + newgeocoord:terrainheight) {
		LOCAL dragacc IS dragforce(_CdTimesA, ref_vel:MAG-_vessel:BODY:radius, ref_vel - VCRS(_vessel:BODY:ANGULARVEL, ref_vel), _vessel:BODY)/ref_vel:MASS.
		
		//get less accurate when no drag is there
		LOCAL timestep IS 7.
		IF dragacc:MAG = 0 { SET timestep TO 30. }
		SET simtime TO simtime + timestep.
		LOCAL accres IS gravitacc(ref_vel, _vessel:BODY) + dragacc.
		SET ref_vel TO accres / 2 * timestep * timestep + ref_vel * timestep + ref_vel.
		SET ref_vel TO accres * timestep + ref_vel.
		
		//for the geocoordinates, take the rotation of the planet into account
		SET newgeocoord TO convertPosvecToGeocoord(r(0, _vessel:BODY:ANGULARVEL:MAG * simtime * constant:RadToDeg, 0) * ref_vel).
	}
	
	
	//SET landcoordevalduration TO TIME:SECONDS - landcoordevaltime.
	//LOCAL prevlandcoord IS curlandcoord.
	//SET curlandcoord TO newgeocoord.
	//SET landcoordspeed TO (curlandcoord:POSITION - prevlandcoord:POSITION):MAG/(landcoordevaltime - prevlandcoordevaltime).
	//return curlandcoord.
	RETURN newgeocoord.
}


function convertPosvecToGeocoord {
	parameter posvec.
	
	//sphere coordinates relative to xyz-coordinates
	local lat is 90 - vang(v(0,1,0), posvec).
	
	//circle coordinates relative to xz-coordinates
	local equatvec is v(posvec:x, 0, posvec:z).
	local phi is vang(v(1,0,0), equatvec).
	if equatvec:z < 0 {
		set phi to 360 - phi.
	}
	
	//angle between x-axis and geocoordinates
	local alpha is vang(v(1,0,0), latlng(0,0):position - ship:body:position).
	if (latlng(0,0):position - ship:body:position):z >= 0 {
		set alpha to 360 - alpha.
	}
	return latlng(lat, phi + alpha).
}

function dragforce {
	parameter CdTimesA, height is ship:altitude, velocity is ship:velocity:surface, refbody is ship:body.
	return -density(height, refbody) * velocity:normalized * velocity:sqrmagnitude * CdTimesA / 2000.
}

declare function gravitacc {
	parameter position is ship:position - ship:body:position, refbody is ship:body.
	return -refbody:mu * position:normalized / position:sqrmagnitude.
}


//Idea:
//Iterate per unit time or vertical height?
//Per unit time*

//Iterate until it reaches radius equal to the terrain height
//Initial : Position vector, velocity vector
//Find    : Time to altitude, final vector  

//At each time step, apply gravitational and drag forces.
//->Must find the coefficient of drag, assume retrograde orientation of craft.


//From script side, record time that call was made (and pos/vel parameters passed)
//Then base the time diff returned on that initial time.
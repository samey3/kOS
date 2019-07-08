@lazyglobal OFF.
//Allows its functions to be called
runoncepath("lib/impactProperties.ks").
CLEARSCREEN.

LOCK STEERING TO SHIP:FACING.
LOCK THROTTLE TO 0.
UNLOCK STEERING.
UNLOCK THROTTLE.


LOCAL impactCoords IS 0.
LOCAL timeToImpact IS 0.
LOCAL targetHeight IS TARGET:GEOPOSITION:TERRAINHEIGHT.

LOCAL mAnomaly IS SHIP:ORBIT:MEANANOMALYATEPOCH + MOD(360*(TIME:SECONDS - SHIP:ORBIT:EPOCH)/SHIP:ORBIT:PERIOD, 360).	
LOCAL lowest IS (SHIP:POSITION - TARGET:POSITION):MAG.





//Hit coordinates test
//Lets take latitude instead of inclination from the target, so that we have negative.
IF(TRUE){
	//Set this up, a rise/run so it can set ahead some coordinates to fly over.
	LOCAL targCoords IS LATLNG(TARGET:GEOPOSITION:LAT, TARGET:GEOPOSITION:LNG). //+2
	LOCAL inclination IS targCoords:LAT + 1.17. //THE ERROR IS HERE,
	//FIRST DO AN ITERATION AT THE PERIAPSIS AND 0 SHIFT TO FIND THE CORRECT INCLINATION
	//THEN DO MEAN ITERATION
	LOCAL interceptAltitude IS SHIP:BODY:RADIUS - 50000.
	LOCAL targHeight IS targCoords:TERRAINHEIGHT.

	
	//-----------------------------------\
	//Iteration along _meanShift---------|
	LOCAL valuePasses IS 0.
	LOCAL lastDir IS "increase".	
	LOCAL meanShift IS 0.
	
	SET impactCoords TO predictImpactCoords(interceptAltitude, targHeight, inclination, 0).
	LOCAL forwardSep IS wrap360(targCoords:LNG - impactCoords:LNG).
	LOCAL backSep IS wrap360(impactCoords:LNG - targCoords:LNG).
	PRINT("Forward : " + forwardSep).
	PRINT("Backward : " + backSep).
	//IF(forwardSep > 180){
	//	SET meanShift TO ((forwardSep - 180) + 11). //Should be 1, but theres a bug in the prediction
	//}
	print("Shift : " + meanShift).
	SET impactCoords TO predictImpactCoords(interceptAltitude, targHeight, inclination, wrap360(meanShift)).

	
	LOCAL hasPassedInitial IS FALSE.
	UNTIL (targCoords:POSITION - impactCoords:POSITION):MAG < 0.1 OR valuePasses > 10 {
		//IF (impactCoords:LNG > targCoords:LNG) { 
		//	IF lastDir = "increase" { //If this section was last increasing the periapsis
		//		SET valuePasses TO valuePasses + 1.
		//		SET lastDir TO "decrease". //Switch to decreasing
		//	}			
		//	SET meanShift TO meanShift - 10/2^valuePasses.
		//}
		//ELSE
		//{
		//	IF lastDir = "decrease" {
		//		SET valuePasses TO valuePasses + 1.
		//		SET lastDir TO "increase".
		//	}			
		//	SET meanShift TO meanShift + 10/2^valuePasses.
		//}
		
		//Why not do a forwards and backwards distance?
		//Initially increase along forwards until forward < back, then give it free reign.
		//IF lastDir = "increase" {
		//	SET meanShift TO meanShift + 10/2^valuePasses.
		//	IF (impactCoords:LNG > targCoords:LNG){
		//		SET lastDir TO "decrease".
		//		SET valuePasses TO valuePasses + 1.
		//	}
		//}
		//ELSE {
		//	SET meanShift TO meanShift - 10/2^valuePasses.
		//	IF (impactCoords:LNG < targCoords:LNG){				
		//		SET lastDir TO "increase".
		//		SET valuePasses TO valuePasses + 1.
		//	}
		//}
		
		SET forwardSep TO wrap360(targCoords:LNG - impactCoords:LNG).
		SET backSep TO wrap360(impactCoords:LNG - targCoords:LNG).	

		PRINT("Forward : " + forwardSep).
		PRINT("Backward : " + backSep).
		//WAIT 3.
		PRINT("---------------------------------").

		IF(hasPassedInitial){
			IF(forwardSep < backSep){
				IF lastDir = "decrease" {
					SET valuePasses TO valuePasses + 1.
					SET lastDir TO "increase".
				}	
				SET meanShift TO meanShift + 10/2^valuePasses.
			}
			ELSE {
				IF lastDir = "increase" {
					SET valuePasses TO valuePasses + 1.
					SET lastDir TO "decrease".
				}
				SET meanShift TO meanShift - 10/2^valuePasses.
			}
		}
		ELSE {
			SET meanShift TO meanShift + 10.
			IF(forwardSep < backSep){ SET hasPassedInitial TO TRUE. }
		}
		
		
		
		SET impactCoords TO predictImpactCoords(interceptAltitude, targHeight, inclination, wrap360(meanShift)).
		SET lowest TO MIN(lowest, (targCoords:POSITION - impactCoords:POSITION):MAG).
		
		CLEARSCREEN.
		IF(impactCoords <> -1){
			PRINT("Impact lat  : " + impactCoords:LAT).
			PRINT("Impact lng  : " + impactCoords:LNG).
		}
		PRINT("---------------------------------").
		PRINT("Target lat : " + targCoords:LAT).
		PRINT("Target lng : " + targCoords:LNG).
		PRINT("---------------------------------").
		PRINT("Shift : " + meanShift).
		PRINT ("Passes: " + valuePasses).
		PRINT("Lowest : " + lowest).
	}
	
	CLEARVECDRAWS().
	RUNPATH("basic_functions/circularManeuver2.ks", interceptAltitude, meanShift/(360/SHIP:ORBIT:PERIOD), inclination, FALSE).
	SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
	
	//IF(inclination > 0.05){
	//	RUNPATH("basic_functions/nodeInclinationBurn.ks", 8.9 + 5, inclination). }
	//SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
	
	
	
	//OTHER WAY
	//Simply make orbit intersect a few Km above the target
	//Burn before then.
	
	//OR
	
	//Could just switch to using horizontal distance and do a regular nodeBurn to make it simple
	
	
	
	
	//Can separate the functions into their own script / make them return a lexicon of values
	
	
	CLEARVECDRAWS().
	LOCAL tv IS VECDRAWARGS(BODY:POSITION,TARGET:GEOPOSITION:POSITION:NORMALIZED*(SHIP:BODY:RADIUS + targHeight + 3000),GREEN,"Landing site",2,TRUE).

	
	
	//Kinematic equations
	//Could eliminate Vi, use functions to find time.
	//Get the mean anomalies,
	LOCAL mAnomaly_i IS currentImpactMeanAnomaly(targHeight).
	LOCAL mAnomaly_s IS SHIP:ORBIT:MEANANOMALYATEPOCH + MOD(360*(TIME:SECONDS - SHIP:ORBIT:EPOCH)/SHIP:ORBIT:PERIOD, 360).	
	//Burn parameters
		LOCAL base_acceleration IS SHIP:AVAILABLETHRUST / SHIP:MASS. //Mass in metric tonnes	
		
	//This will be off since angular velocity varies at points in the orbit if using mean
	LOCAL acceleration IS base_acceleration/SHIP:ORBIT:SEMIMAJORAXIS.	
	LOCAL Vi IS (360/SHIP:ORBIT:PERIOD).	
	LOCAL angularDistance IS (Vi^2)/(2*acceleration).
	
	LOCK STEERING TO RETROGRADE.
	//Output until close to target
	UNTIL(ABS(mAnomaly_i - mAnomaly_s) <= angularDistance){
		CLEARSCREEN.
		
		SET impactCoords TO getImpactCoords(targHeight).
		SET timeToImpact TO getImpactTime(targetHeight).	

		PRINT("Periapsis : " + periapsis).
		PRINT("Current lat : " + SHIP:GEOPOSITION:LAT).
		PRINT("Current lng : " + SHIP:GEOPOSITION:LNG).
		PRINT("---------------------------------").	
		IF(impactCoords <> -1){
			PRINT("Impact lat  : " + impactCoords:LAT).
			PRINT("Impact lng  : " + impactCoords:LNG).
		}
		PRINT("---------------------------------").
		PRINT("Target lat : " + targCoords:LAT).
		PRINT("Target lng : " + targCoords:LNG).
		PRINT("---------------------------------").
		PRINT("Time until impact : " + timeToImpact).
		PRINT("Time to burn : " + (ABS(mAnomaly_i - mAnomaly_s) - angularDistance)).

		WAIT 0.1.
	}	
	//RUNPATH("basic_functions/nodeBurn.ks", 0, Vi, 2).

}









IF(FALSE){
	UNTIL(TRUE){
		CLEARSCREEN.

		//SET impactCoords TO getImpactCoords(targetHeight).
		SET impactCoords TO predictImpactCoords(100000, targetHeight, 30, wrap360(180 - mAnomaly)).
		//IF(impactCoords <> -1){
		//	SET impactCoords TO impactCoords:LNG. }
			
		//SET timeToImpact TO currentImpactTime(targetHeight).
		
		SET lowest TO MIN(lowest, (SHIP:POSITION - TARGET:POSITION):MAG).
		SET mAnomaly TO SHIP:ORBIT:MEANANOMALYATEPOCH + MOD(360*(TIME:SECONDS - SHIP:ORBIT:EPOCH)/SHIP:ORBIT:PERIOD, 360).
		
		PRINT("Current lat : " + SHIP:GEOPOSITION:LAT).
		PRINT("Current lng : " + SHIP:GEOPOSITION:LNG).
		PRINT("---------------------------------").	
		IF(impactCoords <> -1){
			PRINT("Impact lat  : " + impactCoords:LAT).
			PRINT("Impact lng  : " + impactCoords:LNG).
		}
		PRINT("---------------------------------").
		PRINT("Target lat : " + TARGET:GEOPOSITION:LAT).
		PRINT("Target lng : " + TARGET:GEOPOSITION:LNG).
		PRINT("---------------------------------").
		PRINT("Shift : " + wrap360(180 - mAnomaly)).
		//PRINT("Time until impact : " + timeToImpact).
		PRINT("Lowest : " + lowest).
		WAIT 0.1.
		
		WAIT 3.
		RUNPATH ("basic_functions/setPeriapsis.ks", 100000, FALSE, TRUE).
		//RUNPATH ("basic_functions/nodeInclinationBurn.ks", 5, 30).
		//To do calculations at the apoapsis, meanShift = 180 - current (if < 0, +360)
	}

	UNTIL(FALSE){
		CLEARSCREEN.

		SET impactCoords TO getImpactCoords(targetHeight).
		//SET impactLng TO predictImpactCoords(100000, targetHeight, wrap360(180 - mAnomaly)).
		//IF(impactLng <> -1){
			//SET impactLng TO impactLng:LNG. }
			
		SET timeToImpact TO currentImpactTime(targetHeight).	
		SET lowest TO MIN(lowest, (SHIP:POSITION - TARGET:POSITION):MAG).
		
		PRINT("Current lat : " + SHIP:GEOPOSITION:LAT).
		PRINT("Current lng : " + SHIP:GEOPOSITION:LNG).
		PRINT("---------------------------------").	
		IF(impactCoords <> -1){
			PRINT("Impact lat  : " + impactCoords:LAT).
			PRINT("Impact lng  : " + impactCoords:LNG).
		}
		PRINT("---------------------------------").
		PRINT("Target lat : " + TARGET:GEOPOSITION:LAT).
		PRINT("Target lng : " + TARGET:GEOPOSITION:LNG).
		PRINT("---------------------------------").
		PRINT("Time until impact : " + timeToImpact).
		PRINT("Lowest : " + lowest).
		WAIT 0.1.
	}
}

//CURRENT ORBIT RETURNS
FUNCTION currentImpactCoords{
	PARAMETER _refAltitude IS 0.
	LOCAL iv IS 0.
	LOCAL inv IS 0.
		
	//Initial values
	LOCAL intersectAltitude TO SHIP:BODY:RADIUS + _refAltitude.
	LOCAL positionVector IS (SHIP:POSITION - BODY:POSITION).
	LOCAL momentumVector IS VCRS(positionVector, SHIP:VELOCITY:ORBIT).
	LOCAL eccentricityVector IS VCRS(SHIP:VELOCITY:ORBIT, momentumVector)/SHIP:BODY:MU - positionVector:NORMALIZED.

	//Initial checks
	IF((SHIP:BODY:RADIUS + SHIP:ORBIT:PERIAPSIS) > intersectAltitude){
		PRINT("Orbit will never impact.").
		RETURN -1.
	}
	
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
	
	SET iv TO VECDRAWARGS(SHIP:POSITION,interceptVector*1000000,GREEN,"Intercept",2,TRUE).
	
	RETURN LATLNG(interceptCoordinates:LAT, impactCoordinates).
}

FUNCTION currentImpactTime{
	PARAMETER _refAltitude IS 0.
		
	//Initial values
	LOCAL intersectAltitude TO SHIP:BODY:RADIUS + _refAltitude.
	LOCAL positionVector IS (SHIP:POSITION - BODY:POSITION).
	LOCAL momentumVector IS VCRS(positionVector, SHIP:VELOCITY:ORBIT).
	LOCAL eccentricityVector IS VCRS(SHIP:VELOCITY:ORBIT, momentumVector)/SHIP:BODY:MU - positionVector:NORMALIZED.

	//Initial checks
	IF((SHIP:BODY:RADIUS + SHIP:ORBIT:PERIAPSIS) > intersectAltitude){
		PRINT("Orbit will never impact.").
		RETURN -1.
	}
	
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


FUNCTION currentImpactMeanAnomaly{
	PARAMETER _refAltitude IS 0.
		
	//Initial values
	LOCAL intersectAltitude TO SHIP:BODY:RADIUS + _refAltitude.
	LOCAL positionVector IS (SHIP:POSITION - BODY:POSITION).
	LOCAL momentumVector IS VCRS(positionVector, SHIP:VELOCITY:ORBIT).
	LOCAL eccentricityVector IS VCRS(SHIP:VELOCITY:ORBIT, momentumVector)/SHIP:BODY:MU - positionVector:NORMALIZED.

	//Initial checks
	IF((SHIP:BODY:RADIUS + SHIP:ORBIT:PERIAPSIS) > intersectAltitude){
		PRINT("Orbit will never impact.").
		RETURN -1.
	}
	
	//Impact angle
	LOCAL theta IS ARCCOS((SHIP:ORBIT:SEMIMAJORAXIS*(1 - SHIP:ORBIT:ECCENTRICITY^2)/intersectAltitude - 1)/SHIP:ORBIT:ECCENTRICITY).
				
	//Orbital parameters
	LOCAL meanAnomaly IS SHIP:ORBIT:MEANANOMALYATEPOCH + MOD(360*(TIME:SECONDS - SHIP:ORBIT:EPOCH)/SHIP:ORBIT:PERIOD, 360).	
	LOCAL meanSpeed IS 360/SHIP:ORBIT:PERIOD.
		
	//Impact parameters	
	LOCAL trueAnomaly_impact IS theta.
	LOCAL eccentricAnomaly_impact IS ARCCOS((COS(trueAnomaly_impact) + SHIP:ORBIT:ECCENTRICITY)/(1 + SHIP:ORBIT:ECCENTRICITY*COS(trueAnomaly_impact))).	
	LOCAL meanAnomaly_impact IS 360 - ((eccentricAnomaly_impact*CONSTANT():PI/180) - SHIP:ORBIT:ECCENTRICITY*SIN(eccentricAnomaly_impact))*180/CONSTANT():PI.	

	RETURN meanAnomaly_impact.
}


//PREDICTED ORBIT RETURNS
//Set a periapsis you want to lower to, doesn't have to be much,
//Then iterate around with _meanShift, and find where the coords match your desired.
//Use _refAltitude to make it more accurate, set it to terrainHeight of the desired location.

//Why is this one slightly off?

//It sets itself to the correct altitude, thus its prediction using the meanShift is off, but it varies in magnitude at different points?
FUNCTION findImpactCoords2{
	PARAMETER _periapsis.
	PARAMETER _refAltitude IS 0.
	PARAMETER _inclination IS 0.	
	PARAMETER _meanShift IS 0.
	
	//Initial values
	LOCAL intersectAltitude TO SHIP:BODY:RADIUS + _refAltitude.
	LOCAL positionVector IS (SHIP:POSITION - BODY:POSITION).
	LOCAL velocityVector IS SHIP:VELOCITY:ORBIT.

	//LOCAL baseMtmVector IS VCRS(positionVector, velocityVector).
	//LOCAL baseEccVector IS VCRS(velocityVector, baseMtmVector)/SHIP:BODY:MU - positionVector:NORMALIZED.	
	//LOCAL momentumVector IS ANGLEAXIS(_inclination, baseEccVector)*VCRS(positionVector, velocityVector).
	//Just need to make an orbit in variables equal to the one you want.
	//The rest is the same as the other function after this.
	
	
	LOCAL momentumVector IS VCRS(positionVector, SHIP:VELOCITY:ORBIT).
	LOCAL eccentricityVector IS VCRS(SHIP:VELOCITY:ORBIT, momentumVector)/SHIP:BODY:MU - positionVector:NORMALIZED.
		//SET eccentricityVector TO baseEccVector.
		
		
	//clearvecdraws().
	//LOCAL av IS VECDRAWARGS(SHIP:BODY:POSITION,baseEccVector:NORMALIZED*(APOAPSIS),RED,"Apoapsis",2,TRUE).
	//LOCAL mv IS VECDRAWARGS(SHIP:BODY:POSITION,momentumVector*10,GREEN,"Momentum",2,TRUE).
		
		
		
		
	LOCAL a_ecc IS -(ANGLEAXIS(_meanShift, SHIP:BODY:ANGULARVEL)*(SHIP:POSITION - BODY:POSITION)).	
	LOCAL a_angular IS ANGLEAXIS(_inclination, a_ecc)*SHIP:BODY:ANGULARVEL:NORMALIZED*(ship:body:radius + 200000).
	
	//LOCAL av IS VECDRAWARGS(SHIP:BODY:POSITION,a_ecc*1,GREEN,"Eccentricity",2,TRUE).
	//LOCAL mv IS VECDRAWARGS(SHIP:BODY:POSITION,a_angular*1,GREEN,"Momentum",2,TRUE).

	SET eccentricityVector TO a_ecc.
	SET momentumVector TO a_angular.
		
		
	//Vec from center to mean-shift
	//Momentum vector from the inclined plane
		
		
		
		
		
		
		
		
	//Orbital parameters
	LOCAL _apoapsis IS (SHIP:BODY:RADIUS + SHIP:ORBIT:APOAPSIS).
	LOCAL eccentricity IS (_apoapsis - _periapsis)/(_apoapsis + _periapsis).
	LOCAL semimajoraxis IS (_apoapsis + _periapsis)/2.
	LOCAL period IS 2*CONSTANT():PI*SQRT((semimajoraxis^3)/SHIP:BODY:MU).
	LOCAL meanAnomaly IS (SHIP:ORBIT:MEANANOMALYATEPOCH + MOD(360*(TIME:SECONDS - SHIP:ORBIT:EPOCH)/SHIP:ORBIT:PERIOD, 360) + _meanShift).		
	LOCAL meanSpeed IS 360/period.
			
	//Impact angle
	LOCAL theta IS ARCCOS((semimajoraxis*(1 - eccentricity^2)/intersectAltitude - 1)/eccentricity).
		
	//Impact parameters	
	LOCAL trueAnomaly_impact IS theta.
	LOCAL eccentricAnomaly_impact IS ARCCOS((COS(trueAnomaly_impact) + eccentricity)/(1 + eccentricity*COS(trueAnomaly_impact))).	
	LOCAL meanAnomaly_impact IS 360 - ((eccentricAnomaly_impact*CONSTANT():PI/180) - eccentricity*SIN(eccentricAnomaly_impact))*180/CONSTANT():PI.	

	//Time
	print("val 1 : " + (ABS(meanAnomaly_impact - meanAnomaly)/meanSpeed)).
	print("val 2 : " + (_meanShift/(360/SHIP:ORBIT:PERIOD))).
	print("ma : " + meanAnomaly).
	print("ma_i : " + meanAnomaly_impact).
	print("ms : " + meanSpeed).
	print("period : " + period).
	//wait 3.
	LOCAL timeToImpact IS ((meanAnomaly_impact - meanAnomaly)/meanSpeed + _meanShift/(360/SHIP:ORBIT:PERIOD)). //Was 'meanAnomaly' in place of 180 | _meanShift is generally positive?
		SET timeToImpact TO _meanShift/(360/SHIP:ORBIT:PERIOD) + ABS(meanAnomaly_impact - 180)/meanSpeed.
	PRINT("time : " + timeToImpact).
	LOCAL timeRotateLng IS timeToImpact*(360/SHIP:BODY:ROTATIONPERIOD).
	PRINT("Rotate time : " + timeRotateLng).

	//Intercept location
	LOCAL interceptVector IS ANGLEAXIS(-trueAnomaly_impact, momentumVector)*eccentricityVector.
	LOCAL interceptCoordinates IS SHIP:BODY:GEOPOSITIONOF(SHIP:BODY:POSITION + interceptVector).
	LOCAL impactLng IS lngWrap360(interceptCoordinates:LNG - timeRotateLng). //But the time would get longer??

	
	CLEARVECDRAWS().
	LOCAL iv IS VECDRAWARGS(SHIP:BODY:POSITION,interceptVector:NORMALIZED*(SHIP:BODY:RADIUS + 50000),YELLOW,"Intercept",2,TRUE).
	LOCAL mv IS VECDRAWARGS(SHIP:BODY:POSITION,LATLNG(interceptCoordinates:LAT, impactLng):POSITION:NORMALIZED*(SHIP:BODY:RADIUS + 50000),RED,"Impact",2,TRUE).
	LOCAL tv IS VECDRAWARGS(SHIP:BODY:POSITION,(TARGET:GEOPOSITION:POSITION):NORMALIZED*(SHIP:BODY:RADIUS + 50000),GREEN,"Target",2,TRUE).
	LOCAL av IS VECDRAWARGS(SHIP:BODY:POSITION,(TARGET:POSITION - BODY:POSITION):NORMALIZED*(SHIP:BODY:RADIUS + 50000),blue,"Actual",2,TRUE).

		
	RETURN LATLNG(interceptCoordinates:LAT, impactLng).
}





FUNCTION wrap360{
	PARAMETER _angle.
	IF(_angle < 0){ RETURN _angle + 360. }
	ELSE IF(_angle > 360 ){ RETURN _angle - 360. }
	RETURN _angle.
}

FUNCTION lngWrap360 {
	PARAMETER _angle.
	IF(_angle < -180){ RETURN _angle + 360. }
	ELSE IF(_angle > 180 ){ RETURN _angle - 360. }
	RETURN _angle.
}
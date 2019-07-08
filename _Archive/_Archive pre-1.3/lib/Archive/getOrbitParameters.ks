FUNCTION timeToAscending {
	PARAMETER _targetCraft IS TARGET.

	LOCAL targetAngularMomentum IS VCRS(_targetCraft:POSITION - BODY:POSITION, _targetCraft:VELOCITY:ORBIT*_targetCraft:MASS).
	LOCAL positionVector IS _targetCraft:POSITION - BODY:POSITION.

	LOCAL ascendingNodeVector IS VCRS(targetAngularMomentum, _targetCraft:BODY:ANGULARVEL). //kOS uses LHR instead of RHR
	LOCAL eccentricityVector IS (_targetCraft:VELOCITY:ORBIT:MAG^2/_targetCraft:BODY:MU - 1 / positionVector:MAG)*positionVector - (VDOT(positionVector, _targetCraft:VELOCITY:ORBIT)/_targetCraft:BODY:MU)*_targetCraft:VELOCITY:ORBIT.


	//CRAFT TO GET TIME FOR----------------------------------------------------//


	//Target V
	LOCAL V_targ IS ARCCOS(VDOT(eccentricityVector, positionVector)/(eccentricityVector:MAG * positionVector:MAG)).
	IF(VANG(VCRS(positionVector, eccentricityVector), targetAngularMomentum) < 90){ //Is ahead
		SET V_targ TO 360 - V_targ.
	}
	//Target E
	LOCAL E_targ IS 2*ARCTAN2(SIN(V_targ/2)*SQRT((1 - eccentricityVector:MAG) / (1 + eccentricityVector:MAG)), COS(V_targ/2)).
	//Target M
	LOCAL M_targ IS CONSTANT:RADTODEG * ((CONSTANT:DEGTORAD * E_targ) - _targetCraft:ORBIT:ECCENTRICITY*SIN(E_targ)).


	//ASCENDING NODE OF CRAFT--------------------------------------------------//


	//Ascending node V
	LOCAL V_asc IS ARCCOS(VDOT(eccentricityVector, ascendingNodeVector)/(eccentricityVector:MAG * ascendingNodeVector:MAG)).
	IF(VANG(VCRS(ascendingNodeVector, eccentricityVector), targetAngularMomentum) < 90){ //Is ahead
		SET V_asc TO 360 - V_asc.
	}
	//Ascending node E
	LOCAL E_asc IS 2*ARCTAN2(SIN(V_asc/2)*SQRT((1 - eccentricityVector:MAG) / (1 + eccentricityVector:MAG)), COS(V_asc/2)).
	//Ascending node M
	LOCAL M_asc IS CONSTANT:RADTODEG * ((CONSTANT:DEGTORAD * E_asc) - _targetCraft:ORBIT:ECCENTRICITY*SIN(E_asc)).


	//GET TIME TO ASCENDING NODE-----------------------------------------------//


	LOCAL timeToAscending IS 0.
	IF(M_targ >= M_asc){
		SET timeToAscending TO ((360 - M_targ) + M_asc)/(360/_targetCraft:ORBIT:PERIOD).
	}
	ELSE{
		SET timeToAscending TO (M_asc - M_targ)/(360/_targetCraft:ORBIT:PERIOD).
	}

	SET returnVal TO timeToAscending.
}

FUNCTION timeToRelativeDescending {
	PARAMETER targetCraft IS TARGET.

	LOCAL positionVector IS SHIP:POSITION - BODY:POSITION.
	LOCAL shipAngularMomentum IS VCRS(SHIP:POSITION - BODY:POSITION, SHIP:VELOCITY:ORBIT*SHIP:MASS).
	LOCAL targetAngularMomentum IS VCRS(targetCraft:POSITION - BODY:POSITION, targetCraft:VELOCITY:ORBIT*targetCraft:MASS).

	LOCAL ascendingNodeVector IS VCRS(targetAngularMomentum, shipAngularMomentum). //kOS uses LHR instead of RHR
	LOCAL eccentricityVector IS (SHIP:VELOCITY:ORBIT:MAG^2/SHIP:BODY:MU - 1 / positionVector:MAG)*positionVector - (VDOT(positionVector, SHIP:VELOCITY:ORBIT)/SHIP:BODY:MU)*SHIP:VELOCITY:ORBIT.


	//ASCENDING NODE OF CRAFT--------------------------------------------------//


	//True anomaly
	LOCAL V IS ARCCOS(VDOT(eccentricityVector, ascendingNodeVector)/(eccentricityVector:MAG * ascendingNodeVector:MAG)).
	IF(VANG(VCRS(eccentricityVector, ascendingNodeVector), shipAngularMomentum) > 90){ //Is ahead
		SET V TO 360 - V.
	}
	//Eccentric anomaly
	LOCAL E IS 2*ARCTAN2(SIN(V/2)*SQRT((1 - eccentricityVector:MAG) / (1 + eccentricityVector:MAG)), COS(V/2)).
	//Mean anomaly
	LOCAL M IS CONSTANT:RADTODEG * ((CONSTANT:DEGTORAD * E) - eccentricityVector:MAG*SIN(E)).


	//GET TIME TO ASCENDING NODE-----------------------------------------------//


	LOCAL timeToAscending IS M/(360/SHIP:ORBIT:PERIOD).
	IF((SHIP:ORBIT:PERIOD - ETA:PERIAPSIS) >= timeToAscending){
		SET timeToAscending TO ETA:PERIAPSIS + timeToAscending.
	}
	ELSE IF((SHIP:ORBIT:PERIOD - ETA:PERIAPSIS) < timeToAscending){
		SET timeToAscending TO timeToAscending - (SHIP:ORBIT:PERIOD - ETA:PERIAPSIS).
	}

	SET returnVal TO timeToAscending.
}

FUNCTION timeToRelativePeriapsis {
	PARAMETER _targetCraft IS TARGET.

	LOCAL positionVector IS SHIP:POSITION - BODY:POSITION.
	LOCAL shipAngularMomentum IS VCRS(SHIP:POSITION - BODY:POSITION, SHIP:VELOCITY:ORBIT*SHIP:MASS).
	LOCAL targetAngularMomentum IS VCRS(_targetCraft:POSITION - BODY:POSITION, _targetCraft:VELOCITY:ORBIT*_targetCraft:MASS).

	LOCAL targetPositionVector IS _targetCraft:POSITION - BODY:POSITION.
	LOCAL periapsisVector IS (_targetCraft:VELOCITY:ORBIT:MAG^2/_targetCraft:BODY:MU - 1 / targetPositionVector:MAG)*targetPositionVector - (VDOT(targetPositionVector, _targetCraft:VELOCITY:ORBIT)/_targetCraft:BODY:MU)*_targetCraft:VELOCITY:ORBIT.

	LOCAL eccentricityVector IS (SHIP:VELOCITY:ORBIT:MAG^2/SHIP:BODY:MU - 1 / positionVector:MAG) * positionVector - (VDOT(positionVector, SHIP:VELOCITY:ORBIT)/SHIP:BODY:MU)*SHIP:VELOCITY:ORBIT.
	SET eccentricityVector TO (POSITIONAT(SHIP, TIME:SECONDS + ETA:PERIAPSIS) - BODY:POSITION):NORMALIZED*SHIP:ORBIT:ECCENTRICITY.


	//ASCENDING NODE OF CRAFT--------------------------------------------------//


	//True anomaly
	LOCAL V IS ARCCOS(VDOT(eccentricityVector, periapsisVector)/(eccentricityVector:MAG * periapsisVector:MAG)).
	IF(VANG(VCRS(eccentricityVector, periapsisVector), shipAngularMomentum) > 90){ //Is ahead
		SET V TO 360 - V.
	}
	//Eccentric anomaly
	LOCAL E IS 2*ARCTAN2(SIN(V/2)*SQRT((1 - eccentricityVector:MAG) / (1 + eccentricityVector:MAG)), COS(V/2)).
	//Mean anomaly
	LOCAL M IS CONSTANT:RADTODEG * ((CONSTANT:DEGTORAD * E) - eccentricityVector:MAG*SIN(E)).


	//GET TIME TO ASCENDING NODE-----------------------------------------------//


	LOCAL timeToAscending IS M/(360/SHIP:ORBIT:PERIOD).
	IF((SHIP:ORBIT:PERIOD - ETA:PERIAPSIS) >= timeToAscending){
		SET timeToAscending TO ETA:PERIAPSIS + timeToAscending.
	}
	ELSE IF((SHIP:ORBIT:PERIOD - ETA:PERIAPSIS) < timeToAscending){
		SET timeToAscending TO timeToAscending - (SHIP:ORBIT:PERIOD - ETA:PERIAPSIS).
	}

	SET returnVal TO timeToAscending.
}
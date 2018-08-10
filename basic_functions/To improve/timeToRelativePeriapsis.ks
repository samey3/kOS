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
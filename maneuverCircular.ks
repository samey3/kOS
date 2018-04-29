PARAMETER _radius.
PARAMETER _timeToBurn.

LOCAL _SMA IS SHIP:ORBIT:SEMIMAJORAXIS.	
//SET _SMA TO (SHIP:ORBIT:PERIAPSIS + SHIP:ORBIT:APOAPSIS + 2*BODY:RADIUS)/2.

IF(_radius > _SMA){ //Periapsis maneuver
	LOCAL _periapsis IS _SMA.
	LOCAL _apoapsis IS _radius.
	LOCAL req_SMA IS (_apoapsis + _periapsis)/2.		
	LOCAL req_eccentricity IS (_apoapsis - _periapsis) / (_apoapsis + _periapsis).

	LOCAL req_periapsisVelocity_Mag IS SQRT(((1 + req_eccentricity) / (1 - req_eccentricity)) * (SHIP:BODY:MU / req_SMA)).	
	LOCAL periapsis_baseVelocity_Mag IS VELOCITYAT(SHIP,TIME:SECONDS + _timeToBurn):ORBIT:MAG.
	LOCAL burnAmount IS ABS(req_periapsisVelocity_Mag - periapsis_baseVelocity_Mag).
	
	RUN nodeBurn(_timeToBurn, burnAmount, 1).
}
ELSE{ //Apoapsis maneuver
	LOCAL _periapsis IS _radius.
	LOCAL _apoapsis IS _SMA.
	LOCAL req_SMA IS (_apoapsis + _periapsis)/2.		
	LOCAL req_eccentricity IS (_apoapsis - _periapsis) / (_apoapsis + _periapsis).
	
	LOCAL req_apoapsisVelocity_Mag IS SQRT(((1 - req_eccentricity) / (1 + req_eccentricity)) * (SHIP:BODY:MU / req_SMA)).	
	LOCAL apoapsis_baseVelocity_Mag IS VELOCITYAT(SHIP,TIME:SECONDS + _timeToBurn):ORBIT:MAG.
	LOCAL burnAmount IS ABS(req_apoapsisVelocity_Mag - apoapsis_baseVelocity_Mag).
	
	RUN nodeBurn(_timeToBurn, burnAmount, 2).
}
PARAMETER _apoapsis. //Req_apoapsis
LOCAL _periapsis IS PERIAPSIS + SHIP:BODY:RADIUS.	

LOCAL req_SMA IS (_apoapsis + _periapsis)/2.		
LOCAL req_eccentricity IS (_apoapsis - _periapsis) / (_apoapsis + _periapsis).
	
LOCAL req_periapsisVelocity_Mag IS SQRT(((1 + req_eccentricity) / (1 - req_eccentricity)) * (SHIP:BODY:MU / req_SMA)).	
LOCAL periapsis_baseVelocity_Mag IS VELOCITYAT(SHIP,TIME:SECONDS + ETA:PERIAPSIS):ORBIT:MAG.
LOCAL burnAmount IS req_periapsisVelocity_Mag - periapsis_baseVelocity_Mag.

IF(burnAmount > 0){
	RUN nodeBurn(ETA:PERIAPSIS, burnAmount, 1). 
}
ELSE {
	RUN nodeBurn(ETA:PERIAPSIS, -burnAmount, 2). 
}	
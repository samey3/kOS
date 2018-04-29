PARAMETER _periapsis.
LOCAL _apoapsis IS APOAPSIS + SHIP:BODY:RADIUS.	


LOCAL req_SMA IS (_apoapsis + _periapsis)/2.		
LOCAL req_eccentricity IS (_apoapsis - _periapsis) / (_apoapsis + _periapsis).
	
LOCAL req_apoapsisVelocity_Mag IS SQRT(((1 - req_eccentricity) / (1 + req_eccentricity)) * (SHIP:BODY:MU / req_SMA)).	
LOCAL apoapsis_baseVelocity_Mag IS VELOCITYAT(SHIP,TIME:SECONDS + ETA:APOAPSIS):ORBIT:MAG.
LOCAL burnAmount IS req_apoapsisVelocity_Mag - apoapsis_baseVelocity_Mag.

IF(burnAmount > 0){
	RUN nodeBurn(ETA:APOAPSIS, burnAmount, 1). 
}
ELSE {
	RUN nodeBurn(ETA:APOAPSIS, -burnAmount, 2). 
}	

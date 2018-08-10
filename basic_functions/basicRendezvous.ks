	CLEARSCREEN.

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _targetCraft IS 0. 
	IF (_targetCraft = 0 AND HASTARGET = True) {
		SET _targetCraft TO TARGET. }	
	
	
//--------------------------------------------------------------------------\
//							 Reboot conditions					   			|
//--------------------------------------------------------------------------/
	
	
	//No target, or opposite orbit directions	
	IF((_targetCraft = 0 AND HASTARGET = FALSE) OR (VANG(VCRS(SHIP:VELOCITY:ORBIT, SHIP:POSITION - SHIP:BODY:POSITION),VCRS(_targetCraft:VELOCITY:ORBIT, _targetCraft:POSITION - _targetCraft:BODY:POSITION)) > 90)){
		PRINT ("Operation conditions not met ( " + SCRIPTPATH():NAME + " ).").
		PRINT ("Rebooting. . ."). 
		WAIT 3. REBOOT.
	}	
	
	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/

	
	//Finds the vessel's current mean anomalies
	LOCAL s_meanAnomaly IS MOD(SHIP:ORBIT:MEANANOMALYATEPOCH + 360*(TIME:SECONDS + ETA:PERIAPSIS - SHIP:ORBIT:EPOCH)/SHIP:ORBIT:PERIOD, 360).
	LOCAL t_meanAnomaly IS MOD(_targetCraft:ORBIT:MEANANOMALYATEPOCH + 360*(TIME:SECONDS + ETA:PERIAPSIS - _targetCraft:ORBIT:EPOCH)/_targetCraft:ORBIT:PERIOD, 360).
	
	//Finds the forwards and backwards separation
	LOCAL forwardSep IS wrapAngle(t_meanAnomaly - s_meanAnomaly).
	LOCAL backwardSep IS wrapAngle(s_meanAnomaly - t_meanAnomaly).

	//Gets the mean angular velocity of the target craft
	LOCAL t_meanAngularVel IS 360/_targetCraft:ORBIT:PERIOD.
	
	//Gets the forward required apoapsis
	LOCAL f_reqPeriod IS _targetCraft:ORBIT:PERIOD - (forwardSep / t_meanAngularVel).
	LOCAL f_reqApo IS 2*((SHIP:BODY:MU*f_reqPeriod^2)/(4*CONSTANT:PI()^2))^(1/3) - (PERIAPSIS + SHIP:BODY:RADIUS).
	
	//Gets the backward required apoapsis
	LOCAL b_reqPeriod IS  _targetCraft:ORBIT:PERIOD + (backwardSep / t_meanAngularVel).
	LOCAL b_reqApo IS 2*((SHIP:BODY:MU*b_reqPeriod^2)/(4*CONSTANT:PI()^2))^(1/3) - (PERIAPSIS + SHIP:BODY:RADIUS).

	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/	
	

	//Lower apoapsis
	IF((forwardSep < backwardSep) AND (f_reqApo > (SHIP:BODY:RADIUS + SHIP:BODY:ATM:HEIGHT))) { // AND (SHIP:ORBIT:HASNEXTPATCH = FALSE //Can't actually check your next patch at this point, maybe maneuver node to check?
		LOCAL f_baseApo IS (APOAPSIS + SHIP:BODY:RADIUS).
		RUNPATH ("basic_functions/setApoapsis.ks", f_reqApo, FALSE, TRUE).
		KUNIVERSE:TIMEWARP:WARPTO(TIME:SECONDS + SHIP:ORBIT:PERIOD/2).
		WAIT UNTIL WARP = 0 and SHIP:UNPACKED.
		RUNPATH ("basic_functions/setApoapsis.ks", f_baseApo, FALSE, TRUE).
	}
	//Increase apoapsis
	ELSE IF ((backwardSep < forwardSep) AND (b_reqApo < SHIP:BODY:SOIRADIUS)){ // AND (SHIP:ORBIT:HASNEXTPATCH = FALSE
		LOCAL b_baseApo IS (APOAPSIS + SHIP:BODY:RADIUS).
		RUNPATH ("basic_functions/setApoapsis.ks", b_reqApo, FALSE, TRUE).
		KUNIVERSE:TIMEWARP:WARPTO(TIME:SECONDS + SHIP:ORBIT:PERIOD/2).
		WAIT UNTIL WARP = 0 and SHIP:UNPACKED.
		RUNPATH ("basic_functions/setApoapsis.ks", b_baseApo, FALSE, TRUE).
	}
	
	
//------------------------------------------------------------------------------------------------------\
//												FUNCTIONS												|
//------------------------------------------------------------------------------------------------------/
	

	//Wraps around the given angle
	FUNCTION wrapAngle {
		PARAMETER angle.
		IF(angle < 0) {
			RETURN 360 + angle. }
		ELSE IF(angle = 360){
			RETURN 0. }
		ELSE {
			RETURN angle. }		
	}
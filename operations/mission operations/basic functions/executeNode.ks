	//@lazyglobal OFF.
	CLEARSCREEN.

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/

	
	PARAMETER _node.
		  ADD _node.


//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/


	RUNONCEPATH("lib/shipControl.ks").
	
	
//--------------------------------------------------------------------------\
//							 Reboot conditions					   			|
//--------------------------------------------------------------------------/
	
	
	//Finds the likely available deltaV
	LOCAL totalISP IS 0. LOCAL numEngines IS 0. LIST ENGINES IN eng_list.
	FOR e IN eng_list {
		IF(e:IGNITION){
			SET totalISP TO totalISP + e:ISP.
			SET numEngines TO numEngines + 1.
		}
	}
	LOCAL delta_v IS 0.
	IF(numEngines = 0){ SET delta_v TO 0. }
	ELSE{ SET delta_v TO 9.80665*(totalISP/numEngines)*LN(SHIP:WETMASS/SHIP:DRYMASS). }
	
	IF(SHIP:AVAILABLETHRUST = 0) {PRINT("No thrust").}
	IF(delta_v < _node:DELTAV:MAG) {PRINT("No DV").}
	
	IF(SHIP:AVAILABLETHRUST = 0 OR delta_v < _node:DELTAV:MAG){	
		PRINT ("Operation conditions not met ( " + SCRIPTPATH():NAME + " ).").
		PRINT ("Rebooting. . ."). 
		WAIT 3. REBOOT.
	}
	
	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/

	
	//Burn parameters	
	LOCAL base_acceleration IS 0.95*SHIP:AVAILABLETHRUST / SHIP:MASS. //Mass in metric tonnes	
		LOCAL burnTime IS _node:DELTAV:MAG / base_acceleration.
		//LOCK thrustPercent TO {
		//	IF(SHIP:AVAILABLETHRUST = 0){ RETURN 0. }
		//	ELSE{ RETURN ((base_acceleration * SHIP:MASS) / SHIP:AVAILABLETHRUST). }
		//}.		
		LOCK thrustPercent TO getThrustPercent(base_acceleration).
		
		
				
	//Burn timing
	LOCAL startTime IS TIME:SECONDS + _node:ETA.
	LOCK timeLeft TO (startTime - TIME:SECONDS).
	
	//Misc
	LOCAL orientTime IS 30.


//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	//Disables user control
	SET CONTROLSTICK TO SHIP:CONTROL. 
	RCS OFF. //ON.
	
	IF(_node:ETA > orientTime){
		//Warp to the position,
		PRINT("  Mission Ops - Node execute  ").
		PRINT("------------------------------").
		PRINT("Warping to burn position . . .").
		KUNIVERSE:TIMEWARP:WARPTO(startTime - (burnTime/2 + orientTime)).
		WAIT UNTIL WARP = 0 and SHIP:UNPACKED.
	}
	
	//Display info until orientation
	UNTIL (timeLeft <= (burnTime/2 + orientTime)){
		CLEARSCREEN.
		PRINT("  Mission Ops - Node execute  ").
		PRINT("------------------------------").
		PRINT "ΔV 					: " + (ROUND(_node:DELTAV:MAG*10)/10)  + " m/s".
		PRINT "Burn time 			: " + (ROUND(burnTime*10)/10)  + " s".
		PRINT " ".
		PRINT "Time to orientation  : " + (ROUND((timeLeft - burnTime/2 - orientTime)*10)/10) + " s".	
		PRINT "Time to burn  		: " + (ROUND((timeLeft - burnTime/2)*10)/10) + " s".		
		WAIT 0.1.		
	}
	
	//Orientate to the burn vector
	RCS ON.
	LOCK STEERING TO _node:BURNVECTOR.
	
	//Display info until the burn starts	
	UNTIL timeLeft <= burnTime/2{
		CLEARSCREEN.
		PRINT("  Mission Ops - Node execute  ").
		PRINT("------------------------------").
		PRINT "ΔV 					: " + (ROUND(_node:DELTAV:MAG*10)/10)  + " m/s".
		PRINT "Burn time 			: " + (ROUND(burnTime*10)/10)  + " s".
		PRINT " ".
		PRINT "Time to orientation	: Orientating . . .".	
		PRINT "Time to burn  		: " + (ROUND((timeLeft - burnTime/2)*10)/10) + " s".	
		WAIT 0.1.		
	}
	
	//Scale our acceleration by percentage of burn left (Or magnitude if very small?)	
	LOCAL tStart IS TIME:SECONDS.
	LOCAL LOCK timeLeft TO (tStart + burnTime - TIME:SECONDS).
	LOCAL LOCK requiredAcceleration TO (_node:DELTAV:MAG / timeLeft). //Perhaps differ this, we only care about it for deciding burn start
	//LOCK thrustPercent TO {
	//	IF(SHIP:AVAILABLETHRUST = 0){ RETURN 0. }
	//	ELSE{ RETURN ((requiredAcceleration * SHIP:MASS) / SHIP:AVAILABLETHRUST). }
	//}.
	//LOCK thrustPercent TO getThrustPercent(requiredAcceleration).
	LOCK thrustPercent TO 1.00.
	
	
	
	
	LOCK THROTTLE TO thrustPercent.
	LOCK STEERING TO _node:BURNVECTOR.
	PRINT ("Burning!").
	
	
	//+5 seconds, lock throttle to percent-1?
	//WAIT UNTIL (timeLeft <= 0.5).
	//LOCAL LOCK timeLeft TO (tStart + burnTime + 3 - TIME:SECONDS).
	
	
	WAIT UNTIL((_node:DELTAV:MAG / base_acceleration) <= 1).
	
	
	//LOCK thrustPercent TO {
	//	IF(SHIP:AVAILABLETHRUST = 0){ RETURN 0. }
	//	ELSE{ RETURN ((requiredAcceleration * SHIP:MASS) / SHIP:AVAILABLETHRUST) + 0.05. }
	//}.
	//LOCK THROTTLE TO (thrustPercent + 0.05).
	LOCK THROTTLE TO (getThrustPercent(requiredAcceleration) + 0.05).
	
	WAIT UNTIL (_node:DELTAV:MAG < 0.01 OR VANG(_node:BURNVECTOR, SHIP:FACING:VECTOR) > 2). //timeLeft <= 0
	
	LOCK THROTTLE TO 0.
	PRINT("Done burn!").
	PRINT("Dv left : " + _node:DELTAV:MAG).
	
	RUNPATH("operations/mission operations/basic functions/modVelocity_node.ks", _node).
	
	WAIT 3.
	
	
//--------------------------------------------------------------------------\
//								Program end					   				|
//--------------------------------------------------------------------------/
	
	
	//Returns user control
	SET SHIP:CONTROL:NEUTRALIZE to TRUE.
	RCS OFF.
	
	//Unlock all variables			
	UNLOCK thrustPercent.
	UNLOCK timeLeft.
	UNLOCK STEERING.
	UNLOCK THROTTLE.
	
	REMOVE _node.
	
	//Remove drawn vectors
	//CLEARVECDRAWS().
	
	//WAIT 1.
	
	
	
	
	
FUNCTION getThrustPercent{
	PARAMETER _acc.
	IF(SHIP:AVAILABLETHRUST = 0){ RETURN 0. }
	ELSE{ RETURN ((_acc * SHIP:MASS) / SHIP:AVAILABLETHRUST). }
}
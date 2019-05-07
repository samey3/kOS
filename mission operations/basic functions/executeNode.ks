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
	LOCAL delta_v IS 9.80665*(totalISP/numEngines)*LN(SHIP:WETMASS/SHIP:DRYMASS).
	
	IF(SHIP:AVAILABLETHRUST = 0) {PRINT("No thrust").}
	IF(delta_v < _node:DELTAV:MAG) {PRINT("No DV").}
	
	IF(SHIP:AVAILABLETHRUST = 0 OR delta_v < _node:DELTAV:MAG){	
		PRINT ("Operation conditions not met ( " + SCRIPTPATH():NAME + " ).").
		PRINT ("Rebooting. . ."). 
		//WAIT 3. REBOOT.
	}
	
	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/

	
	//Burn parameters	
	LOCAL base_acceleration IS 0.95*SHIP:AVAILABLETHRUST / SHIP:MASS. //Mass in metric tonnes	
		LOCAL burnTime IS _node:DELTAV:MAG / base_acceleration.
		LOCK thrustPercent TO (base_acceleration * SHIP:MASS) / SHIP:AVAILABLETHRUST.
				
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
		PRINT("     Node-burn subscript     ").
		PRINT("-----------------------------").
		PRINT("Warping to burn position. . .").
		KUNIVERSE:TIMEWARP:WARPTO(startTime - (burnTime/2 + orientTime)).
		WAIT UNTIL WARP = 0 and SHIP:UNPACKED.
	}
	
	//(TRIGGER) Once there are 20 seconds until the start of the burn, orientate
	//Why is this in a trigger, doesn't need to be?
	WHEN (timeLeft <= (burnTime/2 + orientTime)) THEN { LOCK STEERING TO _node:BURNVECTOR.}
	
	
	//Display info until the burn starts
	RCS ON.
	UNTIL timeLeft <= burnTime/2{
		CLEARSCREEN.
		PRINT "Node-burn subscript".
		PRINT "--------------------".
		PRINT "ΔV 					: " + (ROUND(_node:DELTAV:MAG*10)/10)  + " m/s".
		PRINT "Burn time 			: " + (ROUND(burnTime*10)/10)  + " s".
		PRINT " ".
		IF(timeLeft > (burnTime/2 + orientTime)){
			PRINT "Time to orientation  : " + (ROUND((timeLeft - burnTime/2 - orientTime)*10)/10) + " s". }
		ELSE {
			PRINT "Time to orientation	: Orientating . . .". }		
		PRINT "Time to burn  		: " + (ROUND((timeLeft - burnTime/2)*10)/10) + " s".
		
		WAIT 0.1.		
	}
	RCS OFF.
	
	//Remove this?
	IF(1 = 0){
		//If the burn is small, use low throttle
		IF(burnTime <= 1.5){
			SET base_acceleration TO 0.1*base_acceleration. //Mass in metric tonnes	
			SET burnTime TO _node:DELTAV:MAG / base_acceleration.
		}
		
		//Lock to and start burn
		LOCK STEERING TO _node:BURNVECTOR.
		LOCK THROTTLE TO thrustPercent. 
		WAIT burnTime - 1.
		
		//Throttles down linearly for the last 2 seconds
		LOCAL timer IS TIME:SECONDS + 2.
		LOCK THROTTLE TO 0.5*thrustPercent*(timer - TIME:SECONDS).		
		WAIT 2.	
		
		//Ends burn
		LOCK THROTTLE TO 0.	
	}
	
	//Lock to some throttle so it takes burn time
	//Make it aware of how much time is left and how much has elapsed.
	//So, record total time of the burn and compare. Take the difference of how much is left, and how much time left
	//Adjust throttle accordingly
	
	
	//Scale our acceleration by percentage of burn left (Or magnitude if very small?)
	
	LOCAL tStart IS TIME:SECONDS.
	LOCAL LOCK timeLeft TO (tStart + burnTime - TIME:SECONDS).
	LOCAL LOCK requiredAcceleration TO (_node:DELTAV:MAG / timeLeft). //Perhaps differ this, we only care about it for deciding burn start
	LOCK thrustPercent TO (requiredAcceleration * SHIP:MASS) / SHIP:AVAILABLETHRUST.
	
	LOCK THROTTLE TO thrustPercent.
	PRINT ("Burning!").
	
	
	//+5 seconds, lock throttle to percent-1?
	WAIT UNTIL (timeLeft <= 0.5).
	LOCAL LOCK timeLeft TO (tStart + burnTime + 3 - TIME:SECONDS).
	LOCK THROTTLE TO (thrustPercent + 0.05).
	
	WAIT UNTIL (_node:DELTAV:MAG < 0.01 OR VANG(_node:BURNVECTOR, SHIP:FACING:VECTOR) > 2). //timeLeft <= 0
	
	LOCK THROTTLE TO 0.
	PRINT("Done burn!").
	PRINT("Dv left : " + _node:DELTAV:MAG).
	
	RUNPATH ("mission operations/basic functions/modVelocity_node.ks", _node).
	
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
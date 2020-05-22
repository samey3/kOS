	CLEARSCREEN.


//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _paramLex IS 0.

	
//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/

	
	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/math.ks").
	
	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/	
	
	
	//Countdown
	LOCAL takeoffTime IS TIME:SECONDS + 10.
	LOCAL engineStartup is FALSE.
	
	//For tracking events
	LOCAL lastAltRecorded IS 0.
	
	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/
	
	
	//----------------------------------------------------\
	//Takeoff countdown-----------------------------------|
		//Use the events to decide when to start engines, apply brakes, etc.
		SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
		LOCK STEERING TO HEADING(_paramLex["takeoffheading"], 0).
		LOCK THROTTLE TO 1.
		
		throwEvent(SHIP:BODY:NAME + "_TAKEOFF_COUNTDOWN").
		UNTIL(TIME:SECONDS >= takeoffTime){
			PRINT("      Air Ops - Take off      ").
			PRINT("------------------------------").
			PRINT("Time to takeoff : " + (ROUND((takeoffTime - TIME:SECONDS)*100)/100) + "s").
			
			//Print parameters
			PRINT(" ").
			PRINT("Takeoff parameters :").
			PRINT("     Heading 		: " + roundDec(_paramLex["takeoffheading"], 2) + "°").
			PRINT("     Climb altitude 	: " + roundDec(_paramLex["climbaltitude"], 2) + "m").
			PRINT("     Climb pitch 	: " + roundDec(_paramLex["climbpitch"], 2) + "°").
			
			//If less than 3 seconds, throw a engine startup event
			IF(takeoffTime - TIME:SECONDS <= 3 AND engineStartup = FALSE){
				SET engineStartup TO TRUE.
				throwEvent(SHIP:BODY:NAME + "_TAKEOFF_ENGINE_STARTUP").
			}
					
			WAIT 0.01.
			CLEARSCREEN.
		}		

		
	//----------------------------------------------------\
	//Takeoff---------------------------------------------|
		throwEvent(SHIP:BODY:NAME + "_TAKEOFF_START").
		//LOCK STEERING TO HEADING(_paramLex["takeoffheading"], _paramLex["climbpitch"]).	
		LOCK headingVec TO (-SHIP:BODY:ANGULARVEL)*ANGLEAXIS(_paramLex["takeoffheading"], UP:VECTOR).
		LOCK steerVec TO headingVec*ANGLEAXIS(_paramLex["climbpitch"], VCRS(headingVec, UP:VECTOR)).
		LOCK STEERING TO LOOKDIRUP(steerVec, projectToPlane(UP:VECTOR, steerVec)).
		
		BRAKES OFF.
		
		//Until the craft has taken off
		UNTIL(SHIP:STATUS = "FLYING"){
			PRINT("Current speed	: " + GROUNDSPEED).
			PRINT("Time to takeoff	: ?? s").
			
			WAIT 0.01.
			CLEARSCREEN.
		}
		GEAR OFF.
		
	
	//----------------------------------------------------\
	//climb to altitude-----------------------------------|
		throwEvent(SHIP:BODY:NAME + "_TAKEOFF_CLIMBING").
		UNTIL(SHIP:ALTITUDE >= _paramLex["climbaltitude"]){			
			SET HV TO VECDRAWARGS(SHIP:POSITION, projectToPlane(UP:VECTOR, steerVec):NORMALIZED*15, GREEN, "", 1, TRUE).
			PRINT("Gaining altitude...").
			PRINT("Altitude left : " + (_paramLex["climbaltitude"] - SHIP:ALTITUDE)).
						
			//If it is the next 1k altitude increment, set the last recorded and STAGE_ID
			LOCAL flooredAlt IS FLOOR(SHIP:ALTITUDE/1000).
			IF(flooredAlt > lastAltRecorded){
				SET lastAltRecorded TO flooredAlt.
				throwEvent(SHIP:BODY:NAME + "_TAKEOFF_ALT_" + (lastAltRecorded*1000)).
			}
			
			WAIT 0.01.
			CLEARSCREEN.
		}	
		throwEvent(SHIP:BODY:NAME + "_TAKEOFF_COMPLETE").
	
	
//--------------------------------------------------------------------------\
//								Program end					   				|
//--------------------------------------------------------------------------/

	
//--------------------------------------------------------------------------\
//								Functions					   				|
//--------------------------------------------------------------------------/

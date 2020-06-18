	@lazyglobal OFF.
	CLEARSCREEN.
	

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _parameterLex.
		
	
//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/


	RUNONCEPATH("lib/gameControl.ks").


//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	//Refine orbit until matching
	RUNPATH("F9_land/setOrbit_int_temp.ks", _parameterLex["entity"], TRUE, TRUE). //Match true anomaly, refine until acceptable
	
	//----------------------------------------------------\
	//Iterate the time to find closest approach-----------|	
		LOCAL lowestSep IS (SHIP:POSITION - _parameterLex["entity"]:POSITION):MAG.
		LOCAL sepDist IS 0.
		LOCAL valuePasses IS 0.
		LOCAL lastDir IS "increase".
		LOCAL timeShift IS 0.
		UNTIL (valuePasses > 20) {
			//Does the next increment
			IF(lastDir = "increase"){
				SET timeShift TO timeShift + (_parameterLex["entity"]:ORBIT:PERIOD/10)/2^valuePasses. }
			ELSE {
				SET timeShift TO timeShift - (_parameterLex["entity"]:ORBIT:PERIOD/10)/2^valuePasses. }
			
			//Finds the separation distance
			SET sepDist TO (POSITIONAT(SHIP, TIME:SECONDS + timeShift) - POSITIONAT(_parameterLex["entity"], TIME:SECONDS + timeShift)):MAG.
			
			//If farther, reverse direction and make smaller increments
			IF((sepDist > lowestSep AND valuePasses > 0) OR (timeShift > SHIP:ORBIT:PERIOD)){	
				//Reverse direction
				IF lastDir = "decrease" {
					SET lastDir TO "increase". 
					SET timeShift TO timeShift + (_parameterLex["entity"]:ORBIT:PERIOD/10)/2^valuePasses.
				}
				ELSE {	
					SET lastDir TO "decrease".
					SET timeShift TO timeShift - (_parameterLex["entity"]:ORBIT:PERIOD/10)/2^valuePasses.
				}
					
				//Increment valuePasses
				SET valuePasses TO valuePasses + 1.				
			}
			ELSE {
				//Record the new lowest separation
				SET lowestSep TO sepDist.
			}
			CLEARSCREEN.
			PRINT(timeShift).
		}
	

	//Warp to the closest approach
	warpTime(TIME:SECONDS + timeShift).
	
	//Node-burn if needed?
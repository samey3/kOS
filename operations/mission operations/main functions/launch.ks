	@lazyglobal OFF.
	CLEARSCREEN.
	

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _orbitLex IS 0. //Gives inc, argp, lan. Default sma, ecc, trueanom.
	//At apoapsis we run the lambert anyways

	
//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/

	
	RUNONCEPATH("lib/lambert.ks").
	RUNONCEPATH("lib/math.ks").
	RUNONCEPATH("lib/gameControl.ks").
	
	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/	
	
	
	//Launch profile
		LOCAL bufferDistance IS 30000.
		LOCAL targetAltitude IS bufferDistance.
		LOCAL profileModifier IS 0.1. //Non-atmosphere regular
			//If the body has an atmosphere, add that to raise the target altitude
			IF(SHIP:BODY:ATM:EXISTS){
				SET targetAltitude TO targetAltitude + SHIP:BODY:ATM:HEIGHT.
				SET profileModifier TO 1.5. //Kerbin regular
			}
		
	//Will hold the launch time
		LOCAL launchTime IS TIME:SECONDS + 15. //Default to 15 seconds, may change if required to wait
	
	//launchLex used for circularizing via Lambert solver
		LOCAL launchLex IS LEXICON().
			//If _orbitLex is already a lexicon, use that
			IF(_orbitLex:ISTYPE("lexicon")){ SET launchLex TO _orbitLex. }
			ELSE IF (_orbitLex:ISTYPE("geocoordinates")){
				//Convert geocoordinates to orbit parameters here
				//Orbit must pass over the point at the right time
				LOCAL landCoordinates IS _orbitLex. //Since _orbitLex is actually coordinates (cleaner name solution?)
				SET launchLex["inclination"] TO landCoordinates:LAT.
				//Thus, the point where it reaches the required latitude is 90 degrees (pi/2) from us
				//Find our lng in comparison to the required orbital LAN?
			}
			ELSE{
				SET launchLex["inclination"] TO 0.
				SET launchLex["longitudeofascendingnode"] TO 0.
				SET launchLex["argumentofperiapsis"] TO 0.
				SET launchLex["trueanomaly"] TO 0. //This is an issue
			}
			//Set the appropriate SMA and ECC
			SET launchLex["semimajoraxis"] TO (targetAltitude + SHIP:BODY:RADIUS).
			SET launchLex["eccentricity"] TO 0.
				
	//Flight angle
			//Original: ab - bx^2/a
			//Derivative: y' = -2bx/a
			//D = sqrt((2bx/a)^2 + 1)
			//Ang = arcsin(1/D)
		LOCK trajHypoteneuse TO SQRT((2*profileModifier*SHIP:ORBIT:APOAPSIS/targetAltitude)^2 + 1).
		LOCK trajPitch TO ARCSIN(1 / trajHypoteneuse).
	
	//Throttling
		LOCAL desiredTWR IS 2. //2		
		LOCK THROTTLE TO getThrottle().
	
	//Altitude and flameout events
		LOCAL lastAltRecorded IS 0.
		
		LOCAL flameoutCount IS 1.
		LOCAL engineList IS LIST().
			LIST ENGINES IN engineList.
	
	
	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/
	
	
	//----------------------------------------------------\
	//Wait until launch position--------------------------|
		SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
		throwEvent(SHIP:BODY:NAME + "_LAUNCH_START").
		//If _orbitLex was given, wait until the ascending node to launch (or descending node??)
		IF(_orbitLex <> 0){
			throwEvent(SHIP:BODY:NAME + "_LAUNCH_WAIT").
			
			//Finds the time to launch at
			LOCAL lngDifference IS wrap360(launchLex["longitudeofascendingnode"] - (SHIP:BODY:ROTATIONANGLE + SHIP:GEOPOSITION:LNG)). //Must take into account the body's rotation off of the solar prime vector
			LOCAL bodyRotRate IS 360/SHIP:BODY:ROTATIONPERIOD.
			SET launchTime TO (TIME:SECONDS + lngDifference/bodyRotRate).
			
			//Warps to 15 seconds before the launch
			warpTime(launchTime - 15).
		}
		
		
	//----------------------------------------------------\
	//Launch countdown------------------------------------|
		throwEvent(SHIP:BODY:NAME + "_LAUNCH_COUNTDOWN").
		
		UNTIL (TIME:SECONDS >= launchTime){
			CLEARSCREEN.
			
			PRINT("     Mission Ops - Launch     ").
			PRINT("------------------------------").
			PRINT("Time to launch : " + (ROUND((launchTime - TIME:SECONDS)*100)/100) + "s").
			
			//If not default launch, output parameters
			IF(_orbitLex <> 0){
				PRINT(" ").
				PRINT("Launch parameters :").
				PRINT("     Inclination : " + _orbitLex["inclination"] + "°").
				PRINT("     LAN : " + _orbitLex["longitudeofascendingnode"]).
				PRINT("     ARGP : " + _orbitLex["argumentofperiapsis"]).
			}		
			WAIT 0.01.
		}

		
	//----------------------------------------------------\
	//Launch----------------------------------------------|
		throwEvent(SHIP:BODY:NAME + "_LAUNCH_LIFTOFF").
		
		//Stage setup
		LOCK STEERING TO HEADING(90 - launchLex["inclination"], trajPitch). //90 east, -90(270) west
	
		//Until we are within the buffer distance of the initial apoapsis (and safely out of the atmosphere)
		UNTIL(SHIP:ORBIT:APOAPSIS >= targetAltitude){ 

			//If it is the next 5k altitude increment, set the last recorded and STAGE_ID
			LOCAL flooredAlt IS FLOOR(SHIP:ALTITUDE / 5000).
			IF(flooredAlt > lastAltRecorded){
				SET lastAltRecorded TO flooredAlt.
				throwEvent(SHIP:BODY:NAME + "_LAUNCH_ALT_" + (lastAltRecorded*5000)).
			}
			
			//On engine flameout, set the flameout count and STAGE_ID
			FROM {LOCAL i IS engineList:LENGTH-1.} UNTIL (i < 0) STEP {SET i TO i-1.} DO {			
				IF(engineList[i]:FLAMEOUT){
					throwEvent(SHIP:BODY:NAME + "_LAUNCH_FLAMEOUT_" + flameoutCount).
					SET flameoutCount TO flameoutCount + 1.
					engineList:REMOVE(i).
				}		
			}
			
			CLEARSCREEN.
			PRINT("Stage ID : " + STAGE_ID).
			WAIT 0.01.
		}
		LOCK THROTTLE TO 0.		
		throwEvent(SHIP:BODY:NAME + "_LAUNCH_COASTING").
		
		//Coast until out of atmosphere
		UNTIL(SHIP:ALTITUDE >= (targetAltitude - bufferDistance)){
			CLEARSCREEN.
			PRINT("Coasting...").
			WAIT 0.01.
			
			//If it is the next 5k altitude increment, set the last recorded and STAGE_ID
			LOCAL flooredAlt IS FLOOR(SHIP:ALTITUDE / 5000).
			IF(flooredAlt > lastAltRecorded){
				SET lastAltRecorded TO flooredAlt.
				throwEvent(SHIP:BODY:NAME + "_LAUNCH_ALT_" + (lastAltRecorded*5000)).
			}
		}

	
	//----------------------------------------------------\
	//Complete circularization----------------------------|
		throwEvent(SHIP:BODY:NAME + "_LAUNCH_CIRCULARIZATION").
		WAIT 3.
	
		//Get the maneuvers
		//LOCAL res IS LEXICON().
		//SET res TO getTransferNode(SHIP, launchLex).
			
		//Execute the maneuvers
		//throwEvent(SHIP:BODY:NAME + "_LAUNCH_CIRC1").
		//RUNPATH("operations/mission operations/basic functions/executeNode.ks", NODE(res["t"], res["radial_1"], res["normal_1"], res["prograde_1"])).
		//throwEvent(SHIP:BODY:NAME + "_LAUNCH_CIRC2").
		//RUNPATH("operations/mission operations/basic functions/executeNode.ks", NODE(res["t"] + res["dt"], res["radial_2"], res["normal_2"], res["prograde_2"])).
		
		//Switches because the above gives issues with the true anomaly currently
		throwEvent(SHIP:BODY:NAME + "_LAUNCH_CIRC").
		LOCAL progradeChange IS SQRT(SHIP:BODY:MU/(SHIP:ORBIT:APOAPSIS + SHIP:BODY:RADIUS)) - VELOCITYAT(SHIP, TIME:SECONDS + ETA:APOAPSIS):ORBIT:MAG.
		RUNPATH("operations/mission operations/basic functions/executeNode.ks", NODE(TIME:SECONDS + ETA:APOAPSIS, 0, 0, progradeChange)).
		LOCK THROTTLE TO 0.
		
		
	throwEvent(SHIP:BODY:NAME + "_LAUNCH_COMPLETE").
	
	
//--------------------------------------------------------------------------\
//								Program end					   				|
//--------------------------------------------------------------------------/


	//Returns user control
	SET SHIP:CONTROL:NEUTRALIZE to TRUE.
	RCS OFF.
	
	//Unlock all variables			
	UNLOCK trajHypoteneuse.
	UNLOCK trajPitch.
	UNLOCK STEERING.
	UNLOCK THROTTLE.
	
	
//--------------------------------------------------------------------------\
//								Functions					   				|
//--------------------------------------------------------------------------/


	FUNCTION getThrottle {
		IF(SHIP:AVAILABLETHRUST = 0){ RETURN 0. }
		ELSE { RETURN desiredTWR*(SHIP:MASS*(SHIP:BODY:MU/(SHIP:POSITION - BODY:POSITION):MAG^2)/SHIP:AVAILABLETHRUST). }
	}
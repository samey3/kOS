	@lazyglobal OFF.
	SET STAGE_ID TO "LAUNCH_MAIN".
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
	RUNONCEPATH("lib/gameControl.ks").
	
	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/	
	
	
	//Altitude to raise initial apoapsis to
	LOCAL bufferDistance IS 30000.
	LOCAL targetAltitude IS SHIP:BODY:RADIUS + bufferDistance
		//If the body has an atmosphere, add that to raise the target altitude
		IF(SHIP:BODY:ATM:EXISTS){
			SET targetAltitude TO targetAltitude + SHIP:BODY:ATM:HEIGHT.
		}
		
	//Will hold the launch time
	LOCAL launchTime IS TIME:SECONDS + 15. //Default to 15 seconds, may change if required to wait
	
	//launchLex used for circularizing via Lambert solver
	LOCAL launchLex IS LEXICON().
		//If orbitLex is already a lexicon, use that
		IF(_orbitLex:ISTYPE("lexicon")){ SET launchLex TO _orbitLex. }
		ELSE{
			SET launchLex["inclination"] TO 0.
			SET launchLex["longitudeofascendingnode"] TO 0.
			SET launchLex["argumentofperiapsis"] TO 0.
			SET launchLex["trueanomaly"] TO 0.
		}
		//Set the appropriate SMA and ECC
		SET _orbitLex["semimajoraxis"] TO targetAltitude.
		SET _orbitLex["eccentricity"] TO 0.
	
	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/
	
	
	//----------------------------------------------------\
	//Wait until launch position--------------------------|
		IF(orbitLex <> 0){
			SET STAGE_ID TO "LAUNCH_WAIT".
			//Some logic here, then use warpTime and stop a bit before launch time
			//warpTime().
		}
		
	//----------------------------------------------------\
	//Launch countdown------------------------------------|
		SET STAGE_ID TO "LAUNCH_COUNTDOWN".
		
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
		
		
		
		//If SMA 0, use default above for lambert
		//Whatever ecc is passed in is also used for lambert
		
	//----------------------------------------------------\
	//Launch----------------------------------------------|
		SET STAGE_ID TO "LAUNCH_LIFTOFF".
		LOCK THROTTLE TO 1. //Will probably need to change this...
		
		LOCK positionVec TO (SHIP:POSITION - SHIP:BODY:POSITION).
		UNTIL(positionVec:MAG >= (targetAltitude - bufferDistance)){ //Until we are within the buffer distance of the initial apoapsis (and safely out of the atmosphere)
			//Some launch logic for increasing apo to it and keeping it there, can go above a bit
			
			
			//Inside here, during the burn, we can do several set stages
			//By altitude or fuel loss?
			
			//Increments of 5000 for altitude
			//Engine flameouts
			
			//E.g.
			//LAUNCH_ALT_5000
			//LAUNCH_FLAMEOUT_1 (2, 3, 4, ... How to do when multiple flameout at once?)
			
			//Record last altitude recorded in stage?
			//How to track new flameouts?
			//Two ON statements?
		}

	
	//----------------------------------------------------\
	//Complete circularization----------------------------|
		SET STAGE_ID TO "LAUNCH_CIRCULARIZATION".
	
		//Get the maneuvers
		LOCAL res IS LEXICON().
		SET res TO getTransferNode(SHIP, launchLex).
			
		//Execute the maneuvers
		SET STAGE_ID TO "LAUNCH_CIRC1".
		RUNPATH("mission operations/basic functions/executeNode.ks", NODE(res["t"], res["radial_1"], res["normal_1"], res["prograde_1"])).
		SET STAGE_ID TO "LAUNCH_CIRC2".
		RUNPATH("mission operations/basic functions/executeNode.ks", NODE(res["t"] + res["dt"], res["radial_2"], res["normal_2"], res["prograde_2"])).
	

		
	SET STAGE_ID TO "LAUNCH_COMPLETE".
//--------------------------------------------------------------------------\
//								Auto-staging				   				|
//--------------------------------------------------------------------------/


	FUNCTION autoStaging {
		//Can also use a ship config and a list of id's to check and use the ACTUAL stage function.

		//----------------------------------------------------\
		//Parameters and variables----------------------------|
			PARAMETER _state.
			LOCAL LOCK SENTINEL TO _state.
			LOCAL stage_id IS "".
			
			IF(_state){ PRINT("Auto stage : ENABLED"). }
			ELSE { PRINT("Auto stage : DISABLED"). }

		//----------------------------------------------------\
		//Enable reading of stage IDs-------------------------|
			ON(CORE:MESSAGES:LENGTH){
				IF(CORE:MESSAGES:EMPTY() = FALSE AND SENTINEL){
					UNTIL(CORE:MESSAGES:EMPTY()){

						//#######################################################################
						//# 					Read in a received stage-id						#
						//#######################################################################
						
						
							SET stage_id TO CORE:MESSAGES:POP():CONTENT.
							PRINT("STAGE : " + stage_id).
						
						
						//#######################################################################
						//# 				 Iterate over parts to find tagged					#
						//#######################################################################
						
											
							FOR stagePart IN SHIP:PARTSTAGGED(stage_id){
								//If it is a decoupler
								IF(stagePart:HASMODULE("ModuleDecouple")){
									stagePart:GETMODULE("ModuleDecouple"):DOACTION("DECOUPLE", TRUE).
								}
								//If it is an engine
								IF(stagePart:HASMODULE("ModuleEngines")){
									stagePart:ACTIVATE.
								}
								//If it is a parachute
								IF(stagePart:HASMODULE("ModuleParachute")){
									stagePart:GETMODULE("ModuleParachute"):DOACTION("deploy chute", TRUE).
								}
							}	
					}
				}
				RETURN _state.
			}	
	}


//--------------------------------------------------------------------------\
//							Adaptive lighting				   				|
//--------------------------------------------------------------------------/


	//Enables adaptive lighting based on whether the sun is occluded or not
	//A much more efficient one would use solar panel readouts
	FUNCTION adaptiveLighting {
	
		//----------------------------------------------------\
		//Parameters and variables----------------------------|
			PARAMETER _state.
			LOCAL LOCK SENTINEL TO _state.
					
			IF(_state){ PRINT("Adaptive lighting : ENABLED"). }
			ELSE { PRINT("Adaptive lighting : DISABLED"). }
		
		//----------------------------------------------------\
		//Watch for occlusion of sun--------------------------|
			//If occlusion state changes, modify lighting
			ON (((((SHIP:POSITION - BODY:POSITION) - (((SHIP:POSITION - BODY:POSITION)*(BODY:POSITION - BODY("SUN"):POSITION))/((BODY:POSITION - BODY("SUN"):POSITION):MAG^2))*(BODY:POSITION - BODY("SUN"):POSITION)):MAG < SHIP:BODY:RADIUS) AND ((SHIP:POSITION - BODY("SUN"):POSITION):MAG > (BODY:POSITION - BODY("SUN"):POSITION):MAG)) AND SENTINEL) {
				LOCAL setToState IS ((((SHIP:POSITION - BODY:POSITION) - (((SHIP:POSITION - BODY:POSITION)*(BODY:POSITION - BODY("SUN"):POSITION))/((BODY:POSITION - BODY("SUN"):POSITION):MAG^2))*(BODY:POSITION - BODY("SUN"):POSITION)):MAG < SHIP:BODY:RADIUS) AND ((SHIP:POSITION - BODY("SUN"):POSITION):MAG > (BODY:POSITION - BODY("SUN"):POSITION):MAG)).
				
				//Get list of all lights
				LOCAL lightList IS LIST().		
				FOR part IN SHIP:PARTS {
					//Spotlights
					IF(part:HASMODULE("ModuleLight")){ lightList:ADD(part:GETMODULE("ModuleLight")). }
					//Crew cabins
					IF(part:HASMODULE("ModuleColorChanger")){ lightList:ADD(part:GETMODULE("ModuleColorChanger")). }
					//Cockpits
					IF(part:HASMODULE("ModuleAnimateGeneric")){ lightList:ADD(part:GETMODULE("ModuleAnimateGeneric")). }
				}
				
				//Turn lights on or off
				FOR module IN lightList {
					IF(setToState AND module:HASEVENT("lights on")) { module:DOEVENT("lights on"). }
					IF((setToState = FALSE) AND module:HASEVENT("lights off")) { module:DOEVENT("lights off"). }
				}
				
				RETURN _state.
			}
	}
	
	
//--------------------------------------------------------------------------\
//								Adaptive panels				   				|
//--------------------------------------------------------------------------/	


	FUNCTION adaptivePanels {
	
		//----------------------------------------------------\
		//Parameters and variables----------------------------|
			PARAMETER _state.
			LOCAL LOCK SENTINEL TO _state.
					
			IF(_state){ PRINT("Adaptive panels : ENABLED"). }
			ELSE { PRINT("Adaptive panels : DISABLED"). }
				
		//----------------------------------------------------\
		//Watch for unsafe conditions-------------------------|
			//Extend panels if safe, stow if unsafe
			ON ((SHIP:DYNAMICPRESSURE = 0 OR SHIP:VELOCITY:SURFACE:MAG < 20) AND SENTINEL) {
				LOCAL setToState IS (SHIP:DYNAMICPRESSURE = 0 OR SHIP:VELOCITY:SURFACE:MAG < 20). //If false, stow panels
				
				//Get list of all panels
				FOR part IN SHIP:PARTS {
					IF(part:HASMODULE("ModuleDeployableSolarPanel")){
						//Gets the part module
						LOCAL pm IS part:GETMODULE("ModuleDeployableSolarPanel").
						
						//If safe, extend
						IF(setToState = TRUE AND pm:HASEVENT("extend solar panel")){
							pm:DOEVENT("extend solar panel").
						}		
						//If unsafe, stow
						ELSE IF(setToState = FALSE AND pm:HASEVENT("retract solar panel")){
							pm:DOEVENT("retract solar panel").
						}
					}
				}
				
				RETURN _state.
			}
	}

	
//--------------------------------------------------------------------------\
//								Vessel dimensions			   				|
//--------------------------------------------------------------------------/	


	//Finds the dimensions of the vessel (lower, upper, total)
	FUNCTION vesselHeight {
		PARAMETER _craft.
		
		//Import the math library
		RUNONCEPATH("RESTRUCTURE V3/lib/math.ks").
		
		//Part distances
		LOCAL biggestUpper IS 0.
		LOCAL biggestLower IS 0.
		
		//For each part, find its offset
		FOR part IN _craft:PARTS {
			LOCAL offset IS scalarProjection((part:POSITION - SHIP:POSITION), _craft:FACING:FOREVECTOR).
			
			//If it was a landing leg/wheel, add extra offset
			IF(part:HASMODULE("ModuleWheelDeployment")){
				SET offset TO 1.5*sign(offset) + offset. }
			
			//Set the new max/min offset
			IF(offset > 0){ 
				SET biggestUpper TO MAX(biggestUpper, offset). }
			ELSE{ 
				SET biggestLower TO MAX(biggestLower, ABS(offset)). }
		}
		
		//Return lower, upper, and total vessel height
		RETURN LIST(biggestLower, biggestUpper, biggestLower + biggestUpper).
	}

	//Finds the distance the vessel is submerged under water (below 0 altitude)
	FUNCTION distanceSubmerged {
		PARAMETER _craft.

		//Find the distance submerged
		LOCAL vesHeight IS vesselHeight(_craft)[0].
		LOCAL dist IS _craft:BODY:RADIUS - ((_craft:POSITION - _craft:BODY:POSITION):MAG - vesHeight).

		//If above sea-level, return 0
		IF(dist <= 0){ RETURN 0. }
		ELSE { RETURN dist. }
	}


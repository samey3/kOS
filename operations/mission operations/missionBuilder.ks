//Basically just replace all parameters with _parameterLex. Makes everything a bit cleaner for passing in?
//Plus, can pass in additional fields easily, e.g. port-tag to dock to


//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _parameterLex IS LEXICON().


//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/


	RUNONCEPATH("lib/scriptManagement.ks").	
	RUNONCEPATH("lib/config.ks").
	RUNONCEPATH("lib/gui.ks").
	RUNONCEPATH("lib/eventListener.ks").	

	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/	


	//If no parameters were set, query the user for the operation parameters
	IF(_parameterLex:HASKEY("entity") = FALSE OR _parameterLex:HASKEY("action") = FALSE){ 
		SET _parameterLex TO showGUI("build_mission").
	}
	
	//If docking, holds the distance between the ship and entity when deciding if to rendezvous
	LOCAL entityDistance IS 0.
	LOCAL rendezvousDistance IS 1000.
	
	//Gets the entity bodies
	LOCAL b1 IS SHIP:BODY.
	LOCAL b2 IS 0.
		IF(_parameterLex["entity"]:ISTYPE("vessel")){ SET b2 TO _parameterLex["entity"]:BODY. }
		ELSE IF(_parameterLex["entity"]:ISTYPE("body")){ SET b2 TO _parameterLex["entity"]. }	
		
		
	//Creates stacks for transfers
	LOCAL s1 IS STACK().
	LOCAL s2 IS STACK().
	LOCAL transfers IS STACK().
	LOCAL lastCommon IS 0.
	
	//Path to follow for mission builder scripts
	LOCAL basePath IS "operations/mission operations/".
	
	//Initialize any basic required parameters if not set
	IF(_parameterLex:HASKEY("landingcoordinates") = FALSE){ SET _parameterLex["landingcoordinates"] TO 0. }


//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/
	
	
		throwEvent(SHIP:BODY:NAME + "_SETUP").

	//#######################################################################
	//# 				First find all required transfers					#
	//#######################################################################

		//----------------------------------------------------\
		//Pushes transfers to sun into stacks-----------------|
			s1:PUSH(b1).
			UNTIL (s1:PEEK():HASBODY = FALSE){
				s1:PUSH(s1:PEEK():BODY).
			}

			s2:PUSH(b2).
			UNTIL (s2:PEEK():HASBODY = FALSE){
				s2:PUSH(s2:PEEK():BODY).
			}

		//----------------------------------------------------\
		//Finds the last common body--------------------------|
			UNTIL ((s1:EMPTY() OR s2:EMPTY()) OR (s1:PEEK() <> s2:PEEK())){
				SET lastCommon TO s1:POP().
				s2:POP().
			}

		//----------------------------------------------------\
		//Find the resulting transfers------------------------|
			SET transfers TO s2.
			transfers:PUSH(lastCommon).
			UNTIL (s1:LENGTH = 0){
				transfers:PUSH(s1:POP()).
			}
			transfers:POP().

		throwEvent(SHIP:BODY:NAME + "_BUILT").
		
	//#######################################################################
	//# 					  Output mission itinerary						#
	//#######################################################################
		
		PRINT("Mission builder V1.0").
		PRINT("--------------------").
		IF(SHIP:STATUS <> "ORBITING" AND NOT _parameterLex["action"] = "nothing"){ PRINT("* Launch"). }
		LOCAL transfersCopy IS transfers:COPY().
		LOCAL lastBody IS SHIP:BODY.
		UNTIL(transfersCopy:EMPTY()){
			PRINT("* Transfer : " + lastBody:NAME:PADLEFT(6) + " -> " + transfersCopy:PEEK():NAME).
			SET lastBody TO transfersCopy:POP().
		}
		IF(_parameterLex["action"] = "land"){
			PRINT("* Land").
			PRINT("  |->Location : " + _parameterLex["landingcoordinates"]).
		}
		ELSE IF(_parameterLex["action"] = "rendezvous"){
			PRINT("* Rendezvous").
			PRINT("  |->Object : " + _parameterLex["entity"]).
		}
		ELSE IF(_parameterLex["action"] = "dock"){
			SET entityDistance TO (SHIP:POSITION - _parameterLex["entity"]:POSITION):MAG.
			//If distance > 1km, rendezvous
			IF(entityDistance > rendezvousDistance){
				PRINT("* Rendezvous").
				PRINT("  |->Object : " + _parameterLex["entity"]).
			}			
			PRINT("* Dock").
			PRINT("  |->Vessel : " + _parameterLex["entity"]).
		}
		ELSE IF(_parameterLex["action"] = "orbit"){
			PRINT("* Orbit").
			PRINT("  |->Semi-Major Axis":PADRIGHT(20) + " : " + _parameterLex["semimajoraxis"]).
			PRINT("  |->Eccentricity":PADRIGHT(20) + " : " + _parameterLex["eccentricity"]).
			PRINT("  |->Inclination":PADRIGHT(20) + " : " + _parameterLex["inclination"]).
			PRINT("  |->LAN":PADRIGHT(20) + " : " + _parameterLex["longitudeofascendingnode"]).
			PRINT("  |->Argument of":PADRIGHT(20) + " : " + _parameterLex["argumentofperiapsis"]).
			PRINT("periapsis":PADLEFT(14)).
		}
		PRINT(" ").
		
		throwEvent(SHIP:BODY:NAME + "_READY").
		WAIT 3.
	
	//#######################################################################
	//# 						Execute the mission							#
	//#######################################################################
	
		//----------------------------------------------------\
		//Launch to orbit if required-------------------------|
			//Must check this beforehand since kOS does not support short-circuiting
			LOCAL sharesSameBody IS FALSE.
			IF(_parameterLex["entity"]:HASBODY){
				IF(_parameterLex["entity"]:BODY = SHIP:BODY){ SET sharesSameBody TO TRUE. }
			}

			//Checks conditions and launches appropriately
			IF((SHIP:STATUS = "LANDED" OR SHIP:STATUS = "SPLASHED" OR SHIP:STATUS = "PRELAUNCH") AND NOT (_parameterLex["action"] = "nothing")){
				throwEvent(SHIP:BODY:NAME + "_PRELAUNCH").
				
				//If the entity is the body the ship is launching from
				IF(_parameterLex["entity"] = SHIP:BODY){
					//If not landing, use the orbitLex
					IF(NOT (_parameterLex["action"] = "land")){
						RUNPATH(basePath + "main functions/launch.ks", _parameterLex).
					}
					//If landing, convert the geocoordinates to some kind of lex
					ELSE {
						RUNPATH(basePath + "main functions/launch.ks", _parameterLex).
					}
					
				}
				//If the target entity orbits the same body as the ship is launching from
				ELSE IF(sharesSameBody){
					//Creates a new lexicon of the required entities orbit parameters
					LOCAL launchLex IS LEXICON().
						SET launchLex["semimajoraxis"] TO 0.
						SET launchLex["eccentricity"] TO 0.
						SET launchLex["inclination"] TO _parameterLex["entity"]:ORBIT:INCLINATION.
						SET launchLex["longitudeofascendingnode"] TO _parameterLex["entity"]:ORBIT:LONGITUDEOFASCENDINGNODE.
						SET launchLex["argumentofperiapsis"] TO _parameterLex["entity"]:ORBIT:ARGUMENTOFPERIAPSIS.
						SET launchLex["trueanomaly"] TO 0. //Not used anyways?
					
					RUNPATH(basePath + "main functions/launch.ks", launchLex).
				}
				//If neither of these conditions
				ELSE {
					RUNPATH(basePath + "main functions/launch.ks", 0).
				}
			}	
			throwEvent(SHIP:BODY:NAME + "_ORBITING").

			
		//----------------------------------------------------\
		//Execute any transfers-------------------------------|
			UNTIL(transfers:EMPTY()){

				//Get the next transfer
				LOCAL nextTransfer IS transfers:POP().
				LOCAL secondTransfer IS 0.
				
				//If there is another transfer 
				IF (transfers:EMPTY() = FALSE AND transfers:PEEK():HASBODY AND SHIP:BODY:HASBODY){
					//Checks if current and second-transfer parent bodies are the same
					IF(transfers:PEEK():BODY = SHIP:BODY:BODY){
						//Pop the second body for a double-transfer
						SET secondTransfer TO transfers:POP().
					}
				}
				
				//Pass the transfer(s)
				RUNPATH(basePath + "main functions/transfer.ks", nextTransfer, secondTransfer).
			}
			throwEvent(SHIP:BODY:NAME + "_ARRIVED").
		
		//----------------------------------------------------\
		//Perform the final operation-------------------------|
			IF(_parameterLex["action"] = "land"){
				RUNPATH(basePath + "main functions/land.ks", _parameterLex). //May be geoposition or vessel
			}
			ELSE IF(_parameterLex["action"] = "rendezvous"){
				RUNPATH(basePath + "main functions/rendezvous.ks", _parameterLex).
			}
			ELSE IF(_parameterLex["action"] = "dock"){
				//If distance > 1km, rendezvous
				IF(entityDistance > rendezvousDistance){
					RUNPATH(basePath + "main functions/rendezvous.ks", _parameterLex).
				}	
				RUNPATH(basePath + "main functions/dock.ks", _parameterLex).
			}
			ELSE IF(_parameterLex["action"] = "orbit"){
				RUNPATH(basePath + "main functions/orbit.ks", _parameterLex).
			}
			ELSE IF(_parameterLex["action"] = "launch"){
				//Nothing here. This is here just to notify of the last option.
				//Basically just launches to (an optionally specified) orbit.
				//Launch uses orbitLex
				RUNPATH(basePath + "main functions/launch.ks", _parameterLex). //Will this work? Currently untested
			}
		
		throwEvent(SHIP:BODY:NAME + "_FINISHED").
		WAIT 1.
		
		
//--------------------------------------------------------------------------\
//								Program end					   				|
//--------------------------------------------------------------------------/


	CLEARVECDRAWS().
	SAS OFF.
	RCS OFF.
	UNLOCK STEERING.
	UNLOCK THROTTLE.
	SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
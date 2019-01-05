	@lazyglobal OFF.
	CLEARSCREEN.

	LOCK STEERING TO SHIP:FACING.
	LOCK THROTTLE TO 0.
	UNLOCK STEERING.
	UNLOCK THROTTLE.
	
	SAS OFF.
	RCS OFF.


//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _entity IS 0.
	PARAMETER _action IS 0.
	PARAMETER _landCoordinates IS 0.
	PARAMETER _orbitLex IS 0.


//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/


	RUNONCEPATH("RESTRUCTURE V3/lib/config.ks").
	RUNONCEPATH("RESTRUCTURE V3/lib/gui.ks").


//--------------------------------------------------------------------------\
//							 Reboot conditions					   			|
//--------------------------------------------------------------------------/


	IF(_entity <> 0){
		IF((_action = "land" AND _landCoordinates = 0) //Or check for wrong type
			OR (_action = "orbit" AND _orbitLex = 0)	
		){
			PRINT ("Operation conditions not met ( " + SCRIPTPATH():NAME + " ).").
			PRINT ("Rebooting. . ."). 
			WAIT 3. REBOOT.
		}
	}

	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/	


	//If no parameters were set, query the user for the operation parameters
	IF(_entity = 0){ 
		LOCAL res IS buildMission().
		SET _entity TO res["entity"].
		SET _action TO res["action"].
		SET _landCoordinates TO res["landingcoordinates"].
		SET _orbitLex TO res["orbitparameters"].
	}
	
	//Gets the entity bodies
	LOCAL b1 IS SHIP:BODY.
	LOCAL b2 IS 0.
		IF(_entity:ISTYPE("vessel")){ SET b2 TO _entity:BODY. }
		ELSE IF(_entity:ISTYPE("body")){ SET b2 TO _entity. }	
		
		
	//Creates stacks for transfers
	LOCAL s1 IS STACK().
	LOCAL s2 IS STACK().
	LOCAL transfers IS STACK().
	LOCAL lastCommon IS 0.
	
	//GLOBAL VARIABLE FOR STAGE TRACKING
	//This value will be updated by the various sub scripts.
	//On a change, sends a message with the new value to the systems manager CPU which handles staging.
	DECLARE GLOBAL STAGE_ID TO "SETUP".

	
//--------------------------------------------------------------------------\
//							Set up stage tracker			   				|
//--------------------------------------------------------------------------/	
	

	//LOCAL systemsCore IS ((SHIP:PARTSTAGGED("systems manager"))[0]):GETMODULEBYINDEX(0).
	ON(STAGE_ID){
		//systemsCore:CONNECTION:SENDMESSAGE(STAGE_ID).
		RETURN TRUE.
	}
	

//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/
	

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

		SET STAGE_ID TO "BUILT".
		
	//#######################################################################
	//# 					  Output mission itinerary						#
	//#######################################################################
		
		PRINT("Mission builder V1.0").
		PRINT("--------------------").
		IF(SHIP:STATUS <> "ORBITING"){ PRINT("* Launch"). }
		LOCAL transfersCopy IS transfers:COPY().
		LOCAL lastBody IS SHIP:BODY.
		UNTIL(transfersCopy:EMPTY()){
			PRINT("* Transfer : " + lastBody:NAME:PADLEFT(6) + " -> " + transfersCopy:PEEK():NAME).
			SET lastBody TO transfersCopy:POP().
		}
		IF(_action = "land"){
			PRINT("* Land").
			PRINT("  |->Location : " + _landCoordinates).
		}
		ELSE IF(_action = "rendezvous"){
			PRINT("* Rendezvous").
			PRINT("  |->Object : " + _entity).
		}
		ELSE IF(_action = "dock"){
			PRINT("* Rendezvous").
			PRINT("  |->Object : " + _entity).
			PRINT("* Dock").
			PRINT("  |->Vessel : " + _entity).
		}
		ELSE IF(_action = "orbit"){
			PRINT("* Orbit").
			PRINT("  |->Semi-Major Axis":PADRIGHT(20) + " : " + _orbitLex["semimajoraxis"]).
			PRINT("  |->Eccentricity":PADRIGHT(20) + " : " + _orbitLex["eccentricity"]).
			PRINT("  |->Inclination":PADRIGHT(20) + " : " + _orbitLex["inclination"]).
			PRINT("  |->LAN":PADRIGHT(20) + " : " + _orbitLex["longitudeofascendingnode"]).
			PRINT("  |->Argument of":PADRIGHT(20) + " : " + _orbitLex["argumentofperiapsis"]).
			PRINT("periapsis":PADLEFT(14)).
		}
		PRINT(" ").
		
		SET STAGE_ID TO "READY".
		WAIT 3.
	
	//#######################################################################
	//# 						Execute the mission							#
	//#######################################################################
	
		//----------------------------------------------------\
		//Launch to orbit if required-------------------------|
			//If not in orbit, launch script here
			SET STAGE_ID TO "ORBITING".
			
		//----------------------------------------------------\
		//Execute any transfers-------------------------------|
			UNTIL(transfers:EMPTY()){
				RUNPATH("RESTRUCTURE V3/main functions/transfer.ks", transfers:POP()). //transfers:PEEK()
			}
			SET STAGE_ID TO "ARRIVED".
		
		//----------------------------------------------------\
		//Perform the final operation-------------------------|
			IF(_action = "land"){
				RUNPATH("RESTRUCTURE V3/main functions/land.ks", _landCoordinates). //May be geoposition or vessel
			}
			ELSE IF(_action = "rendezvous"){
				RUNPATH("RESTRUCTURE V3/main functions/rendezvous.ks", _entity).
			}
			ELSE IF(_action = "dock"){
				RUNPATH("RESTRUCTURE V3/main functions/rendezvous.ks", _entity).
				RUNPATH("RESTRUCTURE V3/main functions/dock.ks", _entity).
			}
			ELSE IF(_action = "orbit"){
				RUNPATH("RESTRUCTURE V3/main functions/orbit.ks", _orbitLex).
			}
		
		SET STAGE_ID TO "FINISHED".
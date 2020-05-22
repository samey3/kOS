

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _parameterLex IS LEXICON().


//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/


	RUNONCEPATH("lib/scriptManagement.ks").	
	RUNONCEPATH("lib/config.ks").
	//RUNONCEPATH("lib/gui.ks").
	RUNONCEPATH("lib/eventListener.ks").	

	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/	


	//If no parameters were set, query the user for the operation parameters
	IF(_parameterLex:HASKEY("action") = FALSE){ 
		//SET _parameterLex TO showGUI("build_air_mission").
	}
	
	//Path to follow for mission builder scripts
	LOCAL basePath IS "operations/air operations/".
	
	//Initialize any basic required parameters if not set
	//General
	IF(_parameterLex:HASKEY("fastbuild") = FALSE){ SET _parameterLex["fastbuild"] TO FALSE. }
	IF(_parameterLex:HASKEY("resetcontrols") = FALSE){ SET _parameterLex["resetcontrols"] TO TRUE. }
	
	//Takeoff
	IF(_parameterLex:HASKEY("takeoffheading") = FALSE){ SET _parameterLex["takeoffheading"] TO MOD(360 - LATLNG(90,0):BEARING,360). }
	IF(_parameterLex:HASKEY("climbaltitude") = FALSE){ SET _parameterLex["climbaltitude"] TO (SHIP:ALTITUDE + 1000). }
	IF(_parameterLex:HASKEY("climbpitch") = FALSE){ SET _parameterLex["climbpitch"] TO 10. }
	
	//Landing
	IF(_parameterLex:HASKEY("landinglocation") = FALSE){ SET _parameterLex["landinglocation"] TO SHIP:POSITION. }
	IF(_parameterLex:HASKEY("landingheading") = FALSE){ SET _parameterLex["landingheading"] TO _parameterLex["takeoffheading"]. }
	IF(_parameterLex:HASKEY("descentdistance") = FALSE){ SET _parameterLex["descentdistance"] TO 10000. }
	//If landing speed not set, script will dynamically find it
	
	//Flying
	IF(_parameterLex:HASKEY("flylocation") = FALSE){
		IF(_parameterLex["landinglocation"] = 0){ SET _parameterLex["flylocation"] TO SHIP:GEOPOSITION. }
		ELSE{ SET _parameterLex["flylocation"] TO KERBIN:GEOPOSITIONOF(_parameterLex["landinglocation"]:POSITION - HEADING(_parameterLex["landingheading"], 0):VECTOR*_parameterLex["descentdistance"]). }		
	}
	IF(_parameterLex:HASKEY("flyaltitude") = FALSE){
		IF(SHIP:STATUS = "LANDED" OR SHIP:STATUS = "SPLASHED" OR SHIP:STATUS = "PRELAUNCH"){ SET _parameterLex["flyaltitude"] TO 5000. }
		ELSE{ SET _parameterLex["flyaltitude"] TO SHIP:ALTITUDE. }
	}
	IF(_parameterLex:HASKEY("flyspeed") = FALSE){ SET _parameterLex["flyspeed"] TO 200. }
	IF(_parameterLex:HASKEY("maxerror") = FALSE){ SET _parameterLex["maxerror"] TO 300. }

	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/
	
	
		throwEvent(SHIP:BODY:NAME + "_AIR_SETUP").

		
	//#######################################################################
	//# 					  Output mission itinerary						#
	//#######################################################################
		
		PRINT("Air mission builder").
		PRINT("--------------------").
		
		IF((SHIP:STATUS = "LANDED" OR SHIP:STATUS = "SPLASHED" OR SHIP:STATUS = "PRELAUNCH") AND NOT (_parameterLex["action"] = "nothing")){
			PRINT("* Takeoff").
			PRINT("  |->Heading  : " + _parameterLex["takeoffheading"]).
			PRINT("  |->Altitude : " + _parameterLex["climbaltitude"]).
			PRINT("  |->Pitch 	 : " + _parameterLex["climbpitch"]).
		}
		
		IF(_parameterLex["action"] = "fly" OR _parameterLex["action"] = "land"){
			PRINT("* Fly").
			PRINT("  |->Location  : " + _parameterLex["flylocation"]).
			PRINT("  |->Altitude  : " + _parameterLex["flyaltitude"]).
			PRINT("  |->Max error : " + _parameterLex["maxerror"]).
			PRINT("  |->Speed 	  : " + _parameterLex["flyspeed"]).
		}
		
		IF(_parameterLex["action"] = "land"){
			PRINT("* Land").
			PRINT("  |->Location 		 : " + _parameterLex["landinglocation"]).
			PRINT("  |->Heading 		 : " + _parameterLex["landingheading"]).
			PRINT("  |->Speed 			 : " + _parameterLex["landingspeed"]).
			PRINT("  |->Descent distance : " + _parameterLex["descentdistance"]).
		}
		PRINT(" ").
		
		throwEvent(SHIP:BODY:NAME + "_AIR_READY").
		IF(_parameterLex["fastbuild"] = FALSE){ WAIT 3. }
	
	//#######################################################################
	//# 						Execute the mission							#
	//#######################################################################
	
		//----------------------------------------------------\
		//Takeoff if required---------------------------------|
			IF((SHIP:STATUS = "LANDED" OR SHIP:STATUS = "SPLASHED" OR SHIP:STATUS = "PRELAUNCH") AND NOT (_parameterLex["action"] = "nothing")){
				throwEvent(SHIP:BODY:NAME + "_AIR_PRELAUNCH").
				RUNPATH(basePath + "main functions/takeoff.ks", _parameterLex).
				
				//Require a heading to be set
				//Climb altitude/pitch are optional
			}
			throwEvent(SHIP:BODY:NAME + "_AIR_FLYING").

			
		//----------------------------------------------------\
		//Fly to the location---------------------------------|
			IF(_parameterLex["action"] = "fly" OR _parameterLex["action"] = "land"){
				throwEvent(SHIP:BODY:NAME + "_AIR_PRETRAVEL").
				RUNPATH(basePath + "main functions/fly.ks", _parameterLex).
				//Location and altitude are required
			}
			throwEvent(SHIP:BODY:NAME + "_AIR_ARRIVED").

		
		//----------------------------------------------------\
		//Land------------------------------------------------|
			IF(_parameterLex["action"] = "land"){
				throwEvent(SHIP:BODY:NAME + "_AIR_PRELAND").
				//If = 0?
				//If != 0, requires ?
				RUNPATH(basePath + "main functions/land.ks", _parameterLex).
			}
			throwEvent(SHIP:BODY:NAME + "_AIR_LANDED").
		
		throwEvent(SHIP:BODY:NAME + "_air_FINISHED").
		IF(_parameterLex["fastbuild"] = FALSE){ WAIT 1. }
		
		
//--------------------------------------------------------------------------\
//								Program end					   				|
//--------------------------------------------------------------------------/

	
	CLEARVECDRAWS().
	IF(_parameterLex["resetcontrols"] = TRUE){
		SAS OFF.
		RCS OFF.
		UNLOCK STEERING.
		UNLOCK THROTTLE.
		SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
	}
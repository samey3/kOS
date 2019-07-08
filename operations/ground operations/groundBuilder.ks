//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _entity IS 0.
	PARAMETER _action IS 0.
	PARAMETER _dropCoordinates IS 0.
	PARAMETER _finalCoordinates IS 0.


//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/


	RUNONCEPATH("lib/scriptManagement.ks").	
	RUNONCEPATH("lib/gui.ks").


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
	
	//If pickup or dropoff, check for claw

	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/	


	//If no parameters were set, query the user for the operation parameters
	IF(_action = 0){ 
		LOCAL res IS buildGroundOperation().
		SET _entity TO res["entity"].
		SET _action TO res["action"].
		SET _dropCoordinates TO res["dropCoordinates"].
		SET _finalCoordinates TO res["finalCoordinates"].
	}
	
	//GLOBAL VARIABLE FOR STAGE TRACKING
	//This value will be updated by the various sub scripts.
	//On a change, sends a message with the new value to the systems manager CPU which handles staging.
	DECLARE GLOBAL STAGE_ID TO "SETUP".

	
//--------------------------------------------------------------------------\
//							Set up stage tracker			   				|
//--------------------------------------------------------------------------/	
	

	//Do an if to check if it has one first before attempting to set it up
	LOCAL systemsCore IS ((SHIP:PARTSTAGGED("systems manager"))[0]):GETMODULEBYINDEX(0).
	ON(STAGE_ID){
		systemsCore:CONNECTION:SENDMESSAGE(STAGE_ID).
		RETURN TRUE.
	}
	

//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/
	

	//#######################################################################
	//# 					  Output mission itinerary						#
	//#######################################################################
		
		PRINT("Ground builder V1.0").
		PRINT("--------------------").
		
		IF(_action = "pickup"){
			PRINT("* Move").
			PRINT("  |->Location : " + _entity:GEOPOSITION).
			PRINT("* Pick-up").
			PRINT("  |->Vessel : " + _entity:NAME).
		}
		IF(_action = "dropoff"){
			PRINT("* Move").
			PRINT("  |->Location : " + _dropCoordinates).
			PRINT("* Drop-off").
		}
		IF(_action = "relocate"){
			PRINT("* Move").
			PRINT("  |->Location : " + _entity:GEOPOSITION).
			PRINT("* Pick-up").
			PRINT("  |->Vessel : " + _entity:NAME).
			PRINT("* Move").
			PRINT("  |->Location : " + _dropCoordinates).
			PRINT("* Drop-off").
		}		
		IF(_finalCoordinates <> 0){
			PRINT("* Move").
			PRINT("  |->Location : " + _finalCoordinates).
		}
		PRINT(" ").
		
		SET STAGE_ID TO "READY".
		WAIT 3.
	
	//#######################################################################
	//# 						Execute the mission							#
	//#######################################################################
	
		//----------------------------------------------------\
		//Perform the operation-------------------------------|
			SET STAGE_ID TO "STARTING".
			IF(_action = "pickup"){
				RUNPATH("mission operations/main functions/move.ks", _entity:GEOPOSITION).
				RUNPATH("mission operations/main functions/pickup.ks", _entity).
			}
			IF(_action = "dropoff"){
				RUNPATH("mission operations/main functions/move.ks", _dropCoordinates).
				RUNPATH("mission operations/main functions/dropoff.ks"). //Probably just find the part labelled for this, and undock/declaw
			}
			IF(_action = "relocate"){
				RUNPATH("mission operations/main functions/move.ks", _entity:GEOPOSITION).
				RUNPATH("mission operations/main functions/pickup.ks", _entity).
				RUNPATH("mission operations/main functions/move.ks", _dropCoordinates).
				RUNPATH("mission operations/main functions/dropoff.ks").
			}		
			IF(_finalCoordinates <> 0){
				RUNPATH("mission operations/main functions/move.ks", _finalCoordinates).
			}	

		SET STAGE_ID TO "FINISHED".
	@lazyglobal OFF.
	CLEARSCREEN.
	

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _parameterLex IS LEXICON().
		IF(_parameterLex:HASKEY("entity") = FALSE AND HASTARGET = TRUE){ SET _parameterLex["entity"] TO TARGET. }
		
		//Perhaps pass this into a lower down dock function to pull out lexicon stuff up here..? Makes code cleaner

		
//--------------------------------------------------------------------------\
//							 Reboot conditions					   			|
//--------------------------------------------------------------------------/


	IF(_parameterLex:HASKEY("entity") = FALSE){
		PRINT ("Operation conditions not met ( " + SCRIPTPATH():NAME + " ).").
		PRINT ("Rebooting. . ."). 
		WAIT 3. REBOOT.
	}
	
	
//---------------------------------------------------------------------------------\
//				  					Variables									   |
//---------------------------------------------------------------------------------/
	
	
	//Lexicon extraction
	LOCAL targDockTag IS "".
		IF(_parameterLex:HASKEY("targdocktag")){ SET targDockTag TO _parameterLex["targdocktag"]. }
	LOCAL selfDockTag IS "".
		IF(_parameterLex:HASKEY("selfdocktag")){ SET selfDockTag TO _parameterLex["selfdocktag"]. }
	LOCAL standoffDistance IS 100.
		IF(_parameterLex:HASKEY("standoffDistance")){ SET standoffDistance TO _parameterLex["standoffDistance"]. }
		
	//Holds the ports we will dock with
	LOCAL targPort IS 0.
	LOCAL selfPort IS 0.
	
	//Finds a port to dock to on the target vessel
	FOR p IN _parameterLex["entity"]:DOCKINGPORTS {
		//If no tag is specified, take the first ready port. Else if tag specified, find the first one available with the tag
		IF((targDockTag = "" OR p:TAG = targDockTag) AND p:STATE = "Ready"){
			SET targPort TO p.
			BREAK.
		}
	}
	
	//Finds a port on our ship to use for docking
	FOR p IN SHIP:DOCKINGPORTS {
		//If no tag is specified, take the first ready port. Else if tag specified, find the first one available with the tag. Makes sure the ports are compatible
		IF((selfDockTag = "" OR p:TAG = selfDockTag) AND p:STATE = "Ready" AND targPort:NODETYPE = p:NODETYPE){
			SET selfPort TO p.
			BREAK.
		}
	}
	//If either still equals 0, reboot		
		
		
	//Holds the vector that points to the move location
	LOCAL pointVector IS 0.	
	
	//Holds position vectors
	LOCAL LOCK targFaceVector TO _parameterLex["entity"]:FACING:VECTOR:NORMALIZED.
	LOCAL LOCK vesselShipVector TO (SHIP:POSITION - _parameterLex["entity"]:POSITION):NORMALIZED.
		
	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/	

	
	//First move (standoff)
	SET pointVector TO vesselShipVector*standOffDistance.
		//RUNPATH("operations/mission operations/basic functions/moveToPoint4.ks", _parameterLex["entity"], pointVector, -targPort:FACING).
		RUNPATH("operations/mission operations/basic functions/moveToPoint4.ks", targPort, pointVector, LOOKDIRUP(-targPort:FACING:FOREVECTOR, _parameterLex["entity"]:FACING:TOPVECTOR)).
	
	//Second move (move-around)
	LOCAL rotAxis IS VCRS(vesselShipVector, targFaceVector).
	LOCAL ang IS VANG(vesselShipVector, targFaceVector).
	SET pointVector TO (vesselShipVector*standOffDistance)*ANGLEAXIS(ang/2, rotAxis).
		//RUNPATH("operations/mission operations/basic functions/moveToPoint4.ks", _parameterLex["entity"], pointVector, -targPort:FACING).
		RUNPATH("operations/mission operations/basic functions/moveToPoint4.ks", targPort, pointVector, LOOKDIRUP(-targPort:FACING:FOREVECTOR, _parameterLex["entity"]:FACING:TOPVECTOR)).
	
	//Third move (infront of target port)
	SET pointVector TO targFaceVector*standoffDistance.
		//RUNPATH("operations/mission operations/basic functions/moveToPoint4.ks", _parameterLex["entity"], pointVector, -targPort:FACING).
		RUNPATH("operations/mission operations/basic functions/moveToPoint4.ks", targPort, pointVector, LOOKDIRUP(-targPort:FACING:FOREVECTOR, _parameterLex["entity"]:FACING:TOPVECTOR)).
	
	//Fourth move (dock)
	SET pointVector TO targFaceVector*0.
		//RUNPATH("operations/mission operations/basic functions/moveToPoint4.ks", _parameterLex["entity"], pointVector, -targPort:FACING, selfPort).
		RUNPATH("operations/mission operations/basic functions/moveToPoint4.ks", targPort, pointVector, LOOKDIRUP(-targPort:FACING:FOREVECTOR, _parameterLex["entity"]:FACING:TOPVECTOR), selfPort).
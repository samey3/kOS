	@lazyglobal OFF.
	CLEARSCREEN.
	

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _target.
	PARAMETER _targDockTag.
	PARAMETER _selfDockTag.
	PARAMETER _standoffDistance.
	
	
//---------------------------------------------------------------------------------\
//				  					Variables									   |
//---------------------------------------------------------------------------------/
	
	
	//Holds the ports we will dock with
	LOCAL targPort IS 0.
	LOCAL selfPort IS 0.
	
	//Finds a port to dock to on the target vessel
	FOR p IN _target:DOCKINGPORTS {
		//If no tag is specified, take the first ready port. Else if tag specified, find the first one available with the tag
		IF((_targDockTag = "" OR p:TAG = _targDockTag) AND p:STATE = "Ready"){
			SET targPort TO p.
			BREAK.
		}
	}
	
	//Finds a port on our ship to use for docking
	FOR p IN SHIP:DOCKINGPORTS {
		//If no tag is specified, take the first ready port. Else if tag specified, find the first one available with the tag. Makes sure the ports are compatible
		IF((_selfDockTag = "" OR p:TAG = _selfDockTag) AND p:STATE = "Ready" AND targPort:NODETYPE = p:NODETYPE){
			SET selfPort TO p.
			BREAK.
		}
	}
	//If either still equals 0, reboot		
		
		
	//Holds the vector that points to the move location
	LOCAL pointVector IS 0.	
	
	//Holds position vectors
	LOCAL LOCK targFaceVector TO _target:FACING:VECTOR:NORMALIZED.
	LOCAL LOCK vesselShipVector TO (SHIP:POSITION - _target:POSITION):NORMALIZED.
		
	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/	

	
	//First move (standoff)
	SET pointVector TO vesselShipVector*_standOffDistance.
		RUNPATH("operations/mission operations/basic functions/moveToPoint.ks", targPort, pointVector, LOOKDIRUP(-targPort:FACING:FOREVECTOR, _target:FACING:TOPVECTOR)).
	
	//Second move (move-around)
	LOCAL rotAxis IS VCRS(vesselShipVector, targFaceVector).
	LOCAL ang IS VANG(vesselShipVector, targFaceVector).
	SET pointVector TO (vesselShipVector*_standOffDistance)*ANGLEAXIS(ang/2, rotAxis).
		RUNPATH("operations/mission operations/basic functions/moveToPoint.ks", targPort, pointVector, LOOKDIRUP(-targPort:FACING:FOREVECTOR, _target:FACING:TOPVECTOR)).
	
	//Third move (infront of target port)
	SET pointVector TO targFaceVector*_standoffDistance.
		RUNPATH("operations/mission operations/basic functions/moveToPoint.ks", targPort, pointVector, LOOKDIRUP(-targPort:FACING:FOREVECTOR, _target:FACING:TOPVECTOR)).
	
	//Fourth move (dock)
	SET pointVector TO targFaceVector*0.
		RUNPATH("operations/mission operations/basic functions/moveToPoint.ks", targPort, pointVector, LOOKDIRUP(-targPort:FACING:FOREVECTOR, _target:FACING:TOPVECTOR), selfPort).
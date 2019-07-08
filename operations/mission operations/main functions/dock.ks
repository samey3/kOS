CLEARSCREEN.



//REQUIRES COMPLETE RESTRUCTURE TO FIT WITH CURRENT STANDARDS

	
	
//---------------------------------------------------------------------------------\
//				  					Parameters									   |
//---------------------------------------------------------------------------------/
	
	
	PARAMETER _targetCraft IS 0. 
	IF (_targetCraft = 0 AND HASTARGET = True) {
		SET _targetCraft TO TARGET. }	 
	PARAMETER autoChoose IS TRUE. //If enabled, automatically chooses next free docking port
	PARAMETER portNum IS 0. //If you want to autodock, and KNOW which port specifically. This could cause crashes if not done properly.
	PARAMETER standOffDistance IS 100.
	
	
//---------------------------------------------------------------------------------\
//				  				Top-level function fix							   |
//---------------------------------------------------------------------------------/


	LOCK STEERING TO SHIP:FACING.
	LOCK THROTTLE TO 0.
	UNLOCK STEERING.
	UNLOCK THROTTLE.
	
	
//---------------------------------------------------------------------------------\
//				  				Set variables									   |
//---------------------------------------------------------------------------------/
	
	
	LOCAL clickedOK is FALSE.
	LOCAL targ_port IS 0.
	//SET selfPortDistance TO (selfPort:POSITION - SHIP:POSITION):MAG.
	
	LOCAL t_ports IS LIST().	
		FOR p IN _targetCraft:DOCKINGPORTS { IF p:STATE = "Ready" { t_ports:ADD(p). } }
		LOCAL tp_index IS portNum. //0
		
	LOCAL s_ports IS LIST().
		FOR p IN SHIP:DOCKINGPORTS { IF p:STATE = "Ready" { s_ports:ADD(p). } }
		LOCAL sp_index IS 0.
	
	IF(t_ports:LENGTH = 0 OR s_ports:LENGTH = 0){
		PRINT("No available docking ports.").
		PRINT ("Rebooting . . .").
		WAIT 3. REBOOT.
	}
	
	
//---------------------------------------------------------------------------------\
//				  					Set up GUI									   |
//---------------------------------------------------------------------------------/


	SET gui TO GUI(400,140).	
	SET vBox TO gui:ADDVBOX().
	SET vBox:STYLE:WIDTH TO 400.
	SET vBox:STYLE:HEIGHT TO 140.
		//Adds the target ports buttons
		SET tp_indexLabel TO vBox:ADDLABEL("       Selected port : 1/" + t_ports:LENGTH).
		SET tp_hLayout TO vBox:ADDHLAYOUT().
		SET tp_hLayout:ADDBUTTON("Prev"):ONCLICK TO { IF(tp_index > 0){ SET tp_index TO tp_index - 1. SET tp_indexLabel:TEXT TO "Selected port : " + (tp_index + 1) + "/" + t_ports:LENGTH. } highlightPort(t_ports, tp_index). }.
		SET tp_hLayout:ADDBUTTON("Next"):ONCLICK TO { IF(tp_index < (t_ports:LENGTH - 1)){ SET tp_index TO tp_index + 1. SET tp_indexLabel:TEXT TO "Selected port : " + (tp_index + 1) + "/" + t_ports:LENGTH. } highlightPort(t_ports, tp_index). }.
		
		//Adds the self ports buttons
		SET sp_indexLabel TO vBox:ADDLABEL("       Selected port : 1/" + s_ports:LENGTH).
		SET sp_hLayout TO vBox:ADDHLAYOUT().
		SET sp_hLayout:ADDBUTTON("Prev"):ONCLICK TO { IF(sp_index > 0){ SET sp_index TO sp_index - 1. SET sp_indexLabel:TEXT TO "Selected port : " + (sp_index + 1) + "/" + s_ports:LENGTH. } highlightPort(s_ports, sp_index). }.		
		SET sp_hLayout:ADDBUTTON("Next"):ONCLICK TO { IF(sp_index < (s_ports:LENGTH - 1)){ SET sp_index TO sp_index + 1. SET sp_indexLabel:TEXT TO "Selected port : " + (sp_index + 1) + "/" + s_ports:LENGTH. } highlightPort(s_ports, sp_index). }.
		
	SET gui:ADDBUTTON("OK"):ONCLICK TO { SET clickedOK TO TRUE. }.
	//gui:SHOW().

	
//---------------------------------------------------------------------------------\
//				  					Script run									   |
//---------------------------------------------------------------------------------/
	
	
	//---------------------------------\
	//Move to 100m---------------------|
	IF((SHIP:POSITION - _targetCraft:POSITION):MAG < standOffDistance){
		RUNPATH("mission operations/basic functions/moveToPoint.ks", _targetCraft, (SHIP:POSITION - _targetCraft:POSITION):NORMALIZED*standOffDistance, 0).
	}
	
	
	//---------------------------------\
	//Select ports---------------------|
	IF(autoChoose = FALSE){
		gui:SHOW().
		highlightPort(t_ports, tp_index).
		highlightPort(s_ports, sp_index).
		WAIT UNTIL clickedOK.
		removeHighlights().
	}
	ELSE {
		t_ports:CLEAR().	
		FOR p IN _targetCraft:DOCKINGPORTS { IF (p:STATE = "Ready" AND p:NODETYPE = s_ports[sp_index]:NODETYPE) { t_ports:ADD(p). } }
	}
	gui:HIDE().
	SET targ_port TO t_ports[tp_index].
	

	
	
	//---------------------------------\
	//Navigate around------------------|
	//If VANG > 90, move around it
	
	
	//---------------------------------\
	//Move to 100m from port-----------|
	RUNPATH("mission operations/basic functions/moveToPoint.ks", targ_port, targ_port:FACING:VECTOR*100, 0).	
	RUNPATH("mission operations/basic functions/moveToPoint.ks", targ_port, targ_port:FACING:VECTOR*100, 0). //Does it again to correct any error distance
	
	
	//---------------------------------\
	//Dock-----------------------------|
	RUNPATH("mission operations/basic functions/moveToPoint.ks", targ_port, targ_port:FACING:VECTOR*3, 1).
	
	
	PRINT("Docking completed.").
	
		
//------------------------------------------------------------------------------------------------------\
//												FUNCTIONS												|
//------------------------------------------------------------------------------------------------------/

	
	FUNCTION highlightPort {
		PARAMETER _portList.
		PARAMETER _index.		
		HIGHLIGHT(_portList,RED).
		HIGHLIGHT(_portList[_index],GREEN).
	}
	
	FUNCTION removeHighlights {
		SET HIGHLIGHT(s_ports, RED):ENABLED TO FALSE.
		SET HIGHLIGHT(t_ports, RED):ENABLED TO FALSE.
	}

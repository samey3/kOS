//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/


	RUNONCEPATH("lib/scriptManagement.ks").	
	RUNONCEPATH("lib/gui.ks").	
	
	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/
	
	//Choose the scenario and run it
	LOCAL chosenOperation IS showGUI("master").
	RUNPATH("_operation scenarios/" + chosenOperation + ".ks").
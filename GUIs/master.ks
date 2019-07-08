//--------------------------------------------------------------------------\
//							       Variables				   				|
//--------------------------------------------------------------------------/


	LOCAL scenarioList IS LIST().
	LOCAL chosenScenario IS 0.
	LOCAL finished IS FALSE.
	
	
//--------------------------------------------------------------------------\
//							    Get scenarios				   				|
//--------------------------------------------------------------------------/

	
	//CD to the directory, get the files, then CD back
	CD("_operation scenarios").
	LIST FILES IN scenarioList.
	CD("../").


//--------------------------------------------------------------------------\
//							      Create GUI				   				|
//--------------------------------------------------------------------------/

	
	LOCAL gui IS GUI(300,800).	
		LOCAL titleLabel IS gui:ADDLABEL("Select operation scenario").
			SET titleLabel:STYLE:ALIGN TO "CENTER".
		LOCAL v_layout IS gui:ADDVLAYOUT().

	//Adds the done button and disables it
	LOCAL doneButton IS gui:ADDBUTTON("Execute operation").
	SET doneButton:ONCLICK TO { 
		SET finished TO TRUE.
	}.
	SET doneButton:ENABLED TO FALSE.
	
	//The box where the scenario files will be shown
	LOCAL vbox_scenarios IS v_layout:ADDVBOX().


//--------------------------------------------------------------------------\
//							  Display scenarios				   				|
//--------------------------------------------------------------------------/
	
		
	//Removes the .ks extension on each and displays a button in the list
	FOR scenario IN scenarioList {
		LOCAL scenarioName Is scenario:NAME:REPLACE(".ks", "").
		SET vbox_scenarios:ADDBUTTON(scenarioName):ONCLICK TO {
			SET chosenScenario TO scenarioName.
			SET doneButton:ENABLED TO TRUE.
		}.		
	}
	
	
//--------------------------------------------------------------------------\
//								  Show GUI					   				|
//--------------------------------------------------------------------------/	
			
		
		//Shows the GUI
		gui:SHOW().
		
		//Waits until the done button is clicked
		WAIT UNTIL(finished).
			gui:HIDE().
				
		//Returns the result
		SET GUI_RESULT_RES TO chosenScenario.
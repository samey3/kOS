	@lazyglobal OFF.
	CLEARSCREEN.
	

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _parameterLex IS LEXICON().
		IF(_parameterLex:HASKEY("entity") = FALSE AND HASTARGET = TRUE){ SET _parameterLex["entity"] TO TARGET. }

		
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
	LOCAL targDockTag IS (CHOOSE _parameterLex["targdocktag"] IF _parameterLex:HASKEY("targdocktag") ELSE "").
	LOCAL selfDockTag IS (CHOOSE _parameterLex["selfdocktag"] IF _parameterLex:HASKEY("selfdocktag") ELSE "").
	LOCAL standoffDistance IS (CHOOSE _parameterLex["standoffDistance"] IF _parameterLex:HASKEY("standoffDistance") ELSE 100).
		
		
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	RUNPATH("F9_land/dock_int_temp.ks", _parameterLex["entity"], targDockTag, selfDockTag, standoffDistance).
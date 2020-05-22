	CLEARSCREEN.
	

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _paramLex.
	
	
//---------------------------------------------------------------------------------\
//				  					Variables									   |
//---------------------------------------------------------------------------------/
	
	
	//Lexicon extraction
	LOCAL flyLocation IS _paramLex["flylocation"].
	LOCAL flyAltitude IS _paramLex["flyaltitude"].
	LOCAL flySpeed IS _paramLex["flyspeed"].
	LOCAL maxError IS _paramLex["maxerror"].
		
		
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	RUNPATH("operations/air operations/intermediate functions/flyToPoint.ks", flyLocation, flyAltitude, flySpeed, maxError).
	@lazyglobal OFF.
	CLEARSCREEN.
	

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _body.

	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	//If we are the parent body (injection)
	IF(_body:HASBODY AND _body:BODY = SHIP:BODY){
		RUNPATH("mission operations/intermediate functions/inject.ks", _body).
	}
	//If the target is the parent body (ejection)
	ELSE {
		RUNPATH("mission operations/intermediate functions/eject.ks", _body).
	}
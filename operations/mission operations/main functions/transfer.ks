	@lazyglobal OFF.
	CLEARSCREEN.
	

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _firstBody.
	PARAMETER _secondBody IS 0.

	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	//If we are the parent body (injection)
	IF(_firstBody:HASBODY AND _firstBody:BODY = SHIP:BODY){
		RUNPATH("operations/mission operations/intermediate functions/inject.ks", _firstBody).
	}
	//If the target is the parent body (ejection)
	ELSE {
		//If not a double-transfer
		IF(_secondBody = 0){
			RUNPATH("operations/mission operations/intermediate functions/eject.ks", _firstBody).
		}
		//Else if it is a double-transfer
		ELSE {
			RUNPATH("operations/mission operations/intermediate functions/doubleTransfer.ks", SHIP:BODY, _secondBody).
		}
	}
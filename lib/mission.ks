
	//Declare the global variables
	DECLARE GLOBAL STAGE_ID IS "".
	DECLARE GLOBAL TRANSFER_COUNT IS 0.
	
//--------------------------------------------------------------------------\
//							Set up stage tracker			   				|
//--------------------------------------------------------------------------/	
	

	IF(SHIP:PARTSTAGGED("systems manager"):LENGTH <> 0){
		LOCAL systemsCore IS ((SHIP:PARTSTAGGED("systems manager"))[0]):GETMODULEBYINDEX(0).
		ON((STAGE_ID + "_" + TRANSFER_COUNT)){
			LOCAL stageMessage IS (TRANSFER_COUNT + "_" + STAGE_ID).
			systemsCore:CONNECTION:SENDMESSAGE(stageMessage).
			PRINT("CHANGED : " + stageMessage).
			WAIT 2.
			RETURN TRUE.
		}
	}
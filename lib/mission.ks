//--------------------------------------------------------------------------\
//							  Global variables				   				|
//--------------------------------------------------------------------------/


	//Global variables
	DECLARE GLOBAL STAGE_ID IS "".
	DECLARE GLOBAL TRANSFER_COUNT IS 0.
	
	//Holds all events
	LOCAL eventList IS LIST().
	
	
//--------------------------------------------------------------------------\
//							Set up stage tracker			   				|
//--------------------------------------------------------------------------/	


	//IF(SHIP:PARTSTAGGED("systems manager"):LENGTH <> 0){
	//	LOCAL systemsCore IS ((SHIP:PARTSTAGGED("systems manager"))[0]):GETMODULEBYINDEX(0).
	//	ON((STAGE_ID + "_" + TRANSFER_COUNT)){
	//		LOCAL stageMessage IS (TRANSFER_COUNT + "_" + STAGE_ID).
	//		systemsCore:CONNECTION:SENDMESSAGE(stageMessage).
	//		PRINT("CHANGED : " + stageMessage).
	//		WAIT 2.
	//		RETURN TRUE.
	//	}
	//}
	
	ON((STAGE_ID + "_" + TRANSFER_COUNT)){
	
		//Finds the new stage message
		LOCAL newStageID IS (TRANSFER_COUNT + "_" + STAGE_ID).
		
		//For each event in the list	
		FROM {LOCAL i IS eventList:LENGTH-1.} UNTIL (i < 0) STEP {SET i TO i-1.} DO {			
			//If it matches the current stage
			IF((eventList[i])["stage_id"] = newStageID){
			
				//Finds the list of relevant parts
				LOCAL partList IS SHIP:PARTSTAGGED((eventList[i])["tag_id"]).
				FOR eventPart IN partList {
				
					//May have single or list of events/actions
					IF((eventList[i])["action"]:ISTYPE("list")){
						FOR action IN (eventList[i])["action"] { handleEvent(eventPart, action). }
					}
					ELSE{
						handleEvent(eventPart, (eventList[i])["action"]).
					}					
				}
				
				//Removes the event afterwards
				eventList:REMOVE(i).
			}		
		}
				
		RETURN TRUE.
	}

	
//--------------------------------------------------------------------------\
//								Functions					   				|
//--------------------------------------------------------------------------/	


	//Adds a new event to the given event list
	FUNCTION addEvent{
		PARAMETER _stageIdentifier.
		PARAMETER _tagIdentifier.
		PARAMETER _action.
		
		eventList:ADD(
			LEXICON(
				"stage_id", _stageIdentifier,
				"tag_id", _tagIdentifier,
				"action", _action
			)
		).
	}
	
	
	//Finds the appropriate module and activates the action/event
	FUNCTION handleEvent{
		PARAMETER _part.
		PARAMETER _action.
		
		FOR moduleName IN _part:ALLMODULES {
			//Gets the module
			LOCAL pModule IS _part:GETMODULE(moduleName).

			//Stuff that appears in-flight when right-clicking
			IF(pModule:HASACTION(_action)){ pModule:DOACTION(_action, TRUE). BREAK. }
			//Stuff that appears in the action-group editor (e.g. toggles)
			IF(pModule:HASEVENT(_action)){ pModule:DOEVENT(_action). BREAK. }
		}
	}
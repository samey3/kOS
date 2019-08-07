//--------------------------------------------------------------------------\
//							  	  Variables				   					|
//--------------------------------------------------------------------------/


	//Holds all event listeners
	LOCAL listenerList IS LIST().

	
//--------------------------------------------------------------------------\
//								  Functions					   				|
//--------------------------------------------------------------------------/	


	//Adds a listener to the list
	FUNCTION addListener{
		PARAMETER _eventName.
		PARAMETER _delegate.
		PARAMETER _preserve IS FALSE.
		
		listenerList:ADD(
			LEXICON(
				"event_name", _eventName,
				"delegate", _delegate,
				"preserve", _preserve
			)
		).
	}
	
	//Throws an event with a given name
	FUNCTION throwEvent {
		PARAMETER _eventName.
		SET STAGE_ID TO _eventName.
		
		//Find the event name with the transfer count included
		SET _eventName TO (_eventName).
		
		//Handles the event
		handleEvent(_eventName).		
	}
	
	//Handles the code blocks
	FUNCTION handleEvent{
		PARAMETER _eventName.
		
		//For each listener in the list	
		FROM {LOCAL i IS listenerList:LENGTH-1.} UNTIL (i < 0) STEP {SET i TO i-1.} DO {			
			//If it matches the event name
			IF((listenerList[i])["event_name"] = _eventName){
				//Execute the code block, and remove it if it is not preserved
				(listenerList[i])["delegate"]:CALL().
				IF((listenerList[i])["preserve"] = FALSE){ listenerList:REMOVE(i). }	
			}
		}
	}
	
	//Handles right-click actions, events, and sliders
	FUNCTION handlePartAction{
		PARAMETER _tag.
		PARAMETER _action.
		PARAMETER _value IS 0.
		
		//Goes through every module of tagged parts
		LOCAL partList IS SHIP:PARTSTAGGED(_tag).
		FOR eventPart IN partList {
			FOR moduleName IN eventPart:ALLMODULES {
				//Gets the module
				LOCAL pModule IS eventPart:GETMODULE(moduleName).
				
				//Stuff that has a slider
				IF(pModule:HASFIELD(_action)){ pModule:SETFIELD(_action, _value). BREAK. }
				//Stuff that appears in-flight when right-clicking
				IF(pModule:HASACTION(_action)){ pModule:DOACTION(_action, TRUE). BREAK. }
				//Stuff that appears in the action-group editor (e.g. toggles)
				IF(pModule:HASEVENT(_action)){ pModule:DOEVENT(_action). BREAK. }
			}
		}
	}
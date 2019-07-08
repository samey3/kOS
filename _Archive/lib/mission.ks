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


	ON((TRANSFER_COUNT + "_" + STAGE_ID)){
	
		//Finds the new stage message
		LOCAL newStageID IS (TRANSFER_COUNT + "_" + STAGE_ID).
		
		//For each event in the list	
		FROM {LOCAL i IS eventList:LENGTH-1.} UNTIL (i < 0) STEP {SET i TO i-1.} DO {	
		
			//If it matches the current stage
			IF((eventList[i])["stage_id"] = newStageID){

				//Finds the list of relevant parts
				//LOCAL partList IS SHIP:PARTSTAGGED((eventList[i])["tag_id"]).
				//FOR eventPart IN partList {
		
					//May have single or list of events/actions
				//	IF((eventList[i])["action"]:ISTYPE("list")){
				//		FOR action IN (eventList[i])["action"] { handleEvent(eventPart, action, (eventList[i])["value"]). }
				//	}
				//	ELSE{
				//		handleEvent(eventPart, (eventList[i])["action"], (eventList[i])["value"]).
				//	}					
				//}
				
				

				LOCAL partList IS SHIP:PARTSTAGGED((eventList[i])["tag_id"]).
				
				//If not a list, execute the single action
				IF(NOT (eventList[i])["action"]:ISTYPE("list")){
					IF(_action:ISTYPE("UserDelegate")){ handleEvent(0, (eventList[i])["action"], (eventList[i])["value"]). }
					ELSE{ FOR eventPart IN partList { handleEvent(eventPart, (eventList[i])["action"], (eventList[i])["value"]). } }
				}
				//If a list, execute them in order
				ELSE{
					FOR action IN (eventList[i])["action"] {
						IF(action:ISTYPE("UserDelegate")){ handleEvent(0, action, (eventList[i])["value"]). }
						ELSE{ FOR eventPart IN partList { handleEvent(eventPart, action, (eventList[i])["value"]). } }
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
		PARAMETER _value IS 0.
		
		eventList:ADD(
			LEXICON(
				"stage_id", _stageIdentifier,
				"tag_id", _tagIdentifier,
				"action", _action,
				"value", _value
			)
		).
	}
	
	
	//Throws an event with a given name
	FUNCTION throwEvent {
		PARAMETER _eventName.
		SET STAGE_ID TO _eventName.
	}
	
	
	//Finds the appropriate module and activates the action/event
	FUNCTION handleEvent{
		PARAMETER _part.
		PARAMETER _action.
		PARAMETER _value.
		
		//If not a part-specific action
		IF(_action:ISTYPE("UserDelegate")){ 
			IF(NOT _action:ISDEAD){ _action:CALL(). }
		}
		ELSE{		
			FOR moduleName IN _part:ALLMODULES {
				//Gets the module
				LOCAL pModule IS _part:GETMODULE(moduleName).
				
				//Stuff that has a slider
				IF(pModule:HASFIELD(_action)){ pModule:SETFIELD(_action, _value). BREAK. }
				//Stuff that appears in-flight when right-clicking
				IF(pModule:HASACTION(_action)){ pModule:DOACTION(_action, TRUE). BREAK. }
				//Stuff that appears in the action-group editor (e.g. toggles)
				IF(pModule:HASEVENT(_action)){ pModule:DOEVENT(_action). BREAK. }
			}
		}
	}
	
	
	
//--------------------------------------------------------------------------\
//							  Delegate actions				   				|
//--------------------------------------------------------------------------/	
	
	//A brief description of this section:
	//These delegate functions may be referenced to and have parameters bound to them.
	//They can then be added as an action using addEvent, and when the event occurs,
	//They will be executed with the parameters previously bound to them.
	//e.g. (sendMsg@):BIND("ship name", message)
	
	//----------------------------------------------------\
	//Set state-------------------------------------------|
		
		//Scalars
		FUNCTION setThrottle 		{ PARAMETER _value. LOCK THROTTLE 						TO _value. }
		FUNCTION setPilotThrottle 	{ PARAMETER _value. SET SHIP:CONTROL:PILOTMAINTHROTTLE 	TO _value. }
		FUNCTION setPhysicalWarp 	{ PARAMETER _value. SET WARPMODE TO "PHYSICS". SET WARP TO _value. }
		FUNCTION setRailsWarp 		{ PARAMETER _value. SET WARPMODE TO "RAILS".   SET WARP TO _value. }		
		FUNCTION setPhysicalWarpRate{ PARAMETER _value. SET WARPMODE TO "PHYSICS". SET RATE TO _value. }
		FUNCTION setRailsWarpRate 	{ PARAMETER _value. SET WARPMODE TO "RAILS".   SET RATE TO _value. }		
		FUNCTION setControlFore		{ PARAMETER _value. SET SHIP:CONTROL:FORE 				TO _value. }
		FUNCTION setControlStarboard{ PARAMETER _value. SET SHIP:CONTROL:STARBOARD 			TO _value. }
		FUNCTION setControlTop		{ PARAMETER _value. SET SHIP:CONTROL:TOP 				TO _value. }
		FUNCTION setControlYaw		{ PARAMETER _value. SET SHIP:CONTROL:YAW 				TO _value. }	
		FUNCTION setControlPitch	{ PARAMETER _value. SET SHIP:CONTROL:PITCH 				TO _value. }		
		FUNCTION setControlRoll		{ PARAMETER _value. SET SHIP:CONTROL:ROLL 				TO _value. }		
		FUNCTION setWheelSteer		{ PARAMETER _value. SET SHIP:CONTROL:WHEELSTEER 		TO _value. }		
		FUNCTION setThrottle		{ PARAMETER _value. SET SHIP:CONTROL:WHEELTHROTTLE 		TO _value. }		
		FUNCTION setControlYawTrim	{ PARAMETER _value. SET SHIP:CONTROL:YAWTRIM 			TO _value. }
		FUNCTION setControlPitchTrim{ PARAMETER _value. SET SHIP:CONTROL:PITCHTRIM 			TO _value. }
		FUNCTION setControlRollTrim	{ PARAMETER _value. SET SHIP:CONTROL:ROLLTRIM 			TO _value. }
		FUNCTION setWheelSteerTrim	{ PARAMETER _value. SET SHIP:CONTROL:WHEELSTEERTRIM 	TO _value. }
		FUNCTION setThrottleTrim	{ PARAMETER _value. SET SHIP:CONTROL:WHEELTHROTTLETRIM 	TO _value. }
		FUNCTION setPitchTS					{ PARAMETER _value. SET STEERINGMANAGER:PITCHTS 				TO _value. }
		FUNCTION setYawTS					{ PARAMETER _value. SET STEERINGMANAGER:YAWTS 					TO _value. }
		FUNCTION setRollTS					{ PARAMETER _value. SET STEERINGMANAGER:ROLLTS 					TO _value. }
		FUNCTION setMaxStoppingTime			{ PARAMETER _value. SET STEERINGMANAGER:MAXSTOPPINGTIME 		TO _value. }		
		FUNCTION setRollControlAngleRange	{ PARAMETER _value. SET STEERINGMANAGER:ROLLCONTROLANGLERANGE 	TO _value. }
		FUNCTION setPitchTorqueAdjust		{ PARAMETER _value. SET STEERINGMANAGER:PITCHTORQUEADJUST 		TO _value. }
		FUNCTION setPitchTorqueFactor		{ PARAMETER _value. SET STEERINGMANAGER:PITCHTORQUEFACTOR 		TO _value. }
		FUNCTION setYawTorqueAdjust			{ PARAMETER _value. SET STEERINGMANAGER:YAWTORQUEADJUST 		TO _value. }
		FUNCTION setYawTorqueFactor			{ PARAMETER _value. SET STEERINGMANAGER:YAWTORQUEFACTOR 		TO _value. }
		FUNCTION setRollTorqueAdjust		{ PARAMETER _value. SET STEERINGMANAGER:ROLLTORQUEADJUST 		TO _value. }
		FUNCTION setRollTorqueFactor		{ PARAMETER _value. SET STEERINGMANAGER:ROLLTORQUEFACTOR 		TO _value. }		
		FUNCTION setTerminalWidth 		{ PARAMETER _value. SET TERMINAL:WIDTH 			TO _value. }	
		FUNCTION setTerminalHeight 		{ PARAMETER _value. SET TERMINAL:HEIGHT			TO _value. }	
		FUNCTION setTerminalBrightness 	{ PARAMETER _value. SET TERMINAL:BRIGHTNESS		TO _value. }	
		FUNCTION setTerminalCharWidth 	{ PARAMETER _value. SET TERMINAL:CHARWIDTH		TO _value. }	
		FUNCTION setTerminalCharHeight 	{ PARAMETER _value. SET TERMINAL:CHARHEIGHT		TO _value. }	
		
		//Directions
		FUNCTION setSteering 		{ PARAMETER _value. LOCK STEERING 		TO _value. }
		
		//Booleans
		FUNCTION setGear			{ PARAMETER _value. SET GEAR 			TO _value. }
		FUNCTION setRCS				{ PARAMETER _value. SET RCS 			TO _value. }
		FUNCTION setSAS				{ PARAMETER _value. SET SAS 			TO _value. }
		FUNCTION setLights			{ PARAMETER _value. SET LIGHTS 			TO _value. }
		FUNCTION setBrakes			{ PARAMETER _value. SET BRAKES 			TO _value. }
		FUNCTION setAbort			{ PARAMETER _value. SET ABORT 			TO _value. }	
		FUNCTION setLegs			{ PARAMETER _value. SET LEGS 			TO _value. }
		FUNCTION setChutes			{ PARAMETER _value. SET CHUTES 			TO _value. }
		FUNCTION setChuteSafe		{ PARAMETER _value. SET CHUTESSAFE 		TO _value. }
		FUNCTION setPanels			{ PARAMETER _value. SET PANELS 			TO _value. }
		FUNCTION setRadiators		{ PARAMETER _value. SET RADIATORS 		TO _value. }
		FUNCTION setLadders			{ PARAMETER _value. SET LADDERS 		TO _value. }
		FUNCTION setBays			{ PARAMETER _value. SET BAYS 			TO _value. }
		FUNCTION setDeployDrills	{ PARAMETER _value. SET DEPLOYDRILLS 	TO _value. }
		FUNCTION setDrills			{ PARAMETER _value. SET DRILLS 			TO _value. }
		FUNCTION setFuelCells		{ PARAMETER _value. SET FUELCELLS 		TO _value. }
		FUNCTION setISRU			{ PARAMETER _value. SET ISRU 			TO _value. }
		FUNCTION setIntakes			{ PARAMETER _value. SET INTAKES 		TO _value. }
		FUNCTION setUserControl 	{ PARAMETER _value. SET SHIP:CONTROL:NEUTRALIZE 			TO _value. }
		FUNCTION setFacingVectors	{ PARAMETER _value. SET STEERINGMANAGER:SHOWFACINGVECTORS 	TO _value. }
		FUNCTION setAngularVectors	{ PARAMETER _value. SET STEERINGMANAGER:SHOWANGULARVECTORS 	TO _value. }
		FUNCTION setSteeringStats	{ PARAMETER _value. SET STEERINGMANAGER:SHOWSTEERINGSTATS 	TO _value. }
		FUNCTION setwriteCSVFiles	{ PARAMETER _value. SET STEERINGMANAGER:WRITECSVFILES 		TO _value. }
		FUNCTION setTerminalReverse		{ PARAMETER _value. SET TERMINAL:REVERSE				TO _value. }	
		FUNCTION setTerminalVisualBeep	{ PARAMETER _value. SET TERMINAL:VISUALBEEP				TO _value. }	
		
		//Strings
		FUNCTION setSASMode			{ PARAMETER _value. SET SASMODE 		TO _value. }
		FUNCTION setNAVMode			{ PARAMETER _value. SET NAVMODE 		TO _value. }
		FUNCTION setTransferCount 	{ PARAMETER _value. SET TRANSFER_COUNT 	TO _value. }
		FUNCTION setStageID 		{ PARAMETER _value. SET STAGE_ID 		TO _value. }
		
		//Entity
		FUNCTION setActiveVessel 	{ PARAMETER _value. KUNIVERSE:FORCEACTIVE(_value). 			   	   }
		FUNCTION setTarg			{ PARAMETER _value. SET TARGET 							TO _value. }

	
	//----------------------------------------------------\
	//Toggle state----------------------------------------|
	
		//Booleans
		FUNCTION toggleGear			{ PARAMETER _value. SET GEAR 			TO (NOT GEAR). 			}
		FUNCTION toggleRCS			{ PARAMETER _value. SET RCS 			TO (NOT RCS). 			}
		FUNCTION toggleSAS			{ PARAMETER _value. SET SAS 			TO (NOT SAS). 			}
		FUNCTION toggleLights		{ PARAMETER _value. SET LIGHTS 			TO (NOT LIGHTS). 		}
		FUNCTION toggleBrakes		{ PARAMETER _value. SET BRAKES 			TO (NOT BRAKES). 		}
		FUNCTION toggleAbort		{ PARAMETER _value. SET ABORT 			TO (NOT ABORT). 		}		
		FUNCTION toggleLegs			{ PARAMETER _value. SET LEGS 			TO (NOT LEGS). 			}
		FUNCTION toggleChutes		{ PARAMETER _value. SET CHUTES 			TO (NOT CHUTES). 		}
		FUNCTION toggleChuteSafe	{ PARAMETER _value. SET CHUTESSAFE 		TO (NOT CHUTESSAFE). 	}
		FUNCTION togglePanels		{ PARAMETER _value. SET PANELS 			TO (NOT PANELS). 		}
		FUNCTION toggleRadiators	{ PARAMETER _value. SET RADIATORS 		TO (NOT RADIATORS). 	}
		FUNCTION toggleLadders		{ PARAMETER _value. SET LADDERS 		TO (NOT LADDERS). 		}
		FUNCTION toggleBays			{ PARAMETER _value. SET BAYS 			TO (NOT BAYS). 			}
		FUNCTION toggleDeployDrills	{ PARAMETER _value. SET DEPLOYDRILLS 	TO (NOT DEPLOYDRILLS). 	}
		FUNCTION toggleDrills		{ PARAMETER _value. SET DRILLS 			TO (NOT DRILLS). 		}
		FUNCTION toggleFuelCells	{ PARAMETER _value. SET FUELCELLS 		TO (NOT FUELCELLS). 	}
		FUNCTION toggleISRU			{ PARAMETER _value. SET ISRU 			TO (NOT ISRU). 			}
		FUNCTION toggleIntakes		{ PARAMETER _value. SET INTAKES 		TO (NOT INTAKES). 		}
		FUNCTION toggleUserControl 	{ PARAMETER _value. SET SHIP:CONTROL:NEUTRALIZE TO (NOT SHIP:CONTROL:NEUTRALIZE). }
	
	
	//----------------------------------------------------\
	//Miscellaneous---------------------------------------|
	
		FUNCTION stageVessel 		{ STAGE. 													}
		FUNCTION terminalPrint 		{ PARAMETER _value. 	PRINT(_value).						}
		FUNCTION waitCPU 			{ PARAMETER _value. 	WAIT _value. 						}
		FUNCTION revert 			{ PARAMETER _value. 	KUNIVERSE:REVERTTO(_value). 		}
		FUNCTION pauseGame 			{ PARAMETER _value. 	KUNIVERSE:PAUSE(). 					}
		FUNCTION quicksaveToGame 	{ PARAMETER _value. 	KUNIVERSE:QUICKSAVETO(_value). 		}	
		FUNCTION quickloadFromGame	{ PARAMETER _value. 	KUNIVERSE:QUICKLOADFROM(_value).	}
		FUNCTION writeDebugLog 		{ PARAMETER _value. 	KUNIVERSE:DEBUGLOG(_value). 		}
		FUNCTION endWarp 			{ KUNIVERSE:TIMEWARP:CANCELWARP(). 							}
		FUNCTION revertLaunch 		{ KUNIVERSE:REVERTTOLAUNCH(). 								}
		FUNCTION revertEditor 		{ KUNIVERSE:REVERTTOEDITOR(). 								}		
		FUNCTION quicksaveGame 		{ KUNIVERSE:QUICKSAVE(). 									}
		FUNCTION quickloadGame 		{ KUNIVERSE:QUICKLOAD(). 									}
				
		FUNCTION launchVessel { //This will end the running script 
			PARAMETER _name.
			PARAMETER _site IS "LAUNCHPAD". //"RUNWAY"
			PARAMETER _editor IS "VAB". //"SPH"			
			LOCAL template IS KUNIVERSE:GETCRAFT(_name, _editor).
			KUNIVERSE:LAUNCHCRAFTFROM(template, _site).
		}
		
		FUNCTION sendMsg {
			PARAMETER _vessel.
			PARAMETER _message.		
			LOCAL conn IS VESSEL(_vessel):CONNECTION.
			IF(conn:ISCONNECTED){ conn:SENDMESSAGE(_message). }
		}
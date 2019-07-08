//STAGE.
WAIT 3.

//Finds the list of relevant parts
LOCAL partList IS SHIP:PARTSTAGGED("hinge"). //ModuleRoboticServoHinge, ModuleRoboticServoPiston
FOR eventPart IN partList {
	IF(eventPart:HASMODULE("ModuleRoboticServoHinge")){
	LOCAL pModule IS eventPart:GETMODULE("ModuleRoboticServoHinge").
		pModule:SETFIELD("target angle", 0).
	}	
}

PRINT("Waiting to uncurl...").
WAIT 15.
PRINT("Extending pistons...").

SET partList TO SHIP:PARTSTAGGED("piston"). //ModuleRoboticServoHinge, ModuleRoboticServoPiston
FOR eventPart IN partList {
	IF(eventPart:HASMODULE("ModuleRoboticServoPiston")){
	LOCAL pModule IS eventPart:GETMODULE("ModuleRoboticServoPiston").
		pModule:SETFIELD("target extension", 6.00).
	}	
}
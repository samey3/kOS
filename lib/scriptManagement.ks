//This script is used to prepare the environment for script execution.
//It manages the initial conditions before the main programs run so that it may avoid potential problems.
//-------------------------------------------------------------------------------------------------------

//Turns off lazy globals
@lazyglobal OFF.

//Clears the terminal
CLEARSCREEN.

//Set pilot values
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

//Unset steering
LOCK STEERING TO SHIP:FACING.
LOCK THROTTLE TO 0.
UNLOCK STEERING.
UNLOCK THROTTLE.

//Unset SAS/RCS
SAS OFF.
RCS OFF.

//Remove any maneuver nodes in the flight plan
FOR nodeEntry in ALLNODES { REMOVE nodeEntry. }  
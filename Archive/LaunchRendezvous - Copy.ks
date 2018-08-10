CLEARSCREEN.

SET nearbyVessels TO LIST().
LIST TARGETS IN vesselList.
	FOR VESSEL IN vesselList
	{										
		IF SHIP:BODY:NAME = VESSEL:BODY:NAME {
			nearbyVessels:ADD(VESSEL).
		}
	}
	
LOCAL chosen IS False.
LOCAL listIndex IS 0.

ag1 OFF.
ag2 OFF.
ag3 OFF.

UNTIL chosen = True {
	PRINT "Use action group 1 to move up the list.".
	PRINT "Use action group 2 to move down the list.".
	PRINT "Use action group 3 to confirm target vessel".
	PRINT " ".
	PRINT nearbyVessels.
	PRINT " ".
	PRINT "Target vessel: [" + listIndex + "] " + nearbyVessels[listIndex].
	
	WAIT UNTIL ag1 = "True" or ag2 = "True" or ag3 = "True".	
		IF ag1 = "True" AND listIndex > 0{ 
			SET listIndex TO listIndex - 1. 
		}
		IF ag2 = "True" AND listIndex < (nearbyVessels:LENGTH - 1){ 
			SET listIndex TO listIndex + 1.
		}
		IF ag3 = "True" { 
			SET chosen TO True. 
		}
		CLEARSCREEN.
		
		ag1 OFF.
		ag2 OFF.
		ag3 OFF.
}	
CLEARSCREEN.

LOCAL targetCraft IS nearbyVessels[listIndex].
SET TARGET TO targetCraft.


//--------------------------------------------------------\\
//														  ||
//----------------------Sensor check----------------------//


	CLEARSCREEN.
	PRINT "Full Sensor Dump:".
	
	LIST SENSORS IN SENSELIST.
	FOR S IN SENSELIST { //Turns all sensors on
		PRINT "Turning on Sensor: " + S:TYPE.
		S:TOGGLE().
		WAIT 0.6.
	} //Add a part that checks if any required sensors are missing

	PRINT "Sensors check complete.".
	WAIT 2.
	CLEARSCREEN.
	
	
//--------------------------------------------------------\\
//					 Waiting for lineup				 	  ||
//--------------------------------------------------------//
	
//--------------------------------------------------------\\
//						Launch sequence					  ||
//--------------------------------------------------------//
	
	
	PRINT "Launch sequence:".
	LOCK THROTTLE TO 1.
	FROM {local countdown is 3.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
		PRINT countdown.
		WAIT 1. // pauses the script here for 1 second.
	}

	LOCK STEERING TO smoothRotate(up).
	STAGE.
	PRINT "Liftoff".
	
	
//--------------------------------------------------------\\
//						 Gravity turn					  ||
//--------------------------------------------------------//
	
	
	LOCK shipThrust_Vector TO -SHIP:FACING:VECTOR:NORMALIZED*SHIP:THRUST.
	LOCK gravity_Vector TO (SHIP:BODY:MU / (SHIP:BODY:POSITION - SHIP:POSITION):MAG^2)*(SHIP:BODY:POSITION - SHIP:POSITION):NORMALIZED.
	LOCK drag_vector TO SHIP:SENSORS:ACC - gravity_Vector - shipThrust_Vector.

	
//--------------------------------------------------------\\
//					 Atmospheric coasting				  ||
//--------------------------------------------------------//






//Vector heading smoother
FUNCTION smoothRotate {
    PARAMETER dir.
    LOCAL spd IS max(SHIP:ANGULARMOMENTUM:MAG/10,4).
    LOCAL curF IS SHIP:FACING:FOREVECTOR.
    LOCAL curR IS SHIP:FACING:TOPVECTOR.
    LOCAL rotR IS R(0,0,0).
    IF VANG(dir:FOREVECTOR,curF) < 90{SET rotR TO ANGLEAXIS(min(0.5,VANG(dir:TOPVECTOR,curR)/spd),VCRS(curR,dir:TOPVECTOR)).}
    RETURN LOOKDIRUP(ANGLEAXIS(min(2,VANG(dir:FOREVECTOR,curF)/spd),VCRS(curF,dir:FOREVECTOR))*curF,rotR*curR).
}

LOCAL desiredAltitude IS 80000.
LOCAL launchDirection IS 90.

//(90,0)
//0 is north, 90 east, 180 south, 275 west.

//--------------------------------------------------------\\
//														  ||
//----------------------Choose altitude-------------------//

LOCAL chosen IS False.
CLEARSCREEN.

UNTIL chosen = True {
	PRINT "Use action group 1 to add 1Km to desired altitude.".
	PRINT "Use action group 2 to remove 1Km from desired altitude.".
	PRINT "Use action group 3 to confirm target altitude".
	PRINT "Desired altitude: " + (desiredAltitude/1000) + "Km".
	
	WAIT UNTIL ag1 = "True" or ag2 = "True" or ag3 = "True".	
		IF ag1 = "True" { 
			SET desiredAltitude TO desiredAltitude + 1000. 
			TOGGLE ag1. 
		}
		IF ag2 = "True" { 
			SET desiredAltitude TO desiredAltitude - 1000. 
			TOGGLE ag2. 
		}
		IF ag3 = "True" { 
			SET chosen TO True. 
			TOGGLE ag3. 
		}
		CLEARSCREEN.
}

ag1 OFF.
ag2 OFF.
ag3 OFF.

SET chosen TO False.
UNTIL chosen = True {
	PRINT " 0 = North   90 = East   180 = South   270 = West".
	PRINT " ".
	PRINT "Use action group 1 to add 1° to direction.".
	PRINT "Use action group 2 to add 10° to direction.".
	PRINT " ".
	PRINT "Use action group 3 to remove 1° from direction.".
	PRINT "Use action group 4 to remove 10° from direction.".
	PRINT " ".
	PRINT "Use action group 5 to confirm direction".
	PRINT "Direction: " + launchDirection + "°".
	
	WAIT UNTIL ag1 = "True" or ag2 = "True" or ag3 = "True" or ag4 = "True" or ag5 = "True".	
		IF ag1 = "True" { 
			SET launchDirection TO launchDirection + 1.
			TOGGLE ag1. 
		}
		IF ag2 = "True" { 
			SET launchDirection TO launchDirection + 10.
			TOGGLE ag2. 
		}
		IF ag3 = "True" { 
			SET launchDirection TO launchDirection - 1.
			TOGGLE ag3. 
		}
		IF ag4 = "True" {
			SET launchDirection TO launchDirection - 10.		
			TOGGLE ag4. 
		}
		IF ag5 = "True" { 
			SET chosen TO True. 
			TOGGLE ag5. 
		}
		CLEARSCREEN.
}


//--------------------------------------------------------\\
//														  ||
//----------------------Sensor check----------------------//
	//LOCAL sensorsIsReady = True.

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
//														  ||
//----------------------Launch sequence-------------------//
PRINT "Launch sequence:".
	LOCK THROTTLE TO 1.
	FROM {local countdown is 3.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
		PRINT countdown.
		WAIT 1. // pauses the script here for 1 second.
	}

	LOCK STEERING TO smoothRotate(up).
	STAGE.
	PRINT "Liftoff".

	//Collecting total engine thrust----//
		LOCAL availThrust IS 0.
		LOCK availThrust TO SHIP:AVAILABLETHRUST.
	//----------------------------------//
	
//--------------------------------------------------------\\
//														  ||
//-----------------------Gravity turn---------------------//
	WAIT UNTIL verticalspeed > 40.
		CLEARSCREEN.
		PRINT "Commencing gravity turn.".	
			
		
	UNTIL apoapsis >= desiredAltitude OR (apoapsis/desiredAltitude) > 1 OR verticalspeed <= 0	{ //Remove the verticalSpeed argument, its just temp here
		IF (apoapsis/desiredAltitude - 0.95) <= 0 {
			LOCK THROTTLE TO (SHIP:SENSORS:GRAV:MAG / (availThrust / SHIP:MASS) * 3).
		}
		ELSE IF ((apoapsis/desiredAltitude) >= 0.99999 )
		{
			LOCK THROTTLE TO 0. //Cuts off when apoapsis is above desired
		}
		ELSE
		{													
			LOCK THROTTLE TO (SHIP:SENSORS:GRAV:MAG / (availThrust / SHIP:MASS) * (SQRT(40 * (1 - apoapsis/desiredAltitude)) / 1.4142 * 3)) + 0.01. //+1% throttle
		}
		LOCK STEERING TO HEADING(launchDirection,90 - 77*(apoapsis/desiredAltitude)). //    The rocket can turn 77/90 of the full way
	}
	
//--------------------------------------------------------//
//-------------------Atmospheric coasting-----------------//

	//IF SHIP:SENSORS:PRES > 0 {
	//	PRINT "Coasting out of atmosphere.".
	//
	//	//Finds the drag vector in m/s^2
	//		LOCAL dragOpp IS 0.
	//		LOCK dragOpp TO (SHIP:SENSORS:ACC - SHIP:SENSORS:GRAV).
	//	//----------------------------------\\
	//	//Finds ship acceleration in m/s^2--//	
	//		LOCAL shipAcc IS 0.
	//		LOCK shipAcc TO (dragOpp:MAG / ((availThrust - SHIP:MASS*SHIP:SENSORS:GRAV:MAG)/SHIP:MASS)).//-0.04. //Seems to have a slightly raised value, the -0.04 should reduce that.
	//	//----------------------------------\\
	//	//Setting steering and throttle-----//
	//		LOCK STEERING TO smoothRotate(prograde).
	//	//----------------------------------//
	//
	//	UNTIL SHIP:SENSORS:PRES = 0 {
	//		PRINT "Atmospheric acceleration: " + dragOpp:MAG.
	//		PRINT "Ship acceleration: " + shipAcc.
	//		PRINT "Pressure: " + SHIP:SENSORS:PRES.
	//		IF apoapsis > (desiredAltitude + 1) {
	//			LOCK THROTTLE TO 0.
	//		} ELSE {
	//			LOCK THROTTLE TO shipAcc/availThrust/SHIP:MASS+0.05. //Multiplying by 1.03 slightly raises the thrust so that lost altitude can be regained.
	//		}
	//		WAIT 0.1.
	//		CLEARSCREEN.
	//	}
	//}  
//--------------------------------------------------------//
PRINT "Throttling down.".
LOCK THROTTLE TO 0.

LOCAL shipPitch IS 0.
LOCK shipPitch TO ARCSIN(SHIP:SENSORS:GRAV:MAG / (availThrust/SHIP:MASS)).
						//90 is east, right arg is pitch above horizon
						
LOCK STEERING TO HEADING (launchDirection,shipPitch).


UNTIL verticalspeed <= 0 {
	print "Pitch: " + shipPitch.
	print "gravity acc: " + SHIP:SENSORS:GRAV:MAG.
	print "Ship down acc: " + (availThrust/SHIP:MASS*SIN(shipPitch)).
	wait 0.1.
	clearscreen.
} 

PRINT "Apokee reached. Throttling up.".
LOCK THROTTLE TO 1.
//LOCK THROTTLE TO ((SHIP:SENSORS:GRAV:MAG / SIN(shipPitch))*SHIP:MASS)/availThrust.

WAIT 0.8.

SET lastEccentricity TO 1.
UNTIL obt:eccentricity > lastEccentricity {
    SET lastEccentricity TO obt:eccentricity.

	IF verticalspeed > 0{
		LOCK STEERING TO HEADING (launchDirection,0).
	}
	ELSE
	{
		LOCK STEERING TO HEADING (launchDirection,shipPitch).
	}
	
	IF obt:eccentricity < 0.2 {
		LOCK THROTTLE TO (SQRT(500 * OBT:ECCENTRICITY) / 10).
		PRINT "Lowering throttle...".
	}
	
	PRINT "Excess vertical acc: " + ((SIN(shipPitch)*(availThrust/SHIP:MASS)) - SHIP:SENSORS:GRAV:MAG).
	PRINT "Vertical speed: " + verticalspeed.
	PRINT "Ship pitch: " + shipPitch.
	PRINT "Eccentricity: " + obt:eccentricity.
	
	WAIT 0.1.
	CLEARSCREEN.
}

LOCK THROTTLE TO 0.
PRINT "Orbit acheived. Throttling down. Waiting for approach of apokee.".

WAIT UNTIL (apoapsis - altitude) < 40.
	IF WARP > 0 {
		SET WARP TO 0.
	}	
	PRINT "Apokee reached. Orientating vessel to prograde.".
	LOCK STEERING TO smoothRotate(prograde).
	
WAIT UNTIL (apoapsis - altitude) < 2.
	PRINT "Throttling up.".
	LOCK THROTTLE TO 0.005.

SET lastEccentricity TO 1.
WAIT 0.1.
UNTIL obt:eccentricity > lastEccentricity {
    SET lastEccentricity TO obt:eccentricity.
}
	PRINT "Orbit circularized.".
	LOCK THROTTLE TO 0.
	
	
	
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

CLEARSCREEN.

//Find a way to get correct altitude at time


SET nearbyVessels TO LIST().
LIST TARGETS IN vesselList.
	FOR VESSEL IN vesselList
	{										//vv Added MAX to Thrust here, which may change effects.
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
//LOCAL targetCraft IS MUN.
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
//														  ||
//-------------------Waiting for lineup-------------------//
	SET timeOrbit TO 180 + 11 * (targetCraft:body:altitudeOf(positionAt(targetCraft,TIME:SECONDS + 180)) / 10000 - 7).
	SET targetVec TO targetCraft:POSITION - targetCraft:BODY:POSITION.
	SET upVec TO UP:VECTOR.
		
	SET avgOrbAlt TO (targetCraft:APOAPSIS + targetCraft:PERIAPSIS) / 2.
	SET avgOrbSpeed TO SQRT((constant():G * targetCraft:BODY:MASS) / (targetCraft:BODY:RADIUS + avgOrbAlt)). 												//Gives +1.8 degrees for errors, Write an equation here to accont for changing mass of rocket and time it perfectly
	SET launchAngle TO ((timeOrbit * avgOrbSpeed) / (2 * constant():PI * (targetCraft:BODY:RADIUS + avgOrbAlt)) * 360) - (10.5 + (avgOrbAlt / 10000 - 7) * 0.9) + 1.9. //..And why would you rendevous under 70Km? (Add support for in-air rendevous!)
		
		IF launchAngle < 0 { //Will this work?
			UNTIL launchAngle > 0 {
				SET launchAngle TO launchAngle + 360.
			}
		}
		
	SET lastAngle TO 0.	
	LOCAL movingTowards IS false.
		
	SET WARPMODE TO "RAILS".
	SET WARP TO 0.
	UNTIL (VECTORANGLE(targetVec, upVec) < launchAngle AND VECTORANGLE(targetVec, upVec) > (launchAngle - 5) AND movingTowards = true) {
		CLEARSCREEN.

		SET targetVec TO targetCraft:POSITION - targetCraft:BODY:POSITION.
		SET upVec TO UP:VECTOR.
		
		IF VECTORANGLE(targetVec, upVec) < lastAngle { //Does check to see if moving towards current kOS vessel
			SET movingTowards TO True.
		}
		ELSE
		{
			SET movingTowards TO False.
		}
		SET lastAngle TO VECTORANGLE(targetVec, upVec).	
	
		PRINT "Ship relative angle: " + VECTORANGLE(targetVec, upvEC).
		PRINT "Is approaching: " + movingTowards.
		PRINT "Required launch angle: " + launchAngle + " - " + (launchAngle - 5).
		PRINT "Expected altitude: " + avgOrbAlt.
		PRINT "Expected velocity: " + avgOrbSpeed.
		PRINT "Expected time to apoapsis: " + timeOrbit.

	
	
			IF (VECTORANGLE(targetVec,upVec) > (launchAngle + 40) OR movingTowards = false) {SET WARP TO 4.}.
			IF (VECTORANGLE(targetVec,upVec) < (launchAngle + 10) AND movingTowards = true) {SET WARP TO 2.}.
			IF (VECTORANGLE(targetVec,upVec) < (launchAngle + 5) AND movingTowards = true) {SET WARP TO 1.}.
			IF (VECTORANGLE(targetVec,upVec) < (launchAngle + 2) AND movingTowards = true) {SET WARP TO 0.}.
		WAIT 0.1.
	}

	LOCAL targetAltitude IS targetCraft:body:altitudeOf(positionAt(targetCraft,time:seconds + timeOrbit)).
	LOCAL targetInclination IS (90 - targetCraft:OBT:INCLINATION).
	SET TARGET TO targetCraft.
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
//--------------------------------------------------------//

//-----------------------Gravity turn---------------------//
	WAIT UNTIL verticalspeed > 40.
		CLEARSCREEN.
		PRINT "Commencing gravity turn.".	
	
	LIST ENGINES IN engines.
	
	LOCK THROTTLE TO 1.
	UNTIL (apoapsis/targetAltitude) >= 1 { //apoapsis >= targetAltitude. Its in this form to prevent a NaN error due to negative square rooting
		IF (apoapsis/targetAltitude - 0.95) >= 0  AND (apoapsis/targetAltitude) < 0.99 { //Was 1 - apo/targ > 0) as well?
			CLEARSCREEN.
			WAIT 0.1.
			LOCK THROTTLE TO (SHIP:SENSORS:GRAV:MAG / (availThrust / SHIP:MASS) * ((40 * (1 - apoapsis/targetAltitude))^0.5 / 1.4142 * 3)) + 0.01. //+1% throttle
		}
		ELSE
		{		 
			LOCK THROTTLE TO (SHIP:SENSORS:GRAV:MAG / (availThrust / SHIP:MASS) * 3).	
		}		

		LOCK STEERING TO HEADING(targetInclination,90 - 77*(apoapsis/targetAltitude)). //    The rocket can turn 77/90 of the full way
				
		//FOR eng IN engines {
		//	IF eng:FLAMEOUT {
		//		STAGE.
		//		WAIT 0.1.
		//		BREAK.
		//	}
		//}
	}
//--------------------------------------------------------//
//-------------------Atmospheric coasting-----------------//
	IF 1 = 0 { //Stop entry into this section
	//IF SHIP:SENSORS:PRES > 0 {
	IF SHIP:SENSORS:PRES > 9999999 { //Replace this shit later
		PRINT "Coasting out of atmosphere.".
	
		//Finds the drag vector in m/s^2
			LOCAL dragOpp IS 0.
			LOCK dragOpp TO (SHIP:SENSORS:ACC - SHIP:SENSORS:GRAV).
		//----------------------------------\\
		//Finds ship acceleration in m/s^2--//	
			LOCAL shipAcc IS 0.
			
			//CRASHING LINE HERE
			//vvvvvvvvvvvvvvvvvv
			//LOCK shipAcc TO (dragOpp:MAG / ((availThrust - SHIP:MASS*SHIP:SENSORS:GRAV:MAG)/SHIP:MASS)).//-0.04. //Seems to have a slightly raised value, the -0.04 should reduce that.
		//----------------------------------\\
		//Setting steering and throttle-----//
			LOCK STEERING TO smoothRotate(prograde).
		//----------------------------------//
	
		PRINT "Got here!".
		PRINT "ACCCCC: " + shipAcc.
		PRINT "grav mag: " + SHIP:SENSORS:GRAV:MAG.
		
		UNTIL SHIP:SENSORS:PRES >= 0.001 AND apoapsis >= targetAltitude{
			PRINT "Atmospheric acceleration: " + dragOpp:MAG.
			PRINT "Ship acceleration: " + shipAcc.
			PRINT "Pressure: " + SHIP:SENSORS:PRES.
			IF apoapsis > targetAltitude {
				LOCK THROTTLE TO 0.
			} ELSE {
				LOCK THROTTLE TO shipAcc/availThrust/SHIP:MASS+0.01. //Multiplying by 1.03 slightly raises the thrust so that lost altitude can be regained.
			}
			WAIT 0.1.
			CLEARSCREEN.
		}
	}  
	}
	ag10 ON.
//--------------------------------------------------------//
//Could wait in the main program, and run this^^^ as a second program? and it ends upon atmospheric exit. and the main program will resume after some condition like atmosphere exit or reference in second program.

LOCK THROTTLE TO 0.
//LOCK STEERING TO prograde.

//WAIT UNTIL ETA:APOAPSIS < 60.
LOCK STEERING TO smoothRotate((targetCraft:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT):DIRECTION).



WAIT UNTIL (targetCraft:POSITION - SHIP:POSITION):MAG <= ((targetCraft:VELOCITY:ORBIT:MAG^2 - SHIP:VELOCITY:ORBIT:MAG^2) / (2 * SHIP:AVAILABLETHRUST / SHIP:MASS)).
//WAIT UNTIL verticalspeed < 0.2.
	LOCK THROTTLE TO 1.

WAIT UNTIL (targetCraft:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT):MAG < 20. 
	//LOCK THROTTLE TO SQRT((targetCraft:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT):MAG) / 6.324 + 0.01.
	//Remove these fucking slashes

WAIT UNTIL (targetCraft:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT):MAG < 2.

LOCK THROTTLE TO 0.
WAIT 1.

//--------------------------------------------------------//
//RCS movements

STAGE.
SAS ON.
RCS ON.

SET controlStick to SHIP:CONTROL.
LOCK STEERING TO smoothRotate(SHIP:FACING). //Locks vessel to current heading

PRINT "Moving away from stage.".
//Pushes forward at max RCS thrust for 1 second
SET SHIP:CONTROL:FORE TO 1.
SET now TO TIME:SECONDS.
WAIT UNTIL TIME:SECONDS > now + 1.
SET SHIP:CONTROL:FORE TO 0.

WAIT 5.

PRINT "Orientating to reduce relative velocity.".
SET newDir TO (-1 * (targetCraft:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT)):DIRECTION.
	LOCK STEERING TO smoothRotate(newDir). //prepare to cancel out velocity
	
	WAIT UNTIL VECTORANGLE(SHIP:FACING:VECTOR,newDir:VECTOR) < 1.
		SET SHIP:CONTROL:FORE TO -0.6.
		
		SET lastVel TO (targetCraft:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT):MAG.
		UNTIL (targetCraft:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT):MAG > lastVel{
			SET lastVel TO (targetCraft:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT):MAG.
		}
		SET SHIP:CONTROL:FORE to 0.0.
	
//--------------------------------------------------------//

PRINT "Velocity cancelled.".

RUN dock.

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

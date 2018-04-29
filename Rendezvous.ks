CLEARSCREEN.

//If not similar orbits, run orbit match

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _accuracy.
	PARAMETER _TC_Param IS 0. 
	IF _TC_Param <> 0 {
		SET _targetCraft TO _TC_Param.
	}
	ELSE IF _TC_Param = 0 AND HASTARGET = True {
		SET _targetCraft TO TARGET.
	}
	ELSE {
		PRINT "No target is selected.".
		PRINT "Shutting down . . .".
		SHUTDOWN.
	}
	
	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/

	
	LOCK ecc TO _targetCraft:ORBIT:ECCENTRICITY.
    LOCK eccentricAnomalyDeg TO ARCTAN2( SQRT(1-ecc^2)*SIN(_targetCraft:ORBIT:TRUEANOMALY), ecc + COS(_targetCraft:ORBIT:TRUEANOMALY) ).
    LOCK eccentricAnomalyRad TO eccentricAnomalyDeg * CONSTANT:DEGtoRAD.
    LOCK meanAnomalyRad TO eccentricAnomalyRad - ecc*SIN(eccentricAnomalyDeg).
    LOCK rawTime TO meanAnomalyRad / SQRT( _targetCraft:ORBIT:BODY:MU / _targetCraft:ORBIT:SEMIMAJORAXIS^3 ).
	LOCK ETA_periapsis TO (_targetCraft:ORBIT:PERIOD - MOD(rawTime + _targetCraft:ORBIT:PERIOD, _targetCraft:ORBIT:PERIOD)).
		

	LOCAL sepTime IS (ETA_periapsis - ETA:PERIAPSIS).
	IF (sepTime < 0){
		SET sepTime TO SHIP:ORBIT:PERIOD + sepTime.
	}	
	print("Sep time : " + sepTime).
	
	LOCAL req_apoapsis IS 2*((SHIP:BODY:MU*((SHIP:ORBIT:PERIOD + sepTime)/(2*CONSTANT():PI))^2)^(1/3)) - (PERIAPSIS + SHIP:BODY:RADIUS).
	LOCAL base_apoapsis IS SHIP:ORBIT:APOAPSIS + BODY:RADIUS.
	
	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/
		
	//Make it also check reducing the orbit, and compare DV costs here 
	//For lowering, check if it enters the atmosphere
	//For raising, make sure it doesn't escape
		
		
	RUN maneuverPeriapsis(req_apoapsis).
	reducePositionDifferences(_accuracy).
	RUN maneuverPeriapsis(base_apoapsis).
	
	
//--------------------------------------------------------------------------\
//								Functions					   				|
//--------------------------------------------------------------------------/	


//______________________________________________________________
//							Cancel velocity						|
//______________________________________________________________|


FUNCTION cancelVelDONTUSEME{ //THE FIRST SMOOTH ROTATE
	PARAMETER toVector.
	PARAMETER toSpeed. //This is more like error range
	
	SET rcsX TO True.
	SET rcsY TO True.
	SET rcsZ TO True.
	
	RCS ON.
	SAS ON.
		
	//Sets up the custom axis	
	LOCK xVec TO SHIP:FACING:FOREVECTOR.
	LOCK yVec TO SHIP:FACING:TOPVECTOR.
	LOCK zVec TO SHIP:FACING:STARVECTOR.
	
	LOCK relativeVel TO (toVector - VELOCITYAT(SHIP, TIME:SECONDS + ETA:PERIAPSIS):ORBIT).
	LOCK ship_Target_velVec TO V(VDOT(relativeVel,xVec),VDOT(relativeVel,yVec),VDOT(relativeVel,zVec)).
	LOCK STEERING TO smoothRotate(LOOKDIRUP(xVec,yVec)).
	
	
	//High speed stabilization
	UNTIL (rcsX = False AND rcsY = False AND rcsZ = False){
	
		IF ABS(ship_Target_velVec:X) > 1
		{
			SET SHIP:CONTROL:FORE TO ABS(ship_Target_velVec:X)/(ship_Target_velVec:X).
		}
		ELSE
		{
			SET SHIP:CONTROL:FORE TO 0.
			SET rcsX TO False.
		}
		
		IF ABS(ship_Target_velVec:Y) > 1
		{
			SET SHIP:CONTROL:TOP TO ABS(ship_Target_velVec:Y)/(ship_Target_velVec:Y).
		}
		ELSE
		{
			SET SHIP:CONTROL:TOP TO 0.
			SET rcsY TO False.
		}
		
		IF ABS(ship_Target_velVec:Z) > 1
		{
			SET SHIP:CONTROL:STARBOARD TO ABS(ship_Target_velVec:Z)/(ship_Target_velVec:Z).
		}
		ELSE
		{
			SET SHIP:CONTROL:STARBOARD TO 0.
			SET rcsZ TO False.
		}

		CLEARSCREEN.
		PRINT "Reducing relative velocity...(High speed)".
		PRINT "-----------------------------------------".
		PRINT "X: " + ship_Target_velVec:X.
		PRINT "Y: " + ship_Target_velVec:Y.
		PRINT "Z: " + ship_Target_velVec:Z.	
	}	
	
	//Resets booleans for low speed stabilization
	SET rcsX TO True.
	SET rcsY TO True.
	SET rcsZ TO True.

	//Low speed stabilization
	LOCAL stopTime IS TIME:SECONDS + 40.
	UNTIL ((rcsX = False AND rcsY = False AND rcsZ = False) OR TIME:SECONDS > stopTime){	
	
		IF ABS(ship_Target_velVec:X) < toSpeed 
		{
			SET SHIP:CONTROL:FORE TO 0.
			SET rcsX TO False.
		}
		ELSE
		{
			//SET SHIP:CONTROL:FORE TO (ABS(ship_Target_velVec:X)/(ship_Target_velVec:X))*100*sqrt(16*ABS(ship_Target_velVec:X))*toSpeed.
			SET SHIP:CONTROL:FORE TO (ABS(ship_Target_velVec:X)/(ship_Target_velVec:X))*0.05.
			WAIT 0.01.
			SET SHIP:CONTROL:FORE TO 0.
			SET rcsX TO True.
		}	
		
		IF ABS(ship_Target_velVec:Y) < toSpeed 
		{
			SET SHIP:CONTROL:TOP TO 0.
			SET rcsY TO False.
		}
		ELSE
		{
			//SET SHIP:CONTROL:TOP TO (ABS(ship_Target_velVec:Y)/(ship_Target_velVec:Y))*100*sqrt(16*ABS(ship_Target_velVec:Y))*toSpeed.
			SET SHIP:CONTROL:TOP TO (ABS(ship_Target_velVec:Y)/(ship_Target_velVec:Y))*0.05.
			WAIT 0.01.
			SET SHIP:CONTROL:TOP TO 0.
			SET rcsY TO True.
		}
		
		IF ABS(ship_Target_velVec:Z) < toSpeed 
		{
			SET SHIP:CONTROL:STARBOARD TO 0.
			SET rcsZ TO False.
		}
		ELSE
		{
			//SET SHIP:CONTROL:STARBOARD TO (ABS(ship_Target_velVec:Z)/(ship_Target_velVec:Z))*100*sqrt(16*ABS(ship_Target_velVec:Z))*toSpeed.
			SET SHIP:CONTROL:STARBOARD TO (ABS(ship_Target_velVec:Z)/(ship_Target_velVec:Z))*0.05.			
			WAIT 0.01.
			SET SHIP:CONTROL:STARBOARD TO 0.
			SET rcsZ TO True.
		}
		
		CLEARSCREEN.
		PRINT "Reducing relative velocity... (Low speed)".
		PRINT "-----------------------------------------".
		PRINT "X (" + rcsX + "): " + ship_Target_velVec:X.
		PRINT "Y (" + rcsY + "): " + ship_Target_velVec:Y.
		PRINT "Z (" + rcsZ + "): " + ship_Target_velVec:Z.	
	}
	
	//UNLOCK xVec.
	//UNLOCK yVec.
	//UNLOCK zVec.
	//UNLOCK relativeVel.
	//UNLOCK ship_Target_velVec.
}







FUNCTION reducePositionDifferences{ //THE FIRST SMOOTH ROTATE
	//PARAMETER otherPosition.
	PARAMETER toSpeed. //This is more like error range
	
	LOCAL counter IS 0.
	SET rcsList TO list().
	list parts in partList.
	for part in partList
	{
		for module in part:modules
		{
			if module = "ModuleRCSFX"
			{
				rcsList:add(part:getmodule("ModuleRCSFX")).
			}
		}
	}
	
	SET rcsX TO True.
	SET rcsY TO True.
	SET rcsZ TO True.
	
	RCS ON.
	SAS ON.
		
	//Sets up the custom axis	
	LOCK xVec TO SHIP:FACING:FOREVECTOR.
	LOCK yVec TO SHIP:FACING:TOPVECTOR.
	LOCK zVec TO SHIP:FACING:STARVECTOR.
	
	LOCK relativeVel TO (POSITIONAT(_targetCraft, TIME:SECONDS + ETA:PERIAPSIS) - POSITIONAT(SHIP, TIME:SECONDS + ETA:PERIAPSIS)).
	LOCK ship_Target_velVec TO V(VDOT(relativeVel,xVec),VDOT(relativeVel,yVec),VDOT(relativeVel,zVec)).
	LOCK STEERING TO smoothRotate(LOOKDIRUP(xVec,yVec)).
	
	
	//High speed stabilization
	UNTIL (rcsX = False AND rcsY = False AND rcsZ = False){	
	
		IF ABS(ship_Target_velVec:X) > 15000
		{
			SET SHIP:CONTROL:FORE TO -ABS(ship_Target_velVec:X)/(ship_Target_velVec:X)*0.10.
		}
		ELSE
		{
			SET SHIP:CONTROL:FORE TO 0.
			SET rcsX TO False.
		}
		
		IF ABS(ship_Target_velVec:Y) > 15000
		{
			SET SHIP:CONTROL:TOP TO -ABS(ship_Target_velVec:Y)/(ship_Target_velVec:Y)*0.10.
		}
		ELSE
		{
			SET SHIP:CONTROL:TOP TO 0.
			SET rcsY TO False.
		}
		
		IF ABS(ship_Target_velVec:Z) > 15000
		{
			SET SHIP:CONTROL:STARBOARD TO ABS(ship_Target_velVec:Z)/(ship_Target_velVec:Z)*0.10.
		}
		ELSE
		{
			SET SHIP:CONTROL:STARBOARD TO 0.
			SET rcsZ TO False.
		}

		CLEARSCREEN.
		PRINT "Reducing relative position...(High speed)".
		PRINT "-----------------------------------------".
		PRINT "X: " + ship_Target_velVec:X.
		PRINT "Y: " + ship_Target_velVec:Y.
		PRINT "Z: " + ship_Target_velVec:Z.	
	}	
	
	//Resets booleans for low speed stabilization
	SET rcsX TO True.
	SET rcsY TO True.
	SET rcsZ TO True.
	
	//Low speed stabilization
	LOCAL stopTime IS TIME:SECONDS + 45. //30 seconds to reduce
	UNTIL ((rcsX = False AND rcsY = False AND rcsZ = False) OR TIME:SECONDS > stopTime){	
	
		IF ABS(ship_Target_velVec:X) < toSpeed 
		{
			SET SHIP:CONTROL:FORE TO 0.
			SET rcsX TO False.
		}
		ELSE
		{
			//SET SHIP:CONTROL:FORE TO (ABS(ship_Target_velVec:X)/(ship_Target_velVec:X))*100*sqrt(16*ABS(ship_Target_velVec:X))*toSpeed.
			SET SHIP:CONTROL:FORE TO -(ABS(ship_Target_velVec:X)/(ship_Target_velVec:X))*0.05.
			WAIT 0.0001.
			SET SHIP:CONTROL:FORE TO 0.
			SET rcsX TO True.
		}	
		
		IF ABS(ship_Target_velVec:Y) < toSpeed 
		{
			SET SHIP:CONTROL:TOP TO 0.
			SET rcsY TO False.
		}
		ELSE
		{
			//SET SHIP:CONTROL:TOP TO (ABS(ship_Target_velVec:Y)/(ship_Target_velVec:Y))*100*sqrt(16*ABS(ship_Target_velVec:Y))*toSpeed.
			SET SHIP:CONTROL:TOP TO -(ABS(ship_Target_velVec:Y)/(ship_Target_velVec:Y))*0.05.
			WAIT 0.01.
			SET SHIP:CONTROL:TOP TO 0.
			SET rcsY TO True.
		}
		
		IF ABS(ship_Target_velVec:Z) < toSpeed 
		{
			SET SHIP:CONTROL:STARBOARD TO 0.
			SET rcsZ TO False.
		}
		ELSE
		{
			//SET SHIP:CONTROL:STARBOARD TO (ABS(ship_Target_velVec:Z)/(ship_Target_velVec:Z))*100*sqrt(16*ABS(ship_Target_velVec:Z))*toSpeed.
			SET SHIP:CONTROL:STARBOARD TO (ABS(ship_Target_velVec:Z)/(ship_Target_velVec:Z))*0.05.			
			WAIT 0.01.
			SET SHIP:CONTROL:STARBOARD TO 0.
			SET rcsZ TO True.
		}
		
		
		IF(ABS(ship_Target_velVec:X) < 30 AND ABS(ship_Target_velVec:Y) < 30 AND ABS(ship_Target_velVec:Z) < 30){
			rcsList[2]:SETFIELD("rcs", False).
			rcsList[3]:SETFIELD("rcs", False).
		}
				ELSE IF(ABS(ship_Target_velVec:X) < 400 AND ABS(ship_Target_velVec:Y) < 400 AND ABS(ship_Target_velVec:Z) < 400){
			SET counter TO 0.
			UNTIL counter = rcsList:LENGTH{
				//rcsList[counter]:SETFIELD("rcs", False).
				rcsList[counter]:SETFIELD("thrust limiter", 1).
				SET counter TO counter + 1.
			}
		}
		ELSE IF(ABS(ship_Target_velVec:X) < 1000 AND ABS(ship_Target_velVec:Y) < 1000 AND ABS(ship_Target_velVec:Z) < 1000){
			SET counter TO 0.
			UNTIL counter = rcsList:LENGTH{
				//rcsList[counter]:SETFIELD("rcs", False).
				rcsList[counter]:SETFIELD("thrust limiter", 4).
				SET counter TO counter + 1.
			}
		}
		ELSE IF(ABS(ship_Target_velVec:X) < 7000 AND ABS(ship_Target_velVec:Y) < 7000 AND ABS(ship_Target_velVec:Z) < 7000){
			SET counter TO 0.
			UNTIL counter = rcsList:LENGTH{
				rcsList[counter]:SETFIELD("thrust limiter", 10).
				SET counter TO counter + 1.
			}
		}
		
		CLEARSCREEN.
		PRINT "Reducing relative position... (Low speed)".
		PRINT "-----------------------------------------".
		PRINT "X (" + rcsX + "): " + ship_Target_velVec:X.
		PRINT "Y (" + rcsY + "): " + ship_Target_velVec:Y.
		PRINT "Z (" + rcsZ + "): " + ship_Target_velVec:Z.	
	}
	
	SET counter TO 0.
	UNTIL counter = rcsList:LENGTH{
		rcsList[counter]:SETFIELD("thrust limiter", 100).
		rcsList[counter]:SETFIELD("rcs", true).
		SET counter TO counter + 1.
	}
}
	
PARAMETER toVector.
PARAMETER toSpeed.	
	
SET rcsX TO True.
SET rcsY TO True.
SET rcsZ TO True.

LOCAL endTime IS TIME:SECONDS + 30.
		
//Sets up the custom axis		
LOCK custom_xVec TO SHIP:FACING:FOREVECTOR.
LOCK custom_yVec TO SHIP:FACING:TOPVECTOR.
LOCK custom_zVec TO SHIP:FACING:STARVECTOR.
	
	
LOCAL totalDiff IS (SHIP:VELOCITY:ORBIT - toVector).
LOCAL diff IS 0.
LOCAL initialVel IS 0.

//LOCK relativeVel TO (SHIP:VELOCITY:ORBIT - toVector).
LOCK relativeVel TO totalDiff.
LOCK ship_Target_velVec TO V(VDOT(relativeVel,custom_xVec),VDOT(relativeVel,custom_yVec),VDOT(relativeVel,custom_zVec)).
	
	
//High speed stabilization
UNTIL ((rcsX = False AND rcsY = False AND rcsZ = False) OR TIME:SECONDS > endTime){	

	SET initialVel TO SHIP:VELOCITY:ORBIT.
	
	IF ABS(ship_Target_velVec:X) > 0.5
	{
		SET SHIP:CONTROL:FORE TO -ABS(ship_Target_velVec:X)/(ship_Target_velVec:X).
	}
	ELSE
	{
		SET SHIP:CONTROL:FORE TO 0.
		SET rcsX TO False.
	}
		
	IF ABS(ship_Target_velVec:Y) > 0.5
	{
		SET SHIP:CONTROL:TOP TO -ABS(ship_Target_velVec:Y)/(ship_Target_velVec:Y).
	}
	ELSE
	{
		SET SHIP:CONTROL:TOP TO 0.
		SET rcsY TO False.
	}
		
	IF ABS(ship_Target_velVec:Z) > 0.5
	{
		SET SHIP:CONTROL:STARBOARD TO -ABS(ship_Target_velVec:Z)/(ship_Target_velVec:Z).
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
	PRINT "Current : " + SHIP:VELOCITY:ORBIT.
	PRINT "Expected : " + toVector.
	
	SET diff TO SHIP:VELOCITY:ORBIT - initialVel.
	SET totalDiff TO totalDiff + diff.
}	
	
//Resets booleans for low speed stabilization
SET rcsX TO True.
SET rcsY TO True.
SET rcsZ TO True.

SET endTime TO TIME:SECONDS + 30.
	
//Maybe just set toSpeed in here to 0.05? Seems to work fine. Or maybe slightly based on mass
//Low speed stabilization
UNTIL ((rcsX = False AND rcsY = False AND rcsZ = False) OR TIME:SECONDS > endTime){	

	SET initialVel TO SHIP:VELOCITY:ORBIT.
	
	IF ABS(ship_Target_velVec:X) < toSpeed 
	{
		SET SHIP:CONTROL:FORE TO 0.
		SET rcsX TO False.
	}
	ELSE
	{
		SET SHIP:CONTROL:FORE TO (-ABS(ship_Target_velVec:X)/(ship_Target_velVec:X))*sqrt(16*ABS(ship_Target_velVec:X))*toSpeed*5. //Added 5 for further
	}	
		
	IF ABS(ship_Target_velVec:Y) < toSpeed 
	{
		SET SHIP:CONTROL:TOP TO 0.
		SET rcsY TO False.
	}
	ELSE
	{
		SET SHIP:CONTROL:TOP TO (-ABS(ship_Target_velVec:Y)/(ship_Target_velVec:Y))*sqrt(16*ABS(ship_Target_velVec:Y))*toSpeed*5.
	}
		
	IF ABS(ship_Target_velVec:Z) < toSpeed 
	{
		SET SHIP:CONTROL:STARBOARD TO 0.
		SET rcsZ TO False.
	}
	ELSE
	{
		SET SHIP:CONTROL:STARBOARD TO (-ABS(ship_Target_velVec:Z)/(ship_Target_velVec:Z))*sqrt(16*ABS(ship_Target_velVec:Z))*toSpeed*5.
	}
		
	CLEARSCREEN.
	PRINT "Reducing relative velocity... (Low speed)".
	PRINT "-----------------------------------------".
	PRINT "X: " + ship_Target_velVec:X.
	PRINT "Y: " + ship_Target_velVec:Y.
	PRINT "Z: " + ship_Target_velVec:Z.	
	PRINT "Current : " + SHIP:VELOCITY:ORBIT.
	PRINT "Expected : " + toVector.
	
	SET diff TO SHIP:VELOCITY:ORBIT - initialVel.
	SET totalDiff TO totalDiff + diff.
}
	
SET SHIP:CONTROL:FORE TO 0.
SET SHIP:CONTROL:TOP TO 0.
SET SHIP:CONTROL:STARBOARD TO 0.
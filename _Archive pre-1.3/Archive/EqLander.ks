//THIS ONE WAITS UNTIL THE ANGLE IS NEAR 0



CLEARSCREEN.
GEAR OFF.

PARAMETER targetObject IS 0. //Optional parameter when running the script, skips location selection and lands at chosen targetObject

SET targetCoordinates TO 0.	
SET terrainHeight TO 0.
SET latInclination TO 0.
SET method TO 0.

IF targetObject = 0 {
	selectType.
	IF method = "SELECT" {
		selectEntity.
	}
	ELSE
	{
		selectCoordinates.
	}
}
ELSE {
	SET targetCoordinates TO targetObject:GEOPOSITION.
}

SET latInclination TO targetCoordinates:LAT.
SET terrainHeight TO targetCoordinates:TERRAINHEIGHT + 500.


//BIG PROBLEM HERE
//Inclination apparently takes into account if the angle is tilted, even if it is flat


//--------------------------------------------------------//
//-------------------Inclination change-------------------//


//Lock to node------------------------//
LOCK shipInclination TO SHIP:OBT:INCLINATION * ABS(SHIP:OBT:VELOCITY:ORBIT:Y) / SHIP:OBT:VELOCITY:ORBIT:Y.
IF shipInclination < latInclination {
	LOCK STEERING TO smoothRotate(LOOKDIRUP(-VCRS(UP:VECTOR,SHIP:OBT:VELOCITY:ORBIT), UP:VECTOR)).
}
ELSE
{
	LOCK STEERING TO smoothRotate(LOOKDIRUP(VCRS(UP:VECTOR,SHIP:OBT:VELOCITY:ORBIT), UP:VECTOR)).
}
//WAIT UNTIL ETA:apoapsis < 1.


//Adjust inclination------------------//
LOCK THROTTLE TO 0.2.
UNTIL ABS(shipInclination - latInclination) < 0.1 {
	CLEARSCREEN.
	PRINT "Current : " + shipInclination.
	PRINT "Target  : " + latInclination.
	WAIT 0.1.
}
LOCK THROTTLE TO 0.


UNLOCK THROTTLE.
LOCK STEERING TO smoothRotate(RETROGRADE).


//--------------------------------------------------------//
//-------------------Finding periapsis--------------------//


LOCAL intersectPeriapsis IS (BODY:RADIUS + terrainHeight).
//LOCK intersectSMA TO (apoapsis + BODY:RADIUS + intersectPeriapsis)/2.
//LOCK intersectEcc TO (apoapsis + BODY:RADIUS) / intersectSMA - 1.


//--------------------------------------------------------//
//-----------------Time to surface impact-----------------//


//--------------------------------------------------------//
//--------------Planetary rotation calculation------------//


LOCAL impactRotationAngle IS 360*((SHIP:ORBIT:PERIOD/2)/BODY:ROTATIONPERIOD).
LOCK preLandedCoords TO SHIP:BODY:GEOPOSITIONOF(2*(SHIP:BODY:POSITION - SHIP:POSITION)).
LOCK landingCoords TO LATLNG(preLandedCoords:LAT, addLongitude(preLandedCoords:LNG, -impactRotationAngle)).

SET longitudeDifference TO addLongitude(targetCoordinates:LNG, -landingCoords:LNG).
IF longitudeDifference < 0 {
	SET longitudeDifference TO 360 - ABS(longitudeDifference).
}


//--------------------------------------------------------//
//-------------------Velocity reduction-------------------//

LOCK orbitAngularVelocity TO 2*CONSTANT():PI/SHIP:ORBIT:PERIOD.

LOCAL waitTime IS ABS((CONSTANT():PI*longitudeDifference/180) / (orbitAngularVelocity - 2*CONSTANT():PI/BODY:ROTATIONPERIOD)).

LOCAL intersectApoapsis IS SHIP:BODY:RADIUS + SHIP:BODY:ALTITUDEOF(POSITIONAT(SHIP,TIME:SECONDS + waitTime)).
LOCAL intersectSMA IS (intersectApoapsis + intersectPeriapsis)/2.
LOCAL intersectEccentricity IS (intersectApoapsis - intersectPeriapsis) / (intersectApoapsis + intersectPeriapsis).
LOCAL intersectApoapsis_Velocity IS SQRT(((1 - intersectEccentricity) / (1 + intersectEccentricity)) * (SHIP:BODY:MU / intersectSMA)).

//Burns to reduce periapsis to intersect point
RUN nodeBurn(waitTime, VELOCITYAT(SHIP,TIME:SECONDS + waitTime):ORBIT:MAG - intersectApoapsis_Velocity, 2).


LOCAL shipAcceleration IS (SHIP:AVAILABLETHRUST/SHIP:MASS).
LOCAL burnTime IS (VELOCITYAT(SHIP,TIME:SECONDS + ETA:PERIAPSIS):ORBIT:MAG / shipAcceleration).
LOCAL burnDistance IS ((VELOCITYAT(SHIP,TIME:SECONDS + ETA:PERIAPSIS):ORBIT:MAG / 2)*burnTime).

//Burns to reduce excess horizontal velocity once periapsis is reached.
SET waitTime TO (ETA:PERIAPSIS - (burnDistance/SHIP:VELOCITY:SURFACE:MAG) + burnTime/2). //BurnTime/2 shifts the burn start forwards, as the subscript starts a bit early usually
RUN nodeBurn(waitTime, VELOCITYAT(SHIP,TIME:SECONDS + waitTime):ORBIT:MAG, 2). //WaitTime / 2 help at all?


//Reduce any excess velocity before landing
LOCK STEERING TO smoothRotate((-VELOCITY:SURFACE):DIRECTION).
RCS ON.
WAIT 6.
LOCAL shipAltitude IS SHIP:ALTITUDE - SHIP:GEOPOSITION:TERRAINHEIGHT.
LOCAL burnAmount IS (SHIP:VELOCITY:SURFACE:MAG / shipAcceleration)*(SHIP:BODY:MU / (shipAltitude + SHIP:BODY:RADIUS)^2) + SHIP:VELOCITY:SURFACE:MAG.
RUN nodeBurn(0, burnAmount + 1, 3).


GEAR ON.
SET legDistance TO 0.
SET partList TO SHIP:PARTS.
FOR PART IN partList
{			
	IF (PART:POSITION - SHIP:POSITION):MAG > legDistance {
		SET legDistance TO (PART:POSITION - SHIP:POSITION):MAG.   //Finds the part farthest from the vessel center
	}
}
SET shipAltitude TO SHIP:ALTITUDE - SHIP:GEOPOSITION:TERRAINHEIGHT - legDistance.
LOCAL Ag IS (SHIP:BODY:MU / (shipAltitude + SHIP:BODY:RADIUS)^2).
LOCAL Vf IS SQRT(VERTICALSPEED^2 + 2*Ag*shipAltitude).
LOCAL timeLand IS Vf/Ag - 1.
RUN nodeBurn(timeLand, Vf, 3).

LOCK STEERING TO smoothRotate(UP).
RCS OFF.

CLEARSCREEN.
PRINT "Landed at".
PRINT "---------------------------".
PRINT "LAT 					: " + SHIP:GEOPOSITION:LAT.
PRINT "LNG 					: " + SHIP:GEOPOSITION:LNG.
PRINT " ".
PRINT "Distance from target : " + targetCoordinates:POSITION:MAG + " m".
PRINT " ".

//--------------------------------------------------------------------------------------------\
//											Functions										  |
//--------------------------------------------------------------------------------------------/


//WRAPS


//------------------------------------------------------\\
//Angle wrap--------------------------------------------//
FUNCTION angWrap {
	PARAMETER angle.
	LOCAL angleNew IS angle.
	IF angleNew < 0 {
		SET angleNew TO 360 + angleNew.
	}	
	IF angleNew > 360 {
		SET angleNew TO angleNew - 360.
	}
	RETURN angleNew.
}


//------------------------------------------------------\\
//Add longitude-----------------------------------------//
FUNCTION addLongitude {
	PARAMETER longitude.
	PARAMETER angle.
	
	LOCAL longNew IS longitude + angle.
	IF longNew > 180 {
		UNTIL longNew < 0 {
			SET longNew TO longNew - 180.
		}
	}	
	ELSE IF longNew < -180 {
		UNTIL longNew > 0 {
			SET longNew TO longNew + 180.
		}
	}
	RETURN longNew.
}


//SUB-CALCULATIONS


//UI


//------------------------------------------------------\\
//Selection type----------------------------------------//
FUNCTION selectType {
	ag1 OFF.
	ag2 OFF.
		
	PRINT "Use action group 1 to select an entity from a list.".
	PRINT "Use action group 2 to manually select landing location.".
		
	WAIT UNTIL ag1 = "True" or ag2 = "True".	
		IF ag1 = "True"{ 
			SET method TO "SELECT".
			ag1 OFF.
		}
		IF ag2 = "True" { 
			SET method TO "MANUAL".
			ag2 OFF.
		}
		
	CLEARSCREEN.
}


//------------------------------------------------------\\
//Select entity-----------------------------------------//
FUNCTION selectEntity {
	SET landedEntities TO LIST().
	
	LIST TARGETS IN entityList.
		FOR ENTITY IN entityList
		{										
			IF SHIP:BODY:NAME = ENTITY:BODY:NAME AND (ENTITY:STATUS = "LANDED" OR ENTITY:STATUS = "SPLASHED"){
				landedEntities:ADD(ENTITY).
			}
		}
	

	LOCAL listIndex IS 0.
	LOCAL chosen IS "False".
	
	ag1 OFF.
	ag2 OFF.
	ag3 OFF.
	
	UNTIL chosen = True {
		PRINT "Use action group 1 to move up the list.".
		PRINT "Use action group 2 to move down the list.".
		PRINT "Use action group 3 to confirm target".
		PRINT " ".
		PRINT landedEntities.
		PRINT " ".
		PRINT "Target entity: [" + listIndex + "] " + landedEntities[listIndex].
		
		WAIT UNTIL ag1 = "True" OR ag2 = "True" OR ag3 = "True".	
			IF ag1 = "True" AND listIndex > 0{ 
				SET listIndex TO listIndex - 1. 
			}
			IF ag2 = "True" AND listIndex < (landedEntities:LENGTH - 1){ 
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
	
	LOCK targetCoordinates TO landedEntities[listIndex]:GEOPOSITION.
}


//------------------------------------------------------\\
//Select coordinates------------------------------------//
FUNCTION selectCoordinates {
	LOCAL latitude IS 0.
	LOCAL longitude IS 0.
	LOCAL targetSpot IS LATLNG(latitude, longitude).
	LOCAL body IS SHIP:BODY.
	
	SET VD_location TO VECDRAWARGS(targetSpot:POSITION, targetSpot:POSITION - body:POSITION, RED, "Target location", 1, True).
	
	
	//Choose location
	LOCAL chosen IS "False".
	
	ag1 OFF.
	ag2 OFF.
	ag3 OFF.
	ag4 OFF.
	ag5 OFF.
	
	//Choose latitude
	UNTIL chosen = True {
		PRINT "Use action group 1 to increase latitude by 1.".
		PRINT "Use action group 2 to increase latitude by 10.".
		PRINT "Use action group 3 to decrease latitude by 1.".
		PRINT "Use action group 4 to decrease latitude by 10.".
		PRINT "Use action group 5 to confirm latitude".
		PRINT " ".
		PRINT "Latitude: " + latitude.
		
		WAIT UNTIL ag1 = "True" OR ag2 = "True" OR ag3 = "True" OR ag4 = "True" OR ag5 = "True".	
			IF ag1 = "True"{ 
				SET latitude TO latitude + 1.
			}
			IF ag2 = "True"{ 
				SET latitude TO latitude + 10.
			}
			IF ag3 = "True" { 
				SET latitude TO latitude - 1.
			}
			IF ag4 = "True" { 
				SET latitude TO latitude - 10.
			}
			IF ag5 = "True" { 
				SET chosen TO True.
			}
			
			SET targetSpot TO LATLNG(latitude, longitude).
			SET VD_location TO VECDRAWARGS(targetSpot:POSITION, targetSpot:POSITION - body:POSITION, RED, "Target location", 1, True).
			
			CLEARSCREEN.
			
			ag1 OFF.
			ag2 OFF.
			ag3 OFF.
			ag4 OFF.
			ag5 OFF.
	}
	
	//Choose longitude
	SET chosen TO False.
	UNTIL chosen = True {
		PRINT "Use action group 1 to increase longitude by 1.".
		PRINT "Use action group 2 to increase longitude by 10.".
		PRINT "Use action group 3 to decrease longitude by 1.".
		PRINT "Use action group 4 to decrease longitude by 10.".
		PRINT "Use action group 5 to confirm longitude".
		PRINT " ".
		PRINT "longitude: " + longitude.
		
		WAIT UNTIL ag1 = "True" OR ag2 = "True" OR ag3 = "True" OR ag4 = "True" OR ag5 = "True".	
			IF ag1 = "True"{ 
				SET longitude TO longitude + 1.
			}
			IF ag2 = "True"{ 
				SET longitude TO longitude + 10.
			}
			IF ag3 = "True" { 
				SET longitude TO longitude - 1.
			}
			IF ag4 = "True" { 
				SET longitude TO longitude - 10.
			}
			IF ag5 = "True" { 
				SET chosen TO True.
			}
			
			SET targetSpot TO LATLNG(latitude, longitude).
			SET VD_location TO VECDRAWARGS(targetSpot:POSITION, targetSpot:POSITION - body:POSITION, RED, "Target location", 1, True).
			
			CLEARSCREEN.
			
			ag1 OFF.
			ag2 OFF.
			ag3 OFF.
			ag4 OFF.
			ag5 OFF.
	}
	
	SET targetCoordinates TO targetSpot.
}


//SHIP FUNCTIONAL


//------------------------------------------------------\\
//Smooth rotate-----------------------------------------//
FUNCTION smoothRotate {
    PARAMETER dir.
    LOCAL spd IS max(SHIP:ANGULARMOMENTUM:MAG/10,4).
    LOCAL curF IS SHIP:FACING:FOREVECTOR.
    LOCAL curR IS SHIP:FACING:TOPVECTOR.
    LOCAL rotR IS R(0,0,0).
    IF VANG(dir:FOREVECTOR,curF) < 90{SET rotR TO ANGLEAXIS(min(0.5,VANG(dir:TOPVECTOR,curR)/spd),VCRS(curR,dir:TOPVECTOR)).}
    RETURN LOOKDIRUP(ANGLEAXIS(min(2,VANG(dir:FOREVECTOR,curF)/spd),VCRS(curF,dir:FOREVECTOR))*curF,rotR*curR).
}



//THIS ONE USES ANGULAR VELOCITY



CLEARSCREEN.

//PARAMETER targetObject. //Optional parameter when running the script, skips location selection and lands at chosen targetObject

SET targetCoordinates TO 0.	
SET terrainHeight TO 0.
SET latInclination TO 0.
SET method TO 0.

selectType.
IF method = "SELECT" {
	selectEntity.
}
ELSE
{
	selectCoordinates.
}

SET latInclination TO targetCoordinates:LAT.
SET terrainHeight TO targetCoordinates:TERRAINHEIGHT.


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
WAIT UNTIL ETA:apoapsis < 1.


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


LOCAL valuePasses IS 0.
LOCAL lastDir IS "".

LOCAL intersectPeri IS (periapsis + BODY:RADIUS).  //MAYBE ADD TERRAIN HEIGHT HERE??
LOCK intersectSMA TO (apoapsis + BODY:RADIUS + intersectPeri)/2.
LOCK intersectEcc TO (apoapsis + BODY:RADIUS) / intersectSMA - 1.
LOCK intersectPeriArg TO SHIP:OBT:ARGUMENTOFPERIAPSIS * ABS(SHIP:OBT:VELOCITY:ORBIT:Y) / SHIP:OBT:VELOCITY:ORBIT:Y. //Check if this works
LOCK intersectTrueAnom TO ARCSIN(1) - intersectPeriArg. //Not sure if good to have ships current inclination?
LOCK resultingAlt TO intersectSMA*(1-intersectEcc^2) / (1+intersectEcc*COS(intersectTrueAnom)). //latInclination in place of TrueAnom

UNTIL ABS(resultingAlt - (terrainHeight + BODY:RADIUS)) < 0.1 OR valuePasses > 25 {
	IF resultingAlt > (terrainHeight + BODY:RADIUS) { //Was intersectPeri here
		IF lastDir = "increase" { //If this section was last increasing the periapsis
			SET valuePasses TO valuePasses + 1.
			SET lastDir TO "decrease". //Switch to decreasing
		}
		ELSE IF lastDir = "" { //If this is the first iteration
			SET lastDir TO "decrease".
		}
		
		SET intersectPeri TO intersectPeri - 100000/2^valuePasses.
	}
	ELSE
	{
		IF lastDir = "decrease" {
			SET valuePasses TO valuePasses + 1.
			SET lastDir TO "increase".
		}
		ELSE IF lastDir = "" {
			SET lastDir TO "increase".
		}
		
		SET intersectPeri TO intersectPeri + 100000/2^valuePasses.
	}
	
	CLEARSCREEN.
	PRINT "Target periapsis  : " + (terrainHeight + BODY:RADIUS).
	PRINT "--------------------------------".
	PRINT "Checking periapsis: " + intersectPeri.
	PRINT "Passes: " + valuePasses.
	PRINT lastDir.
	PRINT "--------------------------------".
	PRINT "Resulting altitude: " + resultingAlt.
}
CLEARSCREEN.


//--------------------------------------------------------//
//-----------------Time to surface impact-----------------//


LOCAL apoToPeri_Time IS SQRT((4*(CONSTANT():PI^2)*(intersectSMA^3))/SHIP:BODY:MU)/2.


//Set orbital parameters--------------//
SET PeR TO intersectPeri.
SET PeA TO intersectPeri-BODY:RADIUS.
SET PeT TO apoToPeri_Time.
SET a TO intersectSMA.
SET Ecc TO intersectEcc.
SET deg2Rad TO CONSTANT():PI / 180.
SET rad2Deg TO 180 / CONSTANT():PI.


//Calculate time----------------------//
IF Ecc > 0{
	SET impactTheta TO -ARCCOS((PeR * (1 + Ecc) / (resultingAlt) - 1) / Ecc).
}

if (Ecc = 1.0) {
	SET D TO TAN(impactTheta / 2).
	SET M TO D + D * D * D / 3.0.
	SET timeOffset TO SQRT(2.0 * (PeR)^3 / BODY:MU) * M.
} else if (a > 0) {
	SET cosTheta TO COS(impactTheta).
	SET cosE TO (Ecc + cosTheta) / (1.0 + Ecc * cosTheta).
	SET radE TO ARCCOS(cosE).
	SET M TO (radE * deg2Rad) - Ecc * SIN(radE).
	SET timeOffset TO (SQRT(A^3 / BODY:MU) * M).
} else if (a < 0) {
	SET cosTheta TO COS(impactTheta).
	SET coshF TO ((Ecc + cosTheta) / (1.0 + Ecc * cosTheta)).
	SET radF TO LN(coshF + SQRT(coshF^2 - 1.0)). //AcosH of cosTheta
	SET M TO Ecc * (((CONSTANT():E^radF) - (CONSTANT():E^(0-radF)))/2) - radF. //sinH(radF) - radF
	SET timeOffset TO (SQRT(-1 * A^3 / BODY:MU) * M).
}
SET timeToAlt1 TO PeT - timeOffset.
SET timeToAlt2 TO PeT + timeOffset.


//--------------------------------------------------------//
//--------------Planetary rotation calculation-------------//


LOCAL vecTargetSite IS targetCoordinates:POSITION - BODY:POSITION.
LOCAL vecInitialSite IS SHIP:OBT:VELOCITY:ORBIT.

LOCAL impactRotationAngle IS 360*(timeToAlt1/BODY:ROTATIONPERIOD).

LOCAL preLandedCoords IS SHIP:BODY:GEOPOSITIONOF(SHIP:BODY:POSITION - SHIP:POSITION + vecInitialSite).
LOCAL landingCoords IS LATLNG(preLandedCoords:LAT, addLongitude(preLandedCoords:LNG, -impactRotationAngle)).


LOCAL longitudeDifference IS addLongitude(targetCoordinates:LNG, -landingCoords:LNG).
	
LOCK orbitAngularVelocity TO 2*CONSTANT():PI/SHIP:ORBIT:PERIOD.	
LOCAL waitTime IS (CONSTANT():PI*longitudeDifference/180) / (orbitAngularVelocity - 2*CONSTANT():PI/BODY:ROTATIONPERIOD).

PRINT "Long diff (rad) : " + longitudeDifference.
PRINT "Ship angular vel : " + SHIP:ANGULARVEL:MAG.
PRINT "Body angular vel : " + 2*CONSTANT():PI/BODY:ROTATIONPERIOD.
	WAIT 10.


//--------------------------------------------------------//
//-------------------Velocity reduction-------------------//


LOCAL startTime IS TIME:SECONDS.
LOCK timeLeft TO (waitTime + startTime) - TIME:SECONDS.

UNTIL (periapsis + BODY:RADIUS) < intersectPeri OR ag9 = True {
	CLEARSCREEN.
	PRINT "Time left until burn: " + timeLeft.
	PRINT "Lower periapsis by: " + (periapsis + BODY:RADIUS - intersectPeri).
	PRINT "Current orbit peri: " + periapsis.
}


//--------------------------------------------------------//
//--------------------Surface approach--------------------//

SET startTime TO TIME:SECONDS.

LOCK timeImpact TO (startTime + timeToAlt1) - TIME:SECONDS.
UNTIL timeImpact = 0 {
	CLEARSCREEN.
	PRINT "Time to impact: " + timeImpact.
	print "---------------------------".
	//PRINT "Target lng: " + targetCoordinates:LNG.
	//PRINT "Difference: " + initialRotDifference.
	//PRINT "Lng Difference: " + lngDifference.
	PRINT " ".
	PRINT "Pre-Landing coords:".
	PRINT "LAT : " + preLandedCoords:LAT.
	PRINT "LNG : " + preLandedCoords:LNG.
	PRINT " ".
	PRINT "Landing coords:".
	PRINT "LAT : " + landingCoords:LAT.
	PRINT "LNG : " + landingCoords:LNG.
	PRINT " ".
	PRINT "Current coords:".
	PRINT "LAT : " + SHIP:GEOPOSITION:LAT.
	PRINT "LNG : " + SHIP:GEOPOSITION:LNG.
	PRINT " ".
	PRINT "Rot-angle : " + impactRotationAngle.
}

//--------------------------------------------------------//
//-----------------------Suicide burn----------------------//

//Can do this part now maybe???
//Will be based off of the terrain height though but it may be able to work

//Terrain height
//Initial downward speed (Maybe from vector from ship to planet?)






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
	
	SET targetCoordinates TO landedEntities[listIndex]:GEOPOSITION.
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



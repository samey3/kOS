@lazyglobal OFF.
runoncepath("lib/impactProperties.ks").
runoncepath("lib/shipControl.ks").

CLEARSCREEN.

LOCK STEERING TO SHIP:FACING.
LOCK THROTTLE TO 0.
UNLOCK STEERING.
UNLOCK THROTTLE.

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _coordinates IS TARGET:GEOPOSITION.
	PARAMETER _interceptAltitude IS SHIP:BODY:RADIUS - 50000.


//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/	
	
	
	LOCAL timeToImpact IS 0.
	LOCAL targetHeight IS _coordinates:TERRAINHEIGHT.
	LOCAL inclination IS 0.
	LOCAL stopAltitude IS 10000.


//--------------------------------------------------------------------------\
//							 Reboot conditions					   			|
//--------------------------------------------------------------------------/
	
	
	//Final periapsis must dip below surface
	IF((SHIP:BODY:RADIUS + SHIP:ORBIT:PERIAPSIS) < _interceptAltitude){	
		PRINT ("Operation conditions not met ( " + SCRIPTPATH():NAME + " ).").
		PRINT ("Rebooting. . ."). 
		WAIT 3. REBOOT.
	}
	
	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	//----------------------------------------------------\
	//Iterate the latitude--------------------------------|
		LOCAL valuePasses IS 0.
		LOCAL lastDir IS "increase".
		LOCAL inclinationShift IS 0.
		LOCAL impactCoords IS predictImpactCoords(_interceptAltitude, targetHeight + stopAltitude, inclinationShift, 0).
		
		UNTIL (valuePasses > 10) {
			IF(impactCoords:LAT < _coordinates:LAT){
				IF lastDir = "decrease" {
					SET valuePasses TO valuePasses + 1.
					SET lastDir TO "increase".
				}	
				SET inclinationShift TO inclinationShift + 10/2^valuePasses.
			}
			ELSE {
				IF lastDir = "increase" {
					SET valuePasses TO valuePasses + 1.
					SET lastDir TO "decrease".
				}
				SET inclinationShift TO inclinationShift - 10/2^valuePasses.
			}
			
			//Sets the new impact coordinates
			SET impactCoords TO predictImpactCoords(_interceptAltitude, targetHeight + stopAltitude, inclinationShift, 0).
			
			//Output info
			CLEARSCREEN.
			PRINT("Impact lat  : " + impactCoords:LAT).
			PRINT("Target lat : " + _coordinates:LAT).
			PRINT("---------------------------------").
			PRINT("Shift : " + inclinationShift).
			PRINT("Passes: " + valuePasses).
		}
		
		//Sets the inclination
		SET inclination TO inclinationShift.
	
	
	//----------------------------------------------------\
	//Iterate the meanShift-------------------------------|
		SET valuePasses TO 0.
		SET lastDir TO "increase".	
		LOCAL meanShift IS 0.
		
		SET impactCoords TO predictImpactCoords(_interceptAltitude, targetHeight + stopAltitude, inclination, 0).
		LOCAL forwardSep IS wrap360(_coordinates:LNG - impactCoords:LNG).
		LOCAL backSep IS wrap360(impactCoords:LNG - _coordinates:LNG).

		LOCAL hasPassedInitial IS FALSE.
		UNTIL (valuePasses > 10) {
			SET forwardSep TO wrap360(_coordinates:LNG - impactCoords:LNG).
			SET backSep TO wrap360(impactCoords:LNG - _coordinates:LNG).	

			//Increases/decreases meanShift to get accurate value
			IF(hasPassedInitial){
				IF(forwardSep < backSep){
					IF lastDir = "decrease" {
						SET valuePasses TO valuePasses + 1.
						SET lastDir TO "increase".
					}	
					SET meanShift TO meanShift + 10/2^valuePasses.
				}
				ELSE {
					IF lastDir = "increase" {
						SET valuePasses TO valuePasses + 1.
						SET lastDir TO "decrease".
					}
					SET meanShift TO meanShift - 10/2^valuePasses.
				}
			}
			ELSE {
				SET meanShift TO meanShift + 10.
				IF(forwardSep < backSep){ SET hasPassedInitial TO TRUE. }
			}

			//Gets the new impact coordinates
			SET impactCoords TO predictImpactCoords(_interceptAltitude, targetHeight + stopAltitude, inclination, wrap360(meanShift)).
			
			//Output info
			CLEARSCREEN.
			PRINT("Impact lng  : " + impactCoords:LNG).
			PRINT("Target lng : " + _coordinates:LNG).
			PRINT("---------------------------------").
			PRINT("Shift : " + meanShift).
			PRINT("Passes: " + valuePasses).
		}
	
	
	//----------------------------------------------------\
	//Transition to target orbit--------------------------|
		RUNPATH("basic_functions/circularManeuver.ks", _interceptAltitude, meanShift/(360/SHIP:ORBIT:PERIOD), inclination, FALSE).
	

	//SAS ON.
	//RUNPATH("tester.ks").
	

	UNTIL(TRUE){
		
		
		SET impactCoords TO getImpactCoords(targetHeight).
		SET timeToImpact TO getImpactTime(targetHeight).	

		CLEARSCREEN.
		PRINT("Current lat : " + SHIP:GEOPOSITION:LAT).
		PRINT("Current lng : " + SHIP:GEOPOSITION:LNG).
		PRINT("---------------------------------").	
		PRINT("Impact lat  : " + impactCoords:LAT).
		PRINT("Impact lng  : " + impactCoords:LNG).
		PRINT("---------------------------------").
		PRINT("Time until impact : " + timeToImpact).

		WAIT 0.1.
	}	
	
	
	
	//Do a warp somewhere.
	//----------------------------------------------------\
	//Ensure correct velocity direction-------------------|
		//Use modVelocity with a 0.01 time limit?
		//Seems like a bit of a hack though, how about a separate function that returns after 1 run-through? 
		//Thus call it as much as you want
	
	//----------------------------------------------------\
	//Reduce horizontal velocity above target-------------|
		LOCAL base_acceleration IS SHIP:AVAILABLETHRUST/SHIP:MASS. //Mass in metric tonnes
	
		//Projects the relative position and velocity vectors onto the plane normal to the target's 'up' vector
		//NEED TO AVOID USING TARGET, MUST USE _COORDINATES INSTEAD
		LOCK horizontalVelocity TO (SHIP:VELOCITY:SURFACE - TARGET:VELOCITY:SURFACE) - (((SHIP:VELOCITY:SURFACE - TARGET:VELOCITY:SURFACE)*TARGET:UP:VECTOR)/TARGET:UP:VECTOR:MAG^2)*TARGET:UP:VECTOR. //Should maybe include target:surfaceVel evne though its 0?
		LOCK horizontalVelocity TO SHIP:VELOCITY:SURFACE - ((SHIP:VELOCITY:SURFACE*TARGET:UP:VECTOR)/TARGET:UP:VECTOR:MAG^2)*TARGET:UP:VECTOR. //Should maybe include target:surfaceVel evne though its 0?
		LOCK horizontalDistance TO (TARGET:POSITION - SHIP:POSITION) - (((TARGET:POSITION - SHIP:POSITION)*TARGET:UP:VECTOR)/TARGET:UP:VECTOR:MAG^2)*TARGET:UP:VECTOR.	

		LOCK stopDistance TO (horizontalVelocity:MAG^2)/(2*base_acceleration).
		
		
		LOCAL uv IS VECDRAWARGS(TARGET:POSITION,TARGET:UP:VECTOR*2000000,BLUE,"Landing position",1,TRUE).
		LOCAL hv IS VECDRAWARGS(SHIP:POSITION,horizontalDistance,RED,"Horizontal distance",1,TRUE).
		LOCK uv TO VECDRAWARGS(TARGET:POSITION,TARGET:UP:VECTOR*2000000,BLUE,"Landing position",1,TRUE).
		LOCK hv TO VECDRAWARGS(SHIP:POSITION,horizontalDistance,RED,"Horizontal distance",1,TRUE).
		
		SAS ON.
		LOCK STEERING TO smoothRotate((-horizontalVelocity):DIRECTION).
		UNTIL(horizontalDistance:MAG <= stopDistance){
			CLEARSCREEN.
			PRINT("Time to burn : " + ((horizontalDistance:MAG - stopDistance)/horizontalVelocity:MAG)).		
		}
		RUNPATH ("basic_functions/nodeBurn.ks", 0, horizontalVelocity:MAG, -horizontalVelocity).
		CLEARVECDRAWS().
		LOCK STEERING TO smoothRotate((-SHIP:VELOCITY:SURFACE):DIRECTION).
		WAIT 5.

	
	
	//----------------------------------------------------\
	//Perform the landing---------------------------------|


//--------------------------------------------------------------------------\
//								Program end					   				|
//--------------------------------------------------------------------------/


	//Returns user control
	SET SHIP:CONTROL:NEUTRALIZE to TRUE.
	SAS OFF.
	RCS OFF.
	
	//Unlock all variables		
	UNLOCK STEERING.
	UNLOCK THROTTLE.

	CLEARVECDRAWS().
	WAIT 1.
	

//------------------------------------------------------------------------------------------------------\
//												FUNCTIONS												|
//------------------------------------------------------------------------------------------------------/	
	

	FUNCTION wrap360{
		PARAMETER _angle.
		IF(_angle < 0){ RETURN _angle + 360. }
		ELSE IF(_angle > 360 ){ RETURN _angle - 360. }
		RETURN _angle.
	}

	FUNCTION lngWrap360 {
		PARAMETER _angle.
		IF(_angle < -180){ RETURN _angle + 360. }
		ELSE IF(_angle > 180 ){ RETURN _angle - 360. }
		RETURN _angle.
	}
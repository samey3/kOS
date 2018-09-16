	@lazyglobal OFF.
	RUNONCEPATH("lib/GUI_IO.ks").



//Atmo bodies:
//Can use a really lowered periapsis, enough that the current geo pos will be the landing coordinates (enough forward vel to match it) ,or go 0 horizontal vel?
//Thus can drop straight down onto the position with no horizontal affect from the atmosphere.
//Can also use parachutes accurately this way.

//Use time to 10k, add that lng to targCoord lng, find new geoposition, use that for initial corrections.


	CLEARSCREEN.
	LOCK STEERING TO SHIP:FACING.
	LOCK THROTTLE TO 0.
	UNLOCK STEERING.
	UNLOCK THROTTLE.
	

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	//If none chosen, GUI load
	PARAMETER _coordinates IS selectCoordinates().
		//If it returned a vessel
		LOCAL targetCraft IS 0.
		IF(_coordinates:ISTYPE("Vessel")){
			SET targetCraft TO _coordinates.
			SET _coordinates TO _coordinates:GEOPOSITION.
		}
		
		//Records the desired, in atmosphere it must overshoot a bit
		LOCAL initialCoordinates IS _coordinates.
		IF(SHIP:BODY:ATM:EXISTS){
			//Split the 13 degree based on the inclination ratio
			SET _coordinates TO LATLNG(_coordinates:LAT, _coordinates:LNG + 13). }
			
	PARAMETER _interceptAltitude IS SHIP:BODY:RADIUS - 50000.
	
	
//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/


	RUNONCEPATH("lib/impactProperties.ks").
	RUNONCEPATH("lib/shipControl.ks").
	RUNONCEPATH("lib/math.ks").
	RUNONCEPATH("lib/gameControl.ks").


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
		WAIT 1.

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
	
	
	//----------------------------------------------------\
	//Warp to corrections---------------------------------|
	
	
		SET _coordinates TO initialCoordinates.
		
		LOCAL base_acceleration IS SHIP:AVAILABLETHRUST/SHIP:MASS. //Mass in metric tonnes
		LOCAL timeToAbove IS getImpactTime(targetHeight + stopAltitude).
		LOCAL pre_surfaceVelocity IS projectToPlane(VELOCITYAT(SHIP, TIME:SECONDS + timeToAbove):SURFACE, (_coordinates:POSITION - BODY:POSITION)).
		LOCAL pre_burnTime IS pre_surfaceVelocity:MAG/base_acceleration.		
		LOCK STEERING TO smoothRotate(RETROGRADE).
		
		IF(SHIP:BODY:ATM:EXISTS){
			warpTime(timeToAbove - pre_burnTime - 60). }
		ELSE {
			warpTime(timeToAbove - pre_burnTime - 30). }
		//60 atmosphere, 30 vacuum 
		
	//----------------------------------------------------\
	//Ensure correct velocity direction-------------------|	
		IF(SHIP:BODY:ATM:EXISTS){
			RUNPATH("basic_functions/modTrajectory.ks", _coordinates, 0, 10). }
		ELSE {
			RUNPATH("basic_functions/modTrajectory.ks", _coordinates, 0, 20). }
		//10 atmosphere, 20 vacuum	

	//----------------------------------------------------\
	//Reduce horizontal velocity above target-------------|
		RUNPATH("basic_functions/stopAtVector.ks", _coordinates).	
	
	//----------------------------------------------------\
	//Perform the landing---------------------------------|
		RUNPATH ("basic_functions/suicideBurn.ks", targetCraft).
		
		LOCAL wv IS VECDRAWARGS(_coordinates:POSITION, (_coordinates:POSITION - BODY:POSITION):NORMALIZED*1000,GREEN,"Landing position",1,TRUE).


//--------------------------------------------------------------------------\
//								Program end					   				|
//--------------------------------------------------------------------------/


	//Returns user control
	SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
	SAS OFF.
	RCS OFF.
	
	//Unlock all variables		
	UNLOCK STEERING.
	UNLOCK THROTTLE.

	//CLEARVECDRAWS().
	WAIT 1.
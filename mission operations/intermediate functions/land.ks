	@lazyglobal OFF.
	SET STAGE_ID TO "LAND_0".
	CLEARSCREEN.
	

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _landingLocation IS 0. //If 0, land anywhere. If 1, select location. If anything else, use the value given (will be geocoordinates)	
	PARAMETER _interceptAltitude IS SHIP:BODY:RADIUS - 50000. //The 'periapsis' used for impact location prediction. Would relate to angle of attack on atmospheric entry.
	
	
//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/


	RUNONCEPATH("lib/impactProperties.ks").
	RUNONCEPATH("lib/shipControl.ks").
	RUNONCEPATH("lib/math.ks").
	RUNONCEPATH("lib/gameControl.ks").
	RUNONCEPATH("lib/gui.ks").


//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/	
	
	
	//Find landing location
	LOCAL res IS 0.
		IF(_landingLocation = 0){ SET res TO LATLNG(0,0). }
		ELSE IF(_landingLocation = 1){ SET res TO selectCoordinates(). }
		ELSE { SET res TO _landingLocation. }
			
		LOCAL _targCraft IS 0.
		LOCAL _coordinates IS 0.
		IF(res:ISTYPE("Vessel")){
			SET _targCraft TO res.
			SET _coordinates TO res:GEOPOSITION.
		}
		ELSE {
			SET _coordinates TO res.
		}
	
	//Impact prediction variables	
	LOCAL timeToImpact IS 0.
	LOCAL targetHeight IS _coordinates:TERRAINHEIGHT.
	LOCAL inclination IS 0.
	LOCAL stopAltitude IS 10000. //Aim for initial 'impact' 10Km above the target. //Could base on ratios compared to Kerbin gravity


//--------------------------------------------------------------------------\
//							 Reboot conditions					   			|
//--------------------------------------------------------------------------/
	
	
	//Final periapsis must dip below surface
	//IF(willImpact(SHIP)){	
	//	PRINT ("Operation conditions not met ( " + SCRIPTPATH():NAME + " ).").
	//	PRINT ("Rebooting. . ."). 
	//	WAIT 3. REBOOT.
	//}
	
	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/





	//MANEUVER IT TO A FLAT, CIRCULAR ORBIT FIRST.

	//#######################################################################
	//#																		#
	//# If the vessel is in orbit, de-orbit it first						#
	//#																		#
	//#######################################################################
		SET STAGE_ID TO "LAND_1".
		IF(willImpact(SHIP) = FALSE){
			LOCAL targCoords IS _coordinates.
			IF(SHIP:BODY:ATM:EXISTS AND SHIP:BODY:ATM:SEALEVELPRESSURE >= 0.3){
				SET targCoords TO LATLNG(targCoords:LAT, targCoords:LNG + 13).
			}
			
			//----------------------------------------------------\
			//Iterate the latitude--------------------------------|
				LOCAL valuePasses IS 0.
				LOCAL lastDir IS "increase".
				LOCAL inclinationShift IS 0.
				LOCAL impactCoords IS predictImpactCoords(_interceptAltitude, targetHeight + stopAltitude, inclinationShift, 0).
				
				UNTIL (valuePasses > 10) {
					IF(impactCoords:LAT < targCoords:LAT){
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
					PRINT("Target lat : " + targCoords:LAT).
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
				LOCAL forwardSep IS wrap360(targCoords:LNG - impactCoords:LNG).
				LOCAL backSep IS wrap360(impactCoords:LNG - targCoords:LNG).

				LOCAL hasPassedInitial IS FALSE.
				UNTIL (valuePasses > 10) {
					SET forwardSep TO wrap360(targCoords:LNG - impactCoords:LNG).
					SET backSep TO wrap360(impactCoords:LNG - targCoords:LNG).	

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
					PRINT("Target lng : " + targCoords:LNG).
					PRINT("---------------------------------").
					PRINT("Shift : " + meanShift).
					PRINT("Passes: " + valuePasses).
				}
			
			
			//----------------------------------------------------\
			//Transition to target orbit--------------------------|
				RUNPATH("mission operations/_to_remove/circularManeuver.ks", _interceptAltitude, meanShift/(360/SHIP:ORBIT:PERIOD), inclination, FALSE).
				//CAN WE GET RID OF THIS
				WAIT 1.
		}

	
	//#######################################################################
	//#																		#
	//# Follow trajectory and correct sideways (perpendicular) error		#
	//#	if a landing location is specified									#
	//#																		#
	//#######################################################################
		SET STAGE_ID TO "LAND_2".
		//If a landing location was chosen
		IF(_landingLocation <> 0){		
		
			//----------------------------------------------------\
			//Variables-------------------------------------------|			
				//Horizontal speed, distance, and stopping distance
				//These are used for waiting until the burn
				LOCAL LOCK planeNormalVector TO (_coordinates:POSITION - BODY:POSITION).
				LOCAL LOCK horizontalVector TO projectToPlane((_coordinates:POSITION - SHIP:POSITION), planeNormalVector).
				
				LOCAL initialHorizontalVector IS projectToPlane((_coordinates:POSITION - SHIP:POSITION), planeNormalVector):NORMALIZED.
					LOCAL LOCK horizontalSpeed TO scalarProjection(SHIP:VELOCITY:SURFACE, initialHorizontalVector).
					LOCAL LOCK horizontalDistance TO scalarProjection((_coordinates:POSITION - SHIP:POSITION), initialHorizontalVector).
											
					//LOCAL LOCK horizontalVelocity TO projectToPlane(SHIP:VELOCITY:SURFACE, planeNormalVector).
							
											
				LOCAL LOCK stopDistance TO (-(horizontalSpeed^2)/(2*(-SHIP:AVAILABLETHRUST/SHIP:MASS))).

		
			//----------------------------------------------------\
			//Perform corrections---------------------------------|	
				RCS ON.
				LOCK STEERING TO SRFRETROGRADE.
		
				//IF no atmo, use RCS. If sufficient atmo, use vessel itself
				IF(SHIP:BODY:ATM:EXISTS AND SHIP:BODY:ATM:SEALEVELPRESSURE >= 0.3){
					//Initial glide correction code in-atmosphere
					UNTIL (horizontalDistance <= (0.85*stopDistance)){		
						CLEARSCREEN.
						PRINT("Stop distance : " + stopDistance).
						PRINT("Distance to burn : " + (horizontalDistance - 0.85*stopDistance)).			
						//Do some horizontal gliding corrections
						//We are allowed to reference Trajectories addon in here
					}
				}
				ELSE{
					//Should we make it wait until a specific time for this?
					RUNPATH("mission operations/_to_remove/modTrajectory.ks", _coordinates, 0, 20).
					
					//Wait until burn
					UNTIL (horizontalDistance <= (0.85*stopDistance)){		
						CLEARSCREEN.
						PRINT("Stop distance : " + stopDistance).
						PRINT("Distance to burn : " + (horizontalDistance - 0.85*stopDistance)).			
					}
				}	
		}
	
	
	//#######################################################################
	//#																		#
	//# Reduce parallel difference between predicted and desired impact		#
	//#																		#
	//#######################################################################
		SET STAGE_ID TO "LAND_4".
		//If a landing location was chosen
		IF(_landingLocation <> 0){	

			//----------------------------------------------------\
			//Variables-------------------------------------------|
				LOCK planeNormalVector TO (_coordinates:POSITION - BODY:POSITION).
				LOCAL initialHorizontalVector IS projectToPlane((_coordinates:POSITION - SHIP:POSITION), planeNormalVector):NORMALIZED.
				LOCAL LOCK impactDifference TO scalarProjection((getImpactCoords():POSITION - _coordinates:POSITION), initialHorizontalVector).
				
			
			//----------------------------------------------------\
			//Perform the burn------------------------------------|		
				LOCK STEERING TO SRFRETROGRADE.
				LOCK THROTTLE TO 1.
				//Until error is sufficiently small, or most horizontal velocity has been burned off
				UNTIL (impactDifference < 100 OR VANG(projectToPlane(SRFRETROGRADE:VECTOR, planeNormalVector), initialHorizontalVector) < 90){		
					CLEARSCREEN.
					PRINT("Difference : " + impactDifference).
				}
				LOCK THROTTLE TO 0.					
		}
		
	
	//#######################################################################
	//#																		#
	//# Perform landing														#
	//#																		#
	//#######################################################################	
		SET STAGE_ID TO "LAND_5".
		
		LOCAL paramObj IS 0.
		IF(_targCraft <> 0){ SET paramObj TO _targCraft. }
		ELSE IF(_coordinates <> 0){ SET paramObj TO _coordinates. }
		//Else leave as 0
		
		//Pass in the parameter (vessel, geocoordinates, or 0)
		RUNPATH ("mission operations/basic functions/suicideBurn.ks", paramObj).
		

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

	WAIT 1.
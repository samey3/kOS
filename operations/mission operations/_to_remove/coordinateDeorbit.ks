	
	@lazyglobal OFF.
	CLEARSCREEN.
	

//--------------------------------------------------------------------------\
//								 Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _coordinates.
	PARAMETER _interceptAltitude.
	

//--------------------------------------------------------------------------\
//								 Variables					   				|
//--------------------------------------------------------------------------/


	LOCAL valuePasses IS 0.
	LOCAL lastDir IS "increase".
	LOCAL inclinationShift IS 0.
	LOCAL impactCoords IS predictImpactCoords(_interceptAltitude, targetHeight + stopAltitude, inclinationShift, 0).

	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	//----------------------------------------------------\
	//Iterate the latitude--------------------------------|
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
		RUNPATH("operations/mission operations/_to_remove/circularManeuver.ks", _interceptAltitude, meanShift/(360/SHIP:ORBIT:PERIOD), inclination, FALSE).
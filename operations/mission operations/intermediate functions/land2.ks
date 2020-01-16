	
	//Should the landingLocation = 1 GUI menu be removed?
	//Really, the functionality is already given by missionBuilder, so just remove it
	//HOWEVER, no changes are required to make it work
	
	
	
	//Remember, use bounding boxes bottomAlt for our ship.
	//When other vessel loads, check for a pad tag (should this be able to be changed? sure.)
	
	
	//Can pass in the target vessel and part tag to the landing burn script.
	
	//set refEntity to 0.
	//If theres a vessel defined,
	//	If theres a tag defined
	//		Iterate all parts for the tag
	//		If found, set refEntity to part, break
	//		Else not found, set refEntity to ship
	//	Else no tag, set refEntity to ship
	//}
	//
	//Base decisions on if refEntity = 0
	
	//Basically, if a vessel part or vessel is defined DURING THE LANDING BURN SCRIPT,
	//NOT THIS ONE, then there isn't really a situation where we DONT want to land on it.
	
	//Landing burn script: pass in: coordinates, vessel, vessel tag?
	//What if coords AND vessel?
	
	//Well we've already split vessel apart if we passed one in to the builder,
	//So coords and vessel in the same spot
	
	//Coordinates would be the center of the vessel,
	//But if vessel (and optionally tag defind), we want to use that for our center landing location
	//So landing script uses vessel coordinates, and landing burn script can use the exact part-tag coordinates
	
	//So on vessel unpack, set the landingCoordinates to the partTagged coordinates
	//Adjust the landing altitude
	//And that should be it
	
	
	
	
	//CONFIRMED
	//USES RELMIN:Z
	
	//either:
	//On suicide burn script start/actual burn start, deploy gears
	//Take both height measurments on loading of target?
	//What about regular, non-vessellanding?
	
	//Define a safe deploy time, and set the vehicleLowerHalfHeight to the new value
	//This will be used in the suicideBurn script.
	
	
	
	@lazyglobal OFF.
	CLEARSCREEN.
	

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _landingLocation. //Geocoordinates, or 0 (no location chosen)
	PARAMETER _landOnVessel.
	PARAMETER _landVesselPartTag. //Use the central landing part, e.g. docking port, pad panel, etc.
	PARAMETER _interceptAltitude. //The 'periapsis' used for impact location prediction. Would relate to angle of attack on atmospheric entry.
	PARAMETER _reentryOnly.
	PARAMETER _aimAhead.
	PARAMETER _reentryBurn.
	PARAMETER _burnEndAngle.
	PARAMETER _landingBurn.

	
//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/


	//RUNONCEPATH("lib/impactProperties.ks").
	//RUNONCEPATH("lib/shipControl.ks").
	//RUNONCEPATH("lib/math.ks").
	//RUNONCEPATH("lib/gameControl.ks").
	//RUNONCEPATH("lib/gui.ks").
	
	RUNONCEPATH("lib/impactProperties.ks").


//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/	
	
	
	//Impact prediction variables	
	//LOCAL timeToImpact IS 0.
	//LOCAL targetHeight IS _coordinates:TERRAINHEIGHT.
	//LOCAL inclination IS 0.
	//LOCAL stopAltitude IS 10000. //Aim for initial 'impact' 10Km above the target. //Could base on ratios compared to Kerbin gravity
	
	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	//----------------------------------------------------\
	//Reentry---------------------------------------------|
		//If no landing location set, just deorbit
		IF(_landingLocation = 0){
			//If orbiting, deorbit
			IF(willImpact(SHIP) = FALSE){ RUNPATH("operations/mission operations/_to_remove/circularManeuver.ks", _interceptAltitude, 60, 0, FALSE). }
			
			//Take the predicted impact coordinates, and subtract the aimAhead to set a target landing point
			LOCAL rotateAxis IS VCRS(getImpactCoords(SHIP:BODY:RADIUS + 10000):POSITION - SHIP:BODY:POSITION, getImpactCoords(SHIP:BODY:RADIUS):POSITION - SHIP:BODY:POSITION).
			SET _landingLocation TO SHIP:BODY:GEOPOSITIONOF((getImpactCoords(SHIP:BODY:RADIUS):POSITION - SHIP:BODY:POSITION)*ANGLEAXIS(_aimAhead, rotateAxis)).	
		}
		//Else if a landing location was given
		ELSE{
			//If orbiting, deorbit to the desired coordinates + _aimAhead degrees
			IF(willImpact(SHIP) = FALSE){
				//Angular momentum vector
				LOCAL rotateAxis IS VCRS(VCRS(BODY:NORTHPOLEVECTOR, _landingCoordinates:POSITION - SHIP:BODY:POSITION), _landingCoordinates:POSITION - SHIP:BODY:POSITION).
				LOCAL impactCoordinates IS (_landingCoordinates:POSITION - SHIP:BODY:POSITION)*ANGLEAXIS(_aimAhead, rotateAxis).
				RUNPATH("operations/mission operations/_to_remove/coordinateDeorbit.ks", impactCoordinates, _interceptAltitude, SHIP:BODY:RADIUS).
			}
		}

	IF(_reentryOnly = FALSE){
	
		//Coast
		
		//Reentry burn
		
		//Landing burn
	}


	//Re-enter
	//-Iterate if coordiantes, else just immediately deorbit
	
	//If NOT reenterOnly (e.g. mission builder will now finish. Could run spaceplane code after in air_operations)
	//	coast
	//	IF reentryBurn, do burn
	//	IF landingBurn, do burn
	//	WAIT UNTIL SHIP:STATUS splashed or landed
	//}
	//
	//DONE! Mission builder is finished.
	
	
	
	
	
	//DEORBIT/REENTRY (Uses aimAhead)
		//Deorbit using aimAhead
	
	//if(!reentryOnly){
		//reentry burn (Uses eentryburn, burnEndAngle)
		//if(reentryBurn){
			//Lock steering to initial landing surface/orbital velocity? (if constant lock and your location is BEHIND you, would flip rocket, so set it once then don't change)
			//What angular dist away from TARGET_LANDING_SPOT do we want to finish the reentry burn? (burnEndAngle)
			//Define plane again on the landing location, use same method there.
			//Find when to start the burn
			//Start burn
			//End the burn once impact location passes the plane
		//}
		
		//Landing burn (Uses landingBurn)
		//if(landingBurn){
			//enter suicideBurn.ks
		//}
	//}
	//Done!



		

//--------------------------------------------------------------------------\
//								Program end					   				|
//--------------------------------------------------------------------------/


	CLEARVECDRAWS().
	SAS OFF.
	RCS OFF.
	UNLOCK STEERING.
	UNLOCK THROTTLE.
	SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
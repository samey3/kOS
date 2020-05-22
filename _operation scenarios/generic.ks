	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks").
	
	//Variables
		LOCAL parameterLex IS LEXICON().
			//Basic parameters
			SET parameterLex["entity"] TO KERBIN. 										//Vessel("vessel name")
			SET parameterLex["action"] TO "orbit". 										//orbit, rendezvous, dock, land, launch
			SET parameterLex["fastbuild"] TO FALSE. 									//TRUE, FALSE
			SET parameterLex["resetcontrols"] TO TRUE. 									//TRUE, FALSE
			
			//Docking
			SET parameterLex["targdocktag"] TO "". 										//Empty, "random", "tag name"
			SET parameterLex["selfdocktag"] TO "". 										//Empty, "random", "tag name"
			SET parameterLex["standoffDistance"] TO 100.
			
			//Landing
			SET parameterLex["landingtarget"] TO KERBIN:GEOPOSITIONLATLNG(0,0). 		//Geoposition, vessel, 0 default (no landing coordinates)
			SET parameterLex["landVesselPartTag"] TO "". 								//Part tag on target vessel to use for pad altitude and center reference
			SET parameterLex["interceptaltitude"] TO 0.
			SET parameterLex["reenteronly"] TO FALSE. 									//Set to true if you would like to switch to spaceplane code upon reentering
			SET parameterLex["aimahead"] TO 0. 											//How far ahead of final landing location we want to be on for our initial trajectory. e.g. 0 for direct impact (i.e. no reentry burn). 
			SET parameterLex["reentryburn"] TO FALSE. 									//Reentry burn to adjust impact coordinates to desired coordinates
			SET parameterLex["burnendangle"] TO 0. 										//Angle between vessel and impact location (body as center) at the end of the reentry burn
			SET parameterLex["landingburn"] TO FALSE.
			
			//Orbiting/launching
			SET parameterLex["semimajoraxis"] TO KERBIN:BODY:RADIUS + 100000.
			SET parameterLex["eccentricity"] TO 0.
			SET parameterLex["inclination"] TO 0.
			SET parameterLex["longitudeofascendingnode"] TO 0.
			SET parameterLex["argumentofperiapsis"] TO 0.
			SET parameterLex["trueanomaly"] TO 0.
			
		LOCAL airParameterLex IS LEXICON().
			//Basic parameters
			SET airParameterLex["action"] TO "takeoff". 								//takeoff, fly, land
			SET airParameterLex["fastbuild"] TO FALSE. 									//TRUE, FALSE
			SET airParameterLex["resetcontrols"] TO FALSE. 								//TRUE, FALSE
			
			//Takeoff
			SET airParameterLex["takeoffheading"] TO 90. 								//North[0], East[90], South[180], West[270]
			SET airParameterLex["climbaltitude"] TO 5000. 								//Altitude to climb to on takeoff
			SET airParameterLex["climbpitch"] TO 25. 									//Degrees off of horizon
			
			//Flying
			SET airParameterLex["flylocation"] TO KERBIN:GEOPOSITIONLATLNG(0,0).		//Geoposition to fly to
			SET airParameterLex["flyaltitude"] TO 5000.									//Altitude above the coordinates to fly to
			SET airParameterLex["flyspeed"] TO 200.										//Cruising speed of the craft
			SET airParameterLex["maxerror"] TO 300.										//Maximum error distance for the point to count as having been 'reached' by the craft
			
			//Landing
			SET airParameterLex["landinglocation"] TO KERBIN:GEOPOSITIONLATLNG(0,0). 	//Geoposition, 0 (no coordinates, land anywhere)
			SET airParameterLex["landingheading"] TO 90. 								//North[0], East[90], South[180], West[270]
			SET airParameterLex["landingspeed"] TO 40. 									//Speed to land at, varies per craft and body
			SET airParameterLex["descentdistance"] TO 6000. 							//Distance from location for start of descent

			
	//Custom events
		//ON(){
			//Code
			//PRESERVE.
		//}

	
	//Event listeners
		//addListener("BATTERIES_DEPLETED", {
		//	PRINT("hello").
		//}, TRUE). //True preserves the eventListener (it can handle the event again). False means it will only handle it once
		
	//Mission steps:
		configureVessel(). //Configured with a ship config. Call this again with a specific vessel name if e.g. rocket becomes a rover
		RUNPATH("operations/mission operations/missionBuilder.ks").
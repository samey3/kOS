	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks").
	
	//Variables
		LOCAL parameterLex IS LEXICON().
			//Basic parameters
			SET parameterLex["entity"] TO KERBIN. //Vessel("vessel name")
			SET parameterLex["action"] TO "orbit". //Orbit, rendezvous, dock, land, launch
			
			//Docking
			SET parameterLex["targdocktag"] TO "". //Empty, "random", "tag name"
			SET parameterLex["selfdocktag"] TO "". //Empty, "random", "tag name"
			SET parameterLex["standoffDistance"] TO 100.
			
			//Landing
			SET parameterLex["landingtarget"] TO KERBIN:GEOPOSITIONLATLNG(0,0). //Geoposition, vessel, 0 default (no landing coordinates)
			SET parameterLex["landVesselPartTag"] TO "". //Part tag on target vessel to use for pad altitude and center reference
			SET parameterLex["interceptaltitude"] TO 0.
			SET parameterLex["reenteronly"] TO FALSE. //Set to true if you would like to switch to spaceplane code upon reentering
			SET parameterLex["aimahead"] TO 0. //How far ahead of final landing location we want to be on for our initial trajectory. e.g. 0 for direct impact (i.e. no reentry burn). 
			SET parameterLex["reentryburn"] TO FALSE. //Reentry burn to adjust impact coordinates to desired coordinates
			SET parameterLex["burnendangle"] TO 0. //Angle between vessel and impact location (body as center) at the end of the reentry burn
			SET parameterLex["landingburn"] TO FALSE.
			
			//Orbiting/launching
			SET parameterLex["semimajoraxis"] TO KERBIN:BODY:RADIUS + 100000.
			SET parameterLex["eccentricity"] TO 0.
			SET parameterLex["inclination"] TO 0.
			SET parameterLex["longitudeofascendingnode"] TO 0.
			SET parameterLex["argumentofperiapsis"] TO 0.
			SET parameterLex["trueanomaly"] TO 0.
	
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
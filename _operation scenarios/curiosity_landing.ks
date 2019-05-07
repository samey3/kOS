	//Once this one is fleshed out, create a generic version that others can be based off of
	
	
	
	RUNONCEPATH("lib/mission.ks").
	RUNONCEPATH("lib/config.ks"). //Run this between missions if it changes from rocket to rover or something
	
	
	
	//Mission variables:
		LOCAL orbitLex IS LEXICON().
			SET orbitLex["semimajoraxis"] TO 1686750.
			SET orbitLex["eccentricity"] TO 0.60.
			SET orbitLex["inclination"] TO 10.
			SET orbitLex["longitudeofascendingnode"] TO 30.
			SET orbitLex["argumentofperiapsis"] TO 20.
			SET orbitLex["trueanomaly"] TO 60.
	
	//Mission staging:
		//Lexicon
		//E.g.
		//["1_LAND_START", "1", "DECOUPLE"]
		//["1_LAND_START", "2", "EXTEND"]
		//["1_LAND_START", "3", "TAKE SAMPLE"]
		//["1_GLIDE", "4", "DEPLOY"]
		//["1_BURN_START""5", "CUT PARACHUTE"]
		
		//Left refers to the staging event seen, middle is tagged parts, right is action
		
		//Better?
		
		//[
		//	"1_LAND_START",
		//	Lexicon: [
		//		"1", "DECOUPLE",
		//		"2", "EXTEND"
		//	]
		//]
		
		//A lexicon of lexicons; top level lexicon for event id, then next level is
		//All events associated with it
		
		//How to efficiently declare this and pass it to the ON change?
		//Also, might not need a second processor for this since it already triggers ON change.
		
		//Perhaps the ON change will always check a lexicon variable, and we can change it during run-time
		//Will it need to be a global variable though?
	
	//Mission steps:
	
		configureVessel().
		RUNPATH("mission operations/missionBuilder.ks", DUNA, "land", LATLNG(0, -146.5116), 0).
		//configureVessel("someName"). //This will create a new entry right now
		//RUNPATH("ground operations/groundBuilder.ks", DUNA, "drive", LATLNG(0, 0)).
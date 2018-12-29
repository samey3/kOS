

//Manual or from files
FUNCTION selectCoordinates {	
	LOCAL chosenCoordinates IS 0.
	LOCAL landOnTop IS TRUE.
	LOCAL dataPath IS "Data/Saved coordinates/" + SHIP:BODY:NAME + ".txt".
	
	LOCAL gui IS GUI(800,140).	
	LOCAL titleLabel IS gui:ADDLABEL("Select landing location").
	LOCAL selectedLabel IS gui:ADDLABEL("Selected : None").
		SET titleLabel:STYLE:ALIGN TO "CENTER".
	LOCAL okButton IS gui:ADDBUTTON("OK").

	LOCAL hLayout IS gui:ADDHLAYOUT().
	//{
		LOCAL vFilesBox IS hLayout:ADDVBOX().	
		//{
			LOCAL filesLabel IS vFilesBox:ADDLABEL("Saved locations").
				SET filesLabel:STYLE:ALIGN TO "CENTER".
			LOCAL fileCoordinatesBox IS vFilesBox:ADDVLAYOUT().
			//{			
				//If the file does not exist, create it
				IF(NOT VOLUME(0):EXISTS(dataPath)){
					WRITEJSON(LIST(), dataPath). }
				SET coordinateList TO READJSON(dataPath).
				FOR dataLine IN coordinateList {
					LOCAL splitData IS dataLine:SPLIT(",").
					SET fileCoordinatesBox:ADDBUTTON(splitData[0]):ONCLICK TO { SET chosenCoordinates TO LATLNG(splitData[1]:TOSCALAR,splitData[2]:TOSCALAR). SET selectedLabel:TEXT TO ("Selected : " + splitData[0]). }.		
				}
			//}
		//}
		
		hLayout:ADDSPACING(5).
		
		LOCAL vVesselsBox IS hLayout:ADDVBOX().	
		//SET vVesselsBox:STYLE:WIDTH TO 300.
		//{
			LOCAL vesselsLabel IS vVesselsBox:ADDLABEL("Landed vessels").
				SET vesselsLabel:STYLE:ALIGN TO "CENTER".
			LOCAL vesselCoordinatesBox IS vVesselsBox:ADDVLAYOUT().
			//{
				//This required a weird workaround, it kept setting it to random asteroids
				LOCAL shipLexicon IS LEXICON().
				LIST TARGETS IN vesselList.
				FOR vessel IN vesselList {
					IF(vessel:BODY = SHIP:BODY AND (vessel:STATUS = "LANDED" OR vessel:STATUS = "SPLASHED")){
						SET shipLexicon[vessel:NAME] TO vessel.	
					}
				}
				FOR vesselKey IN shipLexicon:KEYS {
					LOCAL vesselButton IS vesselCoordinatesBox:ADDBUTTON(vesselKey).
					SET vesselButton:ONCLICK TO { SET chosenCoordinates TO shipLexicon[vesselButton:TEXT]. SET selectedLabel:TEXT TO ("Selected : " + vesselButton:TEXT). }.		

					//SET vesselCoordinatesBox:ADDBUTTON(vesselKey):ONCLICK TO { SET chosenCoordinates TO shipLexicon[vesselKey]. SET selectedLabel:TEXT TO ("Selected : " + vesselKey). }.		
				}
			//}
		//}
	//}
	gui:SHOW().
	
	
	WAIT UNTIL(okButton:TAKEPRESS AND chosenCoordinates <> 0).
		gui:HIDE().
		
		//Return just the coordinates
		IF(chosenCoordinates:ISTYPE("Vessel") AND landOnTop = FALSE){
			SET chosenCoordinates TO chosenCoordinates:GEOPOSITION.
		}		

		//Return the vessel itself
		RETURN chosenCoordinates.
}




FUNCTION getFilesFromPath {

}
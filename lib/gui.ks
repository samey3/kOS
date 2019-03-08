//This will contain the various GUI windows that may pop up. Removes large chunks of GUI code from functionality scripts.



//--------------------------------------------------------------------------\
//								Mission builder				   				|
//--------------------------------------------------------------------------/


	//If it is an asteroid, must make sure it is being tracked before returning
	FUNCTION buildMission{
	
		//Is set when the build button is clicked
		LOCAL finished IS FALSE.
	
		//Values to pass later on
		LOCAL chosenEntity IS KERBIN.
		LOCAL chosenAction IS "land".
		LOCAL landCoordinates IS KERBIN:GEOPOSITIONLATLNG(0,0).
		LOCAL orbitLex IS LEXICON(). //Does not need an entry for MNA (Mean enomaly at epoch, position in orbit)
			SET orbitLex["semimajoraxis"] TO 0.
			SET orbitLex["eccentricity"] TO 0.
			SET orbitLex["inclination"] TO 0.
			SET orbitLex["longitudeofascendingnode"] TO 0.
			SET orbitLex["argumentofperiapsis"] TO 0.
			SET orbitLex["trueanomaly"] TO RANDOM(). //Random point away from 0.
		
		
		//Intermediate variables
		LOCAL entityLexicon IS LEXICON().

		//Create the GUI
		LOCAL gui IS GUI(1200,140).	
			LOCAL titleLabel IS gui:ADDLABEL("Mission builder V1.0").
			LOCAL h_layout IS gui:ADDHLAYOUT().
	
		LOCAL buildButton IS gui:ADDBUTTON("Build and execute").
		SET buildButton:ONCLICK TO { 
			SET finished TO TRUE.
		}.
	
	
		//--------------------------------------------------------------------------\
		//								Entity select				   				|
		//--------------------------------------------------------------------------/
		
		
			LOCAL v_entitiesLayout IS h_layout:ADDHLAYOUT().
			LOCAL v_entities IS v_entitiesLayout:ADDVLAYOUT().
				//Add the label
				LOCAL entitiesLabel IS v_entities:ADDLABEL("Selected : Kerbin").		
					SET entitiesLabel:STYLE:ALIGN TO "CENTER".
					
				
				//###################################################################
				//							Entity buttons							#
				//###################################################################
				
					//Add the body/asteroid/vessel buttons
					LOCAL entityButton_box IS v_entities:ADDHBOX().
						//Set the on-change function
						SET entityButton_box:ONRADIOCHANGE TO {
							PARAMETER _button.
							
							//Clears any chosen values
							entityBox:CLEAR().
							landBox:CLEAR().
							v_orbitLayout:HIDE().
							v_landLayout:HIDE().
							SET chosenEntity TO KERBIN.							
							SET chosenAction TO 0.
							SET landCoordinates TO 0.
							SET entitiesLabel:TEXT TO ("Selected : Kerbin").
							SET actionsLabel:TEXT TO ("Selected : None").	
							SET landLabel:TEXT TO ("Selected : None").								
							SET savedButton:PRESSED TO FALSE.
							SET landedButton:PRESSED TO FALSE.
							SET customButton:PRESSED TO FALSE.
							SET customButton:PRESSED TO TRUE.
							SET buildbutton:ENABLED TO FALSE.
							
							//Reloads the entity list
							SET entityLexicon TO populateEntityLexicon(entityButton_box:RADIOVALUE).
							FOR entityKey IN entityLexicon:KEYS {
								LOCAL entityButton IS entityBox:ADDBUTTON(entityKey).
								SET entityButton:ONCLICK TO {
									SET chosenEntity TO entityLexicon[entityButton:TEXT].
									SET entitiesLabel:TEXT TO ("Selected : " + entityButton:TEXT).
									SET actionsLabel:TEXT TO ("Selected : None").
									v_orbitLayout:HIDE().
									v_landLayout:HIDE().
									SET savedButton:PRESSED TO FALSE.
									SET landedButton:PRESSED TO FALSE.
									SET customButton:PRESSED TO FALSE.
									SET customButton:PRESSED TO TRUE.
								}.
							}
						}.
					
				//######################################################################
					LOCAL bodyButton IS entityButton_box:ADDRADIOBUTTON("Bodies", TRUE).	
					SET bodyButton:ONCLICK TO {										
						landButton:SHOW(). rendezvousButton:HIDE(). dockButton:HIDE(). orbitButton:SHOW().
					}.
				//######################################################################
					LOCAL asteroidButton IS entityButton_box:ADDRADIOBUTTON("Asteroids", FALSE).	
					SET asteroidButton:ONCLICK TO {										
						landButton:HIDE(). rendezvousButton:SHOW(). dockButton:HIDE(). orbitButton:HIDE().
					}.
				//######################################################################
					LOCAL vesselButton IS entityButton_box:ADDRADIOBUTTON("Vessels", FALSE).	
					SET vesselButton:ONCLICK TO {										
						landButton:HIDE(). rendezvousButton:SHOW(). dockButton:SHOW(). orbitButton:HIDE().
					}.
				//######################################################################
				
									
				//Create the containing box
				LOCAL entityBox IS v_entities:ADDVBOX().				
					
			
		//--------------------------------------------------------------------------\
		//								Action select				   				|
		//--------------------------------------------------------------------------/	
			
			
			LOCAL v_actionsLayout IS h_layout:ADDHLAYOUT().
			LOCAL v_actions IS v_actionsLayout:ADDVLAYOUT().
				//Add the label
				LOCAL actionsLabel IS v_actions:ADDLABEL("Selected : Land").	
					SET actionsLabel:STYLE:ALIGN TO "CENTER".
					

				//###################################################################
				//							Action buttons							#
				//###################################################################
				
					//Create the containing box
					LOCAL actionBox IS v_actions:ADDVBOX().
				
				//######################################################################
					LOCAL landButton IS actionBox:ADDBUTTON("Land").	
					SET landButton:ONCLICK TO {
						SET chosenAction TO "land".
						SET actionsLabel:TEXT TO ("Selected : Land").
						SET landCoordinates TO chosenEntity:GEOPOSITIONLATLNG(0, 0).
						SET landLabel:TEXT TO ("Selected : " + landCoordinates).
						SET buildbutton:ENABLED TO TRUE.
						v_orbitLayout:HIDE().
						v_landLayout:SHOW().
						v_spacerLayout:HIDE().
					}.
				//######################################################################
					LOCAL rendezvousButton IS actionBox:ADDBUTTON("Rendezvous").	
					SET rendezvousButton:ONCLICK TO {
						SET chosenAction TO "rendezvous".
						SET actionsLabel:TEXT TO ("Selected : Rendezvous").
						SET buildbutton:ENABLED TO TRUE.
						v_orbitLayout:HIDE().
						v_landLayout:HIDE().
						v_spacerLayout:SHOW().
					}.
				//######################################################################
					LOCAL dockButton IS actionBox:ADDBUTTON("Dock").	
					SET dockButton:ONCLICK TO {
						SET chosenAction TO "dock".
						SET actionsLabel:TEXT TO ("Selected : Dock").
						SET buildbutton:ENABLED TO TRUE.
						v_orbitLayout:HIDE().
						v_landLayout:HIDE().
						v_spacerLayout:SHOW().
					}.
				//######################################################################
					LOCAL orbitButton IS actionBox:ADDBUTTON("Orbit").	
					SET orbitButton:ONCLICK TO {
						SET chosenAction TO "orbit".
						SET actionsLabel:TEXT TO ("Selected : Orbit").
						SET buildbutton:ENABLED TO TRUE.
						v_orbitLayout:SHOW().
						v_landLayout:HIDE().
						v_spacerLayout:HIDE().
					}.
				//######################################################################
				
				
				//Set the default state for 'bodies'
				landButton:SHOW(). rendezvousButton:HIDE(). dockButton:HIDE(). orbitButton:SHOW().
					
			
		//--------------------------------------------------------------------------\
		//						Landing location select				   				|
		//--------------------------------------------------------------------------/	
		
		
			LOCAL v_landLayout IS h_layout:ADDHLAYOUT(). v_landLayout:HIDE().
				SET v_landLayout:STYLE:WIDTH TO 500.
			LOCAL v_land IS v_landLayout:ADDVLAYOUT().
				//Add the label
				LOCAL landLabel IS v_land:ADDLABEL("Location : Kerbin:GEOPOSITIONLATLNG(0,0)").		
					SET landLabel:STYLE:ALIGN TO "CENTER".
					

			//###################################################################
			//							Location buttons						#
			//###################################################################
			
				//Add the body/asteroid/vessel buttons
				LOCAL landButton_box IS v_land:ADDHBOX().
				
			//######################################################################
				LOCAL savedButton IS landButton_box:ADDRADIOBUTTON("Saved locations", FALSE).	
				SET savedButton:ONCLICK TO {
					landBox:CLEAR().
					IF(chosenEntity <> 0){
						LOCAL path IS ("mission operations/data/saved coordinates/" + chosenEntity:NAME + ".txt").
						IF(NOT VOLUME(0):EXISTS(path)){ WRITEJSON(LIST(), path). } //If the file does not exist, create it
						
						SET coordinateList TO READJSON(path).
						FOR dataLine IN coordinateList {
							LOCAL splitData IS dataLine:SPLIT(",").
							SET landBox:ADDBUTTON(splitData[0]):ONCLICK TO { SET landCoordinates TO LATLNG(splitData[1]:TOSCALAR(0),splitData[2]:TOSCALAR(0)). SET landLabel:TEXT TO ("Selected : " + splitData[0]). }.		
						}
					}	
				}.
			//######################################################################
				LOCAL landedButton IS landButton_box:ADDRADIOBUTTON("Landed vessels", FALSE).	
				SET landedButton:ONCLICK TO {
					IF(chosenEntity <> 0){
						landBox:CLEAR().
						//This required a weird workaround, it kept setting it to random asteroids
						LOCAL shipLexicon IS LEXICON().
						LIST TARGETS IN vesselList.
						FOR vessel IN vesselList {
							IF(vessel:BODY = chosenEntity AND (vessel:STATUS = "LANDED" OR vessel:STATUS = "SPLASHED")){
								SET shipLexicon[vessel:NAME] TO vessel.	
							}
						}
						FOR vesselKey IN shipLexicon:KEYS {
							LOCAL vesselButton IS landBox:ADDBUTTON(vesselKey).
							SET vesselButton:ONCLICK TO { SET landCoordinates TO shipLexicon[vesselButton:TEXT]. SET landLabel:TEXT TO ("Selected : " + vesselButton:TEXT). }.		
						}
					}
				}.
			//######################################################################
				LOCAL customButton IS landButton_box:ADDRADIOBUTTON("Custom", TRUE).	
				SET customButton:ONCLICK TO {				
					landBox:CLEAR().
					
					landBox:ADDHLAYOUT().
					LOCAL lat_layout IS landBox:ADDHLAYOUT().
						lat_layout:ADDLABEL("Latitude"). lat_layout:ADDSPACING(10).
						LOCAL latField IS lat_layout:ADDTEXTFIELD("0").
							SET latField:STYLE:HSTRETCH TO FALSE.
							SET latField:STYLE:WIDTH TO 200.
							SET latField:ONCHANGE TO {
								PARAMETER _string.					
								SET landCoordinates TO chosenEntity:GEOPOSITIONLATLNG(latField:TEXT:TOSCALAR(0), longField:TEXT:TOSCALAR(0)).
								SET landLabel:TEXT TO ("Selected : " + landCoordinates).
							}.			
					LOCAL long_layout IS landBox:ADDHLAYOUT().
						long_layout:ADDLABEL("Longitude").
						LOCAL longField IS long_layout:ADDTEXTFIELD("0").
						SET longField:STYLE:HSTRETCH TO FALSE.
						SET longField:STYLE:WIDTH TO 200.
						SET longField:ONCHANGE TO {
							PARAMETER _string.					
							SET landCoordinates TO chosenEntity:GEOPOSITIONLATLNG(latField:TEXT:TOSCALAR(0), longField:TEXT:TOSCALAR(0)).
							SET landLabel:TEXT TO ("Selected : " + landCoordinates).
						}.
				}.
			//######################################################################
			
			
			//Create the containing box
			LOCAL landBox IS v_land:ADDVBOX().
				//Default population (custom location)
				LOCAL lat_layout IS landBox:ADDHLAYOUT().
					lat_layout:ADDLABEL("Latitude"). lat_layout:ADDSPACING(10).
					LOCAL latField IS lat_layout:ADDTEXTFIELD("0").
					SET latField:STYLE:HSTRETCH TO FALSE.
					SET latField:STYLE:WIDTH TO 200.
					SET latField:ONCHANGE TO {
						PARAMETER _string.					
						SET landCoordinates TO chosenEntity:GEOPOSITIONLATLNG(latField:TEXT:TOSCALAR(0), longField:TEXT:TOSCALAR(0)).
						SET landLabel:TEXT TO ("Selected : " + landCoordinates).
					}.			
				LOCAL long_layout IS landBox:ADDHLAYOUT().
					long_layout:ADDLABEL("Longitude").
					LOCAL longField IS long_layout:ADDTEXTFIELD("0").
					SET longField:STYLE:HSTRETCH TO FALSE.
					SET longField:STYLE:WIDTH TO 200.
					SET longField:ONCHANGE TO {
						PARAMETER _string.					
						SET landCoordinates TO chosenEntity:GEOPOSITIONLATLNG(latField:TEXT:TOSCALAR(0), longField:TEXT:TOSCALAR(0)).
						SET landLabel:TEXT TO ("Selected : " + landCoordinates).
					}.
					
			
	//--------------------------------------------------------------------------\
	//								Orbit select				   				|
	//--------------------------------------------------------------------------/	
	
	
		LOCAL v_orbitLayout IS h_layout:ADDHLAYOUT(). v_orbitLayout:HIDE().
			SET v_orbitLayout:STYLE:WIDTH TO 500.
		LOCAL v_orbit IS v_orbitLayout:ADDVLAYOUT().
			//Add the label
			LOCAL orbitLabel IS v_orbit:ADDLABEL("Input orbit parameters").		
				SET orbitLabel:STYLE:ALIGN TO "CENTER".
				
					
		//###################################################################
		//							Parameter fields						#
		//###################################################################
	
			//Create the containing box
			LOCAL orbitBox IS v_orbit:ADDVBOX().
	
		//######################################################################		
			LOCAL sma_layout IS orbitBox:ADDHLAYOUT().
				sma_layout:ADDLABEL("Semi-Major Axis").
				LOCAL smaField IS sma_layout:ADDTEXTFIELD("0").
				SET smaField:STYLE:HSTRETCH TO FALSE. SET smaField:STYLE:WIDTH TO 200.
				SET smaField:ONCHANGE TO {
					PARAMETER _string.					
					SET orbitLex["semimajoraxis"] TO smaField:TEXT:TOSCALAR(0).
				}.
		//######################################################################		
			LOCAL ecc_layout IS orbitBox:ADDHLAYOUT().
				ecc_layout:ADDLABEL("Eccentricity").
				LOCAL eccField IS ecc_layout:ADDTEXTFIELD("0").
				SET eccField:STYLE:HSTRETCH TO FALSE. SET eccField:STYLE:WIDTH TO 200.
				SET eccField:ONCHANGE TO {
					PARAMETER _string.					
					SET orbitLex["eccentricity"] TO eccField:TEXT:TOSCALAR(0).
				}.
		//######################################################################
			LOCAL inc_layout IS orbitBox:ADDHLAYOUT().
				inc_layout:ADDLABEL("Inclination").
				LOCAL incField IS inc_layout:ADDTEXTFIELD("0").
				SET incField:STYLE:HSTRETCH TO FALSE. SET incField:STYLE:WIDTH TO 200.
				SET incField:ONCHANGE TO {
					PARAMETER _string.					
					SET orbitLex["inclination"] TO incField:TEXT:TOSCALAR(0).
				}.
		//######################################################################
			LOCAL lan_layout IS orbitBox:ADDHLAYOUT().
				lan_layout:ADDLABEL("Longitude of ascending node").
				LOCAL lanField IS lan_layout:ADDTEXTFIELD("0").
				SET lanField:STYLE:HSTRETCH TO FALSE. SET lanField:STYLE:WIDTH TO 200.
				SET lanField:ONCHANGE TO {
					PARAMETER _string.					
					SET orbitLex["longitudeofascendingnode"] TO lanField:TEXT:TOSCALAR(0).
				}.
		//######################################################################
			LOCAL ap_layout IS orbitBox:ADDHLAYOUT().
				ap_layout:ADDLABEL("Argument of periapsis").
				LOCAL apField IS ap_layout:ADDTEXTFIELD("0").
				SET apField:STYLE:HSTRETCH TO FALSE. SET apField:STYLE:WIDTH TO 200.
				SET apField:ONCHANGE TO {
					PARAMETER _string.					
					SET orbitLex["argumentofperiapsis"] TO apField:TEXT:TOSCALAR(0).
				}.
		//######################################################################
		
		
	//--------------------------------------------------------------------------\
	//								  Spacer					   				|
	//--------------------------------------------------------------------------/	

	
		//Why isn't this working? May as well remove if you still cannot get it to work
		LOCAL v_spacerLayout IS h_layout:ADDHLAYOUT(). v_spacerLayout:SHOW().
			SET v_spacerLayout:STYLE:WIDTH TO 500.
			
			
	//--------------------------------------------------------------------------\
	//								  SHOW GUI					   				|
	//--------------------------------------------------------------------------/	
			
		
		//Shows the GUI
		SET bodyButton:PRESSED TO FALSE.
		SET bodyButton:PRESSED TO TRUE.
		gui:SHOW().
		
		//Waits until a valid configuration is chosen and the build button is clicked
		WAIT UNTIL(finished).
			gui:HIDE().
			
		//If rendezvousing with an asteroid, start tracking it so it does not disapear
		IF(chosenEntity:ISTYPE("SpaceObject") AND chosenAction = "rendezvous"){
			chosenEntity:STARTTRACKING().
		}
		
		//Creates the result lexicon
		LOCAL res IS LEXICON(). //Perhaps a third property to return a LIST which contains any additional params, E.g. landing coordinates
			SET res["entity"] TO chosenEntity.
			SET res["action"] TO chosenAction.
			SET res["landingcoordinates"] TO landCoordinates.
			SET res["orbitparameters"] TO orbitLex.
			
		//Returns the result lexicon
		RETURN res.
	}
	
	
	//--------------------------------------------------\
	//Used for populating the entity list---------------|
		FUNCTION populateEntityLexicon {
			PARAMETER _type.
			
			LOCAL resLex IS LEXICON().
			
			//Adds the matching entities to the lexicon
			IF(_type = "bodies"){
				LIST BODIES IN targList.
				FOR entity IN targList {
					SET resLex[entity:NAME] TO entity.	
				}
			}
			ELSE IF(_type = "asteroids"){
				LIST TARGETS IN targList.
				FOR entity IN targList {
					IF(entity:TYPE = "SpaceObject"){
						SET resLex[entity:NAME] TO entity.	
					}
				}
			}
			ELSE IF(_type = "vessels"){
				LIST TARGETS IN targList.
				FOR entity IN targList {
					IF(entity:TYPE <> "Debris" AND entity:TYPE <> "SpaceObject" AND (entity:STATUS = "FLYING" or entity:STATUS = "ORBITING")){
						SET resLex[entity:NAME] TO entity.	
					}
				}
			}
			
			//Returns the lexicon	
			RETURN resLex.
		}
	
	
//--------------------------------------------------------------------------\
//							Select landing coordinates		 				|
//--------------------------------------------------------------------------/


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
						SET fileCoordinatesBox:ADDBUTTON(splitData[0]):ONCLICK TO { SET chosenCoordinates TO LATLNG(splitData[1]:TOSCALAR(0),splitData[2]:TOSCALAR(0)). SET selectedLabel:TEXT TO ("Selected : " + splitData[0]). }.		
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

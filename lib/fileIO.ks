//--------------------------------------------------------------------------\
//							  	  Variables				   					|
//--------------------------------------------------------------------------/

	
//--------------------------------------------------------------------------\
//								  Functions					   				|
//--------------------------------------------------------------------------/	


	//Grabs a pair of coordinates based on the name
	FUNCTION getCoordinates {
		PARAMETER _locationName.
		PARAMETER _body IS SHIP:BODY.
		
		LOCAL path IS ("data/saved coordinates/" + _body:NAME + ".txt").
		IF(NOT VOLUME(0):EXISTS(path)){ WRITEJSON(LIST(), path). } //If the file does not exist, create it
		
		LOCAL coordinateList IS READJSON(path).
		FOR dataLine IN coordinateList {
			LOCAL splitData IS dataLine:SPLIT(",").
			IF(splitData[0] = _locationName){ RETURN _body:GEOPOSITIONLATLNG(splitData[1]:TOSCALAR(0),splitData[2]:TOSCALAR(0)). }			
		}
		RETURN _body:GEOPOSITIONLATLNG(0,0).
	}
	
	//Saves a new pair of coordinates
	FUNCTION saveCoordinates {
		PARAMETER _locationName.
		PARAMETER _coordinates.
		PARAMETER _body IS SHIP:BODY.
		
		//Open the current bodies file
		LOCAL path IS ("data/saved coordinates/" + _body:NAME + ".txt").
		IF(NOT VOLUME(0):EXISTS(path)){ WRITEJSON(LIST(), path). } //If the file does not exist, create it
		
		//Read in the list, add the location, and write it back
		LOCAL coordinateList IS READJSON(path).
		coordinateList:ADD(_locationName + "," + _coordinates:LAT + "," + _coordinates:LNG).		
		WRITEJSON(coordinateList, path).
	}
	
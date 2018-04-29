LOCAL chosen IS false.

LOCK spot TO SHIP:GEOPOSITION.
LOCK vecTargetSite TO spot:POSITION - BODY:POSITION.

LOCK returnedCoords TO vectToCoordinates(vecTargetSite).


LOCK vecInitialSite TO SHIP:OBT:VELOCITY:ORBIT.
LOCK preLandedCoords TO vectToCoordinates(vecInitialSite).


LOCK kosFindCoords TO SHIP:BODY:GEOPOSITIONOF(SHIP:BODY:POSITION - SHIP:POSITION + vecInitialSite).

UNTIL chosen = True {
	CLEARSCREEN.
	PRINT "KOS   LAT/LNG : " + kosFindCoords:LAT + " / " + kosFindCoords:LNG.
	PRINT "Found LAT/LNG : " + preLandedCoords:LAT + " / " + preLandedCoords:LNG.
	WAIT 0.1.
}




FUNCTION vectToCoordinates {
	PARAMETER _Vector.
	LOCAL longitude IS 0.
	LOCAL latitude IS 0.

	//Increasing longitude is CCW direction
	//Coordinates
	LOCAL refFront IS LATLNG(0,0).
	LOCAL refRight IS LATLNG(0,270).
	LOCAL refLeft IS LATLNG(0,90).
	LOCAL refUp IS LATLNG(90,0).
	//Vectors
	LOCAL refFront_vector IS refFront:POSITION - BODY:POSITION.
	LOCAL refRight_vector IS refRight:POSITION - BODY:POSITION.
	LOCAL refLeft_vector IS refLeft:POSITION - BODY:POSITION.	
	LOCAL refUp_vector IS refUp:POSITION - BODY:POSITION.	
	LOCAL _Vector_flat IS V(_Vector:X, 0, _Vector:Z).
	
	
	//Determine longitude
	IF(VANG(_Vector_flat, refLeft_vector) < VANG(_Vector_flat, refRight_vector)){ //Closer to left
		SET longitude TO VANG(_Vector_flat, refFront_vector).
	}
	ELSE{ //Closer to right
		SET longitude TO -VANG(_Vector_flat, refFront_vector).
	}
	
	
	//Determine latitude
	IF(VANG(_Vector, refUp_vector) < 90){
		//SET latitude TO VANG(_Vector, _Vector_flat).
		SET latitude TO 90 - VANG(_Vector, refUp_vector).
	}
	ELSE{
		//SET latitude TO -VANG(_Vector, _Vector_flat).
		SET latitude TO -VANG(_Vector, refUp_vector) + 90.
	}
	
	
	//Return geo-coordinates
	LOCAL geoCoords IS LATLNG(latitude, longitude).
	RETURN geoCoords.
}
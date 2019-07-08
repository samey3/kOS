CLEARSCREEN.
CLEARVECDRAWS().

//How many steps between the angles to search for best
LOCAL angSteps IS 200.

//Power of the sun
LOCAL sunPower IS 1360*4*CONSTANT:PI()*KERBIN:ORBIT:SEMIMAJORAXIS^2.
LOCK sunlightVector TO ((SHIP:POSITION - SUN:POSITION):NORMALIZED*sunIntensity).
LOCK albedolightVector TO (getAlbedoVector()*albedoIntensity).

//Solar and albedo intensity
LOCK sunIntensity TO sunPower/(4*CONSTANT:PI()*sunPosVec:MAG^2).
LOCK albedoIntensity TO sunIntensity*0.33.
LOCAL sunIntensityString IS "".
LOCAL albedoIntensityString IS "".

//Various vectors
LOCK sunPosVec TO (SHIP:POSITION - SUN:POSITION).
LOCK _vES TO (SUN:POSITION - KERBIN:POSITION).
LOCK _vEC TO (SHIP:POSITION - KERBIN:POSITION).
LOCK angSEC TO VANG(_vES, _vEC).


//Axis to rotate around
LOCK iterateAxis TO VCRS(_vES, _vEC).



//Drawn vectors
LOCAL resDrawVec IS 0.
LOCAL sunDrawVec IS 0.
LOCAL albedoDrawVec IS 0.
LOCAL magNorthDrawVec IS 0.
LOCAL GPSDrawVec IS 0.
LOCAL shipLightDrawVec IS 0.
LOCAL shipFaceDrawVec IS 0.
LOCAL resSunDrawVec IS 0.


//Points for drawn vectors
LOCAL GPSFinalPoint IS 0.


//Starboard right
//Top up
//Fore forwards

//ang = arcsin(i/imax)



//X-axis
LOCK px_current TO {
	LOCAL current IS 0.
	LOCAL s_angle IS VANG(SHIP:FACING:STARVECTOR, -sunlightVector). //Sun current
	IF(s_angle <= 90){ SET current TO current + COS(s_angle)*(sunIntensity/1360). }	
	LOCAL a_angle IS VANG(SHIP:FACING:STARVECTOR, albedolightVector). //Albedo current
	IF(a_angle <= 90){ SET current TO current + COS(a_angle)*(albedoIntensity/1360). }
	RETURN current.	
}.
LOCK nx_current TO {
	LOCAL current IS 0.
	LOCAL s_angle IS VANG(-SHIP:FACING:STARVECTOR, -sunlightVector). //Sun current
	IF(s_angle <= 90){ SET current TO current + COS(s_angle)*(sunIntensity/1360). }	
	LOCAL a_angle IS VANG(-SHIP:FACING:STARVECTOR, albedolightVector). //Albedo current
	IF(a_angle <= 90){ SET current TO current + COS(a_angle)*(albedoIntensity/1360). }	
	RETURN current.	
}.
//Y-axis
LOCK py_current TO {
	LOCAL current IS 0.
	LOCAL s_angle IS VANG(SHIP:FACING:TOPVECTOR, -sunlightVector). //Sun current
	IF(s_angle <= 90){ SET current TO current + COS(s_angle)*(sunIntensity/1360). }	
	LOCAL a_angle IS VANG(SHIP:FACING:TOPVECTOR, albedolightVector). //Albedo current
	IF(a_angle <= 90){ SET current TO current + COS(a_angle)*(albedoIntensity/1360). }	
	RETURN current.	
}.
LOCK ny_current TO {
	LOCAL current IS 0.
	LOCAL s_angle IS VANG(-SHIP:FACING:TOPVECTOR, -sunlightVector). //Sun current
	IF(s_angle <= 90){ SET current TO current + COS(s_angle)*(sunIntensity/1360). }	
	LOCAL a_angle IS VANG(-SHIP:FACING:TOPVECTOR, albedolightVector). //Albedo current
	IF(a_angle <= 90){ SET current TO current + COS(a_angle)*(albedoIntensity/1360). }	
	RETURN current.	
}.
//Z-axis
LOCK pz_current TO {
	LOCAL current IS 0.
	LOCAL s_angle IS VANG(SHIP:FACING:FOREVECTOR, -sunlightVector). //Sun current
	IF(s_angle <= 90){ SET current TO current + COS(s_angle)*(sunIntensity/1360). }	
	LOCAL a_angle IS VANG(SHIP:FACING:FOREVECTOR, albedolightVector). //Albedo current
	IF(a_angle <= 90){ SET current TO current + COS(a_angle)*(albedoIntensity/1360). }	
	RETURN current.	
}.
LOCK nz_current TO {
	LOCAL current IS 0.
	LOCAL s_angle IS VANG(-SHIP:FACING:FOREVECTOR, -sunlightVector). //Sun current
	IF(s_angle <= 90){ SET current TO current + COS(s_angle)*(sunIntensity/1360). }	
	LOCAL a_angle IS VANG(-SHIP:FACING:FOREVECTOR, albedolightVector). //Albedo current
	IF(a_angle <= 90){ SET current TO current + COS(a_angle)*(albedoIntensity/1360). }	
	RETURN current.	
}.

//ang = arccos(I0/Imax)
//cos(ang) = I0/iMax = ratio*1

//------------------------------
//NOW OUR ON-BOARD CALCULATIONS|
//------------------------------

LOCK lightVector_ship TO (
	SHIP:FACING:STARVECTOR*(px_current:CALL() - nx_current:CALL())
	+ SHIP:FACING:TOPVECTOR*(py_current:CALL() - ny_current:CALL())
	+ SHIP:FACING:FOREVECTOR*(pz_current:CALL() - nz_current:CALL())
).



UNTIL(FALSE){
	//SET GPSFinalPoint TO (SHIP:BODY:POSITION + getGPSVector()).
	//SET GPSDrawVec TO VECDRAW((SHIP:BODY:POSITION - SHIP:POSITION):NORMALIZED*100, GPSFinalPoint - (SHIP:BODY:POSITION - SHIP:POSITION):NORMALIZED*100, GREEN, "GPS position", 1, TRUE, 0.25).

	//PRINT("Positive-X : " + px_current:CALL()).
	//PRINT("Negative-X : " + nx_current:CALL()).
	//sunlightVector
	
	SET shipLightDrawVec TO VECDRAW(SHIP:POSITION, lightVector_ship:NORMALIZED*10, YELLOW, "panels_light_vector", 1, TRUE, 0.5).
	
	LOCAL albedoVec IS -getAlbedoVector(TRUE).
	SET foundAlbedoDrawVec TO VECDRAW(SHIP:POSITION - albedoVec:NORMALIZED*10, albedoVec:NORMALIZED*10, BLUE, "estimated_albedo_vector", 1, TRUE, 0.5).
	
	LOCAL resultSunVector IS (lightVector_ship + albedoVec*0.33).
	SET resSunDrawVec TO VECDRAW(SHIP:POSITION, resultSunVector:NORMALIZED*10, GREEN, "result_sun_vector", 1, TRUE, 0.5).
	
	
	SET xDraw TO VECDRAW(SHIP:POSITION, SHIP:FACING:STARVECTOR*(px_current:CALL() - nx_current:CALL())*5, WHITE, "x", 1, TRUE, 0.5).
	SET yDraw TO VECDRAW(SHIP:POSITION, SHIP:FACING:TOPVECTOR*(py_current:CALL() - ny_current:CALL())*5, WHITE, "y", 1, TRUE, 0.5).
	SET zDraw TO VECDRAW(SHIP:POSITION, SHIP:FACING:FOREVECTOR*(pz_current:CALL() - nz_current:CALL())*5, WHITE, "z", 1, TRUE, 0.5).
	
	//PRINT("lightVec : " + lightVector_ship:MAG).
	//PRINT("albedoVec : " + albedoVec:MAG*0.33).
}












FUNCTION getGPSVector{
	LOCAL posVec IS (SHIP:POSITION - SHIP:BODY:POSITION).
	
	//'Vertical' error (Earth relative 'up')
	SET posVec TO posVec:NORMALIZED*(posVec:MAG + ((2*RANDOM()-1)*SQRT(10))).
	
	//'Horizontal' error (Orbital velocity)
	SET posVec TO posVec + SHIP:VELOCITY:ORBIT:NORMALIZED*((2*RANDOM()-1)*SQRT(10)).
	
	//Return the result with error added
	RETURN posVec.
}



FUNCTION getAlbedoVector{
	PARAMETER _useGPS IS FALSE.

	//Temp vars
	LOCAL angStep IS 0.
	LOCAL resVec IS 0.
	LOCAL refPoint IS 0.

	LOCAL _vPS IS 0.
	LOCAL _vPC IS 0.

	LOCAL angPS IS 0.
	LOCAL angPC IS 0.

	LOCAL diffIncidence IS 0.
	LOCAL closestVal IS 0.
	LOCAL albedoVec IS 0.
	LOCAL sunVec IS 0.

	//If occluded, no sun or albedo
	IF(((((SHIP:POSITION - BODY:POSITION) - (((SHIP:POSITION - BODY:POSITION)*(BODY:POSITION - BODY("SUN"):POSITION))/((BODY:POSITION - BODY("SUN"):POSITION):MAG^2))*(BODY:POSITION - BODY("SUN"):POSITION)):MAG < SHIP:BODY:RADIUS) AND ((SHIP:POSITION - BODY("SUN"):POSITION):MAG > (BODY:POSITION - BODY("SUN"):POSITION):MAG))){
		SET albedoVec TO 0.
		SET sunVec TO 0.
	}
	ELSE{
		//Iterate
		SET closest TO 1000.
		FROM {LOCAL i IS 0.} UNTIL i = angSEC STEP {SET i TO i+angSEC/angSteps.} DO {
			SET sunVec TO sunPosVec.
		
			//Get the angle this iteration
			SET rotAng TO ANGLEAXIS(i, iterateAxis).
		  
			//Get the result vector
			SET resVec TO (_vES:NORMALIZED*rotAng)*KERBIN:RADIUS.
			
			//Find the reflection point
			SET refPoint TO KERBIN:POSITION + resVec.
			
			//Sun-point/point-vec angle
			SET _vPS TO (refPoint - SUN:POSITION).
			SET angPS TO VANG(resVec, _vPS).
			
			//CubeSat-point/point-vec angle
			IF(_useGPS = FALSE){ SET _vPC TO (refPoint - SHIP:POSITION). }
			ELSE{ SET _vPC TO (refPoint - (SHIP:BODY:POSITION + getGPSVector())). }
			
			SET angPC TO VANG(resVec, _vPC).
			
			//Find the difference in incidence angles. If lower, record. If higher, break.
			SET diffIncidence TO ABS(angPS - angPC).
			IF(diffIncidence < closest){
				SET closest TO diffIncidence.
			}
			ELSE IF (diffIncidence > closest){
				SET rotAng TO ANGLEAXIS(i-angSEC/angSteps, iterateAxis).
				SET resVec TO (_vES:NORMALIZED*rotAng)*KERBIN:RADIUS.
				SET refPoint TO KERBIN:POSITION + resVec.					
				IF(_useGPS = FALSE){ SET albedoVec TO (SHIP:POSITION - refPoint). }
				ELSE{ SET albedoVec TO ((SHIP:BODY:POSITION + getGPSVector()) - refPoint). }
				
				BREAK.
			}
		}
	}
	
	//Set the strings
	SET sunIntensityString TO ("Sun (" + sunIntensity + " W/m^2)").
	SET albedoIntensityString TO ("Albedo (" + albedoIntensity + " W/m^2)").
	
	//Draw the vector
	//SET resDrawVec TO VECDRAW(KERBIN:POSITION, resVec, GREEN, "resVec", 1.0, TRUE, 1).
	//SET sunDrawVec TO VECDRAW(SUN:POSITION, sunVec, YELLOW, sunIntensityString, 1, TRUE, 1).
	//SET albedoDrawVec TO VECDRAW(KERBIN:POSITION + resVec, albedoVec, RED, albedoIntensityString, 1, TRUE, 1).
	
	//IF(NOT sunVec:ISTYPE("scalar")){ SET sunDrawVec TO VECDRAW((SUN:POSITION - SHIP:POSITION):NORMALIZED*100, sunVec:NORMALIZED*100, YELLOW, sunIntensityString, 1, TRUE, 0.5). }
	//IF(NOT albedoVec:ISTYPE("scalar")){ SET albedoDrawVec TO VECDRAW((KERBIN:POSITION + resVec - SHIP:POSITION):NORMALIZED*100, albedoVec:NORMALIZED*100, RED, albedoIntensityString, 1, TRUE, 0.5). }
	
	//SET magNorthDrawVec TO VECDRAW(SHIP:POSITION, , GREEN, "Magnetic North", 1, TRUE, 0.5).
	
	RETURN (KERBIN:POSITION + resVec - SHIP:POSITION):NORMALIZED.
}


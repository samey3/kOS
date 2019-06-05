
//How many steps between the angles to search for best
LOCAL angSteps IS 200.

//Power of the sun
LOCAL sunPower IS 1360*4*CONSTANT:PI()*KERBIN:ORBIT:SEMIMAJORAXIS^2.

//Solar and albedo intensity
LOCK sunIntensity TO P/(4*CONSTANT:PI()*sunVec:MAG^2).
LOCK albedoIntensity TO sunIntensity*0.33.
LOCAL sunIntensityString IS "".
LOCAL albedoIntensityString IS "".

//Various vectors
LOCK sunVec TO (SHIP:POSITION - SUN:POSITION).
LOCK _vES TO (SUN:POSITION - KERBIN:POSITION).
LOCK _vEC TO (SHIP:POSITION - KERBIN:POSITION).
LOCK angSEC TO VANG(_vES, _vEC).


//Axis to rotate around
LOCK iterateAxis TO VCRS(_vES, _vEC).


//Temp vars
LOCAL angStep IS 0.
LOCAL resVec IS 0.
LOCAL refPoint IS 0.

LOCAL _vPS IS 0.
LOCAL _vCS IS 0.

LOCAL angPS IS 0.
LOCAL angPC IS 0.

LOCAL diffIncidence IS 0.
LOCAL closestVal IS 0.
LOCAL albedoVec IS 0.

LOCAL sunDrawVec IS 0.
LOCAL albedoDrawVec IS 0.


UNTIL(1=0){

	//Iterate
	SET closest TO 1000.
	FROM {LOCAL i IS 0.} UNTIL i = angSEC STEP {SET i TO i+angSEC/angSteps.} DO {
		//Get the angle this iteration
		SET rotAng TO ANGLEAXIS(i, iterateAxis).
	  
		//Get the result vector
		SET resVec TO (_vES:NORMALIZED*rotAng)*KERBIN:RADIUS.
		
		//Find the reflection point
		SET refPoint TO KERBIN:POSITION + resVec.
		
		//Sun-point/point-vec angle
		SET _vPS TO (SUN:POSITION - refPoint).
		SET angPS TO VANG(resVec, _vPS).
		
		//CubeSat-point/point-vec angle
		SET _vPC TO (SUN:POSITION - refPoint).
		SET angPC TO VANG(resVec, _vPC).
		
		//Find the difference in incidence angles. If lower, record. If higher, break.
		SET diffIncidence TO ABS(angPS - angPC).
		IF(diffIncidenc < closest){
			SET closest TO diffIncidenc.
		}
		ELSE IF (diffIncidenc > closest){
			SET rotAng TO ANGLEAXIS(i-angSEC/angSteps, iterateAxis).
			SET resVec TO _vES:NORMALIZED*rotAng.
			SET refPoint TO KERBIN:POSITION + resVec.
			SET albedoVec TO (SHIP:POSITION - refPoint).
			BREAK.
		}
	}
	
	//Set the strings
	SET sunIntensityString TO ("Sun (" + sunIntensity + " W/m^2)").
	SET albedoIntensityString TO ("Albedo (" + albedoIntensity + " W/m^2)").
	
	//Draw the vector
	SET sunDrawVec TO VECDRAW(SUN:POSITION, sunVec, YELLOW, sunIntensityString, 1.0, TRUE, 1).
	SET albedoDrawVec TO VECDRAW(KERBIN:POSITION, albedoVec, RED, albedoIntensityString, 1.0, TRUE, 1).
}


CLEARSCREEN.
RUNONCEPATH("lib/math.ks").
LOCK THROTTLE TO 0.
STAGE.

print("Show : " + SHIP:AVAILABLETHRUST).

//Get grav and ship accelerations
LOCK g_acc TO SHIP:BODY:MU / (SHIP:POSITION - SHIP:BODY:POSITION):MAG^2.
LOCK s_acc TO SHIP:AVAILABLETHRUST/SHIP:MASS*0.7.
//print("Show : " + s_acc).
//print("Show : " + g_acc).
//print("Show : " + (g_acc/s_acc)).
//print("Show4 : " + ARCSIN(g_acc/s_acc)).

//Find angle tilt required
LOCK angleReq TO ARCSIN(g_acc/s_acc).
PRINT("ANGLE : " + angleReq).

//Create the path
LOCAL initPos IS SHIP:GEOPOSITION.
LOCAL targetPos IS initPos.
LOCAL path IS QUEUE().
	path:PUSH(LATLNG(initPos:LAT + 0.1, initPos:LNG + 0)).
	path:PUSH(LATLNG(initPos:LAT + 0.1, initPos:LNG + 0.1)).
	path:PUSH(LATLNG(initPos:LAT + 0, initPos:LNG + 0.1)).
	path:PUSH(LATLNG(initPos:LAT + 0, initPos:LNG + 0)).
	path:PUSH(LATLNG(initPos:LAT + 0.1, initPos:LNG + 0)).
	path:PUSH(LATLNG(initPos:LAT + 0.1, initPos:LNG + 0.1)).
	path:PUSH(LATLNG(initPos:LAT + 0, initPos:LNG + 0.1)).
	path:PUSH(LATLNG(initPos:LAT + 0, initPos:LNG + 0)).
	path:PUSH(LATLNG(initPos:LAT + 0.1, initPos:LNG + 0)).
	path:PUSH(LATLNG(initPos:LAT + 0.1, initPos:LNG + 0.1)).
	path:PUSH(LATLNG(initPos:LAT + 0, initPos:LNG + 0.1)).
	path:PUSH(LATLNG(initPos:LAT + 0, initPos:LNG + 0)).

//Find the required facing direction
LOCK relProject TO projectToPlane(targetPos:POSITION - SHIP:GEOPOSITION:POSITION, UP:VECTOR).
LOCK modPitch TO ANGLEAXIS(angleReq + 7, VCRS(relProject, UP:VECTOR)).	
LOCK faceDir to relProject:DIRECTION*modPitch.

//Lock steering to the required direction and start engines	
LOCK STEERING TO faceDir.
LOCK THROTTLE TO 1.

LOCAL nextVec IS 0.
LOCAL faceVec IS 0.
UNTIL (path:EMPTY){
	CLEARVECDRAWS().
	SET targetPos TO path:POP().	
	UNTIL (relProject:MAG < 100){
		SET nextVec TO VECDRAW(targetPos:POSITION, UP:VECTOR:NORMALIZED*100, RED, "Next target", 1.0, TRUE, 1).
		SET faceVec TO VECDRAW(SHIP:POSITION, faceDir:VECTOR:NORMALIZED*30, YELLOW, "Required", 1.0, TRUE, 1).
	}
}

CLEARVECDRAWS().
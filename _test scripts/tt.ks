RUNONCEPATH("lib/math.ks").
RUNONCEPATH("lib/fileIO.ks").
AG1 OFF.

CLEARSCREEN.

LOCAL startPoint IS SHIP:GEOPOSITION.

WAIT UNTIL(AG1).

LOCAL endPoint IS SHIP:GEOPOSITION.

PRINT(startPoint).
PRINT("").
PRINT(endPoint).
PRINT("").
LOCAL posVec Is startPoint:POSITION - endPoint:POSITION.

LOCAL angleDir IS VANG(-SHIP:BODY:ANGULARVEL, projectToPlane(posVec, UP:VECTOR)).





PRINT("dir: " + angleDir).



saveCoordinates("island_runway_start", startPoint).
saveCoordinates("island_runway_end", endPoint).
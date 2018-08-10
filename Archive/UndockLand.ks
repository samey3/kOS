CLEARSCREEN.
//Undock from station-------------------------------------//

SET portList TO SHIP:DOCKINGPORTS.
SAS ON.
RCS ON.
SET controlStick to SHIP:CONTROL.


IF portList:LENGTH > 0 {
	portList[0]:UNDOCK.
	
	LOCAL closest IS 500.
	LOCAL hostStation IS SHIP.
	LIST TARGETS IN vesselList.
	FOR VESSEL IN vesselList
		{										
			IF (VESSEL:POSITION - SHIP:POSITION):MAG < closest AND VESSEL <> SHIP {
				SET closest TO (VESSEL:POSITION - SHIP:POSITION):MAG.
				SET hostStation TO VESSEL.
			}
		}

	LOCK STEERING TO smoothRotate(SHIP:FACING).

	SET SHIP:CONTROL:FORE TO -1.
	WAIT 1.
	SET SHIP:CONTROL:FORE TO 0.

	UNTIL (hostStation:POSITION - SHIP:POSITION):MAG > 50 {
		PRINT "Separating from station...".
		PRINT "--------------------------".
		PRINT "Distance : " + (hostStation:POSITION - SHIP:POSITION):MAG.
		WAIT 0.1.
		CLEARSCREEN.
	}
}

LOCK STEERING TO smoothRotate(retrograde).
WAIT UNTIL VANG(SHIP:FACING:VECTOR,retrograde:VECTOR) < 5.

//--------------------------------------------------------//
//Deorbit-------------------------------------------------//

UNTIL ETA:APOAPSIS < 1 {
	PRINT "Waiting until apoapsis....".
	PRINT "--------------------------".
	PRINT "Time to Ap : " + ETA:APOAPSIS.
	WAIT 0.1.
	CLEARSCREEN.
}

LOCK THROTTLE TO 1.

PRINT "Commencing deorbit burn...".

WAIT UNTIL periapsis < 50.

LOCK THROTTLE TO 0.
CLEARSCREEN.

//--------------------------------------------------------//
//Land----------------------------------------------------//

LOCK bodyGrav TO SHIP:BODY:MASS*CONSTANT():G / (SHIP:POSITION - BODY:POSITION):MAG^2.
LOCK velAngle TO VANG(UP:VECTOR,SHIP:VELOCITY:ORBIT) - 90.
LOCK shipAcc TO SHIP:AVAILABLETHRUST / SHIP:MASS.
LOCK decelHeight TO (verticalspeed^2 / (2 * (shipAcc*SIN(velAngle) - bodyGrav))) + 50.

UNTIL (altitude - SHIP:GEOPOSITION:TERRAINHEIGHT) <= decelHeight {
	PRINT "Waiting to burn...........".
	PRINT "--------------------------".
	PRINT "Burn height      : " + decelHeight.
	PRINT "Current altitude : " + (altitude - SHIP:GEOPOSITION:TERRAINHEIGHT).
	PRINT "Distance left    : " + (altitude - SHIP:GEOPOSITION:TERRAINHEIGHT - decelHeight).
	WAIT 0.1.
	CLEARSCREEN.
}

LOCK THROTTLE TO 1.
WAIT UNTIL SHIP:VELOCITY:SURFACE:MAG < 7.
LOCK THROTTLE TO 0.

LOCK STEERING TO smoothRotate(UP).

UNTIL (altitude - SHIP:GEOPOSITION:TERRAINHEIGHT) <= (decelHeight - 50) {
	PRINT "Waiting to burn...........".
	PRINT "--------------------------".
	PRINT "Burn height      : " + decelHeight.
	PRINT "Current altitude : " + (altitude - SHIP:GEOPOSITION:TERRAINHEIGHT).
	PRINT "Distance left    : " + (altitude - SHIP:GEOPOSITION:TERRAINHEIGHT - decelHeight).
	WAIT 0.1.
	CLEARSCREEN.
}
LOCK THROTTLE TO 1.
GEAR ON.
LEGS ON.
WAIT UNTIL SHIP:VELOCITY:SURFACE:MAG < 5.
LOCK THROTTLE TO 0.

WAIT UNTIL SHIP:STATUS = "LANDED".
PRINT "Landed!".
	
//--------------------------------------------------------\\
//														  ||
//-------------------------Functions----------------------//

FUNCTION smoothRotate {
    PARAMETER dir.
    LOCAL spd IS max(SHIP:ANGULARMOMENTUM:MAG/10,4).
    LOCAL curF IS SHIP:FACING:FOREVECTOR.
    LOCAL curR IS SHIP:FACING:TOPVECTOR.
    LOCAL rotR IS R(0,0,0).
    IF VANG(dir:FOREVECTOR,curF) < 90{SET rotR TO ANGLEAXIS(min(0.5,VANG(dir:TOPVECTOR,curR)/spd),VCRS(curR,dir:TOPVECTOR)).}
    RETURN LOOKDIRUP(ANGLEAXIS(min(2,VANG(dir:FOREVECTOR,curF)/spd),VCRS(curF,dir:FOREVECTOR))*curF,rotR*curR).
}
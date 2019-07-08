CLEARSCREEN.
//Undock from station-------------------------------------//

SET portList TO SHIP:DOCKINGPORTS.
SAS ON.
RCS ON.
SET controlStick to SHIP:CONTROL.


IF portList:LENGTH > 0 {
	portList[0]:UNDOCK.
	WAIT 1.
	SAS ON.
	RCS ON.
	
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
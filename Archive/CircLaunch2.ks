CLEARSCREEN.

PARAMETER targetCraft IS selectEntity("ORBITING").

LOCAL targetAltitude IS targetCraft:PERIAPSIS.
LOCAL targetInclination IS 90.


//--------------------------------------------------------\\
//														  ||
//----------------------Launch sequence-------------------//

	LOCK STEERING TO smoothRotate(UP).
	PRINT "Launch sequence:".
	FROM {local countdown is 3.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
		PRINT countdown.
		WAIT 1. // pauses the script here for 1 second.
	}
	PRINT "Liftoff".

	
	
	
	
	LOCAL base_acceleration IS SHIP:AVAILABLETHRUST / SHIP:MASS.
	//LOCAL Ag IS -ABS(((SHIP:BODY:MU / SHIP:BODY:RADIUS^2) + (SHIP:BODY:MU / (SHIP:BODY:RADIUS + targetAltitude)^2))/2). //Makes it always a negative
	LOCAL Ag IS -ABS(SHIP:BODY:MU / SHIP:BODY:RADIUS^2).
	SET Ag TO -0.352.
	LOCAL accNet IS base_acceleration + Ag.	
	
	PRINT "1 : " + (2*accNet*Ag*targetAltitude).
	PRINT "2 : " + (Ag - accNet).
	PRINT "3 : " + accNet.
	PRINT "4 : " + Ag.
	
	
	LOCAL midVel IS SQRT((2*accNet*Ag*targetAltitude)/(Ag - accNet)).	
	LOCAL burnTime IS midVel / accNet.
	LOCAL timeToApo IS midVel*(Ag - accNet)/(Ag*accNet).

	LOCAL Vm IS SQRT(-2*Ag*targetAltitude).
	
	PRINT "targetAltitude : " + targetAltitude.
	PRINT "midVel : " + midVel.
	PRINT "base : " + base_acceleration.
	PRINT "ag : " + Ag.
	PRINT "accNet : " + accNet.
	PRINT "time   : " + timeToApo.
	WAIT 5.
	
	
	RUN nodeBurn(0,burnTime*base_acceleration,4).
	

//------------------------------------------------------------------------------------------------------\
//												FUNCTIONS												|
//------------------------------------------------------------------------------------------------------/


FUNCTION smoothRotate {
    PARAMETER dir.
    LOCAL spd IS max(SHIP:ANGULARMOMENTUM:MAG/10,4).
    LOCAL curF IS SHIP:FACING:FOREVECTOR.
    LOCAL curR IS SHIP:FACING:TOPVECTOR.
    LOCAL rotR IS R(0,0,0).
    IF VANG(dir:FOREVECTOR,curF) < 90{SET rotR TO ANGLEAXIS(min(0.5,VANG(dir:TOPVECTOR,curR)/spd),VCRS(curR,dir:TOPVECTOR)).}
    RETURN LOOKDIRUP(ANGLEAXIS(min(2,VANG(dir:FOREVECTOR,curF)/spd),VCRS(curF,dir:FOREVECTOR))*curF,rotR*curR).
}















FUNCTION selectEntity {
	PARAMETER entLocatation IS "LANDED".
	SET entities TO LIST().
	
	LIST TARGETS IN entityList.
		FOR ENTITY IN entityList
		{										
			IF SHIP:BODY:NAME = ENTITY:BODY:NAME AND (ENTITY:STATUS = entLocatation){
				entities:ADD(ENTITY).
			}
		}
	

	LOCAL listIndex IS 0.
	LOCAL chosen IS "False".
	
	ag1 OFF.
	ag2 OFF.
	ag3 OFF.
	
	UNTIL chosen = True {
		PRINT "Select a " + entLocatation + " entity.".
		PRINT "Use action group 1 to move up the list.".
		PRINT "Use action group 2 to move down the list.".
		PRINT "Use action group 3 to confirm target".
		PRINT " ".
		PRINT entities.
		PRINT " ".
		PRINT "Target entity: [" + listIndex + "] " + entities[listIndex].
		
		WAIT UNTIL ag1 = "True" OR ag2 = "True" OR ag3 = "True".	
			IF ag1 = "True" AND listIndex > 0{ 
				SET listIndex TO listIndex - 1. 
			}
			IF ag2 = "True" AND listIndex < (entities:LENGTH - 1){ 
				SET listIndex TO listIndex + 1.
			}
			IF ag3 = "True" { 
				SET chosen TO True. 
			}
			
			CLEARSCREEN.
			
			ag1 OFF.
			ag2 OFF.
			ag3 OFF.
	}	
	
	RETURN entities[listIndex].
}

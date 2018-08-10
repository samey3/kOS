
//Implement a way to find its current state and start from there, a case without breaks?

RUN UNDOCK.
LOCAL landingTarget IS selectEntity("LANDED").
LOCAL deliverTarget IS selectEntity("ORBITING").


UNTIL FALSE {
	RUN EQLANDER(landingTarget).
	WAIT 10.
	RUN CIRCLAUNCH(deliverTarget).
	RUN CIRCRENDEZVOUS(deliverTarget).
	RUN DOCK(deliverTarget).
	RUN UNDOCK.
}






//------------------------------------------------------------------------------------------------------\
//												FUNCTIONS												|
//------------------------------------------------------------------------------------------------------/


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
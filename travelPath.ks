//PARAMETER path IS STACK().
LOCAL path IS STACK().

//A queue might be better here
//path:PUSH(SHIP:GEOPOSITION).
//path:PUSH(LATLNG(0.5, 112.5)).
//path:PUSH(LATLNG(1, 113)).
//path:PUSH(LATLNG(0.5, 113.5)).
//path:PUSH(LATLNG(0, 113.5)).
//path:PUSH(LATLNG(0, 113)).

//path:PUSH(SHIP:GEOPOSITION).
//path:PUSH(LATLNG(0, 113)).

path:PUSH(TARGET:GEOPOSITION).
path:PUSH(SHIP:BODY:GEOPOSITIONOF(HEADING(270,0):VECTOR*300)).

BRAKES OFF.
PRINT("lat : " + SHIP:GEOPOSITION:LAT).
PRINT("lng : " + SHIP:GEOPOSITION:LNG).

UNTIL (path:EMPTY){ //Does while false, waits till true
	LOCAL nextNode IS path:POP().
	LOCK surfaceNormal TO VCRS(SHIP:BODY:GEOPOSITIONOF(HEADING(0,0):VECTOR):POSITION - SHIP:GEOPOSITION:POSITION, SHIP:BODY:GEOPOSITIONOF(HEADING(90,0):VECTOR):POSITION - SHIP:GEOPOSITION:POSITION).
	
	LOCK WHEELTHROTTLE TO 1.
	//LOCK STEERING TO smoothRotate(LOOKDIRUP(nextNode:POSITION - SHIP:POSITION, surfaceNormal)). //WHEELSTEERING	
	LOCK STEERING TO smoothRotate(LOOKDIRUP(SHIP:BODY:GEOPOSITIONOF((nextNode:POSITION - SHIP:POSITION):NORMALIZED):POSITION - SHIP:GEOPOSITION:POSITION, surfaceNormal)).
	
	
	
	//Fc = (mv^2)/r	
	//Fc = Fg/2
	//m = ship mass
	//V = movingVel
	//Turn radius will vary with current velocity
	//Thus,
	//r = safetyFactor*(mv^2)/Fg
	
	LOCAL safetyFactor IS 2.
	LOCK F_grav TO SHIP:BODY:MU/(SHIP:ALTITUDE + SHIP:BODY:RADIUS)^2.
	LOCK turnRadius TO safetyFactor*(SHIP:MASS * SHIP:VELOCITY:SURFACE:MAG^2)/F_grav.
	
	
	PRINT("Turn radius : " + turnRadius).
	
	//Center of mass has centripital applied.
	//Once centripital force is greater than grav force (integrate along horizontally?), it will start to rotate.
	//Thus, find max speed based on that.
	
	
	
	UNTIL ((nextNode:POSITION - SHIP:POSITION):MAG <= turnRadius){
		//Go straight
		//Maintain velocity
		CLEARSCREEN.
		PRINT("Travelling to : ").
		PRINT("Lat : " + SHIP:GEOPOSITION:LAT).
		PRINT("Lng : " + SHIP:GEOPOSITION:LNG).
		PRINT("Distance left : " + (nextNode:POSITION - SHIP:GEOPOSITION:POSITION):MAG).
		PRINT("Turn radius : " + turnRadius).
		SET surfaceNormalVec TO VECDRAWARGS(SHIP:POSITION,surfaceNormal*10,GREEN,"Normal",1,TRUE).
		SET steeringVec TO VECDRAWARGS(SHIP:POSITION,(SHIP:BODY:GEOPOSITIONOF((nextNode:POSITION - SHIP:POSITION):NORMALIZED):POSITION - SHIP:GEOPOSITION:POSITION)*10,RED,"Steering",1,TRUE).
		SET nextNodeVec TO VECDRAWARGS(nextNode:POSITION,(nextNode:POSITION - SHIP:BODY:POSITION):NORMALIZED * 400,BLUE,"Next node",5,TRUE).
		
		WAIT 0.1.
	}
	//Begin turn
	//Maintain velocity
	
	//Possible methods:
	//Find the time to complete the turn, base heading on that (Not good)
	//Do some positioning, turn epicentre vector, and ships position determines its heading
	
	
	if(path:EMPTY = FALSE){
		//Epicenter seems off, draw peek node as well
		//How about just aim at each point on the edge of the turn radius?
		LOCAL inVector IS (nextNode:POSITION - SHIP:GEOPOSITION:POSITION):NORMALIZED.
		LOCAL outVector IS (path:PEEK():POSITION - nextNode:POSITION):NORMALIZED.
		//LOCAL turnEpicentre IS SHIP:BODY:GEOPOSITIONOF(nextNode:POSITION + (nextNode:POSITION + turnRadius*((-inVector):NORMALIZED + (outVector):NORMALIZED):NORMALIZED)).
		LOCAL turnEpicentre IS SHIP:BODY:GEOPOSITIONOF(nextNode:POSITION + (turnRadius*((-inVector) + outVector):NORMALIZED)).
		LOCAL initialAngle IS VANG(inVector, outVector).	
		LOCAL turnStartVec IS (SHIP:POSITION - turnEpicentre:POSITION).	
		LOCK turnProgressAngle TO 90*(VANG(SHIP:POSITION - turnEpicentre:POSITION, turnStartVec))/initialAngle.
		UNTIL (turnProgressAngle >= 90 OR (SHIP:POSITION - nextNode:POSITION):MAG > turnRadius){
			//Go straight
			//Maintain velocity
			//LOCK STEERING TO smoothRotate(LOOKDIRUP(inVector*COS(turnProgressAngle) + outVector*SIN(turnProgressAngle), surfaceNormal)). //WHEELSTEERING
			LOCK STEERING TO smoothRotate(LOOKDIRUP(SHIP:BODY:GEOPOSITIONOF((inVector*COS(turnProgressAngle) + outVector*SIN(turnProgressAngle)):NORMALIZED):POSITION - SHIP:GEOPOSITION:POSITION, surfaceNormal)). //WHEELSTEERING				
			CLEARSCREEN.		
			PRINT("Turn progress 	: " + (100*(turnProgressAngle/90)) + "%").
			PRINT("Angle value 		: " + turnProgressAngle).
			PRINT("In portion 		: " + inVector*COS(turnProgressAngle)).
			PRINT("out portion 		: " + outVector*SIN(turnProgressAngle)).
			SET surfaceNormalVec TO VECDRAWARGS(SHIP:POSITION,surfaceNormal*10,GREEN,"Normal",1,TRUE).
			SET steeringVec TO VECDRAWARGS(SHIP:POSITION,(SHIP:BODY:GEOPOSITIONOF((inVector*COS(turnProgressAngle) + outVector*SIN(turnProgressAngle)):NORMALIZED):POSITION - SHIP:GEOPOSITION:POSITION)*10,RED,"Steering",1,TRUE).
			SET nextNodeVec TO VECDRAWARGS(nextNode:POSITION,(nextNode:POSITION - SHIP:BODY:POSITION):NORMALIZED * 400,BLUE,"Next node",5,TRUE).
			SET epicenterVec TO VECDRAWARGS(turnEpicentre:POSITION,(turnEpicentre:POSITION - SHIP:BODY:POSITION):NORMALIZED * 400,WHITE,"Epicenter",5,TRUE).
			
			SET toVec TO VECDRAWARGS(SHIP:POSITION,nextNode:POSITION - SHIP:POSITION,RED,"",5,TRUE).
			SET outVec TO VECDRAWARGS(nextNode:POSITION,path:PEEK():POSITION - nextNode:POSITION,WHITE,"",5,TRUE).
			
			WAIT 0.1.
		}
		SET toVec:SHOW TO FALSE.
		SET outVec:SHOW TO FALSE.
	}
	ELSE {
		UNTIL ((SHIP:POSITION - nextNode:POSITION):MAG <= 500) {
			CLEARSCREEN.
			PRINT("Travelling to : ").
			PRINT("Lat : " + SHIP:GEOPOSITION:LAT).
			PRINT("Lng : " + SHIP:GEOPOSITION:LNG).
			PRINT("Distance left : " + (nextNode:POSITION - SHIP:GEOPOSITION:POSITION):MAG).
			PRINT("Turn radius : " + turnRadius).
			SET surfaceNormalVec TO VECDRAWARGS(SHIP:POSITION,surfaceNormal*10,GREEN,"Normal",1,TRUE).
			SET steeringVec TO VECDRAWARGS(SHIP:POSITION,(SHIP:BODY:GEOPOSITIONOF((nextNode:POSITION - SHIP:POSITION):NORMALIZED):POSITION - SHIP:GEOPOSITION:POSITION)*10,RED,"Steering",1,TRUE).
			SET nextNodeVec TO VECDRAWARGS(nextNode:POSITION,(nextNode:POSITION - SHIP:BODY:POSITION):NORMALIZED * 400,BLUE,"Next node",5,TRUE).
			WAIT 0.1.
		}
		BRAKES ON.
	}
	//3PI/4 along? Rotate vector by that much
	
	//cosine component = initialAngle
	//sine component = target
	
	
	//Maybe use bearings? Uses a scalar degree value.
	//Won't have to deal with vertical distance in the vectors
	//node:BEARING should return the relative difference in degrees to the ships bearing
	
	//Heading is absolute from the vessel
	//Bearing is relative
	
	
	//Removes drawn vectors for next node
	removeDrawnVecs.
	
	
	
	//Distance to the next node
	//Travel velocity.
	//Normally use max, but whatever current speed is, base it on that.
	//Using current speed as it gets closer, once it is close enough for a speed, keep speed constant and commence turning.
	
	//E.g. what rate of turning do we want that won't flip it?
	//Find a rate based on that, get the size of the turning circle. Start the turn when at a distance of the turn radius from the node.
	
	//Find a centripital force, and halve it. Use this for the circle.
	//If there are any slopes along the turn, cut speed to a safe value.
	
	//-------------------------------------------------------------------------------
	
	//Maintain velocity function
	//Take in an input speed maybe, adjust through each loop
	//Check if currently accelerating or decelerating, and if faster or slower.
	//If faster and accelerating, use breaks maybe
	
	//Function for dealing with if it is airborne?
}


LOCK WHEELTHROTTLE TO 1.
LOCK WHEELSTEERING TO "kill".
BRAKES ON.

//______________________________________________________________
//							Smooth rotation						|
//______________________________________________________________|


FUNCTION smoothRotate {
    PARAMETER dir.
    LOCAL spd IS max(SHIP:ANGULARMOMENTUM:MAG/10,4).
    LOCAL curF IS SHIP:FACING:FOREVECTOR.
    LOCAL curR IS SHIP:FACING:TOPVECTOR.
    LOCAL rotR IS R(0,0,0).
    IF VANG(dir:FOREVECTOR,curF) < 90{SET rotR TO ANGLEAXIS(min(0.5,VANG(dir:TOPVECTOR,curR)/spd),VCRS(curR,dir:TOPVECTOR)).}
    RETURN LOOKDIRUP(ANGLEAXIS(min(2,VANG(dir:FOREVECTOR,curF)/spd),VCRS(curF,dir:FOREVECTOR))*curF,rotR*curR).
}

FUNCTION removeDrawnVecs {
	SET surfaceNormalVec:SHOW TO FALSE.
	SET steeringVec:SHOW TO FALSE.
	SET nextNodeVec:SHOW TO FALSE.
	SET epicenterVec:SHOW TO FALSE.
}
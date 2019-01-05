//Rotates the vessel to face the given direction
//This function is purely for legacy support now
//Should it be phased out?
//DEPRECATE THIS, or keep for precise controls?
FUNCTION smoothRotate {
	PARAMETER _dir.
	PARAMETER _maxTime IS 0.1.
	SAS OFF.
	
	//LOCAL spd IS max(SHIP:ANGULARMOMENTUM:MAG/10,4).
	//LOCAL curF IS SHIP:FACING:FOREVECTOR.
	//LOCAL curR IS SHIP:FACING:TOPVECTOR.
	//LOCAL rotR IS R(0,0,0).
	//IF VANG(dir:FOREVECTOR,curF) < 90{SET rotR TO ANGLEAXIS(min(0.5,VANG(dir:TOPVECTOR,curR)/spd),VCRS(curR,dir:TOPVECTOR)).}
	//RETURN LOOKDIRUP(ANGLEAXIS(min(2,VANG(dir:FOREVECTOR,curF)/spd),VCRS(curF,dir:FOREVECTOR))*curF,rotR*curR).
	
	SET STEERINGMANAGER:MAXSTOPPINGTIME TO _maxTime.
	RETURN _dir.
}

//Enables adaptive lighting based on whether the sun is occluded or not
//A much more efficient one would use solar panel readouts
FUNCTION adaptiveLighting {
	PARAMETER _state.
	LOCAL LOCK checker TO _state.
	ON (((((SHIP:POSITION - BODY:POSITION) - (((SHIP:POSITION - BODY:POSITION)*(BODY:POSITION - BODY("SUN"):POSITION))/((BODY:POSITION - BODY("SUN"):POSITION):MAG^2))*(BODY:POSITION - BODY("SUN"):POSITION)):MAG < SHIP:BODY:RADIUS) AND ((SHIP:POSITION - BODY("SUN"):POSITION):MAG > (BODY:POSITION - BODY("SUN"):POSITION):MAG)) AND checker) {
		LOCAL setToState IS ((((SHIP:POSITION - BODY:POSITION) - (((SHIP:POSITION - BODY:POSITION)*(BODY:POSITION - BODY("SUN"):POSITION))/((BODY:POSITION - BODY("SUN"):POSITION):MAG^2))*(BODY:POSITION - BODY("SUN"):POSITION)):MAG < SHIP:BODY:RADIUS) AND ((SHIP:POSITION - BODY("SUN"):POSITION):MAG > (BODY:POSITION - BODY("SUN"):POSITION):MAG)).
		
		LOCAL lightList IS LIST().		
		FOR part IN SHIP:PARTS {
			//Spotlights
			IF(part:HASMODULE("ModuleLight")){ lightList:ADD(part:GETMODULE("ModuleLight")). }
			//Crew cabins
			IF(part:HASMODULE("ModuleColorChanger")){ lightList:ADD(part:GETMODULE("ModuleColorChanger")). }
			//Cockpits
			IF(part:HASMODULE("ModuleAnimateGeneric")){ lightList:ADD(part:GETMODULE("ModuleAnimateGeneric")). }
		}
		
		FOR module IN lightList {
			IF(setToState AND module:HASEVENT("lights on")) { module:DOEVENT("lights on"). }
			IF((setToState = FALSE) AND module:HASEVENT("lights off")) { module:DOEVENT("lights off"). }
		}
		RETURN _state.
	}
}

//Sets solar panel state
FUNCTION setSolarPanels {
	PARAMETER _state.
	//Make them store when moving fast in atmosphere, but deploy when sitting still
	//E.g. landed
}

//Sets drill state
FUNCTION setDrills {
	PARAMETER _state.
	
}

ON(CORE:MESSAGES:LENGTH){
	IF(CORE:MESSAGES:EMPTY() = FALSE){
		UNTIL(CORE:MESSAGES:EMPTY()){
			PRINT("Received message : " + CORE:MESSAGES:POP():CONTENT).
		}
	}
	RETURN TRUE.
}


FUNCTION setRCSLimits {
	//This will go over every RCS thruster, and modify them so that their center of thrust is in the center of mass
}



FUNCTION autoStage {
	//Stages when there is no fuel left in the stage
	//Use an ON/WHEN
}






FUNCTION findFarthestPart {
	PARAMETER _craft IS SHIP.
	PARAMETER _portion IS "All".	
	
	LOCAL farthest IS 0.	
	FOR part IN _craft:PARTS {
		LOCAL partPosition IS (part:POSITION - _craft:POSITION).
		IF(_portion = "All"){
			SET farthest TO MAX(farthest, partPosition:MAG).
		}
		ELSE IF(_portion = "Upper" AND VANG(_craft:FACING:FOREVECTOR, partPosition) <= 90){
			SET farthest TO MAX(farthest, ABS(partPosition*_craft:FACING:FOREVECTOR)).
		}
		ELSE IF(_portion = "Lower" AND VANG(_craft:FACING:FOREVECTOR, partPosition) >= 90){
			SET farthest TO MAX(farthest, ABS(partPosition*_craft:FACING:FOREVECTOR)).
		}
	}
	RETURN farthest.
}

//Perhaps if landed, can get alt:radar + top height?
//Could also do top-most part, radar height/geopos height?
//OR
//part:pos - body:pos - body:radius - part:geopos:terrainheight.
//Gives ship height if on ground

//Pad gave problem because of core orientation
FUNCTION findCraftHeight {
	PARAMETER _craft IS SHIP.
	
	//Part distances
	LOCAL biggestUpper IS 0.
	LOCAL biggestLower IS 0.
	
	//Finds the vessel height
	FOR part IN _craft:PARTS {
		LOCAL partDistance IS (part:POSITION - _craft:POSITION)*_craft:FACING:FOREVECTOR.
		IF(partDistance > 0){
			SET biggestUpper TO MAX(biggestUpper, partDistance). }
		ELSE {
			SET biggestLower TO MAX(biggestUpper, -partDistance). }
	}
	
	RETURN biggestLower + biggestUpper.
}

//ONLY FINDS TO THE CENTER OF A PART.
//So how do we find the true-bottom-height?





//Could place a cherry light on the backside of a cockpit, and have a warning function
//Looks light warning lights inside the cockpit

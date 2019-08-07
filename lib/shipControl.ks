//Move adaptive lighting and panels to an autonomous script perhaps?

//--------------------------------------------------------------------------\
//							Adaptive lighting				   				|
//--------------------------------------------------------------------------/


	//Enables adaptive lighting based on whether the sun is occluded or not
	//A much more efficient one would use solar panel readouts
	FUNCTION adaptiveLighting {
	
		//----------------------------------------------------\
		//Parameters and variables----------------------------|
			PARAMETER _state.
			LOCAL LOCK SENTINEL TO _state.
					
			IF(_state){ PRINT("Adaptive lighting : ENABLED"). }
			ELSE { PRINT("Adaptive lighting : DISABLED"). }
		
		//----------------------------------------------------\
		//Watch for occlusion of sun--------------------------|
			//If occlusion state changes, modify lighting
			ON (((((SHIP:POSITION - BODY:POSITION) - (((SHIP:POSITION - BODY:POSITION)*(BODY:POSITION - BODY("SUN"):POSITION))/((BODY:POSITION - BODY("SUN"):POSITION):MAG^2))*(BODY:POSITION - BODY("SUN"):POSITION)):MAG < SHIP:BODY:RADIUS) AND ((SHIP:POSITION - BODY("SUN"):POSITION):MAG > (BODY:POSITION - BODY("SUN"):POSITION):MAG)) AND SENTINEL) {
				LOCAL setToState IS ((((SHIP:POSITION - BODY:POSITION) - (((SHIP:POSITION - BODY:POSITION)*(BODY:POSITION - BODY("SUN"):POSITION))/((BODY:POSITION - BODY("SUN"):POSITION):MAG^2))*(BODY:POSITION - BODY("SUN"):POSITION)):MAG < SHIP:BODY:RADIUS) AND ((SHIP:POSITION - BODY("SUN"):POSITION):MAG > (BODY:POSITION - BODY("SUN"):POSITION):MAG)).
				
				//Get list of all lights
				LOCAL lightList IS LIST().		
				FOR part IN SHIP:PARTS {
					//Spotlights
					IF(part:HASMODULE("ModuleLight")){ lightList:ADD(part:GETMODULE("ModuleLight")). }
					//Crew cabins
					IF(part:HASMODULE("ModuleColorChanger")){ lightList:ADD(part:GETMODULE("ModuleColorChanger")). }
					//Cockpits
					IF(part:HASMODULE("ModuleAnimateGeneric")){ lightList:ADD(part:GETMODULE("ModuleAnimateGeneric")). }
				}
				
				//Turn lights on or off
				FOR module IN lightList {
					IF(setToState AND module:HASEVENT("lights on")) { module:DOEVENT("lights on"). }
					IF((setToState = FALSE) AND module:HASEVENT("lights off")) { module:DOEVENT("lights off"). }
				}
				
				RETURN _state.
			}
	}
	
	
//--------------------------------------------------------------------------\
//								Adaptive panels				   				|
//--------------------------------------------------------------------------/	


	FUNCTION adaptivePanels {
	
		//----------------------------------------------------\
		//Parameters and variables----------------------------|
			PARAMETER _state.
			LOCAL LOCK SENTINEL TO _state.
					
			IF(_state){ PRINT("Adaptive panels : ENABLED"). }
			ELSE { PRINT("Adaptive panels : DISABLED"). }
				
		//----------------------------------------------------\
		//Watch for unsafe conditions-------------------------|
			//Extend panels if safe, stow if unsafe
			ON ((SHIP:DYNAMICPRESSURE = 0 OR SHIP:VELOCITY:SURFACE:MAG < 20) AND SENTINEL) {
				LOCAL setToState IS (SHIP:DYNAMICPRESSURE = 0 OR SHIP:VELOCITY:SURFACE:MAG < 20). //If false, stow panels
				
				//Get list of all panels
				FOR part IN SHIP:PARTS {
					IF(part:HASMODULE("ModuleDeployableSolarPanel")){
						//Gets the part module
						LOCAL pm IS part:GETMODULE("ModuleDeployableSolarPanel").
						
						//If safe, extend
						IF(setToState = TRUE AND pm:HASEVENT("extend solar panel")){
							pm:DOEVENT("extend solar panel").
						}		
						//If unsafe, stow
						ELSE IF(setToState = FALSE AND pm:HASEVENT("retract solar panel")){
							pm:DOEVENT("retract solar panel").
						}
					}
				}
				
				RETURN _state.
			}
	}

	
//--------------------------------------------------------------------------\
//								Vessel dimensions			   				|
//--------------------------------------------------------------------------/	


	//How about we just use vessel bounds here?
	//https://ksp-kos.github.io/KOS/structures/vessels/bounds.html#structure:BOUNDS
	

	//Finds the dimensions of the vessel (lower, upper, total)
	FUNCTION vesselHeight {
		PARAMETER _craft.
		
		//Import the math library
		RUNONCEPATH("lib/math.ks").
		
		//Part distances
		LOCAL biggestUpper IS 0.
		LOCAL biggestLower IS 0.
		
		//For each part, find its offset
		FOR part IN _craft:PARTS {
			LOCAL offset IS scalarProjection((part:POSITION - SHIP:POSITION), _craft:FACING:FOREVECTOR).
			
			//If it was a landing leg/wheel, add extra offset
			IF(part:HASMODULE("ModuleWheelDeployment")){
				SET offset TO 1.5*sign(offset) + offset. }
			
			//Set the new max/min offset
			IF(offset > 0){ 
				SET biggestUpper TO MAX(biggestUpper, offset). }
			ELSE{ 
				SET biggestLower TO MAX(biggestLower, ABS(offset)). }
		}
		
		//Return lower, upper, and total vessel height
		RETURN LIST(biggestLower, biggestUpper, biggestLower + biggestUpper).
	}

	//Finds the distance the vessel is submerged under water (below 0 altitude)
	FUNCTION distanceSubmerged {
		PARAMETER _craft.

		//Find the distance submerged
		LOCAL vesHeight IS vesselHeight(_craft)[0].
		LOCAL dist IS _craft:BODY:RADIUS - ((_craft:POSITION - _craft:BODY:POSITION):MAG - vesHeight).

		//If above sea-level, return 0
		//IF(dist <= 0){ RETURN 0. }
		//ELSE { RETURN dist. }
		
		RETURN dist.
	}

	
//--------------------------------------------------------------------------\
//								Vessel axial RCS			   				|
//--------------------------------------------------------------------------/	


	//Get the total RCS thrust per ship-centered axis
	//Can thrust the axial amount IN THAT DIRECTION (opposite way that the RCS port faces)
	FUNCTION getRCSThrustAxis {
		//Lexicon to hold the axial thrust values
		LOCAL axlThr IS LEXICON().
			SET axlThr["px"] TO 0.
			SET axlThr["nx"] TO 0.
			SET axlThr["py"] TO 0.
			SET axlThr["ny"] TO 0.
			SET axlThr["pz"] TO 0.
			SET axlThr["nz"] TO 0.
		
		//4-thruster block, 1Kn of thrust
		FOR p IN SHIP:PARTSNAMED("RCSBlock.v2") {
			//Get the block's forevector axis
			SET axlThr["px"] TO axlThr["px"] + ABS(SHIP:FACING:FOREVECTOR*(p:FACING:FOREVECTOR*1)).
			SET axlThr["nx"] TO axlThr["nx"] + ABS(SHIP:FACING:FOREVECTOR*(p:FACING:FOREVECTOR*1)).			
			SET axlThr["py"] TO axlThr["py"] + ABS(SHIP:FACING:TOPVECTOR*(p:FACING:FOREVECTOR*1)).
			SET axlThr["ny"] TO axlThr["ny"] + ABS(SHIP:FACING:TOPVECTOR*(p:FACING:FOREVECTOR*1)).		
			SET axlThr["pz"] TO axlThr["pz"] + ABS(SHIP:FACING:STARVECTOR*(p:FACING:FOREVECTOR*1)).
			SET axlThr["nz"] TO axlThr["nz"] + ABS(SHIP:FACING:STARVECTOR*(p:FACING:FOREVECTOR*1)).
		
			//Get the block's topvector axis
			SET axlThr["px"] TO axlThr["px"] + ABS(SHIP:FACING:FOREVECTOR*(p:FACING:TOPVECTOR*1)).
			SET axlThr["nx"] TO axlThr["nx"] + ABS(SHIP:FACING:FOREVECTOR*(p:FACING:TOPVECTOR*1)).			
			SET axlThr["py"] TO axlThr["py"] + ABS(SHIP:FACING:TOPVECTOR*(p:FACING:TOPVECTOR*1)).
			SET axlThr["ny"] TO axlThr["ny"] + ABS(SHIP:FACING:TOPVECTOR*(p:FACING:TOPVECTOR*1)).		
			SET axlThr["pz"] TO axlThr["pz"] + ABS(SHIP:FACING:STARVECTOR*(p:FACING:TOPVECTOR*1)).
			SET axlThr["nz"] TO axlThr["nz"] + ABS(SHIP:FACING:STARVECTOR*(p:FACING:TOPVECTOR*1)).			
		}
		
		//1-thruster block, 1Kn of thrust
		FOR p IN SHIP:PARTSNAMED("linearRcs") {
			//Get the block's forevector axis
			//X-axis
			IF(VANG(SHIP:FACING:FOREVECTOR, p:FACING:FOREVECTOR) < 90){ 
				SET axlThr["nx"] TO axlThr["nx"] + SHIP:FACING:FOREVECTOR*(p:FACING:FOREVECTOR*1). }
			ELSE{
				SET axlThr["px"] TO axlThr["px"] - SHIP:FACING:FOREVECTOR*(p:FACING:FOREVECTOR*1). }
			
			//Y-axis
			IF(VANG(SHIP:FACING:TOPVECTOR, p:FACING:FOREVECTOR) < 90){ 
				SET axlThr["ny"] TO axlThr["ny"] + SHIP:FACING:TOPVECTOR*(p:FACING:FOREVECTOR*1). }
			ELSE{
				SET axlThr["py"] TO axlThr["py"] - SHIP:FACING:TOPVECTOR*(p:FACING:FOREVECTOR*1). }
			
			//Z-axis
			IF(VANG(SHIP:FACING:STARVECTOR, p:FACING:FOREVECTOR) < 90){ 
				SET axlThr["nz"] TO axlThr["nz"] + SHIP:FACING:STARVECTOR*(p:FACING:FOREVECTOR*1). }
			ELSE{
				SET axlThr["pz"] TO axlThr["pz"] - SHIP:FACING:STARVECTOR*(p:FACING:FOREVECTOR*1). }		
		}

		//1-thruster block, 12Kn of thrust
		FOR p IN SHIP:PARTSNAMED("vernierEngine") {
			//Get the block's negative starvector axis
			//X-axis
			IF(VANG(SHIP:FACING:FOREVECTOR, -p:FACING:STARVECTOR) < 90){ 
				SET axlThr["nx"] TO axlThr["nx"] + SHIP:FACING:FOREVECTOR*(-p:FACING:STARVECTOR*12). }
			ELSE{
				SET axlThr["px"] TO axlThr["px"] - SHIP:FACING:FOREVECTOR*(-p:FACING:STARVECTOR*12). }
			
			//Y-axis
			IF(VANG(SHIP:FACING:TOPVECTOR, -p:FACING:FOREVECTOR) < 90){ 
				SET axlThr["ny"] TO axlThr["ny"] + SHIP:FACING:TOPVECTOR*(-p:FACING:STARVECTOR*12). }
			ELSE{
				SET axlThr["py"] TO axlThr["py"] - SHIP:FACING:TOPVECTOR*(-p:FACING:STARVECTOR*12). }
			
			//Z-axis
			IF(VANG(SHIP:FACING:STARVECTOR, -p:FACING:FOREVECTOR) < 90){ 
				SET axlThr["nz"] TO axlThr["nz"] + SHIP:FACING:STARVECTOR*(-p:FACING:STARVECTOR*12). }
			ELSE{
				SET axlThr["pz"] TO axlThr["pz"] - SHIP:FACING:STARVECTOR*(-p:FACING:STARVECTOR*12). }		
		}

		//Return the lexicon
		RETURN axlThr.
	}
	
	
//--------------------------------------------------------------------------\
//								Part highlighting			   				|
//--------------------------------------------------------------------------/



	FUNCTION highlightPart {
		PARAMETER _pl.
		PARAMETER _colour.	
		IF(_pl:ISTYPE("list")){ FOR p IN _pl { HIGHLIGHT(p, _colour). } }
		ELSE{ HIGHLIGHT(_pl, _colour). }
	}
	
	FUNCTION removeHighlight {
		SET HIGHLIGHT(s_ports, RED):ENABLED TO FALSE.
		SET HIGHLIGHT(t_ports, RED):ENABLED TO FALSE.
		
		PARAMETER _pl.
		IF(_pl:ISTYPE("list")){ FOR p IN _pl { SET HIGHLIGHT(p, RED):ENABLED TO FALSE. } }
		ELSE{ SET HIGHLIGHT(_pl, RED):ENABLED TO FALSE. }
	}

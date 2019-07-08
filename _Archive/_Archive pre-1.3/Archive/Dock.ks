//Assume starting in final stage
	CLEARSCREEN.
	
//---------------------------------------------\
//				  Set variables				   |
//---------------------------------------------/

	//PARAMETER dockNum. //DELETE MEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
	PARAMETER _TC_Param IS 0. 
	IF _TC_Param <> 0 {
		SET targetCraft TO _TC_Param.
	}
	ELSE IF _TC_Param = 0 AND HASTARGET = True {
		SET targetCraft TO TARGET.
	}
	ELSE {
		PRINT "No target is selected.".
		PRINT "Shutting down . . .".
		SHUTDOWN.
	}
	
	SET ports TO targetCraft:DOCKINGPORTS.	
	SET selfPortList TO SHIP:DOCKINGPORTS.
	SET selfPort TO selfPortList[0].
		FOR DOCKINGPORTS IN selfPortList //Finds the front-most docking port on self-vessel
		{			
			IF VANG(SHIP:FACING:VECTOR, DOCKINGPORTS:POSITION - SHIP:POSITION) < VANG(SHIP:FACING:VECTOR, selfPort:POSITION - SHIP:POSITION){
				SET selfPort TO DOCKINGPORTS.
			}
		}
		//Set a condition thing for if there are no docking ports	
	SET selfPortDistance TO (selfPort:POSITION - SHIP:POSITION):MAG.	
	

//---------------------------------------------\
//				  Set controls				   |
//---------------------------------------------/


	SAS ON.
	RCS ON.
	SET controlStick to SHIP:CONTROL.

	SET SHIP:CONTROL:FORE TO 0.
	SET SHIP:CONTROL:STARBOARD TO 0.
	LOCK THROTTLE TO 0.

	
//---------------------------------------------\
//				 Move to standoff			   |
//---------------------------------------------/		


	//Probably put a cancelVel here
	//Moves to 100m away from target craft
	moveToPoint(targetCraft,(SHIP:POSITION - targetCraft:POSITION):NORMALIZED*100,0).


//---------------------------------------------\
//				Choose docking port			   |
//---------------------------------------------/


	LOCAL chosen IS False.
		IF ports:LENGTH = 1 {
			//This will skip the section below as there is only one docking port available
			SET chosen TO True.
		}
		//SET chosen TO True. //DELETE MEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
	LOCAL listIndex IS 0.

	ag1 OFF.
	ag2 OFF.
	ag3 OFF.
	SET portHighlight TO HIGHLIGHT(ports,RED).
	SET portSel TO HIGHLIGHT(ports[listIndex],GREEN).

	UNTIL chosen = True {
		PRINT "Use action group 1 to move up the list.".
		PRINT "Use action group 2 to move down the list.".
		PRINT "Use action group 3 to confirm target docking port".
		PRINT " ".
		PRINT ports.
		PRINT " ".
		PRINT "Target docking port: [" + listIndex + "] " + ports[listIndex].
		
		WAIT UNTIL ag1 = "True" OR ag2 = "True" OR ag3 = "True".	
			IF ag1 = "True" AND listIndex > 0{ 
				SET listIndex TO listIndex - 1. 
			}
			IF ag2 = "True" AND listIndex < (ports:LENGTH - 1){ 
				SET listIndex TO listIndex + 1.
			}
			IF ag3 = "True" { 
				SET chosen TO True. 
			}
			SET portHighlight TO HIGHLIGHT(ports,RED).
			SET portSel TO HIGHLIGHT(ports[listIndex],GREEN).
			
			CLEARSCREEN.
			
			ag1 OFF.
			ag2 OFF.
			ag3 OFF.
	}	
	SET targetPort TO ports[listIndex].

	SET portHighlight:ENABLED TO False. //Disables port highlighting (Disables all)
	SET portSel:ENABLED TO True. //Reenable highlighting of selected port

	CLEARSCREEN.

	//SET targetPort TO ports[dockNum]. //DELETE MEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
//---------------------------------------------\
//		Collision avoidance calculations	   |
//---------------------------------------------/


SET minDistance TO 0.
SET partList TO targetCraft:PARTS.
FOR PART IN partList
{			
	IF (PART:POSITION - targetCraft:POSITION):MAG > minDistance {
		SET minDistance TO (PART:POSITION - targetCraft:POSITION):MAG.   //Finds the part farthest from the vessel center
	}
}

SET minDistance TO minDistance + 15.   //Adds 15 to the minimum distance the docking vessel must be from the target craft
//IF closestApproach < minDistance{
	//Set this up, then run next part
//}


//---------------------------------------------\
//			  Move to port standoff			   |
//---------------------------------------------/


moveToPoint(targetPort,targetPort:FACING:VECTOR*100,0).		
	
	
//---------------------------------------------\
//				  Move to port				   |
//---------------------------------------------/


moveToPoint(targetPort,targetPort:FACING:VECTOR:NORMALIZED * (selfPortDistance + 4),1).


//---------------------------------------------\
//				  End program				   |
//---------------------------------------------/
	
	
SET portSel:ENABLED TO False.
//Program end



//------------------------------------------------------------------------------------------------------\
//												FUNCTIONS												|
//------------------------------------------------------------------------------------------------------/


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


//______________________________________________________________
//							Cancel velocity						|
//______________________________________________________________|


FUNCTION cancelVel{ //THE FIRST SMOOTH ROTATE
	PARAMETER toSpeed.	
	SET rcsX TO True.
	SET rcsY TO True.
	SET rcsZ TO True.
	
		
	//Sets up the custom axis		
	LOCK custom_xVec TO SHIP:FACING:FOREVECTOR.
	LOCK custom_yVec TO SHIP:FACING:TOPVECTOR.
	LOCK custom_zVec TO SHIP:FACING:STARVECTOR.
	
	LOCK relativeVel TO (SHIP:VELOCITY:ORBIT - targetCraft:VELOCITY:ORBIT).
	LOCK ship_Target_velVec TO V(VDOT(relativeVel,custom_xVec),VDOT(relativeVel,custom_yVec),VDOT(relativeVel,custom_zVec)).
	//LOCK STEERING TO smoothRotate(LOOKDIRUP(custom_xVec,custom_yVec)).
	
	
	//High speed stabilization
	UNTIL (rcsX = False AND rcsY = False AND rcsZ = False){	
	
		IF ABS(ship_Target_velVec:X) > 0.5
		{
			SET SHIP:CONTROL:FORE TO -ABS(ship_Target_velVec:X)/(ship_Target_velVec:X).
		}
		ELSE
		{
			SET SHIP:CONTROL:FORE TO 0.
			SET rcsX TO False.
		}
		
		IF ABS(ship_Target_velVec:Y) > 0.5
		{
			SET SHIP:CONTROL:TOP TO -ABS(ship_Target_velVec:Y)/(ship_Target_velVec:Y).
		}
		ELSE
		{
			SET SHIP:CONTROL:TOP TO 0.
			SET rcsY TO False.
		}
		
		IF ABS(ship_Target_velVec:Z) > 0.5
		{
			SET SHIP:CONTROL:STARBOARD TO -ABS(ship_Target_velVec:Z)/(ship_Target_velVec:Z).
		}
		ELSE
		{
			SET SHIP:CONTROL:STARBOARD TO 0.
			SET rcsZ TO False.
		}

		CLEARSCREEN.
		PRINT "Reducing relative velocity...(High speed)".
		PRINT "-----------------------------------------".
		PRINT "X: " + ship_Target_velVec:X.
		PRINT "Y: " + ship_Target_velVec:Y.
		PRINT "Z: " + ship_Target_velVec:Z.	
	}	
	
	//Resets booleans for low speed stabilization
	SET rcsX TO True.
	SET rcsY TO True.
	SET rcsZ TO True.
	
	//Low speed stabilization
	UNTIL (rcsX = False AND rcsY = False AND rcsZ = False){	
	
		IF ABS(ship_Target_velVec:X) < toSpeed 
		{
			SET SHIP:CONTROL:FORE TO 0.
			SET rcsX TO False.
		}
		ELSE
		{
			SET SHIP:CONTROL:FORE TO (-ABS(ship_Target_velVec:X)/(ship_Target_velVec:X))*sqrt(16*ABS(ship_Target_velVec:X))*toSpeed*5. //Added 5 for further
		}	
		
		IF ABS(ship_Target_velVec:Y) < toSpeed 
		{
			SET SHIP:CONTROL:TOP TO 0.
			SET rcsY TO False.
		}
		ELSE
		{
			SET SHIP:CONTROL:TOP TO (-ABS(ship_Target_velVec:Y)/(ship_Target_velVec:Y))*sqrt(16*ABS(ship_Target_velVec:Y))*toSpeed*5.
		}
		
		IF ABS(ship_Target_velVec:Z) < toSpeed 
		{
			SET SHIP:CONTROL:STARBOARD TO 0.
			SET rcsZ TO False.
		}
		ELSE
		{
			SET SHIP:CONTROL:STARBOARD TO (-ABS(ship_Target_velVec:Z)/(ship_Target_velVec:Z))*sqrt(16*ABS(ship_Target_velVec:Z))*toSpeed*5.
		}
		
		CLEARSCREEN.
		PRINT "Reducing relative velocity... (Low speed)".
		PRINT "-----------------------------------------".
		PRINT "X: " + ship_Target_velVec:X.
		PRINT "Y: " + ship_Target_velVec:Y.
		PRINT "Z: " + ship_Target_velVec:Z.	
	}
	
	SET SHIP:CONTROL:FORE TO 0.
	SET SHIP:CONTROL:TOP TO 0.
	SET SHIP:CONTROL:STARBOARD TO 0.
}


//______________________________________________________________
//							Draw vectors						|
//______________________________________________________________|


FUNCTION drawDockingVecs {
	//Draws vector form target port, directly in front of it for 100m
	SET portFrontVec TO VECDRAWARGS(targetPort:POSITION,portVec,GREEN,"Port Vector",1,TRUE).
		
	//Closest approach vector
	SET closestAppVec TO VECDRAWARGS(targetPort:POSITION,((100*targetPort:FACING:VECTOR):NORMALIZED + (SHIP:POSITION - targetPort:POSITION):NORMALIZED):NORMALIZED*closestApproach,RED,"Closest approach",1,TRUE).	
	
	//Vector distance between ship and target port
	SET distanceVec TO VECDRAWARGS(targetPort:POSITION,SHIP:POSITION - targetPort:POSITION,RED,"Distance: " + (targetPort:POSITION - SHIP:POSITION):MAG + "m",1,TRUE).
}


//______________________________________________________________
//						Remove drawn vectors					|
//______________________________________________________________|


FUNCTION removeDrawnVecs {
	SET toTargetVec:SHOW TO FALSE.
	SET xVecProj:SHOW TO FALSE.
	SET yVecProj:SHOW TO FALSE.
	SET zVecProj:SHOW TO FALSE.
}


//______________________________________________________________
//							Move to point						|
//______________________________________________________________|


FUNCTION moveToPoint {
	PARAMETER hostObj. //Object to host the vector
	PARAMETER Vec. //Vector extending from host object
	PARAMETER faceDir IS 0. //Direction to face during move (Default 0 is current facing).
	
	
	//---------------------------------------------\
	//				Custom axis setup			   |
	//---------------------------------------------/
	
	
		LOCK custom_xVec TO SHIP:FACING:FOREVECTOR.
		LOCK custom_yVec TO SHIP:FACING:TOPVECTOR.
		LOCK custom_zVec TO SHIP:FACING:STARVECTOR.
	
	
	//---------------------------------------------\
	//				  Initial variables			   |
	//---------------------------------------------/
	
		SET rcsList TO ship:partsNamed("RCSBlock").	
		SET total_rcs_thrust TO rcsList:LENGTH. //kN. Can set to the length of the list because each thruster is only 1kN
	
		//Vector from ship to point
		LOCK shipToPoint_Vector TO (hostObj:POSITION + Vec) - SHIP:POSITION.
	
		SET base_acceleration TO total_rcs_thrust / SHIP:MASS. //Mass in metric tonnes	
		SET moveSpeed TO SQRT(0.2*shipToPoint_Vector:MAG*base_acceleration).
	
	
	//---------------------------------------------\
	//				  Relative vectors			   |
	//---------------------------------------------/
	
	
		//Vector from ship to point
		//LOCK shipToPoint_Vector TO (hostObj:POSITION + Vec) - SHIP:POSITION.
		
		LOCK relative_velocity_vector TO (SHIP:VELOCITY:ORBIT - targetCraft:VELOCITY:ORBIT).
		LOCK relative_velocity_CA_Vector TO V(VDOT(relative_velocity_vector,custom_xVec),VDOT(relative_velocity_vector,custom_yVec),VDOT(relative_velocity_vector,custom_zVec)).
		
		LOCK coastVelocityVector TO V(VDOT(shipToPoint_Vector,custom_xVec),VDOT(shipToPoint_Vector,custom_yVec),VDOT(shipToPoint_Vector,custom_zVec)):NORMALIZED * movespeed.
		LOCK proportionalThrustVec TO V(ABS(coastVelocityVector:X), ABS(coastVelocityVector:Y), ABS(coastVelocityVector:Z)) / MAX(MAX(ABS(coastVelocityVector:X), ABS(coastVelocityVector:Y)), ABS(coastVelocityVector:Z)).
		
	
	//---------------------------------------------\
	//			  RCS thrust calculations		   |
	//---------------------------------------------/
	
		
		//1.0kN for 4-way block
		//2.0kN for linear block
		PRINT "RCS thrust : " + total_rcs_thrust + " Kn".
		
		LOCK required_thrust TO base_acceleration * SHIP:MASS.
		LOCK rcsThrustPercent TO required_thrust / total_rcs_thrust.
		
		
		
		//THRUST CALCULATIONS REWRITE
		SET rcsList TO ship:partsNamed("RCSBlock").	
		IF(faceDir = 0){
			SET total_rcs_thrust TO rcsList:LENGTH/2. //X-axis is 2x
		}
		ELSE IF(faceDir = 1){
			SET total_rcs_thrust TO rcsList:LENGTH.
		}
		
		SET base_acceleration TO total_rcs_thrust / SHIP:MASS. //Acceleration possible in each axis
		LOCK required_thrust TO base_acceleration * SHIP:MASS.
		LOCK rcsThrustPercent TO required_thrust / total_rcs_thrust.
		
		
		//Each axis possible acceleration added, resulting acceleration vector, must equal base_acceleration
		//Will be a flat overall multiplier?
		
		SET accelerationScaleMultiplier TO 1/SQRT(proportionalThrustVec:X^2 + proportionalThrustVec:Y^2 + proportionalThrustVec:Z^2).

	
	//---------------------------------------------\
	//					Start move				   |
	//---------------------------------------------/
	
	
		cancelVel(0.05).	
		PRINT "Performing move-to-point.".
	
	//-------------------------------------------------------------\\
	//Locks the ship direction-------------------------------------//
		
		LOCAL xThrustHalver IS 0.5.
		IF(faceDir = 0){
			LOCK STEERING TO smoothRotate(SHIP:FACING).
			WAIT UNTIL SHIP:ANGULARMOMENTUM:MAG < 0.1.
		}
		ELSE IF(faceDir = 1){
			SET xThrustHalver TO 1. //No halving
			SET base_acceleration TO base_acceleration*2. //Can be inneficient and do this since its facing along the axis
			SET total_rcs_thrust TO total_rcs_thrust*2.
			
			//Either base acceleration is a bit higher,
			//Or thrusting too much (Doesn't seem to be the case though)
			
			
			
			LOCK STEERING TO smoothRotate(LOOKDIRUP(((hostObj:POSITION + Vec)-SHIP:POSITION),targetCraft:FACING:TOPVECTOR)).
			WAIT UNTIL VECTORANGLE(SHIP:FACING:VECTOR,((hostObj:POSITION + Vec)-SHIP:POSITION)) < 0.3 AND SHIP:ANGULARMOMENTUM:MAG < 0.1.
		}
		WAIT 1.
		
		PRINT "Set move speed".
		PRINT moveSpeed.
		
	//-------------------------------------------------------------\\
	//Accelerate to move speed-------------------------------------//		
		//Scaling not needed here, used for reference. Remove afterwards
		//ACCELERATION REWRITE				Scaling			|	Percent		|		Proportion			|						Sign					| X-halved
		SET SHIP:CONTROL:FORE TO accelerationScaleMultiplier*rcsThrustPercent*proportionalThrustVec:X *(ABS(coastVelocityVector:X)/coastVelocityVector:X) * xThrustHalver. //X-thrust is halved due to double maxmimum thrust of others
		SET SHIP:CONTROL:TOP TO accelerationScaleMultiplier*rcsThrustPercent*proportionalThrustVec:Y *(ABS(coastVelocityVector:Y)/coastVelocityVector:Y).
		SET SHIP:CONTROL:STARBOARD TO accelerationScaleMultiplier*rcsThrustPercent*proportionalThrustVec:Z *(ABS(coastVelocityVector:Z)/coastVelocityVector:Z).
		
		//WAIT UNTIL (coastVelocityVector:NORMALIZED*moveSpeed - relative_velocity_CA_Vector):MAG <= 0.3.
		PRINT "xacc : " + (accelerationScaleMultiplier*rcsThrustPercent*proportionalThrustVec:X *(ABS(coastVelocityVector:X)/coastVelocityVector:X) * xThrustHalver).
		PRINT "mult : " + accelerationScaleMultiplier.
		PRINT "% : " + rcsThrustPercent.
		PRINT "PPV : " + proportionalThrustVec:X.
		PRINT " ".
		PRINT "Base accel : " + base_acceleration.
		PRINT "mass : " + SHIP:MASS.
		WAIT moveSpeed/base_acceleration.
		
		SET SHIP:CONTROL:FORE TO 0.
		SET SHIP:CONTROL:TOP TO 0.
		SET SHIP:CONTROL:STARBOARD TO 0.
		
	//-------------------------------------------------------------\\
	//Deceleration calculations------------------------------------//	
		//OLD WORKING CODE
		//LOCK thrust_time TO (ABS(relative_velocity_CA_Vector:X) / base_acceleration).
		//LOCK distance_start TO 0.5*ABS(relative_velocity_CA_Vector:X)*thrust_time.
		//WHAT IS THIS LINE : LOCK distance_start TO (ABS(relative_velocity_CA_Vector:X)*thrust_time + 0.5*base_acceleration*thrust_time^2).
		
		
		//DECELERATION REWRITE
		LOCK thrust_time TO relative_velocity_CA_Vector:MAG / base_acceleration.
		LOCK distance_start TO 0.5*ABS(relative_velocity_CA_Vector:MAG)*thrust_time.
		
		
		
		
	//-------------------------------------------------------------\\
	//Velocity management------------------------------------------//		
		UNTIL((shipToPoint_Vector:MAG - selfPortDistance) <= distance_start){
				
			//X-axis management------------------------------------\\
				IF ABS(relative_velocity_CA_Vector:X - coastVelocityVector:X) < 0.05 {
					SET SHIP:CONTROL:FORE TO 0.					
				}
				ELSE IF (relative_velocity_CA_Vector:X - coastVelocityVector:X) < 0{ //X-AXIS HAS TWICE THE AMOUNT OF AXIAL MAX-THRUST THAN Y OR Z. ADD CODE TO FIND THIS MAYBE?
					//SET SHIP:CONTROL:FORE TO 0.2/2 *proportionalThrustVec:X. //Go forward
					SET SHIP:CONTROL:FORE TO 0.1.
				}
				ELSE
				{
					//SET SHIP:CONTROL:FORE TO -0.2/2 *proportionalThrustVec:X.
					SET SHIP:CONTROL:FORE TO -0.1.
				}	
			
			//Y-axis management------------------------------------\\
				IF ABS(relative_velocity_CA_Vector:Y - coastVelocityVector:Y) < 0.005 {
					SET SHIP:CONTROL:TOP TO 0.
				}
				ELSE IF (relative_velocity_CA_Vector:Y - coastVelocityVector:Y) < 0 {
					SET SHIP:CONTROL:TOP TO sqrt(16*ABS(relative_velocity_CA_Vector:Y - coastVelocityVector:Y))*0.1.
					//SET SHIP:CONTROL:TOP TO 0.2 *proportionalThrustVec:Y.
				}
				ELSE
				{
					SET SHIP:CONTROL:TOP TO -sqrt(16*ABS(relative_velocity_CA_Vector:Y - coastVelocityVector:Y))*0.1.
					//SET SHIP:CONTROL:TOP TO -0.2 *proportionalThrustVec:Y.
				}	

			//Z-axis management------------------------------------\\ (+1 pushes negative Z)
				IF ABS(relative_velocity_CA_Vector:Z - coastVelocityVector:Z) < 0.005 {
					SET SHIP:CONTROL:STARBOARD TO 0.
				}
				ELSE IF (relative_velocity_CA_Vector:Z - coastVelocityVector:Z) < 0{ //GO FORWARD
					SET SHIP:CONTROL:STARBOARD TO sqrt(16*ABS(relative_velocity_CA_Vector:Z - coastVelocityVector:Z))*0.1.
					//SET SHIP:CONTROL:STARBOARD TO 0.2 *proportionalThrustVec:Z.
				}
				ELSE
				{
					SET SHIP:CONTROL:STARBOARD TO -sqrt(16*ABS(relative_velocity_CA_Vector:Z - coastVelocityVector:Z))*0.1.
					//SET SHIP:CONTROL:STARBOARD TO -0.2 *proportionalThrustVec:Z.
				}
				PRINT "--------------------------------------------".
			
			//Vessel and movement data-----------------------------\\
				CLEARSCREEN.
				PRINT "Remaining distance: " + shipToPoint_Vector:MAG.
				PRINT " ".
				PRINT "Component velocities".
				PRINT "--------------------------------------------".
				PRINT "X : " + relative_velocity_CA_Vector:X.
				PRINT "Y : " + relative_velocity_CA_Vector:Y.
				PRINT "Z : " + relative_velocity_CA_Vector:Z.
				PRINT " ".
				PRINT "Required component velocities".
				PRINT "--------------------------------------------".
				PRINT "X : " + coastVelocityVector:X.
				PRINT "Y : " + coastVelocityVector:Y.
				PRINT "Z : " + coastVelocityVector:Z.
				PRINT " ".
				PRINT "Thrust proportions".
				PRINT "--------------------------------------------".
				PRINT "X : " + proportionalThrustVec:X.
				PRINT "Y : " + proportionalThrustVec:Y.
				PRINT "Z : " + proportionalThrustVec:Z.
				PRINT " ".
				PRINT "Deceleration parameters".
				PRINT "--------------------------------------------".
				PRINT "Target deceleration : " + base_acceleration.
				PRINT "RCS thrust percent  : " + rcsThrustPercent.
				PRINT "Thrust time         : " + thrust_time.
				PRINT "Distance start      : " + distance_start.
			
			//Draw helper vectors----------------------------------\\
				SET toTargetVec TO VECDRAWARGS(SHIP:POSITION, (hostObj:POSITION + vec) - SHIP:POSITION,RED,"Path",1,TRUE).
				SET xVecProj TO VECDRAWARGS(SHIP:POSITION,custom_xVec*10,GREEN,"X (Line-up)",1,TRUE).		
				SET yVecProj TO VECDRAWARGS(SHIP:POSITION,custom_yVec*10,YELLOW,"Y",1,TRUE).		
				SET zVecProj TO VECDRAWARGS(SHIP:POSITION,custom_zVec*10,WHITE,"Z",1,TRUE).
			//-----------------------------------------------------//
		}

	//-------------------------------------------------------------\\
	//Deceleration to point----------------------------------------//	
		//UNLOCK distance_start.	
		//
		//LOCK STEERING TO smoothRotate(SHIP:FACING).
		//SET SHIP:CONTROL:FORE TO -(rcsThrustPercent).		
		//WAIT thrust_time.
		//	SET SHIP:CONTROL:FORE TO 0.	
		//	removeDrawnVecs.
			
			
		//DECELERATION REWRITE
		UNLOCK distance_start.	
		
		LOCK STEERING TO smoothRotate(SHIP:FACING).
		//SECTIONS							Scaling			|	Percent		|		Proportion			|						Sign					| X-halved
		SET SHIP:CONTROL:FORE TO -accelerationScaleMultiplier*rcsThrustPercent*proportionalThrustVec:X *(ABS(relative_velocity_CA_Vector:X)/relative_velocity_CA_Vector:X) * xThrustHalver. //X-thrust is halved due to double maxmimum thrust of others
		SET SHIP:CONTROL:TOP TO -accelerationScaleMultiplier*rcsThrustPercent*proportionalThrustVec:Y *(ABS(relative_velocity_CA_Vector:Y)/relative_velocity_CA_Vector:Y).
		SET SHIP:CONTROL:STARBOARD TO -accelerationScaleMultiplier*rcsThrustPercent*proportionalThrustVec:Z *(ABS(relative_velocity_CA_Vector:Z)/relative_velocity_CA_Vector:Z).
		//																												Used coastVelocityVector here before
		WAIT thrust_time.
			SET SHIP:CONTROL:FORE TO 0.
			SET SHIP:CONTROL:TOP TO 0.
			SET SHIP:CONTROL:STARBOARD TO 0.
			removeDrawnVecs.
			
			
			
			
		//IF (Vec:MAG < 1)
		IF ((hostObj:POSITION - SHIP:POSITION):MAG > 2){ //If not docking, completely cancel velocity
			cancelVel(0.05).
		}

	PRINT ("Move-to-point completed.").
	PRINT ("Error distance : " + (hostObj:POSITION + Vec - SHIP:POSITION):MAG).
	WAIT 5.
	
	SET SHIP:CONTROL:FORE TO 0.
	SET SHIP:CONTROL:TOP TO 0.
	SET SHIP:CONTROL:STARBOARD TO 0.
}
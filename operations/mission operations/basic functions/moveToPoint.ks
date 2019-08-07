	@lazyglobal OFF.
	CLEARSCREEN.
	
	
//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _host.
	PARAMETER _posVec.
	PARAMETER _facing IS SHIP:FACING.
	PARAMETER _selfRef IS SHIP.	
	
	
//--------------------------------------------------------------------------\
//								 Imports					   				|
//--------------------------------------------------------------------------/


	RUNONCEPATH("lib/math.ks").	
	RUNONCEPATH("lib/shipControl.ks").	
	

//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/


	//Uses the node position of the port if it is a docking port
	LOCAL hostRoot IS (CHOOSE _host:SHIP IF (NOT _host:ISTYPE("vessel")) ELSE _host).
	LOCK hostPos TO (CHOOSE _host:NODEPOSITION IF _host:ISTYPE("DockingPort") ELSE _host:POSITION).
	LOCK refPos TO (CHOOSE _selfRef:NODEPOSITION IF _selfRef:ISTYPE("DockingPort") ELSE _selfRef:POSITION).

	//Velocity at which the craft will move towards the target point
	LOCAL moveSpeed IS 1.5.

	//Records the vector so that we may create a line
	LOCAL startVec IS (SHIP:POSITION - (hostPos + _posVec)). //No need to lock it to _host's centered coordinates right?
	
	//Holds the starting and ending positions relative to the host
	LOCAL LOCK startPosition TO (hostPos + _posVec + startVec).
	LOCAL LOCK endPosition TO (hostPos + _posVec).
	
	//Holds the position and velocity differences, and converts to ship-centered-coordinates
	LOCK posDiff TO toShipCentered(SHIP, projectToPlane(refPos - endPosition, startPosition - endPosition)).
	LOCK velDiff TO toShipCentered(SHIP, (SHIP:VELOCITY:ORBIT - hostRoot:VELOCITY:ORBIT) - (endPosition - startPosition):NORMALIZED*moveSpeed).
	
	//The drawn vectors
	LOCAL vdHost IS 0.
	LOCAL vdPos IS 0.

	//----------------------------------------------------\
	//PID loops-------------------------------------------|
		//Position PID values
		LOCAL wn_pos IS 2.					//3
		LOCAL zeta_pos IS 2.				//4
		LOCAL Kp_pos IS (wn_pos^2)*SHIP:MASS.	//
		LOCAL Kd_pos IS 2*SHIP:MASS*zeta_pos*wn_pos.//
		LOCAL Ki_pos IS 0.					//0.01
		LOCAL deadBand_pos IS 0.002. 		//If under 0.05, don't thrust
		
		//Velocity PID values
		LOCAL wn_vel IS 0.5. //2				//3
		LOCAL zeta_vel IS 0.1.	 //2			//4
		LOCAL Kp_vel IS (wn_vel^2)*SHIP:MASS.		//
		LOCAL Kd_vel IS 2*SHIP:MASS*zeta_vel*wn_vel.	//
		LOCAL Ki_vel IS 0.						//0.01
		LOCAL deadBand_vel IS 0.1.				//If under 0.05, don't thrust
			
		//PID X-axis position
		LOCAL xPID_pos IS PIDLOOP(Kp_pos, Ki_pos, Kd_pos).
			SET xPID_pos:SETPOINT TO 0.
			SET xPID_pos:MAXOUTPUT TO 1.
			SET xPID_pos:MINOUTPUT TO -1.
			
		//PID Y-axis position
		LOCAL yPID_pos IS PIDLOOP(Kp_pos, Ki_pos, Kd_pos).
			SET yPID_pos:SETPOINT TO 0.
			SET yPID_pos:MAXOUTPUT TO 1.
			SET yPID_pos:MINOUTPUT TO -1.
			
		//PID Z-axis position
		LOCAL zPID_pos IS PIDLOOP(Kp_pos, Ki_pos, Kd_pos).
			SET zPID_pos:SETPOINT TO 0.
			SET zPID_pos:MAXOUTPUT TO 1.
			SET zPID_pos:MINOUTPUT TO -1.
	
		//PID X-axis velocity
		LOCAL xPID_vel IS PIDLOOP(Kp_vel, Ki_vel, Kd_vel). //Need diff values for this one
			SET xPID_vel:SETPOINT TO 0.
			SET xPID_vel:MAXOUTPUT TO 1.
			SET xPID_vel:MINOUTPUT TO -1.
			
		//PID Y-axis velocity
		LOCAL yPID_vel IS PIDLOOP(Kp_vel, Ki_vel, Kd_vel).
			SET yPID_vel:SETPOINT TO 0.
			SET yPID_vel:MAXOUTPUT TO 1.
			SET yPID_vel:MINOUTPUT TO -1.
			
		//PID Z-axis velocity
		LOCAL zPID_vel IS PIDLOOP(Kp_vel, Ki_vel, Kd_vel).
			SET zPID_vel:SETPOINT TO 0.
			SET zPID_vel:MAXOUTPUT TO 1.
			SET zPID_vel:MINOUTPUT TO -1.		
			
	
	//----------------------------------------------------\
	//RCS scaling-----------------------------------------|	
		//Finds the maximum thrust in each axis
		LOCAL axlThr IS getRCSThrustAxis().
		LOCAL xMax IS MAX(axlThr["px"], axlThr["nx"]).
		LOCAL yMax IS MAX(axlThr["py"], axlThr["ny"]).
		LOCAL zMax IS MAX(axlThr["pz"], axlThr["nz"]).
		LOCAL allMin IS MINS(axlThr:VALUES).
		
		//Scaling for thrust axis
		LOCAL xScale IS 0.
		LOCAL yScale IS 0.
		LOCAL zScale IS 0.
		
		//X is the lowest
		IF(xMax <= yMax AND xMax <= zMax){
			SET xScale TO 1.
			SET yScale TO xMax/yMax.
			SET zScale TO xMax/zMax.
		}
		//Y is the lowest
		ELSE IF(yMax <= xMax AND yMax <= zMax){
			SET xScale TO yMax/xMax.
			SET yScale TO 1.
			SET zScale TO yMax/zMax.
		}
		//Z is the lowest
		ELSE IF(zMax <= xMax AND zMax <= zMax){
			SET xScale TO zMax/xMax.
			SET yScale TO zMax/yMax.
			SET zScale TO 1.	
		}
		
		//Holds the forward velocity and the stopping distance
		LOCAL LOCK forwardVel TO (endPosition - refPos):NORMALIZED*(SHIP:VELOCITY:ORBIT - hostRoot:VELOCITY:ORBIT).
		LOCAL LOCK stoppingDistance TO forwardVel^2 / (2*allMin/SHIP:MASS).
		
		
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/

	
	LOCK STEERING TO _facing.
	RCS ON.

	//----------------------------------------------------\
	//Initial approach------------------------------------|
		//Maintains a forward velocity and keeps the craft on the 'line' until it has reach 1.5x the stopping distance		
		UNTIL((endPosition - refPos):MAG <= 1.5*stoppingDistance){ //Basically as long as we pass it, it exits it... Fix this?
			
			//Maintains the X-axis thrust
			IF(ABS(posDiff:X) > deadBand_pos OR ABS(velDiff:X) > deadBand_vel){
				SET SHIP:CONTROL:FORE TO (xPID_pos:UPDATE(TIME:SECONDS, posDiff:X) + xPID_vel:UPDATE(TIME:SECONDS, velDiff:X))*xScale. }
			ELSE{
				SET SHIP:CONTROL:FORE TO 0. }
			
			//Maintains the Y-axis thrust
			IF(ABS(posDiff:Y) > deadBand_pos OR ABS(velDiff:Y) > deadBand_vel){
				SET SHIP:CONTROL:TOP TO (yPID_pos:UPDATE(TIME:SECONDS, posDiff:Y) + yPID_vel:UPDATE(TIME:SECONDS, velDiff:Y))*yScale. }
			ELSE{
				SET SHIP:CONTROL:TOP TO 0. }
			
			//Maintains the Z-axis thrust
			IF(ABS(posDiff:Z) > deadBand_pos OR ABS(velDiff:Z) > deadBand_vel){
				SET SHIP:CONTROL:STARBOARD TO (zPID_pos:UPDATE(TIME:SECONDS, posDiff:Z) + zPID_vel:UPDATE(TIME:SECONDS, velDiff:Z))*zScale. }
			ELSE{
				SET SHIP:CONTROL:STARBOARD TO 0. }

			//Outputs some info to the terminal
			CLEARSCREEN.
			SET vdHost TO VECDRAWARGS(hostPos, _posVec, RED, "Host vector", 1, TRUE).
			SET vdPos TO VECDRAWARGS(hostPos + _posVec, startVec, RED, "Line vector", 1, TRUE).
			PRINT("Host vessel		: " + hostRoot:NAME).
			PRINT("Forward velocity : " + ROUND(forwardVel, 3) + " m/s").
			PRINT("Distance 		: " + ROUND((endPosition - refPos):MAG, 3) + " m").
			WAIT 0.01.
		}

	//----------------------------------------------------\
	//Final approach-----------------------------------------|
		//Switches to using only the position PIDs for the final movement
		LOCK posDiff TO toShipCentered(SHIP, refPos - endPosition).
		LOCK velDiff TO toShipCentered(SHIP, (SHIP:VELOCITY:ORBIT - hostRoot:VELOCITY:ORBIT)).
		UNTIL(posDiff:MAG < 3*deadBand_pos){ //AND velDiff:MAG < deadBand_vel
		
			//Maintains the X-axis thrust
			IF(ABS(posDiff:X) > deadBand_pos){
				SET SHIP:CONTROL:FORE TO xPID_pos:UPDATE(TIME:SECONDS, posDiff:X)*xScale. }
			ELSE{
				SET SHIP:CONTROL:FORE TO 0. }
			
			//Maintains the Y-axis thrust
			IF(ABS(posDiff:Y) > deadBand_pos){
				SET SHIP:CONTROL:TOP TO yPID_pos:UPDATE(TIME:SECONDS, posDiff:Y)*yScale. }
			ELSE{
				SET SHIP:CONTROL:TOP TO 0. }
			
			//Maintains the Z-axis thrust
			IF(ABS(posDiff:Z) > deadBand_pos){
				SET SHIP:CONTROL:STARBOARD TO zPID_pos:UPDATE(TIME:SECONDS, posDiff:Z)*zScale. }
			ELSE{
				SET SHIP:CONTROL:STARBOARD TO 0. }

			//Outputs some info to the terminal
			CLEARSCREEN.
			SET vdHost TO VECDRAWARGS(hostPos, _posVec, RED, "Host vector", 1, TRUE).
			SET vdPos TO VECDRAWARGS(hostPos + _posVec, startVec, RED, "Line vector", 1, TRUE).
			PRINT("Host vessel		: " + hostRoot:NAME).
			PRINT("Forward velocity : " + ROUND(forwardVel, 3) + " m/s").
			PRINT("Distance 		: " + ROUND((endPosition - refPos):MAG, 3) + " m").
			WAIT 0.01.
		}
	
		
//--------------------------------------------------------------------------\
//								Program end					   				|
//--------------------------------------------------------------------------/	
	
	CLEARVECDRAWS().
	UNLOCK hostPos.	
	UNLOCK refPos.	
	UNLOCK startPosition.	
	UNLOCK endPosition.	
	UNLOCK posDiff.	
	UNLOCK velDiff.	
	UNLOCK forwardVel.	
	UNLOCK stoppingDistance.	
	RCS OFF.
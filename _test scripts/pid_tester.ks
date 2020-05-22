	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
	
	SET altReq TO 1000. //75, 68
	//lock Fg to ship:mass * body:mu /((ship:altitude + body:radius)^2).
	//lock am to vang(up:vector, ship:facing:vector).
	set T_star to 0.
	
	//set wn to 1.
	//set zeta to 1.
	//set Kp to wn^2 * ship:mass.
	//set Kd to 2 * ship:mass * zeta * wn.
	//set Ki to 0.0.
	
	ON(AG1){
		SET PID:SETPOINT TO 1000.
		GEAR OFF.
		PRESERVE.
	}
	ON(AG2){
		SET PID:SETPOINT TO 68.
		GEAR ON.
		PRESERVE.
	}
	
	
	//This setup slows it down early
	set wn to 1.
	set zeta to 3.
	set Kp to wn^2 * ship:mass.
	set Kd to 2 * ship:mass * zeta * wn.
	set Ki to 0.0.
	SET close_Ki TO 1.
	
	//This setup slows it down early
	set wn to 3.
	set zeta to 4.5.//4.35.
	set Kp to wn^2 * ship:mass.
	set Kd to 2 * ship:mass * zeta * wn.
	set Ki to 0.0.
	SET close_Ki TO 1.
	
	

	LOCK STEERING TO UP.
	STAGE.

	SET PID TO PIDLOOP(Kp, Ki, Kd).
	SET PID:SETPOINT TO altReq.
	SET PID:MAXOUTPUT TO ship:availablethrust.
	SET PID:MINOUTPUT TO 0.
	
	//WAIT UNTIL (VERTICALSPEED <= 1).
	lock throttle to T_star / ship:availablethrust.
	GEAR OFF.
	
	
	UNTIL(FALSE){
		CLEARSCREEN.
		PRINT(ALTITUDE).
		SET T_star TO PID:UPDATE(TIME:SECONDS, ALTITUDE).
		IF(ABS(altReq - ALTITUDE) <= 10){
			SET PID:KI TO 2.
		}
		ELSE{
			SET PID:KI TO close_Ki.
		}
		WAIT 0.001.
	}





	
IF(FALSE){	
	SET Kp TO 0.01.
	SET Ki TO 0.001.
	SET Kd TO 0.1.
	SET PID TO PIDLOOP(Kp, Ki, Kd).
	SET PID:SETPOINT TO 0.

	SET Kp2 TO 0.01.
	SET Ki2 TO 0.001.
	SET Kd2 TO 0.1.
	SET PID2 TO PIDLOOP(Kp2, Ki2, Kd2).
	SET PID2:SETPOINT TO 1000.

	SET thrott TO 1.
	LOCK STEERING TO UP.
	LOCK THROTTLE TO thrott.
	STAGE.
	GEAR OFF.
	WAIT 2.
	LOCK THROTTLE TO 0.
	
	WAIT UNTIL (VERTICALSPEED <= 1).
	print("got here").
	LOCK THROTTLE TO thrott.
	
	
	UNTIL(FALSE){
		SET thrott TO thrott + PID:UPDATE(TIME:SECONDS, VERTICALSPEED). 
		SET thrott TO thrott + PID2:UPDATE(TIME:SECONDS, ALTITUDE). 
		WAIT 0.001.
	}
}


IF(FALSE){
	SET g TO KERBIN:MU / KERBIN:RADIUS^2.
	LOCK accvec TO SHIP:SENSORS:ACC - SHIP:SENSORS:GRAV.
	LOCK gforce TO accvec:MAG / g.

	SET Kp TO 0.01.
	SET Ki TO 0.006.
	SET Kd TO 0.006.
	SET PID TO PIDLOOP(Kp, Ki, Kd).
	SET PID:SETPOINT TO 1.0.

	SET thrott TO 0.
	LOCK STEERING TO UP.
	LOCK THROTTLE TO thrott.
	STAGE.
	GEAR OFF.
	WAIT 2.
	LOCK THROTTLE TO 0.
	
	WAIT UNTIL (VERTICALSPEED <= 1).
	print("got here").
	LOCK THROTTLE TO thrott.

	UNTIL(FALSE){
		SET thrott TO thrott + PID:UPDATE(TIME:SECONDS, gforce). 
		//pid:update() is given the input time and input and returns the output. gforce is the input.
		WAIT 0.001.
	}
}




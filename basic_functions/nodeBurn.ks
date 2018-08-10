	//CLEARSCREEN.

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _timeToPeak. 
	PARAMETER _burnDV.
	PARAMETER _dirVector IS V(0,0,0).
	
	
//--------------------------------------------------------------------------\
//							 Reboot conditions					   			|
//--------------------------------------------------------------------------/
	
	
	//Finds the likely available deltaV
	LOCAL totalISP IS 0. LOCAL numEngines IS 0. LIST ENGINES IN eng_list.
	FOR e IN eng_list {
		IF(e:IGNITION){
			SET totalISP TO totalISP + e:ISP.
			SET numEngines TO numEngines + 1.
		}
	}
	LOCAL delta_v IS 9.80665*(totalISP/numEngines)*LN(SHIP:WETMASS/SHIP:DRYMASS).
		SET delta_v TO 99999999999999.
	
	IF(SHIP:AVAILABLETHRUST = 0) {PRINT("No thrust").}
	IF(_dirVector = V(0,0,0)) {PRINT("No vector").}
	IF(delta_v < _burnDV) {PRINT("No DV").}
	
	IF(SHIP:AVAILABLETHRUST = 0 OR _dirVector = V(0,0,0) OR delta_v < _burnDV){	
		PRINT ("Operation conditions not met ( " + SCRIPTPATH():NAME + " ).").
		PRINT ("Rebooting. . ."). 
		WAIT 3. REBOOT.
	}
	
	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/


	//Heading direction
	LOCAL orbNormal IS VCRS(SHIP:POSITION - SHIP:BODY:POSITION, SHIP:VELOCITY:ORBIT).	
	IF _dirVector = 1 {
		LOCK t_vec TO SHIP:VELOCITY:ORBIT. } //Orbit prograde
	ELSE IF _dirVector = 2 {
		LOCK t_vec TO -SHIP:VELOCITY:ORBIT. } //Orbit retrograde
	ELSE IF _dirVector = 3 {
		LOCK t_vec TO SHIP:VELOCITY:SURFACE. } //Surface prograde
	ELSE IF _dirVector = 4 {
		LOCK t_vec TO -SHIP:VELOCITY:SURFACE. } //Surface retrograde
	ELSE IF _dirVector = 5 {
		LOCK t_vec TO -orbNormal. } //Radial 'up' (LH)
	ELSE IF _dirVector = 6 {
		LOCK t_vec TO orbNormal. } //Radial 'down' (LH)
	ELSE IF _dirVector = 7 {
		LOCK t_vec TO VCRS(-orbNormal, VELOCITY:ORBIT). } //Normal 'out' (LH)
	ELSE IF _dirVector = 8 {
		LOCK t_vec TO VCRS(orbNormal, VELOCITY:ORBIT). } //Normal 'in' (LH)
	ELSE {
		SET t_vec TO _dirVector. } //Custom direction (Must predict ahead of time)

	
	//Burn parameters
	SET base_acceleration TO SHIP:AVAILABLETHRUST / SHIP:MASS. //Mass in metric tonnes	
		SET burnTime TO _burnDV / base_acceleration.
		LOCK thrustPercent TO (base_acceleration * SHIP:MASS) / SHIP:AVAILABLETHRUST.
		
		
	//Burn timing
	SET startTime TO TIME:SECONDS + _timeToPeak.
	LOCK timeLeft TO (startTime - TIME:SECONDS).
	
	//Wait time for info
	LOCAL waitTime IS 1.
	
	
	//Expected final vector
	//This won't work properly on longer burns
	//LOCAL velFuture IS VELOCITYAT(SHIP, TIME:SECONDS + _timeToPeak). // + burnTime/2
	//LOCAL expectedVector IS velFuture:ORBIT + t_vec*_burnDV. //Need to find the expected vector at Apo + 1/2 burnTime


//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	//Disables user control
	SET CONTROLSTICK to SHIP:CONTROL. 
	SAS ON.
	RCS OFF. //ON.
	WAIT waitTime. //Incase ship was moving
	
	
	//Warp to the position,
	PRINT("     Node-burn subscript     ").
	PRINT("-----------------------------").
	PRINT("Warping to burn position. . .").
	KUNIVERSE:TIMEWARP:WARPTO(startTime - waitTime - (burnTime/2 + 20)).
	WAIT UNTIL WARP = 0 and SHIP:UNPACKED.
	
	
	//(TRIGGER) Once there are 20 seconds until the start of the burn, orientate
	WHEN (timeLeft <= (burnTime/2 + 20)) THEN { LOCK STEERING TO smoothRotate(t_vec:DIRECTION). }
	
	//Display info until the burn starts
	UNTIL timeLeft <= burnTime/2{
		CLEARSCREEN.
		PRINT "Node-burn subscript".
		PRINT "--------------------".
		PRINT "ΔV 					: " + (ROUND(_burnDV*10)/10)  + " m/s".
		PRINT "Burn time 			: " + (ROUND(burnTime*10)/10)  + " s".
		PRINT " ".
		IF(timeLeft > (burnTime/2 + 20)){
			PRINT "Time to orientation  : " + (ROUND((timeLeft - burnTime/2 - 20)*10)/10) + " s". }
		ELSE {
			PRINT "Time to orientation	: Orientating . . .". }		
		PRINT "Time to burn  		: " + (ROUND((timeLeft - burnTime/2)*10)/10) + " s".
		
		SET bv TO VECDRAWARGS(SHIP:POSITION, t_vec:NORMALIZED*10,RED,"Thrust vector",1,TRUE).
		
		WAIT 0.1.
	}
	
	
	//Perform the burn
	LOCK THROTTLE TO thrustPercent. 

	IF(burnTime > 1.5){
		WAIT burnTime - 1.
			//Throttles down linearly for the last 2 seconds
			LOCAL timer IS TIME:SECONDS + 2.
			LOCK THROTTLE TO 0.5*thrustPercent*(timer - TIME:SECONDS).		
			WAIT 2.		
	}
	ELSE {
		WAIT burnTime.
	}	
	LOCK THROTTLE TO 0.	

	
	//Corrects velocity
	//IF(_dirVector <> 4){
		//RUN cancelVelocity(expectedVector, 0.05).
	//}
	
	
//--------------------------------------------------------------------------\
//								Program end					   				|
//--------------------------------------------------------------------------/


	
	
	//Returns user control
	SET SHIP:CONTROL:NEUTRALIZE to TRUE.
	SAS OFF.
	RCS OFF.
	
	//Unlock all variables		
	UNLOCK Xa.
	UNLOCK Ya.
	UNLOCK Za.
	UNLOCK c_relVel.
	UNLOCK differenceVec.	
	UNLOCK thrustPercent.
	UNLOCK STEERING.
	UNLOCK THROTTLE.
	
	//Remove drawn vectors
	CLEARVECDRAWS().
	
	WAIT 1.

	
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
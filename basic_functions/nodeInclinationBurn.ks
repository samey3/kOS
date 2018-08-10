	CLEARSCREEN.

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _timeToPeak. 
	PARAMETER _inclinationChange.
	
	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/

	
	LOCAL velFuture IS VELOCITYAT(SHIP, TIME:SECONDS + _timeToPeak).
	LOCAL orbNormal IS VCRS(SHIP:POSITION - SHIP:BODY:POSITION, SHIP:VELOCITY:ORBIT):NORMALIZED.
	LOCAL e_vec IS (-orbNormal*(TAN(_inclinationChange)*velFuture:ORBIT:MAG) + velFuture:ORBIT):NORMALIZED * velFuture:ORBIT:MAG.
		IF(_inclinationChange < 0){
			//SET e_vec TO -e_vec. 
			//WORKED FINE BEFORE COMMENTING???
			
			//This function needs fixing, its not entirely accurate, 0.7 degrees???? off and such sometimes.
		}

	LOCAL t_vec IS (e_vec - velFuture:ORBIT).
	LOCAL _burnDV IS t_vec:MAG.
	
	
	//For info display
	LOCAL waitTime IS 3.
	

//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	SET ev TO VECDRAWARGS(SHIP:POSITION, e_vec:NORMALIZED*10,BLUE,"Inclined vector",1,TRUE).
	SET cv TO VECDRAWARGS(SHIP:POSITION, velFuture:ORBIT:NORMALIZED*10,GREEN,"Current vector",1,TRUE).
	
	PRINT("   Modifying orbit inclination   ").
	PRINT("---------------------------------").
	PRINT("(+ is above the plane in LHR up)").
	PRINT(" ").
	PRINT("Inclination change : " + ROUND(_inclinationChange*10)/10 + " degrees").	
	WAIT waitTime.
	
	//Calls the nodeBurn
	RUNPATH("basic_functions/nodeBurn.ks", _timeToPeak - waitTime, (e_vec - velFuture:ORBIT):MAG, (e_vec - velFuture:ORBIT)). //_burnDV, t_vec
	
	
//--------------------------------------------------------------------------\
//								Program end					   				|
//--------------------------------------------------------------------------/


	//Remove drawn vectors
	CLEARVECDRAWS().
	CLEARSCREEN.
		
//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/
	
	
	PARAMETER _targetCraft IS 0. 
	IF (_targetCraft = 0 AND HASTARGET = True) {
		SET _targetCraft TO TARGET. }	

	
//--------------------------------------------------------------------------\
//				  		  Top-level function fix						    |
//--------------------------------------------------------------------------/

	LOCK STEERING TO SHIP:FACING.
	LOCK THROTTLE TO 0.
	UNLOCK STEERING.
	UNLOCK THROTTLE.
		
	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	//Matches the target's orbit
	RUNPATH("/basic_functions/matchOrbit.ks", _targetCraft).

	//Performs a basic rendezvous
	RUNPATH("/basic_functions/basicRendezvous.ks", _targetCraft).

	//Performs linear rendezvous
	LOCK targ_vec TO (_targetCraft:POSITION - SHIP:POSITION).
	LOCK rv_vec TO (SHIP:VELOCITY:ORBIT - _targetCraft:VELOCITY:ORBIT).
	IF(targ_vec:MAG > 200){
		//Cancel relative velocity
		IF(rv_vec:MAG > 3){
		RUNPATH("basic_functions/nodeBurn.ks", 20, rv_vec:MAG, -rv_vec). }
		RUNPATH("basic_functions/nodeBurn.ks", 20, rv_vec:MAG, -rv_vec).
	
		//Accelerates towards the target
		LOCAL t_vec IS (targ_vec:NORMALIZED*(targ_vec:MAG - 200)/250).
		RUNPATH("basic_functions/nodeBurn.ks", 20, t_vec:MAG, t_vec).
		
		//Decelerates
		LOCAL arrivalTime IS (targ_vec:MAG/rv_vec:MAG).
		RUNPATH("basic_functions/nodeBurn.ks", arrivalTime, rv_vec:MAG, -rv_vec).
	}
	
	//Removes any excessive relative velocity
	IF(rv_vec:MAG > 5){
		RUNPATH("basic_functions/nodeBurn.ks", 20, rv_vec:MAG, -rv_vec). }
	
	//Cancels all relative velocity
	RUNPATH("basic_functions/modVelocity.ks", _targetCraft, V(0,0,0)).
	
	
//--------------------------------------------------------------------------\
//								Program end					   				|
//--------------------------------------------------------------------------/

	
	UNLOCK targ_vec.
	UNLOCK rv_vec.

//-----------------------------------------------------------------------------------------------------------
// 	Name: solarVelocity
//	Parameters : 
//		- Gets an object's velocity relative to the sun (needed for planets, as by default returns relative to current body).
//	
//-----------------------------------------------------------------------------------------------------------
FUNCTION solarVelocity {
	PARAMETER _body.
	RETURN -(SUN:VELOCITY:ORBIT - _body:VELOCITY:ORBIT).
}


//-----------------------------------------------------------------------------------------------------------
// 	Name: nodeFromVector
//	Parameters : 
//		- Converts time and vector to a maneuver node
//	
//-----------------------------------------------------------------------------------------------------------
FUNCTION nodeFromVector {

	//--------------------------------------------------------------------------\
	//								Parameters					   				|
	//--------------------------------------------------------------------------/


		PARAMETER _time.
		PARAMETER _vector.
		
		
	//--------------------------------------------------------------------------\
	//								 Imports					   				|
	//--------------------------------------------------------------------------/		
	
	
		RUNONCEPATH("RESTRUCTURE V3/lib/math.ks").
		
		
	//--------------------------------------------------------------------------\
	//								Variables					   				|
	//--------------------------------------------------------------------------/	
		

		LOCAL m_pos IS POSITIONAT(SHIP, _time) - SHIP:BODY:POSITION. //POSITIONAT(SHIP:BODY, _time)
		LOCAL m_pro IS VELOCITYAT(SHIP, _time):ORBIT.
		LOCAL m_norm IS VCRS(m_pro, m_pos).
		LOCAL m_rad IS VCRS(m_norm, m_pro).
			
			
	//--------------------------------------------------------------------------\
	//							   Function run					   				|
	//--------------------------------------------------------------------------/

	
		//Find the resulting components
		LOCAL pro IS _vector*m_pro:NORMALIZED.
		LOCAL norm IS _vector*m_norm:NORMALIZED.
		LOCAL rad IS _vector*m_rad:NORMALIZED.
		
		//Return as a node
		RETURN NODE(_time, rad, norm, pro).
}


//-----------------------------------------------------------------------------------------------------------
// 	Name: nodeFromDesiredVector
//	Parameters : 
//		- Creates a node where the resultant velocity is equal to the input vector
//	
//-----------------------------------------------------------------------------------------------------------
FUNCTION nodeFromDesiredVector {

	//--------------------------------------------------------------------------\
	//								Parameters					   				|
	//--------------------------------------------------------------------------/


		PARAMETER _time.
		PARAMETER _vector.
		
		
	//--------------------------------------------------------------------------\
	//								Variables					   				|
	//--------------------------------------------------------------------------/	
	
	
		LOCAL changeVector IS (_vector - VELOCITYAT(SHIP, _time):ORBIT).
		
		
	//--------------------------------------------------------------------------\
	//							   Function run					   				|
	//--------------------------------------------------------------------------/
	
	
		return nodeFromVector(_time, changeVector).
}
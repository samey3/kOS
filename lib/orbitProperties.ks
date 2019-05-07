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
// 	Name: meanAnomaly
//	Parameters : 
//		- Gets an an object's mean anomaly
//	
//-----------------------------------------------------------------------------------------------------------
FUNCTION meanAnomaly {
	PARAMETER _body.

	//Position and eccentricity vectors
	LOCAL posVec IS _body:POSITION - _body:BODY:POSITION.
	LOCAL eccVec IS (_body:VELOCITY:ORBIT:MAG^2/_body:BODY:MU - 1 / posVec:MAG)*posVec - (VDOT(posVec, _body:VELOCITY:ORBIT)/_body:BODY:MU)*_body:VELOCITY:ORBIT.
	
	//Eccentric anomaly
	LOCAL E IS 2*ARCTAN2(SIN(_body:ORBIT:TRUEANOMALY/2)*SQRT((1 - eccVec:MAG) / (1 + eccVec:MAG)), COS(_body:ORBIT:TRUEANOMALY/2)).
	
	//Mean anomaly
	LOCAL M IS CONSTANT:RADTODEG * ((CONSTANT:DEGTORAD * _body:ORBIT:ECCENTRICITY) - eccVec:MAG*SIN(_body:ORBIT:ECCENTRICITY)).
	
	RETURN M.
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
	
	
		RUNONCEPATH("lib/math.ks").
		
		
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
	
	
		RETURN nodeFromVector(_time, changeVector).
}

//-----------------------------------------------------------------------------------------------------------
// 	Name: changeVectorFromNode
//	Parameters : 
//		- Returns the velocity change vector of the node at the maneuver time
//	
//-----------------------------------------------------------------------------------------------------------
FUNCTION changeVectorFromNode {

	//--------------------------------------------------------------------------\
	//								Parameters					   				|
	//--------------------------------------------------------------------------/


		PARAMETER _node.
		
		
	//--------------------------------------------------------------------------\
	//							   Function run					   				|
	//--------------------------------------------------------------------------/
	
	
		RETURN _node:DELTAV.
}

//-----------------------------------------------------------------------------------------------------------
// 	Name: changeVectorFromNode
//	Parameters : 
//		- Returns the final velocity vector of the node at the maneuver time
//	
//-----------------------------------------------------------------------------------------------------------
FUNCTION finalVectorFromNode {

	//--------------------------------------------------------------------------\
	//								Parameters					   				|
	//--------------------------------------------------------------------------/


		PARAMETER _node.
		
		
	//--------------------------------------------------------------------------\
	//								Variables					   				|
	//--------------------------------------------------------------------------/
	
	
		LOCAL velocityAtTime IS VELOCITYAT(SHIP, TIME:SECONDS + _node:ETA).
		LOCAL velocityChange IS _node:DELTAV.
		
		
	//--------------------------------------------------------------------------\
	//							   Function run					   				|
	//--------------------------------------------------------------------------/
	
	
		RETURN velocityAtTime + velocityChange.
}
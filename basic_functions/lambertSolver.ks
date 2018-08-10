







FUNCTION Lambert {


//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER r1_in.
	PARAMETER r2_in.
	PARAMETER p_t.
	PARAMETER mu.
	PARAMETER lw.
	
	
//--------------------------------------------------------------------------\
//								  Output					   				|
//--------------------------------------------------------------------------/


	LOCAL v1 IS 0.
	LOCAL v2 IS 0.
	LOCAL a IS 0.
	LOCAL p IS 0.
	LOCAL theta IS 0.
	LOCAL iter IS 0.

	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/	


	LOCAL V IS 0.
	LOCAL T IS 0.
	LOCAL r2_mod IS 0.    // R2 module
	LOCAL dot_prod IS 0. // dot product
	LOCAL c IS 0.		        // non-dimensional chord
	LOCAL s IS 0.		        // non dimensional semi-perimeter
	LOCAL am IS 0.		        // minimum energy ellipse semi major axis
	LOCAL lambda IS 0.	        //lambda parameter defined in Battin's Book
	LOCAL x IS 0.
	LOCAL x1 IS 0.
	LOCAL x2 IS 0.
	LOCAL y1 IS 0.
	LOCAL y2 IS 0.
	LOCAL x_new IS 0.
	LOCAL y_new IS 0.
	LOCAL err IS 0.
	LOCAL alfa IS 0.
	LOCAL beta IS 0.
	LOCAL psi IS 0. 
	LOCAL eta IS 0.
	LOCAL eta2 IS 0.
	LOCAL sigma1 IS 0.
	LOCAL vr1 IS 0.
	LOCAL vt1 IS 0.
	LOCAL vt2 IS 0.
	LOCAL vr2 IS 0.
	LOCAL R IS 0.
	LOCAL i_count IS 0.
	LOCAL tolerance IS 0.
	
	LOCAL r1 IS LIST().
	LOCAL r2 IS LIST().
	LOCAL r2_vers IS LIST().
	LOCAL ih_dum IS LIST(). 
	LOCAL ih IS LIST(). 
	LOCAL dum IS LIST().

	// Increasing the tolerance does not bring any advantage as the
	// precision is usually greater anyway (due to the rectification of the tof
	// graph) except near particular cases such as parabolas in which cases a
	// lower precision allow for usual convergence.

	if (p_t <= 0)
	{
		PRINT("ERROR in Lambert Solver: Negative Time in input.").
		WAIT 3. REBOOT.
	}

	SET i TO 0.
	UNTIL(i >= 3)
	{
		r1:INSERT(i, r1_in[i]).
		r2:INSERT(i, r2_in[i]).
		SET R TO R + r1[i]*r1[i]).
		SET i TO i + 1.
	}

	SET R TO sqrt(R).
	SET V TO sqrt(mu/R).
	SET T TO R/V.

	// working with non-dimensional radii and time-of-flight
	SET p_t TO p_t/T.
	SET i TO 0.
	UNTIL(i >= 3)  // r1 dimension is 3
	{
		SET r1[i] TO r1[i]/R.
		SET r2[i] TO  r2[i]/R.
		SET r2_mod TO  r2_mod + r2[i]*r2[i].
		SET i TO i + 1.
	}

	// Evaluation of the relevant geometry parameters in non dimensional units
	SET r2_mod TO SQRT(r2_mod).

	SET i TO 0.
	UNTIL(i >= 3){
		SET dot_prod TO dot_prod + (r1[i] * r2[i]). 
		SET i TO i + 1.
	}

	SET theta TO ARCCOS(dot_prod/r2_mod).

	if (lw)
		SET theta TO 2*ARCCOS(-1)-theta.

	SET c TO SQRT(1 + r2_mod*(r2_mod - 2 * COS(theta))).
	SET s TO (1 + r2_mod + c)/2.
	SET am TO s/2.
	SET lambda TO SQRT(r2_mod) * COS(theta/2)/s.

	// We start finding the log(x+1) value of the solution conic:
	// NO MULTI REV --> (1 SOL)
	//	inn1=-.5233;    //first guess point
	//  inn2=.5233;     //second guess point
	SET x1 TO LOG(0.4767).
	SET x2 TO LOG(1.5233).
	SET y1 TO LOG(x2tof(-0.5233,s,c,lw))-LOG(p_t).
	SET y2 TO LOG(x2tof(0.5233,s,c,lw))-LOG(p_t).

	// Regula-falsi iterations
	SET err TO 1.
	SET i_count TO 0.
	UNTIL(NOT ((err>tolerance) && (y1 <> y2)))
	{
		SET i_count TO i_count + 1.
		SET x_new TO (x1*y2-y1*x2)/(y2-y1).
		SET y_new TO LOG(x2tof(exp(x_new)-1,s,c,lw))-LOG(p_t).
		SET x1 TO x2.
		SET y1 TO y2.
		SET x2 TO x_new.
		SET y2 TO y_new.
		SET err TO fabs(x1-x_new).
	}
	SET iter TO i_count.
	SET x TO exp(x_new)-1.

	// The solution has been evaluated in terms of log(x+1) or tan(x*pi/2), we
	// now need the conic. As for transfer angles near to pi the lagrange
	// coefficient technique goes singular (dg approaches a zero/zero that is
	// numerically bad) we here use a different technique for those cases. When
	// the transfer angle is exactly equal to pi, then the ih unit vector is not
	// determined. The remaining equations, though, are still valid.

	SET a TO am/(1 - x^2).

	// psi evaluation
	IF(x < 1)  // ellipse
	{
		SET beta TO 2 * ARCSIN(SQRT( (s-c)/(2*a) )).
		IF (lw) { SET beta TO -beta. }
		SET alfa TO 2*ARCCOS(x).
		SET psi TO (alfa-beta)/2.
		SET eta2 TO 2*a*SIN(psi)^2)/s.
		SET eta TO SQRT(eta2).
	}
	else       // hyperbola
	{
		SET beta TO 2*ASINH(SQRT((c-s)/(2*a))).
		IF (lw) { SET beta TO -beta. }
		SET alfa TO 2*ACOSH(x).
		SET psi TO (alfa-beta)/2.
		SET eta2 TO -2*a*(SINH(psi)^2)/s.
		SET eta TO SQRT(eta2).
	}

	// parameter of the solution
	SET p TO ( r2_mod / (am * eta2) ) * sin(theta/2)^2.
	SET sigma1 TO (1/(eta * sqrt(am)) )* (2 * lambda * am - (lambda + x * eta)).
	vett(r1,r2,ih_dum).
	vers(ih_dum,ih).

	IF(lw)
	{
		SET i TO 0.
		UNTIL(i >= 3){
			SET ih[i] TO -ih[i].
			SET i TO i + 1.
		}
	}

	SET vr1 TO sigma1.
	SET vt1 TO SQRT(p).
	SET vett(ih,r1,dum).

	SET i TO 0.
	UNTIL(i >= 3){
		SET v1[i] TO vr1 * r1[i] + vt1 * dum[i].
		SET i TO i + 1.
	}

	SET vt2 = vt1 / r2_mod.
	SET vr2 = -vr1 + (vt1 - vt2)/tan(theta/2).
	vers(r2,r2_vers).
	vett(ih,r2_vers,dum).
	SET i TO 0.
	UNTIL(i >= 3){
		SET v2[i] TO vr2 * r2[i] / r2_mod + vt2 * dum[i].
		SET i TO i + 1.
	}

	for (i = 0;i < 3;i++)
	{
		v1[i] *= V.
		v2[i] *= V.
	}
	SET i TO 0.
	UNTIL(i >= 3){
		SET v1[i] TO v1[i]*V.
		SET v2[i] TO v2[i]*V.
		SET i TO i + 1.
	}
	
	
	SET a TO a*R.
	SET p TO p*R.
}



FUNCTION IIF { PARAMETER c. PARAMETER t. PARAMETER f. IF c { RETURN t. } RETURN f. }
FUNCTION SINH { PARAMETER x. LOCAL K_DEGREES IS 180/K_PI. SET x TO x/K_DEGREES. RETURN (K_E^x - K_E^(-x))/2. }
FUNCTION COSH { PARAMETER x. LOCAL K_DEGREES IS 180/K_PI. SET x TO x/K_DEGREES. RETURN (K_E^x + K_E^(-x))/2. }
FUNCTION ASINH { PARAMETER x. PARAMETER y IS 0. LOCAL K_DEGREES IS 180/K_PI. RETURN IIF(y<0,-1,1)*K_DEGREES*LN(x+SQRT(x^2+1)). }
FUNCTION ACOSH { PARAMETER x. PARAMETER y IS 0. LOCAL K_DEGREES IS 180/K_PI. RETURN IIF(y<0,-1,1)*K_DEGREES*LN(x+SQRT(x^2-1)). }
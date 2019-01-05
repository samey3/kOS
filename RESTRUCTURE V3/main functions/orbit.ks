	@lazyglobal OFF.
	CLEARSCREEN.
	

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _orbitLex.


//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	RUNPATH("RESTRUCTURE V3/intermediate functions/refineOrbit.ks", _orbitLex, 10).
	//Run enough times till orbital parameters are sufficiently met. The solution to deciding whether it is met enough can be used in rendezvous as well.
	
	
	
	//Since we use a true anomaly as input, and we get a time-to-point as output (where the intersecton would occur),
	//we could perhaps convert it to mean anomaly (or was true needed?), and get the velocity vector at that point.
	
	//Can use flight path angle
	//https://en.wikipedia.org/wiki/Elliptic_orbit
	//http://www.braeunig.us/space/orbmech.htm Figure 4.8
	
	//Can acheive getting a vector for the plane of the orbit.
	//Assuming its all in our found plane (from plane vector), can use the parameters and true/mean anomaly
	//With something like an eccentricity vector, and can find a vector to a point at that time.
	//Then, AngleAxis(90 - flight path angle)
	
	//Can use vis-visa to get the speed, and thus combine vector/magnitude to find the velocity at that point.
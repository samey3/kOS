//Ship height is only required by the suicide burn

//Perhaps we can tag a part on the landing pad with a name? Main script will query all its parts upon it loading for the first time and attempt to find it, and use it for the height.
//If not found, just uses the top-most part.

//Can use :BOUNDS on our vessel in real-time, e.g. first example here: https://ksp-kos.github.io/KOS/structures/vessels/bounds.html

//e.g. local bounds_box is ship:bounds.
//It seems relMin:Y is what we would use to find difference in landing leg length?



	//Landing
	//SET parameterLex["landingtarget"] TO KERBIN:GEOPOSITIONLATLNG(0,0). //Geoposition, vessel, 0 default (no landing coordinates)
	//SET parameterLex["interceptaltitude"] TO 0.
	//SET parameterLex["reenteronly"] TO FALSE. //Set to true if you would like to switch to spaceplane code upon reentering
	//SET parameterLex["reentryburn"] TO FALSE. //Reentry burn to adjust impact coordinates to desired coordinates
	//SET parameterLex["landingburn"] TO FALSE.

	
	//Split out the vessel and coordinates here?
	//Sure...
	
	
//We require reentryonly even if we disable both burns. This is so it can continue outputting landing altitude events and such.
//Temporairly enable an ON statement for events? and then disable it after somehow? can we get a reference to it?
	
//Overall?
//reentryonly: if true, then stop running after doing the burn
//If false, continue
//
//This is unaffected if a landing location is specified or not.
//
//reentryburn:
//Angular distance?
//If true,
//	If landing location, use angular distance. When to start though? Obviously reduce impact point to the correct location.. On non-atmo landings this is assuming we placed it ahead??
//	If no landing location, what should we use? Base it on percentage through atmosphere? How much should we burn?
//If false, skip immediately to landingburn if any
//
//
//landingburn:
//If false, do not enter the suicide burn script (attempt would occur after reentry if reentry burn false, or after reentry burn if reentryburn true)
//If true, enter into the suicide burn script at the next chance
//
//In both cases, just feed it the landing location if any



//Another parameter, aimahead?
//Is in degrees, how far ahead of target we should make our impact (in the direction of our landing approach) (Still using circular maneuver...)
//
//e.g. reentryaimahead
//If no landing loc, once deorbited, find the predicted landing location, then subtract our reentryaimahead from it and set that as our landing coordinates (remember its along our velocity trajectory, not longitude)

//So specifies a landing location later anyways for use with the reentry burn if not already specified.
//Once we have a landing location (-aimahead from predicted in case of none preset), we use the angular velocity or something again to predict when to start the reentry burn
//Start the burn based on what? Really can start whenever and it will adjust. Previously based on stopping directly above the target.
//We can probably just follow the surface/orbital velcity fine.
//Base the start/[[end]] on angular difference? We can use current mean/true anomaly and find time to target mean/true anomaly.
//End because e.g. case we want to stop directly above the point

//Use angular dist based on circular geometry. Translate this into a true/mean anomaly and work with that?


//Burn can just run full throttle the whole time



	@lazyglobal OFF.
	CLEARSCREEN.
	

//--------------------------------------------------------------------------\
//								 Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _parameterLex.
	

//--------------------------------------------------------------------------\
//								 Variables					   				|
//--------------------------------------------------------------------------/


	//Lexicon extraction
	LOCAL landOnVessel IS 0.
	LOCAL landingCoordinates IS (CHOOSE _parameterLex["landingtarget"] IF _parameterLex:HASKEY("landingtarget") ELSE 0).
		//If a vessel was given, use its coordinates instead and keep a reference to the vessel
		IF(landingCoordinates:ISTYPE("vessel")){
			SET landOnVessel TO landingCoordinates.
			SET landingCoordinates TO landingCoordinates:GEOPOSITION.			
		}	
	LOCAL landVesselPartTag IS (CHOOSE _parameterLex["landVesselPartTag"] IF _parameterLex:HASKEY("landVesselPartTag") ELSE "").
	LOCAL interceptAltitude IS (CHOOSE _parameterLex["interceptaltitude"] IF _parameterLex:HASKEY("interceptaltitude") ELSE SHIP:BODY:RADIUS).
	LOCAL reenterOnly IS (CHOOSE _parameterLex["reenteronly"] IF _parameterLex:HASKEY("reenteronly") ELSE FALSE).
	LOCAL aimAhead 	  IS (CHOOSE _parameterLex["aimahead"] IF _parameterLex:HASKEY("aimahead") ELSE 0).
	LOCAL reentryBurn IS (CHOOSE _parameterLex["reentryburn"] IF _parameterLex:HASKEY("reentryburn") ELSE FALSE).
	LOCAL burnEndAngle IS (CHOOSE _parameterLex["burnendangle"] IF _parameterLex:HASKEY("burnendangle") ELSE 0).
	LOCAL landingBurn IS (CHOOSE _parameterLex["landingburn"] IF _parameterLex:HASKEY("landingburn") ELSE FALSE).		
	
	//Intermediate orbit if we're not already in an equatorial
	LOCAL circLex IS LEXICON().
		SET circLex["semimajoraxis"] TO SHIP:ORBIT:SEMIMAJORAXIS.
		SET circLex["inclination"] TO 0.
		SET circLex["eccentricity"] TO 0.
		SET circLex["longitudeofascendingnode"] TO 0.
		SET circLex["argumentofperiapsis"] TO 0.
		SET circLex["trueanomaly"] TO 0.
	
	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/
	
	
	//----------------------------------------------------\
	//Move into equatorial orbit--------------------------|
		//If not already in a circular orbit, get into one
		throwEvent(SHIP:BODY:NAME + "_LAND_PREPARE").
		IF(SHIP:ORBIT:ECCENTRICITY > 0.01 OR SHIP:ORBIT:INCLINATION > 0.5){
			RUNPATH("operations/mission operations/intermediate functions/setOrbit.ks", circLex).
		}	
		
	//----------------------------------------------------\
	//Execute the landing script--------------------------|
		throwEvent(SHIP:BODY:NAME + "_LAND_START").
		RUNPATH("operations/mission operations/intermediate functions/land2.ks", landingCoordinates, landOnVessel, landVesselPartTag, interceptAltitude, reenterOnly, aimAhead, reentryBurn, burnEndAngle, landingBurn).
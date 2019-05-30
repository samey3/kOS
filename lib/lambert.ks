//Code used from:
//https://github.com/johnwhall/kos-scripts/blob/master/lib/liblambertoptimize.ks
//https://github.com/johnwhall/kos-scripts/blob/master/lib/liborbitalstate.ks

//Referenced code is sort of a mess, and fully adapting it is going to be a headache.
//So for now, we'll just copy it all to here and just adapt the processing call.

//Should this even be a lib file? Where else to put it?


@lazyglobal off.
RUNONCEPATH("lib/processing.ks").

	//Provides the Lambert result for directly intercepting a target (add distance)
	FUNCTION getInterceptNode {
		PARAMETER s1.
		PARAMETER s2.
		PARAMETER allowLob IS TRUE.
		PARAMETER optArrival IS TRUE.
		PARAMETER startTime IS TIME:SECONDS.
		
		LOCAL rv1 IS getECIVecs(s1:ORBIT).
		LOCAL rv2 IS getECIVecs(s2:ORBIT).

		//RETURN lambert(rv1, rv2, s1:BODY:MU, allowLob, optArrival, startTime).
		RETURN lambert2(s1:ORBIT, s2:ORBIT, allowLob, optArrival, startTime).
	}
	
	//Provides the lambert result for intercepting a target orbit
	FUNCTION getTransferNode {
		//PARAMETER _semimajoraxis.
		//PARAMETER _eccentricity.
		//PARAMETER _inclination.
		//PARAMETER _longitudeofascendingnode.
		//PARAMETER _argumentofperiapsis.
		//PARAMETER _trueanomaly.
		PARAMETER s1.
		PARAMETER _targetOrbit.
		
		PARAMETER allowLob IS TRUE.
		PARAMETER optArrival IS TRUE.
		PARAMETER startTime IS TIME:SECONDS.
		
		
		//Create the lexicon to hold the desired orbit's parameters
		//PARAMETER _targetOrbit IS LEXICON().
			SET _targetOrbit["mu"] TO s1:BODY:MU.	
			//SET targetOrbit["semimajoraxis"] TO _semimajoraxis.	
			//SET targetOrbit["eccentricity"] TO _eccentricity.	
			//SET targetOrbit["inclination"] TO _inclination.	
			//SET targetOrbit["longitudeofascendingnode"] TO _longitudeofascendingnode.	
			//SET targetOrbit["argumentofperiapsis"] TO _argumentofperiapsis.	
			SET _targetOrbit["trueanomaly"] TO (startTime/s1:ORBIT:PERIOD)*360. //This is irrelevant?		
			
		//Get the ECI vecs for the orbits
		LOCAL rv1 IS getECIVecs(s1:ORBIT).
		LOCAL rv2 IS getECIVecs(_targetOrbit).

		RETURN lambert(rv1, rv2, _targetOrbit["mu"], allowLob, optArrival, startTime).
	}

//#######################################################################
//#																		#
//# lib: lambertoptimize												#
//#																		#
//#######################################################################

	//Seems s1 and s2 are vessels/bodies
	//Used for getting transfer
	function lambert {
	  //parameter s1.
	  //parameter s2.
		parameter rv1.
		parameter rv2.
		parameter mu IS SHIP:BODY:MU.
		parameter allowLob is true.
		parameter optArrival is true.
		parameter startTime is time:seconds.
		parameter endTime is 0.
  
		LOCAL kep1 IS eciVecsToKepElem(mu, rv1[0], rv1[1]).
		LOCAL kep2 IS eciVecsToKepElem(mu, rv2[0], rv2[1]). 
	  
		LOCAL period1 IS 2*CONSTANT():PI*SQRT((kep1[0]^3)/mu).
		LOCAL period2 IS 2*CONSTANT():PI*SQRT((kep2[0]^3)/mu).
	    
		local synodicPeriod to 1 / abs((1 / period1) - (1 / period2)).
			SET synodicPeriod TO 2*ETA:PERIAPSIS. //Did I do this????
		local dtMin to 0.
		local dtMax to max(period1, period2). //Forcibly bound this, e.g. 3 years max? WRONG. This is travel time, must bound t inside the java app

		//local rv1 to getECIVecs(s1:orbit).
		//local rv2 to getECIVecs(s2:orbit).
	  
		//Perhaps cannot limit dtMin and dtMax though?
		if(endTime = 0){
			SET endTime TO (startTime + synodicPeriod). //time:sec + time to start + duration = end time
		}
	  
		//local res to lambertOptimizeBounded(s1, s2, startTime, startTime + synodicPeriod, dtMin, dtMax, allowLob, optArrival).
		//local res to lambertOptimizeBounded(rv1, rv2, mu, startTime, startTime + synodicPeriod, dtMin, dtMax, allowLob, optArrival).
		local res to lambertOptimizeBounded(rv1, rv2, mu, startTime, endTime, dtMin, dtMax, allowLob, optArrival).
	  
		return res.
	}
	
	//Seems s1 and s2 are vessels/bodies
	//Used for getting intercept
	function lambert2 {
		parameter s1.
		parameter s2.
		parameter allowLob is true.
		parameter optArrival is true.
		parameter startTime is time:seconds.
		parameter endTime is 0.
	    
		local synodicPeriod to 1 / abs((1 / s1:period) - (1 / s2:period)).
		local dtMin to 0.
		local dtMax to max(s1:period, s2:period).

		local rv1 to getECIVecs(s1).
		local rv2 to getECIVecs(s2).
	  
		//Perhaps cannot limit dtMin and dtMax though?
		if(endTime = 0){
			SET endTime TO (startTime + synodicPeriod). //time:sec + time to start + duration = end time
		}
	  
		//local res to lambertOptimizeBounded(s1, s2, startTime, startTime + synodicPeriod, dtMin, dtMax, allowLob, optArrival).
		//local res to lambertOptimizeBounded(rv1, rv2, s1:body:mu, startTime, startTime + synodicPeriod, dtMin, dtMax, allowLob, optArrival).
		local res to lambertOptimizeBounded(rv1, rv2, s1:body:mu, startTime, endTime, dtMin, dtMax, allowLob, optArrival).
	  
		return res.
	}

	function lambertOptimizeBounded {
	  //parameter s1.
	  //parameter s2.
	  parameter rv1.
	  parameter rv2.
	  PARAMETER mu.
	  parameter tMin.
	  parameter tMax.
	  parameter dtMin is 0.
	  //parameter dtMax is max(s1:orbit:period, s2:orbit:period).
	  parameter dtMax is max(2*CONSTANT():PI*SQRT(((eciVecsToKepElem(mu, rv1[0], rv1[1]))[0]^3)/mu), 2*CONSTANT():PI*SQRT(((eciVecsToKepElem(mu, rv2[0], rv2[1]))[0]^3)/mu)).
	  parameter allowLob is true.
	  parameter optArrival is true.

	  local calcStartTime to time:seconds.
	  print "Calc start time: " + calcStartTime.
	  print "Passed tMin: " + tMin.
	  print "Passed tMax: " + tMax.

	  set tMin to tMin - time:seconds.
	  set tMax to tMax - time:seconds.
	  print "Adjusted tMin: " + tMin.
	  print "Adjusted tMax: " + tMax.

	  local MIN_STEP_T to 1.
	  local MIN_STEP_DT to 1.

	  set tMin to max(0, tMin).
	  set tMax to max(tMin + 1e-8, tMax).

	  set dtMin to max(0, dtMin).
	  set dtMax to max(dtMin + 1e-8, dtMax).

	  //local b to s1:body.
	  //if s2:body <> b {
	//	print "bodies must be the same".
	//	exit.
	  //}

	  //local rv1 to getECIVecs(s1:orbit).
	  //local rv2 to getECIVecs(s2:orbit).

	  local res to lexicon().

	  // initialize these to force us into the loop, then immediately recalculate
	  local tStep to 2 * MIN_STEP_T.
	  local dtStep to 2 * MIN_STEP_DT.

	  // pure equality check is ok since these are assigned directly, not computed
	  until tStep = MIN_STEP_T and dtStep = MIN_STEP_DT {
		// do this at the beginning of the loop (after checking the until condition) so
		// we loop at least once with tStep = dtStep = 1
		set tStep to max(MIN_STEP_T, (tMax - tMin) / 10000).
		set dtStep to max(MIN_STEP_DT, (dtMax - dtMin) / 500).

		set res to solveLambert(mu, //b:mu,
								rv1[0], rv1[1],
								rv2[0], rv2[1],
								tMin, tMax, tStep,
								dtMin, dtMax, dtStep,
								allowLob, optArrival).

		set tMin to max(0, res["t"] - tStep).
		set tMax to tMin + 2 * tStep.

		set dtMin to max(0, res["dt"] - dtStep).
		set dtMax to dtMin + 2 * dtStep.

		//set tStep to MIN_STEP_T.
		//set dtStep to MIN_STEP_DT.
	  }

	  local calcEndTime to time:seconds.
	  print "Calc end time: " + calcEndTime + " (total time: " + (calcEndTime - calcStartTime) + ")".
	  print "answer from processing: " + res["t"].

	  set res["t"] to res["t"] + calcStartTime.
	  print "returning " + res["t"] + " (" + (res["t"] - time:seconds) + " from now)".

	  return res.
	}


//#######################################################################
//#																		#
//# lib: orbitalstate													#
//#																		#
//#######################################################################

	function eciVecsToKepElem {
	  parameter mu, r, v.

	  // Semi-major Axis
	  local a to 1 / ((2 / r:mag) - (v:sqrmagnitude / mu)).

	  // Eccentricity
	  local h to vcrs(r, v).
	  local eVec to vcrs(v, h) / mu - r:normalized.
	  local e to eVec:mag.
	  
	  // Inclination
	  local i to arccos(h:z / h:mag).

	  // Longitude of Ascending Node
	  local n to V(-h:y, h:x, 0).
	  local lan to 0.
	  if n:mag <> 0 {
		set lan to arccos(n:x / n:mag).
		if n:y < 0 { set lan to 360 - lan. }
	  }

	  // Argument of Periapsis
	  local aop to 0.
	  if n:mag <> 0 and e <> 0 {
		set aop to arccos(vdot(n, eVec) / (n:mag * e)).
		if eVec:z < 0 { set aop to 360 - aop. }
	  }

	  // True Anomaly
	  local ta to 0.
	  if e <> 0 { // TODO: do something reasonable when the orbit is circular
		set ta to arccos(vdot(eVec, r) / (e * r:mag)).
		if vdot(r, v) < 0 { set ta to 360 - ta. }
	  }

	//  // Eccentric Anomaly
	//  local ea to arccos((e + cos(ta)) / (1 + e * cos(ta))).
	//  if 180 < ta and ta < 360 { set ea to 360 - ea. }
	//
	//  // Mean Anomaly
	//  local ma to ea - e * sin(ea).

	  // TODO: change ta to ma?
	  return list(a, e, i, lan, aop, ta).
	}

	function kepElemToEciVecs {
	  // Best reference I've found:
	  // http://ccar.colorado.edu/ASEN5070/handouts/kep2cart_2002.doc
	  parameter mu, elems.

	  local a to elems[0].
	  local e to elems[1].
	  local i to elems[2].
	  local lan to elems[3].
	  local aop to elems[4].
	  local ta to elems[5].

	  local p to a * (1 - e^2).
	  local r to p / (1 + e * cos(ta)).
	  local h to sqrt(mu * p).

	  local coslan to cos(lan).
	  local sinlan to sin(lan).
	  local cosaopta to cos(aop + ta).
	  local sinaopta to sin(aop + ta).
	  local cosi to cos(i).
	  local sini to sin(i).

	  local x to r * (coslan * cosaopta - sinlan * sinaopta * cosi).
	  local y to r * (sinlan * cosaopta + coslan * sinaopta * cosi).
	  local z to r * (sini * sinaopta).

	  local sinta to sin(ta).
	  local herpsinta to h * e * sinta / (r * p).
	  local hr to h / r.

	  local vx to x * herpsinta - hr * (coslan * sinaopta + sinlan * cosaopta * cosi).
	  local vy to y * herpsinta - hr * (sinlan * sinaopta - coslan * cosaopta * cosi).
	  local vz to z * herpsinta + hr * sini * cosaopta.

	  return list(V(x, y, z), V(vx, vy, vz)).
	}

	FUNCTION getECIVecs
	{
		//Either an orbit structure, or a lexicon
		PARAMETER p_obt.
		
		IF(p_obt:ISTYPE("Orbit")){
			RETURN kepElemToEciVecs(p_obt:body:mu, LIST(p_obt:semimajoraxis,
									p_obt:eccentricity,
									p_obt:inclination,
									p_obt:longitudeofascendingnode,
									p_obt:argumentofperiapsis,
									p_obt:trueanomaly)).
		}
		ELSE {
			RETURN kepElemToEciVecs(p_obt["mu"], LIST(p_obt["semimajoraxis"],
									p_obt["eccentricity"],
									p_obt["inclination"],
									p_obt["longitudeofascendingnode"],
									p_obt["argumentofperiapsis"],
									p_obt["trueanomaly"])).
		}
	}
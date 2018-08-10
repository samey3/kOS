function lambertOptimizeBounded {
  parameter s1.
  parameter s2.
  parameter tMin.
  parameter tMax.
  parameter dtMin is 0.
  parameter dtMax is max(s1:orbit:period, s2:orbit:period).
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

  local b to s1:body.
  if s2:body <> b {
    print "bodies must be the same".
    exit.
  }

  local rv1 to getECIVecs(s1:orbit).
  local rv2 to getECIVecs(s2:orbit).

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

    set res to mainframeLambertOptimizeVecs(b:mu,
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
  print "answer from mainframe: " + res["t"].

  set res["t"] to res["t"] + calcStartTime.
  print "returning " + res["t"] + " (" + (res["t"] - time:seconds) + " from now)".

  return res.
}

function lambertOptimize {
  parameter s1.
  parameter s2.
  parameter allowLob is true.
  parameter optArrival is true.
  parameter startTime is time:seconds.

  local synodicPeriod to 1 / abs((1 / s1:orbit:period) - (1 / s2:orbit:period)).
  local dtMin to 0.
  local dtMax to max(s1:orbit:period, s2:orbit:period).

  local res to lambertOptimizeBounded(s1, s2, startTime, startTime + synodicPeriod, dtMin, dtMax, allowLob, optArrival).
  
  return res.
}


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

function getECIVecs
{
	parameter p_obt.
	return kepElemToEciVecs(p_obt:body:mu, list(p_obt:semimajoraxis,
	                                            p_obt:eccentricity,
									      	    p_obt:inclination,
										        p_obt:longitudeofascendingnode,
      										    p_obt:argumentofperiapsis,
	      									    p_obt:trueanomaly)).
}
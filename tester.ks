CLEARSCREEN.

LOCK STEERING TO SHIP:FACING.
LOCK THROTTLE TO 0.
UNLOCK STEERING.
UNLOCK THROTTLE.


//RUNPATH ("basic_functions/circularize.ks", SHIP:BODY:RADIUS + 8000000, TRUE).
//RUNPATH ("basic_functions/nodeInclinationBurn.ks", ETA:PERIAPSIS, -120).
//RUNPATH ("basic_functions/matchOrbit.ks").
//RUNPATH ("basic_functions/basicRendezvous.ks").

RUNPATH ("Rendezvous.ks").
RUNPATH ("Dock.ks").
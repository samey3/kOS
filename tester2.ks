@lazyglobal OFF.
//Allows its functions to be called
runoncepath("processing/processRequest.ks").

CLEARSCREEN.

LOCK STEERING TO SHIP:FACING.
LOCK THROTTLE TO 0.
UNLOCK STEERING.
UNLOCK THROTTLE.

//RUNPATH ("Rendezvous.ks").
//RUNPATH ("Dock.ks").

LOCAL resultQueue IS findPath(LATLNG(-90,SHIP:GEOPOSITION:LNG)).
RUNPATH ("travelPath.ks", resultQueue).








//////////////////////////////////////////////////////////////////////////////////
//
//	ASK WHAT ADAM WANTS,WRITE SMALL KOS SCRIPTS FOR IT.
//	OR ALTERNATIVELY, DO A LAYTHE MISSION TOGETHER.
//
//////////////////////////////////////////////////////////////////////////////////
CLEARSCREEN.

//If no target
//get LAN, warp to it, match difference using VANG
//set periapsis first, then apoapsis

//If target, can check if it is craft or contract.
//if contract, if it has :ORBIT then treat like craft, else pass it into no target
//Otherwise, use :ORBIT stuff

//First make circular orbit at radius equal to the target craft's periapsis







PARAMETER _targetCraft IS TARGET.
GLOBAL returnVal IS 0. //Used for retrieving values from run functions, as return values from such scripts are not supported yet.


LOCAL ascendingInclination IS getAscendingInclination(_targetCraft).
RUN timeToRelativeAscending(_targetCraft).
RUN nodeInclinationBurn(returnVal, -ascendingInclination). //CHANGED IT TO NEGATIVE INCLINATION HERE, ACTUALLY FIX IT

RUN timeToRelativePeriapsis(_targetCraft).
RUN maneuverCircular(_targetCraft:ORBIT:APOAPSIS + _targetCraft:ORBIT:BODY:RADIUS, returnVal).

RUN rendezvous(100, _targetCraft).
RUN dock(_targetCraft).

//RUN nodeInclinationBurn(returnVal, -ascendingInclination).
//Vector between these two, shipvel_vector + inclination_degrees
//Vel->Position

//Current ship velocity
//target velocity
//Both at the ascending node
//The difference is the burn amount?
//RUN nodeBurn(timeAsc, 100,6).


FUNCTION getAscendingInclination {
	PARAMETER _TC.
	LOCAL shipAngularVelocity IS VCRS(SHIP:POSITION - BODY:POSITION, SHIP:VELOCITY:ORBIT).
	LOCAL targetAngularVelocity IS VCRS(_TC:POSITION - BODY:POSITION, _TC:VELOCITY:ORBIT).
	LOCAL ascendingInclination IS VANG(targetAngularVelocity, shipAngularVelocity). //kOS uses LHR instead of RHR	
	RETURN ascendingInclination.
}
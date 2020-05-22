//StarShip Test Vehicle
//Testwill achieve: Low Kerbin Orbit of the Starship 

clearscreen.

//Global-------------------------------------------------------------*******

set firstStageThrottle to 0.

set var1 to 0.

set SuperHeavySteer to heading(0,90).

set Yvar to 90.

set altVar to 1000.

set secondStageThrottle to 0.

set StarshipSteer to UP.

lock steering to StarshipSteer.

clearscreen.


lock Fg to (SHIP:BODY:MU * SHIP:mass)  / (SHIP:position - body:position):mag^2.

print"Fg". print Fg.
print"ship:availablethrust". print ship:availablethrust.

lock targetAngle to arcsin(Fg / ship:availablethrust).
print "targetAngle". print targetAngle.

print"check1".
wait 1z.
set targetAlt to apoapsis.

lock StarshipSteer to heading(90,targetAngle).
until periapsis > targetAlt
{
	print"=================================================".
	print"------------Starship SN1-TV-1--------------------".
	print"=================================================".
	print" ".
	
	print"Fg". print Fg.
	print"ship:availablethrust". print ship:availablethrust*1000.
	print"targetAngle". print targetAngle.
	print "StarshipSteer". print StarshipSteer.
	wait 0.1.
	
	clearscreen.
	
	
}
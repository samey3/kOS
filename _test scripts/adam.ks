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

set StarshipSteer to 0.


//Vehicle Start Up---------------------------------------------------*******

print"=================================================".
print"------------Starship SN1-TV-1--------------------".
print"=================================================".
print" ".

wait 1.
print"Fueling Loading Complete".
wait 1.

print" ".
print"Vehicle In Startup".

wait 2.

print" ".

lock throttle to 0.
lock steering to up.

clearscreen.


//Launch Prep----------------------------------------------------------*******

print"=================================================".
print"------------Starship SN1-TV-1--------------------".
print"=================================================".
print" ".



clearscreen.


//Countdown----------------------------------------------------------*******

print"=================================================".
print"------------Starship SN1-TV-1--------------------".
print"=================================================".
print" ".

print"Launch In:".
wait 1.
print"3".
wait 1.
print"2".
wait 1.
print"1".
wait 1.

stage.
print"Ignition".
wait 0.3.
print" ".

print"Throttle Up".
print " ".

lock throttle to firstStageThrottle.

until var1 > 99
{	
	set var1 to var1 + 0.1.
	set firstStageThrottle to firstStageThrottle + 0.1.
}

lock throttle to 100.
lock steering to up.
print" ".
print"Clamps Release".
stage.

clearscreen.


//First Stage Flight-------------------------------------------------*******

print"=================================================".
print"------------Starship SN1-TV-1--------------------".
print"=================================================".
print" ".

stage.

wait 0.5.
print"StarShip is in Flight".
print" ".

stage.

until apoapsis > 50000
{
	wait until (altitude > altVar).

	set altVar to (altVar + 1500).
	set Yvar to (Yvar - 1).
	PRINT("Val : " + Yvar).
	set SuperHeavySteer to heading(90,Yvar).
	
}	

wait until ship:availablethrust <1.
set throttle to 0.

clearscreen.


//Staging------------------------------------------------------------*******

print"=================================================".
print"------------Starship SN1-TV-1--------------------".
print"=================================================".
print" ".

print"Coasting to Seperation".
wait 5.
print" ".

toggle AG5.
print"Seperation Confirmed".
wait 0.5.

rcs on.
set throttle to 100.
wait 10.

clearscreen.


//Second Stage Flight------------------------------------------------*******

print"=================================================".
print"------------Starship SN1-TV-1--------------------".
print"=================================================".
print" ".

print"Starship Engine Ignition".
stage.

set var1 to 0.

until var1 > 99
{	
	set var1 to var1 + 0.1.
	set secondStageThrottle to secondStageThrottle + 0.1.
}

set secondStageThrottle to 100.

wait 3.



lock steering to StarshipSteer.

lock Fg to (ship:body:mu * ship:mass)  / (ship:position - body:position):mag^2.

print"Fg". print Fg.
print"ship:availablethrust". print ship:availablethrust.

lock targetAngle to arcsin(Fg / ship:availablethrust).
print "targetAngle". print targetAngle.

print"check1".
wait 20.
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


clearscreen.

//Orbit Operations---------------------------------------------------*******

print"=================================================".
print"------------Starship SN1-TV-1--------------------".
print"=================================================".
print" ".


if periapsis >70000
{
	print"Orbit Achieved".
}
else
{
	print"Orbit Not Achieved".
}

print"Apoapsis: ". print apoapsis. 

print"Periapsis: ". print periapsis.

wait 100.























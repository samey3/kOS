FUNCTION warpTime {
	PARAMETER _duration.
	LOCAL warpTimer IS TIME:SECONDS + _duration.
	KUNIVERSE:TIMEWARP:WARPTO(TIME:SECONDS + _duration).	
	UNTIL(TIME:SECONDS >= warpTimer){
		CLEARSCREEN.
		PRINT("Time left : " + (warpTimer - TIME:SECONDS)).
	}
	WAIT UNTIL WARP = 0 AND SHIP:UNPACKED.
}
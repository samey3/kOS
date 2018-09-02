FUNCTION wrapAngle {
	PARAMETER angle.
	IF(angle < 0) {
		RETURN 360 + angle. }
	ELSE IF(angle = 360){
		RETURN 0. }
	ELSE {
		RETURN angle. }		
}
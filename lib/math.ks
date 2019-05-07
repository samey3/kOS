
//Math
FUNCTION wrap360 {
	PARAMETER _angle.
	IF(_angle < 0) { RETURN 360 + _angle. }
	ELSE IF(_angle >= 360){ RETURN _angle - 360. }
	RETURN _angle.		
}

//Lng -180 to 180
FUNCTION wrap180 {
	PARAMETER _angle.
	IF(_angle < -180) { RETURN 360 + _angle. }
	ELSE IF(_angle >= 180){ RETURN _angle - 360. }
	RETURN _angle.		
}

FUNCTION sign {
	PARAMETER _value.
	IF (_value < 0) { RETURN -1. }
	ELSE IF (_value > 0) { RETURN 1. }
	RETURN 0.
}

FUNCTION percentDifference {
	PARAMETER _A.
	PARAMETER _B.
	RETURN 2*ABS(_A - _B)/(_A + _B).
}

FUNCTION scalarDifference {
	PARAMETER _A.
	PARAMETER _B.
	RETURN ABS(_A - _B).
}



//Vectors
FUNCTION projectToPlane {
	PARAMETER _vector.
	PARAMETER _planeNormal.	
	RETURN _vector - ((_vector*_planeNormal)/_planeNormal:MAG^2)*_planeNormal.
}

//_A on to _B
FUNCTION vectorProjection {
	PARAMETER _A.
	PARAMETER _B.
	RETURN ((_A*_B)/(_B:MAG^2))*_B.
}

//Gives the length of the projection; Can be used for the horizontal distance?
//Make sure you use the reference vector that is after the corrections.
FUNCTION scalarProjection {
	PARAMETER _A.
	PARAMETER _B.
	RETURN ((_A*_B)/_B:MAG).
}
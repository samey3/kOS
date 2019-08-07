//Extended functions
//Lowest value in a list
FUNCTION MINS {
	PARAMETER _list.
	LOCAL m IS _list[0].
	FOR val IN _list {
		SET m TO MIN(m, val).
	}
	RETURN m.
}

//Highest value in a list
FUNCTION MAXS {
	PARAMETER _list.
	LOCAL m IS _list[0].
	FOR val IN _list {
		SET m TO MAX(m, val).
	}
	RETURN m.
}


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


//Coordinate systems
//Ship-centered-coordinates
FUNCTION toShipCentered {
	PARAMETER _S.
	PARAMETER _V.
	RETURN V(
		_S:FACING:FOREVECTOR*_V,
		_S:FACING:TOPVECTOR *_V,
		_S:FACING:STARVECTOR*_V
	).
}

//Body-centered-coordinates (original coordinate system located around body, and it has no :FACING values to use)
FUNCTION toBodyCentered {
	PARAMETER _V.
	RETURN (
		SHIP:FACING:FOREVECTOR*_V:X +
		SHIP:FACING:TOPVECTOR *_V:Y +
		SHIP:FACING:STARVECTOR*_V:Z
	).
}
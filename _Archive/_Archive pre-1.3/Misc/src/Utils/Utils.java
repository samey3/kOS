package Utils;

import org.apache.commons.math3.geometry.euclidean.threed.Vector3D;

public abstract class Utils {
	private Utils() {
	}

	public static String formatVector(Vector3D v) {
		return v.toString().replaceAll(",", "").replaceAll(";", ",").replaceAll("\\{", "(").replaceAll("\\}", ")");
	}
}
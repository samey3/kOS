//--------------------------------------------------------------------------\
//							  	  Variables				   					|
//--------------------------------------------------------------------------/


	DECLARE GLOBAL GUI_RESULT_RES IS 0.
	LOCAL guiPath IS "GUIs/".


//--------------------------------------------------------------------------\
//								  Functions					   				|
//--------------------------------------------------------------------------/	


	FUNCTION showGUI {
		PARAMETER _guiName.

		//Find the complete path
		LOCAL resultPath IS (guiPath + _guiName + ".ks").
		
		//If it exists, open the GUI, and return the result afterwards
		IF(VOLUME(0):EXISTS(resultPath)){
			RUNPATH(resultPath).
			RETURN GUI_RESULT_RES.
		}
		//Else display the error
		ELSE{
			PRINT("The GUI interface '" + _guiName + "' does not exist.").
		}
	}
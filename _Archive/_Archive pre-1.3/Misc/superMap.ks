	CLEARSCREEN.
	

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _precision IS 0.5.
	

//--------------------------------------------------------------------------\
//								 Variables					   				|
//--------------------------------------------------------------------------/


	LOCAL partList IS SHIP:PARTSTAGGED("processor").
	LOCAL processorList IS LIST().	
	FOR core IN partList {
		processorList:ADD(core:GETMODULEBYINDEX(0)).
	}	
		
	LOCAL totalSteps IS 182*360*(1/_precision)^2.
	LOCAL stepsPer IS totalSteps/processorList:LENGTH.
	
	
//--------------------------------------------------------------------------\
//							 Reboot conditions					   			|
//--------------------------------------------------------------------------/	
	
	
	IF(ROUND(stepsPer) <> stepsPer){	
		PRINT ("Operation conditions not met ( " + SCRIPTPATH():NAME + " ).").
		PRINT("Improper number of CPUs; required amounts : 10, 20, 40, 80... etc.").
		PRINT ("Rebooting. . ."). 
		WAIT 3. REBOOT.
	}
	

//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/	

	
	PRINT("Number of CPUs : " + processorList:LENGTH).	
	PRINT("Precision : " + _precision).
	PRINT("Steps per CPU : " + stepsPer + "(" + (stepsPer*(1/_precision)) + " lines)").
	
	//FROM { LOCAL i IS 0. } UNTIL (i = 3) STEP { SET i TO (i + 1). } DO {
	//	COPYPATH ("mapBody2.ks", processorList[i]:VOLUME).
	//	SET processorList[i]:BOOTFILENAME TO "mapBody2.ks".
	//}
		
	
	FROM { LOCAL i IS 0. } UNTIL (i = processorList:LENGTH) STEP { SET i TO (i + 1). } DO { //processorList:LENGTH
		LOCAL startStep IS stepsPer*i.
		LOCAL stopStep IS stepsPer*(i+1).
		//processorList[i]:DOEVENT("open terminal").
		//processorList[i]:DEACTIVATE.
		//COPYPATH ("mapBody2.ks", processorList[i]:VOLUME).
		//SET processorList[i]:BOOTFILENAME TO "mapBody2.ks".
		//WAIT 1.
		//processorList[i]:ACTIVATE.
		processorList[i]:CONNECTION:SENDMESSAGE(_precision).
		processorList[i]:CONNECTION:SENDMESSAGE(i).
		processorList[i]:CONNECTION:SENDMESSAGE(startStep).
		processorList[i]:CONNECTION:SENDMESSAGE(stopStep).
		PRINT("Core : " + i).
		//WAIT 1.
	}
	
	
	
	
	
	
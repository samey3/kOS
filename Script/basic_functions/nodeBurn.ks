	PRINT(" ").
	PRINT("~~~~~~~~~~~~~~~running node burn~~~~~~~~~~~~~~~~~~").

	PARAMETER _timeToPeak. 
	PARAMETER _burnDV.
	PARAMETER _dirVector IS V(0,0,0).
	
	
//-----------------------------------------------------//
	//LIST ENGINES IN eng_list.
	//FOR e IN eng_list { PRINT(e). }
	
	
	PRINT("Time : " + _timeToPeak).
	PRINT("DV : " + _burnDV).
	PRINT("Vector : " + _dirVector).
	IF(_dirVector = V(0,0,0)){ PRINT("~~~~~~~~~~~~~~~~~"). PRINT("Args were shifted"). PRINT("~~~~~~~~~~~~~~~~~"). }
	

//-----------------------------------------------------//

	LOCK STEERING TO SHIP:FACING.
	LOCK THROTTLE TO 0.		
	
	
	
	
	
	//Noticed behaviour:
	
	//1. Commenting out either of the LOCK lines (lines 22,23) with 'LIST ENGINES' and the 'FOR' loop (lines 10,11) commented out, will result in it receiving arguments correctly.
		
	//2. Uncommenting 'LIST ENGINES' and the 'FOR' loop (allowing it to run), and commenting out either of the LOCK statements causes it to complain eng_list is undefined
	//   However, leaving the two LOCK statements uncommented (letting them run), the for loop will output eng_list normally
	
	//All of this occurs after a first succesful run of nodeBurn.ks, circularize->setApoapsis->nodeBurn
	//However the error occurs on the second call, circularize->setPeriapsis->nodeBurn
	
	//In setPeriapsis, adding an extra argument at the start will result in it working. It seems the first will be skipped, using the second argument (What was mean't to be the first) as the first argument.
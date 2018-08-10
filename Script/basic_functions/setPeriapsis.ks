	PARAMETER _periapsis.
	
	//This is the regular one that causes errors
	RUNPATH ("basic_functions/nodeBurn.ks", 999, 20, 1).
	
	//However, adding an extra argument (any value) will result in it working.
	//It will skip the first argument, and use the second as first
	
	//Uncomment this one, comment the other, and it will work.
	//RUNPATH ("basic_functions/nodeBurn.ks", "ANY VALUE HERE", 999, 10, 1).
	
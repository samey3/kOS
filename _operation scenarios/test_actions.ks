	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks"). //Run this between missions if it changes from rocket to rover or something
	
	//Mission staging:
		addListener("KERBIN_FINISHED", {
			LIGHTS ON.
			DEPLOYDRILLS ON.
			WAIT 5.
			DRILLS ON.
			WAIT 5.
			DEPLOYDRILLS OFF.
			DRILLS OFF.
			WAIT 10.
			GEAR OFF.
			WAIT 5.
			handlePartAction("4", "extend solar panel").
			WAIT 2.
			LIGHTS OFF.
		}).

	//Mission steps:
		configureVessel().
		RUNPATH("operations/mission operations/missionBuilder.ks", KERBIN, "nothing", 0, 0).
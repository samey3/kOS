	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks"). //Run this between missions if it changes from rocket to rover or something
	
	//Variables
	LOCAL electricCapacity IS 0.
	LIST RESOURCES IN resList.
	FOR res IN resList {
		IF res:NAME = "ELECTRICCHARGE" { SET electricCapacity TO res:CAPACITY. BREAK. }
	}
	
	//Custom events
		//If the ships electric capacity is less than 10%, turn on the fuel cells until 50%
		ON((SHIP:ELECTRICCHARGE/electricCapacity) < 0.10){
			throwEvent("BATTERIES_DEPLETED").
		}
	
	//Event listeners
		addListener("BATTERIES_DEPLETED", {
			FUELCELLS ON.
			UNTIL((SHIP:ELECTRICCHARGE/electricCapacity) >= 0.50){
				CLEARSCREEN.
				PRINT("Recharging batteries...").
				PRINT("Charge : " + (SHIP:ELECTRICCHARGE/electricCapacity) + "%").
				WAIT 0.01.
			}
			FUELCELLS OFF.
		}).
		

	//Mission steps:
		configureVessel().
		//RUNPATH("operations/mission operations/missionBuilder.ks", KERBIN, "nothing", 0, 0).
		WAIT UNTIL(FALSE).
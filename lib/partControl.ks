//--------------------------------------------------------------------------\
//									ISRU					   				|
//--------------------------------------------------------------------------/


	//How about we make this purely for activating, move logic for checking amounts to an actual script?
	//Perhaps can make use of ON for automatic shutdown of resource generation once full?
	FUNCTION enableISRU {
		
		//----------------------------------------------------\
		//Parameters------------------------------------------|
			PARAMETER _converter IS (SHIP:PARTSTITLEDPATTERN("Convert-O-Tron"))[0].
			PARAMETER _lf IS TRUE.
			PARAMETER _ox IS TRUE.
			PARAMETER _mp IS TRUE.
		
		//----------------------------------------------------\
		//Variables-------------------------------------------|
			//Gets the resource converter module (returns if it has none)
			LOCAL rscModule IS 0.
				IF(_converter:HASMODULE("ModuleResourceConverter")){ SET rscModule TO _converter:GETMODULE("ModuleResourceConverter"). }
				ELSE { RETURN 0. }
		
			//Finds the maximum capacity of liquid fuel
			LOCAL maxLf IS 0.
			LOCAL maxOx IS 0.
			LOCAL maxMp IS 0.
			
			LOCAL itr IS SHIP:RESOURCES:ITERATOR.
			UNTIL (itr:NEXT = FALSE){
				IF(itr:VALUE:NAME = "LiquidFuel"){ SET maxLf TO maxLf + itr:VALUE:CAPACITY. }
				IF(itr:VALUE:NAME = "Oxidizer"){ SET maxOx TO maxOx + itr:VALUE:CAPACITY. }
				IF(itr:VALUE:NAME = "Monopropellant"){ SET maxMp TO maxMp + itr:VALUE:CAPACITY. }
			}
		
		//----------------------------------------------------\
		//Activate ISRU---------------------------------------|
			//Activate liquid fuel
			IF(_lf AND SHIP:LIQUIDFUEL < maxLf){
				IF(rscModule:HASEVENT("start isru [lqdfuel]"){ rscModule:DOEVENT("start isru [lqdfuel]"). }
			}
			
			//Activate oxidizer
			IF(_ox AND SHIP:LIQUIDFUEL < maxOx){
				IF(rscModule:HASEVENT("start isru [ox]"){ rscModule:DOEVENT("start isru [ox]"). }
			}
			
			//Activate Monopropellant
			IF(_mp AND SHIP:LIQUIDFUEL < maxMp){
				IF(rscModule:HASEVENT("start isru [monoprop]"){ rscModule:DOEVENT("start isru [monoprop]"). }
			}
	}
	
	FUNCTION disableISRU {
	
	}
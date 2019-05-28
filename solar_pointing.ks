	@lazyglobal OFF.
	CLEARSCREEN.
	
	
//--------------------------------------------------------------------------\
//							  Solar panel lists				   				|
//--------------------------------------------------------------------------/
	
	
	LOCAL px IS LIST().
	SET px TO SHIP:PARTSTAGGED("-x").
	LOCAL nx IS LIST().
	SET nx TO SHIP:PARTSTAGGED("-x").
	
	LOCAL py IS LIST().
	SET py TO SHIP:PARTSTAGGED("-y").
	LOCAL ny IS LIST().
	SET ny TO SHIP:PARTSTAGGED("-y").
	
	LOCAL pz IS LIST().
	SET pz TO SHIP:PARTSTAGGED("-z").
	LOCAL nz IS LIST().
	SET nz TO SHIP:PARTSTAGGED("-z").
	
	
	//provided/list:length
	//GETMODULE("ModuleDeployableSolarPanel")
	//GETFIELD("energy flow")
	
//--------------------------------------------------------------------------\
//							  	 Script run					   				|
//--------------------------------------------------------------------------/


	LOCK pxVec TO getEnergyVec(px).
	LOCK nxVec TO getEnergyVec(nx).
	LOCK pyVec TO getEnergyVec(py).
	LOCK nyVec TO getEnergyVec(ny).
	LOCK pzVec TO getEnergyVec(pz).
	LOCK nzVec TO getEnergyVec(nz).
	LOCK resultVec TO (pxVec + nxVec + pyVec + nyVec + pzVec + nzVec).

	LOCAL drawVec IS 0.
	
	UNTIL (FALSE) {
		SET drawVec TO VECDRAWARGS(SHIP:POSITION, resultVec:NORMALIZED*10, YELLOW, "Sun vector", 1, TRUE).
	}

	
//--------------------------------------------------------------------------\
//							  	  Functions					   				|
//--------------------------------------------------------------------------/


FUNCTION getEnergyVec {
	PARAMETER panelList.
	
	LOCAL energyFlow IS getEnergyFlow(panelList)/panelList:LENGTH.
	LOCAL energyVec IS (panelList[0]):FACING:VECTOR*energyFlow.
	
	RETURN energyVec.
}



FUNCTION getEnergyFlow {	
	PARAMETER panelList.

	LOCAL energyFlowModules IS modulesList(moduleHasEnergyFlow@, panelList).
	LOCAL totalFlow IS 0.
	
	for module in energyFlowModules {
		LOCAL moduleEnergyFlow IS module:getField("energy flow").
		SET totalFlow TO totalFlow + moduleEnergyFlow.
	}
	
	RETURN totalFlow.
}



function moduleHasEnergyFlow {
    parameter thisMod.
    return thisMod:HasField("energy flow").
}

function modulesList {
    parameter comparator.
	PARAMETER panelList.
	
    LOCAL modulesOfInterest IS List().
    for part in panelList {
        for moduleName in part:modules {
            LOCAL module IS part:GetModule(moduleName).
            if comparator(module) {
                modulesOfInterest:add(module).
            }
        }
    }
    return modulesOfInterest.
}
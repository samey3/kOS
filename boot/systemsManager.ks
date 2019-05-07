@lazyglobal OFF.
RUNONCEPATH("0:/lib/shipControl.ks").

//Enable the automatic ship systems.
adaptiveLighting(TRUE).
adaptivePanels(TRUE).
autoStaging(TRUE).

//Does not let the manager end.
WAIT UNTIL(FALSE).
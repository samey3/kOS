@lazyglobal OFF.
RUNONCEPATH("0:/lib/shipControl.ks").

PRINT("Enabled adaptive lighting.").
adaptiveLighting(TRUE).
autoStaging(TRUE).

WAIT UNTIL(FALSE). //Does not let the manager end.
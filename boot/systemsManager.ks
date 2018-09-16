@lazyglobal OFF.
runoncepath("0:/lib/shipControl.ks").

PRINT("Enabled adaptive lighting.").
adaptiveLighting(TRUE).

WAIT UNTIL(FALSE). //Does not let the manager end.


//Do some checks, e.g. retract panels when entering atmosphere
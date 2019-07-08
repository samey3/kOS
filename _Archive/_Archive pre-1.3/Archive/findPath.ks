CLEARSCREEN.

//PARAMETER coords.


//Data structure
//--------------
//	surfaceNodes
//	|
//	|-[lat][lng]----- (nodes, coordinates, visited)
//					|
//					|
//					|-[0]*connected nodes*---
//					|						|
//					|						|-[0]-Node coordinates [lat][lng][0][n][0] (:LAT, :LNG suffixes)
//					|						|
//					|						|-[1]-Edge weight [lat][lnt][0][n][1]
//					|		
//					|
//					|-[2]*Visted node?*------ [lat][lng][1] (boolean)
//
//




//-------------------------------------------------------------------------------------------------------------------------
//BUILD DATA STRUCTURE FROM BODY
//-------------------------------------------------------------------------------------------------------------------------


//Update this so its a directed graph, and only across the portion it would possibly travel


SET vertexList TO LIST().
SET weightMap TO LIST().

SET surfaceNodes TO LIST(). //Empty list.
FROM {LOCAL i IS 0.} UNTIL i = 1 STEP {SET i TO i+1.} DO { //---------------------------------------------------179
	CLEARSCREEN.
	PRINT((((i + 1) / 360)*100) + "% complete.").
	
	surfaceNodes:ADD(LIST()).//Added list in next spot(i) [0,1,2,...,i]
	FROM {LOCAL j IS 0.} UNTIL j = 10 STEP {SET j TO j+1.} DO { //----------------------------------------------359
		surfaceNodes[i]:ADD(LIST()). 	//Creates J-portion of 2d-array
			surfaceNodes[i][j]:ADD(LIST()).	//Adds data list for the entry spot in the 2d-array
				LOCAL nodePoint IS LATLNG(i,j).
				FROM {LOCAL V IS i-1. LOCAL n IS 0.} UNTIL V > i+1 STEP {SET V TO V+1.} DO {
					FROM {LOCAL H IS j-1.} UNTIL H > j+1 STEP {SET H TO H+1.} DO {
						IF(V <> i OR H <> j){
							surfaceNodes[i][j][0]:ADD(LIST()). //i,j,0,n adds a list in the n-spot
							
							//Sets the coordinates
							LOCAL point IS LATLNG(cc(V),cc(H)).
							surfaceNodes[i][j][0][n]:ADD(point). 
							
							//Finds the weight of the connecting edge
							LOCAL slope IS ABS(nodePoint:TERRAINHEIGHT - point:TERRAINHEIGHT) / (nodePoint:POSITION - point:POSITION):MAG.
							IF(slope < 0.5) { surfaceNodes[i][j][0][n]:ADD(1). }
							ELSE IF (slope <= 8) { surfaceNodes[i][j][0][n]:ADD(10). }
							ELSE { surfaceNodes[i][j][0][n]:ADD(100). }
										
							SET n TO n+1.
						}						
					}
					
				}
			surfaceNodes[i][j]:ADD(false). //Visited[1]	
			vertexList:ADD(surfaceNodes[i][j]).
	}
}

//-------------------------------------------------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------------------------------------------------

//Do some output checking. All good so far!
LOCAL lat IS 0.
LOCAL lng IS 8.
LOCAL nodeN IS 5.
PRINT("Checking " + lat + "/" + lng).
PRINT("Visited? : " + surfaceNodes[lat][lng][1]).
PRINT("Coords : " + surfaceNodes[lat][lng][0][nodeN][0]:LAT + "/" + surfaceNodes[lat][lng][0][nodeN][0]:LNG). //nodes, first node, weight
PRINT("Weight : " + surfaceNodes[lat][lng][0][nodeN][1]). //nodes, first node, weight
PRINT("Height : " + surfaceNodes[lat][lng][0][nodeN][0]:TERRAINHEIGHT).
//Biggest issue may be, it automatically converts to -180/180 and -90/90 form. Though it would make more sense to users.

//-------------------------------------------------------------------------------------------------------------------------
//												  DO SOME PATH FINDING
//-------------------------------------------------------------------------------------------------------------------------


//ADD TO WEIGHT MAP
//SET weightMap[i][j] TO

//Would require a 4-nested for loop? or maybe when creating node weights, add them to a lexicon?



//0-180,0-360
//LOCAL n IS 0.
//LOCAL tempVal.
//FOR V IN vertexList {
//	tempVal = V % 180.
//   dist[i][j] = graph[i][j];
//
//	dist[DIV(n,180)][MOD(n,180)] = 0.
//	SET n TO n+1.
//}

//FOR k IN vertexList {
//	FOR i IN vertexList {
//		FOR j IN vertexList {
//			IF((dist[i][k] + dist[k][j]) < dist[i][j]){
//				SET dist[i][j] TO dist[i][k] + dist[k][j].
//			}
//		}
//	}    
//}




//-------------------------------------------------------------------------------------------------------------------------
//														FUNCTIONS
//-------------------------------------------------------------------------------------------------------------------------


//CorrectCoordinates. Keeps coordinates in range of 0-180/0-360
FUNCTION cc {
    PARAMETER coord.
	IF(coord < 0){ RETURN 360 + coord. }
	ELSE IF(coord > 360){ RETURN coord - 360. }
	ELSE { RETURN coord. }
}

FUNCTION DIV {
	PARAMETER quotient.
	PARAMETER divisor.	
	RETURN (quotient - divisor*MOD(quotient,divisor)).
}
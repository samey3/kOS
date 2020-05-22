@lazyglobal off.
//
//  display_bounds.ks
//  -----------------
//
// A small example program that will show you how to
// read the BOUNDS information of Vessels and Parts,
// and will display the box as a set of Vecdraws.
// You may iterate over the parts with the N and P
// keys. (The "-1 th" part is to show the whole
// vessel's box).
//

// Because this example uses lots of delegates
// in its VECDRAWs, it needs the time to keep running
// those delegates each update, or else it really
// bogs down:
if CONFIG:IPU < 500 {
  set CONFIG:IPU to 500.
  HUDTEXT("NOTICE: EXAMPLE SCRIPT INCREASED CONFIG:IPU TO " + CONFIG:IPU,
    20, 2, 22, magenta, true).
}
HUDTEXT("NOTICE: EXAMPLE SCRIPT INCREASED CONFIG:IPU TO " + CONFIG:IPU,20, 2, 22, magenta, true).

// =======================================
// These are some utility functions for this
// example program to help display things:
// =======================================

function vector_tostring_rounded {
  // Same thing that vector:tostring() normally
  // does, but with more rounding so the display
  // doesn't get so big:
  parameter vec.

  return "V(" +
    round(vec:x,2) + ", " +
    round(vec:y,2) + ", " +
    round(vec:z,2) + ")".
}

local arrows is LIST().
function draw_abs_to_box {
  // Draws the vectors from origin TO the 2 opposite corners of the box:

  parameter B.

  // Wipe any old arrow draws off the screen.
  for arrow in arrows { set arrow:show to false. }
  wait 0.

  arrows:CLEAR().
  arrows:ADD(Vecdraw(
    {return V(0,0,0).}, {return B:ABSMIN.}, RGB(1,0,0.75), "ABSMIN", 1, true)).
  arrows:ADD(Vecdraw(
    {return V(0,0,0).}, {return B:ABSMAX.}, RGB(1,0,0.75), "ABSMAX", 1, true)).
}

local edges is LIST().
function draw_box {
  // Draws a bounds box as a set of 12 non-pointy
  // vecdraws along the box edges:
  parameter B.

  // Wipe any old edge draws off the screen.
  for edge in edges { set edge:show to false. }
  wait 0.

  // These need to calculate using relative coords to find all the box edges:
  local rel_x_size is B:RELMAX:X - B:RELMIN:X.
  local rel_y_size is B:RELMAX:Y - B:RELMIN:Y.
  local rel_z_size is B:RELMAX:Z - B:RELMIN:Z.

  edges:CLEAR().

  // The 4 edges parallel to the relative X axis:
  edges:ADD(Vecdraw(
    {return B:ABSORIGIN + B:FACING * V(B:RELMIN:X, B:RELMIN:Y, B:RELMIN:Z).},
    {return B:FACING * V(rel_x_size, 0, 0).},
    RGBA(1,0,1,0.75), "", 1, true, 0.02, false, false)).
  edges:ADD(Vecdraw(
    {return B:ABSORIGIN + B:FACING * V(B:RELMIN:X, B:RELMIN:Y, B:RELMAX:Z).},
    {return B:FACING * V(rel_x_size, 0, 0).},
    RGBA(1,0,1,0.75), "", 1, true, 0.02, false, false)).
  edges:ADD(Vecdraw(
    {return B:ABSORIGIN + B:FACING * V(B:RELMIN:X, B:RELMAX:Y, B:RELMAX:Z).},
    {return B:FACING * V(rel_x_size, 0, 0).},
    RGBA(1,0,1,0.75), "", 1, true, 0.02, false, false)).
  edges:ADD(Vecdraw(
    {return B:ABSORIGIN + B:FACING * V(B:RELMIN:X, B:RELMAX:Y, B:RELMIN:Z).},
    {return B:FACING * V(rel_x_size, 0, 0).},
    RGBA(1,0,1,0.75), "", 1, true, 0.02, false, false)).

  // The 4 edges parallel to the relative Y axis:
  edges:ADD(Vecdraw(
    {return B:ABSORIGIN + B:FACING * V(B:RELMIN:X, B:RELMIN:Y, B:RELMIN:Z).},
    {return B:FACING * V(0, rel_y_size, 0).},
    RGBA(1,0,1,0.75), "", 1, true, 0.02, false, false)).
  edges:ADD(Vecdraw(
    {return B:ABSORIGIN + B:FACING * V(B:RELMIN:X, B:RELMIN:Y, B:RELMAX:Z).},
    {return B:FACING * V(0, rel_y_size, 0).},
    RGBA(1,0,1,0.75), "", 1, true, 0.02, false, false)).
  edges:ADD(Vecdraw(
    {return B:ABSORIGIN + B:FACING * V(B:RELMAX:X, B:RELMIN:Y, B:RELMAX:Z).},
    {return B:FACING * V(0, rel_y_size, 0).},
    RGBA(1,0,1,0.75), "", 1, true, 0.02, false, false)).
  edges:ADD(Vecdraw(
    {return B:ABSORIGIN + B:FACING * V(B:RELMAX:X, B:RELMIN:Y, B:RELMIN:Z).},
    {return B:FACING * V(0, rel_y_size, 0).},
    RGBA(1,0,1,0.75), "", 1, true, 0.02, false, false)).

  // The 4 edges parallel to the relative Z axis:
  edges:ADD(Vecdraw(
    {return B:ABSORIGIN + B:FACING * V(B:RELMIN:X, B:RELMIN:Y, B:RELMIN:Z).},
    {return B:FACING * V(0, 0, rel_z_size).},
    RGBA(1,0,1,0.75), "", 1, true, 0.02, false, false)).
  edges:ADD(Vecdraw(
    {return B:ABSORIGIN + B:FACING * V(B:RELMIN:X, B:RELMAX:Y, B:RELMIN:Z).},
    {return B:FACING * V(0, 0, rel_z_size).},
    RGBA(1,0,1,0.75), "", 1, true, 0.02, false, false)).
  edges:ADD(Vecdraw(
    {return B:ABSORIGIN + B:FACING * V(B:RELMAX:X, B:RELMAX:Y, B:RELMIN:Z).},
    {return B:FACING * V(0, 0, rel_z_size).},
    RGBA(1,0,1,0.75), "", 1, true, 0.02, false, false)).
  edges:ADD(Vecdraw(
    {return B:ABSORIGIN + B:FACING * V(B:RELMAX:X, B:RELMIN:Y, B:RELMIN:Z).},
    {return B:FACING * V(0, 0, rel_z_size).},
    RGBA(1,0,1,0.75), "", 1, true, 0.02, false, false)).
}

//
// ===============================
//        main program
// ===============================
//

local pNum is -1.
local keyPress is "".

until keyPress = "q" {

  local box is 0. // will get set to the bounds box in a moment.
  local description is "".

  clearscreen.
  
  LOCAL relVel IS SHIP.
  PRINT("Name : " + relVel:NAME).

  if pNum = -1 {
    // PART NUMBER -1 will be a special flag this
    // example program uses to mean "entire vessel".
    set box to relVel:bounds.
    set description to relVel:TOSTRING().
  } else {
    local p is relVel:parts[pNum].
    set box to p:bounds.
    set description to "Part[" + pNum + "]:" + p:TOSTRING().
  }

  // These two functions do the actual drawing, and are defined
  // below in this file.  When trying to learn how this works,
  // look at draw_abs_to_box() first - it's the simpler one to
  // understand that just uses absolute coordinates.  The other
  // one, draw_box(), is more complex as it has to use the
  // relative coords to get all the other corners of the box:
  draw_abs_to_box(box).
  draw_box(box).

  print "Showing bounds of: " + description.
  print "-----------------------------------------------------------".
  print "        ABSMIN: " + vector_tostring_rounded(box:ABSMIN).
  print "        ABSMAX: " + vector_tostring_rounded(box:ABSMAX).
  print "     ABSORIGIN: " + vector_tostring_rounded(box:ABSORIGIN).
  print "     ABSCENTER: " + vector_tostring_rounded(box:ABSCENTER).
  print "        RELMIN: " + vector_tostring_rounded(box:RELMIN).
  print "        RELMAX: " + vector_tostring_rounded(box:RELMAX).
  print "       EXTENTS: " + vector_tostring_rounded(box:EXTENTS).
  print "          SIZE: " + vector_tostring_rounded(box:SIZE).
  print "     RELCENTER: " + vector_tostring_rounded(box:RELCENTER).
  print "     BOTTOMALT: " + round(box:BOTTOMALT,2).
  print "BOTTOMALTRADAR: " + round(box:BOTTOMALTRADAR,2).
  print "-----------------------------------------------------------".
  print "Press N for next, P for previous, Q for quit.".
  set keyPress to terminal:input:getchar().
  if keyPress = "n" set pNum to min(relVel:parts:length-1, pNum + 1).
  if keyPress = "p" set pNum to max(-1, pNum - 1).

  clearvecdraws().
}
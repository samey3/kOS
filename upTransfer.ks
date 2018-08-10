	
	
	
	
First make sure circular.

Take current radius, take target radius.
Find time to that radius.

Your transfer will take t_time, and will cover 1/2 orbit (1 PI).
The target body will movein t_time by some angle.

IF your orbit < body
set apo, find time
180 - body_move_angle = distance you require in front of you.


IF your orbit > body
set peri, find time.
angle - 180, you require behind you.
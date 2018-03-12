if {0} {
	
	== Falling trolls prankster
Avoid falling objects
Gain points for every second 
Some falling objects give you a specific power
Ennemies at different speeds and sizes
Buy extra skills
reverse bad guy, slow down bad guy, shoot bad guy
fully random and highscore

This may be overwhelming at once but let;s just start doing it step by step.

#Version 1
For version 1 we just draw a canvas. 
A troll image which we place on top
And our hero which we'll place at the bottom

We alrady put the utilities RND function which we'll use later on

TODO explanations

Note that the X/Y axis numbering starts from the TOP LEFT corner being 0,0
Placing an image places it from the center of that image


package require Tk
package require Img 

set settings(screen_width) 1000
set settings(screen_height) 800
proc init {} {
	global settings images canvas
	grid [canvas .canvas -width 1000 -height 800 -bg white]

	set images(troll) [image create photo  -file "./images/troll.png"] 
	set images(hero) [image create photo  -file "./images/hero.gif"] 

	set canvas(troll) [.canvas create image 500 150 -image $images(troll) -tags troll]
	set canvas(hero) [.canvas create image 500 750 -image $images(hero) -tags hero]

}

#Misc Utilities
proc rnd {min max} {
		expr {int(($max - $min + 1) * rand()) + $min}
}
init
}

if {0} {



proc createProductImage {imgName img type} {
		if {![string match *$imgName* [image names]  ]} { 
			set img [image create photo $imgName -file "./images/${type}_$img"] 
		}
		return $imgName
	}


#VERSION 2	
With this version we want to move our little hero to the left and to the right but not outside the width of the screen.
We'll also want to make a copy of the troll image and shrink it since it's too large

package require Tk
package require Img

set settings(screen_width) 1000
set settings(screen_height) 800
proc init {} {
	global settings images canvas
	grid [canvas .canvas -width 1000 -height 800 -bg white]

	set images(troll) [image create photo  -file "./images/troll.png"] 
	set images(trollsmall) [image create photo]
	$images(trollsmall) copy $images(troll) -subsample 2 2
	set images(hero) [image create photo  -file "./images/hero.gif"] 
	
	set canvas(troll) [.canvas create image 500 50 -image $images(trollsmall) -tags troll -anchor center]
	set canvas(hero) [.canvas create image 500 750 -image $images(hero) -tags hero]
	
	
	bind . <Key> {
		puts "You pressed %K"
	}

	bind . <Key-Left> {	moveHero Left }
	bind . <Key-Right> {	moveHero Right }


}
#Left or right means the X axis 
#Move by 7px you can go anywhere from 5 to 10px
proc moveHero {direction {move 0}} {
	global canvas settings
	lassign [.canvas coords $canvas(hero)] x y
	set x [expr {int($x)}]
	set y [expr {int($y)}]
		 
	switch -nocase -- $direction {
		left {
			incr x -5
		}
		right {
			incr x 5
		}
	}
	
	if {$x >= $settings(screen_width) || $x <=0} { return }
	puts "New Location $x $y"
	.canvas coords $canvas(hero) $x $y

	if {$move > 0} {
		puts $move
		incr move -1
		after 100 [list moveHero $direction $move]
	}
	
}

#Misc Utilities
proc rnd {min max} {
		expr {int(($max - $min + 1) * rand()) + $min}
}
init


}
if {0} {
	
#VERSION 3	
First we make the trolls much smaller..
Now we will create a new function that generates randomly placed Trolls  outside the viewport/canvas on the x axis between 0 and $settings(screen_width) 1000 and y -100 pixels.
Another function will move these trolls down up until they get at the $settings(screen_height) 800 location.
When they reach the bottom we clean them up.
Cleaning up variables, unused images and objects is a very wise thing to do. It clears memory, allows you to stop slow downs of your programs and you avoid bugs later on.

New trolls get created every 1 second. They move every 50 milliseconds so it appears that they're sliding down

We also verify if the user collides with any troll.. informing him with tk_messageBox -message

package require Tk
package require Img

set settings(screen_width) 1000
set settings(screen_height) 800
proc init {} {
	global settings images canvas
	grid [canvas .canvas -width 1000 -height 800 -bg white]

	set images(troll) [image create photo  -file "./images/troll.png"] 
	set images(trollsmall) [image create photo]
	$images(trollsmall) copy $images(troll) -subsample 2 2
	set images(hero) [image create photo  -file "./images/hero.gif"] 
	
	set canvas(troll) [.canvas create image 500 50 -image $images(trollsmall) -tags troll -anchor center]
	set canvas(hero) [.canvas create image 500 750 -image $images(hero) -tags hero]
	
	
	bind . <Key> {
		puts "You pressed %K"
	}

	bind . <Key-Left> {	moveHero Left }
	bind . <Key-Right> {	moveHero Right }

	
}
#Left or right means the X axis 
#Move by 7px you can go anywhere from 5 to 10px
proc moveHero {direction {move 0}} {
	global canvas settings
	lassign [.canvas coords $canvas(hero)] x y
	set x [expr {int($x)}]
	set y [expr {int($y)}]
	

	 
	switch -nocase -- $direction {
		left {
			incr x -7
		}
		right {
			incr x 7
		}
	}
	#The modifier should be 1/3 or 1/2 of the width of our hero
	set modifier 10
	if {$x > [expr {$settings(screen_width)-$modifier}] || $x <=$modifier} { return }
	.canvas coords $canvas(hero) $x $y

	if {$move > 0} {
		puts $move
		incr move -1
		after 100 [list moveHero $direction $move]
	}
	
}

proc generateRandomTroll {}  {
	global trolls canvas settings images

	#we could also do rnd 0 $settings(screen_width) but this will generate most of the trolls on the sides... 
	#while we want most of them to be in the center, rarely on the sides
	set perfectDistance [expr {$settings(screen_width)/5}]
	set x_location [rnd [rnd 0 $perfectDistance] [rnd [expr {$perfectDistance*4}] $settings(screen_width) ]]
#	set x_location [rnd 10 [expr {$settings(screen_width)-10}]]
	lappend trolls [.canvas create image $x_location  -50 -image $images(trollsmall) -tags troll -anchor center]
	puts "Generated troll at $x_location"
	after 700 [list generateRandomTroll ]
}

#Notice how we can move them all at the same time with the move function?
proc moveTrolls {} {
	global trolls canvas settings images

	.canvas move troll 0 5
	
	foreach troll $trolls {
		lassign [.canvas coords $troll] x y
		#Delete the canvas item and remove it from the list!
		if {$y >  $settings(screen_height)} {
			.canvas delete $troll
			puts "Deleting troll $troll"
			set trolls [lremove  $trolls $troll]
		}
	}
	
	if {![collideWithHero]} {
		after 50 [list moveTrolls]
	}
}

#Collision
proc collideWithHero {} {
	global canvas settings
	lassign [.canvas coords $canvas(hero)] x y
	
	foreach {x1 y1 x2 y2} [.canvas bbox hero]  {}
	set width [expr {$x2-$x1}] 	
	set height [expr {$y2-$y1}] 	

	
	set collision [.canvas find overlapping [expr {$x-$width/3}] [expr {$y-$height/3}] [expr {$x+$width/3}] [expr {$y+$height/3}] ]
	if {[llength $collision ] > 1} {
	puts "COLLISSION with troll [.canvas bbox [lindex $collision 0]]  hero [.canvas bbox [lindex $collision 1]]   ! "

		foreach after [after info] {
			after cancel $after
		}
		
		tk_messageBox -message "The troll got you! GAME ENDED"
		return 1
	}
	return 0
}
#Misc Utilities
proc rnd {min max} {
	expr {int(($max - $min + 1) * rand()) + $min}
}
#Remove an element from the list
proc lremove {args} {
	
	   array set opts {-all 0 pattern -exact}
    while {[string match -* [lindex $args 0]]} {
	switch -glob -- [lindex $args 0] {
	    -a*	{ set opts(-all) 1 }
	    -g*	{ set opts(pattern) -glob }
	    -r*	{ set opts(pattern) -regexp }
	    --	{ set args [lreplace $args 0 0]; break }
	    default {return -code error "unknown option \"[lindex $args 0]\""}
	}
	set args [lreplace $args 0 0]
    }
    set l [lindex $args 0]
    foreach i [join [lreplace $args 0 0]] {
	if {[set ix [lsearch $opts(pattern) $l $i]] == -1} continue
	set l [lreplace $l $ix $ix]
	if {$opts(-all)} {
	    while {[set ix [lsearch $opts(pattern) $l $i]] != -1} {
		set l [lreplace $l $ix $ix]
	    }
	}
    }
    return $l
}
puts [info patchlevel]
init
generateRandomTroll
moveTrolls
}

if {0} {

#Version 4

Every 5 seconds we increase the speed.
We generate trolls faster.

Top Left corner has text with the hero's  lives
and is updated every 500 milliseconds with a +10 score
Whenever he gets hit we put a red text above his head HIT  and decrease a life
When his lives are over.. A big text GAME ENDED appears


EXERCISE: To make it more interesting we'll create trolls that are different sizes and move at different speeds.

}
package require Tk
package require Img

set settings(screen_width) 1000
set settings(screen_height) 800
set settings(lives) 3
set settings(score) 0
proc init {} {
	global settings images canvas
	grid [canvas .canvas -width 1000 -height 800 -bg white]

	set images(troll) [image create photo  -file "./images/troll.png"] 
	set images(trollsmall) [image create photo]
	$images(trollsmall) copy $images(troll) -subsample 2 2
	set images(hero) [image create photo  -file "./images/hero.gif"] 
	
	set canvas(troll) [.canvas create image 500 50 -image $images(trollsmall) -tags troll -anchor center]
	set canvas(hero) [.canvas create image 500 750 -image $images(hero) -tags hero]
	
	
	bind . <Key> {
		puts "You pressed %K"
	}

	bind . <Key-Left> {	moveHero Left }
	bind . <Key-Right> {	moveHero Right }
	
	#version 4
	set font {Arial 20}
	set canvas(lives) [.canvas create text 30 20 -text "Lives: $settings(lives)"  -font $font -anchor w ]
	set canvas(score) [.canvas create text 30 50 -text "Score: $settings(score)"  -font $font -anchor w]	
	.canvas raise  $canvas(score)
	.canvas raise  $canvas(lives) 
}
#version 4
proc updateScore {time} {
	global canvas settings
	incr settings(score) 10
	.canvas itemconfigure $canvas(score)  -text "Score: $settings(score)"
	after $time [list updateScore $time]
}

#Left or right means the X axis 
#Move by 7px you can go anywhere from 5 to 10px
proc moveHero {direction {move 0}} {
	global canvas settings images
	lassign [.canvas coords $canvas(hero)] x y
	set x [expr {int($x)}]
	set y [expr {int($y)}]
	

	 
	switch -nocase -- $direction {
		left {
			incr x -7
		}
		right {
			incr x 7
		}
	}
	#The modifier should be 1/3 or 1/2 of the width of our hero
	set width [image width $images(hero)]
	set modifier [expr {$width/2}]
	if {$x > [expr {$settings(screen_width)-$modifier}] || $x <=$modifier} { return }
	.canvas coords $canvas(hero) $x $y

	if {$move > 0} {
		puts $move
		incr move -1
		after 100 [list moveHero $direction $move]
	}
	
}

proc generateRandomTroll {time}  {
	global trolls canvas settings images

	#we could also do rnd 0 $settings(screen_width) but this will generate most of the trolls on the sides... 
	#while we want most of them to be in the center, rarely on the sides
	set perfectDistance [expr {$settings(screen_width)/5}]
	set x_location [rnd [rnd 0 $perfectDistance] [rnd [expr {$perfectDistance*4}] $settings(screen_width) ]]
#	set x_location [rnd 10 [expr {$settings(screen_width)-10}]]
	lappend trolls [.canvas create image $x_location  -50 -image $images(trollsmall) -tags troll -anchor center]

	incr time -5
	after $time [list generateRandomTroll $time ]
}

#Notice how we can move them all at the same time with the move function?
proc moveTrolls {time} {
	global trolls canvas settings images

	.canvas move troll 0 5
	
	foreach troll $trolls {
		lassign [.canvas coords $troll] x y
		#Delete the canvas item and remove it from the list!
		if {$y >  $settings(screen_height)} {
			.canvas delete $troll
			puts "Deleting troll $troll"
			set trolls [lremove  $trolls $troll]
		}
	}
	
	#version 3
	if {![collideWithHero]} {

		if {[expr {[clock seconds] - $settings(lastCheck)}] >= 5} {
			incr time -1
			set settings(lastCheck) [clock seconds]
			puts "Increasing troll speed $time"
		}
		after $time [list moveTrolls $time]
	}
}

#Collision
proc collideWithHero {} {
	global canvas settings
	lassign [.canvas coords $canvas(hero)] x y
	
	foreach {x1 y1 x2 y2} [.canvas bbox hero]  {}
	set width [expr {$x2-$x1}] 	
	set height [expr {$y2-$y1}] 	

	
	set collision [.canvas find overlapping [expr {$x-$width/3}] [expr {$y-$height/3}] [expr {$x+$width/3}] [expr {$y+$height/3}] ]
	if {[llength $collision ] > 1} {
			puts "COLLISSION with troll [.canvas bbox [lindex $collision 0]]  hero [.canvas bbox [lindex $collision 1]]   ! "
			
		incr settings(lives) -1
		.canvas itemconfigure $canvas(lives)  -text "Lives: $settings(lives)"
		set canvasText  [.canvas create text $x [expr {$y-$height}] -text "*HIT*" -fill red -font {Arial 13} -anchor n]	
		.canvas delete [lindex $collision 1] 	
		displayHitText $canvasText  25
		if {$settings(lives) <= 0} {
			foreach after [after info] {
				after cancel $after
			}
			tk_messageBox -message "The trolls got you for good this time! GAME ENDED"
			return 1
		}
		return 0
	}
	return 0
}
#Version 4
proc displayHitText {canvasText iterations} {
	global canvas
	incr iterations -1
	
	.canvas move $canvasText 0 -5
	if {!$iterations} {
		.canvas delete $canvasText
		return 0
	}
	after 100 [list displayHitText $canvasText $iterations]
}
#Misc Utilities
proc rnd {min max} {
	expr {int(($max - $min + 1) * rand()) + $min}
}
#Remove an element from the list
proc lremove {args} {
	
	   array set opts {-all 0 pattern -exact}
    while {[string match -* [lindex $args 0]]} {
	switch -glob -- [lindex $args 0] {
	    -a*	{ set opts(-all) 1 }
	    -g*	{ set opts(pattern) -glob }
	    -r*	{ set opts(pattern) -regexp }
	    --	{ set args [lreplace $args 0 0]; break }
	    default {return -code error "unknown option \"[lindex $args 0]\""}
	}
	set args [lreplace $args 0 0]
    }
    set l [lindex $args 0]
    foreach i [join [lreplace $args 0 0]] {
	if {[set ix [lsearch $opts(pattern) $l $i]] == -1} continue
	set l [lreplace $l $ix $ix]
	if {$opts(-all)} {
	    while {[set ix [lsearch $opts(pattern) $l $i]] != -1} {
		set l [lreplace $l $ix $ix]
	    }
	}
    }
    return $l
}
puts [info patchlevel]
init
set settings(start) [clock seconds]
set settings(lastCheck) [clock seconds]
generateRandomTroll 700
moveTrolls 50
after 2000 [list updateScore 500]

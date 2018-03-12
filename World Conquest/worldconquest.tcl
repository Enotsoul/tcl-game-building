if {0} {
World Conquest
Description: Each territory has a certain number of armies which can be used to attack adjacent territories. 
The player can attack as often as they want, but conquering too many
 territories stretches out their troops so that the territories can be reclaimed easily. 
 Additional armies are given based on conquered territories, so not expanding fast enough 
 will also lead to losing. A straight forward AI is relatively easy to produce.

Variants: Dice Wars is a high-speed Flash game that is similar to Risk.

This is usually a game played with AI's so we'll design the AI implementation early on.


#VERSSION 1
Version 1 we draw the "lands" as simple boxes so we focus on the gameplay first.
You can draw the lands with the canvas if you want making different forms with the polygon option.

Then we handle the click event in 2 different ways, notice how it works by clicking around.




package require Tk
package require Img

set settings(screen_width) 1100
set settings(screen_height) 900
proc init {} {
	global settings lands canvas
	grid [canvas .canvas -width $settings(screen_width) -height $settings(screen_height) -bg white]

	set xoffset 10
	set yoffset 10
	set ysize 150
	set xsize 150
	for {set y 1} {$y<=5} {incr y }  {
		for {set x 1 } {$x <= 7} {incr x }  {
			set startx [expr {($x-1)*$xsize+$xoffset}]
			set starty [expr {($y-1)*$ysize+$yoffset}]
			set endx [expr {$x*$xsize+$xoffset}]
			set endy [expr {$y*$ysize+$yoffset}]
	
			set land land$x.$y
			set landid [.canvas create rectangle "$startx $starty $endx $endy" -fill #C2C2C2 -tags $land -outline black -activefill #ECECEC -width 2]
			.canvas bind $landid <Button-1> [list clickOnLand $landid]
			lappend lands($landid) na
		}
	}
	set settings(startGame) 1

	bind .canvas <Button-1> { onClick %x %y }
}
#The "best" way to handle a click on a specific land
proc clickOnLand {landid} {
	tk_messageBox -message "You clicked on the specific land $landid"
}

#the canvas way to handle a click
#Note that if you missclick somewhere next to a land it will find another land
#EXERCISE review how you could fix this with either verifying the BBOX or find enclosed
proc onClick {x y} {
	set x [.canvas canvasx $x] ; set y [.canvas canvasy $y]
	set i [.canvas find closest $x $y]

	set t [.canvas gettags $i]
	tk_messageBox -message "You clicked on the canvas and we thought you meant the land $i $t"
}

#Misc Utilities
proc rnd {min max} {
		expr {int(($max - $min + 1) * rand()) + $min}
}
init

}


if {0} {
	#VERSION 2
	We  allow the player to chose a land where he'll start.
	Then assigning 3 ai's a random land on the board different than our own

We'll have a StartGame function which assigns every emtpy land  a text field with a random army power between 1 and 2.
We'll also assign our player and AI lands an army of 3

Introducing dictionaries via the dict function. This will allow us to center the lands settings like owner, 
army and  other info later in the game.
EXERCISE: You can implement the whole game using lists and arrays, modifying where we have a dictionary.

}
package require Tk
package require Img 1.4

set settings(screen_width) 1100
set settings(screen_height) 900
set settings(font) "Arial 14"
#VERSION 2: Not really needed, we can also create a simple variable, 
#though the dict create should have a certain internal speedup
set lands [dict create]
proc init {} {
	global settings lands 
	grid [canvas .canvas -width $settings(screen_width) -height $settings(screen_height) -bg white]

	set maxx 7
	set maxy  5
	set xoffset 10
	set yoffset 10
	set ysize 150
	set xsize 150
	for {set y 1} {$y<=$maxy} {incr y }  {
		for {set x 1 } {$x <= $maxx} {incr x }  {
			set startx [expr {($x-1)*$xsize+$xoffset}]
			set starty [expr {($y-1)*$ysize+$yoffset}]
			set endx [expr {$x*$xsize+$xoffset}]
			set endy [expr {$y*$ysize+$yoffset}]
	
			set land land$x.$y
			set landid [.canvas create rectangle "$startx $starty $endx $endy" -fill #C2C2C2 -tags $land -outline black -activefill #ECECEC -width 2]
			.canvas bind $landid <Button-1> [list clickOnLand $landid]
			dict set lands $landid owner na
		}
	}
	set settings(startGame) 1

	#bind .canvas <Button-1> { onClick %x %y }
}

proc clickOnLand {landid} {
	global settings lands
	if {$settings(startGame)} {
		.canvas itemconfigure $landid -fill #4ADD6D -activefill #95E8A9 
		set settings(player1) $landid
		dict set lands $landid owner player1
		lappend setting(turnorder) player1
		assignAILands
		startGame
	}
}

proc assignAILands {} {
	global lands settings 
	#VERSION 2
	set newlands [lremove [dict keys $lands] $settings(player1)]
	
	set max [llength $newlands]
	foreach ai {1 2 3} {fill activefill} { #DD4A4E #E8959A  #4E4ADD  #959DE8    #4AC8DD  #95E1E8 } { 
		set landAI [lindex $newlands [rnd 0 $max]-1]
		set settings(ai$ai) $landAI
		puts "AI LAND $landAI"
		.canvas itemconfigure $landAI -fill $fill -activefill $activefill
		lappend setting(turnorder) ai$ai
		dict set lands $landAI owner ai$ai
		#Remove the current AI land from the list, so the next AI doesn't collide
		set newlands [lremove $newlands $landAI]
		set max [llength $newlands]

	}
}
proc  startGame {} {
	global settings lands
	puts "LANDS $lands"
	foreach {land} [dict keys $lands] {
		if {[regexp {player.+|ai.+} [dict get $lands $land owner]]} {
			set army 3
		} else {
			set army [rnd 1 2]
		}
		#TODO switch to coords
		foreach {x1 y1 x2 y2} [.canvas bbox $land] { }
		set centerx [expr {($x2+$x1)/2}] 
		set centery [expr {($y2+$y1)/2}]
		set text [.canvas create text $centerx $centery -text "$army"  -font $settings(font) ]	
		#anchor center
		dict set lands $land army $army
		dict set lands $land text $text
		puts "Land $land army $army text $text at $centerx $centery owner [dict get $lands $land owner] [.canvas coords $land]"
	}
	
	set settings(startGame) 0
}


#Misc Utilities
proc rnd {min max} {
		expr {int(($max - $min + 1) * rand()) + $min}
}
#This is our custom made lremove
#	#If you want to use original lremove copy it from the fallingtrolls game
proc lremove {list index} {
	set searchid [lsearch $list $index)]
	return [lreplace $list $searchid $searchid ""]
}
init

if {0} {
	#VERSION 3
	In this version we want to introduce turns.
	Each turn each unowned land has a 1 in 3 chance to gain 1 land.
	Players and AI gain +1 army per land they own
	implementing an End turn button signifies the turn goes to the other AI's and then back to the user
	We also want to implement an attack function, attacking nearby lands.
	First clicking the land we want to use as an army to the next adjacent land we want to attack
	Drawing an arrow from the one direction to the other
	
	The lands must be adjacent.
	When attacking you are asked how many soldiers you want to deploy
	The remaining soldiers are left behind
	
	
	VERSION 4?
	BASIC AI:
	The AI selects an adjacent location to attack based upon which adjacent location
	is "weaker" than his location
	
	Implementing a basic FLASHing mechanism letting us know which land a AI has chosen
	Which Land an AI wants to attack
	Which land we have chosen
		set timer 100
		after $timer [list	.canvas itemconfigure $landAI -fill $activefill]
		after [incr timer 150] 	[list .canvas itemconfigure $landAI -fill $fill]
		after [incr timer 150] [list	.canvas itemconfigure $landAI -fill $activefill]
		after [incr timer 150] 	[list .canvas itemconfigure $landAI -fill $fill]
}

if {0} {
	#VERSION 4
	
}

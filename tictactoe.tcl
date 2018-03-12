if {0} {
	tic tac toe
	3x3 grid
	X and 0
	Player Vs Player
	Player vs AI
	
	
	#Version 1
	We draw a 3x3 grid of buttons
	When we click a button it switches by changing it to X or O
	depending on the previous setting, registering this in the global gameboard variable
	Switching X or O after each click, disabling the command ( so you can't click 10 times)
	Initialize the gameboard
package require Tk
set settings(current) X
array set gameboard ""
proc init {} {
	ttk::label .lblInfo -text "X or O"
	grid .lblInfo -row 0 -column 1
	
	for {set x 1} { $x<=3} { incr x } {
		for {set y 1} { $y<=3} { incr y } {
			grid [button .btn$x$y -text " " -command [list placeXorO $x $y] \
			-width 5 -height 2 			] -row $y -column $x
			set gameboard($x,$y) ""
		}
	}
}

proc placeXorO {x y} {
	global gameboard settings
	set gameboard($x,$y) $settings(current)
	.btn$x$y configure -text   $settings(current) -command {}
	
	switch -- $settings(current) {
		X { set settings(current) O }
		O { set settings(current) X }
	}
}

#Function that takes min and max and generates a random integer number
proc rnd {min max} {
		expr {int(($max - $min + 1) * rand()) + $min}
}

init
}
if {0} {
	
	#VERSION 2
	We now implement some functions that verify if there are 3 X's or O's in a row
	Diagonally (2 diagonals), horizontally or vertically 	after each  move
	Verifying the whole board for wins.
	Optimally we should verify from the last move
	something which we will do in the 4 and 5 in a row games with a more difficult
	but efficient algorithm. For now this will do.
	
	Inform the user when it's his turn via the label.
	NOTE: View how we split everything in it's own function.
	The VerifyWinner could have contained 8 If's and other things
	making it a function longer than 20 lines.
	By splitting functions up we make our code maintainable and easier to read.
	We spend  between 5:1 and 10:1 time in reading to writing ration when coding, keep this in mind!
	package require Tk
set settings(current) X
array set gameboard ""
proc init {} {
	global gameboard
	ttk::label .lblInfo -text "Player X's turn"
	grid .lblInfo -row 0 -column 1 -columnspan 3
	
	for {set x 1} { $x<=3} { incr x } {
		for {set y 1} { $y<=3} { incr y } {
			grid [button .btn$x$y -text " " -command [list placeXorO $x $y] \
			-width 5 -height 2 			] -row $y -column $x
			set gameboard($x,$y) ""
		}
	}
}

proc placeXorO {x y} {
	global gameboard settings
	set gameboard($x,$y) $settings(current)
	.btn$x$y configure -text   $settings(current) -command {}
	
	verifyWinner $settings(current)
	switch -- $settings(current) {
		X { set settings(current) O }
		O { set settings(current) X }
	}
	.lblInfo  configure -text "Player $settings(current)'s turn"
}

#Version 2
#Verify the winner
proc verifyWinner {type} {
	set win 0
	incr win [verifyDiagonals $type]
	incr win [verifyHorizontal $type]
	incr win [verifyVertical $type]
	
	if {$win} {
		set text "Player $type wins!"
		tk_messageBox -message  $text
		.lblInfo configure -text  $text
	}
}
proc verifyDiagonals {type} {
	global gameboard
	if {$gameboard(1,1) == $type && $gameboard(2,2) == $type && $gameboard(3,3) == $type} {
		return 1
	}
	if {$gameboard(1,3) == $type && $gameboard(2,2) == $type && $gameboard(3,1) == $type} {
		return 1
	}
	
	return 0
}

#verify the 3 horizontal lines
proc verifyHorizontal {type} {
	global gameboard
	for {set y 1} {$y<=3} {incr y} {
		if {$gameboard(1,$y) == $type && $gameboard(2,$y) == $type 
			&& $gameboard(3,$y) == $type} {
			return 1
		}
	}
	return 0
}
#Verify the 3 vertical lines
proc verifyVertical {type} {
	global gameboard
	for {set x 1} {$x<=3} {incr x} {
		if {$gameboard($x,1) == $type && $gameboard($x,2) == $type 
			&& $gameboard($x,3) == $type} {
			return 1
		}
	}
	return 0
}

#Function that takes min and max and generates a random integer number
proc rnd {min max} {
		expr {int(($max - $min + 1) * rand()) + $min}
}

init
}

if {0} {
	#Version 3
	Button to restart game 
	Reinitialize buttons and gameboard array
	Checkboxes to specify
	Player Vs Player
	Player VS AI
	Basic AI implementation: 
	1st turn places a O on an empty space
	
	[places O next to the other O's
	blocks X'es]
	
	Verify Draw (3x3 board is full)
	Disable all other buttons when someone wins untill he clicks the restart buttons
	
}
package require Tk
set settings(current) X
array set gameboard ""
proc init {} {
	global gameboard
	ttk::label .lblInfo -text "Player X's turn"
	grid .lblInfo -row 0 -column 1 -columnspan 3
	
	for {set x 1} { $x<=3} { incr x } {
		for {set y 1} { $y<=3} { incr y } {
			grid [button .btn$x$y -text " " -command [list placeXorO $x $y] \
			-width 5 -height 2 			] -row $y -column $x
			set gameboard($x,$y) ""
		}
	}
		
	grid [ttk::label .lblGameMode -text "Game Mode"] -row 0 -column 0 
	grid [ttk::radiobutton .radHuman -text "Player VS Player" -variable gamemode -value human ] -row 1 -column 0
	grid [ttk::radiobutton .radAI -text "Player vs AI" -variable gamemode -value ai ] -row 2 -column 0
	.radHuman invoke
	grid [ttk::button .btnRestart -text "Restart Game" -command reinitializeBoard ] -row 3 -column 0
}

proc placeXorO {x y} {
	global gameboard settings
	set gameboard($x,$y) $settings(current)
	.btn$x$y configure -text   $settings(current) -command {}
	
	if {![verifyWinner $settings(current)]}  {
		switch -- $settings(current) {
			X { set settings(current) O }
			O { set settings(current) X }
		}
		.lblInfo  configure -text "Player $settings(current)'s turn"
		moveAI
	}
}

#Version 2
#Verify the winner
proc verifyWinner {type} {
	set win 0

	incr win [verifyDiagonals $type]
	incr win [verifyHorizontal $type]
	incr win [verifyVertical $type]
	
	if {$win} {
		message  "Player $type wins!"		
		reinitializeBoard 1
		return 1
	}
	if {[verifyDraw]} { 	message  "Draw!"	; return 0 } 
	return 0
}
#Version 3
proc message {message} {
	tk_messageBox -message  $message
	.lblInfo configure -text  $message
}
proc verifyDiagonals {type} {
	global gameboard
	if {$gameboard(1,1) == $type && $gameboard(2,2) == $type && $gameboard(3,3) == $type} {
		return 1
	}
	if {$gameboard(1,3) == $type && $gameboard(2,2) == $type && $gameboard(3,1) == $type} {
		return 1
	}
	
	return 0
}

#verify the 3 horizontal lines
proc verifyHorizontal {type} {
	global gameboard
	for {set y 1} {$y<=3} {incr y} {
		if {$gameboard(1,$y) == $type && $gameboard(2,$y) == $type 
			&& $gameboard(3,$y) == $type} {
			return 1
		}
	}
	return 0
}
#Verify the 3 vertical lines
proc verifyVertical {type} {
	global gameboard
	for {set x 1} {$x<=3} {incr x} {
		if {$gameboard($x,1) == $type && $gameboard($x,2) == $type 
			&& $gameboard($x,3) == $type} {
			return 1
		}
	}
	return 0
}
#Version 3

proc verifyDraw {} {
	global gameboard
	set totalMoves 0
	for {set x 1} { $x<=3} { incr x } {
		for {set y 1} { $y<=3} { incr y } {

			if {$gameboard($x,$y) !=""} {
				incr  totalMoves
			}
		}
	}
	if {$totalMoves == 9} {
		return 1
	}
	return 0
}
proc reinitializeBoard {{disableButtons 0}} {
	global gameboard settings
	.lblInfo configure -text "Player X's turn"
	for {set x 1} { $x<=3} { incr x } {
		for {set y 1} { $y<=3} { incr y } {
			if {!$disableButtons} {
				.btn$x$y configure -text " " -command [list placeXorO $x $y] 
				set gameboard($x,$y) ""
			} else {
				.btn$x$y configure -command {}
			}
		}
	}
	set settings(current) X
}
#Simple AI, chose a random location that's empty to place an O
#TODO verify this
proc moveAI {} {
	global gameboard settings gamemode
	if {$gamemode != "ai"} { return }
	set aiMoved 0
	set ok 9
	
	for {set x 1} { $x<=3} { incr x } {
		for {set y 1} { $y<=3} { incr y } {
			if {$gameboard($x,$y) != ""} {
				incr ok -1
			}
		}
	}
	if {!$ok} { puts "Gameboard is full! moveAI" ; return 0 }
	
	while {!$aiMoved} {
		set x [rnd 1 3]
		set y [rnd 1 3]
		puts "AI moving $x $y"
		if {$gameboard($x,$y) == ""} {
			set aiMoved 1
			set gameboard($x,$y) $settings(current)
			.btn$x$y configure -text $settings(current)
			if {[verifyWinner $settings(current)]} { 			puts "AI Won!" }
		}
		incr movesBeforeGivingUp -1
	}
	set settings(current) [expr {$settings(current) == "X" ? "O" : "X"}]
	.lblInfo  configure -text "Player $settings(current)'s turn"
	
}
#Function that takes min and max and generates a random integer number
proc rnd {min max} {
		expr {int(($max - $min + 1) * rand()) + $min}
}

init

puts "GAME MODE $gamemode"
if {0} {
	#Version 4
	Make the game more beautiful
	Adding images and marking the win on the board 
	#BTN FLASH
	

EXERCISES
Making the AI Smarter is an exercise left to you
You will need to rewrite the way we detect wins, this way the AI detects your potential wins and tries to block you
While trying to win himself
	
}

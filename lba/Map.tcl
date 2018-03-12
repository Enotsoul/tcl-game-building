oo::class create Map {
	variable info sock map visitedTiles
	

#TODO multiple maps.. dynamic map loading etc..
	method drawMap {{mapData ""}} {
		if {$mapData == ""} { set mapData [dict get $map map]  }
		append output "[color yellow bold]\[Map\]\n[color white ]You are in [dict get $map name]  at ($info(x),$info(y))\n[color reset]"

		for {set y 1} {$y<=[dict get $map y]} { incr y} {
			for {set x 1} {$x<=[dict get $map x]} { incr x} {
				if {$x == $info(x) && $y == $info(y)} { puts "$x == $info(x) && $y == $info(y)" ; append output [color green bold] }
				if {[info exists visitedTiles($x,$y)]} { append output [string index [lindex $mapData $y-1] $x-1][color reset white] } else { append output [color red bold]?[color reset white] }
			}
			append output "\n"
		}
		append output "[color yellow bold]\[/Map\][color reset]\n"
		puts $sock $output
	}

	#TODO allow multiple maps..
	#TODO specific actions that occur when moving
	#Todo show location information
	method move {location} {
		set x $info(x)
		set y $info(y)
		set maxx [dict get $map x]
		set maxy [dict get $map y]
		switch $location {
			n { incr y -1} 
			e { incr x 1} 
			w { incr x -1} 
			s { incr y 1} 
		}
		if {$x >= 1 && $y >= 1 && $maxx >= $x && $maxy>=$y} {
			#TODO use energy 
		#	useEnergy 1
			set info(x) $x 
			set info(y) $y
			set visitedTiles($x,$y) 1
		#	my drawMap [dict get $map map]
		puts $sock "[color white]You moved to ($x,$y). [color reset]"
		} else { puts $sock "[color magenta]You are at the edge of the town [dict get $map name]. You have nowhere else to go[color reset]" }

	}

	
}

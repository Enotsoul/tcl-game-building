 if {0} {
	STATUS
	0 banned   1 dead  	2 zombie 	3 alive
}
proc levels {} {
	for	{set i 1} {$i<100} {incr i} {
			puts "Variant 1 Level: $i  Experience: [expr 100* ($i**1.5)- (100*$i)] OR  [expr 100* ($i**1.3)] "
			puts "Variant 2 Level: $i  Experience: [expr (8 * ($i ** 3))/10]"
			puts "Variant 3 Level: $i  Experience: [expr round( 0.2 * ($i ** 3) + 0.8 * ($i ** 2) + 100 * $i)]"
	}
}
oo::class create Character {
	mixin Authentication Map Combat
	variable port address sock username info idle map visitedTiles items;#server
	
	constructor  {_sock _address _port } {
		set sock $_sock
		set address $_address
		set port $_port
		#set server $_server
		
		set map {
	map {#=#=#=#=#@@@@
#=#=#=#=#@@@@
#=#=#=#=#@@#@
#=#=#=#=#@@@@
#=#=#=#=#===#
#=#=#=#=#@@@@
#=#=#=#=#@@@@}
	name "Broken Hopes"
	alive 100
	zombies 1
	dead 0
	infected 0
	x 13
	y 7
}
	}
	#TODO caching..?
	method getArguments {method} {
		set classes [self class]
		lappend classes {*}[info class mixins [self class]]
		foreach class $classes {
			if {$method in [info class methods $class]} {
				return [lindex [info class definition $class $method] 0]
			}
		} 
		return ""
	}
	
	method wrongNumArgs {cmd arguments_length {cmd_arguments ""}} {
		if {$cmd_arguments == ""} {
			set cmd_arguments [my getArguments $cmd]
		}
		
		if {[llength $cmd_arguments] > $arguments_length} {
			set sub [regsub -all {(\w*[^ ])} $cmd_arguments {<\1> }]
			puts $sock "[color magenta bold]Correct is syntax:  [color green] $cmd $sub [color reset]"
			return 0
		}
		return 1
	}
	
	method handleCommand {data} {
		set command [lindex $data 0]
		set arguments [lrange $data 1 end]
		#	if {[dict exists $currentMenu [set partial [string trim [lindex $menu 0]]]]} { set isOk 1 ; break}
		if {[string is space $command] || [scan $command %c] == 0} {
			puts "[getTimestamp] KeepAlive $sock"
			return 0
		}
		if {$command ni "connect auth register new"} { 	if {![my verifyAuthenticated]} {	return 0	} }
		if {$command == "reload"} { Server reload }
		if {[dict exists $::commands $command]} { 
			set cmd [dict get $::commands $command]
			if {[llength $cmd]<2} {
				my $cmd $arguments
			} else {		my {*}$cmd			}
		} else {
			puts $sock "That command does not exist. Type [color green]commands[color reset] for a list of commands. Try help <topic> to get help on a desired topic"  
		}
	}
	
	method showHealth {min max {length 25}} {
		set relative [expr {$min/double($max)}]
		if {$relative > 0.75} {
			set color [color bold green]
		} elseif {$relative > 0.50} {
			set color [color bold blue]
		} elseif {$relative > 0.25} {
			set color [color bold yellow]
		} else {
			set color [color red]
		}
		return "$color[progressbar $min $max # $length][color reset]"
	}

	method userStats {cmd} {
		append stats "[color yellow bold]\[Stats\]:\n"
		append stats [color white][string repeat =- 33][color reset]\n

		
		append stats [format "%-20s %s%s %s\n" [string totitle health]: [color green] [my showHealth $info(health) $info(max_health)] "($info(health)/$info(max_health)) [color reset]"]
		append stats [format "%-20s %s%s %s\n" [string totitle Energy]: [color cyan] [progressbar $info(energy) $info(max_energy)] "($info(energy)/$info(max_energy)) [color reset]"]
		
			
		foreach {var} {level money  experience total_experience  attack defence  } {
			append stats [format "%-20s  %s%s%s\n" [string totitle $var]: [color yellow] $info($var) [color reset]]
		}
		
		append stats [color white][string repeat =- 33]\n
		puts $sock $stats
		return 1
	}
	
	method getInfo {var} {
		if {[info exists info($var)]} {
			return $info($var)
		}
		return ""
	}
	
	method setInfo {var data} {
		if {[info exists info($var)]} {
			set info($var) $data
		} 
	}
	method incrInfo {var incr} {
		if {[info exists info($var)]} {
			incr info($var) $incr
		} 
	}
	
	#Increase experience
	#Also leveling up when hitting a specific number
	method incrExperience {incr} {
		incr info(experience) $incr
		incr info(total_experience) $incr
	}
		
	method getSock {} {
		return $sock
	}

	#Send a message to a user
	#TODO in future verify if you have a mobile phone
	method sendPrivateMsg {cmd} {
		if {![my wrongNumArgs msg [llength $cmd] "message"]}  { return 0 }
		lassign $cmd toUser 
		set msg [lrange $cmd 1 end]
		
		puts "send private msg $cmd  toUser $toUser msg $msg"
		set toSock [Server getUserSock $toUser]
		if {$toSock != -1} {
			puts $toSock "[color green]($username):[color reset] $msg"
		} else {
			#TODO save message if user is offline
			puts $sock "This user is currently offline.."
		}
	}
	#TODO channels
	#TODO allow only specific
	method sendMsgToAll {msg} {
		Server sendMsgToAll $username $msg
	}
	
	method getCommandList {msg} {
		set keys [dict keys $::commands]
		foreach {a b c d} {
			puts $sock "$a \t $b \t $c \t $d"
		}
	}
	#Show message if you're at a certain location
	#TODO show everyone
	proc showMsgEventAtYourLocation {npcID message} {
		global settings
		set npcx [getNPC $npcID x]
		set npcy [getNPC $npcID y]
		if {$npcx == $settings(x) && $npcy == $settings(y)} {
			puts $message
		}
	}

	#Cleanup user
	destructor  {
		#TODO before destroying save data changed to database:)
		puts "Destroying Character object [self] "
	}
}


set ::items {
	"First Aid Kit" {	type health  value 5  price 10  }
	"Energizer" { type energy value 10   price 10 }
	
	"Baseball Bat" { type weapon value  2 accuracy 50 price 30 infectionChance 4 }
	Axe { type weapon value 3 accuracy 50 price 70 infectionChance 5 }
	"Kantana" { type weapon value  4 accuracy 60 price 100  infectionChance 7}
	"Bullet" { type ammunition accuracy 50 price 0.2 }
	Gun { type weapon requires Bullet value 5 price 170 infectionChange 13}
	
	"Basic Clothes" { type defence value 2 price 30 }
	"Simple Armour" { type defence value  3 price 70  }
	"Protective Armour" { type defence value  4 price 100  }
	"Zombie Slayer Armour" { type defence value  5 price 170  }
	
	"Canned Food" { type food  value 5 }
	"Water Bottle" { type water value  5 }
	
	"Survival Syringe" { price 50 }
}

oo::class create Items {
	variable items
	
	constructor {_items} {
		#LOad all items from database
	}
	
	method findByName {name} {
		#SQL
		
	}
}
oo::class create UserItems {
	variable inventory 
	
	constructor {} {
		#add items to inventory
	}
	
	method useItem {} {
		
	}
	#Use health stuff
	method heal {} {
		
	}
}


if {0} {
for	{set i 1} {$i<1000} {incr i} {
	set socket [socket localhost 7733]
	
	fconfigure $socket -buffering line -blocking 0 -encoding utf-8
	puts $socket "connect [rnd 1 1000000] [rnd 1 1000000]"
	if {[rnd 1 7] == 3} {
		lappend socket_list $socket
	
	} else {
		after [rnd 1500 7000] close $socket
	}
	
}
 proc rnd {min max} {
	expr {int(($max - $min + 1) * rand()) + $min}
}
 
proc doSomething {} {
	foreach sock $::socket_list {
		puts $sock "connect some_random D4t4"
		close $sock
	}
}

}

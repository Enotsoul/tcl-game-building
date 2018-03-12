oo::class create Combat {
	variable sock info
	
	method verifyLocation {user} {
	#	set user [Server getUserObject $_username]
		if {[$user getInfo x] == $info(x)  && [$user getInfo x] == $info(y)} { return 1 }
		return 0
	}
	
	#TODO handle NPC aswell as normal users
	#TODO calculate exp
	#TODO decrease energy
	
	method attack {defender_username} {
		set defender [Server getUserObject $defender_username]
	
		if {$defender  == [self]} { puts $sock "You can't attack yourself.." ; return 0 }
		if {$defender == -1} {
			puts $sock "[color red]$defender_username is not online. At the moment you can ONLY attack online users[color reset]"
			return 0
		}
		if {![my verifyLocation $defender]} {
			puts $sock  "[color red]$defender_username is not at the same location as you are[color reset]"
			return 0
		}
		my doAttack [self] $defender
	}
	
	method doAttack {attacker defender} {
		#if {$attackerID == "" || $defenderID == ""} { report warning "NPCATTACKNPC att $attackerID defid $defenderID" ; return }
		set attacker_dmg [my calculateUserDamage $attacker]
		set defender_damage [my calculateUserDamage $defender]
		
		set attacker_def [my calculateUserDefence $attacker]
		set defender_def [my calculateUserDefence $defender]
		
		set defender_final_damage [expr {$defender_def-$attacker_dmg}]
		set attacker_final_damage [expr {$attacker_def-$defender_damage}]

		if {[my attackDoDamage $attacker $defender $defender_final_damage]} {
			my attackDoDamage $defender $attacker  $attacker_final_damage
		}
	}
	
	#later make it more advanced.. add weapons and stuff
	method attackDoDamage {attacker defender hp} {

		#if hp > 0 then "missed hit"
		# If HP = 0 it can still be a infectious bite!
		if {$hp >= 0} {
set msg "[color green bold][$defender getInfo username][color reset white] missed a hit at [color bold purple][$attacker getInfo username][color reset red]  $hp damage."
			Server sendMsgToAll Combat [::report notice $msg]
			 return 1
		 }
		$defender incrInfo  health $hp
	
		# showMsgEventAtYourLocation $defenderID 
		Server sendMsgToAll Combat [::report notice "[color green bold][$defender getInfo username][color reset blue] has been hit by [color bold purple][$attacker getInfo username][color reset red] for $hp damage."]
		if {[my verifyAlive $defender]} {
		#	NPCInfectNPC $attackerID $defenderID
			return 1
		} else {
			#showMsgEventAtYourLocation $defenderID
			Server sendMsgToAll Combat  [::report warning "[color green bold][$defender getInfo username][color reset blue] has been killed by [color bold purple][$attacker getInfo username]"]
			return 0
		}
	}
	
	method verifyAlive {user} {
		set status [$user getInfo status]
		if {$status == "Dead" || [$user getInfo health] <= 0} {
			return 0
		}
		return 1
	}
		
	
	
	method calculateUserDefence {user} {
		set defence  [$user getInfo defence]
		set coef [expr {$defence/2}]
		set min [expr {$defence-$coef}]
		return [rnd $min $defence]
	}
		#Random between attack +/-attack/3
	method calculateUserDamage {user} {
		set attack  [$user getInfo attack]
		set coef [expr {$attack/3}]
		set min [expr {$attack-$coef}]
		set max [expr {$attack+$coef}]
		return [rnd $min $max]
	}
	
	
	#Maybe sometime create a universal calculator...
	method calculateUserSetting {variable divider} {
		global settings
		set usersetting  $settings($variable)
		set coef [expr {$usersetting/$divider}]
		set min [expr {$usersetting-$coef}]
		set max [expr {$usersetting+$coef}]
		return [rnd $min $max]
	}


}



proc NPCInfectNPC {attackerID defenderID} {
	global map
	if {[getNPC $attackerID status] == "Zombie" && [getNPC $defenderID status] != "Zombie"} {
		if {[rnd 1 3] != 3} { 
			setNPC $defenderID status Infected
			dict incr map infected 1
			showMsgEventAtYourLocation $defenderID [report warning "[color red][getNPCName $defenderID][color reset] has been infected by a Zombie"]
		}
	}
}



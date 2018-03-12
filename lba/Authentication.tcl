
oo::class create Authentication {
	
	variable sock username info idle visitedTiles  address
	


	method auth {msg} {
		puts "auth args $msg"
		set errors ""
		lassign $msg username password

		#View if email exists and if password is correct
		array set Client [list username "" password ""]
		DB eval {SELECT * FROM users WHERE  username=$username} Client {}
		if {![string match -nocase $Client(username) $username]} {
			puts $sock "No such username exists, consider registering it."
			lappend errors "AUTH INEXISTENT"
		}

		if {![string match [::sha1::sha1 -hex $password] $Client(password)]} {
			#TODO block user for 10 minutes after 5 failed attempts
			puts $sock "Wrong password for $username"
			lappend errors "AUTH WRONGPASSWORD"
		}

		if {[string length $errors] == 0} {
			set username $Client(username)
			#set info [dict create {*}[array get Client]]
			array set info [array get Client]
					
			#Specific things at higher status
			if {$Client(status) == 3} {
				
			}
			set visitedTiles($info(x),$info(y)) 1
	
			#Fist we disconnect other sessions and then we update the current user to the socket
			Server disconnectLoggedInAgain $username
			Server updateUserToSock $username $sock 
			
			#Control if level 0 (banned/inactive), disallow

			if {$Client(last_login_ip) !=""} {
				puts $sock "[color yellow bold]Last online from $Client(last_login_ip) at $Client(last_auth_at)"
			}
		puts $sock "\n[color yellow bold]Welcome back to LifeBeyondApocalypse $Client(username). 
Updates/messages since you where last here: none[color reset]"
			set timestamp [getTimestamp]
			#TODO press return to continue..
			DB eval {UPDATE users SET last_auth_at=:timestamp, last_login_ip=:address}
		}

		puts "[getTimestamp]: AUTH from $sock user $username  $errors"
		
	}
	
	method register {msg} {
		set errors ""
		lassign $msg username password email
		if {[llength $msg]<3} {
			puts $sock "Not enough parameters, should be [color green]NEW <username> <password> <email>"
			return 0
		}
		
		#[minLength $username] && [minLength $password] && [minLength $email]
		
		#View if email exists and if password is correct
		array set Client [list username "" ]
		DB eval {SELECT * FROM users WHERE username=$username} Client {}
		puts "Client [array get Client]"
		if {[string match -nocase $Client(username) $username]} {
			puts $sock "User already exists, consider logging in [color green]\[c\]onnect <username> <password>[color reset] "
			lappend errors "REGISTER already exists"
		}


		if {[string length $errors] == 0} {
			set password [::sha1::sha1 -hex $password] 
			set date [getTimestamp]
			DB eval {INSERT INTO users (username,email,password,registered_at,last_auth_at,register_ip) 
				VALUES (:username,:email,:password,:date,:date,:address)}
			DB eval {SELECT * FROM users WHERE username=$username} Client {}
			#set info [dict create {*}[array get Client]]
			array set info [array get Client]
	
			#Start tutorial & send appropiate info
			puts $sock "REGISTER OK Welcome $Client(username)"
			puts "[getTimestamp]: New user ($username) registered from $sock email $email  $errors"
		}


		
	}
	
	
	method verifyAuthenticated {} {
		if {[info exists username]} {
			return  1
		} else { 
			puts $sock "You should authenticate before doing anything else.	Available commands:
[color green]\[c\]onnect <username> ?<password>?[color reset] - to connect.
[color green]NEW <username> ?<password>? ?<email>?[color reset] - create a new character"
			return  0
		}
	}
	
	#forward whoIsOnline Server whoIsOnline [list self getSock]
	method whoIsOnline {args} {
		Server whoIsOnline $sock
	}
	method test {andrei super tar} {
		
	}
	
	#TODO idle processing
}

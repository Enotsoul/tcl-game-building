CREATE TABLE users (
			id  INTEGER PRIMARY KEY,
			username TEXT COLLATE NOCASE,
			email TEXT COLLATE NOCASE,
			password TEXT,
			
			level INTEGER DEFAULT 1,
			experience INTEGER default 0,
			total_experience INTEGER default 0,
			energy INTEGER default 100,
			max_energy INTEGER default 100,
			health INTEGER default 50,
			max_health INTEGER default 50,
			
			infected INTEGER DEFAULT 0,	
			status INTEGER DEFAULT 1,
			money INTEGER DEFAULT 20,
			goldcoins INTEGER DEFAULT 1,
			
			defence INTEGER default 5,
			attack INTEGER default 5,
			encumbrance INTEGER default 0,
			total_encumbrance INTEGER default 50000,
			
			pickpoints INTEGER DEFAULT 0,
			hth_accuracy INTEGER DEFAULT 40,
			blunt_accuracy INTEGER DEFAULT 40,
			blade_accuracy INTEGER DEFAULT 40,
			firearm_accuracy INTEGER DEFAULT 30,
		
			admin_level INTEGER default 0,
			
			map_id INTEGER DEFAULT 1,
			x INTEGER DEFAULT 1,
			y INTEGER DEFAULT 1,
			
		
			last_auth_at DATETIME,
			registered_at DATETIME,
			register_ip TEXT,
			last_login_ip  TEXT,
			time_spent INTEGER

		);
		CREATE TABLE user_statistics (
			user_id INTEGER REFERENCES users ( id ),
			kills INTEGER DEFAULT 0,
			zombie_kills INTEGER DEFAULT 0,
			npc_kills INTEGER DEFAULT 0,
			human_kills INTEGER DEFAULT 0,
			energy_used INTEGER DEFAULT 0,
			bullets_used INTEGER DEFAULT 0,
			revives INTEGER DEFAULT 0
		);
		

		CREATE TABLE items (
			id  INTEGER PRIMARY KEY,
			name TEXT COLLATE NOCASE,
			encumbrance INTEGER DEFAULT 1,
			price INTEGER DEFAULT 1,
			goldcoins INTEGER DEFAULT 1,
			type TEXT COLLATE NOCASE,
			min_value INTEGER,
			value INTEGER,
			max_value INTEGER,
			accuracy INTEGER,
			stackable INTEGER DEFAULT 1,
			search_chance INTEGER DEFAULT 1,
			
		);
		 
CREATE TABLE user_items (
	user_id INTEGER REFERENCES users ( id ),
	item_id INTEGER REFERENCES items ( id ),
	count INTEGER DEFAULT 1,
	damage INTEGER DEFAULT 0,
);
CREATE TABLE maps (
	id  INTEGER PRIMARY KEY,
	name TEXT COLLATE NOCASE,
	description TEXT,

);
--- Safe zone means zombies can never enter
CREATE TABLE map_info (
	map_id  REFERENCES maps ( id ),
	name TEXT COLLATE NOCASE,
	description TEXT,
	x INTEGER,
	y INTEGER,
	safe_zone INTEGER DEFAULT 0,
);

	-- status friend zombie hostile 
CREATE TABLE npc (
	id  INTEGER PRIMARY KEY,
	name TEXT COLLATE NOCASE,
	map_id INTEGER,
	x INTEGER,
	y INTEGER,
	health INTEGER,
	max_health INTEGER,
	attack INTEGER,
	defence INTEGER,
	energy INTEGER,
	status TEXT  COLLATE NOCASE,
	
	barter INTEGER DEFAULT 0,
	healing INTEGER DEFAULT 0,
	
);



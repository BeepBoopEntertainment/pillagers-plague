extends Node


var tower_data = {
	"Ballistae1": {
		"damage": 1,
		"rof": .5,
		"range": 500,
		"cost": 2,
		"ammo": "Arrow",
		"effect": ""
		},
	"Catapult1": {
		"damage": 2,
		"rof": 1,
		"range": 800,
		"cost": 5,
		"ammo": "Fireball",
		"effect": ""
	},
		"IceTower1": {
		"damage": 1,
		"rof": 1.5,
		"range": 400,
		"cost": 5,
		"ammo": "IceShard",
		"effect": "Frozen"
	}
}

var status_data = {
	"Frozen": {
		"duration": 0.7
	}
}

var hp: int = 5
var gold: int = 5
var current_level: int = 1

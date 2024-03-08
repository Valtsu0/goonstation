/datum/faith_reaction
	var/ingredient = null
	var/result = null
	var/amount = 1 // of result chemical per unit of ingredient chemical
	var/cost = 0 // of faith per unit of ingredient chemical

	wine
		ingredient = "water"
		result = "wine"
		cost = 5

	mercury
		ingredient = "silver"
		result = "mercury"
		cost = 10

	silver
		ingredient = "paper" // doesn't really make sense but it allows making holy water with easily accessible things
		result = "silver"
		cost = 20

	holy_spirit
		ingredient = "vodka"
		result = "holy_spirit"
		cost = 20

	ichor
		ingredient = "blood"
		result = "ichor"
		cost = 50

	ectoplasm
		ingredient = "plasma"
		result = "ectoplasm"
		cost = 50


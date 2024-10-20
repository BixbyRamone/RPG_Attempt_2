extends Stats
class_name BountyHunterStats

const name: String = "BountyHunter"
const move: int = 9
const skin: Texture2D = preload("res://Assets/Characters/bountyhunter.png")
const skin_hframes: int = 3
const status_reduction: int = 4
const ability_up: Texture2D = preload("res://Assets/UI/AbilityButtons/cleric_up.png")
const ability_down: Texture2D = preload("res://Assets/UI/AbilityButtons/cleric_down.png")
const effect_color: int = 6

var owner: String = "Player"
var status: String = status_array[1]

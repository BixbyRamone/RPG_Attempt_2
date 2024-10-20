extends Stats
class_name ThiefStats

const name: String = "Thief"
const move: int = 5
const skin: Texture2D = preload("res://Assets/Characters/thief.png")
const skin_hframes: int = 3
const status_reduction: int = 3
const ability_up: Texture2D = preload("res://Assets/UI/AbilityButtons/cleric_up.png")
const ability_down: Texture2D = preload("res://Assets/UI/AbilityButtons/cleric_down.png")
const effect_color: int = 8

var owner: String = "Player"
var status: String = status_array[1]

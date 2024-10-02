extends Stats
class_name RangerStats

const name: String = "Ranger"
const move: int = 6
const skin: Texture2D = preload("res://Assets/Characters/ranger.png")
const skin_hframes: int = 3
const status_reduction: int = 2
const ability_up: Texture2D = preload("res://Assets/UI/AbilityButtons/ranger_up.png")
const ability_down: Texture2D = preload("res://Assets/UI/AbilityButtons/ranger_down.png")
const effect_color: int = 1

var owner: String = "Player"
var status: String = status_array[1]

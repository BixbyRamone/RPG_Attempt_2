extends Stats
class_name ClericStats

const name: String = "Cleric"
const move: int = 3
const skin: Texture2D = preload("res://Assets/Characters/cleric.png")
const skin_hframes: int = 3
const status_reduction: int = 2
const ability_up: Texture2D = preload("res://Assets/UI/AbilityButtons/cleric_up.png")
const ability_down: Texture2D = preload("res://Assets/UI/AbilityButtons/cleric_down.png")
const effect_color: int = 2

var owner: String = "Player"
var status: String = status_array[1]


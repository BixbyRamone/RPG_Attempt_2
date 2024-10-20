extends Stats
class_name AssassinStats

const name: String = "Assassin"
const move: int = 7
const skin: Texture2D = preload("res://Assets/Characters/assassin.png")
const skin_hframes: int = 3
const status_reduction: int = 2
const ability_up: Texture2D = preload("res://Assets/UI/AbilityButtons/cleric_up.png")
const ability_down: Texture2D = preload("res://Assets/UI/AbilityButtons/cleric_down.png")
const effect_color: int = 9

var owner: String = "Player"
var status: String = status_array[1]

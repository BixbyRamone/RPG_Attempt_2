extends Stats
class_name PriestStats

const name: String = "Priest"
const move: int = 4
const skin: Texture2D = preload("res://Assets/Characters/priest.png")
const skin_hframes: int = 3
const owner: String = "Player"
const status_reduction: int = 2
const ability_up: Texture2D = preload("res://Assets/UI/AbilityButtons/priest_up.png")
const ability_down: Texture2D = preload("res://Assets/UI/AbilityButtons/priest_down.png")
const status: String = status_array[1]

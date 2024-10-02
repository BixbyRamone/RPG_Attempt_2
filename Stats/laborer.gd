extends Stats
class_name LaborerStats

const name: String = "Laboror"
const move: int = 3
const skin: Texture2D = preload("res://Assets/Characters/laborer.png")
const skin_hframes: int = 5
const status_reduction: int = 1
const effect_color: int = 4

var owner: String = "NPC"
var status: String = status_array[1]

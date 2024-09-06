extends Stats
class_name RangerStats

const name: String = "Ranger"
const move: int = 6
const skin: Texture2D = preload("res://Assets/Characters/ranger.png")
const skin_hframes: int = 3
const status_reduction: int = 2

var owner: String = "Player"
var status: String = status_array[1]

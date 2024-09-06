extends Stats
class_name SoldierStats

const name: String = "Soldier"
const move: int = 3
const skin: Texture2D = preload("res://Assets/Characters/soldier.png")
const skin_hframes: int = 3
const status_reduction: int = 2

var owner: String = "Player"
var status: String = status_array[1]

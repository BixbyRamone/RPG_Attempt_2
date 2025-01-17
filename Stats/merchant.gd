extends Stats
class_name MerchantStats

const name: String = "Merchant"
const move: int = 7
const skin: Texture2D = preload("res://Assets/Characters/merchant.png")
const skin_hframes: int = 3
const status_reduction: int = 2
const ability_up: Texture2D = preload("res://Assets/UI/AbilityButtons/cleric_up.png")
const ability_down: Texture2D = preload("res://Assets/UI/AbilityButtons/cleric_down.png")
const effect_color: int = 7

var owner: String = "Player"
var status: String = status_array[1]

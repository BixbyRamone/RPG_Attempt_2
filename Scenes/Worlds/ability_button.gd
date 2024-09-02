extends TextureButton
class_name AbilityButton

func button_active(unit_stats: Resource, bul: bool) -> void:
	if bul:
		texture_normal = unit_stats.ability_up
		texture_pressed = unit_stats.ability_down
	visible = bul
	disabled = !bul

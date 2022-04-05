extends Popup

var paused setget set_paused

func _unhandled_input(event):
	if event.is_action_pressed('pause'):
		self.paused = !paused
		
func set_paused(value):
	paused = value
	get_tree().paused = paused
	if paused:
		self.popup_centered()
	else:
		self.visible = false

func _on_Continue_pressed():
	self.paused = false

func _on_Restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_Exit_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Menu/MainMenu.tscn")

extends Control

var Digsideers  := 0
var Digdowners  := 0
var Stopperers  := 0
var Umbrellaers  := 0
var Stairers := 0
var Climbers := 0

func _ready():
	pass # Replace with function body.

func _on_digSide_minus_pressed():
	if Digsideers >=1: 
		Digsideers -= 1
		$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer/VBoxContainer2/Label.text = str(Digsideers)

func _on_digSide_plus_pressed():	
	Digsideers += 1
	$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer/VBoxContainer2/Label.text = str(Digsideers)

func _on_digDown_minus_pressed():
	if Digdowners >=1: 
		Digdowners -= 1
		$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer/VBoxContainer3/Label.text = str(Digdowners)

func _on_digDown_plus_pressed():
	Digdowners += 1
	$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer/VBoxContainer3/Label.text = str(Digdowners)

func _on_stopper_minus_pressed():
	if Stopperers >= 1:
		Stopperers -=1
		$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer2/VBoxContainer/Label.text = str(Stopperers)

func _on_stopper_plus_pressed():
	Stopperers += 1
	$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer2/VBoxContainer/Label.text = str(Stopperers)

func _on_umbrella_minus_pressed():
	if Umbrellaers >= 1:
		Umbrellaers -= 1
		$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer2/VBoxContainer2/Label.text = str(Umbrellaers)

func _on_umbrella_plus_pressed():
	Umbrellaers += 1
	$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer2/VBoxContainer2/Label.text = str(Umbrellaers)

func _on_stair_minus_pressed():
	if Stairers >= 1:
		Stairers -= 1
		$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer3/VBoxContainer/Label.text = str(Stairers)

func _on_stair_plus_pressed():
	Stairers += 1
	$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer3/VBoxContainer/Label.text = str(Stairers)

func _on_climber_minus_pressed():
	if Climbers >= 1:
		Climbers -= 1
		$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer3/VBoxContainer2/Label.text = str(Climbers)
		
func _on_climber_plus_pressed():
	Climbers += 1
	$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer3/VBoxContainer2/Label.text = str(Climbers)

func _on_Try_pressed():
	get_tree().get_current_scene().try_level()
	
func _on_Save_pressed():
	get_tree().get_current_scene().save_level()

func _on_Control_mouse_entered():
	Global.on_panel = true

func _on_Control_mouse_exited():
	Global.on_panel = false

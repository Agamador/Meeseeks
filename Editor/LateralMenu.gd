extends Control


func _ready():
	pass

func start_values():
	$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer/VBoxContainer2/Label.text = str(get_parent().get_parent().get_parent().Digsideers)
	$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer/VBoxContainer3/Label.text = str(get_parent().get_parent().get_parent().Digdowners)
	$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer2/VBoxContainer/Label.text = str(get_parent().get_parent().get_parent().Stopperers)
	$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer3/VBoxContainer/Label.text = str(get_parent().get_parent().get_parent().Stairers)
	$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer3/VBoxContainer2/Label.text = str(get_parent().get_parent().get_parent().Climbers)
	$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer2/VBoxContainer2/Label.text = str(get_parent().get_parent().get_parent().Umbrellaers)
	$Panel/MarginContainer/VBoxContainer/VBoxContainer/Panel/HBoxContainer/vidas.text = str(get_parent().get_parent().get_parent().Lives)


func _on_digSide_minus_pressed():
	if get_parent().get_parent().get_parent().Digsideers >=1: 
		get_parent().get_parent().get_parent().Digsideers -= 1
		$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer/VBoxContainer2/Label.text = str(get_parent().get_parent().get_parent().Digsideers)

func _on_digSide_plus_pressed():	
	get_parent().get_parent().get_parent().Digsideers += 1
	$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer/VBoxContainer2/Label.text = str(get_parent().get_parent().get_parent().Digsideers)

func _on_digDown_minus_pressed():
	if get_parent().get_parent().get_parent().Digdowners >=1: 
		get_parent().get_parent().get_parent().Digdowners -= 1
		$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer/VBoxContainer3/Label.text = str(get_parent().get_parent().get_parent().Digdowners)

func _on_digDown_plus_pressed():
	get_parent().get_parent().get_parent().Digdowners += 1
	$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer/VBoxContainer3/Label.text = str(get_parent().get_parent().get_parent().Digdowners)

func _on_stopper_minus_pressed():
	if get_parent().get_parent().get_parent().Stopperers >= 1:
		get_parent().get_parent().get_parent().Stopperers -=1
		$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer2/VBoxContainer/Label.text = str(get_parent().get_parent().get_parent().Stopperers)

func _on_stopper_plus_pressed():
	get_parent().get_parent().get_parent().Stopperers += 1
	$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer2/VBoxContainer/Label.text = str(get_parent().get_parent().get_parent().Stopperers)

func _on_umbrella_minus_pressed():
	if get_parent().get_parent().get_parent().Umbrellaers >= 1:
		get_parent().get_parent().get_parent().Umbrellaers -= 1
		$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer2/VBoxContainer2/Label.text = str(get_parent().get_parent().get_parent().Umbrellaers)

func _on_umbrella_plus_pressed():
	get_parent().get_parent().get_parent().Umbrellaers += 1
	$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer2/VBoxContainer2/Label.text = str(get_parent().get_parent().get_parent().Umbrellaers)

func _on_stair_minus_pressed():
	if get_parent().get_parent().get_parent().Stairers >= 1:
		get_parent().get_parent().get_parent().Stairers -= 1
		$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer3/VBoxContainer/Label.text = str(get_parent().get_parent().get_parent().Stairers)

func _on_stair_plus_pressed():
	get_parent().get_parent().get_parent().Stairers += 1
	$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer3/VBoxContainer/Label.text = str(get_parent().get_parent().get_parent().Stairers)

func _on_climber_minus_pressed():
	if get_parent().get_parent().get_parent().Climbers >= 1:
		get_parent().get_parent().get_parent().Climbers -= 1
		$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer3/VBoxContainer2/Label.text = str(get_parent().get_parent().get_parent().Climbers)
		
func _on_climber_plus_pressed():
	get_parent().get_parent().get_parent().Climbers += 1
	$Panel/MarginContainer/VBoxContainer/TabContainer/Habilidades/VBoxContainer/HBoxContainer3/VBoxContainer2/Label.text = str(get_parent().get_parent().get_parent().Climbers)

func _on_Try_pressed():
	get_tree().get_current_scene().try_level()
	
func _on_Control_mouse_entered():
	Global.on_panel = true

func _on_Control_mouse_exited():
	Global.on_panel = false


func _on_minus_lives_pressed():
	if get_parent().get_parent().get_parent().Lives >= 2:
		get_parent().get_parent().get_parent().Lives -= 1
		$Panel/MarginContainer/VBoxContainer/VBoxContainer/Panel/HBoxContainer/vidas.text = str(get_parent().get_parent().get_parent().Lives)

func _on_plus_lives_pressed():
		get_parent().get_parent().get_parent().Lives += 1
		$Panel/MarginContainer/VBoxContainer/VBoxContainer/Panel/HBoxContainer/vidas.text = str(get_parent().get_parent().get_parent().Lives)

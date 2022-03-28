extends Node2D


var base_level = preload("res://Levels/Scenes/LevelBase.tscn").instance()
var celda
var mapa 
var goal
var spawn
var mouse_pos
var Digsideers  := 0
var Digdowners  := 0
var Stopperers  := 0
var Umbrellaers  := 0
var Stairers := 0
var Climbers := 0
var Lives := 1
# Called when the node enters the scene tree for the first time.
func _ready():
	mapa = get_node("TileMap")
	goal = get_node("Goal")
	spawn = get_node("Spawn")
	$Spawn.visible = false
	$Goal.visible = false
	load_map()
	mapa.visible = true
	$Camera2D/CanvasLayer/Control/Panel/MarginContainer/VBoxContainer/VBoxContainer/Try.disabled = true

	$Camera2D/CanvasLayer/Popup/Panel/Yes.connect("pressed",self,'_on_YesButton_pressed')
	$Camera2D/CanvasLayer/Popup/Panel/No.connect("pressed",self,'_on_NoButton_pressed')

	
func _process(delta):
	if $Spawn.visible == true and $Goal.visible == true and check_values():
		$Camera2D/CanvasLayer/Control/Panel/MarginContainer/VBoxContainer/VBoxContainer/Try.disabled = false
	else:
		$Camera2D/CanvasLayer/Control/Panel/MarginContainer/VBoxContainer/VBoxContainer/Try.disabled = true
	
func check_values():
	return Digsideers + Digdowners + Stopperers + Umbrellaers + Stairers + Climbers > 0
	
func _unhandled_input(event):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and !Global.on_panel:
		if Global.tile_mouse != '':
			if Global.tile_mouse != 'Spawn' and Global.tile_mouse != 'Goal':
				place_tile()
			elif Global.tile_mouse == 'Spawn':
				place_spawn()
			elif Global.tile_mouse == 'Goal':
				place_goal()
	if Input.is_mouse_button_pressed(BUTTON_RIGHT):
		remove_spawn()
		remove_goal()
		remove_tile()

func place_tile():
	celda = mapa.world_to_map(get_global_mouse_position())
	mapa.set_cellv(celda, int(Global.tile_mouse))
	
func place_spawn():
	base_level.get_node("Spawn").position = get_global_mouse_position()
	$Spawn.position = get_global_mouse_position()
	$Spawn.visible = true
	
func place_goal():
	base_level.get_node('Goal').position = get_global_mouse_position()
	$Goal.position = get_global_mouse_position()
	$Goal.visible = true
	
func remove_tile():
	celda = mapa.world_to_map(get_global_mouse_position())
	mapa.set_cellv(celda, -1)

func remove_spawn():
	mouse_pos = get_global_mouse_position()
	if mouse_pos.x > $Spawn.position.x - 32 and mouse_pos.x < $Spawn.position.x + 32 and mouse_pos.y > $Spawn.position.y -32 and mouse_pos.y < $Spawn.position.y + 32:
		$Spawn.position = Vector2(0,0)
		$Spawn.visible = false

func remove_goal():
	mouse_pos = get_global_mouse_position()
	if mouse_pos.x > $Goal.position.x - 32 and mouse_pos.x < $Goal.position.x + 32 and mouse_pos.y > $Goal.position.y -32 and mouse_pos.y < $Spawn.position.y + 32:
		$Goal.position = Vector2(0,0)
		$Goal.visible = false

func try_level():
	update_skills()
	var to_save = PackedScene.new()
	var new_map = mapa.duplicate()
	new_map.name = "TileMap"
	if new_map.get_parent():
		new_map.get_parent().remove_child(new_map)
	base_level.add_child(new_map)
	base_level.get_node('TileMap').set_owner(base_level)
	to_save.pack(base_level)
	save_map()
	Global.editing = true
	ResourceSaver.save("res://Levels/Scenes/prueba.tscn" ,to_save)
	Global.prev_escene = "res://Editor/Editor.tscn" 
	get_tree().change_scene("res://Levels/Scenes/prueba.tscn")

func save_map():
	var file = File.new()
	file.open(Global.map_path,File.WRITE)
	file.store_string(var2str(mapa))
	file.close()
	file.open(Global.goal_path, File.WRITE)
	file.store_string(var2str($Goal))
	file.close()
	file.open(Global.spawn_path, File.WRITE)
	file.store_string(var2str($Spawn))
	file.close()
	var skills = {
		"Digsideers": Digsideers,
		"Digdowners": Digdowners,
		"Stopperers": Stopperers,
		"Umbrellaers": Umbrellaers,
		"Stairers": Stairers,
		"Climbers": Climbers,
		"Lives": Lives
	}
	file.open(Global.skills_path, File.WRITE)
	file.store_line(to_json(skills))
	file.close()
	
func load_map():
	var file = File.new()
	if file.file_exists(Global.map_path):
		file.open(Global.map_path,File.READ)
		var map_text = file.get_as_text()
		file.close()
		mapa = str2var(map_text)
		self.add_child(mapa)
	if file.file_exists(Global.goal_path):
		file.open(Global.goal_path, File.READ)
		var goal_text = file.get_as_text()
		file.close()
		goal = str2var(goal_text)
		$Goal.position = goal.position
		base_level.get_node('Goal').position = goal.position
		$Goal.visible = true
	if file.file_exists(Global.spawn_path):
		file.open(Global.spawn_path,File.READ)
		var spawn_text = file.get_as_text()
		file.close()
		spawn = str2var(spawn_text)
		base_level.get_node('Spawn').position = spawn.position
		$Spawn.position = spawn.position
		$Spawn.visible = true
	if file.file_exists(Global.skills_path):
		file.open(Global.skills_path,File.READ)
		var skills_text = parse_json(file.get_as_text())
		file.close()
		Digsideers = skills_text['Digsideers'] 
		Digdowners = skills_text['Digdowners']
		Stopperers = skills_text['Stopperers']
		Umbrellaers = skills_text['Umbrellaers']
		Stairers = skills_text['Stairers']
		Climbers = skills_text['Climbers']
		Lives = skills_text['Lives']
		$Camera2D/CanvasLayer/Control.start_values()

func update_skills():
	Global.Digsideers = Digsideers
	Global.Digdowners = Digdowners
	Global.Umbrellaers = Umbrellaers
	Global.Stairers = Stairers
	Global.Stopperers = Stopperers
	Global.lives = Lives
	
func _on_BackButton_pressed():
	$Camera2D/CanvasLayer/Popup.popup_centered()
	
func _on_YesButton_pressed():
	get_tree().change_scene("res://Menu/MainMenu.tscn")

func _on_NoButton_pressed():
	$Camera2D/CanvasLayer/Popup.visible = false

extends Node2D


var base_level = preload("res://Levels/Scenes/LevelBase.tscn").instance()
var celda
var mapa 
var mouse_pos
# Called when the node enters the scene tree for the first time.
func _ready():
	mapa = get_node("TileMap")
	mapa.visible = true
	$Camera2D/CanvasLayer/Control/Panel/MarginContainer/VBoxContainer/VBoxContainer/Save.disabled = true
	$Camera2D/CanvasLayer/Control/Panel/MarginContainer/VBoxContainer/VBoxContainer/Try.disabled = true
	$Spawn.visible = false
	$Goal.visible = false

func _process(delta):
	if $Spawn.visible == true and $Goal.visible == true:
		$Camera2D/CanvasLayer/Control/Panel/MarginContainer/VBoxContainer/VBoxContainer/Save.disabled = false
		$Camera2D/CanvasLayer/Control/Panel/MarginContainer/VBoxContainer/VBoxContainer/Try.disabled = false
	else:
		$Camera2D/CanvasLayer/Control/Panel/MarginContainer/VBoxContainer/VBoxContainer/Save.disabled = true
		$Camera2D/CanvasLayer/Control/Panel/MarginContainer/VBoxContainer/VBoxContainer/Try.disabled = true
	pass
	
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
		
func save_level():
	var to_save = PackedScene.new()
	var new_map = mapa.duplicate()
	if new_map.get_parent():
		new_map.get_parent().remove_child(new_map)
	base_level.add_child(new_map)
	base_level.get_node('TileMap').set_owner(base_level)
	to_save.pack(base_level)
	var level_str = var2str(to_save)
	var lvl_scene = str2var(level_str)
	var scene = lvl_scene.instance()
	get_tree().change_scene(scene)
	ResourceSaver.save("res://Levels/Scenes/prueba.tscn" ,to_save)

func try_level():
	get_tree().change_scene('')


func _on_BackButton_pressed():
	get_tree().change_scene("res://Menu/MainMenu.tscn")

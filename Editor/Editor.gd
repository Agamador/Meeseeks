extends Node2D

#Precarga el nodo base para un nuevo nivel.
var base_level = preload("res://Levels/Scenes/LevelBase.tscn").instance()
# Vector2 que indica la posición de una celda del mapa.
var celda
# Nodo que contiene el mapa para el nivel.
var mapa 
# Nodo que contiene la meta del nivel.
var goal
# Nodo que contiene la base del nivel.
var spawn
# Vector2 con la posición del ratón en pantalla.
var mouse_pos
# Numero de meeseeks disponibles para excavar horizontalmente en el nivel.
var Digsideers  := 0
# Numero de meeseeks disponibles para excavar verticalmente en el nivel.
var Digdowners  := 0
# Numero de meeseeks disponibles para parar a los demás meeseeks en el nivel.
var Stopperers  := 0
# Numero de meeseeks disponibles para usar el paraguas en el nivel.
var Umbrellaers  := 0
# Numero de meeseeks disponibles para crear escaleras en el nivel.
var Stairers := 0
# Numero de meeseeks disponibles para escalar paredes en el nivel.
var Climbers := 0
# Numero de meeseeks disponibles en el nivel.
var Lives := 1
# Numero máximo de celdas que puede tener un nivel. Utilizado para impedir que un nivel desborde el campo reservado en la base de datos.
var max_cells := 10000

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

# Comprueba que se haya añadido al menos una habilidad al nivel.
func check_values():
	return Digsideers + Digdowners + Stopperers + Umbrellaers + Stairers + Climbers > 0
	
func _unhandled_input(event):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and !Global.on_panel:
		if Global.tile_mouse != '':
			if Global.tile_mouse != 'Spawn' and Global.tile_mouse != 'Goal':
				if mapa.get_used_cells().size() < max_cells:
					place_tile()
					max_tiles_warning(false)
				else: 
					max_tiles_warning(true)
			elif Global.tile_mouse == 'Spawn':
				place_spawn()
			elif Global.tile_mouse == 'Goal':
				place_goal()
	if Input.is_mouse_button_pressed(BUTTON_RIGHT):
		remove_spawn()
		remove_goal()
		remove_tile()

# Obtiene la posición x e y de una celda a partir de la posición del ratón en la pantalla, y coloca la casilla seleccionada en la variable global tile_mouse en la celda.
func place_tile():
	celda = mapa.world_to_map(get_global_mouse_position())
	if celda.x >= 0 and celda.y >= 0: 
		mapa.set_cellv(celda, int(Global.tile_mouse))
		update_placed_cells()

# Hace visible la base del nivel y mueve esta a la posición del ratón.
func place_spawn():
	base_level.get_node("Spawn").position = get_global_mouse_position()
	$Spawn.position = get_global_mouse_position()
	$Spawn.visible = true

# Hace visible la meta del nivel y mueve esta a la posición del ratón.
func place_goal():
	base_level.get_node('Goal').position = get_global_mouse_position()
	$Goal.position = get_global_mouse_position()
	$Goal.visible = true
	
# Obtiene la posición x e y de una celda a partir de la posición del ratón en la pantalla, y elimina la casilla que ésta contenga.
func remove_tile():
	celda = mapa.world_to_map(get_global_mouse_position())
	mapa.set_cellv(celda, -1)
	update_placed_cells()
	if mapa.get_used_cells().size() < max_cells:
		max_tiles_warning(false)

# Comprueba si la posición del ratón coincide con el área de la base y la oculta.
func remove_spawn():
	mouse_pos = get_global_mouse_position()
	if mouse_pos.x > $Spawn.position.x - 32 and mouse_pos.x < $Spawn.position.x + 32 and mouse_pos.y > $Spawn.position.y -32 and mouse_pos.y < $Spawn.position.y + 32:
		$Spawn.position = Vector2(0,0)
		$Spawn.visible = false

# Comprueba si la posición del ratón coincide con el área de la meta y la oculta.
func remove_goal():
	mouse_pos = get_global_mouse_position()
	if mouse_pos.x > $Goal.position.x - 32 and mouse_pos.x < $Goal.position.x + 32 and mouse_pos.y > $Goal.position.y -32 and mouse_pos.y < $Goal.position.y + 32:
		$Goal.position = Vector2(0,0)
		$Goal.visible = false

# Genera el nivel creado en el editor. Almacena el número de habilidades disponibles en las variables globales correspondientes, prepara la escena del nuevo nivel y lo lanza a continuación para probarlo.
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
	ResourceSaver.save("user://prueba.tscn" ,to_save)
	Global.prev_escene = "res://Editor/Editor.tscn" 
	get_tree().change_scene("user://prueba.tscn")

# Genera y almacena todos los archivos necesarios para permitir que el usuario pueda volver a editar el nivel por donde lo dejó.
# Almacena un archivo para el mapa, un archivo para la meta, un archivo para la base, y otro archivo con las habilidades.
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

# Carga los archivos necesarios para que el usuario pueda continuar con la edición de un nivel sin publicar.
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
	update_placed_cells()

# Actualiza las variables globales con el número de habilidades disponibles para cada una de ellas.
func update_skills():
	Global.Digsideers = Digsideers
	Global.Digdowners = Digdowners
	Global.Umbrellaers = Umbrellaers
	Global.Stairers = Stairers
	Global.Stopperers = Stopperers
	Global.Climbers = Climbers
	Global.lives = Lives
	
func _on_BackButton_pressed():
	$Camera2D/CanvasLayer/Popup.popup_centered()
	
func _on_YesButton_pressed():
	get_tree().change_scene("res://Menu/MainMenu.tscn")

func _on_NoButton_pressed():
	$Camera2D/CanvasLayer/Popup.visible = false

# Actualiza el número de casillas colocadas en el nivel.
func update_placed_cells():
	$Camera2D/CanvasLayer/Casillas.text = 'Casillas colocadas: ' + str(mapa.get_used_cells().size())

#Muestra el mensaje de error si el número de casillas alcanza el límite.
func max_tiles_warning(value):
	$Camera2D/CanvasLayer/Warning.visible = value


func _on_help_pressed():
	$Camera2D/CanvasLayer/Help.visible = !$Camera2D/CanvasLayer/Help.visible

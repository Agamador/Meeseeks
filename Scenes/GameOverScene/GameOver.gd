extends Control



export var move_speed := Vector2(-15,-15)
var headers = ["Content-Type: application/json"]
var created_level = preload("res://Levels/Scenes/prueba.tscn").instance()
# Called when the node enters the scene tree for the first time.
func _ready():
	get_data()
	if Global.editing == true:
		$PanelContainer/MarginContainer/Filas/Botones2.visible = true
	else:
		$PanelContainer/MarginContainer/Filas/Botones2.visible = false
	if Global.saved_lives < 1:
		$PanelContainer/MarginContainer/Filas/Botones2/Publicar.disabled = true
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$ParallaxBackground/ParallaxLayer.motion_offset +=  delta * Vector2(-10,-10)
	if $Popup/Panel/TextEdit.text == '':
		$Popup/Panel/Yes.disabled = true
	else: 
		$Popup/Panel/Yes.disabled = false
	
func get_data():
	$PanelContainer/MarginContainer/Filas/Datos/Izquierda/VidasTotales.text = 'Vidas Totales: ' + str(Global.lives)
	$PanelContainer/MarginContainer/Filas/Datos/Izquierda/TiempoGastado.text = 'Tiempo gastado: ' + Global.elapsed_time
	$PanelContainer/MarginContainer/Filas/Datos/Derecha/VidasSalvadas.text = 'Vidas salvadas: ' + str(Global.saved_lives)
	$PanelContainer/MarginContainer/Filas/Datos/Derecha/VidasPerdidas.text = 'Vidas perdidas: ' + str(Global.lost_lives)
	
func _on_Reintentar_pressed():
	Global.saved_lives = 0
	Global.lost_lives = 0
	Global.elapsed_time = 0 
	get_tree().change_scene(Global.prev_escene)

func _on_Marcadores_pressed():
	pass # Replace with function body.

func _on_MenuPrincipal_pressed():
	get_tree().change_scene("res://Menu/MainMenu.tscn")

func _on_Editor_pressed():
	get_tree().change_scene("res://Editor/Editor.tscn")

func _on_Publicar_pressed():
	$Popup.popup_centered()

func _on_No_pressed():
	$Popup.hide()

func _on_Yes_pressed():
	$Popup/Panel/error.visible = false
	var level_name = $Popup/Panel/TextEdit.text
	var file_name = level_name.replace(' ', '_')
	file_name += '.tscn'
	#creamos un packed scene, en la que cargamos el nivel creado, 
	#pasamos la packedscene como cadena al servidor para después poder generar la escena de nuevo desde la cadena
	var scene = PackedScene.new()
	scene.pack(created_level)
	var scene_text = var2str(scene)
	var params = {'user_id': Global.user_id,
		'file_name': file_name,
		'name': level_name,
		'lives': Global.lives,
		'digsideers': Global.Digsideers,
		'digdowners': Global.Digdowners,
		'stopperers': Global.Stopperers,
		'umbrellaers': Global.Umbrellaers,
		'stairers': Global.Stairers,
		'climbers': Global.Climbers,
		'scene': scene_text
	}
	$HTTPRequest.request(Global.apiurl + '/post-level',headers,true,HTTPClient.METHOD_POST,JSON.print(params))


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print(response_code)
	if response_code == 0:
		get_tree().change_scene("res://Menu/MainMenu.tscn")
	else:
		$Popup/Panel/error.visible = true

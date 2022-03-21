extends Control



export var move_speed := Vector2(-15,-15)

# Called when the node enters the scene tree for the first time.
func _ready():
	get_data()
	if Global.editing == true:
		$PanelContainer/MarginContainer/Filas/Botones2.visible = true
	if Global.saved_lives < 1:
		$PanelContainer/MarginContainer/Filas/Botones2/Publicar.disabled = true
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$ParallaxBackground/ParallaxLayer.motion_offset +=  delta * Vector2(-10,-10)
	
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
	pass # Replace with function body.

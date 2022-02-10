extends Control



export var move_speed := Vector2(-15,-15)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.

func get_data():
	$PanelContainer/MarginContainer/Filas/Datos/Izquierda/VidasTotales.text = 'Vidas Totales: ' + str(get_parent().total_lives)
	$PanelContainer/MarginContainer/Filas/Datos/Izquierda/TiempoGastado.text = 'Tiempo gastado: ' + get_parent().str_elapsed
	$PanelContainer/MarginContainer/Filas/Datos/Derecha/VidasSalvadas.text = 'Vidas salvadas: ' + str(get_parent().saved_lives)
	$PanelContainer/MarginContainer/Filas/Datos/Derecha/VidasPerdidas.text = 'Vidas perdidas: ' + str(get_parent().lost_lives)
	
func _on_Reintentar_pressed():
	get_tree().reload_current_scene()

func _on_Marcadores_pressed():
	pass # Replace with function body.

func _on_MenuPrincipal_pressed():
	pass # Replace with function body.

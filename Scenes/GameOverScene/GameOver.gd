extends Control



export var move_speed := Vector2(-15,-15)

# Called when the node enters the scene tree for the first time.
func _ready():
	get_data()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$ParallaxBackground/ParallaxLayer.motion_offset +=  delta * Vector2(-10,-10)
func get_data():
	$PanelContainer/MarginContainer/Filas/Datos/Izquierda/VidasTotales.text = 'Vidas Totales: ' + str(Global.lives)
	$PanelContainer/MarginContainer/Filas/Datos/Izquierda/TiempoGastado.text = 'Tiempo gastado: ' + Global.elapsed_time
	$PanelContainer/MarginContainer/Filas/Datos/Derecha/VidasSalvadas.text = 'Vidas salvadas: ' + str(Global.saved_lives)
	$PanelContainer/MarginContainer/Filas/Datos/Derecha/VidasPerdidas.text = 'Vidas perdidas: ' + str(Global.lost_lives)
	
func _on_Reintentar_pressed():
	pass

func _on_Marcadores_pressed():
	pass # Replace with function body.

func _on_MenuPrincipal_pressed():
	pass # Replace with function body.

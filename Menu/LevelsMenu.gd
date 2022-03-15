extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	$ParallaxBackground/ParallaxLayer.motion_offset +=  delta * Vector2(10,10)

func _on_BackButton_pressed():
	get_tree().change_scene("res://Menu/MainMenu.tscn")

func _on_Comunity_pressed():
	#query a la api para los niveles de la comunidad
	pass

extends Node2D

export var lives := 10
export var objective := 5
export var total_time := 5.0
var game_speed:= 50
var game_speed_change:= 5
var spawn_time:= 90
var original_spawn_time :=90

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _enter_tree():
	pass	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if lives > 0: 
		if spawn_time == 0:
			_spawn_meeseek()
			spawn_time = game_speed * 1.8  #1.8 es la razón de spawn time por la velocidad inicial de 50
		else:
			spawn_time -= 1;
func _speed_changed(value):
	pass
	#change actual value of spawn time
func _spawn_meeseek():
	pass

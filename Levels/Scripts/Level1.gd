extends Node2D

export var lives := 3
var saved_lives := 0
var lost_lives := 0
export var objective := 5
export var total_time := 5.0
var meeseek = preload("res://Scenes/Meeseek/Meeseek.tscn");

var mouse_pointer := 'Basic'

# Called when the node enters the scene tree for the first time.
func _ready():
	$Camera2D.position =$Spawn.position;

func _process(delta):
	pass
	
func _spawn_meeseek():
	if lives>0:
		lives -= 1
		var newMeeseek = meeseek.instance()
		newMeeseek.position = $Spawn.position
		add_child(newMeeseek)
		
func meeseek_saved():
	saved_lives += 1
	print('Salvado maradona')
	if saved_lives == objective:
		pass
		#fin
func meeseek_deceased():
	lost_lives += 1;



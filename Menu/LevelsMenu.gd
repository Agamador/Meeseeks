extends Control

var query
var level_container = preload("res://Menu/LevelContainer.tscn")
var main := true

func _ready():
	get_main_levels()
	
func _process(delta):
	$ParallaxBackground/ParallaxLayer.motion_offset +=  delta * Vector2(10,10)
	$ParallaxBackground/ParallaxLayer2.motion_offset += delta * Vector2(50,50)
func _on_BackButton_pressed():
	get_tree().change_scene("res://Menu/MainMenu.tscn")

func _on_Comunity_pressed():
	erase_levels()
	if main:
		get_community_levels()
		$Comunity.text = 'Originales'
	else:
		get_main_levels()
		$Comunity.text = 'Comunidad'
	main = !main
		
func on_level_pressed(id):
	query = 'level'
	Global.level_id = id;
	$HTTPRequest.request(Global.apiurl + '/get-level/' + str(id))

func get_main_levels():
	query = 'main'
	$HTTPRequest.request(Global.apiurl + '/main-levels/' + str(Global.user_id));

func get_community_levels():
	query = 'community'
	$HTTPRequest.request(Global.apiurl + '/community-levels/' + str(Global.user_id))

func erase_levels():
	for n in $MarginContainer/Panel/MarginContainer/ScrollContainer/VBoxContainer.get_children():
		$MarginContainer/Panel/MarginContainer/ScrollContainer/VBoxContainer.remove_child(n)
		n.queue_free()

func _on_HTTPRequest_request_completed(_result, response_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	match query:
		'main':
			if response_code == 200:
				list_levels_http_response(json.result)
			else: 
				get_main_levels()
		'community':
			if response_code == 200:
				list_levels_http_response(json.result)
			else:
				get_community_levels()
		'level':
			if response_code == 200:
				level_http_response(json.result)
			else:
				on_level_pressed(Global.level_id)


func list_levels_http_response(niveles):
	for i in niveles: 
		var level = level_container.instance()
		if niveles[i].has('name'):
			level.get_node("Margin/Panel/Button/title").text = str(niveles[i].name)
		if niveles[i].has('hi'):
			level.get_node("Margin/Panel/Button/highscore").text = 'HI: ' + str(niveles[i].hi)
		if niveles[i].has('self_percent'): 
			level.get_node("Margin/Panel/Button/percentage").text  = str(niveles[i].self_percent) + ' %'
		if niveles[i].has('top_1') :
			level.get_node("Margin/Panel/Button/HBoxContainer/goldpoints").text = str(niveles[i].top_1.score) + ' ' + niveles[i].top_1.name
		if niveles[i].has('top_2') :
			level.get_node("Margin/Panel/Button/HBoxContainer/silverpoints").text = str(niveles[i].top_2.score) + ' ' + niveles[i].top_2.name
		if niveles[i].has('top_3') :
			level.get_node("Margin/Panel/Button/HBoxContainer/bronzepoints").text = str(niveles[i].top_3.score) + ' ' + niveles[i].top_3.name
		if niveles[i].has('user_name'):
			level.get_node("Margin/Panel/Button/Autor").text = 'Autor: ' + str(niveles[i].user_name)
		level.get_node("Margin/Panel/Button").connect("pressed",self,'on_level_pressed',[i])
		$MarginContainer/Panel/MarginContainer/ScrollContainer/VBoxContainer.add_child(level)

func level_http_response(json):
	Global.Digsideers = json['digsideers']
	Global.Digdowners = json['digdowners']
	Global.Climbers = json['climbers']
	Global.Stairers = json['stairers']
	Global.Stopperers = json['stopperers']
	Global.Umbrellaers = json['umbrellaers']
	Global.lives = json['lives']
	var scene = str2var(json['scene'])
	ResourceSaver.save('user://' + json['file_name'],scene)
	get_tree().change_scene('user://'+ json['file_name'])
	
	

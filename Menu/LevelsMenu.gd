extends Control

var query
var level_container = preload("res://Menu/LevelContainer.tscn")

func _ready():
	query = 'main'
	$HTTPRequest.request(Global.apiurl + '/main-levels/' + str(Global.user_id));

func _process(delta):
	$ParallaxBackground/ParallaxLayer.motion_offset +=  delta * Vector2(10,10)

func _on_BackButton_pressed():
	get_tree().change_scene("res://Menu/MainMenu.tscn")

func _on_Comunity_pressed():
	#query a la api para los niveles de la comunidad
	pass

func on_level_pressed(id):
	query = 'level'
	$HTTPRequest.request(Global.apiurl + '/get-level/' + str(id))


func _on_HTTPRequest_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		match query:
			'main':
				main_levels_http_response(json.result)
			'level':
				level_http_response(json.result)
	else:
		#mensaje de error aquí
		pass

func main_levels_http_response(niveles):
	for i in niveles: 
		var level = level_container.instance()
		level.get_node("Margin/Panel/Button/title").text = str(niveles[i].name)
		if niveles[i].has('hi'):
			level.get_node("Margin/Panel/Button/highscore").text = 'HI: ' + str(niveles[i].hi)
		if niveles[i].has('self_percent'): 
			level.get_node("Margin/Panel/Button/percentage").text  = str(niveles[i].self_percent) + ' %'
		if niveles[i].has('top_1') :
			level.get_node("Margin/Panel/Button/HBoxContainer/goldpoints").text = niveles[i].top_1.name + ' ' + str(niveles[i].top_1.score)
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
	ResourceSaver.save('res://Levels/Scenes/' + json['file_name'],scene)
	get_tree().change_scene('res://Levels/Scenes/'+ json['file_name'])
	
	

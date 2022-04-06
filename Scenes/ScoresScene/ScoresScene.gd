extends Control

var score_container = preload("res://Scenes/ScoresScene/ScorePanel.tscn")
var new_hbox
func _ready():
	get_scores()
	
func _process(delta):
	$ParallaxBackground/ParallaxLayer.motion_offset +=  delta * Vector2(10,10)
	$ParallaxBackground/ParallaxLayer2.motion_offset += delta * Vector2(50,50)
	
func get_scores():
	$HTTPRequest.request(Global.apiurl + '/get-scores/' + str(Global.level_id))


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code != 200:
		get_scores()
	else: 
		var scores = JSON.parse(body.get_string_from_utf8()).result
		if scores.has('error'):
			pass
			#mensaje de error aquí
		else:
			if scores.has('1'):
				$MarginContainer/Panel/MarginContainer/ScrollContainer/VBoxContainer/GoldPanel/Name.text = scores['1'].name
				$MarginContainer/Panel/MarginContainer/ScrollContainer/VBoxContainer/GoldPanel/HI.text = 'HI: ' + str(scores['1'].value)
			if scores.has('2'):
				$MarginContainer/Panel/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/SilverPanel/Name.text = scores['2'].name
				$MarginContainer/Panel/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/SilverPanel/HI.text = 'HI: ' + str(scores['2'].value)
			if scores.has('3'):
				$MarginContainer/Panel/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/BronzePanel/Name.text = scores['3'].name
				$MarginContainer/Panel/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/BronzePanel/HI.text = 'HI: ' + str(scores['3'].value)
			for i in range(4,scores.size()):
				if i % 3 == 1:
					new_hbox = HBoxContainer.new()
					new_hbox.set("custom_constants/separation", 10)
					$MarginContainer/Panel/MarginContainer/ScrollContainer/VBoxContainer.add_child(new_hbox)
				var new_score = score_container.instance()
				new_score.get_node('Place').text = str(i)
				new_score.get_node('Name').text = scores[str(i)].name
				new_score.get_node("HI").text = "HI: " + str(scores[str(i)].value)
				new_hbox.add_child(new_score)

func _on_RetryButton_pressed():
	get_tree().change_scene(Global.prev_escene)

func _on_MainMenuButton_pressed():
	get_tree().change_scene("res://Menu/MainMenu.tscn")


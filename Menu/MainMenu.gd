extends Control

var db
var username
var password
var user_id
var token
var user_data_path = "user://data.txt"
var user_data
var headers = ["Content-Type: application/json"]
var query
# Called when the node enters the scene tree for the first time.
func _ready():
	if !Global.logged:
		check_logged()
	pass
	
func _process(delta):
	$ParallaxBackground/ParallaxLayer.motion_offset +=  delta * Vector2(10,10)
	if $Popup/Panel/HBoxContainer/VBoxContainer2/usename.text != '' and $Popup/Panel/HBoxContainer/VBoxContainer2/password.text != '':
		$Popup/Panel/HBoxContainer2/Login.disabled = false
	else:
		$Popup/Panel/HBoxContainer2/Login.disabled = true
	if ($RegisterPopup/Panel/HBoxContainer/VBoxContainer2/usename.text != '' and
		$RegisterPopup/Panel/HBoxContainer/VBoxContainer2/password.text != '' and
		$RegisterPopup/Panel/HBoxContainer/VBoxContainer2/password2.text != ''):
			$RegisterPopup/Panel/CreateUser.disabled = false
	else: 
		$RegisterPopup/Panel/CreateUser.disabled = true

func _on_play_pressed():
	##
	## Mensaje de que no se guardan los scores si no inicia sesión si no esta loggeado
	##
	get_tree().change_scene("res://Menu/LevelsMenu.tscn")

func _on_editor_pressed():
	get_tree().change_scene("res://Editor/Editor.tscn")

func _on_comunidad_pressed():
	pass # Replace with function body.

func _on_salir_pressed():
	get_tree().quit()

func _on_LoginButton_pressed():
	$Popup.popup()

func _on_close_pressed():
	$Popup.visible = false

func _on_Login_pressed():
	$Popup/Panel/NoUser.visible = false
	$Popup/Panel/Wrongpassword.visible = false
	var params = {"name" : $Popup/Panel/HBoxContainer/VBoxContainer2/usename.text, 
				  "password": $Popup/Panel/HBoxContainer/VBoxContainer2/password.text}
	var headers = ["Content-Type: application/json"]
	query = 'login'
	$HTTPRequest.request(Global.apiurl + '/login',headers,true, HTTPClient.METHOD_POST, JSON.print(params));
	
func _on_Register_pressed():
	$Popup.visible = false
	$RegisterPopup.popup()

func _on_close2_pressed():
	$RegisterPopup.visible = false

func _on_CreateUser_pressed():
	$RegisterPopup/Panel/Wrongpassword.visible = false
	$RegisterPopup/Panel/UsernameTaken.visible = false
	if $RegisterPopup/Panel/HBoxContainer/VBoxContainer2/password.text != $RegisterPopup/Panel/HBoxContainer/VBoxContainer2/password2.text:
		$RegisterPopup/Panel/Wrongpassword.visible = true
	else:
		var params = {'name': $RegisterPopup/Panel/HBoxContainer/VBoxContainer2/usename.text,
					  'password': $RegisterPopup/Panel/HBoxContainer/VBoxContainer2/password.text}
		query = 'register'
		$HTTPRequest.request(Global.apiurl + '/register',headers,true,HTTPClient.METHOD_POST,JSON.print(params))

func _on_LogoutButton_pressed():
	print('cerrando sesión')
	var dir = Directory.new()
	dir.remove(user_data_path)
	$LoginButton.visible = true
	$Label.visible = false
	$LogoutButton.visible = false

func check_logged():
	var file := File.new()
	if file.file_exists(user_data_path):
		file.open(user_data_path,File.READ)
		var user_data = file.get_as_text()
		file.close()
		print(user_data)
		query = 'check'
		var params = {"token" : user_data}
		$HTTPRequest.request(Global.apiurl + '/checktoken', headers,true,HTTPClient.METHOD_POST,JSON.print(params))

func save_login():
	Global.user_id = user_id
	Global.username = username
	var file := File.new()
	file.open(user_data_path,File.READ_WRITE)
	file.store_line(str(token))
	file.close()
	
func set_user():
	$LoginButton.visible = false
	$LogoutButton.visible = true
	$Label.text = str(username)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		match query:
			'login':
				login_http_response(json)
			'check':
				check_http_response(json)
			'register':
				register_http_response(json)
	else:
		print('error http')
		#mensaje para el usuario o retry

func login_http_response(json):
	print(json.result['error'])
	match str(json.result['error']):
		'noname':
			$Popup/Panel/NoUser.visible = true
		'badpass':
			$Popup/Panel/Wrongpassword.visible = true
		'none':
			$Popup.visible = false
			user_id =  json.result['id']
			token = json.result['token']
			username = $Popup/Panel/HBoxContainer/VBoxContainer2/usename.text
			save_login()
			set_user()

func check_http_response(json):
	printt(str(json.result))
	if json.result['status'] == 1:
		Global.logged = true
		username = json.result['username']
		set_user()

func register_http_response(json):
	print(str(json.result['error']))
	match str(json.result['error']):
		'nametaken':
			$RegisterPopup/Panel/UsernameTaken.visible = true
		'none':
			token = json.result['token']
			username = $RegisterPopup/Panel/HBoxContainer/VBoxContainer2/usename.text
			user_id = json.result['id']
			save_login()
			set_user()
			$RegisterPopup.visible = false
		

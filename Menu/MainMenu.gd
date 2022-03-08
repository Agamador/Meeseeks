extends Control

var db
var username
var password
var user_id
# Called when the node enters the scene tree for the first time.
func _ready():
	db = Global.SQLite.new()
	db.path = Global.db_name
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
	pass # Replace with function body.

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
	db.open_db()
	var params := [$Popup/Panel/HBoxContainer/VBoxContainer2/usename.text]
	db.query_with_bindings("SELECT * FROM users WHERE name = ?", params)
	if db.query_result.size() != 0:
		username = db.query_result[0]['name']
		user_id = db.query_result[0]['id']
		password = db.query_result[0]['password']
		if password != $Popup/Panel/HBoxContainer/VBoxContainer2/password.text.sha256_text():
			$Popup/Panel/Wrongpassword.visible = true
		else:
			#login success
			pass
	else: 
		$Popup/Panel/NoUser.visible = true
	db.close_db()
	
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
		db.open_db()
		var dict := Dictionary()
		dict['name'] = $RegisterPopup/Panel/HBoxContainer/VBoxContainer2/usename.text
		dict['password'] = $RegisterPopup/Panel/HBoxContainer/VBoxContainer2/password.text.sha256_text()
		var funsiono = db.insert_row('users', dict)
		if !funsiono:
			$RegisterPopup/Panel/UsernameTaken.visible = true
		else:
			pass
			#log user
		db.close_db()

func save_login():
	var file := File.new()
	file.open("user://Data/data.json",File.READ_WRITE)
	

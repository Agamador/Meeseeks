extends Control

# Almacena el nombre de usuario.
var username

# Almacena la contraseña del usuario.
var password

# Almacena el id del usuario
var user_id

# Almacena el token de inicio de sesión.
var token

# Ruta al archivo para almacenar la sesión iniciada.
var user_data_path = "user://data.txt"

# Almacena el contenido del archivo de sesión iniciada.
var user_data

# Cabeceras para las peticiones HTTP.
var headers = ["Content-Type: application/json"]

# Almacena el nombre de la petición que se va a realizar.
var query

# Contador para el numero de intentos de la petición de comprobación de inicio de sesión.
var tries := 0

# Función llamada cuando el nodo entra por primera vez en el arbol de escenas.
func _ready():
	check_logged()
	
#Función que se ejecuta cada frame
func _process(delta):
	$ParallaxBackground/ParallaxLayer.motion_offset +=  delta * Vector2(10,10)
	$ParallaxBackground/ParallaxLayer2.motion_offset += delta * Vector2(50,50)
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
	if !Global.logged:
		$MarginContainer/VBoxContainer/play.disabled = true
		$MarginContainer/VBoxContainer/editor.disabled = true
	else:
		$MarginContainer/VBoxContainer/play.disabled = false
		$MarginContainer/VBoxContainer/editor.disabled = false

## Función llamada al pulsar el botón Jugar.
# Cambia la pantalla actual por la lista de niveles.
func _on_play_pressed():
	Global.editing = false
	get_tree().change_scene("res://Menu/LevelsMenu.tscn")
	
## Función llamada al pulsar el botón editor
# Cambia la pantalla actual por la del editor
func _on_editor_pressed():
	get_tree().change_scene("res://Editor/Editor.tscn")

## Función llamada al pulsa el botón Salir
# Cierra el programa
func _on_salir_pressed():
	get_tree().quit()

## Función llamada al pulsar el botón iniciar sesión
# Muestra el panel con el formulario para iniciar sesión
func _on_LoginButton_pressed():
	$Popup.popup()

## Función llamada al pulsar el botón para cerrar el panel de inicio de sesión
# Cierra el panel de inicio de sesión
func _on_close_pressed():
	$Popup.visible = false

## Función llamada al pulsar el botón iniciar sesión en el panel de incio de sesión
# Prepara y realiza la petición HTTP para iniciar sesión
func _on_Login_pressed():
	$Popup/Panel/NoUser.visible = false
	$Popup/Panel/Wrongpassword.visible = false
	$Popup/Panel/HttpError.visible = false
	var params = {"name" : $Popup/Panel/HBoxContainer/VBoxContainer2/usename.text, 
				  "password": $Popup/Panel/HBoxContainer/VBoxContainer2/password.text}
	query = 'login'
	$HTTPRequest.request(Global.apiurl + '/login',headers,true, HTTPClient.METHOD_POST, JSON.print(params));

## Función llamada al pulsar el botón crear usuario en el panel de inicio de sesión
# Muestra el panel con el formulario para crear un ususario
func _on_Register_pressed():
	$Popup.visible = false
	$RegisterPopup.popup()

## Función llamada al pulsar el botón para cerrar el panel de creación de usuario
# Cierra el panel de creación de usuario
func _on_close2_pressed():
	$RegisterPopup.visible = false

## Función llamada al pulsar el botón crear usuario en el panel de creación de usuario
# Prepara y realiza la petición HTTP para la creación de usuario
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

## Función llamada al pulsar el botón cerrar sesión
# Cierra la sesión del usuario acutal y borra la información de inicio de sesión
func _on_LogoutButton_pressed():
	var dir = Directory.new()
	dir.remove(user_data_path)
	Global.logged = false
	$LoginButton.visible = true
	$Label.visible = false
	$LogoutButton.visible = false

# Comprueba si ya existe una sesión iniciada previamente y comprueba si esta es correcta mediante una petición HTTP.
func check_logged():
	var file := File.new()
	if file.file_exists(user_data_path):
		$Loading.popup_centered()
		file.open(user_data_path,File.READ)
		user_data = file.get_as_text()
		file.close()
		query = 'check'
		var params = {"token" : user_data}
		$HTTPRequest.request(Global.apiurl + '/check-token', headers,true,HTTPClient.METHOD_POST,JSON.print(params))

# Almacena un token de inicio de sesión para mantener esta abierta al volver a abrir el juego.
func save_login():
	Global.user_id = user_id
	Global.username = username
	var file := File.new()
	file.open(user_data_path,File.WRITE)
	file.store_line(str(token))
	file.close()
	
# Inicia la sesión del usuario.
func set_user():
	$LoginButton.visible = false
	$LogoutButton.visible = true
	$Label.text = str(username)
	$Label.visible = true
	Global.logged = true

# Llama a las funciones necesarias en función de la respuesta a una petición HTTP.
func _on_HTTPRequest_request_completed(_result, response_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	match query:
		'login':
			if response_code == 200:
				login_http_response(json)
			else:
				_on_Login_pressed()
		'check':
			if response_code == 200:
				check_http_response(json)
			else: 
				print(tries)
				if tries < 5:
					check_logged()
					tries += 1
				else:
					$Popup/Panel/HttpError.visible = true
					tries = 0
		'register':
				register_http_response(json)
				
# Gestiona la respuesta HTTP para la petición de inicio de sesión
# Muestra un mensaje de error si el nombre de usuario es incorrecto,
# muestra un mensaje de error si la contraseña es incorrecta.
# Si la respuesta es correcta prepara las variables para el inicio de sesión y llama a save_login() y set_user().
func login_http_response(json):
	match str(json.result['error']):
		'noname':
			$Popup/Panel/NoUser.visible = true
		'badpass':
			$Popup/Panel/Wrongpassword.visible = true
		'none':
			user_id =  json.result['id']
			token = json.result['token']
			username = $Popup/Panel/HBoxContainer/VBoxContainer2/usename.text
			print(username)
			$Popup.visible = false
			Global.logged = true
			save_login()
			set_user()

# Gestiona la respuesta HTTP para la petición de comprobación de sesión.
# Llama a set_user() si la comprobación es correcta.
func check_http_response(json):
	if json.result['status'] == 1:
		$Loading.visible = false
		Global.logged = true
		username = json.result['username']
		user_id = json.result['id']
		Global.user_id = user_id
		set_user()

# Gestiona la respuesta HTTP para la petición de creación de usuario.
# Muestra un error si el nombre de usuario ya está en uso.
# Si la respuesta es correcta el usuario queda registrado y además, se inicia la sesión.
func register_http_response(json):
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

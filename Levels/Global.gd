extends Node

#api
var apiurl = 'https://meeseeks-api-3eivo.ondigitalocean.app/api'

#usuario
var username
var user_id
var logged := false

#navegación
var prev_escene := "res://Menu/MainMenu.tscn"

#juego a pantalla fin de juego
var lives
var saved_lives
var lost_lives
var elapsed_time
var level_id 
var elapsed_seconds
#panel lateral a menú editor
var tile_mouse = ''
var on_panel = false

#Editor
var map_path = "user://editormap.txt"
var goal_path = "user://goalmap.txt"
var spawn_path = "user://spawnmap.txt"
var skills_path = "user://skillsmap.txt"
var editing = false

#habilidades
var Digsideers = 0 
var Digdowners = 0
var Stopperers = 0
var Umbrellaers = 0
var Stairers = 0
var Climbers = 0

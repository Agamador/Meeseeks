extends Node

#api
var apiurl = 'http://127.0.0.1:8000/api'
#usuario
var username
var user_id
var logged := false
#juego a pantalla fin de juego
var lives := 0
var last_level
var saved_lives
var lost_lives
var elapsed_time

#panel lateral a menú editor
var tile_mouse = ''
var on_panel = false

#habilidades
var Digsideers 
var Digdowners 
var Stopperers 
var Umbrellaers 
var Stairers 
var Climbers 

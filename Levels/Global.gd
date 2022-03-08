extends Node

#base de datos
const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db_name = "res://Data/database"
#var db_name = "http://localhost/Meeseeks/database"
	
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

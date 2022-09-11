extends Node

# URL base para llamar a los métodos de la api.
var apiurl = 'http://api.agamador.com/api'
# Almacena el nombre de usuario.
var username
# Almacena el id del usuario.
var user_id
# Almacena si el usuario se encuentra con una sesión iniciada o no.
var logged := false

# Almacena la última escena en la que se encontraba el usuario.
var prev_escene := "res://Menu/MainMenu.tscn"

# Numero de vidas del nivel.
var lives
# Numero de vidas salvadas al final del nivel.
var saved_lives
# Numero de vidas perdidas al final del nivel.
var lost_lives
# Tiempo usado para finalizar el nivel en formato m:s.
var elapsed_time
# Identificador del nivel.
var level_id 
# Tiempo usado para finalizar el nivel en segundos.
var elapsed_seconds
# Tipo de casilla seleccionada para colocar en el editor.
var tile_mouse = ''
# Almacena si el cursor se encuentra en el área de un panel de la interfaz.
var on_panel = false

# Rutas a los archivos almacenados en la máquina del usuario.
var map_path = "user://editormap.txt"
var goal_path = "user://goalmap.txt"
var spawn_path = "user://spawnmap.txt"
var skills_path = "user://skillsmap.txt"

# Almacena si el nivel actual esta siendo probado.
var editing = false

# Número de habilidades disponibles para el nivel.
var Digsideers = 0 
var Digdowners = 0
var Stopperers = 0
var Umbrellaers = 0
var Stairers = 0
var Climbers = 0

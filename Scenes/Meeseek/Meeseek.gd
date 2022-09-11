extends KinematicBody2D
# Velocidad máxima de movimiento horizontal, está en píxeles por segundo (1s = 64px).
const MAXSPEED = 64

# Velocidad de movimento hacia el suelo.
const GRAVITY = 150

# Dirección en la que el meeseek se mueve (+1 = derecha, -1 izquierda).
var right = 1

# Indica si el meeseek sigue vivo.
var alive = true

# Indica si el meeseek ha estado en contacto con el suelo en el frame anterior.
var once = true

# Estado del meeseek, este indica que habilidad tiene que realizar un meeseek en cada momento.
var state := "Basic"

# Contiene los datos de la última collision de meeseek contra algo que no sea el suelo.
var collision

# Indica si el meeseek tiene el cursor encima o no.
var mouse_in := false

# Stopper
# Almacena la posición en la que el meeseek se queda quieto.
var original_position := Vector2.ZERO

# Escalera
# Indica si el meeseek se encuentra pisando una escalera.
var en_escalera := false

#Escalera
# Almacena el id de los tiles que representan la escalera.
var stair_tiles := [19, 18, 17, 16, 15, 14, 13, 20, 21, 22, 23 ,24 ,25 ,26]

# Mapa
# Indica la posición de una celda en el mapa.
var celda

# Nodo que contiene el mapa del nivel.
var map

# Diggers
# Almacena el id del primer bloque diferente al suelo con el que colisiona el meeseek.
var first_collision := -1

# Diggers
# Almacena el número de frames que lleva excavando o taladrando un meeseek.
var frames_digging := 0

# Id del siguiente bloque con el que collisionará un meeseek.
var next_collision := 0

# Indica si el meeseek tiene que dejar de excavar el siguiente bloque.
var stop_digging := false

# Vertical digger
# Indica si el meeseek esta excavando.
var digging := false

# Umbrella
# Indica si el meeseek tiene que dejar de utilizar el paraguas.
var stop_umbrella := false

# Número de frames que lleva el meeseek en el aire.
var air_time := 0

# Stair
# Indica si el meeseek esta actualmente construyendo una escalera.
var building := false

# Almacena el id del tile que esta construyendo actualmente el meeseek.
var building_block := 0

# Indica en que celda esta construyendo el meeseek actualmente.
var building_cell 

# Indica cuantos frames lleva el meeseek construyendo.
var building_frame := 0

# Climber
# Indica si el meeseek se encuentra escalando. 
var climbing := false

# Velocidad del meeseek en cada frame.
# Se inicia el movimiento del meeseek en caida.
var motion = Vector2(0, GRAVITY)

var saved = false

func _ready():
	#mapa
	map = get_parent().get_node("TileMap")
	$Timer.stop()

func _physics_process(delta):
	match state:
		"Basic":
			normal_meeseek()
		"DigSide":
			digSide_meeseek()
		"DigDown":
			digDown_meeseek()
		"Stopper":
			stopper_meeseek()
		"Umbrella":
			umbrella_meeseek()
		"Stair":
			stair_meeseek()
		"Climb":
			climb_meeseek()
		"Nuked":
			motion = Vector2()
			$AnimationPlayer.play("Death")
		_:
			normal_meeseek()
	if state != "Stopper":
		self.set_collision_layer_bit(0, false)
		original_position = Vector2.ZERO
	move_and_slide(motion, Vector2.UP,true,4,2.6, false)

# Gestiona el comportamiento del meeseek si este no tiene ninguna habilidad asignada.
func normal_meeseek():
	if out_of_bounds():
		alive = false
	if alive:
		#bloque meeseek en el aire
		#si vuela durante m�s de 2 segundos aprox(5 bloques)
		if !is_on_floor():
			#comprobación de si estamos en una escalera al caer
			motion.x = 0
			motion.y = GRAVITY
			#para separar el cuerpor de las paredes al caer
			if once:
				once = false
				$Timer.start()
			$Sprite.scale.x = right
			$AnimationPlayer.play("Fall")
		#bloque meeseek en el suelo
		else:
			#reset la separaci�n de la pared al tocar el suelo
			once = true
			motion.x = MAXSPEED * right
			$Timer.stop()
			$Sprite.scale.x = right
			$AnimationPlayer.play("Walking")
			#comprueba las colisiones durante el movimiento,
			for i in get_slide_count():
				collision = get_slide_collision(i)
				if collision.get_collider().get_class() == "StaticBody2D" and !saved:
						saved = true
						self.get_parent().meeseek_saved()
						self.queue_free()  #borrado
						###sumar meeseek a contador de exito y borrarlo
					#si la colisi�n es diferente a la colisi�n frente al suelo, y frente a la direcci�n en la que avanzo
				if collision.normal == Vector2(-right,0) or collision.get_collider().get_class() == "KinematicBody2D":
					right = -right
					motion.x = MAXSPEED * right
				if abs(collision.normal.y) < 0.8:
					motion.y = collision.normal.y

	else:
		if is_on_floor() or out_of_bounds():
			motion = Vector2()
			$AnimationPlayer.play("Death")
			

# Gestiona el comportamiento del meeseek si este tiene la habilidad taladro asignada.
func digSide_meeseek():
	if out_of_bounds():
		alive = false
	if alive:
		if digging:
			$Sprite.scale.x = right
			$AnimationPlayer.play("Side drill")
			motion.x = 0
			##inicia animaci�n excavar
			#numero de frames que se excavan 60 = 1 segundo
			if frames_digging < 30:
				frames_digging += 1
				if first_collision == -1:
					first_collision = map.get_cellv(celda)
					next_collision = map.get_cellv(celda + Vector2(right, 0))
					if next_collision == -1 or next_collision < 5 or next_collision > 9:
						stop_digging = true
			else:
				frames_digging = 0
				#5 a 7 son tiles destrozandose, 8 es el ultimo paso y -1 elimina la casilla
				if first_collision >= 5 and first_collision <= 8:
					first_collision += 1
					if first_collision == 6 :
						first_collision += 1
					map.set_cellv(celda, first_collision)
				elif first_collision == 9:
					first_collision = -1
					map.set_cellv(celda, -1)
					digging = false
					#a�adir animaci�n de romper bloque
					if stop_digging == true:
						map.update_dirty_quadrants()
						self.state = "Basic"
						stop_digging = false
		#bloque meeseek en el aire
		#si vuela durante m�s de 2 segundos aprox(5 bloques)
		else:
			if !is_on_floor():
				#comprobación de si estamos en una escalera al caer
				motion.x = 0
				motion.y = GRAVITY
				#para separar el cuerpor de las paredes al caer
				if once:
					once = false
					$Timer.start()
				$Sprite.scale.x = right
				$AnimationPlayer.play("Fall")
			#bloque meeseek en el suelo
			else:
				#reset la separaci�n de la pared al tocar el suelo
				once = true
				$Timer.stop()
				$Sprite.scale.x = right
				$AnimationPlayer.play("Walking")
				motion.x = MAXSPEED * right
				#comprueba las colisiones durante el movimiento,

				for i in get_slide_count():
					collision = get_slide_collision(i)
					if collision.get_collider().get_class() == "StaticBody2D"and !saved:
							saved = true
							self.get_parent().meeseek_saved()
							self.queue_free()  #borrado
							###sumar meeseek a contador de exito y borrarlo
					if abs(collision.normal.y) < 0.8:
						motion.y = collision.normal.y
					if collision.normal == Vector2(-right, 0):
						celda = map.world_to_map(collision.position - collision.normal)
						if map.get_cellv(celda) >= 5 and map.get_cellv(celda) <= 12:
							digging = true
						elif map.get_cellv(celda) != -1 or collision.get_collider().get_class() == "KinematicBody2D":
							right = -right
							motion.x = MAXSPEED * right


	else:
		if is_on_floor() or out_of_bounds():
			motion = Vector2()
			$AnimationPlayer.play("Death")
				
# Gestiona el comportamiento del meeseeks si este tiene la habilidad excavadora asignada.
func digDown_meeseek():
	if out_of_bounds():
		alive = false
	if alive:
		#bloque meeseek en el aire
		#si vuela durante m�s de 2 segundos aprox(5 bloques)
		if !is_on_floor():
				motion.x = 0
				motion.y = GRAVITY
				#para separar el cuerpor de las paredes al caer
				if once and !digging:
					once = false
					$Timer.start()
				$Sprite.scale.x = right
				$AnimationPlayer.play("Fall")
		#bloque meeseek en el suelo
		else:
			#reset la separaci�n de la pared al tocar el suelo
			once = true
			$Timer.stop()
			if !digging:
				$Sprite.scale.x = right
				$AnimationPlayer.play("Walking")
				motion.x = MAXSPEED *right
			for i in get_slide_count():
				collision =get_slide_collision(i)
				if collision:
					celda = map.world_to_map(collision.position - collision.normal)
					if collision.get_collider().get_class() == "StaticBody2D"and !saved:
						saved = true
						self.get_parent().meeseek_saved()
						self.queue_free()  #borrado
					if collision.normal != Vector2(0,-1):
						if abs(collision.normal.y) < 0.8:
							motion.y = collision.normal.y
						if collision.normal == Vector2(-right, 0) or collision.get_collider().get_class() == "KinematicBody2D":
							right = -right
							motion.x = MAXSPEED * right
						
					elif map.get_cellv(celda) >=5 and map.get_cellv(celda) <=9: 
						motion.x = 0
						#empuje para centrar un poco al meeseek en la celda que excava
						if !digging:
							self.position.x += 15 *right
						digging = true;
						$Sprite.scale.x = right
						$AnimationPlayer.play("Down drill")
						if frames_digging <= 30:
							frames_digging += 1
							if first_collision == -1:
								first_collision = map.get_cellv(celda)
								next_collision = map.get_cellv(celda + Vector2(0, 1))
								if next_collision == -1 or next_collision < 5 or next_collision >9:
									stop_digging = true
						else:
							frames_digging = 0
							#5 a 7 son tiles destrozandose, 8 es el ultimo paso y -1 elimina la casilla
							if first_collision >= 5 and first_collision <= 8:
								if first_collision == 5 or first_collision == 6:
									first_collision = 7 
								else:
									first_collision = first_collision + 1
								map.set_cellv(celda, first_collision)
							elif first_collision == 9:
								first_collision = -1
								#a�adir animaci�n de romper bloque
								map.set_cellv(celda, -1)
								if stop_digging == true:
									self.state = "Basic"
									stop_digging = false
									digging = false
						
	else:
		if is_on_floor() or out_of_bounds():
			motion = Vector2()
			$AnimationPlayer.play("Death")

# Gestiona el comportamiento del meeseek si este tiene la habilidad parar asignada.
func stopper_meeseek():
	if out_of_bounds():
		alive = false
	if alive:
		if is_on_floor():
			if original_position == Vector2.ZERO:
				original_position = self.position
			self.position = original_position
			self.set_collision_layer_bit(0, true)
			$Sprite.scale.x = right
			$AnimationPlayer.play("stopper")
			motion = Vector2.ZERO
			$Timer.stop()
	else:
		if is_on_floor() or out_of_bounds():
			motion = Vector2()
			$AnimationPlayer.play("Death")

# Gestiona el comportamiento del meeseek si este tiene la habilidad paraguas asignada.
func umbrella_meeseek():
	if !once:
		alive = true
		once = true
	if out_of_bounds():
		alive = false
	if alive:
		if !is_on_floor():
			air_time += 1
			$Timer.stop()
			$Sprite.scale.x = right
			$AnimationPlayer.play("Umbrella fall")
			motion.y = GRAVITY/3
			motion.x = 0
			if air_time >= 20:
				stop_umbrella = true
		else: 
			if stop_umbrella:
				self.state = 'Basic'
			motion.x = MAXSPEED * right
			$Timer.stop()
			$Sprite.scale.x = right
			$AnimationPlayer.play("Walking")
			#comprueba las colisiones durante el movimiento,
			for i in get_slide_count():
				collision = get_slide_collision(i)
				if collision.get_collider().get_class() == "StaticBody2D"and !saved:
						saved = true
						self.get_parent().meeseek_saved()
						self.queue_free()  #borrado
						###sumar meeseek a contador de exito y borrarlo
					#si la colisi�n es diferente a la colisi�n frente al suelo, y frente a la direcci�n en la que avanzo
				if collision.normal == Vector2(-right,0) or collision.get_collider().get_class() == "KinematicBody2D":
					right = -right
					motion.x = MAXSPEED * right
				if abs(collision.normal.y) < 0.8:
					motion.y = collision.normal.y
	else:
		if is_on_floor() or out_of_bounds():
			motion = Vector2()
			$AnimationPlayer.play("Death")

# Gestiona el comportamiento del meeseek si este tiene la habilidad escaleras asignada.
func stair_meeseek():
	if out_of_bounds():
		alive = false
	if alive:
		if building:
			$Sprite.scale.x = right
			$AnimationPlayer.play("Stairer")
			if right > 0:
				if building_block == 0:
					building_block = 12
				if  building_frame > 60:
					building_frame = 0 
					building_block += 1
					if building_block <= 19 :
						map.set_cellv(building_cell, building_block)
						self.position.x += 8 * right;
						self.position.y -= 8;
					else:
						building = false;
						self.state = 'Basic'
						building_block = 0
						building_cell = null
				else: 
					building_frame += 1
			else: 
				if building_block == 0:
					building_block = 19
				if building_frame > 60:
					building_frame = 0 
					building_block += 1
					if building_block <= 26:
						map.set_cellv(building_cell, building_block)
						self.position.x += 8 * right;
						self.position.y -= 8;
					else:
						building = false;
						self.state = 'Basic'
						building_block = 0
						building_cell = null
				else:
					 building_frame += 1
		else:
			#bloque meeseek en el aire
			if !is_on_floor():
				#comprobación de si estamos en una escalera al caer
				if get_slide_count() != 0:
					for i in get_slide_count():
						collision = get_slide_collision(i)
						if stair_tiles.has(map.get_cellv(map.world_to_map(collision.position - collision.normal))):
							en_escalera = true;
				if !en_escalera:
					
					motion.x = 0
					motion.y = GRAVITY
					#para separar el cuerpor de las paredes al caer
					if once:
						$Timer.start()
						self.position.x += right * 13
						once = false
					$Sprite.scale.x = right
					$AnimationPlayer.play("Fall")
				else:
					once = false
					if get_slide_count() == 0:
						en_escalera = false
						motion.y = GRAVITY
						once = false
			#bloque meeseek en el suelo
			else:
				#reset la separaci�n de la pared al tocar el suelo
				once = true
				en_escalera = false
				$Timer.stop()
				$Sprite.scale.x = right
				$AnimationPlayer.play("Walking")
				motion.x = MAXSPEED * right
				#comprueba las colisiones durante el movimiento,
				for i in get_slide_count():
					collision = get_slide_collision(i)
					if collision.get_collider().get_class() == "StaticBody2D"and !saved:
						saved = true
						self.get_parent().meeseek_saved()
						self.queue_free()  #borrado
						###sumar meeseek a contador de exito y borrarlo
					#si la colisi�n es diferente a la colisi�n frente al suelo, y frente a la direcci�n en la que avanzo
					if collision.normal == Vector2(0, -1) or en_escalera:
						
						building_cell = map.world_to_map(self.position)
						building_cell.x += right
						#la celda de enfrente está vacía
						if map.get_cellv(building_cell) == -1:
							#el valor de distancia tiene que ser 20 porque si es más chico el hueco no
							#se puede hacer escalera sobre escalera							
							if right > 0:
								if abs(self.position.x - (building_cell.x * 64 )) < 20:
									building = true
									motion = Vector2(0,0)
							else :
								if abs(self.position.x - (building_cell.x * 64 + 64)) < 20:
									building = true
									motion = Vector2(0,0)
					else:
						if collision.get_collider().get_class() == "TileMap":
							celda = map.world_to_map(collision.position - collision.normal)
							if stair_tiles.has(map.get_cellv(celda)):
								en_escalera = true
								motion.y = collision.normal.y
							else:
								en_escalera = false
						if collision.normal == Vector2(-right, 0):
							right = -right
							motion.x = MAXSPEED * right
	else:
		if is_on_floor() or out_of_bounds():
			motion = Vector2()
			$AnimationPlayer.play("Death")	

# Gestiona el comportamiento del meeseek si este tiene la habilidad escalar asignada.
func climb_meeseek():
	if out_of_bounds():
		alive = false
	if alive:
		if climbing:
			$Sprite.scale.x = right
			$AnimationPlayer.play("climb")
			$Timer.stop()
			if is_on_ceiling():
				climbing = false
				self.state = 'Basic'
				self.position.x -= right * 20
			celda = map.world_to_map(self.position + Vector2(right * 65, 0))
			if map.get_cellv(celda) == -1:
				self.state = "Basic"
				self.position = self.position + Vector2(right * 12, -32)
				motion = Vector2(MAXSPEED * right, GRAVITY)
				climbing = false
		else:
			#bloque meeseek en el aire
			#si vuela durante m�s de 2 segundos aprox(5 bloques)
			if !is_on_floor():
				motion.x = 0
				motion.y = GRAVITY
				#para separar el cuerpor de las paredes al caer
				if once:
					once = false
					$Timer.start()
				$Sprite.scale.x = right
				$AnimationPlayer.play("Fall")
			#bloque meeseek en el suelo
			else:
				#reset la separaci�n de la pared al tocar el suelo
				once = true
				$Timer.stop()
				$Sprite.scale.x = right
				$AnimationPlayer.play("Walking")
				motion.x = MAXSPEED * right
				#comprueba las colisiones durante el movimiento,
				for i in get_slide_count():
					collision =get_slide_collision(i)
					if collision:
						if collision.get_collider().get_class() == "StaticBody2D"and !saved:
							saved = true
							self.get_parent().meeseek_saved()
							self.queue_free()  #borrado
							#sumar meeseek a contador de exito y borrarlo
						#si la colisi�n es diferente a la colisi�n frente al suelo, y frente a la direcci�n en la que avanzo
						if collision.normal == Vector2(-right,0):
							if collision.get_collider().get_class() != "KinematicBody2D":
								motion.x = 0
								motion.y = -GRAVITY / 4
								climbing = true
							else: 
								right = -right
								motion.x = MAXSPEED * right
						elif abs(collision.normal.y) < 0.8:
							motion.y = collision.normal.y
							
	else:
		if is_on_floor() or out_of_bounds():
			motion = Vector2()
			$AnimationPlayer.play("Death")

# Elimina al meeseek lanzando la animación de muerte.
func get_nuked():
	self.state = 'Nuked'

# Gestiona la muerte del meeseek.
# A esta funci�ón se llama desde la animaci�n Death para que el meeseek muera al terminar la animació�n.
func death():
	get_parent().meeseek_deceased()
	self.queue_free()

func _unhandled_input(event):
	if mouse_in:
		if (
			event is InputEventMouseButton
			and event.button_index == BUTTON_LEFT
			and event.is_pressed()
		):
			if self.state != get_parent().mouse_pointer:
				match get_parent().mouse_pointer:
					"DigSide":
						if get_parent().Digsideers >= 1:
							self.state = get_parent().mouse_pointer
							get_parent().Digsideers -= 1
							get_parent().update_buttons_values()
							get_tree().set_input_as_handled()
					"DigDown":
						if get_parent().Digdowners >= 1:
							self.state = get_parent().mouse_pointer
							get_parent().Digdowners -= 1
							get_parent().update_buttons_values()
							get_tree().set_input_as_handled()
					"Stopper":
						if get_parent().Stopperers >= 1:
							self.state = get_parent().mouse_pointer
							get_parent().Stopperers -= 1
							get_parent().update_buttons_values()
							get_tree().set_input_as_handled()
					"Umbrella":
						if get_parent(). Umbrellaers >= 1:
							self.state = get_parent().mouse_pointer
							get_parent(). Umbrellaers -= 1
							get_parent().update_buttons_values()
							get_tree().set_input_as_handled()
					"Stair":
						if get_parent().Stairers >= 1:
							self.state = get_parent().mouse_pointer
							get_parent().Stairers -= 1
							get_parent().update_buttons_values()
							get_tree().set_input_as_handled()
					"Climb":
						if get_parent().Climbers >= 1:
							self.state = get_parent().mouse_pointer
							get_parent().Climbers -= 1
							get_parent().update_buttons_values()
							get_tree().set_input_as_handled()
#funciones para controlar el clickar un solo meeseek a la vez (topmost order)
func _on_Meesek_mouse_entered():
	mouse_in = true
	Input.set_custom_mouse_cursor(get_parent().selector,0,Vector2(32,32))
	
func _on_Meesek_mouse_exited():
	mouse_in = false
	Input.set_custom_mouse_cursor(get_parent().arrow,0,Vector2(0,0))

# Comprueba si el meeseek se encuentra dentro de los límites del mapa.
func out_of_bounds():
	return (self.position.y > map.get_used_rect().end.y * 64
		or self.position.x < map.get_used_rect().position.x * 64
		or self.position.x > map.get_used_rect().end.x * 64)
	
func _on_Timer_timeout():
	self.alive = false # Replace with function body.

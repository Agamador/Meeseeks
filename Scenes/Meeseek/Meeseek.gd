extends KinematicBody2D

const DEADSPEED = 200
const MAXSPEED = 60
const GRAVITY = 150
var right = 1
var alive = true
var air_time = 0
var on_air := false
var once = true
var state := "basic"
#escalera
var en_escalera := false
var stair_tiles := [19, 18, 17, 16, 15, 14, 13, 20, 21, 22, 23 ,24 ,25 ,26]
#mapa
var celda
var map
#digger
var first_collision := -1
var frames_digging := 0
var next_collision := 0
var stop_digging := false
#vertical digger
var digging := false
#Umbrella
var stop_umbrella := false
#Climber
var climbing := false
#Se inicia el movimiento del misik en caida
var motion = Vector2(0, GRAVITY)


func _ready():
	#mapa
	map = get_parent().get_node("TileMap")


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
		_:
			normal_meeseek()
	move_and_slide(motion, Vector2.UP)


func normal_meeseek():
	if alive:
		#bloque meeseek en el aire
		#si vuela durante m�s de 2 segundos aprox(5 bloques)
		if air_time > 120:
			alive = false
			#la escalera no se detecta como suelo
		if !is_on_floor():
			if !en_escalera:
				air_time += 1
				motion.x = 0
				motion.y = GRAVITY
				#para separar el cuerpor de las paredes al caer
				if once:
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
			air_time = 0
			$Sprite.scale.x = right
			$AnimationPlayer.play("Walking")
			motion.x = MAXSPEED * right
			#comprueba las colisiones durante el movimiento,
			for i in get_slide_count():
				var collision = get_slide_collision(i)
				if collision:
					if collision.get_collider().get_class() == "StaticBody2D":
						self.get_parent().meeseek_saved()
						self.queue_free()  #borrado
						#sumar meeseek a contador de exito y borrarlo
					#si la colisi�n es diferente a la colisi�n frente al suelo, y frente a la direcci�n en la que avanzo
					if collision.normal != Vector2(0, -1):
						if collision.get_collider().get_class() == "TileMap":
							celda = map.world_to_map(collision.position - collision.normal)
							if stair_tiles.has(map.get_cellv(celda)):
								en_escalera = true
								motion.y = collision.normal.y
							else:
								en_escalera = false
					if collision.normal == Vector2(-right, 0):
						right = -right
	else:
		air_time += 1
		if (
			self.position.y > map.get_used_rect().end.y
			or self.position.x < map.get_used_rect().position.x
			or self.position.x > map.get_used_rect().end.x
			or self.position.y < map.get_used_rect().position.y
		):
			motion = Vector2()
			$AnimationPlayer.play("Death")


#selfxplaining
func digSide_meeseek():
	if alive:
		#bloque meeseek en el aire
		#si vuela durante m�s de 2 segundos aprox(5 bloques)
		if air_time > 120:
			alive = false
		if !is_on_floor():
			if !en_escalera:
				air_time += 1
				motion.x = 0
				motion.y = GRAVITY
				#para separar el cuerpor de las paredes al caer
				if once:
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
			air_time = 0
			$Sprite.scale.x = right
			$AnimationPlayer.play("Walking")
			motion.x = MAXSPEED * right
			#comprueba las colisiones durante el movimiento,
			for i in get_slide_count():
				var collision = get_slide_collision(i)
				if collision:
					if collision.get_collider().get_class() == "StaticBody2D":
						self.get_parent().meeseek_saved()
						self.queue_free()  #borrado
						#sumar meeseek a contador de exito y borrarlo
					#si la colisi�n es diferente a la colisi�n frente al suelo
					if collision.normal != Vector2(0, -1):
						#si chocamos con el mapa
						if collision.get_collider().get_class() == "TileMap":
							celda = map.world_to_map(collision.position - collision.normal)
							#si la celda es de una escalera
							if stair_tiles.has(map.get_cellv(celda)):
								en_escalera = true
								motion.y = collision.normal.y
							else:
								en_escalera = false
								#si nos chocamos de cara
								if collision.normal == Vector2(-right, 0) :
									celda = map.world_to_map(collision.position - collision.normal)
									#print(map.get_cellv(celda))
									#if first_collision != -1 and map.get_cellv(celda)
									motion.x = 0
									##inicia animaci�n excavar

									#numero de frames que se excavan 60 = 1 segundo
									if frames_digging < 30:
										frames_digging += 1
										if first_collision == -1:
											first_collision = map.get_cellv(celda)
											next_collision = map.get_cellv(celda + Vector2(right, 0))
											if next_collision == -1 or next_collision < 5 or next_collision > 8:
												stop_digging = true
									else:
										frames_digging = 0
										#5 a 7 son tiles destrozandose, 8 es el ultimo paso y -1 elimina la casilla
										if first_collision >= 5 and first_collision <= 7:
											first_collision = first_collision + 1
											map.set_cellv(celda, first_collision + 1)
										elif first_collision == 8:
											first_collision = -1
											#a�adir animaci�n de romper bloque
											map.set_cellv(celda, -1)
											if stop_digging == true:
												self.state = "Basic"
												stop_digging = false
						else:
							right = -right
	else:
		air_time += 1
		if (
			self.position.y > map.get_used_rect().end.y
			or self.position.x < map.get_used_rect().position.x
			or self.position.x > map.get_used_rect().end.x
			or self.position.y < map.get_used_rect().position.y
		):
			motion = Vector2()
			$AnimationPlayer.play("Death")


func digDown_meeseek():
	if alive:
		#bloque meeseek en el aire
		#si vuela durante m�s de 2 segundos aprox(5 bloques)
		if air_time > 120:
			alive = false
		if !is_on_floor():
			if !en_escalera:
				air_time += 1
				motion.x = 0
				motion.y = GRAVITY
				#para separar el cuerpor de las paredes al caer
				if once:
					self.position.x += right * 13
					once = false
				$Sprite.scale.x = right
				$AnimationPlayer.play("Fall")
			else:
				#once = false
				if get_slide_count() == 0:
					en_escalera = false
					motion.y = GRAVITY
					#once = false
		#bloque meeseek en el suelo
		else:
			#reset la separaci�n de la pared al tocar el suelo
			once = true
			en_escalera = false
			air_time = 0
			if !digging:
				$Sprite.scale.x = right
				$AnimationPlayer.play("Walking")
				motion.x = MAXSPEED *right
			for i in get_slide_count():
				var collision = get_slide_collision(i)
				if collision:
					celda = map.world_to_map(collision.position - collision.normal)
					print(map.get_cellv(celda))
					if collision.get_collider().get_class() == "StaticBody2D":
						self.get_parent().meeseek_saved()
						self.queue_free()  #borrado
					if collision.normal != Vector2(0,-1):
						#print(collision.get_collider().get_class())
						if collision.get_collider().get_class() == "TileMap":
							#si la celda es de una escalera
							if stair_tiles.has(map.get_cellv(celda)):
								en_escalera = true
								motion.y = collision.normal.y
							else:
								en_escalera = false
								#numero de frames que se excavan 60 = 1 segundo
								right = -right
						
					elif map.get_cellv(celda) >=5 and map.get_cellv(celda) <=9: 
						motion.x = 0
						digging = true;
						$AnimationPlayer.stop()
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
		air_time += 1
		if (
			self.position.y > map.get_used_rect().end.y
			or self.position.x < map.get_used_rect().position.x
			or self.position.x > map.get_used_rect().end.x
			or self.position.y < map.get_used_rect().position.y
		):
			motion = Vector2()
			$AnimationPlayer.play("Death")


func stopper_meeseek():
	if alive:
		#bloque meeseek en el aire
		#si vuela durante m�s de 2 segundos aprox(5 bloques)
		if air_time > 120:
			alive = false
		if !is_on_floor():
			if !en_escalera:
				air_time += 1
				motion.x = 0
				motion.y = GRAVITY
				#para separar el cuerpor de las paredes al caer
				if once:
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
		else:
			motion.x = 0
			self.set_collision_layer_bit(0, true)
	else:
		air_time += 1
		if (
			self.position.y > map.get_used_rect().end.y
			or self.position.x < map.get_used_rect().position.x
			or self.position.x > map.get_used_rect().end.x
			or self.position.y < map.get_used_rect().position.y
		):
			motion = Vector2()
			$AnimationPlayer.play("Death")


func umbrella_meeseek():
	if alive:
		#bloque meeseek en el aire
		#si vuela durante m�s de 2 segundos aprox(5 bloques)
		if !is_on_floor():
			if !en_escalera:
				air_time += 1
				motion.x = 0
				motion.y = GRAVITY/2
				#para separar el cuerpor de las paredes al caer
				if once:
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
			#ya ha estado en el aire
			if !once:
				self.state = "Basic"
			#reset la separaci�n de la pared al tocar el suelo
			once = true
			air_time = 0
			$Sprite.scale.x = right
			$AnimationPlayer.play("Walking")
			motion.x = MAXSPEED * right
			#comprueba las colisiones durante el movimiento,
			for i in get_slide_count():
				var collision = get_slide_collision(i)
				if collision:
					if collision.get_collider().get_class() == "StaticBody2D":
						self.get_parent().meeseek_saved()
						self.queue_free()  #borrado
						#sumar meeseek a contador de exito y borrarlo
					#si la colisi�n es diferente a la colisi�n frente al suelo, y frente a la direcci�n en la que avanzo
					if (
						collision.normal != Vector2(0, -1)
						and collision.normal == Vector2(-right, 0)
					):
						right = -right
	else:
		air_time += 1
		if (
			self.position.y > map.get_used_rect().end.y
			or self.position.x < map.get_used_rect().position.x
			or self.position.x > map.get_used_rect().end.x
			or self.position.y < map.get_used_rect().position.y
		):
			motion = Vector2()
			$AnimationPlayer.play("Death")


func stair_meeseek():
	pass


func climb_meeseek():
	if alive:
		if climbing:
			celda = map.world_to_map(self.position + Vector2(right * 65, 0))
			if map.get_cellv(celda) == -1:
				self.state = "Basic"
				self.position = self.position + Vector2(right * 32, -32)
				motion = Vector2(MAXSPEED * right, GRAVITY)
				climbing = false
		else:
			#bloque meeseek en el aire
			#si vuela durante m�s de 2 segundos aprox(5 bloques)
			if air_time > 120:
				alive = false
			if !is_on_floor():
				if !en_escalera:
					air_time += 1
					motion.x = 0
					motion.y = GRAVITY
					#para separar el cuerpor de las paredes al caer
					if once:
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
				air_time = 0
				$Sprite.scale.x = right
				$AnimationPlayer.play("Walking")
				motion.x = MAXSPEED * right
				#comprueba las colisiones durante el movimiento,
				for i in get_slide_count():
					var collision = get_slide_collision(i)
					if collision:
						if collision.get_collider().get_class() == "StaticBody2D":
							self.get_parent().meeseek_saved()
							self.queue_free()  #borrado
							#sumar meeseek a contador de exito y borrarlo
						#si la colisi�n es diferente a la colisi�n frente al suelo, y frente a la direcci�n en la que avanzo
						if (
							collision.normal != Vector2(0, -1)
							and collision.normal == Vector2(-right, 0)
						):
							if collision.get_collider().get_class() != "KinematicBody2D":
								motion.x = 0
								motion.y = -GRAVITY / 2
								climbing = true
							else:
								right = -right
	else:
		air_time += 1
		if (
			self.position.y > map.get_used_rect().end.y
			or self.position.x < map.get_used_rect().position.x
			or self.position.x > map.get_used_rect().end.x
			or self.position.y < map.get_used_rect().position.y
		):
			motion = Vector2()
			$AnimationPlayer.play("Death")


#a esta funci�n se llama desde la animaci�n Death para que el meeseek muera al terminar la animaci�n
func death():
	get_parent().meeseek_deceased()
	self.queue_free()


#dar actitud a un meesek al clickarle
var mouse_in := false


func _unhandled_input(event):
	if mouse_in:
		if (
			event is InputEventMouseButton
			and event.button_index == BUTTON_LEFT
			and event.is_pressed()
		):
			self.state = get_parent().mouse_pointer
			print(get_parent().mouse_pointer)
			get_tree().set_input_as_handled()


#funciones para controlar el clickar un solo meeseek a la vez (topmost order)
func _on_Meesek_mouse_entered():
	mouse_in = true


func _on_Meesek_mouse_exited():
	mouse_in = false

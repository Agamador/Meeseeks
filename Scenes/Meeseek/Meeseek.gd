extends KinematicBody2D
#las velocidades van en píxeles por segundo, 1 segundo = 60 frames
const DEADSPEED = 200
const MAXSPEED = 64
const GRAVITY = 150
var right = 1
var alive = true
var on_air := false
var once = true
var state := "Basic"
var collision
#dar actitud a un meesek al clickarle
var mouse_in := false

#escalera
#stair step = 8,10
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
#Stair
var building := false
var building_block := 0
var building_cell 
var building_frame := 0
#Climber
var climbing := false
#Se inicia el movimiento del misik en caida
var motion = Vector2(0, GRAVITY)

func _ready():
	#mapa
	map = get_parent().get_node("TileMap")
	$Timer.stop()

func _physics_process(delta):
	match state:
		"Basic":
			self.set_collision_layer_bit(0, false)
			normal_meeseek()
		"DigSide":
			self.set_collision_layer_bit(0, false)
			digSide_meeseek()
		"DigDown":
			self.set_collision_layer_bit(0, false)
			digDown_meeseek()
		"Stopper":
			stopper_meeseek()
		"Umbrella":
			self.set_collision_layer_bit(0, false)
			umbrella_meeseek()
		"Stair":
			self.set_collision_layer_bit(0, false)
			stair_meeseek()
		"Climb":
			self.set_collision_layer_bit(0, false)
			climb_meeseek()
		_:
			normal_meeseek()
	move_and_slide(motion, Vector2.UP,false,4,1.04)

func normal_meeseek():
	if outOfBounds():
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
			$Timer.stop()
			$Sprite.scale.x = right
			$AnimationPlayer.play("Walking")
			motion.x = MAXSPEED * right
			#comprueba las colisiones durante el movimiento,
			for i in get_slide_count():
				collision = get_slide_collision(i)
				if collision.get_collider().get_class() == "StaticBody2D":
						self.get_parent().meeseek_saved()
						self.queue_free()  #borrado
						###sumar meeseek a contador de exito y borrarlo
					#si la colisi�n es diferente a la colisi�n frente al suelo, y frente a la direcci�n en la que avanzo
				if abs(collision.normal.y) < 0.8:
					motion.y = collision.normal.y
				if collision.normal == Vector2(-right, 0):
					right = -right
	else:
		if is_on_floor() or outOfBounds():
			motion = Vector2()
			$AnimationPlayer.play("Death")
			
func digSide_meeseek():
	if outOfBounds():
		alive = false
	if alive:
		if digging:
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
					if collision.get_collider().get_class() == "StaticBody2D":
							self.get_parent().meeseek_saved()
							self.queue_free()  #borrado
							###sumar meeseek a contador de exito y borrarlo
					if abs(collision.normal.y) < 0.8:
						motion.y = collision.normal.y
						#si la colisi�n es diferente a la colisi�n frente al suelo, y frente a la direcci�n en la que avanzo
					if collision.normal == Vector2(-right, 0):
						celda = map.world_to_map(collision.position - collision.normal)
							#if first_collision != -1 and map.get_cellv(celda)
						if map.get_cellv(celda) >= 5 and map.get_cellv(celda) <= 12:
							digging = true
						elif map.get_cellv(celda) != -1 or collision.get_collider().get_class() == "KinematicBody2D":
							right = -right
	else:
		if is_on_floor() or outOfBounds():
			motion = Vector2()
			$AnimationPlayer.play("Death")
				
func digDown_meeseek():
	if outOfBounds():
		alive = false
	if alive:
		#bloque meeseek en el aire
		#si vuela durante m�s de 2 segundos aprox(5 bloques)
		if !is_on_floor():
			if !en_escalera:
				motion.x = 0
				motion.y = GRAVITY
				#para separar el cuerpor de las paredes al caer
				if once and !digging:
					self.position.x += right * 13
					once = false
					$Timer.start()
				$Sprite.scale.x = right
				$AnimationPlayer.play("Fall")
			else:
				if once and !digging:
					self.position.x += right * 13
					once = false
				$Sprite.scale.x = right
				$AnimationPlayer.play("Fall")
		#bloque meeseek en el suelo
		else:
			#reset la separaci�n de la pared al tocar el suelo
			once = true
			en_escalera = false
			$Timer.stop()
			if !digging:
				$Sprite.scale.x = right
				$AnimationPlayer.play("Walking")
				motion.x = MAXSPEED *right
			for i in get_slide_count():
				collision =get_slide_collision(i)
				if collision:
					celda = map.world_to_map(collision.position - collision.normal)
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
		if is_on_floor() or outOfBounds():
			motion = Vector2()
			$AnimationPlayer.play("Death")

func stopper_meeseek():
	if outOfBounds():
		alive = false
	if alive:
		#bloque meeseek en el aire
		#si vuela durante m�s de 2 segundos aprox(5 bloques)
		if !is_on_floor():
			if !en_escalera:
				motion.x = 0
				motion.y = GRAVITY
				#para separar el cuerpor de las paredes al caer
				if once:
					self.position.x += right * 13
					once = false
					$Timer.start()
				$Sprite.scale.x = right
				$AnimationPlayer.play("Fall")
			else:
				if get_slide_count() == 0:
					en_escalera = false
					motion.y = GRAVITY
		else:
			$Timer.stop()
			motion.x = 0
			self.set_collision_layer_bit(0, true)
	else:
		if is_on_floor() or outOfBounds():
			motion = Vector2()
			$AnimationPlayer.play("Death")

func umbrella_meeseek():
	if outOfBounds():
		alive = false
	if alive:
		#bloque meeseek en el aire
		#si vuela durante m�s de 2 segundos aprox(5 bloques)
		if !is_on_floor():
			if !en_escalera:
				$Timer.stop()
				motion.x = 0
				motion.y = GRAVITY/2
				#para separar el cuerpor de las paredes al caer
				if once:
					self.position.x += right * 13
					once = false
				$Sprite.scale.x = right
				$AnimationPlayer.play("Fall")
		#bloque meeseek en el suelo
		else:
			#ya ha estado en el aire
			if !once:
				self.state = "Basic"
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
		if is_on_floor() or outOfBounds():
			motion = Vector2()
			$AnimationPlayer.play("Death")

func stair_meeseek():
	if outOfBounds():
		alive = false
	if alive:
		if building:
			if right > 0:
				if building_block == 0:
					building_block = 12
				if  building_frame > 60:
					building_frame = 0 
					building_block += 1
					if building_block <= 19 :
						map.set_cellv(building_cell, building_block)
						self.position.x += 8 * right;
						self.position.y -= 10;
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
						self.position.y -= 10;
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
					if collision.get_collider().get_class() == "StaticBody2D":
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
								#printt(building_cell, self.position.x, building_cell.x *64,self.position.x - building_cell.x * 64 )
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
	else:
		if is_on_floor() or outOfBounds():
			motion = Vector2()
			$AnimationPlayer.play("Death")	

func climb_meeseek():
	if outOfBounds():
		alive = false
	if alive:
		if climbing:
			if is_on_ceiling():
				climbing = false
				self.state = 'Basic'
				self.position.x -= right * 20
			celda = map.world_to_map(self.position + Vector2(right * 65, 0))
			if map.get_cellv(celda) == -1:
				self.state = "Basic"
				self.position = self.position + Vector2(right * 32, -32)
				motion = Vector2(MAXSPEED * right, GRAVITY)
				climbing = false
		else:
			#bloque meeseek en el aire
			#si vuela durante m�s de 2 segundos aprox(5 bloques)
			if !is_on_floor():
				if !en_escalera:
					
					motion.x = 0
					motion.y = GRAVITY
					#para separar el cuerpor de las paredes al caer
					if once:
						self.position.x += right * 13
						once = false
						$Timer.start()
					$Sprite.scale.x = right
					$AnimationPlayer.play("Fall")
				else:
					once = false
					if get_slide_count() == 0:
						en_escalera = false
						motion.y = GRAVITY
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
		if is_on_floor() or outOfBounds():
			motion = Vector2()
			$AnimationPlayer.play("Death")

#a esta funci�n se llama desde la animaci�n Death para que el meeseek muera al terminar la animaci�n
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
							get_parent().updateButtonsValues()
							get_tree().set_input_as_handled()
					"DigDown":
						if get_parent().Digdowners >= 1:
							self.state = get_parent().mouse_pointer
							get_parent().Digdowners -= 1
							get_parent().updateButtonsValues()
							get_tree().set_input_as_handled()
					"Stopper":
						if get_parent().Stopperers >= 1:
							self.state = get_parent().mouse_pointer
							get_parent().Stopperers -= 1
							get_parent().updateButtonsValues()
							get_tree().set_input_as_handled()
					"Umbrella":
						if get_parent(). Umbrellaers >= 1:
							self.state = get_parent().mouse_pointer
							get_parent(). Umbrellaers -= 1
							get_parent().updateButtonsValues()
							get_tree().set_input_as_handled()
					"Stair":
						if get_parent().Stairers >= 1:
							self.state = get_parent().mouse_pointer
							get_parent().Stairers -= 1
							get_parent().updateButtonsValues()
							get_tree().set_input_as_handled()
					"Climb":
						if get_parent().Climbers >= 1:
							self.state = get_parent().mouse_pointer
							get_parent().Climbers -= 1
							get_parent().updateButtonsValues()
							get_tree().set_input_as_handled()
#funciones para controlar el clickar un solo meeseek a la vez (topmost order)
func _on_Meesek_mouse_entered():
	mouse_in = true
	Input.set_custom_mouse_cursor(get_parent().selector,0,Vector2(32,32))
	
func _on_Meesek_mouse_exited():
	mouse_in = false
	Input.set_custom_mouse_cursor(get_parent().arrow,0,Vector2(0,0))

func outOfBounds():
	return (self.position.y > map.get_used_rect().end.y * 64
		or self.position.x < map.get_used_rect().position.x * 64
		or self.position.x > map.get_used_rect().end.x * 64
		or self.position.y < map.get_used_rect().position.y * 64)
	
func _on_Timer_timeout():
	self.alive = false # Replace with function body.

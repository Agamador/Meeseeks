extends KinematicBody2D

const DEADSPEED = 200
const MAXSPEED = 60
const GRAVITY = 150
var right = 1
var alive = true
var air_time = 0
var once = true
var state := 'basic'
#mapa
var celda
var map
#digger
var first_collision := -1
var frames_digging	:= 0
#Se inicia el movimiento del misik en caida
var motion = Vector2(0,GRAVITY)

func _ready():
	#mapa
	map = get_parent().get_node('TileMap')


func _physics_process(delta):
	match state:
		'Basic': normal_meeseek(); 
		'DigSide': digSide_meeseek()
		'DigDown': pass
		'Stopper': pass
		'Umbrella': pass
		'Stair': pass
		'Climb': pass
		_: normal_meeseek()
	move_and_slide(motion, Vector2.UP)

func normal_meeseek():
	if(alive):
		#bloque meeseek en el aire
		#si vuela durante más de 2 segundos aprox(5 bloques)
		if air_time > 120: 
			alive = false;
		if !is_on_floor():	
			air_time += 1
			motion.x = 0
			#para separar el cuerpor de las paredes al caer
			if once:
				if right > 0:
					self.position.x += 13
				else: 
					self.position.x -= 13
				once = false
			$Sprite.scale.x = right
			$AnimationPlayer.play("Fall")
		#bloque meeseek en el suelo
		else:
			#reset la separación de la pared al tocar el suelo
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
						self.get_parent().meeseek_saved();
						self.queue_free(); #borrado
						#sumar meeseek a contador de exito y borrarlo
					#si la colisión es diferente a la colisión frente al suelo, y frente a la dirección en la que avanzo
					if collision.normal != Vector2(0,-1) and collision.normal == Vector2(-right,0):
						right = -right
	else:
		air_time += 1;
		if is_on_floor() or air_time > 600:
			motion = Vector2();
			$AnimationPlayer.play("Death")

#selfxplaining
func digSide_meeseek():
	if(alive):
		#bloque meeseek en el aire
		#si vuela durante más de 2 segundos aprox(5 bloques)
		if air_time > 120: 
			alive = false;
		if !is_on_floor():	
			air_time += 1
			motion.x = 0
			#para separar el cuerpor de las paredes al caer
			if once:
				if right > 0:
					self.position.x += 13
				else: 
					self.position.x -= 13
				once = false
			$Sprite.scale.x = right
			$AnimationPlayer.play("Fall")
		#bloque meeseek en el suelo
		else:
			#reset la separación de la pared al tocar el suelo
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
						self.get_parent().meeseek_saved();
						self.queue_free(); #borrado
						#sumar meeseek a contador de exito y borrarlo
					#si la colisión es diferente a la colisión frente al suelo, y frente a la dirección en la que avanzo
					if collision.normal != Vector2(0,-1) and collision.normal == Vector2(-right,0):
						celda = map.world_to_map(collision.position - collision.normal)
						#print(map.get_cellv(celda))
						#if first_collision != -1 and map.get_cellv(celda)
						motion.x = 0
						##inicia animación excavar
						
						
						#numero de frames que se excavan 60 = 1 segundo
						if frames_digging < 30:
							frames_digging += 1
							if first_collision == -1:
								first_collision = map.get_cellv(celda)
						else:
							frames_digging = 0 
							#5 a 7 son tiles destrozandose, 8 es el ultimo paso y -1 elimina la casilla
							if first_collision >= 5 and first_collision <= 7:
								first_collision = first_collision + 1
								map.set_cellv(celda, first_collision+1)
							elif first_collision == 8:
								first_collision = -1
								#añadir animación de romper bloque
								map.set_cellv(celda, -1)
								
	else:
		air_time += 1;
		if is_on_floor() or air_time > 600:
			motion = Vector2();
			$AnimationPlayer.play("Death")
			
func digDown_meeseek():
	if(alive):
		#bloque meeseek en el aire
		#si vuela durante más de 2 segundos aprox(5 bloques)
		if air_time > 120: 
			alive = false;
		if !is_on_floor():	
			air_time += 1
			motion.x = 0
			#para separar el cuerpor de las paredes al caer
			if once:
				if right > 0:
					self.position.x += 13
				else: 
					self.position.x -= 13
				once = false
			$Sprite.scale.x = right
			$AnimationPlayer.play("Fall")
		#bloque meeseek en el suelo
		else:
			#reset la separación de la pared al tocar el suelo
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
						self.get_parent().meeseek_saved();
						self.queue_free(); #borrado
						#sumar meeseek a contador de exito y borrarlo
					#si la colisión es diferente a la colisión frente al suelo, y frente a la dirección en la que avanzo
					if collision.normal != Vector2(0,-1) and collision.normal == Vector2(-right,0):
						celda = map.world_to_map(collision.position - collision.normal)
						#print(map.get_cellv(celda))
						#if first_collision != -1 and map.get_cellv(celda)
						motion.x = 0
						##inicia animación excavar
						
						
						#numero de frames que se excavan 60 = 1 segundo
						if frames_digging < 30:
							frames_digging += 1
							if first_collision == -1:
								first_collision = map.get_cellv(celda)
						else:
							frames_digging = 0 
							#5 a 7 son tiles destrozandose, 8 es el ultimo paso y -1 elimina la casilla
							if first_collision >= 5 and first_collision <= 7:
								first_collision = first_collision + 1
								map.set_cellv(celda, first_collision+1)
							elif first_collision == 8:
								first_collision = -1
								#añadir animación de romper bloque
								map.set_cellv(celda, -1)
								
	else:
		air_time += 1;
		if is_on_floor() or air_time > 600:
			motion = Vector2();
			$AnimationPlayer.play("Death")
			
func stopper_meeseek():
	pass
func umbrella_meeseek():
	pass
func stair_meeseek():
	pass
func climb_meeseek():
	pass
	
#a esta función se llama desde la animación Death para que el meeseek muera al terminar la animación
func death(): 
	get_parent().meeseek_deceased();
	self.queue_free()

#dar actitud a un meesek al clickarle
var mouse_in := true
func _unhandled_input(event):
	if mouse_in: 
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
			self.state = get_parent().mouse_pointer
			print(get_parent().mouse_pointer)
			get_tree().set_input_as_handled()

func _on_Meesek_mouse_entered():
	mouse_in = true


func _on_Meesek_mouse_exited():
	mouse_in = false

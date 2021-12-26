extends KinematicBody2D

const DEADSPEED = 200
const MAXSPEED = 60
const GRAVITY = 150
var right = 1
var alive = true
var air_time = 0
var once = true
#Se inicia el movimiento del misik en caida
var motion = Vector2(0,GRAVITY)

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	#print($RayCast2D)
	if(alive):
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
					#si la colisión es diferente a la colisión frente al suelo, y frente a la dirección en la que avanzo
					if collision.normal != Vector2(0,-1) and collision.normal == Vector2(-right,0):
						right = -right
	else:
		air_time += 1;
		if is_on_floor() or air_time > 600:
			motion = Vector2();
			$AnimationPlayer.play("Death")
	move_and_slide(motion, Vector2.UP)

#a esta función se llama desde la animación Death
func death(): 
	self.queue_free()

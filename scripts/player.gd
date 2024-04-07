extends CharacterBody3D

@onready var camera = $Camera3D as Camera3D
func _enter_tree():
	set_multiplayer_authority(name.to_int())

var SPEED = 15.0
const JUMP_VELOCITY = 10
const SENSITIVITY = 0.004

var current_animation = null
var current_state = null

var is_sprinting = false
var is_jumping = false


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$S_Intro.play()
	if is_multiplayer_authority():
		camera.make_current()

func _physics_process(delta):
	if is_multiplayer_authority():
		if position.y < -10:
			position = Vector3(0, 0, 0)
		
		is_jumping = false
		
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta

		# FOV & sprint
		if is_on_floor():
			if Input.is_action_pressed("sprint"):
				is_sprinting = true
				SPEED = 25.0
			if Input.is_action_just_released("sprint"):
				is_sprinting = false
				SPEED = 15.0

		if Input.is_action_just_pressed("saut") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			current_state = "Jump_Start"
			$S_Cri_Saut.play()
			is_jumping = true

		if is_sprinting == true:
			if $Camera3D.fov + 1 <= 100:
				$Camera3D.fov += 1
		else:
			if $Camera3D.fov - 1 >= 75:
				$Camera3D.fov -= 1


		var input_dir = Input.get_vector("gauche", "droite", "avant", "arriere")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		

		if input_dir.x == 0 && input_dir.y == 0:
			$S_Course_Graviers.stop()
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			if is_on_floor() && is_jumping == false:
				current_state = "Idle"
		else:
			# Animation Course (on floor)
			if is_on_floor() && is_jumping == false:
				if $S_Course_Graviers.playing == false:
					$S_Course_Graviers.play()
				if input_dir.y < 0:
					$Rig.rotation.y = deg_to_rad(180)
					if input_dir.x < 0:
						current_state = "Running_Strafe_Left"
					elif input_dir.x > 0:
						current_state = "Running_Strafe_Right"
					else:
						if is_sprinting == false:
							current_state = "Running_B"
						else:
							current_state = "Running_A"
				elif input_dir.y > 0:
					$Rig.rotation.y = deg_to_rad(0)
					if input_dir.x < 0:
						current_state = "Running_Strafe_Right"
					elif input_dir.x > 0:
						current_state = "Running_Strafe_Left"
					else:
						if is_sprinting == false:
							current_state = "Running_B"
						else:
							current_state = "Running_A"
				else:
					if input_dir.x < 0:
						$Rig.rotation.y = deg_to_rad(-90)
						if is_sprinting == false:
							current_state = "Running_B"
						else:
							current_state = "Running_A"
					elif input_dir.x > 0:
						$Rig.rotation.y = deg_to_rad(90)
						if is_sprinting == false:
							current_state = "Running_B"
						else:
							current_state = "Running_A"
					else:
						pass
			else:
				$S_Course_Graviers.stop()
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED


		if current_animation != current_state:
			current_animation = current_state
			$AnimationPlayer.play(current_animation)

	move_and_slide()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		$Camera3D.rotate_x(-event.relative.y * SENSITIVITY)
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x, deg_to_rad(-75), deg_to_rad(60))



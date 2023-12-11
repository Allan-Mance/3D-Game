extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = .001
var health = 5

var can_drop = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		$Pivot.rotate_x(-event.relative.y*MOUSE_SENSITIVITY)
		$Pivot.rotation.x = clamp($Pivot.rotation.x, -.5, 0.25)
		rotate_y(-event.relative.x*MOUSE_SENSITIVITY)
	if event.is_action_pressed("pickup") and can_drop:
		for w in $Pivot/Weapon.get_children():
			if w.has_method("drop"):
				w.drop()


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("shoot"):
		var weapons = $Pivot/Weapon
		for w in weapons.get_children():
			if w.has_method("shoot"):
				w.shoot()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	
func pickup(weapon):
	can_drop = false
	$Pickup_Timer.start()
	$Pivot/Weapon.add_child(weapon)


func _on_pickup_timer_timeout():
	can_drop = true



func damage():
	health -= 1
	if health <= 0:
		get_tree().change_scene_to_file("res://UI/end_game.tscn")


func _on_button_pressed():
	pass # Replace with function body.

extends Car

onready var camera = $Camera2D


func _ready():
	camera.set_as_toplevel(true)

func physics_process(delta):
	camera.global_position = global_position
	camera.rotation = lerp_angle(camera.rotation, rotation + deg2rad(90), 0.1)
	
func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func control():
	if Input.is_action_pressed("left"):
		current_steering_angle = lerp_angle(current_steering_angle, deg2rad(-max_steering_angle), steering_speed)
	elif Input.is_action_pressed("right"):
		current_steering_angle = lerp_angle(current_steering_angle, deg2rad(max_steering_angle), steering_speed)
	else:
		current_steering_angle = lerp_angle(current_steering_angle, 0, 0.1)
	
	var target_acc = Vector2()
	if Input.is_action_pressed("accelerate"):
		current_acc = lerp(current_acc, max_acc, 0.05) # switching gears
		target_acc = transform.x * current_acc
	elif Input.is_action_pressed("back"):
		target_acc = transform.x * reverse_acc
		current_acc = 0 # If Im breaking, engine is turned off
	else:
		current_acc = lerp(current_acc, 0, 0.001) # if ive released accelerate, engine is slowing down but doesnt stop immediately
	acc = target_acc
	

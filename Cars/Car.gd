extends KinematicBody2D

class_name Car

var wheel_base = 60 # distance between front and back wheel

export var max_steering_angle = 10 # how far the front wheel turns
export var steering_speed = 0.1
var current_steering_angle = 0.0 # gradually lerps into max steering angle at steering speed

export var max_acc = 1200
var current_acc = 0.0
export var reverse_acc = -450
export var max_speed_reverse = 250
# friction is against the ground(sand/ice)
export var friction = -0.2
# drag is wind resistance, based on crossection of the car
# friction is based on your velocity, drag is based on square of your velocity
# at a slow speed friction is more significant, at a high speed drag is more significant
export var drag = -0.001



export var drift_speed = 800 # above this speed you start sliding
export var drift_angle = 9 # turn angle between frames
var drift_timer = 0.5
export var traction_fast = 0.001 # how slippery it is when you're above that speed
export var traction_slow = 0.995 # below slip speed. at 1.0 it would change velocity instantly
onready var current_traction = traction_slow
var drifting = false
var prev_heading = Vector2()
var new_heading = Vector2()

var acc = Vector2()
var vel = Vector2()

onready var trail1 = $TrailPos1/Trail
onready var trail2 = $TrailPos2/Trail
onready var trail3 = $TrailPos3/Trail
onready var trail4 = $TrailPos4/Trail
onready var trails = [trail1,trail2,trail3,trail4]


func _physics_process(delta):
	acc = Vector2()
	control()
	drift(delta)
	calculate_steering(delta)
	collide(delta)
	
	apply_friction()
		
	vel += acc * delta
	physics_process(delta)

func collide(delta):
	var collision = move_and_collide(vel*delta)
	if collision:
		vel = vel.slide(collision.normal) # .linear_interpolate(vel.bounce(collision.normal), 0.1)
		rotation = lerp_angle(rotation, vel.angle(), 0.1)
		

func apply_friction():
	# stop if i'm really slow
	if vel.length() < 5: vel = Vector2()
	# Force in the opposite direction of velocity
	var friction_force = vel * friction
	# Velocity squared multiplied by drag
	var drag_force = vel * vel.length()  * drag
	# Add the friction/drag vectors to slow down
	acc += friction_force + drag_force
	
func drift(delta):
	#var steering_angle = abs(rad2deg(prev_heading.angle_to(new_heading)))
	#print(steering_angle)
	# When the car goes above a certain speed it'll have less traction and drift more
	if vel.length() > drift_speed and abs(rad2deg(current_steering_angle)) > drift_angle: 
		drifting = true
		drift_timer = 0.5
	# When speed/angle are just on the threshold, drifting annoyingly oscillates on and off
	# Instead of toggling it based on speed, I turn it on when the speed has crossed a threshold,
	# And then turn it off after awhile
	drift_timer -= delta
	if drift_timer <= 0:
		drifting = false
		
	if drifting:
		current_traction = lerp(current_traction, traction_fast, 0.1)
		for trail in trails:
			trail.leave_tracks = true
	else:
		current_traction = lerp(current_traction, traction_slow, 0.01) 
		for trail in trails:
			trail.leave_tracks = false


func calculate_steering(delta):
	# locations of wheels
	var rear_wheel = position - transform.x * wheel_base/2
	var front_wheel = position + transform.x * wheel_base/2
	rear_wheel += vel * delta 	# back wheel goes forward by velocity
	front_wheel += vel.rotated(current_steering_angle) * delta # front wheel goes forward in the direction where steering is turning
	new_heading = (front_wheel - rear_wheel).normalized() # vector pointing in new direction
	rotation = new_heading.angle()

	var is_moving_forward = new_heading.dot(vel.normalized()) > -0.5
	if is_moving_forward: 
		var target_vel = new_heading * vel.length()  # rotate velocity in the new direction, maintain it's speed
		vel = vel.linear_interpolate(target_vel, current_traction)
	else:
		vel = -new_heading * min(vel.length(), max_speed_reverse)  # can't go faster than reverse speed


	
func physics_process(delta):
	pass
func control():
	pass # defined in inherited scenes. Enemy.gd or Player.gd
	

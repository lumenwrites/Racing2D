extends Car


func _ready():
	traction_fast = 1
	traction_slow = 1
	
func control(): # follow path
	# Todo:
	# - instead of deleting them, loop through them, so you can do several loops
	# - randomize position, add a bit of randomness to target(only once not every frame)
	var navnodes = $"../NavNodes".get_children()
	# print(navnodes)
	if navnodes.size() > 0:
		var target = navnodes[0].position
		if (target - position).length() > 150:
			steer_to_target(target)
			accelerate_to_target(target)
		else:
			navnodes[0].queue_free()
	else:
		acc = Vector2.ZERO
		vel *= 0.9 # slow down	
		
func steer_to_target(target):	
	# Vector pointing to target
	var vector_to_target = position.direction_to(target)
	var turn = 0
	# transform.y points to the right of the car
	# if it's pointing roughly in the direction of the target - turn right
	# if it's pointing roughly in the opposite direction - turn left
	# if they're roughly perpendicular(dot product is near 0), don't turn
	# todo: this would break if car is pointing in the opposite direction of where I want to steer
	if transform.y.dot(vector_to_target) > 0.5:
		turn = 1
	if transform.y.dot(vector_to_target) < -0.5:
		turn = -1
	$arrow_gold.rotation = turn * deg2rad(steering_angle)
	steer_direction  = turn * deg2rad(steering_angle)
	
func accelerate_to_target(target):
	if (target-position).length() > 150:
		acc = transform.x * engine_power
	else:
		acc = Vector2.ZERO
		vel *= 0.9 # slow down

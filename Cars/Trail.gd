extends Line2D

var point

var leave_tracks = true

func _ready():
	set_as_toplevel(true)

func _physics_process(delta):
	if leave_tracks:
		point = get_parent().global_position
		add_point(point)
		if points.size() > 200:
			remove_point(0)
	else:
		if points.size():
			remove_point(0)
#		else:
#			queue_free()

extends StaticBody3D
var j =0
# Called when the node enters the scene tree for the first time.
var calculated_position_x  =0
var calculated_position_z  =0
var is_disabled =false
var init_position
var  gl = 0
func set_collision_disabled(disabled: bool):
# Iterate through all child nodes of this StaticBody3D
	for i in get_child_count():
		var child = get_child(i)
# Check if the child is a CollisionShape3D
		if child is CollisionShape3D:
			child.disabled = disabled
	if disabled:
		print_rich("Traffic light collision [color=orange]disabled[/color].")
	else:
		print_rich("Traffic light collision [color=cyan]enabled[/color].")
func _on_timer_timeout():
	set_collision_disabled(true)
func enable_collision():
	set_collision_disabled(false)
func disable_collision():
	set_collision_disabled(true)
func _process(delta):
	j +=1
	
	var turn = 0
	if j == 1:
		init_position = self.global_position
	calculated_position_x = init_position.x * 0.707 + -init_position.z * 0.707
	calculated_position_z = init_position.x* 0.707 + init_position.z* 0.707
	
	if calculated_position_x <0 && calculated_position_z >0:

		gl = 6
	if calculated_position_x >0 && calculated_position_z <0:

		gl =18
	if calculated_position_x <0 && calculated_position_z <0:

		gl = 12
	if calculated_position_x >0 && calculated_position_z >0:

		gl = 24
	var sec = delta *j
	print("gl", gl)

	if sec > 20 && is_disabled == false:
		j=0
		set_collision_disabled(true)
		is_disabled = true
	elif sec <= 26-gl and sec > gl && is_disabled == true:
		set_collision_disabled(false)
		j=0
		is_disabled = false
		

# Called every frame. 'delta' is the elapsed time since the previous frame.


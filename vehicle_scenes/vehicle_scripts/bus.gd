extends CharacterBody3D
@onready var check_front: Area3D = $check_front
@onready var dodge_box: Area3D = $dodge_box
@onready var left_box: Area3D = $left_box
@onready var right_box: Area3D = $right_box
@onready var brake_box: Area3D = $brake_box
@onready var willhit_box: Area3D = $willhit_box
var rng = RandomNumberGenerator.new()

var _previous_colliders = []
var gravity = -20.0
var wheel_base = 0.4  # distance between front/rear axles
var steering_limit =4.0  # front wheel max turning angle (deg)
var engine_power = 51.0
var braking1 = -1.0
var braking2 = -25.0
var braking3 = -75.0
var friction = -2.0
var drag = -2.0
var max_speed_reverse = 3.0
var slip_speed = 9.0
var traction_slow = 0.9
var traction_fast = 0.05
var direction = 1
var where_to = 1
var death_count = 0
#direction: 1n, 2e, 3s, 4w
var is_turning = false
var get_turn = 0
var drifting = false
var has_red_stop = false
var is_broken = false
# Car state properties
var acceleration = Vector3.ZERO  # current acceleration
var braking = false
var steer_angle = 0.0
var traffic_stop = false
var time_turning = 0
var j = -2
var init_position = self.global_position
var calculated_position_x = 0
var calculated_position_z = 0
var opposite_direction = 0
# New variables for slow/reverse detection
var slow_speed_threshold = 1.5  # Speed below which car is considered slow
var reverse_speed_threshold = -0.5  # Negative speed indicating reverse
var slow_movement_timer = 0.0
var slow_movement_timeout = 2.0  # Time in seconds before stopping due to slow movement

func choose_new_direction():
	var all_directions = [1, 2, 3, 4]
	
	match direction:
		1: 
			opposite_direction =3  # North → opposite is South
		2: 
			opposite_direction =4  # East → opposite is West
		3: 
			opposite_direction =1  # South → opposite is North
		4: 
			opposite_direction =2  # West → opposite is East
		_: 
			opposite_direction =-1  # default fallback
	all_directions.erase(opposite_direction)  # remove the reverse option
	where_to = all_directions[randi() % all_directions.size()]  # pick random valid direction

func get_input():
	braking = false

	#var turn = Input.get_action_strength("ui_left")
	#turn -= Input.get_action_strength("ui_right")
	j +=1
	var turn = 0
	if j == 1:
		init_position = self.global_position
		choose_new_direction()
		print("AAAAAAAAAA",where_to)
	calculated_position_x = init_position.x * 0.707 + -init_position.z * 0.707
	calculated_position_z = init_position.x* 0.707 + init_position.z* 0.707
	print(velocity)
	print(calculated_position_x,"and",calculated_position_z)
	if calculated_position_x <0 && calculated_position_z >0:
		direction = 1 
	if calculated_position_x >0 && calculated_position_z <0:
		direction = 3 
	if calculated_position_x <0 && calculated_position_z <0:
		direction = 2
	if calculated_position_x >0 && calculated_position_z >0:
		direction = 4
	print(direction)
	var is_dodging = 0
	var right_safe = true
	var left_safe = true
	var mi = 0
	var front_detect = check_front.get_overlapping_bodies()
	var shock_detect = brake_box.get_overlapping_bodies()
	var dodge_detect = dodge_box.get_overlapping_bodies()
	var right_detect =right_box.get_overlapping_bodies()
	var left_detect =left_box.get_overlapping_bodies()
	var willhit_detect = willhit_box.get_overlapping_bodies()
	mi = sqrt(acceleration.x**2 + acceleration.z**2)
	var de = acceleration.x
	var sin = de/mi
	for body in right_detect:
		right_safe = false
		
	for body in left_detect:
		left_safe = false
	for body in dodge_detect:
		steering_limit=4 
		if right_safe == true:
			turn = -1
		elif left_safe ==true :
			turn = 1
		else:
			acceleration = -transform.basis.z * braking2
			braking = true
		is_dodging =1
	if sin <0.342 && abs(velocity.z) >5 && (direction == 1 or direction==3):
		is_turning = false
	if abs(sin) >0.658 && abs(velocity.x) >5 && (direction == 2 or direction==4):
		is_turning = false

	if direction == 1 && velocity.z>-1:
		steering_limit = 8
		is_turning = true
		get_turn = turn
	if direction == 2 && velocity.x<1:
		steering_limit = 8
		is_turning = true
		get_turn = turn
	if direction == 3 && velocity.z<1:
		steering_limit = 8
		is_turning = true
		get_turn = turn
	if direction == 4 && velocity.x>-1:
		steering_limit = 8
		is_turning = true
		get_turn = turn
		#if sin <0.342:
			#is_turning = false


	if velocity.x <0.2 && is_dodging == 0:
		if direction ==1:
			turn = -1
		if direction ==3:
			turn = 1
		if is_turning == false:
			steering_limit -= 0.01
	if velocity.z<0.2 && is_dodging ==0:
		if direction ==2:
			turn = -1
		if direction ==4:

			turn = 1
		if is_turning == false:
			steering_limit-=0.01
	if velocity.x >-0.2 && is_dodging == 0 :
		if direction ==1:
			turn = 1 
		if direction ==3:   
			turn = -1
		if is_turning == false:
			steering_limit -= 0.01
	if velocity.z>-0.2 && is_dodging ==0:
		if direction ==2:
			turn = 1
		if direction ==4:

			turn = -1
		if is_turning == false:
			steering_limit-=0.01
	if steering_limit <= 0:
		steering_limit = 0.1
	#if abs(velocity.x) <0.1:
		#if is_turning == false:
			#steering_limit = 4




	steer_angle = turn * deg_to_rad(steering_limit)
	
	var current_colliders = []
	var collision_changed_this_frame: bool = false
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision: # Ensure collision data exists
			var collider_object = collision.get_collider()
			if collider_object: # Ensure the collider object itself exists
				current_colliders.append(collider_object)

	for collider in current_colliders:
		if not _previous_colliders.has(collider):

			collision_changed_this_frame = true
			if collider.name == "traffic_light":
				traffic_stop = true


	# 2. Check for ended collisions (Collision Exited)
	for old_collider in _previous_colliders:
		if not current_colliders.has(old_collider):

			collision_changed_this_frame = true
			acceleration = -transform.basis.z * engine_power
			if old_collider.name == "traffic_light":
				traffic_stop = false
				has_red_stop = true
	acceleration = -transform.basis.z * engine_power
	for body in front_detect:
		if body != self:
			acceleration = -transform.basis.z * braking1
			braking = true
	for body in shock_detect:
		
		if body != self:
			acceleration = -transform.basis.z * braking2
			braking = true
	for body in willhit_detect:
		if body != self:
			is_broken = true
		
	
	

	if traffic_stop == true:
		acceleration = -transform.basis.z * braking2
		braking = true


		
	# --- Update previous colliders for the next frame ---
	_previous_colliders = current_colliders
	steer_angle = turn * deg_to_rad(steering_limit)


func apply_friction(delta):
	# Check for slow/reverse movement first

# Exit early if car was stopped due to slow/reverse movement
	if direction != 1  &&  is_turning == true:
		death_count -= 300
	if is_turning == false:
		death_count +=2
		
		if braking == true:
			death_count-=1
		if braking==true && traffic_stop == true:
			death_count = 0
		if death_count > 1200:
			if get_parent() != null:
				get_parent().remove_child(self)
			death_count =0
		if velocity.length() < 3 and traffic_stop == false:
			acceleration = -transform.basis.z * 0.00000001
			velocity = Vector3.ZERO
			
			if death_count > 200:
				if get_parent() != null:
					get_parent().remove_child(self)
				death_count =0
			if is_broken == true or death_count >600:
				death_count +=2
			if get_parent() != null:
				if is_broken== true :
					get_parent().remove_child(self)
			
				death_count =0
		if (abs(velocity.x)<0.2) &&(direction ==1 or direction ==3):
			velocity.x =0
		if (abs(velocity.z)<0.2) &&(direction ==2 or direction ==4):
			velocity.z =0
	
	
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force
	if has_red_stop ==true:
		time_turning +=1
		#if time_turning >10:
			#direction = where_to

func calculate_steering(delta):
	var rear_wheel = transform.origin + transform.basis.z * wheel_base / 2.0
	var front_wheel = transform.origin - transform.basis.z * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(transform.basis.y, steer_angle) * delta
	var new_heading = rear_wheel.direction_to(front_wheel)
	if not drifting and velocity.length() > slip_speed and Input.is_action_pressed("ui_select"):
		drifting = true
	if drifting and velocity.length() < slip_speed and steer_angle == 0:
		drifting = false
	var traction = traction_fast if drifting else traction_slow
	velocity = lerp(velocity, new_heading * velocity.length(), traction)

	look_at(transform.origin + new_heading, transform.basis.y)
func _physics_process(delta):
	if is_on_floor():
		get_input()
		apply_friction(delta)
		calculate_steering(delta)
	acceleration.y = gravity
	velocity += acceleration * delta
	floor_snap_length
	move_and_slide()

	#earruhgos;fjnkvzcm,kjwohu;rsgfjznldv

		#if collision.length() >=1:
			#gravity = 0


extends Node3D


const bus = preload("res://vehicle_scenes/bus.tscn")
const f1 = preload("res://vehicle_scenes/f_1.tscn")
const motorbike = preload("res://vehicle_scenes/motorbike.tscn")
const suv = preload("res://vehicle_scenes/suv.tscn")
const truck = preload("res://vehicle_scenes/truck.tscn")
var i = 0
var rng = RandomNumberGenerator.new()

	
func _on_spawn_timer_timeout():
	var newVehicle 
	var my_random_number = rng.randi_range(1, 20)
	var my_random_numberz = 0
	print(my_random_number)
	print("SPawn!")
	if my_random_number >0 && my_random_number<=1:
		newVehicle = bus.instantiate()
	if my_random_number >1 && my_random_number<=3:
		newVehicle = truck.instantiate()
	if my_random_number >3 && my_random_number<=10:
		newVehicle = suv.instantiate()
	if my_random_number >10 && my_random_number<=19:
		newVehicle = motorbike.instantiate()
	if my_random_number >19:
		newVehicle = f1.instantiate()
	get_parent().add_child(newVehicle)
	newVehicle.global_position = global_position
func _process(delta):
	i +=1
	if i >300:
		i = 0
		_on_spawn_timer_timeout()

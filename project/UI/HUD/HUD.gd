extends Control

onready var shield_bar := $ShieldBar
onready var cargo_gauge := $CargoGauge
onready var laser_gun := $"/root/GameInitializer/GameWorld/StationSpawner/PlayerShip/LaserGun"

var is_laser := false

func initialize(player: PlayerShip) -> void:
	shield_bar.initialize(player)
	cargo_gauge.initialize(player)
	
func _on_FireButton_pressed():
	var a = InputEventAction.new()
	if laser_gun.has_energe():
		a.action = "fire2"
		is_laser = true
	else :
		a.action = "fire"
		is_laser = false
	a.pressed = true
	Input.parse_input_event(a)

func _on_DockButton_pressed():
	var a = InputEventAction.new()
	a.action = "toggle_dock"
	a.pressed = true
	Input.parse_input_event(a)

func _on_MapButton_pressed():
	var a = InputEventAction.new()
	a.action = "toggle_map"
	a.pressed = true
	Input.parse_input_event(a)

func _on_FireButton_released():
	var a = InputEventAction.new()
	if is_laser:
		a.action = "fire2"
	else:
		a.action = "fire"
	a.pressed = false
	Input.parse_input_event(a)


func _on_joystickRight_pressed():
	_on_FireButton_pressed()


func _on_joystickRight_released():
	_on_FireButton_released()

extends Control

onready var shield_bar := $ShieldBar
onready var cargo_gauge := $CargoGauge


func initialize(player: PlayerShip) -> void:
	shield_bar.initialize(player)
	cargo_gauge.initialize(player)
	
func _ready():
	Events.joystick = $Joystick


func _on_FireButton_pressed():
	var a = InputEventAction.new()
	a.action = "fire"
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
	a.action = "fire"
	a.pressed = false
	Input.parse_input_event(a)

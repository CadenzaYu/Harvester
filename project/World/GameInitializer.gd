# Primary node that takes care of sending setup instructions to some of the
# game's sub-systems; passing along the location of the map viewport for
# mappable objects, informing pirates of obstacles in the world, and 
# giving the player access to the game camera.
extends Node

var _spawned_positions := []
var _world_objects := []

onready var map: MapView = $MapView
onready var camera := $GameWorld/Camera
onready var hud := $UI/HUD
onready var admob := $AdMob


func _ready() -> void:
	Events.connect("station_spawned", self, "_on_Spawner_station_spawned")
	Events.connect("asteroid_spawned", self, "_on_Spawner_asteroid_spawned")
	Events.connect("pirate_spawned", self, "_on_Spawner_pirate_spawned")

	camera.setup_camera_map(map)

	ObjectRegistry.register_distortion_parent($DistortMaskView/Viewport)
	camera.setup_distortion_camera()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
		get_tree().set_input_as_handled()


func _on_Spawner_pirate_spawned(pirate: PirateShip) -> void:
	pirate.setup_world_objects(_world_objects)
	Events.emit_signal("node_spawned", pirate)


func _on_Spawner_station_spawned(station: DockingPoint, player: PlayerShip) -> void:
	_world_objects.append(weakref(station))

	hud.initialize(player)
	player.grab_camera(camera)
	Events.emit_signal("node_spawned", station)
	Events.emit_signal("node_spawned", player)


func _on_Spawner_asteroid_spawned(asteroid: DockingPoint) -> void:
	_world_objects.append(weakref(asteroid))
	Events.emit_signal("node_spawned", asteroid)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST or what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		var a = InputEventAction.new()
		a.action = "ui_cancel"
		a.pressed = true
		Input.parse_input_event(a)


func _on_AdMob_initialization_complete(status, adapter_name):
	print("Admob_initialization_complete：%d, " %status + adapter_name)
	if status == admob.INITIALIZATION_STATUS.READY:
		admob.load_rewarded_interstitial()


func _on_AdMob_rewarded_interstitial_ad_closed():
	admob.load_rewarded_interstitial()


func _on_AdMob_user_earned_rewarded(currency, amount):
	Events.emit_signal("earned_rewarded", amount * 60.0)



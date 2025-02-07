# Handles the input that brings up the minimap or the quit menu.
extends CanvasLayer

onready var screen_fader: TextureRect = $ScreenFader
onready var map: TextureRect = $MapDisplay
onready var upgrade_menu := $UpgradeUI
onready var quit_menu := $QuitMenu
onready var admob := $"../AdMob"


func _ready() -> void:
	Events.connect("player_died", self, "reset", [true])
	Events.connect("quit_requested", self, "quit")
	Events.connect("upgrade_unlocked", upgrade_menu, "open")
	screen_fader.fade_in()
	Settings.joystick_r = $joystickRight

func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused:
		return

	if event.is_action_pressed("ui_cancel"):
		quit_menu.open()
	if event.is_action_pressed("toggle_map") and not map.is_animating():
		map.toggle()


func quit() -> void:
	get_tree().quit()


func reset(with_delay: bool) -> void:
	screen_fader.fade_out(with_delay)
	yield(screen_fader, "animation_finished")
	if admob.is_rewarded_interstitial_loaded():
		admob.show_rewarded_interstitial()
	get_tree().change_scene("res://UI/MainMenu.tscn")

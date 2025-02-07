# Main class to represent the player's physics body. Controls the player's
# current health and how to operate when an upgrade choice has been made.
class_name PlayerShip
extends KinematicBody2D

signal died

export var stats: Resource = preload("res://Ships/Player/player_stats.tres")
export (int, LAYERS_2D_PHYSICS) var projectile_mask := 0
export var ExplosionEffect: PackedScene
# Represents the ship on the minimap. Use a MapIcon resource.
export var map_icon: Resource

var dockables := []

onready var shape := $CollisionShape
onready var agent: GSAISteeringAgent = $StateMachine/Move.agent
onready var camera_transform := $CameraTransform
onready var timer := $MapTimer
onready var cargo := $Cargo
onready var move_state := $StateMachine/Move
onready var gun := $Gun
onready var laser_gun := $LaserGun
onready var vfx := $VFX

var repair_speed := 0.0

func _ready() -> void:
	stats.initialize()
	repair_speed = stats.get_max_health() / 10.0
	Events.connect("damaged", self, "_on_damaged")
	Events.connect("upgrade_chosen", self, "_on_upgrade_chosen")
	Events.connect("earned_rewarded", self, "_on_earned_rewarded")
	stats.connect("health_depleted", self, "die")
	gun.collision_mask = projectile_mask
	laser_gun.collision_mask = projectile_mask
	laser_gun.energe = Settings.save_dict["laser_energe"]


func _toggle_map(map_up: bool, tween_time: float) -> void:
	if not map_up:
		timer.start(tween_time)
		yield(timer, "timeout")
	camera_transform.update_position = not map_up


func die() -> void:
	var effect := ExplosionEffect.instance()
	effect.global_position = global_position
	ObjectRegistry.register_effect(effect)
	Settings.save_dict["laser_energe"] = laser_gun.energe 
	Settings.save_game()

	emit_signal("died")
	Events.emit_signal("player_died")

	queue_free()


func grab_camera(camera: Camera2D) -> void:
	camera_transform.remote_path = camera.get_path()


func _on_damaged(target: Node, amount: int, _origin: Node) -> void:
	if not target == self:
		return
	if OS.get_name() == "Android":
		Input.vibrate_handheld()
	stats.health -= amount


func _on_upgrade_chosen(choice: int) -> void:
	match choice:
		Events.UpgradeChoices.HEALTH:
			stats.add_modifier("max_health", 25.0)
		Events.UpgradeChoices.SPEED:
			stats.add_modifier("linear_speed_max", 125.0)
		Events.UpgradeChoices.CARGO:
			cargo.stats.add_modifier("max_cargo", 50.0)
		Events.UpgradeChoices.MINING:
			cargo.stats.add_modifier("mining_rate", 10.0)
			cargo.stats.add_modifier("unload_rate", 5.0)
		Events.UpgradeChoices.WEAPON:
			gun.stats.add_modifier("damage", 3.0)
			laser_gun.damage_per_second *= 1.2
			# That's a limitation of the stats system, modifiers only add or remove values, and they
			# don't have limits
			if gun.stats.get_stat("cooldown") > 0.2:
				gun.stats.add_modifier("cooldown", -0.05)


func _on_RepairTimer_timeout():
	if stats.health < stats.get_max_health():
		stats.health += repair_speed

func _on_earned_rewarded(amount:float) -> void:
	laser_gun.energe += amount

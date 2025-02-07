# Spawns a group of pirates, then updates their squad and faction. Pirates are
# spawned outside of the asteroid belt, but are asigned an asteroid cluster
# or a point in space in the belt for them to path to. This keeps pirates from
# appearing right on top of the player, or to appear jarringly out of thin air.
class_name PirateSpawner
extends Node2D

export var PirateScene: PackedScene
export var count_min := 1
export var count_max := 5
export var spawn_radius := 150.0

var pirates := 0

func _ready():
	pirates = 0
	
func spawn_pirate_group(
	rng: RandomNumberGenerator, _choice: int, world_radius: float, cluster_position: Vector2
) -> void:
	var spawn_position := cluster_position.normalized() * world_radius * 1.25

	var pirates_in_cluster := []
	for _i in range(rng.randi_range(count_min, count_max)):
		var pirate := PirateScene.instance()
		pirate.position = (
			spawn_position
			+ Vector2.UP.rotated(rng.randf_range(0, PI * 2)) * spawn_radius
		)
		pirates_in_cluster.append(pirate)
	pirates += pirates_in_cluster.size()
	for p in pirates_in_cluster:
		p.setup_squad(
			p == pirates_in_cluster[0], pirates_in_cluster[0], cluster_position, pirates_in_cluster
		)
		p.setup_faction(get_tree().get_nodes_in_group("Pirates"))
		add_child(p)
		p.connect("died", self, "_on_Pirate_die")
		Events.emit_signal("pirate_spawned", p)

func _on_Pirate_die():
	pirates -= 1
	if pirates < 2:
		Events.emit_signal("upgrade_chosen", 0)  # borrow "upgrade_chosen" for spawn new pirate group

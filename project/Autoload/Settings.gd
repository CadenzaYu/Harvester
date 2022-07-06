extends Node

const DEBUG = false
const SAVE_NAME = "user://savegame.save"


var joystick_r = null

# Game data
var save_dict = {
		"enable_sound" : true,
		"enable_music" : true,
		"enable_ads" : true,
		"laser_energe" : 3
	}
# Note: This can be called from anywhere inside the tree. This function is
# path independent.
# Go through everything in the persist category and ask them to return a
# dict of relevant variables.
func save_game():
	var save_game = File.new()
	save_game.open(SAVE_NAME, File.WRITE)
	# Store the save dictionary as a new line in the save file.
	save_game.store_line(Marshalls.utf8_to_base64(to_json(save_dict)))
	save_game.close()

# Note: This can be called from anywhere inside the tree. This function
# is path independent.
func load_game():
	var save_game = File.new()
	if not save_game.file_exists(SAVE_NAME):
		return # Error! We don't have a save to load.

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	save_game.open(SAVE_NAME, File.READ)
	# Get the saved dictionary from the next line in the save file
	var node_data:Dictionary = parse_json(Marshalls.base64_to_utf8(save_game.get_as_text()))
	if not node_data.empty():
		for key in node_data.keys():
			save_dict[key] = node_data[key]
	save_game.close()
		
func _ready():
	load_game()

extends CanvasLayer

# Variables for your UI elements
@onready var game_over_label = $"GameOverPanel/GameOver"
@onready var pop_count_label = $"GameOverPanel/PopCount" # Popped balloon count text
@onready var time_up_label = $"GameOverPanel/Timesup"# Time's Up text

# Variable to hold the popped count
var popped_count: int = 0

func _ready():
	# Hide the game over panel initially
	$GameOverPanel.visible = false
	
func _on_balloon_ui_countdown_finished(popped: int) -> void:
	print("Game Over!!!")
	popped_count = popped
	# Show the Game Over panel when the countdown finishes
	$GameOverPanel.visible = true
	
	if $GameOverPanel.visible:
		print("The Game Over panel is now visible.")
	
	# Update the labels with final information
	game_over_label.text = "Game Over!"
	pop_count_label.text = "You popped %d balloons!" % popped_count
	time_up_label.text = "Time’s up!"
	
	# Optional: Freeze the game or pause the game if needed
	get_tree().paused = true

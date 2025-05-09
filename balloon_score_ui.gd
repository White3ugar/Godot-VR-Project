extends Control  # Changed from CanvasLayer to Control

var popped_count: int = 0

@onready var label = $BalloonCountLabel
@onready var timer_label = $TimerLabel

var countdown_time := 30  # seconds
var countdown_timer: Timer
signal countdown_finished(popped_count)

func _ready():
	# Set initial text
	label.text = "Balloons Popped: %d" % popped_count
	timer_label.text = "Time Left: %ds" % countdown_time

	# Create timer but don't start yet
	countdown_timer = Timer.new()
	countdown_timer.wait_time = 1.0
	countdown_timer.one_shot = false
	countdown_timer.timeout.connect(_on_countdown_tick)
	add_child(countdown_timer)

	# Connect to visibility change (only works for CanvasItem-based nodes like Control)
	connect("visibility_changed", Callable(self, "_on_visibility_changed"))

func _on_visibility_changed():
	if self.visible:
		_start_timer()

func _start_timer():
	if countdown_timer.is_stopped() and countdown_time > 0:
		countdown_timer.start()
		print("Countdown started.")
		
func increment_count():
	popped_count += 1
	label.text = "Balloons Popped: %d" % popped_count

func _on_countdown_tick():
	countdown_time -= 1
	timer_label.text = "Time Left: %ds" % countdown_time
	
	if countdown_time <= 0:
		countdown_timer.stop()
		print("Countdown ended.")
		emit_signal("countdown_finished", popped_count)

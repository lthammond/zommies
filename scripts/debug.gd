extends PanelContainer

@onready var property_container = $MarginContainer/VBoxContainer

var fps : String

func _ready():
	Global.debug = self
	visible = false
	
func _process(delta):
	if !visible:
		return
	fps = "%.2f" % (1.0 / delta)
	add_property("FPS", fps, 0)
	
func _input(event):
	if event.is_action_pressed("debug"):
		visible = !visible
		
func add_property(title: String, value, order):
	var target
	target = property_container.find_child(title, true, false)
	if !target:
		target = Label.new()
		property_container.add_child(target)
		target.name = title
		target.text = target.name + ": " + str(value)
	elif visible:
		target.text = title + ": " + str(value)
		property_container.move_child(target, order)

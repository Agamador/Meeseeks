extends TextureRect

# Called when the node enters the scene tree for the first time.

func _ready():
	connect('gui_input', self, 'item_clicked')
	pass
	
func item_clicked(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			Global.tile_mouse = self.name

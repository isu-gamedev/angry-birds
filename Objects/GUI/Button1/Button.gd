extends TextureButton
tool
export(String) var text setget _set_btn_text


func _ready():
	pass


func _set_btn_text(value):
	var label = get_node_or_null("Label")
	if label == null:
		return
	label.text = value
	text = value

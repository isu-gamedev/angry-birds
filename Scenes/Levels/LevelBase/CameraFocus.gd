extends Node2D


onready var slingshot = get_node("../Slingshot")
onready var camera := $Camera2D
onready var debug_camera := $DebugCamera
onready var tween := $Tween

export(float, 0.1, 3) var zoom = 1 setget set_zoom
export var debug = true

var dbg_speed = 700
var clamping = true

var follow_target: Node2D
var zoom_min
var zoom_max
var zoom_default
var enable_camera_zoom = true
var focus_default_position


func _ready():
	set_zoom(zoom)
	focus_default_position = self.global_position
	zoom_default = camera.zoom
	if enable_camera_zoom:
		zoom_min = camera.zoom - 0.15 * Vector2(1, 1)
		zoom_max = camera.zoom + 0.2 * Vector2(1, 1)
	else:
		zoom_min = camera.zoom
		zoom_max = camera.zoom


func zoom_out_anim():
	tween.interpolate_property(
		camera,
		"zoom",
		camera.zoom,
		zoom_max,
		.6,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT
	)
	tween.start()


func zoom_in_anim(target_global_position):
	tween.interpolate_property(
		camera,
		"zoom",
		camera.zoom,
		zoom_min,
		1.0,
		Tween.TRANS_QUAD,
		Tween.EASE_IN_OUT
	)
	tween.start()


func reset_zoom_anim():
	tween.interpolate_property(
		camera,
		"zoom",
		camera.zoom,
		zoom_default,
		1.2,
		Tween.TRANS_QUAD,
		Tween.EASE_IN_OUT
	)
	tween.interpolate_property(
		self,
		"global_position",
		global_position,
		focus_default_position,
		0.6,
		Tween.TRANS_QUAD,
		Tween.EASE_IN_OUT
	)
	tween.start()


func follow(target: Node2D):
	follow_target = target


func _process(delta):
	if debug:
		if Input.is_action_pressed("ui_left"):
			position.x -= dbg_speed * delta
		if Input.is_action_pressed("ui_right"):
			position.x += dbg_speed * delta
		if Input.is_action_pressed("ui_up"):
			position.y -= dbg_speed * delta
		if Input.is_action_pressed("ui_down"):
			position.y += dbg_speed * delta
	if follow_target:
		if follow_target.global_position.x > global_position.x:
			global_position.x = follow_target.global_position.x
		global_position.y = follow_target.global_position.y

	if clamping and !debug:
		clamp_into_camera_limits()


func set_zoom(val):
	zoom = val
	if find_node("Camera2D"):
		camera.set_zoom(Vector2(val, val))


func set_camera_limits(area: Area2D):
	var collision_shape: CollisionShape2D = area.get_node_or_null("CollisionShape2D")
	var shape: Shape2D = collision_shape.shape
	camera.limit_left = area.position.x - shape.extents.x / 2 * zoom_min.x
	camera.limit_right = area.position.x + shape.extents.x / 2 * zoom_min.x
	camera.limit_top = area.position.y - shape.extents.y / 2 * zoom_min.y
	camera.limit_bottom = area.position.y + shape.extents.y / 2 * zoom_min.y


func clamp_into_camera_limits():
	var vws = camera.get_viewport().get_visible_rect().size * camera.zoom
	position.x = clamp(position.x,
		camera.limit_left + vws.x / 2,
		camera.limit_right - vws.x / 2
	)
	position.y = clamp(position.y,
		camera.limit_top + vws.y / 2,
		camera.limit_bottom - vws.y / 2
	)


func _unhandled_input(event):
	if slingshot.state == slingshot.States.AIMING:
		zoom_out_anim()
		return

	if event is InputEventScreenDrag:
		position.x -= event.relative.x * camera.zoom.x
		get_tree().set_input_as_handled()

	if event is InputEventKey:
		if event.scancode == KEY_F1 and event.pressed:
			set_debug(!debug)
		if event.scancode == KEY_DOWN:
			debug_camera.zoom.x += 0.2
			debug_camera.zoom.y = debug_camera.zoom.x
		if event.scancode == KEY_UP:
			debug_camera.zoom.x -= 0.2
			debug_camera.zoom.y = debug_camera.zoom.x

func set_debug(is_active):
	debug = is_active
	$debug.visible = is_active
	camera.current = !is_active
	debug_camera.current = is_active


func _on_Slingshot_projectile_launched(projectile: Projectile):
	zoom_in_anim(projectile.global_position)
	follow(projectile)
	projectile.connect("almost_stopped", self, "_on_projectile_almost_stopped")


func _on_projectile_almost_stopped():
	follow_target = null
	reset_zoom_anim()

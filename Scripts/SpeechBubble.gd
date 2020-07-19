extends NinePatchRect

const BASE_WIDTH = 101

onready var Arrow = preload("res://Arrow.tscn")
onready var arrow_hbox = $ArrowContainer
onready var tween = $Tween
onready var talk_sound = $RandomSound

var arrow_directions = []

func set_pitch(pitch) -> void:
	talk_sound.base_pitch = pitch

#Add another arrow
func add_arrow(dir:int) -> void:
	if dir >= 0 and dir < 4:
		arrow_directions.append(dir)
		
		var inst = Arrow.instance()
		var rect = inst.get_node("TextureRect")
		if dir == 0 or dir == 2: rect.rect_scale = rect_scale
		rect.rect_rotation = dir * 90
		arrow_hbox.add_child(inst)
		
		if rect_scale.x < 0:
			arrow_hbox.move_child(inst,0)
		
		tween.remove_all()
		tween.interpolate_property(self,"rect_size",rect_size,Vector2(BASE_WIDTH+arrow_directions.size()*80-72,112),.075,Tween.TRANS_CUBIC,Tween.EASE_IN_OUT)
		tween.start()
		
		talk_sound.play()

func clear() -> void:
	arrow_directions.clear()
	for node in arrow_hbox.get_children():
		node.queue_free()
	rect_size = Vector2(BASE_WIDTH,112)
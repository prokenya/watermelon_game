@tool
extends Node2D
class_name Item

const ITEM_DRONE = preload("res://textures/icons/drone.png")
const ITEM_ak_w = preload("res://textures/icons/ak_w.png")
const ITEM_watermelon = preload("res://textures/icons/watermelon.png")
const ITEM_DRONE_EXP = preload("res://icon.png")

const ITEM_TEXTURES = [
	ITEM_DRONE, ITEM_ak_w, ITEM_watermelon,ITEM_DRONE_EXP
	]
const ITEM_STACK_LIM = [
	3,1,10,3
]
@export var amount: int = 1
@export var item_id: int = -1
var curent_amount = -1
var curent_id: int = -1

var desired_size = Vector2(64,64)

func get_texture(idx: int) -> Texture:
	if idx < 0:
		return null
	return ITEM_TEXTURES[min(idx, len(ITEM_TEXTURES) - 1)]

func _ready():
	var texture_size = ITEM_TEXTURES[item_id].get_size()
	var scale_factor = desired_size / texture_size
	$Sprite2D.scale = scale_factor
	update_texture()

func _process(delta):
	if curent_id != item_id:
		curent_id = item_id
		update_texture()
	if curent_amount != amount and amount <= ITEM_STACK_LIM[item_id]:
		curent_amount = amount
		$Label.text = str(amount)
	if amount > ITEM_STACK_LIM[item_id]:
		amount = ITEM_STACK_LIM[item_id]

func update_texture():
	var sprite = $Sprite2D
	if sprite != null:
		sprite.texture = get_texture(item_id)

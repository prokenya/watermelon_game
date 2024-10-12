extends Node2D
class_name Item
var default_item = ["res://scen/drop/abeme.tscn","res://scen/items/inventory/abeme_inv.tscn",
"res://textures/1182467.160.webp",1]
var items:Dictionary = InventoryManager.items
var config = ConfigFile.new()
var sprite
var ITEM_TEXTURES: Array = InventoryManager.ITEM_TEXTURES
var ITEM_STACK_LIM: Array = InventoryManager.ITEM_STACK_LIM
@export var amount: int = 1
@export var item_id: int = -1
var curent_amount = -1
var curent_id: int = -1

var desired_size = Vector2(64,64)

func get_texture(idx: int) -> Texture:
	return ITEM_TEXTURES[idx]

func _ready():
	sprite = $Sprite2D
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
	if sprite != null:
		sprite.texture = get_texture(item_id)
		var texture_size = ITEM_TEXTURES[item_id].get_size()
		var scale_factor = desired_size / texture_size
		sprite.scale = scale_factor
	

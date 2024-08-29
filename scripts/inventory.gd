extends Control

const SLOT_X: int = 5
const SLOT_Y: int = 1
const SLOT_SIZE: Vector2 = Vector2(64, 64)
const HALF_SLOT: Vector2 = 0.5 * SLOT_SIZE
const SPACING: Vector2 = Vector2(2, 2)
const MAX_SLOTS: int = SLOT_X * SLOT_Y

var items: Array = []
var hovered_index: int = -1
var active_slot: int = -1
var active_item: int = -1
var active_item_c: int = -1
var picked_item: Object = null
var picked_id: int = -1
var items_to_remove: Array = []
var is_inventory_active: bool = false
var is_inventory_full: bool = false
var inventory_offset: Vector2 = Vector2()
var user_prefs: UserPref
func _ready(): 
	user_prefs = UserPref.load_or_create()
	items = []
	for i in range(MAX_SLOTS):
		items.append(null)
	is_inventory_full = true
	var i = 0
	for child in get_children():
		if child is Item: # чтобы другие ноды не брало
			items[i] = child
			i += 1
	up_item_pos()
	load_inventory()
	Event.connect("add_item", add_item_by_id_mp)

func load_inventory():
	for slot_id in user_prefs.inventory_items.keys():
		var item_data = user_prefs.inventory_items[slot_id]
		if item_data != null:
			var item_id = item_data["id"]
			var amount = item_data["amount"]
			add_item_by_id(item_id, amount, slot_id)

func save_inventory():
	user_prefs.inventory_items.clear()
	for i in range(MAX_SLOTS):
		var item = items[i]
		if item != null:
			user_prefs.inventory_items[i] = {"id": get_item_id(item), "amount": item.amount}
	user_prefs.save()

func get_pos_by_id(idx: int) -> Vector2:
	var slots_y = int(idx / SLOT_X)
	var slots_x = idx % SLOT_X
	var x_offset = (SLOT_X * (SLOT_SIZE.x + SPACING.x)) * 0.5
	return (SLOT_SIZE + SPACING) * Vector2(slots_x, slots_y) - Vector2(x_offset, 0) # Корректировка позиции по оси X

func get_id_by_pos(lpos: Vector2) -> int:
	var x_offset = (SLOT_X * (SLOT_SIZE.x + SPACING.x)) * 0.5
	lpos.x += x_offset  # Корректировка позиции по оси X

	if lpos.x < 0 or lpos.y < 0:
		return -1
	if lpos.x >= (SLOT_X * (SLOT_SIZE.x + SPACING.x)):
		return -1
	if lpos.y >= (SLOT_Y * (SLOT_SIZE.y + SPACING.y)):
		return -1

	var rough_slot = lpos / (SLOT_SIZE + SPACING)
	var int_x = int(rough_slot.x)
	var int_y = int(rough_slot.y)
	var id = int_y * SLOT_X + int_x
	return id

func up_item_pos():
	for i in range(MAX_SLOTS):
		var item = items[i]
		if item != null:
			item.position = (get_pos_by_id(i) + HALF_SLOT)

func _input(event):
	if event is InputEventScreenTouch:
		var local_pos = (get_global_transform_with_canvas().affine_inverse() * event.position)
		if event.pressed:
			hovered_index = get_id_by_pos(local_pos)
			if hovered_index != -1:
				Event.is_inventory_active = true
			else:
				Event.is_inventory_active = false
			var itm = get_item(hovered_index)
			if hovered_index != -1: # если не за приделами инвенторя
				active_item = get_item_id(itm)
			if itm != null:
				picked_item = itm
				picked_id = hovered_index
				items[picked_id] = null # Важно очистить слот, откуда берется предмет
		else:
			if picked_item != null:
				local_pos = (get_global_transform_with_canvas().affine_inverse() * event.position)
				hovered_index = get_id_by_pos(local_pos)
				if hovered_index >= 0 and hovered_index < MAX_SLOTS:
					var item_in_slot = get_item(hovered_index)
					if item_in_slot == null:
						set_item(picked_item, hovered_index)
					else: # cтак
						if get_item_id(picked_item) == get_item_id(item_in_slot) and item_in_slot.amount < item_in_slot.ITEM_STACK_LIM[get_item_id(item_in_slot)]:
							var addable_amount = item_in_slot.ITEM_STACK_LIM[get_item_id(item_in_slot)] - item_in_slot.amount
							if picked_item.amount <= addable_amount:
								item_in_slot.amount += picked_item.amount
								picked_item.amount = 0
								items_to_remove.append(picked_item)
							else:
								item_in_slot.amount += addable_amount
								picked_item.amount -= addable_amount
								items[picked_id] = picked_item
						else:
							items[hovered_index] = picked_item
							items[picked_id] = item_in_slot
				else:
					var item_id = get_item_id(picked_item)
					Event.emit_signal("drop_item", active_item_c,picked_item.amount)
					print(picked_item.amount,"Items? with ID ", item_id, " was dropped outside the inventory")
					active_item = -1
					items_to_remove.append(picked_item)
					picked_item = null  # Не освобождаем сразу, а помечаем для удаления
				picked_item = null
				up_item_pos()
		queue_redraw()
	elif event is InputEventScreenDrag:
		if picked_item != null:
			picked_item.position = (get_global_transform_with_canvas().affine_inverse() * event.position)
	if hovered_index != -1:
		active_slot = hovered_index

func _process(delta):
	for item in items_to_remove:
		item.queue_free()
	items_to_remove.clear()
	if active_item_c != active_item:
		active_item_c = active_item
		Event.emit_signal("_active_item", active_item_c)

func set_item(item: Node2D, idx: int) -> bool:
	if idx < 0 or idx >= MAX_SLOTS:
		return false
	if items[idx] == null:
		items[idx] = item
		return true
	return false

func get_item(idx: int) -> Node2D:
	if idx < 0 or idx >= MAX_SLOTS:
		return null
	return items[idx]

func get_item_id(item: Node2D) -> int:
	if item is Item:
		return item.item_id
	return -1

func add_item_by_id_mp(item_id,player_id):
	if Event.is_multiplayer == true:
		if player_id == get_parent().get_parent().get_parent().get_parent().player_index:
			add_item_by_id(item_id)
	else: add_item_by_id(item_id)

func add_item_by_id(item_id: int, amount: int = 1, slot_id: int = -1) -> bool:
	if slot_id >= 0 and slot_id < MAX_SLOTS and items[slot_id] == null:
		# Add directly to the specified slot
		var new_item = preload("res://scen/gui/item.tscn").instantiate()
		new_item.item_id = item_id
		new_item.amount = amount # количество
		add_child(new_item)
		set_item(new_item, slot_id)
		up_item_pos()
		is_inventory_full = false
		if active_slot == slot_id:
			active_item = item_id
		return true

	for i in range(MAX_SLOTS):
		var i_id_get = get_item_id(items[i])
		if i_id_get == item_id and items[i].amount < items[i].ITEM_STACK_LIM[i_id_get] and amount > 0:
			var addable_amount = items[i].ITEM_STACK_LIM[i_id_get] - items[i].amount
			if amount <= addable_amount:
				items[i].amount += amount
				is_inventory_full = false
				return true
			else:
				items[i].amount += addable_amount
				amount -= addable_amount
		
		if items[i] == null and amount > 0:
			var new_item = preload("res://scen/gui/item.tscn").instantiate()
			new_item.item_id = item_id
			new_item.amount = amount # количество
			add_child(new_item)
			set_item(new_item, i)
			up_item_pos()
			is_inventory_full = false
			if active_slot == i:
				active_item = item_id
			return true
	is_inventory_full = true
	return false

func _draw():
	save_inventory()
	#print(active_item)
	for i in range(MAX_SLOTS):
		var col = Color.DARK_GRAY
		var rect = Rect2(get_pos_by_id(i), SLOT_SIZE)
		if i == active_slot:
			col = Color.GRAY
		draw_rect(rect, col)

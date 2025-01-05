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
	active_item_c = 0
	active_item = -1
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
	if Event.platform == "PC":
		_handle_pc_input(event)
	else:
		_handle_mobile_input(event)
			# Обработка движения
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		if picked_item != null:
			picked_item.position = (get_global_transform_with_canvas().affine_inverse() * event.position)
	
	if hovered_index != -1:
		active_slot = hovered_index

	active_item = get_item_id(get_item(active_slot))
	queue_redraw()
	
func _handle_mobile_input(event):
	if event is InputEventScreenTouch:
		var local_pos = (get_global_transform_with_canvas().affine_inverse() * event.position)
		if event.pressed:
			hovered_index = get_id_by_pos(local_pos)
			if hovered_index != -1:
				Event.is_inventory_active = true
			else:
				Event.is_inventory_active = false
			var itm = get_item(hovered_index)
			if hovered_index != -1: # если не за пределами инвентаря
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
					else: # стэк
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
					remove_item(picked_item,true)
				picked_item = null
				up_item_pos()
		queue_redraw()

func _handle_pc_input(event):
	if event is InputEventMouseButton:
		var local_pos = (get_global_transform_with_canvas().affine_inverse() * event.position)

		if event.pressed:
			# Если нажата левая кнопка мыши
			if event.button_index == MOUSE_BUTTON_LEFT:
				hovered_index = get_id_by_pos(local_pos)
				if hovered_index != -1:
					Event.is_inventory_active = true
				else:
					Event.is_inventory_active = false
				var itm = get_item(hovered_index)
				if hovered_index != -1: # если не за пределами инвентаря
					active_item = get_item_id(itm)
				if itm != null:
					picked_item = itm
					picked_id = hovered_index
					items[picked_id] = null # Важно очистить слот, откуда берется предмет
		else:
			# Если кнопка мыши отпущена
			if picked_item != null:
				local_pos = (get_global_transform_with_canvas().affine_inverse() * event.position)
				hovered_index = get_id_by_pos(local_pos)
				if hovered_index >= 0 and hovered_index < MAX_SLOTS:
					var item_in_slot = get_item(hovered_index)
					if item_in_slot == null:
						set_item(picked_item, hovered_index)
					else: # стэк
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
					remove_item(picked_item,true)
				picked_item = null
				up_item_pos()
		queue_redraw()

	if !Event.not_move_gui:
		if event is InputEventMouseButton and event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				hovered_index = clamp(active_slot -1 ,0,MAX_SLOTS-1)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				hovered_index = clamp(active_slot +1 ,0,MAX_SLOTS-1)
		if Input.is_action_just_pressed("Q") and active_slot != -1:
			remove_item(null,-33)

		for i in range(1,MAX_SLOTS+1):
			if Input.is_key_pressed(KEY_0 + i):
				hovered_index = i - 1


func _process(delta):
	for item in items_to_remove:
		if is_instance_valid(item):
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
		up_item_pos()  # Переместить предмет на правильную позицию
		return true
	return false


func get_item(idx: int) -> Node2D:
	if idx < 0 or idx >= MAX_SLOTS or !is_instance_valid(items[idx]):
		return null
	return items[idx]

func get_item_id(item: Node2D) -> int:
	if item is Item:
		return item.item_id
	return -1

func remove_item(item = null, drop: bool = false, slot_id: int = -1, item_amount: int = 1, id: int = -33):
	var litem
	var item_id = id
	
	# Если передан предмет (item != null), удаляем его
	if item != null:
		litem = item
		item_id = get_item_id(litem)
		if drop:
			Event.emit_signal("drop_item", item_id, litem.amount)  # Отправляем сигнал, если нужно выбросить предмет
		items_to_remove.append(litem)  # Добавляем в список на удаление
		active_item = -1
		up_item_pos()  # Обновляем позиции предметов
		queue_redraw()  # Перерисовываем интерфейс
		return
	
	# Если id == -33, это означает, что мы удаляем предмет из активного слота
	if id == -33:
		if slot_id == -1:
			slot_id = active_slot  # Если слот не передан, используем активный слот
		litem = get_item(slot_id)
		if litem == null or litem in items_to_remove:
			return  # Если предмета нет или он уже помечен для удаления, ничего не делаем
		
		item_id = get_item_id(litem)
		if item_amount == -1:
			# Удаляем весь предмет
			Event.emit_signal("drop_item", item_id, litem.amount)  # Отправляем сигнал о полном удалении
			items_to_remove.append(litem)  # Добавляем в список на удаление
			active_item = -1
		else:
			# Уменьшаем количество предмета
			var remaining_amount = litem.amount - item_amount
			print(remaining_amount)  # Логируем оставшееся количество для отладки
			if remaining_amount <= 0:
				# Если предмет должен быть полностью удален
				Event.emit_signal("drop_item", item_id, litem.amount)  # Отправляем сигнал о полном удалении
				items_to_remove.append(litem)
				active_item = -1
			else:
				# Если предмет не удаляется, обновляем его количество
				var removed_amount = item_amount  # Количество удаленных предметов
				litem.amount = remaining_amount
				if drop:
					Event.emit_signal("drop_item", item_id, removed_amount)  # Передаем количество удаленных предметов

		up_item_pos()  # Обновляем позиции предметов в инвентаре
		queue_redraw()  # Перерисовываем интерфейс
		return
	
	# Если передан конкретный слот, удаляем предмет из этого слота
	if slot_id >= 0 and slot_id < MAX_SLOTS:
		litem = get_item(slot_id)
		if litem != null:
			# Если предмет существует в слоте
			if item_amount == -1 or litem.amount <= item_amount:
				# Если удаляем весь предмет
				Event.emit_signal("drop_item", item_id, litem.amount)  # Отправляем сигнал о полном удалении
				items_to_remove.append(litem)
				items[slot_id] = null  # Очищаем слот
			else:
				# Уменьшаем количество предмета в слоте
				litem.amount -= item_amount
				if drop:
					Event.emit_signal("drop_item", item_id, item_amount)  # Передаем количество удаленного предмета
			up_item_pos()  # Обновляем позиции
			queue_redraw()  # Перерисовываем интерфейс

func add_item_by_id_mp(item_id,player_id):
	if Event.is_multiplayer == true:
		if player_id == get_parent().player_node.mpp.player_index:
			add_item_by_id(item_id)
	else: add_item_by_id(item_id)

func add_item_by_id(item_id: int, amount: int = 1, slot_id: int = -1) -> bool:
	if slot_id >= 0 and slot_id < MAX_SLOTS and items[slot_id] == null:
		var new_item = preload("res://scen/gui/item.tscn").instantiate()
		new_item.item_id = item_id
		new_item.amount = amount
		add_child(new_item)
		set_item(new_item, slot_id)
		if active_slot == slot_id:
			active_item = item_id
		return true

	for i in range(MAX_SLOTS):
		var item_in_slot = items[i]
		if item_in_slot != null and get_item_id(item_in_slot) == item_id and item_in_slot.amount < item_in_slot.ITEM_STACK_LIM[item_id] and amount > 0:
			var addable_amount = item_in_slot.ITEM_STACK_LIM[item_id] - item_in_slot.amount
			if amount <= addable_amount:
				item_in_slot.amount += amount
				return true
			else:
				item_in_slot.amount += addable_amount
				amount -= addable_amount

		if items[i] == null and amount > 0:
			var new_item = preload("res://scen/gui/item.tscn").instantiate()
			new_item.item_id = item_id
			new_item.amount = amount
			add_child(new_item)
			set_item(new_item, i)
			if active_slot == i:
				active_item = item_id
			return true
	return false


func check_inventory_full() -> Array:
	var avable_items_ids:Array
	for i in range(MAX_SLOTS):
		if items[i] != null:
			var item_id = get_item_id(items[i])
			if items[i].amount < items[i].ITEM_STACK_LIM[item_id]:
				avable_items_ids.append(item_id)
		else: return [-2]
	if avable_items_ids.is_empty():
		return [-1]
	return avable_items_ids

func _draw():
	Event.avable_items_id = check_inventory_full()
	save_inventory()
	#print(active_item)
	for i in range(MAX_SLOTS):
		var col = Color.DARK_GRAY
		var rect = Rect2(get_pos_by_id(i), SLOT_SIZE)
		if i == active_slot:
			col = Color.YELLOW
		draw_rect(rect, col)

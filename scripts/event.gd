extends Node

# op_signals
signal charapter_op()
signal world_s_op()
signal global_op()
signal spawn_enemy()
#player
signal _on_fire_pressed()
signal  control(id)
signal fire()
signal jump()
signal usev(vis: bool,item_id: int,control:int)
signal _active_item(item_id)
signal drop_item(item_id,amount)
signal pick_up()
signal add_item(item_id:int)
var hp_char: int
var is_inventory_active: bool
# drone
var drone_speed
var val_slider: float = 0
var drone_id: int = 0
var control_id:int
signal cam_1_3p(cam: bool)
signal reset_drone_pos()
#iter_call
signal back_s(id: int)
signal menu()

#multiplayer
signal host()
signal join()

extends Node

# op_signals
signal charapter_op()
signal world_s_op()
signal global_op()
signal spawn_enemy()
#player
signal control(id)
signal on_fire(player_id:int)
signal jump()
signal usev(vis: bool,item_id: int,control:int,player_id:int)
signal _active_item(item_id)
signal drop_item(item_id,amount)
signal pick_up(player_id:int)
signal add_item(item_id:int,player_id:int)
var hp_char: int
var is_inventory_active: bool
# drone
var drone_speed: String = "0"
var val_slider: float = 0
var control_item_id: int = 0
var control_id:int = 0
signal cam_1_3p(cam: bool,id:int)
signal reset_drone_pos()
#iter_call
signal back_s(id: int)
signal menu()

#multiplayer
signal host()
signal join()
var is_multiplayer:bool = false

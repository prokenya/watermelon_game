extends Node

# op_signals
signal charapter_op()
signal world_s_op()
signal global_op()
signal spawn_enemy()
#player
signal jump()
signal usev(vis: bool,item_id: int,control:int,player_id:int)
signal _active_item(item_id)
signal drop_item(item_id,amount)
signal pick_up(player_id:int)
signal add_item(item_id:int,player_id:int)
var hp_char: int
var is_inventory_active: bool
##control_player
signal on_fire(player_id:int)
signal control(id:int,item_id:int,player_id:int)
var control_item_id: int = 0 #counter
var control_id:int = 255
var player_control_id:int
# drone
var drone_speed: String = "0"
signal cam_1_3p(cam: bool,id:int)
signal reset_drone_pos()
#iter_call
signal back_s(id: int)
signal menu()

#multiplayer
signal host()
signal join()
var is_multiplayer:bool = false
var mpp_index:int

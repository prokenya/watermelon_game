extends Node

#world_data
var start_world_args: Dictionary
var items: Dictionary
#op_signals
signal charapter_op()
signal world_s_op()
signal global_op()
signal spawn_obj(data: Dictionary)
#iter_call
signal back_s(id: int)
signal menu()
#console
signal printd(data,color:Color)
signal run_comand(comand: String)
#multiplayer
signal host()
signal join()
var is_multiplayer:bool = false
var mppnode
var mpcnode
var mpp_index:int
signal _on_player_connected(mpplayer)
#player
signal _active_item(item_id)
var hp_char: int
var is_inventory_active: bool
##control_player
signal drop_item(item_id,amount)
signal pick_up(player_id:int)
signal add_item(item_id:int,player_id:int)
signal jump()
signal usev(vis: bool,item_id: int,control:int,player_id:int)
signal on_fire(player_id:int)
signal control(id:int,item_id:int,player_id:int)
var control_item_id: int = 0 #counter
var control_id:int = 255
var player_control_id:int
var move_gui:bool
#drone
var drone_speed: String = "0"
signal cam_1_3p(cam: bool,id:int)
signal reset_drone_pos()
func printc(text:String,color = Color.YELLOW):
	Event.emit_signal("printd",text,color)

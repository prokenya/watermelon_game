class_name UserPref extends Resource

@export_range(0, 1, .05) var SFX_lv: float = 0.5
@export_range(0, 1, .05) var music: float = 0.5
#player_s
@export_range(0,1,.05) var sensitivity: float = 0.5
@export var MSAA: int = 0
@export var cam_ch: bool = true
@export var inventory_items: Dictionary = {}
#cheats
@export var freejump_s: bool = false
@export var infinite_hp: bool = false
#world_s
@export var shadows: bool = true
@export var high_graphics: bool = false

func save() -> void:
	ResourceSaver.save(self, "user://user_prefs.tres")

static  func load_or_create() -> UserPref:
	var res: UserPref = load("user://user_prefs.tres") as UserPref
	if !res:
		res = UserPref.new()
	return res

# ResourceCache.gd
extends Node

var loaded_scenes = {}

func get_scene(path: String) -> PackedScene:
	if not loaded_scenes.has(path):
		loaded_scenes[path] = ResourceLoader.load(path)
		print_debug("load")
	return loaded_scenes[path]
	print_debug("get")

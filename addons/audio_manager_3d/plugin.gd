@tool
extends EditorPlugin

var icon = preload("res://addons/audio_manager_3d/images/icon-16x16.png")
var main_script = preload("res://addons/audio_manager_3d/audio_manager_3d.gd")
var audio_resource = preload("res://addons/audio_manager_3d/audio.gd")

func _enter_tree() -> void:
	add_custom_type("AudioManager3D", "Node3D", main_script, icon)
	add_custom_type("Audio", "Resource", audio_resource, null)
	pass


func _exit_tree() -> void:
	remove_custom_type("AudioManager3D")
	remove_custom_type("Audio")
	remove_resource_conversion_plugin(audio_resource)
	pass

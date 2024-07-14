@tool
extends EditorPlugin

func _enter_tree()->void:
	add_autoload_singleton("WorkspacesLoader","res://addons/WorkspaceAreas/scripts/WorkspacesAutoloader.gd")
	add_autoload_singleton("SplitAreaDrawLayer","res://addons/WorkspaceAreas/scripts/AreaSplitManager.gd")

func _exit_tree()->void:
	remove_autoload_singleton("WorkspacesLoader")
	remove_autoload_singleton("SplitAreaDrawLayer")

@tool
extends EditorPlugin

var packer:Control
var root_packer:Control
var files_browse:Button
var files_edit:TextEdit
var files_option:OptionButton

var files_open:EditorFileDialog

func _enter_tree():
	#引入主场景
	var pcker_pckscn = ResourceLoader.load("res://addons/exportwithoutdependence/export_no_de.tscn") as PackedScene
	packer = pcker_pckscn.instantiate()
	add_control_to_dock(3,packer)

	#引入filesdialog
	var files_choose = EditorFileDialog.new()
	files_choose.name = "filesopen"
	files_choose.unique_name_in_owner
	files_choose.display_mode = EditorFileDialog.DISPLAY_LIST
	files_choose.file_mode = 1
	files_choose.dialog_hide_on_ok = true

	add_child(files_choose)

	#链接信号
	files_option = packer.get_node("PanelContainer/MarginContainer/VSplitContainer/HSplitContainer/TabContainer/files/file_path/files_option")
	files_edit = packer.get_node("PanelContainer/MarginContainer/VSplitContainer/HSplitContainer/TabContainer/files/ScrollContainer/files_edit")
	files_browse = packer.get_node("PanelContainer/MarginContainer/VSplitContainer/HSplitContainer/TabContainer/files/file_path/files_b")

	files_open = get_node("filesopen")

	files_open.files_selected.connect(files_edit.under_files)
	files_browse.pressed.connect(files_open.popup)
	files_option.item_selected.connect(change_connect)

func change_connect(item:int) -> void:
	match item:
		0:
			files_open.file_mode = 2
			if files_open.files_selected.is_connected(files_edit.under_files):
				files_open.files_selected.disconnect(files_edit.under_files)
			if not files_open.dir_selected.is_connected(files_edit.under_folder):
				files_open.dir_selected.connect(files_edit.under_folder)
		1:
			files_open.file_mode = 1
			if not files_open.files_selected.is_connected(files_edit.under_files):
				files_open.files_selected.connect(files_edit.under_files)
			if files_open.dir_selected.is_connected(files_edit.under_folder):
				files_open.dir_selected.disconnect(files_edit.under_folder)

func _disable_plugin():
	if packer:
		remove_control_from_docks(packer)
		packer.queue_free()
		packer = null

func _exit_tree():
	# Clean-up of the plugin goes here.
	pass

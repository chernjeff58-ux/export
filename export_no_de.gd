@tool
extends Control

var task_dict:Dictionary
var packer:PCKPacker
var choosed_task_button:Array


# Called when the node enters the scene tree for the first time.
func _ready():
	task_dict = {}
	choosed_task_button = []
	init_preset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#region 主要函数
func add_task() -> int:
	var feg:int = randi_range(1000,10000)
	if task_dict.has(feg) or task_dict.has(1234):
		add_task()
	#创建空的表
	task_dict[feg] = ["","",PackedStringArray([]),false,""]
	return feg

func edit_task(tk_feg:int,tk_name:String,export_path:String,file_path_arr:PackedStringArray,is_encryt:bool,scrt:String) -> void:
	task_dict[tk_feg] = [tk_name,export_path,file_path_arr,is_encryt,scrt]

func go_selected(tk_feg:int) -> void:
	var run_arr = task_dict[tk_feg]
	#一系列检验
	check_arr(run_arr)
	check_name(run_arr[0])
	check_export_path(run_arr[0],run_arr[1])
	check_files_path(run_arr[0],run_arr[2])
	if run_arr[3] == false:
		packer = PCKPacker.new()
		packer.pck_start(run_arr[1])
		for i in run_arr[2]:
			packer.add_file(i,i,false)
		packer.flush(true)
	else:
		check_name(run_arr[4])
		packer = PCKPacker.new()
		packer.pck_start(run_arr[1],32,run_arr[4],true)
		for i in run_arr[2]:
			packer.add_file(i,i,true)
		packer.flush(true)


func go_all() -> void:
	for i in task_dict:
		go_selected(i)

func delete_selected(f:int) -> void:
	task_dict.erase(f)
#endregion

#region 选定与删除ui
#外部添加task_button
func add_task_button() -> void:
	var button1:PackedScene = ResourceLoader.load("res://addons/exportwithoutdependence/task_button.tscn") as PackedScene
	var task_feg:int = add_task()
	var b_instt = button1.instantiate()
	b_instt.set_meta("te",task_feg)
	%tasks_VBox.add_child(b_instt)

func remove_task_button(f:int) -> void:
	choosed_task_button.erase(f)
	var task_bs:Array = %tasks_VBox.get_children()
	for i in task_bs:
		if i.get_meta("te") == f:
			i.queue_free()

func choose_arr_add(is_choosed:bool,f:int) -> void:
	if is_choosed:
		choosed_task_button.append(f)
	if not is_choosed:
		choosed_task_button.erase(f)
#endregion

#region 编辑数据交互
#引进输入的值
func post_input(st:Array) -> void:
	print("post ",st)
	if choosed_task_button != []:
		edit_task(choosed_task_button[-1],st[0],st[1],st[2],st[3],st[4])

#编辑时显示已经编辑完成的
func export_edit(is_choosed:bool,fig:int) -> void:
	#从选择池移除
	choose_arr_add(is_choosed,fig)
	#显示已选择的
	if not task_dict.has(fig):
		return
	var current_tk:Array
	if is_choosed:
		current_tk = task_dict[fig]
	if not is_choosed:
		if choosed_task_button.is_empty():
			return
		current_tk = task_dict[choosed_task_button[-1]]
	%nameE.text = current_tk[0]
	%export_pathE.text = current_tk[1]
	if not current_tk[2].is_empty():
		var new_txt:String
		for i in current_tk[2]:
			new_txt += i + ","
		%files_edit.text = new_txt
	if current_tk[2].is_empty():
		%files_edit.text = ""
	%encrypt.button_pressed = current_tk[3]
	%scrtE.text = current_tk[4]
#endregion

#region 添加删除直连信号
#添加删除导出直接信号
func _on_add_pressed():
	add_task_button()

func _on_delete_pressed():
	for i in choosed_task_button:
		remove_task_button(i)
		delete_selected(i)


 # Replace with function body.


func _on_export_all_pressed():
	go_all()

#关闭时保存预设
func _on_save_pressed():
	save_cfg()

##加载预设
func init_preset() -> void:
	var config = ConfigFile.new()
	config.load("res://addons/exportwithoutdependence/game_settings.cfg")
	if not config.has_section("preset"):
		return
	var keys:PackedStringArray = config.get_section_keys("preset")
	for i in keys:
		task_dict[int(i)] = config.get_value("preset",i)
		var button1:PackedScene = ResourceLoader.load("res://addons/exportwithoutdependence/task_button.tscn") as PackedScene
		var b_instt = button1.instantiate()
		b_instt.set_meta("te",int(i))
		%tasks_VBox.add_child(b_instt)

#保存配置
func save_cfg() -> void:
	var config = ConfigFile.new()
	for key in task_dict:
		# 将值设置到 ConfigFile 对象中[citation:3]
		config.set_value("preset",str(key),task_dict[key])
# 将数据保存到文件。重要：写入配置应使用 'user://' 路径，因为它可写[citation:1]。
	var error = config.save("res://addons/exportwithoutdependence/game_settings.cfg")
	if error == OK:
		print("配置文件保存成功！")
	else:
		print("保存失败，错误码：", error)

func _on_export_selected_pressed():
	for i in choosed_task_button:
		go_selected(i)
#endregion


#region 检验函数
func check_arr(arr:Array) -> void:
	if arr == []:
		printerr("edit preset")
		return

func check_name(t:String) -> void:
	if t == null:
		t = ""
		push_warning(" edit name")

func check_export_path(n:String,t:String) -> void:
	if t == null or t == "":
		printerr(n + "edit export path")
		return
	if not t.ends_with(".pck"):
		printerr(n + " edit export path as *.pck")
		return

func check_files_path(n:String,t:PackedStringArray) -> void:
	if t == null or t == PackedStringArray([]):
		printerr(n + " edit export files paths")
		return

func check_crypt(n:String,new_t:String) -> void:
	if not new_t.length() == 64:
		printerr(n + " Please use 64 characters.")
		return
	var hex_re = RegEx.new()
	hex_re.compile("^[0-9a-fA-F]$")            # 单字符十六进制正则
	for ch in new_t:
		if typeof(ch) != TYPE_STRING or not hex_re.search(ch):  # 条件 1+2
			printerr(n + " Please use hexadecimal characters.")
			break

#endregion




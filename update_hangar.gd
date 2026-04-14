@tool
extends SceneTree

func _init():
	var scene_path = "res://demo/demo1/12_menu_hangar.tscn"
	var packed = load(scene_path) as PackedScene
	var root = packed.instantiate()
	
	var ship_list = root.find_child("ShipList", true, false)
	var btn_back = root.find_child("BTN_Back", true, false)
	
	var wrappers = ["ViperWrapper", "EmeraldWrapper", "PhantomWrapper"]
	var btn_texts = ["Améliorer", "Acheter", "Acheter"]
	var colors = [Color.WHITE, Color(1, 0.8, 0), Color(1, 0.8, 0)] # Améliorer en blanc, Acheter en jaune
	
	for i in range(wrappers.size()):
		var w_name = wrappers[i]
		var wrapper = ship_list.get_node(w_name)
		
		var vbox = VBoxContainer.new()
		vbox.name = w_name.replace("Wrapper", "Box")
		vbox.add_theme_constant_override("separation", 15)
		
		# Move wrapper into vbox
		ship_list.remove_child(wrapper)
		vbox.add_child(wrapper)
		wrapper.owner = root
		
		# Create Button
		var btn = Button.new()
		btn.name = "BTN_Action_" + w_name.replace("Wrapper", "")
		btn.text = btn_texts[i]
		
		# Copy SB_Button properties
		btn.set_script(btn_back.get_script())
		btn.custom_minimum_size = Vector2(130, 40)
		btn.add_theme_font_size_override("font_size", 14)
		btn.set("min_width", 130)
		btn.set("min_height", 40)
		btn.set("style_class_name", "regular_button")
		btn.set("normal_texture", btn_back.get("normal_texture"))
		btn.set("hover_texture", btn_back.get("hover_texture"))
		btn.set("pressed_texture", btn_back.get("pressed_texture"))
		btn.set("slice_margin_left", 64.0)
		btn.set("slice_margin_top", 16.0)
		btn.set("slice_margin_right", 64.0)
		btn.set("slice_margin_bottom", 16.0)
		btn.set("hover_scale_px", 2.0)
		btn.set("pressed_scale_px", -1.0)
		
		# Make "Acheter" buttons yellow logic
		if btn_texts[i] == "Acheter":
			btn.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
		else:
			btn.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5)) # Améliorer en vert
		
		vbox.add_child(btn)
		btn.owner = root
		
		ship_list.add_child(vbox)
		vbox.owner = root

	var new_packed = PackedScene.new()
	new_packed.pack(root)
	ResourceSaver.save(new_packed, scene_path)
	
	print("DONE")
	quit()

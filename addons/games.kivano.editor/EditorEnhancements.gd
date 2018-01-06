tool
extends EditorPlugin
################################### R E A D M E ##################################
# For additional Singleton features you should register res://addons/games.kivano.editor/contents/Singleton/KE.tscn
# as singleton in your project settings
#
#

##################################################################################
#########                     Imported classes/scenes                    #########
##################################################################################
var ScriptTabsScn = preload("res://addons/games.kivano.editor/contents/ScriptTabs/ScriptTabs.tscn");
var GroupManagerScn = preload("res://addons/games.kivano.editor/contents/GroupManager/GroupManagerWindow.tscn");
var SmartExtenderScn = preload("res://addons/games.kivano.editor/contents/SmartExtender/SmartExtenderLogic.tscn");
var ConnectionVisualiserScn = preload("res://addons/games.kivano.editor/contents/ConnectionVisualiser/ConnectionVisualiser.tscn");
var KivanoEnhancementsSignleton = preload("res://addons/games.kivano.editor/contents/Singleton/KE.tscn");

##################################################################################
#########                       Signals definitions                      #########
##################################################################################

##################################################################################
#####  Variables (Constants, Export Variables, Node Vars, Normal variables)  #####
######################### var myvar setget myvar_set,myvar_get ###################
const SCRIPT_TABS_ACTIVE = true; #false;
const GROUP_MANAGER_ACTIVE = true;
const SMART_EXTENDER_ACTIVE = true;
const CONNECTION_VISUALISER_ACTIVE = true;
const TEMPLATE_NODE_ACTIVE = true;
const SINGLETON_ACTIVE = true;
const SINGLETON_NAME = "KE";

export var storage = "";

var scriptTabs;
var groupManager;
var smartExtender;
var connectionVisualiser;

##################################################################################
#########                          Init code                             #########
##################################################################################


func _notification(what):
	if (what == NOTIFICATION_INSTANCED):
		pass
	elif(what == NOTIFICATION_READY):
		set_name(get_plugin_name()); #"KivanoEditorEnhancements");
		pass #only parts that are dependent on outside world (on theparents etc/also called when reparented)
#	elif(what == NOTIFICATION_ENTER_TREE):
		#
		var popup = load("res://addons/games.kivano.editor/contents/Configurator/Configurator.tscn").instance();

		#
		if(SCRIPT_TABS_ACTIVE):
			scriptTabs = ScriptTabsScn.instance();

			#
			get_editor_interface().get_editor_settings().set_setting("text_editor/files/open_dominant_script_on_scene_change", false);

			#Good setting when user want tabs in their own line
			get_editor_interface().get_editor_viewport().add_child(scriptTabs); #2,4 (also 4,x)
			get_editor_interface().get_editor_viewport().move_child(scriptTabs,0); #newline at the top

			#path taken from: script_editor_plugin.cpp:2280 with: print_line("Path to container: " + EditorInterface::get_singleton()->get_editor_viewport()->get_path_to(menu_hb));
#			get_editor_interface().get_editor_viewport().get_node("@@7194/@@6104/@@6105").add_child(scriptTabs)
#			get_editor_interface().get_editor_viewport().get_node("@@7194/@@6104/@@6105").move_child(scriptTabs,4)
#			minizeControl(get_editor_interface().get_editor_viewport().get_node("@@7194/@@6104/@@6105").get_child(3));
#			minizeControl(get_editor_interface().get_editor_viewport().get_node("@@7194/@@6104/@@6105").get_child(7));

			scriptTabs.manualInit(self);

		if(GROUP_MANAGER_ACTIVE):
			groupManager = GroupManagerScn.instance();
			add_control_to_dock(DOCK_SLOT_RIGHT_UL, groupManager);
			groupManager.manualInit(self);

		if(SMART_EXTENDER_ACTIVE):
			smartExtender = SmartExtenderScn.instance();
			add_control_to_container(CONTAINER_TOOLBAR, smartExtender);
			smartExtender.manualInit(self);

		if(CONNECTION_VISUALISER_ACTIVE):
			connectionVisualiser = ConnectionVisualiserScn.instance();
			connectionVisualiser.manualInit(self);
#			get_editor_interface().get_editor_viewport().add_child(connectionVisualiser)

		if(SINGLETON_ACTIVE):
#			it seems that Engine.has_singleton is useless in this scenario
#			if(!Engine.has_singleton(SINGLETON_NAME)):
#				createInfoDialog("'Kivano Editor Enhancemens' Plugin error: \n You need to register scene: \n" + str(KivanoEnhancementsSignleton.get_path()) + "\n as a singleton in your Project settings. \n Singleton should be named: " + SINGLETON_NAME);
			pass
			
		if(TEMPLATE_NODE_ACTIVE):
#			add_custom_type("TemplateNode","Node", preload("contents/TemplateNode/TemplateNode.gd"), preload("assets/white.png"));
			add_custom_type("TemplateSwitcher","Node", preload("contents/TemplateSwitcher/TemplateSwitcher.gd"), preload("contents/TemplateSwitcher/assets/template_switcher_ico.png"));
			add_custom_type("TemplateSwitcher3D","Spatial", preload("contents/TemplateSwitcher/TemplateSwitcher.gd"), preload("contents/TemplateSwitcher/assets/template_switcher_spatial_ico.png"));
			add_custom_type("TemplateSwitcher2D","Node2D", preload("contents/TemplateSwitcher/TemplateSwitcher.gd"), preload("contents/TemplateSwitcher/assets/template_switcher_2d_ico.png"));
			add_custom_type("TemplateHolderInitializer","Node", preload("contents/TemplateSwitcher/TemplateHolderTreeInitializer.gd"), preload("contents/TemplateSwitcher/assets/raw_template_holder.png"));

		on_resized();

		#
		get_editor_interface().get_editor_viewport().connect("resized", self, "on_resized");


	elif(what == NOTIFICATION_EXIT_TREE):
		var data2Save = {};

		if(SCRIPT_TABS_ACTIVE):
			scriptTabs.cleanup(self);
			scriptTabs.free();

		if(GROUP_MANAGER_ACTIVE):
#			data2Save["GroupRawData"] = groupManager.getRawGroupsData();
#			data2Save["GroupDescData"] = groupManager.getGroupDescriptionsData();
			remove_control_from_docks( groupManager ) # Remove the dock
			groupManager.free() # Erase the control from the memory

		if(SMART_EXTENDER_ACTIVE):
			if(smartExtender!=null):
				smartExtender.get_parent().remove_child(smartExtender);
				smartExtender.free() # Erase the control from the memory
				smartExtender = null;
		
		if(TEMPLATE_NODE_ACTIVE):
			remove_custom_type("TemplateNode");

func has_main_screen():
	return false;


##################################################################################
#########                       Getters and Setters                      #########
##################################################################################
func get_plugin_name():
	return "KivanoEditorEnhancements";

func minizeControl(inControl):
	inControl.size_flags_horizontal = 0;
	inControl.set_h_size_flags(Control.SIZE_SHRINK_CENTER);
##################################################################################
#########              Should be implemented in inheritanced             #########
##################################################################################

##################################################################################
#########                    Implemented from ancestor                   #########
##################################################################################

##################################################################################
#########                       Connected Signals                        #########
##################################################################################
func on_resized():
	if(SCRIPT_TABS_ACTIVE):
#		scriptTabs.onToolResize();
		pass

##################################################################################
#########     Methods fired because of events (usually via Groups interface)  ####
##################################################################################

##################################################################################
#########                         Public Methods                         #########
##################################################################################

##################################################################################
#########                         Inner Methods                          #########
##################################################################################
func createInfoDialog(inInfo):
	var infoDialog = AcceptDialog.new();
	add_child(infoDialog);
	infoDialog.dialog_text = inInfo;
	infoDialog.dialog_hide_on_ok = true;
	infoDialog.show();
	infoDialog.set_global_position(OS.get_window_size()/2);
	infoDialog.get_label().valign = VALIGN_CENTER;
	infoDialog.get_label().align = VALIGN_CENTER;

##################################################################################
#########                         Inner Classes                          #########
##################################################################################

tool
extends Node

################################### R E A D M E ##################################
# You should use this node together with TemplateHolder nodes.
# Inside TemplateHolder nodes you can define different templates by adding varius subscenes/nodes 
# to TemplateHolder. Templates are defines by those node names. 
#
# You should fill activeTemplateID with default template name. 

##################################################################################
#########                     Imported classes/scenes                    #########
##################################################################################
const KDataHolderScnPath = "res://addons/games.kivano.editor/contents/TemplateSwitcher/KDataHolder/KDataHolder.tscn";

const TEMPLATE_SWITCHER_ICO_PATH = "res://addons/games.kivano.editor/contents/TemplateSwitcher/assets/template_switcher_ico.png";
const TEMPLATE_SWITCHER_ICO_2D_PATH = "res://addons/games.kivano.editor/contents/TemplateSwitcher/assets/template_switcher_2d_ico.png";
const TEMPLATE_SWITCHER_ICO_3D_PATH = "res://addons/games.kivano.editor/contents/TemplateSwitcher/assets/template_switcher_spatial_ico.png";

const CHOOSEN_ICON_PATH = "res://addons/games.kivano.editor/contents/TemplateSwitcher/assets/choosen.png";
const NOT_CHOOSEN_ICON_PATH = "res://addons/games.kivano.editor/contents/TemplateSwitcher/assets/not_choosen.png";

const DATA_NODE_NAME = "kDataHolder";
const SAVE_DATA_PROP_TEMPLATE = "@Template";

const INSPECTOR_ACTIVE_TEMPLATE = "Active Template";
const IMMUTABLE_ID_PARAM = "IMMUTABLE_ID_PARAM";

##################################################################################
#########                       Signals definitions                      #########
##################################################################################

##################################################################################
#####  Variables (Constants, Export Variables, Node Vars, Normal variables)  #####
######################### var myvar setget myvar_set,myvar_get ###################
export (bool) var autoInit = true; #in some scenarios it might be helpfull to init manually from more top node. Mostly because of godot design which prevents to instance placeholders in child ready
export (NodePath) var templateHolderHolder1 = null setget setTH1;
export (NodePath) var templateHolderHolder2 = null setget setTH2;
export (NodePath) var templateHolderHolder3 = null setget setTH3;
export (NodePath) var templateHolderHolder4 = null setget setTH4;
export (NodePath) var templateHolderHolder5 = null setget setTH5;
export (NodePath) var templateHolderHolder6 = null setget setTH6;
export (NodePath) var templateHolderHolder7 = null setget setTH7;
export (NodePath) var templateHolderHolder8 = null setget setTH8;
export (NodePath) var templateHolderHolder9 = null setget setTH9;
export var devUniqueImmutableID = "" setget setDevUniqueImmutableID; #some unique hash needed for saving data and linking with proper switcher
var activeTemplateID = ""; #  setget setActiveTemplateID;

onready var target =  get_path_to(get_owner()); #NodePath("../..");
#onready var masterPlaceholder = get_parent();

var isInitialized = false;

var templateHolders = [];

#tool
var choosenIcon;
var notChoosenIcon;
var kivanoEnhancementsPlugin;
var editorSelection;
var menuButton;

##################################################################################
#########                          Init code                             #########
##################################################################################
func _notification(what):
	if (what == NOTIFICATION_INSTANCED):
		pass 
	elif(what == NOTIFICATION_READY):
		refreshTemplateHolders();
		retrieveData();
		if(Engine.is_editor_hint()):
			editorInit();
			ensureChildrenArePlaceholders();
			setActiveTemplateID(activeTemplateID);
		elif(autoInit):
			call_deferred("runtimeInit");
		
		isInitialized = true;
	elif(what == NOTIFICATION_EXIT_TREE):
		if(Engine.is_editor_hint()):
			ensureMenuBtnIsNotInContainer();

func manualInit():
	runtimeInit();

#tool
func editorInit():
	
	#
	if(devUniqueImmutableID==""):
		devUniqueImmutableID = str(get_path()) + str(OS.get_unix_time());
		devUniqueImmutableID = devUniqueImmutableID.md5_text();
	
	#
	choosenIcon = load(CHOOSEN_ICON_PATH);
	notChoosenIcon = load(NOT_CHOOSEN_ICON_PATH);
	
	#
	kivanoEnhancementsPlugin = get_node("/root/EditorNode/KivanoEditorEnhancements");
	editorSelection = kivanoEnhancementsPlugin.get_editor_interface().get_selection();
	editorSelection.connect("selection_changed", self, "onEditorSelectionChanged");
	initMenuButton();
	refreshtemplateHolderEditorVisibility();

func initMenuButton():
	menuButton = MenuButton.new();
	menuButton.text = get_name();
	menuButton.get_popup().connect("index_pressed", self, "onMenuBtnPopupPressed");
	
	var icoPath;
	if(self is Spatial):
		icoPath = TEMPLATE_SWITCHER_ICO_3D_PATH;
	elif(self is Node2D):
		icoPath = TEMPLATE_SWITCHER_ICO_2D_PATH;
	else:
		icoPath = TEMPLATE_SWITCHER_ICO_PATH;
	menuButton.icon = load(icoPath);

func runtimeInit():
	if(Engine.is_editor_hint()): return;
	
	for templateHolderHolderPath in templateHolders:
		var templateHolder = get_node(templateHolderHolderPath);
		if(!templateHolder.has_node(activeTemplateID)): 
			templateHolder.queue_free();
			continue;
		
		var activeTemplate = templateHolder.get_node(activeTemplateID);
		var templates2Remove = templateHolder.get_children();
				
		var scn2Instance = null;
		if(activeTemplate is InstancePlaceholder):
			scn2Instance = load(activeTemplate.get_instance_path());
		else:
			activeTemplate.show();
			var activeTemplateChilds = activeTemplate.get_children();
			for templChild in activeTemplateChilds:
				templChild.set_owner(activeTemplate);
			
			templateHolder.remove_child(activeTemplate);
			scn2Instance = PackedScene.new();
			scn2Instance.pack(activeTemplate);
			activeTemplate.queue_free();
			
		templateHolder.replace_by_instance(scn2Instance);
#		templateHolder.show();
		
		var temp2Remove = templates2Remove;
		for temp in temp2Remove:
			temp.queue_free();

##################################################################################
#########                       Getters and Setters                      #########
##################################################################################
func setDevUniqueImmutableID(inVal):
	if(devUniqueImmutableID==""):
		devUniqueImmutableID = inVal;
	else:
		#do nothing, the id is immutable after all
		return;

func setActiveTemplateID(inID):
	activeTemplateID = inID;
	if(is_inside_tree() && Engine.is_editor_hint()):
		refreshtemplateHolderEditorVisibility();

func setTH1(inVal):
	templateHolderHolder1 = inVal;
	if(is_inside_tree()): refreshTemplateHolders();
func setTH2(inVal):
	templateHolderHolder2 = inVal;
	if(is_inside_tree()): refreshTemplateHolders();
func setTH3(inVal):
	templateHolderHolder3 = inVal;
	if(is_inside_tree()): refreshTemplateHolders();
func setTH4(inVal):
	templateHolderHolder4 = inVal;
	if(is_inside_tree()): refreshTemplateHolders();
func setTH5(inVal):
	templateHolderHolder5 = inVal;
	if(is_inside_tree()): refreshTemplateHolders();
func setTH6(inVal):
	templateHolderHolder6 = inVal;
	if(is_inside_tree()): refreshTemplateHolders();
func setTH7(inVal):
	templateHolderHolder7 = inVal;
	if(is_inside_tree()): refreshTemplateHolders();
func setTH8(inVal):
	templateHolderHolder8 = inVal;
	if(is_inside_tree()): refreshTemplateHolders();
func setTH9(inVal):
	templateHolderHolder9 = inVal;
	if(is_inside_tree()): refreshTemplateHolders();

func getCategoryUniquePropertyName():
	return str(devUniqueImmutableID) + SAVE_DATA_PROP_TEMPLATE;

##################################################################################
#########              Should be implemented in inheritanced             #########
##################################################################################

##################################################################################
#########                    Implemented from ancestor                   #########
##################################################################################

##################################################################################
#########                       Connected Signals                        #########
##################################################################################

#tool
func onEditorSelectionChanged():
	if(!isInitialized): return;
	if(get_owner() == kivanoEnhancementsPlugin.get_editor_interface().get_edited_scene_root()):
		ensureChildrenArePlaceholders();
	
	var selectedNodes = editorSelection.get_selected_nodes();
	if(selectedNodes.size()==1):
		var selectedNode = selectedNodes.front();
		var isProperSelected = (selectedNode == get_node(target)) || (selectedNode == self);
		if(isProperSelected):
			ensureMenuBtnIsInContainer();
		else:
			ensureMenuBtnIsNotInContainer();

#tool
func onMenuBtnPopupPressed(inIdx):
	if(menuButton==null): return;
	var selectedLayout = menuButton.get_popup().get_item_text(inIdx);
	activateLayout(selectedLayout);

##################################################################################
#########     Methods fired because of events (usually via Groups interface)  ####
##################################################################################

##################################################################################
#########                         Public Methods                         #########
##################################################################################
func refreshTemplateHolders():
	templateHolders = [];
	if(isNodePathCorrect(templateHolderHolder1)): templateHolders.append(templateHolderHolder1);
	if(isNodePathCorrect(templateHolderHolder2)): templateHolders.append(templateHolderHolder2);
	if(isNodePathCorrect(templateHolderHolder3)): templateHolders.append(templateHolderHolder3);
	if(isNodePathCorrect(templateHolderHolder4)): templateHolders.append(templateHolderHolder4);
	if(isNodePathCorrect(templateHolderHolder5)): templateHolders.append(templateHolderHolder5);
	if(isNodePathCorrect(templateHolderHolder6)): templateHolders.append(templateHolderHolder6);
	if(isNodePathCorrect(templateHolderHolder7)): templateHolders.append(templateHolderHolder7);
	if(isNodePathCorrect(templateHolderHolder8)): templateHolders.append(templateHolderHolder8);
	if(isNodePathCorrect(templateHolderHolder9)): templateHolders.append(templateHolderHolder9);
	
	for templateHolderPath in templateHolders:
		var templateHolder = get_node(templateHolderPath);
		templateHolder.set_scene_instance_load_placeholder(true);

func retrieveData():
	var templateHolderNodeData = getTemplateHolderNodeData();
	var propertyName = getCategoryUniquePropertyName();
	
	if(templateHolderNodeData==null) || (!templateHolderNodeData.hasTemplateSwitcherData(propertyName)): 
		return;
		
	activeTemplateID = templateHolderNodeData.getTemplateSwitcherData(propertyName);
 
#tool
func saveData():
	var templateHolderNodeData = getTemplateHolderNodeData();
	if(templateHolderNodeData==null): return;
	var propertyName = getCategoryUniquePropertyName() ;
	templateHolderNodeData.saveTemplateSwitcherData(propertyName, activeTemplateID);
	get_node(target).set("editor/display_folded", true);

#tool
func activateLayout(inLayout):
	activeTemplateID = inLayout;
	refreshtemplateHolderEditorVisibility();
	saveData();
	refreshMenuButtonItems();

#tool
func refreshtemplateHolderEditorVisibility():
	for templateHolderPath in templateHolders:
		if(!has_node(templateHolderPath)): continue;
		var tempHolder = get_node(templateHolderPath);
		var templates = tempHolder.get_children();
		
		for template in templates:
			if(template.has_method("set_visible")):
				template.set_visible(false);
		
		if(!tempHolder.has_node(activeTemplateID)):
			continue;

		var activeNode = tempHolder.get_node(activeTemplateID);
		if(activeNode.has_method("set_visible")):
			activeNode.set_visible(true);

##################################################################################
#########                         Inner Methods                          #########
##################################################################################
func isNodePathCorrect(inNodePath):
	return (inNodePath!=null) && (inNodePath!="") && (inNodePath!=NodePath() && has_node(inNodePath));
	
#---------tool-----------
#------------------------
func ensureChildrenArePlaceholders():
	if(!Engine.is_editor_hint()): return;
	for templateHolderHolderPath in templateHolders:
		if(!has_node(templateHolderHolderPath)): continue;
		var templateHolderHolder = get_node(templateHolderHolderPath);
		var children = templateHolderHolder.get_children();
		for child in children:
			if(child.get_filename().length()>1):
				child.set_scene_instance_load_placeholder(true);

func refreshMenuButtonItems():
	if(!Engine.is_editor_hint()): return;
	var btnPopup = menuButton.get_popup()
	btnPopup.clear();
	var templNames = getPossibleTemplateNames();
	for templateName in templNames:
		if(activeTemplateID == templateName):
			btnPopup.add_icon_item(choosenIcon, templateName);
		else:
			btnPopup.add_icon_item(notChoosenIcon, templateName);

func getPossibleTemplateNames():
	if(!Engine.is_editor_hint()): return;
	var templNames = [];
	for templateHolderHolderPath in templateHolders:
		if(!has_node(templateHolderHolderPath)): continue;
		var templateHolderHolder = get_node(templateHolderHolderPath);
		var children = templateHolderHolder.get_children();
		for child in children:
			if(child==self): #the case when template switcher is inside template holder
				continue;
			var templateName = child.get_name()
			if(!templNames.has(templateName)):
				templNames.append(templateName);
	return templNames;

func ensureMenuBtnIsInContainer():
	if(!Engine.is_editor_hint()): return;
	if(!menuButton.is_inside_tree()):
		var properContainer = EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU if (get_node(target) is Spatial) else EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU;
		kivanoEnhancementsPlugin.add_control_to_container(properContainer, menuButton);
		refreshMenuButtonItems();

func ensureMenuBtnIsNotInContainer():
	if(menuButton==null): return;
	if(!Engine.is_editor_hint()): return;
	if(menuButton.is_inside_tree()):
		var menuParent = menuButton.get_parent();
		menuParent.remove_child(menuButton);

func getTemplateHolderNodeData():
	if(!has_node(target)): return null;
	var targetNode = get_node(target)
	var mostTopOwner = targetNode.get_owner();
	if(mostTopOwner==null): return null;
	
	var templateHolderData = null;
	if(!targetNode.has_node(DATA_NODE_NAME)):
		if(activeTemplateID=="") || (activeTemplateID==null): return null; 
		templateHolderData = load(KDataHolderScnPath).instance();
		templateHolderData.set_name(DATA_NODE_NAME);
		targetNode.add_child(templateHolderData);
		templateHolderData.set_owner(mostTopOwner);
	else:
		templateHolderData = targetNode.get_node(DATA_NODE_NAME);
	return templateHolderData;

#tool
func _get_property_list():
	var templateNames = getPossibleTemplateNames();
	var templateHoldersList = "No template in use,";
	for templateName in templateNames:
		templateHoldersList = templateHoldersList + templateName + ",";
	templateHoldersList.erase(templateHoldersList.length()-1,1)
	return [
		{
            "hint": PROPERTY_HINT_ENUM,
            "usage": PROPERTY_USAGE_DEFAULT,
 			"hint_string":templateHoldersList,
            "name": INSPECTOR_ACTIVE_TEMPLATE,
            "type": TYPE_STRING
        }
    ];
func _get(property):
	if(property==INSPECTOR_ACTIVE_TEMPLATE):
		return activeTemplateID;

func _set(property, val):
	if(property==INSPECTOR_ACTIVE_TEMPLATE):
		setActiveTemplateID(val);

##################################################################################
#########                         Inner Classes                          #########
##################################################################################


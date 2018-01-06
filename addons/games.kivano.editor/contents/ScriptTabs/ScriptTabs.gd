tool
extends Control
################################### R E A D M E ##################################
#
#
#

##################################################################################
#########                     Imported classes/scenes                    #########
##################################################################################

##################################################################################
#########                       Signals definitions                      #########
##################################################################################

##################################################################################
#####  Variables (Constants, Export Variables, Node Vars, Normal variables)  #####
######################### var myvar setget myvar_set,myvar_get ###################
onready var tabs = get_node("Tabs");
onready var activeIndicator = get_node("activeIndicator");
onready var indicatorTweener = get_node("indicatorMoveTweener");
onready var resizeTweener = get_node("resizeTweener");

var scenesData = {};
var currentSceneId = "";

var editorPlugin;
var currentMainScript;

var curentSceneFilePath = null;
var file;
var prevMainScreen = "3D";
var currentMainScreen = "3D";

var isInitialized = false;

##################################################################################
#########                          Init code                             #########
##################################################################################
func _notification(what):
	if (what == NOTIFICATION_INSTANCED):
		tabs = get_node("Tabs");
	elif(what == NOTIFICATION_READY):
		file = File.new();
		hide();

func _ready():
	pass

func manualInit(inParentEditorPlugin):
	editorPlugin = inParentEditorPlugin;

	#show();

	inParentEditorPlugin.get_editor_interface().get_script_editor().connect("editor_script_changed", self, "onScriptChanged", [], CONNECT_DEFERRED);
	inParentEditorPlugin.get_editor_interface().get_script_editor().connect("script_close", self, "onScriptClose");
	inParentEditorPlugin.connect("scene_changed", self, "onSceneChanged");
	inParentEditorPlugin.connect("main_screen_changed", self, "onMainScreenChanged");
	tabs.connect("tab_clicked", self, "onTabChanged");
	#tabs.connect("tab_changed", self, "onTabChanged");
	tabs.connect("right_button_pressed", self, "on_right_btn_pressed");
	tabs.connect("reposition_active_tab_request", self, "onTabRepositionRequest");

	set_process_input(true);

	get_tree().create_timer(3.0).connect("timeout", self, "setInitializedFlag");

	activeIndicator.hide(); #.modulate.a = 0;

func setInitializedFlag():
	isInitialized = true;

func cleanup(inParentEditorPlugin):
#	inParentEditorPlugin.add_tool_submenu_item("ScriptTab submenu", null);
	pass
##################################################################################
#########                       Getters and Setters                      #########
##################################################################################
#	get_editor_tool_addons().connect("script_changed", self, "onScriptChanged");
#	get_editor_tool_addons().connect("scene_changed", self, "onSceneChanged");
#	get_editor_tool_addons().connect("main_screen_changed", self, "onMainScreenChanged");
#	get_editor_tool_addons().connect("script_closed", self, "onScriptClosed");
#	get_editor_tool_addons().connect("scene_closed", self,  "onSceneClosed");

##################################################################################
#########              Should be implemented in inheritanced             #########
##################################################################################
func _input(event):
	if(event is InputEventMouseButton):
		if(!event.is_pressed()): return
		if(event.button_index != BUTTON_MIDDLE): return;
		if(!get_global_rect().has_point(event.global_position)): return;

		var tabHoverIdx = getCurrentTabAtPos(get_global_transform().xform_inv(event.global_position));
		if(tabHoverIdx>-1):
			scenesData[currentSceneId].openedScripts.remove(tabHoverIdx);
			rebuildTabsFromScnData();
			if(scenesData[currentSceneId].openedScripts.size()>0):
				openScriptWithFilepath(scenesData[currentSceneId].openedScripts[0]);
	elif(event is InputEventKey):
		if(!event.is_pressed()): return
		if(event.scancode == KEY_TAB) && (event.control) && (event.shift):
			prevScript();
		elif(event.scancode == KEY_TAB) && (event.control):
			nextScript();

func getCurrentTabAtPos(inLocalPos):
	for tabIdx in range(tabs.get_tab_count()):
		var rect = tabs.get_tab_rect(tabIdx);
		if(rect.has_point(inLocalPos)):
			return tabIdx;
	return -1;

##################################################################################
#########                    Implemented from ancestor                   #########
##################################################################################

##################################################################################
#########                       Connected Signals                        #########
##################################################################################

########
## From Tabs
func onTabRepositionRequest(inTo):
	var fromData = scenesData[currentSceneId].openedScripts[tabs.current_tab];
	scenesData[currentSceneId].openedScripts.remove(tabs.current_tab);
	scenesData[currentSceneId].openedScripts.insert(inTo, fromData)

	rebuildTabsFromScnData();
	if(scenesData[currentSceneId].prevScript!=null):
		openScriptWithFilepath(scenesData[currentSceneId].prevScript);

var activeTabPrevClickTime = OS.get_ticks_msec();
var prevTabIdx = -1;
func onTabChanged(inTabIdx):
	if(activeTabPrevClickTime + 250 > OS.get_ticks_msec()) && (prevTabIdx == inTabIdx):
		var openedScripts = scenesData[currentSceneId].openedScripts;
		var scene2CheckFilename = openedScripts[inTabIdx].get_basename() + ".tscn";
		if(file.file_exists(scene2CheckFilename)):
			closeScriptWithFilepath(openedScripts[inTabIdx]); #TODO: zdaje sie ze przy zmianie sceny ten skrypt i tak trafia do prevScript
			scenesData[currentSceneId].prevScript = null;
			if(tabs.get_tab_count()>0): tabs.current_tab = 0;
			editorPlugin.get_editor_interface().open_scene_from_path(scene2CheckFilename);
			return;
	activeTabPrevClickTime = OS.get_ticks_msec();
	changeTabToIdx(inTabIdx);

func on_right_btn_pressed(inTabIdx):
	print("right btn licked ", inTabIdx)
	pass

##########
## From EditorPlugin
func onMainScreenChanged(inScreenName):

	if(scenesData.empty()) || (!scenesData.has(currentSceneId)):
		return;

	if(inScreenName=="Script"): # || (inScreenName=="2D") || (inScreenName=="3D"):
		show();
	else:
		hide();

	prevMainScreen  = currentMainScreen;
	currentMainScreen = inScreenName;

	if(currentMainScreen=="Script"):
		refresh4ScriptView();
#		var scriptPath = editorPlugin.get_script_editor().get_current_script().get_path();
		if(scenesData[currentSceneId].prevScript!=null):
			#print("scenesData[currentSceneId].prevScript: ", scenesData[currentSceneId].prevScript)
#			Tutaj gdyby miec sposob na otworzenie skryptu bez wysylania sygnalu o otwarciu,
#			alternatywnie mozna zignorowac kazdy sygnal o script change=scenesData[currentSceneId].prevScript przez jakis czas
			#można by też to najzwyczajniej w świecie opóźnić, i wykonać tylko wtedy jeśli aktualnie otwarty skrypt nie jest zrejestrowany w tabsach
			yield(get_tree().create_timer(0.15),"timeout");
			var  currentlyOpenedScript = editorPlugin.get_editor_interface().get_script_editor().get_current_script();
			var shouldForceOpenScriptFromTab = (currentlyOpenedScript == null) || (scenesData[currentSceneId].openedScripts.find(currentlyOpenedScript.get_path())<0);
			if(shouldForceOpenScriptFromTab):
				openScriptWithFilepath(scenesData[currentSceneId].prevScript);
	if(currentMainScreen=="3D") || (currentMainScreen=="2D"):
		activeIndicator.hide()

func onSceneChanged(inScene):
	get_node("Tabs/Animator").play("fade_out_and_in");
	yield(get_tree().create_timer(0.2), "timeout");

	curentSceneFilePath = inScene.get_filename();
	currentMainScript = inScene.get_script();
	currentSceneId = curentSceneFilePath;

	if(!scenesData.has(currentSceneId)):
		scenesData[currentSceneId] = SceneTabData.new();

	tabs.clear();
	var scnOpenScripts = scenesData[currentSceneId].openedScripts;
	for scriptTabIdx in range(scnOpenScripts.size()):
		tabs.addScriptTab(scnOpenScripts[scriptTabIdx]);

	#ensure dominant script open
	var shouldFocus = currentMainScreen == "Script";
	var gdExists = file.file_exists(curentSceneFilePath.get_basename() + ".gd");
	if(gdExists) && (scenesData[currentSceneId].prevScript==null):
		openScriptWithFilepath(curentSceneFilePath.get_basename() + ".gd", shouldFocus);
	elif(scenesData[currentSceneId].prevScript!=null):
		openScriptWithFilepath(scenesData[currentSceneId].prevScript, shouldFocus);

func onScriptChanged(inScript):
	var scenes = editorPlugin.get_editor_interface().get_open_scenes();
	if(scenes.size()==0): return;

	var scriptFilepath = inScript.get_path();
	ensureScriptIsInTabs(scriptFilepath);

func onScriptClose(inScript):
	var scriptsOpenInEditor =  editorPlugin.get_editor_interface().get_script_editor().get_open_scripts();

	closeScriptWithFilepath(inScript.get_path());

#	if(scenesData[currentSceneId].openedScripts.size()>0):
#		openScriptWithFilepath(scenesData[currentSceneId].openedScripts[0]);

##################################################################################
#########     Methods fired because of events (usually via Groups interface)  ####
##################################################################################
func onToolResize():
	if(currentMainScreen=="Script"):
		refresh4ScriptView();
	if(currentMainScreen=="3D") || (currentMainScreen=="2D"):
		activeIndicator.hide()

##################################################################################
#########                         Public Methods                         #########
##################################################################################
func closeScriptWithFilepath(inScriptFilepath):
	var scriptFilepath = inScriptFilepath;
	tabs.closeScriptTab(scriptFilepath);
	var keyIdx = scenesData[currentSceneId].openedScripts.find(scriptFilepath);
	scenesData[currentSceneId].openedScripts.remove(keyIdx);

func openScriptWithFilepath(inScriptFilepath, focusOnScript = true):
	if(inScriptFilepath==null): return;
	if(focusOnScript):
		editorPlugin.get_editor_interface().edit_resource(load(inScriptFilepath)); #it will be focused because of onScriptChanged signal
	prevTabIdx = tabs.current_tab;
	scenesData[currentSceneId].prevScript = inScriptFilepath;

	ensureScriptIsInTabs(inScriptFilepath); #for the cases when this script was already focused

func nextScript():
	if(tabs.get_tab_count()<2): return;
	var nextScriptIdx = (tabs.current_tab + 1) % tabs.get_tab_count();
	var script2Open = scenesData[currentSceneId].openedScripts[nextScriptIdx];
	openScriptWithFilepath(script2Open);

func prevScript():
	if(tabs.get_tab_count()<2): return;
	var nextScriptIdx = (tabs.current_tab - 1);
	if(nextScriptIdx<0): nextScriptIdx = tabs.get_tab_count()-1;
	var script2Open = scenesData[currentSceneId].openedScripts[nextScriptIdx];
	openScriptWithFilepath(script2Open);

##################################################################################
#########                         Inner Methods                          #########
##################################################################################
func refreshIndicator():
	if(!isInitialized): return;
	var currentTabRect = tabs.get_tab_rect(tabs.current_tab);
	var targetPos = currentTabRect.position;

	indicatorTweener.stop_all();
	indicatorTweener.interpolate_property(activeIndicator, "rect_position", activeIndicator.get_rect().position, targetPos, 0.3, Tween.TRANS_QUART, Tween.EASE_IN_OUT);
	indicatorTweener.interpolate_property(activeIndicator, "rect_size", activeIndicator.get_rect().size, currentTabRect.size, 0.3, Tween.TRANS_QUART, Tween.EASE_IN_OUT);
	indicatorTweener.start();

func changeTabToIdx(inTabIdx):
	var openedScripts = scenesData[currentSceneId].openedScripts;
	var script2Open = openedScripts[inTabIdx];
	openScriptWithFilepath(script2Open);

func ensureScriptIsInTabs(inScript):
	var idx = tabs.getScriptTabIdx(inScript);
	if(idx<0):
		tabs.addScriptTab(inScript);
		idx = tabs.getScriptTabIdx(inScript);

	if(scenesData[currentSceneId].openedScripts.find(inScript)<0):
		scenesData[currentSceneId].openedScripts.insert(idx, inScript);

	if(scenesData[currentSceneId].openedScripts.find(inScript)!=idx):
		print("ScriptTabs ERROR: (scenesData[currentSceneId].openedScripts.find(inScript)!=idx): ", scenesData[currentSceneId].openedScripts.find(inScript), "!=", idx);
		rebuildTabsFromScnData();

	tabs.current_tab = idx;
	scenesData[currentSceneId].prevScript = inScript;

	tabs.ensure_tab_visible(tabs.current_tab);
	call_deferred("refreshIndicator");

static func copyArray(inArray):
	var copy = [];
	for item in inArray:
		copy.append(item);
	return copy;

func rebuildTabsFromScnData():
	tabs.clear();
	for script in scenesData[currentSceneId].openedScripts:
		tabs.addScriptTab(script);

func refresh4ScriptView():
	get_tree().create_timer(0.3).connect("timeout", activeIndicator, "show");
	get_tree().create_timer(0.3).connect("timeout", self, "refreshIndicator");

##################################################################################
#########                         Inner Classes                          #########
##################################################################################
class SceneTabData:
	var openedScripts = [];
	var prevScript = null;

	func removeScriptWithIdx(inIdx):
		openedScripts.remove(inIdx);






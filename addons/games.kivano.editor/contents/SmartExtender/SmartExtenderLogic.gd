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
const TEMPLATE_SCN_FILEPATH               = "res://addons/games.kivano.editor/contents/SmartExtender/templates/template_inherited_scene";
const TEMPLATE_SCN_SCRIPTED_FILEPATH      = "res://addons/games.kivano.editor/contents/SmartExtender/templates/template_inherited_script_scene";
const TEMPLATE_SCN_SIMPLE_SCRIPT_FILEPATH = "res://addons/games.kivano.editor/contents/SmartExtender/templates/template_simple_script_scene";
const TEMPLATE_SCRIPT_FILEPATH            = "res://addons/games.kivano.editor/contents/SmartExtender/templates/template_inherited_script";
const TEMPLATE_USER_SCRIPT_FILEPATH       = "res://addons/games.kivano.editor/contents/SmartExtender/templates/SCRIPT_TEMPLATE";

onready var fileDialog   = get_node("FileDialog");
onready var editorPlugin = get_node("EditorPlugin");
onready var selectedNodeLabel = get_node("FileDialog/TopInfo/selectedNode");

##################################################################################
#########                          Init code                             #########
##################################################################################
func _notification(what):
	if (what == NOTIFICATION_INSTANCED):
		pass #all internal initialization
	elif(what == NOTIFICATION_READY):
		pass

func manualInit(inParentEditorPlugin):
	editorPlugin = inParentEditorPlugin;
	if(Engine.is_editor_hint()):
		editorPlugin.get_editor_interface().get_selection().connect("selection_changed", self, "_onUserNodeSelectionChanged");

##################################################################################
#########                       Getters and Setters                      #########
##################################################################################

##################################################################################
#########              Should be implemented in inheritanced             #########
##################################################################################

##################################################################################
#########                    Implemented from ancestor                   #########
##################################################################################

##################################################################################
#########                       Connected Signals                        #########
##################################################################################
func _onUserNodeSelectionChanged():
	var selectedNodes = editorPlugin.get_editor_interface().get_selection().get_selected_nodes();
	if(selectedNodes.size()>1): return;
	if(selectedNodes.size()==0): return;
	
	var selectedNode = selectedNodes[0];
	
	selectedNodeLabel.set_text(selectedNode.get_name())
	
	if(selectedNode.get_script()!=null):
		get_node("Button").set_disabled(false);
		return;
	
	if(selectedNode.get_filename()!=""):
		get_node("Button").set_disabled(false);
	else:
		get_node("Button").set_disabled(true);
		

func _on_Button_pressed():
	call_deferred("popup");
	
func _on_FileDialog_custom_action( action ):
	pass

func _on_FileDialog_confirmed():
	if(fileDialog.get_current_file()==""): return;
	createSceneFromDialog();


##################################################################################
#########     Methods fired because of events (usually via Groups interface)  ####
##################################################################################

##################################################################################
#########                         Public Methods                         #########
##################################################################################
func popup():
	fileDialog.popup_centered();

##################################################################################
#########                         Inner Methods                          #########
##################################################################################
#this is it!
func createSceneFromDialog():
	
	#
	var newSceneNodeName = fileDialog.get_current_file().split(".")[0]; #without extension
	var newSceneFilepath = fileDialog.get_current_path();
	var selectedNode = editorPlugin.get_editor_interface().get_selection().get_selected_nodes()[0];
	var parentScnPath = selectedNode.get_filename();
	if(parentScnPath==null): parentScnPath="";
	
	#user wrote script filename, we want to have scene filename here
	if(newSceneFilepath.get_extension()=="gd"):
		newSceneFilepath = newSceneFilepath.replace(".gd",".tscn");
	
	if(newSceneFilepath.get_extension()!="tscn") && (newSceneFilepath.get_extension()!="scn"):
		if(newSceneFilepath.get_extension()==null): 
			#something is wrong, there is an extension but it's not tscn or scn... exiting
			return;
		#need to create folder here
		var dirMaker = Directory.new();
		dirMaker.make_dir(newSceneFilepath);
		newSceneFilepath = newSceneFilepath+"/"+newSceneNodeName+".tscn";
	
	#
	var newScriptFilepath = "";
	if(selectedNode.get_script()!=null):
		newScriptFilepath = newSceneFilepath.replace(newSceneFilepath.get_extension(), "gd");
	
	#scn
	var scriptType = ""; 
	var scnTemplateContent;
	if(selectedNode.get_script()==null): 
		scnTemplateContent = inheritedSceneTemplateContent(); 
	elif(parentScnPath==""): 
		scnTemplateContent = simpleSceneTemplateContent(); 
		scriptType = selectedNode.get_class();
	else: 
		scnTemplateContent = inheritedSceneScriptTemplateContent(); 
	
	scnTemplateContent = scnTemplateContent.replace("KIV_PATH_2_BASE_SCENE", parentScnPath);
	scnTemplateContent = scnTemplateContent.replace("KIV_PATH_2_SCRIPT", newScriptFilepath);
	scnTemplateContent = scnTemplateContent.replace("KIV_NEW_NODE_NAME", newSceneNodeName);
	scnTemplateContent = scnTemplateContent.replace("KIV_NODE_TYPE", scriptType);
	
	call_deferred("createFileWithContent",newSceneFilepath, scnTemplateContent); #want to avoid ovverride dialog
#	createFileWithContent(newSceneFilepath, scnTemplateContent); 
	
	#
	call_deferred("saveExtendedScriptOnDisk",selectedNode, newSceneFilepath); #want to avoid ovverride dialog
#	saveExtendedScriptOnDisk(selectedNode, newSceneFilepath);

func saveExtendedScriptOnDisk(inBaseScnNode, inNewSceneFilepath):
	if(inBaseScnNode.get_script()==null): return "";
	
	var baseScriptFilepath = inBaseScnNode.get_script().get_path();
	var extendedScriptFilepath = inNewSceneFilepath.replace(inNewSceneFilepath.get_extension(), "gd");
	var extendedScriptContent = inheritedGdScriptTemplateContent();
	
	extendedScriptContent = extendedScriptContent.replace("KIV_FILENAME", baseScriptFilepath);
	extendedScriptContent = extendedScriptContent + fileContent(TEMPLATE_USER_SCRIPT_FILEPATH);
	
	createFileWithContent(extendedScriptFilepath, extendedScriptContent);
	
	return extendedScriptFilepath;

##### File helpers
##############
func inheritedSceneTemplateContent():
	return fileContent(TEMPLATE_SCN_FILEPATH);
func inheritedSceneScriptTemplateContent():
	return fileContent(TEMPLATE_SCN_SCRIPTED_FILEPATH);
func simpleSceneTemplateContent():
	return fileContent(TEMPLATE_SCN_SIMPLE_SCRIPT_FILEPATH);
func inheritedGdScriptTemplateContent():
	return fileContent(TEMPLATE_SCRIPT_FILEPATH);

func fileContent(inFilePath):
	var fileWithData = File.new();
	if !fileWithData.file_exists(inFilePath): return "";

	fileWithData.open(inFilePath, File.READ);
	var fileContent = fileWithData.get_as_text();
	fileWithData.close();
	return fileContent;

func createFileWithContent(inFilePath, inContent):
	var newSceneFile = File.new();
	newSceneFile.open(inFilePath, File.WRITE);
	newSceneFile.store_line(inContent);
	newSceneFile.close();
##################################################################################
#########                         Inner Classes                          #########
##################################################################################


















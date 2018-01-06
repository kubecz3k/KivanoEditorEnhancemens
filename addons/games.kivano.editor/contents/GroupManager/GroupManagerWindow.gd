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
const PATH_2_PLUGIN_DATA_FILE = "res://addons/games.kivano.group_desc.dat";
const PATH_2_RAW_GROUPS_DATA_FILE = "res://addons/games.kivano.raw_groups.dat";

const GROUP_STATUS_NOT_ADDED_2_MANAGER = 1;
const GROUP_STATUS_NOT_VALIDATE = 2;
const GROUP_STATUS_VALIDATE = 3;

const VALIDATION_STAT_4_SCENE_OK = 1;
const VALIDATION_STAT_4_SCENE_ERROR = 2;

const MSG_NOT_ADDED_2_MANAGER = "Group Manager don't know this group, double click to fill info";
const MSG_SCN_NOT_VALIDATE = "Some scenes that are part of this group don't validate for required methods";
const MSG_GROUP_OK = "No problem here";

const ICO_OK      = preload("res://addons/games.kivano.editor/contents/GroupManager/assets/ok_ico.png");
const ICO_ERROR   = preload("res://addons/games.kivano.editor/contents/GroupManager/assets/error_ico.png");
const ICO_WARNING = preload("res://addons/games.kivano.editor/contents/GroupManager/assets/warning_ico.png");

var uiGroupList;

var group2ValidationStatusMap = {} #groupID is a key, validation status is a val
var scenesList = [];  #raw list of files with scenes in project
var group2SceneMap = {}; #key is group, val is array of SceneValidationInfo

var groupsDatabase = {}; #group is the key, val is dict with properties "desc","methods"[method1(param1,param2)|method2()]"

var parentEditorPlugin;

##################################################################################
#########                          Init code                             #########
##################################################################################
func _notification(what):
	if (what == NOTIFICATION_INSTANCED):
		uiGroupList = get_node("GroupList");
	elif(what == NOTIFICATION_READY):
		pass
	elif(what == NOTIFICATION_EXIT_TREE):
		saveRawGroupsData();

func manualInit(inEditorPlugin):
	parentEditorPlugin = inEditorPlugin;

func _enter_tree():
	pass
#	reset();

func reset():
	uiGroupList.clear()
	group2ValidationStatusMap.clear();
	scenesList.clear();
	group2SceneMap.clear();
	groupsDatabase.clear();

	groupsDatabase = loadDictFromFile(PATH_2_PLUGIN_DATA_FILE);
	gatherInfo();
	fillGroupsList();
	saveRawGroupsData();

##################################################################################
#########                       Getters and Setters                      #########
##################################################################################
func setGroupValidationStatus(inGroup, inStatus):
	if(!group2ValidationStatusMap.has(inGroup)):
		group2ValidationStatusMap[inGroup] = inStatus;
		return;

	if(group2ValidationStatusMap[inGroup] == GROUP_STATUS_VALIDATE):
		group2ValidationStatusMap[inGroup] = inStatus;

func getGroupValidationStatus(inGroup):
	return group2ValidationStatusMap[inGroup];

func getValidationStatus4Scene(inGroup, inSceneFilename):
	var sceneValidationsList = group2SceneMap[inGroup];
	for sceneValdationData in sceneValidationsList:
		print(sceneValdationData.get_class());
#		print(typeof(sceneValdationData))
#		print(sceneValdationData.filepath)
		if(sceneValdationData.getFilePath()==inSceneFilename):
			if(sceneValdationData.notValidatingMethods.size()>0):
				return VALIDATION_STAT_4_SCENE_ERROR;
	return VALIDATION_STAT_4_SCENE_OK;

func hasDescription4Group(inGroup):
	return groupsDatabase.has(inGroup);

func getGroupDesc(inGroup):
	if(!groupsDatabase.has(inGroup)): return "";
	return groupsDatabase[inGroup]["desc"];

func getGroupMethodsAsString(inGroup):
	if(!groupsDatabase.has(inGroup)): return "";
	return groupsDatabase[inGroup]["methods"];

func getGroupMethodsInList(inGroup):
	if(!groupsDatabase.has(inGroup)): return "";
	var methodsString = getGroupMethodsAsString(inGroup);
	return methodsString.split("|");

func getOnlyGroupMethodNamesInList(inGroup):
	if(!groupsDatabase.has(inGroup)): return "";
#	if(inGroup=="World"): breakpoint
	var methodNames = [];
	var methodsString = getGroupMethodsAsString(inGroup);
	var fullMethods = methodsString.split("|");
	for method in fullMethods:
		var methodName = method.left(method.find("("));
		if(methodName.length()>0):
			methodNames.append(methodName);
	return methodNames;

func findSceneValidationInfo(inGroup, inSceneFileName):
	var validationinfos4Group = group2SceneMap[inGroup];
	for info in validationinfos4Group:
		if(info.filePath == inSceneFileName):
			return info;
	return null;

func requestSceneOpen(inScenePath):
	parentEditorPlugin.get_editor_interface().open_scene_from_path(inScenePath);

##################################################################################
#########              Should be implemented in inheritanced             #########
##################################################################################

##################################################################################
#########                    Implemented from ancestor                   #########
##################################################################################
func _on_RefreshBtn_pressed():
	reset();

##################################################################################
#########                       Connected Signals                        #########
##################################################################################
func _on_GroupList_item_activated( index ):
	var group = get_node("GroupList").get_item_text(index);
	get_node("GroupDesc").showGroup(group, group2SceneMap);

func _on_GroupDesc_onSave( groupID, groupDesc, groupMethods ):
	if(groupsDatabase.has(groupID)):
		groupsDatabase[groupID].clear();
	else:
		groupsDatabase[groupID] = {};

	groupsDatabase[groupID]["desc"] = groupDesc;
	groupsDatabase[groupID]["methods"] = groupMethods;

	saveDict2File(groupsDatabase, PATH_2_PLUGIN_DATA_FILE)


##################################################################################
#########     Methods fired because of events (usually via Groups interface)  ####
##################################################################################
func getGroupDescriptionsData():
	return groupsDatabase;

##################################################################################
#########                         Public Methods                         #########
##################################################################################
func gatherInfo():

	var subfolderList = [];

	var dirCursor = Directory.new();
	dirCursor.open("res://");

	fetchAllSubfolders(dirCursor, subfolderList, scenesList);
	subfolderList.erase("res://addons");
	subfolderList.erase("res://.import");

	while(!subfolderList.empty()):

		#
		var currentFolder = subfolderList[0];
		subfolderList.remove(0);

		#
		dirCursor.change_dir(currentFolder);
		var success = fetchAllSubfolders(dirCursor, subfolderList, scenesList);
		if(!success):
			get_node("Title").set_text("Was not able to instance all scenes for some reason!");

func fetchAllSubfolders(inDirCursor, inOutSubfolderList, inOutScenesList):
	inDirCursor.list_dir_begin();
	var currentFile = inDirCursor.get_next();
	while(currentFile!=""):
		if inDirCursor.current_is_dir():
			if(currentFile!="..") && (currentFile!="."):
				var sceneFilePath = inDirCursor.get_current_dir()+"/"+currentFile;
				sceneFilePath = sceneFilePath.replace("///", "//");
				inOutSubfolderList.append(sceneFilePath);
		elif((currentFile.get_extension()=="tscn") || (currentFile.get_extension()=="scn") || (currentFile.get_extension()=="xscn")):
			var sceneFilePath = inDirCursor.get_current_dir()+"/"+currentFile;
			sceneFilePath = sceneFilePath.replace("///", "//");
			if(sceneFilePath!=null)&&(sceneFilePath!=""):
#				print("adding scn: ", currentFile)
				inOutScenesList.append(sceneFilePath);

		currentFile = inDirCursor.get_next();
	return true;

func fillGroupsList():
	loadDefinedGroups();
	assignScenes2Group();
	internalFillGroupList();

func loadDefinedGroups():
	pass

func assignScenes2Group():
	for sceneFileName in scenesList:
		var scn = load(sceneFileName);
		if(scn==null): #probably an error during compiling/instancing
			continue
		print("instancing: ", sceneFileName)
		scn = scn.instance();

		if(scn==null): #probably an error during compiling/instancing
			continue

		var groups = scn.get_groups();

		for group in groups:
			if(!group2SceneMap.has(group)):
				group2SceneMap[group] = [];

			var sceneValInfo = SceneValidationInfo.new();
			sceneValInfo.initialize(sceneFileName);
			group2SceneMap[group].append(sceneValInfo);
			checkGroupStatus(group, scn, sceneFileName);

		scn.free();

func internalFillGroupList():
	var groups = group2SceneMap.keys();
	for group in groups:

		uiGroupList.add_item(group);
		var currentItemIdx = uiGroupList.get_item_count()-1;
		var status =  getGroupValidationStatus(group);
		if(status==GROUP_STATUS_VALIDATE):
			uiGroupList.set_item_icon(currentItemIdx , ICO_OK);
			uiGroupList.set_item_tooltip(currentItemIdx, MSG_GROUP_OK);
		elif(status==GROUP_STATUS_NOT_VALIDATE):
			uiGroupList.set_item_icon(currentItemIdx , ICO_ERROR);
			uiGroupList.set_item_tooltip(currentItemIdx, MSG_SCN_NOT_VALIDATE);
		elif(status==GROUP_STATUS_NOT_ADDED_2_MANAGER):
			uiGroupList.set_item_icon(currentItemIdx , ICO_WARNING);
			uiGroupList.set_item_tooltip(currentItemIdx, MSG_NOT_ADDED_2_MANAGER);

func checkGroupStatus(inGroup, inSceneNode, inSceneFilename):
	var validationinfo = findSceneValidationInfo(inGroup, inSceneFilename);
	if(hasDescription4Group(inGroup)):

		#
		var hasAllRequiredMethods = true;
		var methods2Check = getOnlyGroupMethodNamesInList(inGroup)

		for method in methods2Check:
			if(!doSceneHaveMethod(inSceneNode, method)):
				validationinfo.addNotValidatingMethod(method);
				hasAllRequiredMethods = false;
#				get_node("debug").add_text(inSceneFilename + " dont have " + method + "\n")
#			else:
#				get_node("debug").add_text(inSceneFilename + " have " + method + "\n")
		#
		if(hasAllRequiredMethods):
			setGroupValidationStatus(inGroup, GROUP_STATUS_VALIDATE);
#			get_node("debug").add_text(inGroup + " setting status validate " + "\n")
		else:
			setGroupValidationStatus(inGroup, GROUP_STATUS_NOT_VALIDATE);

	else:
		setGroupValidationStatus(inGroup, GROUP_STATUS_NOT_ADDED_2_MANAGER);

func doSceneHaveMethod(inScn, inMethod):
	if(inScn.get_script()==null):
		 return inMethod=="";
	var scriptSource = inScn.get_script().get_source_code();
	var string2Look = "func " + inMethod + "(";
	if(scriptSource.find(string2Look)>-1):
		return true;
	return false;


##################################################################################
#########                         Inner Methods                          #########
##################################################################################
func saveDict2File(inDict, inFilePath):
	var saveGameFile = File.new();
	saveGameFile.open(inFilePath, File.WRITE);
	saveGameFile.store_line(to_json(inDict));
	saveGameFile.close();

func loadDictFromFile(inFilePath):
	var fileWithData = File.new();
	var loadedDictData = {}
	if !fileWithData.file_exists(inFilePath):
		return {};

	fileWithData.open(inFilePath, File.READ);
	while (!fileWithData.eof_reached()):
		var line = fileWithData.get_line();
		loadedDictData = parse_json(line);
		if typeof(loadedDictData) == TYPE_DICTIONARY: #exit when found first dict
			break;
	fileWithData.close();

	return loadedDictData;

func saveRawGroupsData():
	var rawGroupsDat = getRawGroupsData();
	if(rawGroupsDat!=null):
		saveDict2File(rawGroupsDat, PATH_2_RAW_GROUPS_DATA_FILE);

func getRawGroupsData():
	if(group2SceneMap.size()>0):
		var keys = group2SceneMap.keys();
		return {"RawGroupsData": keys};
	else:
		return null;

##################################################################################
#########                         Inner Classes                          #########
##################################################################################
class SceneValidationInfo:
	var filePath = "";
	var notValidatingMethods = [];

	func initialize(inPath):
		filePath = inPath;

	func addNotValidatingMethod(inMethodName):
		notValidatingMethods.append(inMethodName)

	func getFilePath():
		return filePath;


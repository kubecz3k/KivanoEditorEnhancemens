tool
extends WindowDialog
################################### R E A D M E ##################################
#
#
#

##################################################################################
#########                     Imported classes/scenes                    #########
##################################################################################
var GroupManagerWinScn = preload("../GroupManagerWindow.tscn");

##################################################################################
#########                       Signals definitions                      #########
##################################################################################
signal onSave(groupID, groupDesc, groupMethods);

##################################################################################
#####  Variables (Constants, Export Variables, Node Vars, Normal variables)  #####
######################### var myvar setget myvar_set,myvar_get ###################

export (NodePath) var path2GroupManagerRoot = NodePath("..");
export (NodePath) var description_
export (NodePath) var members_ 
export (NodePath) var titleDesc_ 
export (NodePath) var methodList_ 
export (NodePath) var AddMethodPopup_ 

var methodList;

var groupManagerLogicRoot;
var currentGroupID;
##################################################################################
#########                          Init code                             #########
##################################################################################
func _notification(what):
	if (what == NOTIFICATION_INSTANCED):
		methodList = get_node(methodList_);
		get_node(description_).set_readonly(true);
	elif(what == NOTIFICATION_READY):
			 groupManagerLogicRoot = get_node(path2GroupManagerRoot);

##################################################################################
#########                       Getters and Setters                      #########
##################################################################################
func showGroup(inGroup, group2SceneValidationInfo):

	#
	currentGroupID = inGroup;
	get_node(members_).clear();
	get_node(titleDesc_).set_text("Group: " + currentGroupID);
	get_node(methodList_).clear();
	get_node(description_).set_text("");

	#
	if(groupManagerLogicRoot.hasDescription4Group(currentGroupID)):
		var desc = groupManagerLogicRoot.getGroupDesc(inGroup);
		get_node(description_).set_text(desc);
		var methods = groupManagerLogicRoot.getGroupMethodsInList(inGroup);
		for method in methods: get_node(methodList_).add_item(method);


	#
	var linkedScenes = group2SceneValidationInfo[inGroup];
	for scene in linkedScenes:
#		get_node(members).add_item(scene.filePath);
		addScene2SceneList(currentGroupID, scene)

	popup();

func addScene2SceneList(inGroup, inScene):
	print("-------Adding scene to scene list-------");
	print("scene name: ", inScene.filePath, " group: ", inGroup);

	var validationStatus = groupManagerLogicRoot.getValidationStatus4Scene(inGroup, inScene.filePath)
	get_node(members_).add_item(inScene.filePath);
	var lastItemIdx =get_node(members_).get_item_count() - 1;
	if(validationStatus == groupManagerLogicRoot.VALIDATION_STAT_4_SCENE_OK ):
		get_node(members_).set_item_icon(lastItemIdx, groupManagerLogicRoot.ICO_OK);
		get_node(members_).set_item_tooltip(lastItemIdx, "All methods implemented")
	else:
		get_node(members_).set_item_icon(lastItemIdx, groupManagerLogicRoot.ICO_ERROR);
		get_node(members_).set_item_tooltip(lastItemIdx, "Need to implement one or more methods")

##################################################################################
#########              Should be implemented in inheritanced             #########
##################################################################################

##################################################################################
#########                    Implemented from ancestor                   #########
##################################################################################

##################################################################################
#########                       Connected Signals                        #########
##################################################################################
func _on_editDescriptionBtn_pressed():
	get_node(description_).set_readonly(false);

func _on_addMethodBtn_pressed():
	get_node(AddMethodPopup_).popup();

func _on_removeMethod_pressed():
	var selectedItems = get_node(methodList_).get_selected_items();
	for idx in selectedItems:
		get_node(methodList_).remove_item(idx);

func _on_AddMethodPopup_onMethodSave(inMethodName, inParamString):
	get_node(methodList_).add_item(inMethodName + "(" + inParamString + ")");

func _on_saveBtn_pressed():
	var methods = putMethodsInfo2String();
	var desc = get_node(description_).get_text();
	emit_signal("onSave", currentGroupID, desc, methods)
	hide();

func putMethodsInfo2String():
	var methodsString = "";
	var nmbOfMethods = methodList.get_item_count();
	for idx in range(nmbOfMethods):
		methodsString = methodsString + "|" + methodList.get_item_text(idx);
	methodsString = methodsString.strip_edges()
	if(methodsString.begins_with("|")):
		methodsString = methodsString.right(1);
	return methodsString;

func _on_members_item_activated( index ):
	if(get_node(members_).get_item_text(index).is_abs_path()):
		groupManagerLogicRoot.requestSceneOpen(get_node(members_).get_item_text(index));
		hide();

##################################################################################
#########     Methods fired because of events (usually via Groups interface)  ####
##################################################################################

##################################################################################
#########                         Public Methods                         #########
##################################################################################

##################################################################################
#########                         Inner Methods                          #########
##################################################################################

##################################################################################
#########                         Inner Classes                          #########
##################################################################################













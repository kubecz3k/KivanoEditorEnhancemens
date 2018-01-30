tool
extends Node
################################### R E A D M E ##################################
# 
#
#

##################################################################################
#########                     Imported classes/scenes                    #########
##################################################################################
const TEMPLATE_SPATIAL_SCN_PATH = "res://addons/games.kivano.editor/contents/TemplateSwitcher/TemplateHolders/SpatialTemplateHolder.tscn";
const TEMPLATE_NODE2D_SCN_PATH = "res://addons/games.kivano.editor/contents/TemplateSwitcher/TemplateHolders/2DTemplateHolder.tscn";
const TEMPLATE_NODE_SCN_PATH = "res://addons/games.kivano.editor/contents/TemplateSwitcher/TemplateHolders/RawTemplateHolder.tscn";

##################################################################################
#########                       Signals definitions                      #########
##################################################################################

##################################################################################
#####  Variables (Constants, Export Variables, Node Vars, Normal variables)  #####
######################### var myvar setget myvar_set,myvar_get ###################

##################################################################################
#########                          Init code                             #########
##################################################################################
func _notification(what):
	if (what == NOTIFICATION_INSTANCED):
		pass #all internal initialization
	elif(what == NOTIFICATION_READY):
		call_deferred("postInit");

var templateHolderNode;
func postInit():
	var parent = get_parent();
	var lowner = parent.get_owner();
	if(lowner==null): lowner = parent;
	
	var templateFilePath = "";
	if(parent is Spatial):
		templateFilePath = TEMPLATE_SPATIAL_SCN_PATH;
	elif(parent is Node2D):
		templateFilePath = TEMPLATE_NODE2D_SCN_PATH;
	else:
		templateFilePath = TEMPLATE_NODE_SCN_PATH;
	
	#
	templateHolderNode = load(templateFilePath).instance();
	parent.add_child(templateHolderNode);
	templateHolderNode.set_owner(lowner);
	templateHolderNode.set_scene_instance_load_placeholder(true); 
	
	var children = get_children();
	for child in children:
		remove_child(child);
		templateHolderNode.add_node(child);
	
	#
	queue_free();

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

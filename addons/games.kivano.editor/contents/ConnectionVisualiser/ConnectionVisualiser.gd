tool
extends Node

################################### R E A D M E ##################################
#
#
#

##################################################################################
#########                     Imported classes/scenes                    #########
##################################################################################
var LineScn = preload("res://addons/games.kivano.editor/contents/ConnectionVisualiser/Line/Line.tscn");
##################################################################################
#########                       Signals definitions                      #########
##################################################################################

##################################################################################
#####  Variables (Constants, Export Variables, Node Vars, Normal variables)  #####
######################### var myvar setget myvar_set,myvar_get ###################
export (Material) var signalMaterial;
export (Material) var nodePathMaterial;

var outGoingLines = []
var editorPlugin;


##################################################################################
#########                          Init code                             #########
##################################################################################
func _notification(what):
	if (what == NOTIFICATION_INSTANCED):
		pass #all internal initialization
	elif(what == NOTIFICATION_READY):
		pass #only parts that are dependent on outside world (on theparents etc/also called when reparented)

func manualInit(inParentEditorPlugin):
	editorPlugin = inParentEditorPlugin;
	inParentEditorPlugin.get_editor_interface().get_selection().connect("selection_changed", self, "on_selection_changed");

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
func on_selection_changed():
	#
	while(!outGoingLines.empty()):
		var lineRef = outGoingLines.pop_front();
		if(lineRef.get_ref()):
			lineRef.get_ref().queue_free();

	#
	var selectedNodes = editorPlugin.get_editor_interface().get_selection().get_selected_nodes();
	for node in selectedNodes:
		if (node is Spatial):

			#signal visualisation start
			var possibleOutgoingSignals = node.get_signal_list();
			for connection in possibleOutgoingSignals:
				var outgoingConnections = node.get_signal_connection_list(connection.name);
				for outgoingConnection in outgoingConnections:
					var target = outgoingConnection.target;
					if(target is Spatial):
						print("I have outgoing connection from: ", node.get_name(), " to: ", target.get_name());
						connectSignalLine(node, target);

			var incomingConnections = node.get_incoming_connections();
			for connection in incomingConnections:
				var source = connection.source;
				if(source is Spatial):
					print("I have incoming connection to: ", node.get_name(), " from: ", source.get_name())
					connectSignalLine(source, node);

			#nodepaths visualisation
			var properties = node.get_property_list();
			for property in properties:
				if(property.type == TYPE_NODE_PATH):
					var nodepath = node.get(property.name);
					if(nodepath==null) || (!node.has_node(nodepath)):
						continue;

					var target = node.get_node(nodepath);
					if(target is Spatial):
						connectNodePathLine(node, target);


#			print("properties: ", node.get_property_list());


func connectSignalLine(sourceNode, targetNode):
	connectLine(sourceNode, targetNode, signalMaterial);

func connectNodePathLine(sourceNode, targetNode):
	connectLine(sourceNode, targetNode, nodePathMaterial, 0.1, 0.1, 0.5);

func connectLine(sourceNode, targetNode, inMaterial, inSpaceBetweenDashes = 0.25, inDashInterval = 0.25, inSpeedFactor = 0.25):
	var line = LineScn.instance();
	sourceNode.add_child(line);
	outGoingLines.append(weakref(line));
	line.setDrawTargetSpatial(targetNode);
	line.manualInit(sourceNode, inMaterial, inSpaceBetweenDashes, inDashInterval, inSpeedFactor);

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

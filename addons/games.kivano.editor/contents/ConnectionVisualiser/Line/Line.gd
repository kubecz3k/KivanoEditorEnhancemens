tool
extends ImmediateGeometry
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
var SPACE_BETWEEN_DASHES = 0.25;
var lineInterval = 0.25;
var speedFactor = 0.25;

var drawTargetPoint = Vector3();
var drawTargetSpatialRef = newEmptyWeakRef();
var drawSourceSpatialRef = newEmptyWeakRef();

##################################################################################
#########                          Init code                             #########
##################################################################################
func _notification(what):
	if (what == NOTIFICATION_INSTANCED):
		pass #all internal initialization
	elif(what == NOTIFICATION_READY):
		set_as_toplevel(true);
		look_at(global_transform.origin + Vector3(0,0,1), Vector3(0,1,0));
		if(!Engine.is_editor_hint()):
			queue_free();
			return;

		set_process(true);
		#get_material_override().set_line_width(3);

func manualInit(inSourceNode, inMaterial, inSpaceBetweenDashes = 0.25, inDashInterval = 0.25, inSpeedFactor = 0.25):
	SPACE_BETWEEN_DASHES = inSpaceBetweenDashes;
	lineInterval = inDashInterval;
	speedFactor = inSpeedFactor;

	drawSourceSpatialRef = weakref(inSourceNode);
	material_override = inMaterial;

##################################################################################
#########                       Getters and Setters                      #########
##################################################################################
func setDrawTargetSpatial(inDrawTargetSpatial):
	drawTargetSpatialRef = weakref(inDrawTargetSpatial);

func setDrawTarget(inDrawTargetPoint):
	drawTargetPoint = -1*inDrawTargetPoint;
	drawTargetPoint.y = -drawTargetPoint.y;

##################################################################################
#########              Should be implemented in inheritanced             #########
##################################################################################

##################################################################################
#########                    Implemented from ancestor                   #########
##################################################################################
func _process(delta):

	if(!drawTargetSpatialRef.get_ref()): return;

	global_transform.origin = drawSourceSpatialRef.get_ref().global_transform.origin;

	clear();
#	begin(Mesh.PRIMITIVE_LINES, null);
#	if(drawTargetSpatialRef.get_ref()):
#		drawLine(drawTargetSpatialRef.get_ref().global_transform.origin - global_transform.origin);
#	end();
	currentShift += delta*speedFactor;
	drawDashedLineTo(drawTargetSpatialRef.get_ref().global_transform.origin - global_transform.origin);

	if(currentShift>600.0):
		currentShift = 0;


func drawLine(inTargetPoint):
	inTargetPoint = -1*inTargetPoint;
	inTargetPoint.y = -1*inTargetPoint.y;
#	drawTargetPoint.y = -drawTargetPoint.y;
	#inTargetPoint.z = -1*inTargetPoint.z;

#	add_vertex(Vector3(0,0,0));
#	add_vertex(inTargetPoint);
	drawDashedLineTo(inTargetPoint);

var currentShift = 0.0;
func drawDashedLineTo(inTargetPoint):
	inTargetPoint = -1*inTargetPoint;
	inTargetPoint.y = -1*inTargetPoint.y;

	var dir = inTargetPoint.normalized();
	var maxLength = inTargetPoint.length();
	var currentLength = 0.0;
	var lShift = fmod(currentShift, (SPACE_BETWEEN_DASHES+SPACE_BETWEEN_DASHES));

	while(currentLength<maxLength):
		var sectionStartLength = currentLength + lShift;
		var sectionEndLength = currentLength + lShift - lineInterval;
		var sectionStart =  Vector3() + dir*sectionStartLength;
		var sectionEnd = Vector3() + dir*sectionEndLength;

		if((currentLength + lShift) < lineInterval):
			sectionStart =  Vector3()
			sectionEnd = Vector3() + dir*(currentLength + lShift);

		if(sectionEndLength > maxLength):
			sectionEnd = inTargetPoint; #lineInterval - dir * (tooMuch);
		if(sectionStartLength > maxLength):
			sectionStart = inTargetPoint; #lineInterval - dir * (tooMuch);

		begin(Mesh.PRIMITIVE_LINES, null);
		add_vertex(sectionStart);
		add_vertex(sectionEnd);
		end();
		currentLength = currentLength + lineInterval + SPACE_BETWEEN_DASHES;


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
static func newEmptyWeakRef():
	var weakRef = weakref(Node.new());
	weakRef.get_ref().free()
	return weakRef;
##################################################################################
#########                         Inner Classes                          #########
##################################################################################

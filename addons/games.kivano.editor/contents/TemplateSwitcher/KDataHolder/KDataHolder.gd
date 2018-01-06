tool
extends Node
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
export (Dictionary) var templateSwitcherData = null setget setTemplateSwitcherData;

##################################################################################
#########                          Init code                             #########
##################################################################################
func _notification(what):
	if (what == NOTIFICATION_INSTANCED):
		pass #all internal initialization
	elif(what == NOTIFICATION_READY):
		pass #only parts that are dependent on outside world (on theparents etc/also called when reparented) 
##################################################################################
#########                       Getters and Setters                      #########
##################################################################################
func setTemplateSwitcherData(inData):
	if(templateSwitcherData==null):
		templateSwitcherData = inData;  #in data should be always a dictionary (setter used only by editor)

func saveTemplateSwitcherData(inProperty, inVal):
	if(templateSwitcherData==null):
		templateSwitcherData = {};
	templateSwitcherData[inProperty] = inVal;

func hasTemplateSwitcherData(inProperty):
	if(templateSwitcherData==null):
		return false;
	return templateSwitcherData.has(inProperty);

func getTemplateSwitcherData(inProperty):
	return templateSwitcherData[inProperty];


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

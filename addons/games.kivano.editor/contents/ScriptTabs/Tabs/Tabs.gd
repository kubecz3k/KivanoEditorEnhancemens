tool
extends Tabs
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
static func getTabName4Script(inScriptFilepath):
	var scriptName = inScriptFilepath.get_file().replace("."+inScriptFilepath.get_extension(),"");
	return scriptName;

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
func getScriptTabIdx(inScriptFilepath):
	var scriptName = getTabName4Script(inScriptFilepath)
	var nmbOfTabs = get_tab_count();
	for idxTab in range(nmbOfTabs):
		var title = get_tab_title(idxTab);
		if(title == scriptName):
			return idxTab;
	return -1;

func addScriptTab(inScriptFilepath):
	var scriptName = getTabName4Script(inScriptFilepath)
	var nmbOfTabs = get_tab_count();
	for idxTab in range(nmbOfTabs):
		var title = get_tab_title(idxTab);
		if(title == scriptName):
			return ;
	add_tab(scriptName, null);

func clear():
	var nmbOfTabs = get_tab_count();
	for idxTab in range(nmbOfTabs):
		remove_tab(0);

func closeScriptTab(inScriptFilepath):
	var scriptName = getTabName4Script(inScriptFilepath)
	var nmbOfTabs = get_tab_count();
	for idxTab in range(nmbOfTabs):
		var title = get_tab_title(idxTab);
		if(title == scriptName):
			remove_tab(idxTab);




##################################################################################
#########                         Inner Methods                          #########
##################################################################################

##################################################################################
#########                         Inner Classes                          #########
##################################################################################

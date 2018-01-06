KivanoEditorEnhancements
This plugin is a collection of smaller plugins that enhance in some way the Godot editor.
Currently due to https://github.com/godotengine/godot/issues/9969 there is no gui to configure which plugins should be active.
But it still can be configured by changing constant values in EditorEnhancements.gd:

const SCRIPT_TABS_ACTIVE = true; 
const GROUP_MANAGER_ACTIVE = true;
const SMART_EXTENDER_ACTIVE = true;
const CONNECTION_VISUALISER_ACTIVE = true;
const TEMPLATE_NODE_ACTIVE = true;
const SINGLETON_ACTIVE = true;
const SINGLETON_NAME = "KE";

Short description of those features:

* SCRIPT_TABS
Adds an old fashion container with tabs that holds scripts (like in most code editors). It simulates the way how tabs were working in pre 2.0 Godot. That means each scene is holding it's own tabs with scripts. So when you are changing scene you are also changing visible scripts (this way you can group scripts by linkim them thematically with opened scene).
https://www.youtube.com/watch?v=wV8IawfH8wQ

* GROUP_MANAGER
Plugin for godot to gain more informations about groups and their usage in your project What this plugin does is to simply recursively scan your project directory in order to find every scene file. Then it's instancing every scene in order to check to what groups this scene belongs. It provides an UI which allows to check what groups you have defined in project and what scenes belongs to those groups. Additionally it allows you to manually write description for each group, as well as to define some basic requirements for group members to fulfill (in the form of required methods).
https://youtu.be/inBR5-071ko

* CONNECTION_VISUALISER
Visualize Signals and NodePath connections between between 3D nodes.
https://youtu.be/YLvKY40GPyQ

* SMART_EXTENDER
It's a plugin which allows you to extend your scenes fast. It will try to extend node which is selected in Scene tree.
It's very easy to create inherited scene, select node, click extender icon and select path for inherited scene.
If base scene have script, then companion script for inherited scene will be created. This companion script will be extending base scene script.
If you dont write file extension for your new scene, the plugin will create new folder with proper name in which you will find your scene and script files.
You can also extend raw nodes with this plugin, but keep in mind it will create companion scene for you. In general we think there is no reason to not use this scene instead of raw script, thanks to strict connection between scene and script you will gain possibility to use child nodes and instanced scenes with ease in the future this way.
https://www.youtube.com/edit?o=U&video_id=1IUD-neGurg

* TEMPLATE_NODE
(This is not a proper description will fix that later):
Usually when I need to write tool code in my #GodotEngine game it serves a similar purpose: to refresh editor scene view after selecting model from inspector. It often is quite tedious to have whole scene script as a tool. Last week I came out with a more generic solution. I wrote a tool plugin which allows me to choose which sub-nodes in a scene should be loaded.
And now I can do this without adding any tool code to my scenes: https://mastodon.gamedev.place/system/media_attachments/files/000/008/195/original/media.mp4

* SINGLETON
To use this you will need to define singleton and link it with: 'addons/games.kivano.editor/contents/Singleton/KE.tscn'
With the name defined in SINGLETON_NAME. This singleton currently only allows you to not base on strings whne you are using your groups in code. Instead you can use them like this `node.is_in_group(KE.Group.yourGroupName)`. This way you will get instant error if you are somewhere trying to use group which is not defined in your project (like during the refactoring you rename your groups). In order for this singleton to know your groups work you will need to at least once use GroupManager feature (this feature will save your group info in addons/games.kivano.raw_groups) which will be used by this singleton in runtime. At the moment it might be needed to restart the editor after refreshing groups in order to refresh this file)


**Keep in mind that I take no responsibility for any potential damage casued by this code. You should always use Version control systems in your project.**

# Smart Scene Extender plugin for Godot engine
It's a plugin which allows you to extend your scenes fast. 
It will try to extend node which is selected in Scene tree. 
- It's very easy to create inherited scene, select node, click extender icon and select path for inherited scene.
- If base scene have script, then companion script for inherited scene will be created. This companion script will be extending base scene script.
- Each script is filled with content from template file. You can modify it under /addons/net.kivano.smartextender/SCRIPT_TEMPLATE
- If you dont write file extension for your new scene, the plugin will create new folder with proper name in which you will find your scene and script files.
- You can also extend raw nodes with this plugin, but keep in mind it will create companion scene for you. In general we think there is no reason to not use this scene instead of raw script, thanks to strict connection between scene and script you will gain possibility to use child nodes and instanced scenes with ease in the future this way.

Here you can see how this plugin works in action: https://youtu.be/1IUD-neGurg

Also keep in mind that while we are using this plugin and it should be well tested, we take no responsibility for potential damage casued by this code. You should always use Version control systems in your project.


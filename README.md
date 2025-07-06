# Scene Palette
A work-in-progress tool for easily placing scenes into levels without needing to navigate the file system

Currently only generates previews for 2D scenes.
Placement mode/grid snapping aren't implemented yet.
Features are added as I need them.

### How to use:
1. Once the plugin is enabled, navigate to "Scene Palette" in the toolbar at the bottom of the scene editor.
2. From there, you can add/remove folders from your project directory.
3. Folders are added as tabs, and all the scenes within the directory are added to the tab
4. You can then drag and drop scenes from the menu into the editor as instances or string paths, same as from the file browser
5. You can recolor groups/directories by right clicking on a path in the paths list (fun!)

Config files are stored in `res://addons/.config/scene-palette.cfg`. This includes folder colors and included paths.

#### Example:

![image](https://github.com/user-attachments/assets/64c715fd-379c-48db-829c-954bed5f7a05)

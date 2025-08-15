# Godot 4 Camera Zoom Controller
Made in Godot 4.4.1.

Controller for making a camera that can hover horizontally, and zoom vertically. WIP: Support for orthographic projection. It should be supported in theory, but I haven't gotten that to work with the example scene. 

## Setup
1. Download, extract, and add to project. If using git, clone it as a submodule in your project: `git submodule add https://github.com/Roboticy3/Godot-4-Camera-Zoom-Controller.git`
2. If you just want a simple camera controller for flying around, add `portable/camera_portable.tscn` to your scene! No input action setup or scene setup required. 
3. Other uses will be listed below.

## Action mapping and custom controllers
If you open `portable/camera_portable.tscn`, there should be two nodes. The lower node is the controller using the script `portable/portable_controller.gd`. Replace this with `player_camera/player_camera_controller.gd` and inspect the actions. You can bind the actions below or replace them with your own:
 - "z_in/out". Zooming in and out.
 - "ui_up/down" and "d_ctrl". Actions starting with "ui_" are built-in with every Godot project. However, the official docs recommend changing them for custom ones, especially if you want to have rebindable controls. "ui_up/down", while holding "d_ctrl", will cause a faster zoom than just scrolling.
 - "m_left/right/up/down". Motion controls. Moves the camera horizontally. I like to bind these to WASD

If all these actions are hooked up, you should be able to use the example scene in `example/test.tscn` to see the movement and dynamic loading in action.

 > You can also extend the PlayerCameraController base class with your own implementation.

## Camera limits
To add camera limits, simply attach a `scripts/chunk/chunk_bounds.gd` to any Sprite3D or other VisualInstance that you want to define the horizontal boundaries of your screen. You can change how forgiving the bounds are by adjusting the `zoom_margin` exported property. -1.0 is the default for fully containing the camera in the bounds, though the script is not reliable enough to hide any hard edges visible there.

## Setting up zoom levels
Add a `camera.tscn` to a 3d scene. Select a node where you want the first chunk to be mounted to the scene tree. Add it to a group called "Mount".

 > To change the mount group, enable Editable Children on the `camera.tscn` instance, select the node called ChunkLoader and change "Home mnt" to the desired group. To avoid ambiguity, there should only be one node in this group.

Most changes to this setup will involve enabling Editable Children on the camera anyways. This scene comes with "Readouts", text elements that display relevant information about the camera. A good thing to do after enabling Editable Children is to hide or disable these nodes.

### Changing the loading zones
By default, there are 4 zoom levels, each corresponding to a different group. From furthest to closest:
1. Space
2. World
3. Level
4. Sublevel
When the camera is in each of these levels, it will look for members of the associated group for chunks to load when zooming in. More on that later. Just know that if you change these names now, you may break the example scene.

Each zoom level has a y-value in 3d space which represents the top of the zoom level. Making the camera go above this level will make it attempt to unload the current level and resume the one above. Going below the top of the next level down will load it. The default tops- or "limits" -for each are:
1. 500000
2. 10000
3. 100
4. 1.0

This information is visible in `example/limits.tres`. To change them without effecting the defaults, copy the resource into another folder. Then, there are 3 users of `limits.tres` in `camera.tscn` that need to have their "limits" field set. With Editable Children enabled on the camera, select the following nodes:
 - CameraLevels
 - ChunkDetector
 - ChunkLoader
And set their limits field to the new resource.

Then make sure: 
 - The limit of each level is above the limit of the next level down.
 - The camera starts below the limit of the starting level (by default, Space), and above the limit of the next level down (World). Don't worry, the far plane should be far enough that the camera can still see well at this distance. However, scenes will have to be pretty large to be visible.

### Changing the chunk layout
Examine `example/test.tscn`. Note there isn't much in it. Since the camera itself is responsible for loading levels, it has all the information it needs to mount a level here, as long as there's a node in the Mount group.

The camera should have Editable Children enabled. If you inspect its child ChunkLoader, you should see a property called "Home". The base camera scene does not assign this value, which must be populated for any loading to happen. In test.tscn, it's assigned to `example/home.tscn`. Open that scene to see more of what the camera is going to load.

 > This scene is massive- not in terms of file size, it's literally huge. Some couple 10s of thousands of units across. That's because the camera is going to be very zoomed out if we use it. In the 3d editor, there's a button in the top bar called "View". You can click that, then click "View Settings" in the drop down menu to change the clipping planes in the editor, but it's not enough! No matter what you put in, the editor camera tops out at 100000 for its far plane. If you want to edit larger scenes, I would recommend building them small, then adding them to a scene under a Node3D with a large scale.

The scene only has 3 nodes. A root, a chunk, and a sprite. The sprite is the actual drawing of a planet. The chunk is a VisibleOnScreenNotifier3D. The camera will only load its contents if it is both on screen (according to VisibleOnScreenNotifier3D::is_on_screen()) and if the camera is zoomed in enough. The chunk also has a script attached. The script has a field called "Group" set to "Space". If you change this, you won't be able to zoom in anymore. The Group field has to match the level on which this chunk is encountered. This removes ambiguity when multiple levels are loaded at the same time. If you want to reuse a chunk at multiple levels, use an inherited scene to create a version of the chunk with a different Group.

You can also create more chunks by duplicating the VisibleOnScreenNotifier3D and moving it. The camera will automatically pick the closest chunk, and use the chunk's posiiton as a reference point to load the next chunk on. So you can freely place chunks anywhere in the world. 

Loading a chunk also pauses higher levels. So chunks can even be in motion! When you zoom in on them, any animations or processing will stop. Though I wouldn't recommend making them physics objects unless you're very confident.

It's a little hard to see in the example, but this code also comes with a highlight: a small scene containing a yellow glow that gets placed behind the current closest chunk. You can modify this shine directly as `highlight/scenes/shine.tscn`, or make a copy and set it to the shine that the Highlighter node under your camera will use. 
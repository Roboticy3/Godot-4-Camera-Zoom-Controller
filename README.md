# Godot 4 Camera Zoom Controller
Made in Godot 4.4.1.

Controller for making a camera that can hover horizontally, and zoom vertically. Supports perspective and orthographic projections. 

## Setup
1. Download, extract, and add to project. If using git, clone it as a submodule in your project: `git submodule add https://github.com/Roboticy3/Godot-4-Camera-Zoom-Controller.git`
2. If you just want a simple camera controller for flying around, add `portable/camera_portable.tscn` to your scene! No input action setup or scene setup required.
3. Other uses will be listed below.

## Action mapping and custom controllers
If you open `portable/camera_portable.tscn`, there should be two nodes. The lower node is the controller using the script `portable/portable_controller.gd`. Replace this with `player_camera/player_camera_controller.gd` and inspect the actions. You can bind the actions below or replace them with your own:
 - "z_in/out". Zooming in and out.
 - "ui_up/down" and "d_ctrl". Actions starting with "ui_" are built-in with every Godot project. However, the official docs recommend changing them for custom ones, especially if you want to have rebindable controls. "ui_up/down", while holding "d_ctrl", will cause a faster zoom than just scrolling.
 - "m_left/right/up/down". Motion controls. Moves the camera horizontally. I like to bind these to WASD

You can also extend the PlayerCameraController base class with your own implementation.

## Camera limits
To add camera limits, simply attach a `scripts/chunk/chunk_bounds.gd` to any Sprite3D or other VisualInstance that you want to define the horizontal boundaries of your screen. You can change how forgiving the bounds are by adjusting the `zoom_margin` exported property. -1.0 is the default for fully containing the camera in the bounds, though the script is not reliable enough to hide any hard edges visible there.


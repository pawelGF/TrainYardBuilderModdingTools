Modding tools for Train Yard Builder Game:
https://store.steampowered.com/app/1674900/Train_Yard_Builder/
Modding Tool Instructions
Editor Terminology
The Unity Editor interface is divided into multiple sections (or “windows”, as they will be referred to throughout the document). Each section is labeled on its tab. 

Restoring Tabs
If you ever close one of the windows, you can display it again by clicking the right mouse button on any of the remaining tabs, choosing “Add Tab”, then adding the one that you have just closed.

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/Reading%20a%20tab.png)

Project window
![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/Project%20Window.png)
The Project window in the Unity Editor displays all the assets and files in your project, allowing you to manage and organize them.

Inspector window
![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/Inspector%20Window.png)
The Inspector window in the Unity Editor displays and allows you to modify the properties and settings of selected GameObjects, components, or assets.

Hierarchy window

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/Hierarchy%20window.png)
The Hierarchy window in the Unity Engine displays and organizes all the GameObjects in the current scene, showing their parent-child relationships in a tree-like structure.



Any object in the hierarchy is a GameObject. If a GameObject is indented under another, it’s considered a child, and the one above it is the parent. In the example, "Building Variant" is the parent, and the others are its children. A parent can have multiple children, but each child can have only one parent.


![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/GameObject.png)

Component 
A Component is a block of data attached to a GameObject. Any GameObject can have an unlimited number of Components.
![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/Component.png)

Component field
A Component field is a single piece of data within a Component.

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/Component%20Field.png)

Asset
Any file in a project window.

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/Asset.png)


Prefab

An Asset with blue cube icon and with the name ending “.prefab”. (Use a slider to change icons size- bottom right corner).

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/Prefab.png)

Gizmos
In Unity Editor, shapes created from lines.

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/Gizmos.png)


Creating object in Unity
Setup
Download the Unity Editor version 2021.3.27f.LTS  https://unity3d.com/get-unity/download/archive 
![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/DownloadUnity.gif)

Download the Unity Hub 
https://unity3d.com/get-unity/download 


![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/DownloadProject.gif)


Download the TrainYardBuilderModdingTools project https://github.com/pawelGF/TrainYardBuilderModdingTools

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/AddProjectInUnity.gif)

Open the Unity Hub. Click “Add” in the “Projects” tab.

Select the downloaded Unity project folder.

The TrainYardBuilder_CustomBundles project will appear in the Projects list. Click on it and wait for it to load, which may take several minutes the first time.
Importing into a project
First, you need a model created in a graphics program (e.g., Blender) with an .fbx extension. To import the model into the project, drag it from its location into the Project Window. Once imported with default settings, left-click on the model and adjust the settings in the Inspector as follows:


![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/Object1.png)
![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/Object2.png)
Materials Setup/Fix

1. If no materials are shown (displayed as "None") in the second picture, click "Extract Materials." Unity will ask where to save them—choose any location, but remember where. We recommend using the "Universal Render Pipeline/Lit" material for modded objects. You may need to reattach the base map.

More information can be found in the video : Train Yard Builder Mods | Configure model materials

2. Remember about proper model light settings : Proper light setup

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/BaseMap.png)



Creating mods videos

Following links shows how to create models for Train Yard Builder, you can watch them or follow instructions below

Train Yard Builder Mods | Create a new building with grid to place Decorations
Train Yard Builder Mods | Create decorations 
Train Yard Builder Mods | Create Train 
Train Yard Builder Mods | Create new train cart


![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/BaseMap.png)
Creating mods on your own

Creating a prefab variant

Enter CustomAssetsCreation > Prefabs, then click the right mouse button on a file of an object that you want to create (Tracks, Building, Decoration, Train or Train Carriage). From the displayed menu select “Create/Prefab Variant”.

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/CreatePrefabVariant.png)
You can rename the new Prefab Variant right after creation or by right-clicking it and selecting "Rename."


Double-click the created Prefab Variant. All modifications to your object should be done using this view.

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/Prefab%20window.png)

Click the top-most GameObject and locate the "Grid Object Data" component in the Inspector. If it's missing, click "Add Component" at the bottom, search for "Grid Object Data," and click it to add it to the Inspector.

IMPORTANT - In the "Grid Object Data" component, generate a new GUID by clicking the "Create new" button next to the GUID property. Each object must have a unique GUID as it serves as the object's address. If two objects share the same GUID, only one will load in the game.

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/GridObjectData.png)

Grid Object Data setup
Localized name 
Click the plus button to add a new localized name. Add “Locale Id” and “Name” for each language you want to support. 

Supported Ids - English: en, French: fr, Italian: it, German: de, Spanish: es-ES, Polish: pl, Russian: ru, Simplified Chinese: zh, Japanese: jp, Korean: ko, Portuguese: pt-PT, Brazilian Portuguese: pt-BR, Turkish: tr, Czech: cs, Romanian: ro, Hungarian: hu .

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/GridObjectData2.png)


Category
The category defines where the model will appear in the Inventory as well as sets certain object behaviors. Note that Train Carriages will appear in the same category as Trains.

Price
How much the model costs. We suggest a lower three-digit range for locomotives, higher two-digit range for carriages and buildings, lower two-digit range for roads and tracks and one digit range for decorations. 

Can Only Rotate 90 Degrees
If unchecked, the object will rotate freely.

Tags
Defines which object tags will be applied for model filtering. Any object you create will automatically receive the "User Made" tag (in-game), in addition to the tags you select for your model.

Valid Placement Layers
Layers where an object can be placed. For example, if Valid Placement Layers are set to Rails, the object can only be placed on rails. If set to Rails and Default, the object can be placed on both rails and a table. The layer-object type correlations are:
Building = Default
Rails = Default
Decoration = Default
Train = Rails
Train Carriage = Rails

Can Be Dirty
If the object is intended to integrate with the cleaning system, check this box. You will need to regenerate the pictures afterward to create additional "dirty" object icons. Instructions for generating photos are provided later in the document.

Collider setup 
If the selected Category is “Tracks”, skip this step.
In your Prefab Variant hierarchy, select the GameObject named “Collider” to view the “Box Collider” and “Collider Size Settings” components. Adjust the “Size On Grid X” and “Size On Grid Y” values to determine how many cells the object will occupy on the table. As you modify these values, the red box should resize accordingly. Set the red box size to roughly match the proportions of the object you want to create.
Mesh setup 
If the selected Category is “Tracks”, skip this step.

In your Prefab Variant hierarchy, locate the “Mesh” GameObject and drag your recently imported 3D model onto it. Then, adjust the position, rotation, and scale of the “Mesh” GameObject to fit your model within the red box set up earlier in the Collider setup step.

To move, rotate and scale:
Click F to focus on Game Object. 
Click the appropriate icon in the scene view or use shortcuts:
Move - W, 
Rotate - E, 
Scale - R.
 ![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/How%20to%20rotate.png)
Adjust values either within the Transform section of the Inspector or by manipulating the model using the RGB controls in the Scene.

You might need to adjust the “Size On Grid X” and “Size On Grid Y” values to find the best fit for your model. Repeat the process until your model fits well within the red box.
Models in the game can include the LODGroup component, which renders less detailed versions of 3D models based on camera distance. Attach each 3D model to the appropriate LOD level, indicated by tinted bars in the LOD Group Component.

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/LODGroup.png)

“LOD0” is rendered when the camera is closest to the object. 

IMPORTANT - Model should consist of no more than 10 000 vertices to keep high quality.

After you set up the mesh, change Light Probes to “Off” in the Mesh Renderer Component as well as Rendering Layer Mask to Light Layer 2.
![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/mesh.png)

Grid Setup 
If the selected Category is “Tracks”, skip this step.

Grids are necessary if your object should allow placing another object on top, like a person on a building. To add grids:
Create a new child GameObject by right-clicking the top-most GameObject and selecting “Create Empty” from the menu. Name it something convenient, like “Grid.”

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/CreateEmpty.png)
Click "Add Component," search for "Grid Settings" in the input field, and then select "Grid Settings" from the list.

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/GridSettings.png)
Set up the values in "Grid Settings" 
Cell Count X and Cell Count Y: Define the number of grid cells.
Grid Subdivision: Determines the cell size (1 for normal size, 2 for half the size).
Placement Layer: Specifies the grid's layer, allowing placement of objects that have matching "Valid Placement Layers" in the "Grid Object Data."
Linking Sides: Defines which sides can link with other grids to form a larger grid.

A blue rectangle will display the grid size. Move the “Grid” Game object to the place where you want the grid to be.

You can position the grid wherever you want Decorations to be placed (e.g., on top of a building or a balcony), and you can create as many grids on one object as needed.

Train setup
If the created object “Category” is a Train, under the “Grid Object Data” component there will be a “Train Settings” component. 

Train forward direction is aligned with a root object blue arrow. Train that faces the same direction as the blue arrow.

The scale of the train in the x axis must fit in one unit. Do not exceed the value 1 in the field “Size on Grid X” in the “Collider Size Settings” component.

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/Train1.png)
Adjust the positions of the "FrontWheelsPosition" and "BackWheelsPosition" objects to align with the wheels on your 3D model, ensuring the model is oriented along the z-axis.

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/Train2.png)
Position the "FrontDetectorPosition" object in front of the train model to detect objects ahead.

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/Train3.png)
Move the "IndicatorPosition" object above the train to set the icon's location when using the remote.

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/Train4.png)
To enable smoke effects, check the "HaveSmoke" option in the "TrainSettings" component and correctly position the "SmokePosition" object.
![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/Train5.png)

If you want the train to have lights, activate the “Emission” field in the train's material and add an “Emission Map” texture. “Emission Map” texture corresponds to places on the train where there are lights. Lights should be disabled by default, so “Emission Map’s” color should be black. Set "Global Illumination" to “Realtime.”
![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/EmmisionMap.png)

Track setup

If the created object's "Category" is set to Tracks, a “Track Settings” component will appear under the “Grid Object Data” component. The "Track Offset from Ground" option adjusts the height of the track model from its root GameObject.

Under the root GameObject, the "Mesh" GameObject contains the grid of the selected rails.
To change the rail appearance, select the desired rail type from the “Track” folder, create a “Prefab Variant” from it, and modify the grid object, materials, or textures. Ensure the rail’s shape remains consistent with the original object.

Adding a photo

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/AddPhoto1.png)

When you have finished setting up the object, click on “Tools/Take Photo.”

Select the created object by either using the small circle button or by dragging and dropping the object into the provided field.
![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/AddPhoto2.png)
When you assign the created object, the "Take Photos" button will appear.
If the assigned object’s "Category" is Tracks, a “preview track index” field will also show up. This field determines which track shape is used for test photos to set the photo angle for all track shapes.
Click the "Take Photos" button and wait for 10-20 seconds for the photos to generate.

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/AddPhoto3.png)

Select the best looking photo.

Finishing up
Add created object to corresponding “Asset Bundle” group, which will allow you to export your objects as separate files having the same name as “Asset Bundle” group. You can create new groups via the “New” button. You can create an unlimited number of groups.

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/Bundle1.png)

Click “Assets/Build Asset Bundles”.

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/Bundle2.png)
Wait for build completion.





Adding your new model into the game
Right-click on the “StreamingAssets” folder in the Project window and select “Show in Explorer” to open a window with the newly created mod files.
Move all files named after your bundle (excluding files named “StreamingAssets”) from “Assets/StreamingAssets/” to “<PathToGame>/Train Yard Builder_Data/InactiveMods”.

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/AddBundleToGame.png)

Run the game and press the “Mods” button in the menu. If your bundle is set up correctly, your mod should appear in the list. To activate it, click on your mod and move it to the “Active Mods” list.

Uploading mods to Steam Workshop
To upload your mod to the workshop, select it from the list and click “Upload to the Workshop”.

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/Upload.png)

Downloading mods from Steam Workshop

To download mods from the Workshop, you need to subscribe to them in steam Workshop. After launching the game, the mod should automatically download and be placed in the "Inactive" tab. If the mod doesn’t appear in the "Inactive" tab, try clicking the "Refresh" button in the top right corner.

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/AddMod.png)

If we want the mod to load into the game, we need to select it and move it to the "Active" tab by clicking on the arrows.

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/AddMod2.png)

Uploading table mods To Steam Workshop
To add table mods from the game to the steam workshop, we have to access Table Management in Sandbox Mode. Then, in the "Store Tables" category, we can store the table and  see our saved table presets. 

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/UploadWorkshop.png)

Next, click the Steam Workshop icon to initiate the upload.

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/UploadWorkshop2.png)

When popup occurs, click yes to accept the uploading

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/UploadWorkshop3.png)

Uploading diorama mods to Steam Workshop
To add diorama mods in the game, we need to access the Diorama Table in Sandbox Mode. In the "Dioramas" category, we will see all the dioramas we have created.

![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/UploadDiorama.png)

Next, click the Steam Workshop icon to initiate the upload.
![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/UploadDiorama2.png)

When popup occurs, click yes to accept the uploading
![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/UploadDiorama3.png)
FAQ
My mod only appears in Sandbox mode.
For balancing reasons we only support modding in Sandbox mode.

My material does not look correct.
We support materials with Universal Render Pipeline shaders. Please choose a shader from this group.

I do not see any red box.
If you do not see the red box - enable gizmos in the Scene window. 
![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/RedBox.png)
If, after enabling gizmos, you still do not see the red box, check if the 'Collider' and 'Mesh Root GameObject' are assigned in the 'Collider Size Settings' component.  
![](https://github.com/pawelGF/TrainYardBuilderModdingTools/blob/main/Gifs/ColliderMesh.png)

If they are not assigned, the object will not be loaded in the game.


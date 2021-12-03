# This is the tiled project for map generation
Tilemap generation is disabled in the addon due to limitation of Tilemap node in Godot

# HowTos:
## Import the map objects
Just drag the tmx file into the scene tree
![test7](https://user-images.githubusercontent.com/16952886/144600590-c090b791-2677-47c7-a573-fb71992cc803.gif)

## Update the map objects
To make sure the map is updated correctly remove the previous version, reimport the tmx file and Import it again
![test8](https://user-images.githubusercontent.com/16952886/144600883-bd075714-0c70-42e1-beab-1d3177298e67.gif)


## Add objects on the map
In Tiled, drag tx files onto the map
![test9](https://user-images.githubusercontent.com/16952886/144600987-8ac40d7e-a56c-42c8-b6c2-6dfafa2492ab.gif)


## Update the ground sprite
In Tiled, hide the object layer and export visible layers as a png. Import it as a sprite in your scene. The sprite should not be centered

# Known limitations
 - Ignores ground collision shapes
 - No animated tiles

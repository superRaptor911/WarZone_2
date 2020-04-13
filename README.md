# WarZone_2
A 2D multiplayer shooter made using [Godot](https://godotengine.org/)

## Installing
Open terminal at desired directory and enter
```
git clone --depth 1 https://github.com/superRaptor911/WarZone_2.git
cd WarZone_2
```
You need gdnative c++ plugins to run this project.
You can build them for your system or download precompiled plugins.

You can download pre compiled plugins [here](https://drive.google.com/open?id=1GGgfn0B4uP7YzqoVRyOM4KplnBunhXW5) and paste ```bin ``` folder to base directory.

OR

You can build them (For linux users only).
To build plugins, you’ll need run `setup.sh` script present in `Gdnative` folder :
This script will install required tools and will build plugins.

```
cd Gdnative
sudo ./setup.sh
```
Then import as Godot project.

## Build With
* [Godot](https://godotengine.org/) - open source game engine
* [SCons](https://scons.org/) - build tool

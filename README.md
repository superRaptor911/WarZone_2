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

You can download pre compiled plugins [here](https://github.com/superRaptor911/WarZone_2/archive/libs.zip) and paste ```bin ``` folder to base directory.

OR

You can build them (For linux users only).
To build plugins there are a few prerequisites you’ll need:
* [SCons](https://scons.org/) as a build tool.
* C++ compiler
* Android NDK (optional, only needed if you are building for android)

After downloading the prerequisites, It's time to run build script present in  ``` Gdnative ``` folder to do that
```
cd Gdnative
mkdir -p output/bin/
cd godot-cpp
scons platform=linux -j4
cd ..
./build.sh
```
After the script execution you should get ``` operation 0 completed successfully ( LINUX ) ```.

Then import as Godot project.

## Build With
* [Godot](https://godotengine.org/) - open source game engine
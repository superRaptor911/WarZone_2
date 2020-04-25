# WarZone_2
A 2D multiplayer shooter made using [Godot](https://godotengine.org/) for android.
This game is inspired by counter strike and [CS2D](https://store.steampowered.com/app/666220/CS2D/)


![Screenshot from 2020-04-22 19-58-04](https://user-images.githubusercontent.com/58220198/80273921-2048b700-86f4-11ea-82df-d7d429d13270.png)
![Screenshot from 2020-04-22 19-54-57](https://user-images.githubusercontent.com/58220198/80273931-3fdfdf80-86f4-11ea-98d0-a287780d115d.png)
![Screenshot from 2020-04-22 19-54-19](https://user-images.githubusercontent.com/58220198/80273996-dc09e680-86f4-11ea-8d64-7b027a1538c4.png)
![Screenshot from 2020-04-22 19-58-27](https://user-images.githubusercontent.com/58220198/80274000-e6c47b80-86f4-11ea-894c-31cb6a3660cf.png)


## Installing
Open terminal at desired directory and enter
```
git clone --depth 1 https://github.com/superRaptor911/WarZone_2.git
cd WarZone_2
```
You need gdnative c++ plugins to run this project.
You can build them for your system or download precompiled plugins.

You can download pre compiled plugins [here](https://drive.google.com/open?id=1gHfod0AtoYsMgnV2SEeO8s3Q_v7IXEBO) and paste ```bin ``` folder to base directory.

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

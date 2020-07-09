# WarZone_2
A 2D multiplayer shooter made using [Godot](https://godotengine.org/) for android.
This game is inspired by counter strike and [CS2D](https://store.steampowered.com/app/666220/CS2D/)


![Screenshot from 2020-07-09 21-10-57](https://user-images.githubusercontent.com/58220198/87061420-5abced00-c229-11ea-89da-9b071f300367.png)
![Screenshot from 2020-07-09 21-11-11](https://user-images.githubusercontent.com/58220198/87061428-5c86b080-c229-11ea-80ce-105c03d07322.png)
![Screenshot from 2020-07-09 21-11-46](https://user-images.githubusercontent.com/58220198/87061432-5db7dd80-c229-11ea-89f4-bad1480a5f0e.png)
![Screenshot from 2020-07-09 21-11-59](https://user-images.githubusercontent.com/58220198/87061442-5ee90a80-c229-11ea-9faf-1b140e66e1c4.png)


<p align="center">
    <img src="https://raw.githubusercontent.com/superRaptor911/WarZone_2/master/Resources/Logo.png" height="100" width="100"/>
    <h1 align = "center">Signum - the free and open-source text editor!</h1>
</p>
<p align="center">
    Made by Mint Studios with the Godot Engine, written in GDScript!
</p>
 <p align="center">  
    <img src="https://i.postimg.cc/HL5kSNqh/Annotation-2020-06-07-181537.png" alt="Signum" />
</p>
<p align="center">
    <img src="https://github.com/superRaptor911/WarZone_2/workflows/godot-ci%20export/badge.svg" alt="Signum" />
</p>
<p align="center">
    <img src="https://img.shields.io/github/repo-size/MintStudios/signum"/>
    <img src="https://img.shields.io/github/downloads/superRaptor911/WarZone_2/total?color=lightgreen"/>
    <img src="https://img.shields.io/github/license/superRaptor911/WarZone_2?color=Red"/>
    <img src="https://img.shields.io/github/issues/superRaptor911/WarZone_2"/>
</p>
<p align="center">
    <img src="https://img.shields.io/github/v/release/mintstudios/signum?include_prereleases"/>
    <img src="https://img.shields.io/github/commits-since/mintstudios/signum/latest?include_prereleases"/>
</p>
<p align="center">
    <img src="https://img.shields.io/github/forks/superRaptor911/WarZone_2?style=social"/>
    <img src="https://img.shields.io/github/stars/superRaptor911/WarZone_2?style=social"/>
    <img src="https://img.shields.io/github/watchers/mintstudios/Signum?style=social"/>
</p>


## Installing
Open terminal at desired directory and enter
```
git clone --depth 1 https://github.com/superRaptor911/WarZone_2.git
cd WarZone_2
```
You need gdnative c++ plugins to run this project.
You can build them for your system or download precompiled plugins.

You can download pre compiled plugins [here](https://drive.google.com/open?id=11fYFJB2msNdvu3ShsLR-GuxwOZSoA37d) and paste ```bin ``` folder to base directory.

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

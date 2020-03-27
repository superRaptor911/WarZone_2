#!/bin/bash

msg_buffer="------------------Raptor--inc-------------Dev-Setup--------"


printBuffer()
{
	msg_buffer=$msg_buffer"\n"$1
	clear
	echo -e "$msg_buffer"
}

installGodotCpp()
{
	clear
	printBuffer "Downloading godot cpp bindings"
	rm -rf godot-cpp
	wget "https://github.com/GodotNativeTools/godot-cpp/archive/master.zip"
	
	if [[ $? -eq 0 ]]; then
		unzip master.zip
		mv godot-cpp-master godot-cpp
		rm master.zip
	else
		printBuffer "Error : failed to download godot cpp bindings"
		return 1
	fi

	cd godot-cpp
	wget -O "master.zip" "https://github.com/GodotNativeTools/godot_headers/archive/ddf67cc7b8274c5fb77a71c828bab2991f1ee12a.zip"
	if [[ $? -eq 0 ]]; then
		unzip master.zip
		rm -rf godot_headers
		mv godot_headers-ddf67cc7b8274c5fb77a71c828bab2991f1ee12a godot_headers
		rm master.zip
	else
		printBuffer "Error : failed to download godot cpp bindings"
		return 1
	fi

	printBuffer "Successfully installed godot cpp bindings"
}


installTools()
{
	tools=(unzip scons)
	for i in ${tools[@]}; do
		if ! [ -x "$(command -v $i)" ]; then
			printBuffer "$i not installed .. Installing $i"
			sudo apt install unzip
			if [[ $? -ne 0 ]]; then
				printBuffer "Error unable to install $i"
			fi
		else
			printBuffer "$i already installed"
		fi
	done
}

buildCppBindings()
{
	cd godot-cpp
	printBuffer "Compiling for Linux"
	!(scons platform=linux generate_bindings=yes bits=64 target=release -j4) && exit 1
	printBuffer "Compiling for Windows"
	!(scons platform=windows generate_bindings=yes bits=64 target=release -j4) && exit 1
	clear
	echo "Do you want to generate bindings for android? (y/n)"
	read ans
	if [[ "$ans" != "y" ]]; then
		return 0
	fi

	echo "Okay,Ready to build bindings for android......."
	echo "Please input Android NDK path (example : /home/raptor/Android/Sdk/ndk/21.0.6113669)"
	read ndk_path

	android_archs=(x86 x86_64 armv7 arm64v8)
	for i in ${android_archs[@]}; do
		!(scons platform=android generate_bindings=yes ANDROID_NDK_ROOT="$ndk_path" target=release android_arch=$i -j4) && exit 1
		printBuffer "Compiled for Android $i"
	done
	cd ..
}

buildWarzonePlugins()
{
	printBuffer "Building WarZone 2 plugins"
	cd src
	for i in */; do
		plugin="${i:0:${#i}-1}"
		cd ..
		./build.sh $plugin
		cd src
		printBuffer "Compiled $plugin"
	done
}

main()
{
	installTools
	installGodotCpp
	buildCppBindings
	buildWarzonePlugins	
}
######################################Starts Here#####################################
main
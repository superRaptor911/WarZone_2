#!/bin/bash
start_time=`date +%s`

copy_dest=".."
source=$1
build_result=0
no_patforms=6
exit_on_error=1

#build arguments
args[0]="platform=linux target_name=${source} src_path=src/${source} target=release"
args[1]="platform=android android_arch=armv7 target_name=${source} src_path=src/${source} android_stl=yes target=release"
args[2]="platform=android android_arch=arm64v8 target_name=${source} src_path=src/${source} android_stl=yes target=release"
args[3]="platform=android android_arch=x86 target_name=${source} src_path=src/${source} android_stl=yes target=release"
args[4]="platform=android android_arch=x86_64 target_name=${source} src_path=src/${source} android_stl=yes target=release"
args[5]="platform=windows target_name=${source} src_path=src/${source} target=release"

#platforms
plats[0]="LINUX"
plats[1]="Android armv7"
plats[2]="Android arm64v8"
plats[3]="Android x86"
plats[4]="Android x86_64"
plats[5]="windows"

result=()

build_targets() 
{
	scons $1 -j4
	if [ $? -eq 0 ]; then
		result+="operation $2 completed successfully ( ${plats[i]} )\n"
		build_result+=1
	else
	    exit 1
	fi
}

build_plugin()
{
	for (( i = 0; i < 6; i++ )); do
		build_targets "${args[i]}" "${i}"
	done

	echo
	echo
	echo operation result -----------------------------------

	for (( i = 0; i < 6; i++ )); do
		printf "${result[i]}"
	done

	echo operation result -----------------------------------
	echo
	echo

	if [[ build_result -ne 0 ]]; then
		cp -r output/bin ${copy_dest}
		echo copied libs to ${copy_dest}
	fi	
}

##############################Starts here#######################


clear
mkdir -p output/bin

build_plugin

end_time=`date +%s`
runtime=$((end_time-start_time))

echo "All processes were done in $runtime seconds"
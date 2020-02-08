#!/bin/bash
start_time=`date +%s`

copy_dest="/home/raptor/Documents/softwares/godot/projects/WarZone_2"
build_result=0

#build arguments
args[0]="platform=linux target_name=charMovement src_path=src/charMovement "
args[1]="platform=android android_arch=armv7 target_name=charMovement src_path=src/charMovement android_stl=yes"
args[2]="platform=android android_arch=arm64v8 target_name=charMovement src_path=src/charMovement android_stl=yes"
args[3]="platform=android android_arch=x86 target_name=charMovement src_path=src/charMovement android_stl=yes"
args[4]="platform=android android_arch=x86_64 target_name=charMovement src_path=src/charMovement android_stl=yes"



result=()

build_targets() 
{
	scons $1 -j4
	if [ $? -eq 0 ]; then
		result+="operation $2 completed successfully\n"
		build_result+=1
	else
	    result+="operation $2 failed\n"
	    exit 1
	fi
}

for (( i = 0; i < 5; i++ )); do
	build_targets "${args[i]}" "${i}"
done

echo
echo
echo operation result -----------------------------------

for (( i = 0; i < 5; i++ )); do
	printf "${result[i]}"
done

echo operation result -----------------------------------
echo
echo

if [[ build_result -ne 0 ]]; then
	cp -r output/bin ${copy_dest}
	echo copied libs to ${copy_dest}
fi


end_time=`date +%s`
runtime=$((end_time-start_time))

echo "All processes are done in $runtime seconds"
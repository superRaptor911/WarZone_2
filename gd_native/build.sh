#!/bin/bash
start_time=`date +%s`

source=$1
platforms=$2
ZipAndUpload=$3

copy_dest=".."
build_result=0
exit_on_error=1


#build arguments
args[0]="platform=linux target_name=${source} src_path=src/${source} target=release"
args[1]="platform=android android_arch=armv7 target_name=${source} src_path=src/${source} android_stl=yes target=release"
args[2]="platform=android android_arch=arm64v8 target_name=${source} src_path=src/${source} android_stl=yes target=release"
args[3]="platform=windows target_name=${source} src_path=src/${source} target=release"
args[4]="platform=android android_arch=x86 target_name=${source} src_path=src/${source} android_stl=yes target=release"
args[5]="platform=android android_arch=x86_64 target_name=${source} src_path=src/${source} android_stl=yes target=release"


#platforms
plats[0]="LINUX"
plats[1]="Android armv7"
plats[2]="Android arm64v8"
plats[3]="windows"
plats[4]="Android x86"
plats[5]="Android x86_64"

result=()

build_targets() {
    scons $1 -j4
    if [ $? -eq 0 ]; then
        result+="operation $2 completed successfully ( ${plats[i]} )\n"
        build_result+=1
        echo "Done ............."
    else
        exit 1
    fi
}

build_plugin() {
    #Build only for first 4 platforms
    for (( i = 0; i < 6; i++ )); do

        if [ "$platforms" == "" ] || [ "$platforms" == "${plats[i]}" ]
        then
            echo "$platforms"
            build_targets "${args[i]}" "${i}"
        fi
    done

    echo
    echo
    echo operation result -----------------------------------

    for (( i = 0; i < 4; i++ )); do
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

zip_N_upload()
{
    if [ "$ZipAndUpload" == "y" ] || [ "$ZipAndUpload" == "yes" ]
    then
        echo -e "bin.zip will be uploaded\n\t\tThis will take time........"
        cd ../
        zip -r Gdnative/tools/bin.zip bin && cd Gdnative/tools/ && ./uploadBinZip
        rm bin.zip
    fi

}

##############################Starts here#######################


clear
rm -rf output
mkdir -p output/bin

build_plugin
# zip_N_upload

end_time=`date +%s`
runtime=$((end_time-start_time))

echo "All processes were done in $runtime seconds"

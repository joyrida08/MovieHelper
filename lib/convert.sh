#! /bin/bash

####################################################################################
########################## License Agreement #######################################

    # MovieHelper - A tool that automates the naming and converting of video Files
    # Copyright (C) 2015  Ricky Grassmuck

    # This program is free software: you can redistribute it and/or modify
    # it under the terms of the GNU General Public License as published by
    # the Free Software Foundation, either version 3 of the License, or
    # (at your option) any later version.

    # This program is distributed in the hope that it will be useful,
    # but WITHOUT ANY WARRANTY; without even the implied warranty of
    # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    # GNU General Public License for more details.

    # You should have received a copy of the GNU General Public License
    # along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    # For questions feel free to email me at ricky.grassmuck<@>gmail.com

######################## End License Agreement #####################################
####################################################################################

verb=$1
working_dir=$2
cd $working_dir
spinner() { 
    local pid=$1 
    local delay=0.75
    local spinstr='|/-\' 
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do 
        local temp=${spinstr#?} 
        printf "Processing... [%c] " "$spinstr" 
        local spinstr=$temp${spinstr%"$temp"} 
        sleep $delay 
        printf "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"
    done 
    printf "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"
}

# FFMPEG does not play nice with files that have apostrophes in their names so we remove them here
bad_file=`ls | grep \'`
if [ ! -z "$badFile" ]; then
    find . -type f -name "*'*" -print0 | xargs -0 -L1 rename "'" ""
fi
if [ ! -d "$working_dir/converted_files/" ]; then
    mkdir "$working_dir/converted_files/"
fi
echo ""
echo "********** Getting ready for file conversion... ***********"
echo ""
total=`ls | egrep "*.(mkv|avi)$" | wc -l`
cnt=1
printf "Found %02d Files to Convert\n\n" $total

for i in *; do

    testavi=`echo "$i" | egrep "*.avi"`;
    testmkv=`echo "$i" | egrep "*.mkv"`;
    testdivx=`echo "$i" | egrep "*.divx"`;

    if [ "$testavi" == "$i" ]; then 
        new=`echo $i | sed -e 's/\.avi/\.mp4/'`

    elif [ "$testmkv" == "$i" ]; then
        new=`echo $i | sed -e 's/\.mkv/\.mp4/'`
    elif [ "$testdivx" == "$i" ]; then
        new=`echo $i | sed -e 's/\.divx/\.mp4/'`
    else
        continue
    fi

    printf "[%02d/$total] - $i\n" $cnt

    if [ "$verb" == "0" ]; then   
        ffmpeg -y -loglevel quiet -i "$i" -c copy "$new" &
        spinner $!
    else
        ffmpeg -y -i "$i" -c copy "$new"
    fi
    cnt=`expr $cnt + 1`

    newFileSize=`stat -c %s "$new"`
    fileSize=`stat -c %s "$i"`
    minFileSize=$[fileSize/5*4]
    echo "Cleaning up the mess"
    mv "$new" "$working_dir/converted_files"
    
    if [ $newFileSize -gt $minFileSize ]; then
        rm -f "$i" &
    fi

done  

echo "Complete!"

#!/bin/sh

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



APPDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
process_only=0
convert_only=0
alias filebot="sh $APPDIR/lib/filebot/filebot.sh"
alias convert_to_mp4="sh $APPDIR/lib/convert.sh"

if [ -f ${HOME}/.config/MovieHelper/defaults.conf ]; then
    . ${HOME}/.config/MovieHelper/defaults.conf
else
    . /etc/MovieHelper/defaults.conf
fi

envTest 

if [ "$envCheck" == "0" ]; then
    continue
else
    exit 0
fi

while test $# -gt 0; do
    case $1 in
        --config-file)
            shift
            if [ $# -gt 0 ]; then
                if [ -f "$1" ]; then
                    . "$1"
                    shift
                else
                    echo "config file does not exist"
                    exit 0
                fi
             else
                echo " Must provide a valid config file"
                exit
            fi
        ;;
        -w|--working-dir)
            shift
            if [ $# -gt 0 ]; then 
                if [ -d "$1" ]; then
                    working_dir="$1"
                    shift
                else
                    echo "Not a valid directory"
                    exit 1
                fi
            else
                echo "[ERROR] -w: not enough arguments"
                exit 1
            fi 
        ;;

        -i|--input-dir)
            shift
            if [ $# -gt 0 ]; then 
                if [ -d "$1" ]; then
                    input_dir="$1"
                    shift
                else
                    echo "Not a valid directory"
                    exit 1
                fi
            else
                echo "[ERROR] -i: not enough arguments"
                exit 1
            fi 
        ;;

        -c|--convert-only)
            shift
            convert_only=1
            process_only=0
        ;;
        -p|--process-only)
            shift
            convert_only=0
            process_only=1
        ;;
        -v|--verbosity)
            shift
            if [ $# -gt 0 ]; then
                if [ "$1" == "0" ] || [ "$1" == "1"]; then
                        verb=$1
                        shift
                else
                    echo "Invalid vebosity argument"
                    usage
                    exit 1
                fi
            else
                echo "-v requires one argument, 0 passed"
                exit 0
            fi
            ;;
        -h) 
            usage
            exit 0
            ;;
    esac
done

if [ ! -d "$working_dir" ]; then
    mkdir $working_dir
fi

process(){
    echo "Locating Movie Files..."
    find ${input_dir} -regextype posix-egrep -regex '.*.(mp4|divx|avi|mkv)$' -size +200M -print | xargs -I{} mv {} ${working_dir}
    filebot -script fn:renall ${working_dir} -non-strict --db TheMovieDB
    rm -rf ${input_dir}/*
}

if [ "$convert_only" == "1" ]; then
    convert_to_mp4 $verb $working_dir
elif [ "$process_only" == "1" ]; then
    process
else
    process
    convert_to_mp4 $verb $working_dir
fi


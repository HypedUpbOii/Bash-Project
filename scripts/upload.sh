#!/usr/bin/env bash

if [ -d $1 ]; then # upload files from directory if it exists
    echo "submission (upload): $1 is a directory."
    read -p "Upload all csv files from the directory? (y/n): " choice
    if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
        for i in $1/*.csv; do # iterate over all csv files
            if [ -f $(basename $i) ]; then
                echo "submission (upload): File $(basename $i) already exists."
                read -p "Overwrite the file? (y/n): " choice
                if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
                    cp $i $(pwd)
                else
                    echo "Aborted."
                fi
            else
                cp $i $(pwd)
            fi
        done
    else
        echo "Aborted."
    fi
elif [ ! -f $1 ]; then # check if file exists
    echo "submission (upload): No such file exists."
elif [ $(file $1 | grep -c "CSV") -eq 0 ]; then # check if file is a CSV file
    echo "submission (upload): File is not a CSV file."
    exit 1
elif [ -f $(basename $1) ]; then # check if file already exists
    echo "submission (upload): File already exists."
    read -p "Overwrite the file? (y/n): " choice
    if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
        cp $1 $(pwd)
    else
        echo "Aborted."
    fi
else # upload the file
    cp $1 $(pwd)
fi
#!/usr/bin/env bash

if [ ! -d .mygit ]; then # check if git is initialized
    echo "submission (git_commit): No remote repository has been initialized."
    exit 1
fi
prev_commit=$(tail -n 1 .mygit/Log | cut -d~ -f 1) # get the id of the previous commit
com_msg="$2"
loc=$(cat .mygit/Location) # get the location of the remote repository
if [ $1 == "-am" ]; then # add all csv files to the staging area
    rm .mygit/StagingArea/*.csv 2> /dev/null
    for i in *.csv; do
        if [ ! -f $loc/prev_commit/$i ]; then
            cp $i .mygit/StagingArea
        elif [ $(diff $i $loc/prev_commit/$i | wc -l) -eq 0 ]; then
            continue
        else
            cp $i .mygit/StagingArea
        fi
    done
elif [ $1 != "-m" ]; then # check if the option is valid
    echo "submission (git_commit): Invalid option."
    exit 1
fi
id=$(uuidgen | tr -d '-' | head -c 16) # generate a unique id
uniq_id=$(grep -e "$id" .mygit/Log)
until [ -z "$uniq_id" ]; do
    id=$(uuidgen | tr -d '-' | head -c 16)
    uniq_id=$(grep -e "$id" .mygit/Log)
done
echo "$id~$(date)~$com_msg" >> .mygit/Log # append the commit details to the log file
mkdir $loc/$id
echo "submission (git_commit): Changes committed with id $id"
for i in $(ls .mygit/StagingArea/*.csv); do # copy the files in the staging area to the commit directory
    if [ -f $loc/prev_commit/$(basename $i) ]; then
        patch_info=$(diff $loc/prev_commit/$(basename $i) $i)
        if [ ! -z "$patch_info" ]; then
            diff $loc/prev_commit/$(basename $i) $i > $(basename -s .csv $i).patch # create a patch file if different
            mv $(basename -s .csv $i).patch $loc/$id
            echo "Modified file: $(basename $i)"
            cp $i $loc/prev_commit
        fi
    else
        cp $i $loc/$id # copy the file to the commit directory if new
        echo "New file: $(basename $i)"
        cp $i $loc/prev_commit
    fi
done
echo "$id" > .mygit/Head
rm .mygit/StagingArea/*.csv
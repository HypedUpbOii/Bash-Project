#!/usr/bin/env bash

if [ ! -d .mygit ]; then # check if git is initialized
    echo "submission (git_add): No remote repository has been initialized."
    exit 1
fi
loc=$(cat .mygit/Location)
for i in $@; do
    if [ -f $i ]; then # check if file exists
        if [ $(file $1 | grep -c "CSV") -eq 0 ]; then
            echo "submission (git_add): $i is not a CSV file."
        elif [ ! -f $loc/prev_commit/$i ]; then # check if file is new
            cp $i .mygit/StagingArea
            echo "submission (git_add): Added $i to the staging area."
        elif [ $(diff $i $loc/prev_commit/$i | wc -l) -eq 0 ]; then # check if file has changed
            echo "submission (git_add): No changes recorded in $i. Skipped"
        else # copy file to staging area
            cp $i .mygit/StagingArea
            echo "submission (git_add): Added $i to the staging area."
        fi
    else
        echo "submission (git_add): $i does not exist."
    fi
done
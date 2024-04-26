#!/usr/bin/env bash

if [ ! -d .mygit ]; then # check if git is initialized
    echo "submission (git_remove): No remote repository has been initialized."
    exit 1
fi
for i in $@; do # remove files from the staging area
    if [ -f .mygit/StagingArea/$i ]; then
        rm .mygit/StagingArea/$i
        echo "submission (git_remove): Removed $i from the staging area."
    else
        echo "submission (git_remove): $i is not in the staging area."
    fi
done
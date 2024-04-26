#!/usr/bin/env bash

if [ $1 == $PWD ]; then # Check if the directory is the working directory
    echo "submission (git_init): Cannot initialize a remote repository in the working directory."
    exit 1
fi
if [ -f .mygit ]; then # Check if a git repository has already been initialized
    read -p "A git repository has already been initialized. Enter y to change the directory: " confirm
    if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ] || [ "$confirm" == "YES" ] || [ "$confirm" == "yes" ]; then
        mkdir -p $1
        cp -r $(cat .mygit/Location)/* $1
        rm -r $(cat .mygit/Location)
        echo "$1" > .mygit/Location
        exit 0
    else
        echo "Aborted."
        exit 1
    fi
    exit 1
elif [ ! -d $1 ]; then # If directory doesn't exist, create it
    mkdir -p $1
fi
mkdir .mygit # Create a hidden directory for the git repository
touch .mygit/Location
touch .mygit/Log
touch .mygit/Head
id=$(uuidgen | tr -d '-' | head -c 16) # Generate a unique id for the initial commit
echo "$id~$(date)~Initialised Remote Repository" > .mygit/Log # Log the initial commit
mkdir .mygit/StagingArea
echo "$(realpath $1)" > .mygit/Location
echo "$id" > .mygit/Head # Set the head to the initial commit
mkdir $1/$id
cp *.csv $1/$id 2>/dev/null # Copy all csv files to the initial commit
mkdir $1/prev_commit
cp *.csv $1/prev_commit 2>/dev/null
echo "Initialized empty git repository in $1"
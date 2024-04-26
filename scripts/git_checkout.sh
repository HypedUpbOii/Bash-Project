#!/usr/bin/env bash

if [ ! -d .mygit ]; then # check if git is initialized
    echo "submission (git_checkout): No remote repository has been initialized."
    exit 1
fi
com_id=$(grep -e "$1" .mygit/Log | cut -d~ -f 1)
num_options=$(echo "$com_id" | wc -w)
if [ -z "$com_id" ]; then # check if the commit id exists
    echo "submission (git_checkout): No commit matching with $1"
    exit 1
elif [ "$com_id" == "$(cat .mygit/Head)" ]; then # check if the commit is already checked out
    echo "submission (git_checkout): Already at commit $1"
    exit 1
elif [ $num_options -gt 1 ]; then # check if there are multiple commits with the same substring
    echo "submission (git_checkout): Multiple commits with substring $1"
    echo "Choose one of the following:"
    index=1
    for i in $com_id; do
        echo "$index: $i"
        index=$((index+1))
    done
    read -p "Enter line with correct commit id (Enter n to abort): " index # prompt the user to choose the commit id
    if [[ "$index" == "n" ]] || [[ "$index" == "N" ]]; then
        echo "Aborted."
        exit 1
    elif [[ $index =~ ^[0-9]+$ ]] && [ $index -le $num_options ] && [ $index -gt 0 ]; then # check if the input is valid
        com_id=$(echo $com_id | awk -v num=$index '{print $num}')
    else
        echo "Invalid input. Aborted."
        exit 1
    fi
fi
echo "Chosen commit with id $com_id"
loc=$(cat .mygit/Location)
echo "$com_id" > .mygit/Head
rm *.csv 2> /dev/null
rm .mygit/StagingArea/*.csv 2> /dev/null
commit=$(head -n 1 .mygit/Log | cut -d~ -f 1)
while read -r line; do # copy the files from the commit directory to the staging area
    commit=$(echo $line | cut -d~ -f 1) # get the commit id
    for i in $(ls $loc/$commit); do
        if [ $(echo $(basename $i) | cut -d. -f 2) == "csv" ]; then
            cp $loc/$commit/$(basename $i) .mygit/StagingArea/ # copy the csv files if new
        else
            patch -s .mygit/StagingArea/$(basename -s .patch $i).csv $loc/$commit/$(basename $i) # apply the patch files
        fi
    done
    if [ "$commit" == "$com_id" ]; then
        break
    fi
done < .mygit/Log
mv .mygit/StagingArea/*.csv .
rm $loc/prev_commit/*.csv
cp *.csv $loc/prev_commit
#!/usr/bin/env bash

#1st line = commit id
#2nd line = commit time
#3rd line = commit message

if [ ! -d .mygit ]; then # check if git is initialized
    echo "submission (git_log): No remote repository has been initialized."
    exit 1
fi
tac .mygit/Log > .mygit/revLog # reverse the log file
while IFS= read -r line; do
    id=$(echo $line | cut -d~ -f 1)
    com_time=$(echo $line | cut -d~ -f 2)
    com_msg=$(echo $line | cut -d~ -f 3-)
    # print the commit details
    echo -e "commit:\t $id"
    echo -e "Date:\t $com_time"
    echo -e "\n"
    echo -e "\t\t$com_msg"
    echo -e "\n"
done < .mygit/revLog
rm .mygit/revLog
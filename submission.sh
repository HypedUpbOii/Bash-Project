#!/usr/bin/env bash

export MAIN="main.csv"

case "$1" in
    "")
        # No command provided
        echo -e "Usage: bash submission.sh <command> <arguments>"
        echo -e "Try 'bash submission.sh --help' for more information."
        exit 1
        ;;
    "--help")
        # help page
        echo -e "Usage: bash submission.sh <command> <arguments>"
        echo -e "Helps with management of csv files in the current directory and various other operations."
        echo -e ""
        echo -e "combine:\tCombines all the csv files in the current directory into a single csv file."
        echo -e "total:\t\tAdds a total column to the main csv file."
        echo -e "update:\t\tUpdates the marks of a student in all the csv files."
        echo -e "upload:\t\tUploads a file to the current directory."
        echo -e "git_init:\tInitializes a git repository in some directory."
        echo -e "git_checkout:\tChecks out a branch in the git repository."
        echo -e "git_commit:\tCommits the changes in the git repository."
        echo -e "git_add:\tAdds files to the staging area."
        echo -e "git_remove:\tRemoves files from the staging area."
        echo -e "git_log:\tShows the git log."
        echo -e "statistics:\tShows statistics of the csv files."
        echo -e "graphs:\t\tGenerates graphs for the csv files."
        echo -e "grades:\t\tGenerates grade distribution for the csv files."
        echo -e "report:\t\tGenerates a report card for a student."
        exit 0
        ;;
    "combine")
        if [ $# -gt 1 ]; then # check for number of arguments
            echo -e "submission (combine): No arguments required."
            exit 1
        fi
        if [ $(ls *.csv 2> /dev/null | wc -l) -eq 0 ]; then # check for csv files
            echo -e "submission (combine): No csv files found."
            exit 1
        fi
        has_total=false # check if total column is present
        if [ -f $MAIN ]; then
            total_check=$(head -n 1 $MAIN | awk -F, '{print $NF}')
            if [ "$total_check" == "total" ]; then
                has_total=true
            fi
        fi
        bash ./scripts/combine.sh
        if [ $has_total == true ]; then # re-add total column if present
            touch temp
            awk -f ./scripts/total.awk $MAIN > temp
            cat temp > $MAIN
            rm temp
        fi
        exit 0
        ;;
    "total")
        if [ $# -gt 1 ]; then # check for number of arguments
            echo -e "submission (total): No arguments required."
            exit 1
        fi
        if [ ! -f $MAIN ]; then # check for main csv file
            echo "submission (total): No main csv file found."
            exit 1
        fi
        touch temp.csv
        awk -f ./scripts/total.awk $MAIN > temp.csv
        cat temp.csv > $MAIN
        rm temp.csv
        exit 0
        ;;
    "update")
        if [ $# -gt 1 ]; then # check for number of arguments
            echo -e "submission (update): No arguments required."
            exit 1
        fi
        bash ./scripts/update.sh
        if [ -f $MAIN ]; then # re-evaluate total column if present
            total_check=$(head -n 1 $MAIN | awk -F, '{print $NF}')
            if [ "$total_check" == "total" ]; then
                touch temp
                awk -f ./scripts/total.awk $MAIN > temp
                cat temp > $MAIN
                rm temp
            fi
        fi
        exit 0
        ;;
    "graphs")
        if [ $# -gt 1 ]; then # check for number of arguments
            echo -e "submission (graphs): No arguments required."
            exit 1
        fi
        bash ./scripts/combine.sh 1> /dev/null
        awk -f ./scripts/total.awk $MAIN > temp # makes information up-to-date
        cat temp > $MAIN
        rm temp
        mv ./graphs/default.png .
        rm ./graphs/*.png 2> /dev/null
        mv default.png ./graphs # remove old graphs
        python3 ./customizations/graphs.py
        xdg-open ./customizations/graphviewer.html 2> /dev/null # opens the graph viewer
        exit 0
        ;;
    "grades")
        if [ $# -gt 1 ]; then # check for number of arguments
            echo -e "submission (grades): No arguments required."
            exit 1
        fi
        bash ./scripts/combine.sh 1> /dev/null
        awk -f ./scripts/total.awk $MAIN > temp # makes information up-to-date
        cat temp > $MAIN
        rm temp
        python3 ./customizations/grade_distribution.py # generates grade distribution
        exit 0
        ;;
    "report")
        if [ $# -gt 1 ]; then # check for number of arguments
            echo -e "submission (report): No arguments required."
            exit 1
        fi
        bash ./scripts/combine.sh 1> /dev/null
        awk -f ./scripts/total.awk $MAIN > temp # makes information up-to-date
        cat temp > $MAIN
        rm temp
        read -p "What is the roll number of the student whose report card you wish to generate? " rollnum # get roll number
        if [ -z $rollnum ]; then
            echo -e "submission (report): No roll number entered."
            exit 1
        elif [ $(grep -ic $rollnum $MAIN) -eq 0 ]; then
            echo -e "submission (report): No such roll number found."
            exit 1
        elif [ $(grep -ic $rollnum $MAIN) -gt 1 ]; then # choosing between multiple roll numbers
            echo -e "submission (report): Multiple entries found for the roll number.\n"
            alternatives=$(grep -ie "$rollnum" "$MAIN" | cut -d, -f 1)
            index=1
            for i in "$alternatives"; do
                echo "$index: $i"
                index=$((index+1))
            done
            read -p "Enter line with correct roll number (Enter n to abort): " index
            if [[ "$index" == "n" ]] || [[ "$index" == "N" ]]; then
                echo -e "submission (report): Aborted."
                exit 1
            elif [[ $index =~ ^[0-9]+$ ]] && [ $index -le $(echo "$alternatives" | wc -l) ] && [ $index -gt 0 ]; then # check for valid input
                rollnum=$(echo "$alternatives" | awk -v num=$index '{print $num}' | cut -d, -f 1)
                echo -e "Chosen student with roll number $rollnum"
            else
                echo -e "submission (report): Invalid input. Aborted."
                exit 1
            fi
        fi
        python3 ./customizations/report.py $rollnum # generate report card
        cp ./customizations/student_report.tex ./reportcards
        cd ./reportcards
        pdflatex student_report.tex 1> /dev/null # compile report card
        rm student_report.aux student_report.log student_report.tex
        mv student_report.pdf $rollnum.pdf
        xdg-open $rollnum.pdf 2> /dev/null # open report card
        cd ..
        exit 0
        ;;
    "git_log")
        if [ $# -gt 1 ]; then # check for number of arguments
            echo -e "submission (git_log): No arguments required."
            exit 1
        fi
        bash ./scripts/git_log.sh
        exit 0
        ;;
    "git_add")
        if [ $# -lt 2 ]; then # check for number of arguments
            echo -e "submission (git_add): No files provided."
            exit 1
        fi
        bash ./scripts/git_add.sh "${@:2}"
        exit 0
        ;;
    "upload")
        if [ $# -gt 2 ]; then # check for number of arguments
            echo -e "submission (upload): Please provide only one file."
            exit 1
        elif [ $# -lt 2 ]; then
            echo -e "submission (upload): No file provided."
            exit 1
        fi
        bash ./scripts/upload.sh $2
        exit 0
        ;;
    "git_init")
        if [ $# -lt 2 ]; then # check for number of arguments
            echo -e "submission (git_init): No directory provided."
            exit 1
        elif [ $# -gt 2 ]; then
            echo -e "submission (git_init): Too many arguments."
            exit 1
        fi
        bash ./scripts/git_init.sh $2
        exit 0
        ;;
    "git_checkout")
        if [ $# -lt 2 ]; then # check for number of arguments
            echo -e "submission (git_checkout): No commit id provided."
            exit 1
        elif [ $# -gt 2 ]; then
            echo -e "submission (git_checkout): Too many arguments."
            exit 1
        fi
        bash ./scripts/git_checkout.sh $2
        exit 0
        ;;
    "git_commit")
        if [ $# -lt 3 ]; then # check for number of arguments
            echo -e "submission (git_commit): No commit message provided."
            exit 1
        elif [ $# -gt 3 ]; then
            echo -e "submission (git_commit): Too many arguments."
            exit 1
        fi
        bash ./scripts/git_commit.sh $2 "$3"
        exit 0
        ;;
    "git_remove")
        if [ $# -lt 2 ]; then # check for number of arguments
            echo -e "submission (git_remove): No files provided."
            exit 1
        fi
        bash ./scripts/git_remove.sh "${@:2}"
        exit 0
        ;;
    "statistics")
        if [ $# -lt 2 ]; then # check for number of arguments
            echo -e "submission (statistics): No file provided."
            exit 1
        elif [ $# -gt 2 ]; then
            echo -e "submission (statistics): Too many arguments."
            exit 1
        fi
        if [ "$2" == "$MAIN" ]; then # case for showing all statistics
            if [ $(ls *.csv 2> /dev/null | wc -l) -eq 0 ]; then
                echo -e "submission (statistics): No csv files found."
                exit 1
            fi
            bash ./scripts/combine.sh 1> /dev/null
            awk -f ./scripts/total.awk $MAIN > temp
            for i in $(ls *.csv); do # show statistics for each csv file
                if [ $i != $MAIN ]; then
                    echo -e "\nStatistics for $i"
                    awk -f ./customizations/statistics.awk $i
                fi
            done
            echo -e ""
            echo "Overall Statistics"
            awk -f ./customizations/statistics.awk temp # show statistics for total marks
            rm temp
            echo -e ""
        elif [ -f $2 ]; then
            echo -e "\nStatistics for $(basename $2 .csv)" # show statistics for a single csv file
            awk -f ./customizations/statistics.awk $2
            echo -e ""
        else
            echo -e "submission (statistics): No such file '$2'."
        fi
        exit 0
        ;;
    *)
        # invalid command
        echo -e "submission: No such command '$1'."
        echo -e "Try 'bash submission.sh --help' for more information."
        exit 1
        ;;
esac
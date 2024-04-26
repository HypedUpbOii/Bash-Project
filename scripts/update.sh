#!/usr/bin/env bash

read -p "Enter the roll number of the student: " rollnum
read -p "Enter the name of the student: " studname
if [ -f $MAIN ]; then # Backup MAIN file
    touch temp
    cat $MAIN > temp
    rm $MAIN
fi
files=( *.csv )
touch alternatives
for i in ${files[@]}; do # Check if student exists
    is_present=$(grep -ice "$rollnum,$studname" "$i")
    if [ $is_present -gt 0 ]; then
        rollnum=$(grep -ie "$rollnum,$studname" "$i" | cut -d, -f 1)
        studname=$(grep -ie "$rollnum,$studname" "$i" | cut -d, -f 2)
        break
    else
        matches=$(grep -ie "$rollnum" "$i" | cut -d, -f 1-2)
        if [ ! -z "$matches" ]; then
            echo "$matches" >> alternatives
        fi
        matches=$(grep -ie "$studname" "$i" | cut -d, -f 1-2)
        if [ ! -z "$matches" ]; then
            echo "$matches" >> alternatives
        fi
    fi
done
sort -u alternatives -o alternatives
if [ $is_present -eq 0 ]; then # Student not found
    if [ $(cat alternatives | wc -l) -gt 0 ]; then
        echo "The student is not present in the database."
        echo "Did you mean any of the following?"
        index=1
        while IFS= read -r line; do # Display alternatives
            echo "$index: $line"
            index=$((index+1))
        done < alternatives
        read -p "Enter line with correct roll number and name (Enter n to abort): " index
        if [[ "$index" == "n" ]] || [[ "$index" == "N" ]]; then
            echo "Aborted."
            if [ -f temp ]; then
                touch $MAIN
                cat temp > $MAIN
                rm temp
            fi
            rm alternatives
            exit 1
        elif [[ $index =~ ^[0-9]+$ ]] && [ $index -le $(cat alternatives | wc -l) ] && [ $index -gt 0 ]; then # Update roll number and name
            rollnum=$(sed -n -e "${index}p" alternatives | cut -d, -f 1)
            studname=$(sed -n -e "${index}p" alternatives | cut -d, -f 2)
            echo "Chosen student with roll number $rollnum and name $studname"
            rm alternatives
        else
            echo "Invalid input. Aborted."
            if [ -f temp ]; then
                touch $MAIN
                cat temp > $MAIN
                rm temp
            fi
            rm alternatives
            exit 1
        fi
    else
        echo "No such student exists."
        if [ -f temp ]; then
            touch $MAIN
            cat temp > $MAIN
            rm temp
        fi
        rm alternatives
        exit 1
    fi
else
    echo "Chosen student with roll number $rollnum and name $studname"
    rm alternatives
fi
read -p "Enter exam for which marks are to be updated: " exam
options=$(ls *.csv | grep -ie "$exam") # Check if exam exists
if [ -z "$options" ]; then
    echo "No such exam exists."
    if [ -f temp ]; then
        touch $MAIN
        cat temp > $MAIN
        rm temp
    fi
    exit 1
elif [ $(echo "$options" | wc -l) -gt 1 ]; then # Choosing between multiple exams
    echo "Multiple exams with substring $exam"
    echo "Choose one of the following:"
    index=1
    for i in $options; do
        echo "$index: $(basename -s .csv $i)"
        index=$((index+1))
    done
    read -p "Enter line with correct exam name (Enter n to abort): " index
    if [[ "$index" == "n" ]] || [[ "$index" == "N" ]]; then
        echo "Aborted."
        exit 1
    elif [[ $index =~ ^[0-9]+$ ]] && [ $index -le $(echo "$options" | wc -l) ] && [ $index -gt 0 ]; then # Update exam
        exam=$(echo $options | awk -v num=$index '{print $num}')
    else
        echo "Invalid input. Aborted."
        exit 1
    fi
else 
    exam=$options
fi
read -p "Enter marks for $rollnum in $(basename -s .csv $exam): " marks
if [[ $marks =~ ^[0-9]+(.[0-9]+)?$ ]]; then # Check if marks are valid
    if [ $(grep -ice "$rollnum,$studname" $exam) -eq 0 ]; then
        read -p "Add entry for $rollnum,$studname in $exam? (y/n): " confirm # Add entry if not present
        if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ] || [ "$confirm" == "YES" ] || [ "$confirm" == "yes" ]; then
            if [[ ! $(tail -c1 "$i" | wc -l) -gt 0 ]];then
                    echo "" >> $i
            fi
            echo "$rollnum,$studname,$marks" >> $exam
        else
            echo "Aborted."
            if [ -f temp ]; then
                touch $MAIN
                cat temp > $MAIN
                rm temp
            fi
            exit 1
        fi
    fi
    sed -i -e "s/$rollnum,$studname,.*/$rollnum,$studname,$marks/" $exam # Update marks of the exam
    exam=$(basename -s .csv $exam)

    if [ -f temp ] && [ $(grep -ice "$rollnum,$studname" temp) -gt 0 ] && [ $(head -n 1 temp | grep -ice "$exam") -gt 0 ]; then # Update MAIN file if present
        touch $MAIN
        index=0
        posn=0
        while IFS= read -r line; do
            if [ $index -eq 0 ]; then
                echo "$line" > $MAIN
                index=$((index+1))
                for i in $(echo "$line" | tr "," "\n"); do
                    if [ "$i" == "$exam" ]; then
                        posn=$index
                        break
                    fi
                    index=$((index+1))
                done
                if [ $posn -eq 0 ]; then
                    break
                fi
            elif [ $(echo "$line" | grep -ice "$rollnum,$studname") -gt 0 ]; then
                echo "$line" | awk -v marks="$marks" -v posn="$posn" -F, 'BEGIN{OFS=","}{$posn=marks; print $0}' >> $MAIN
            else
                echo "$line" >> $MAIN
            fi
        done < temp
        if [ $posn -eq 0 ]; then
            cat temp > $MAIN
        fi
        rm temp
    fi
else
    echo "Invalid input. Aborted."
    if [ -f temp ]; then
        touch $MAIN
        cat temp > $MAIN
        rm temp
    fi
    exit 1
fi
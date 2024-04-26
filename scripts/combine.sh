#!/usr/bin/env bash

# Backup existing MAIN file
if [ -f "$MAIN" ]; then
    mv "$MAIN" temp
fi

files=( $(ls *.csv 2> /dev/null) )
if [ ${#files[@]} -eq 0 ]; then # No files found
    echo "submission (combine): No files found to combine."
    if [ -f temp ]; then
        mv temp "$MAIN"
    fi
    exit 1
elif [ ${#files[@]} -eq 1 ]; then # Only 1 file found
    echo ${files[@]}
    echo "submission (combine): Only 1 file found to be combined."
    read -p "Do you wish to proceed? [Y/n]: " input
    if [[ "$input" =~ ^[Yy]?$ ]]; then # Proceed
        cp "${files[0]}" "$MAIN"
        sed -i "1s/Marks/$(basename ${files[0]} .csv)/" "$MAIN"
        if [ -f temp ]; then
            rm temp
        fi
        exit 0
    else
        echo "Aborted."
        if [ -f temp ]; then
            mv temp "$MAIN"
        fi
        exit 1
    fi
else
    # Generate the Header
    header="Roll_Number,Name"
    for file in "${files[@]}"; do
        exam=$(basename "$file" .csv)
        header="$header,$exam"
        exams+=("$exam") # Store exams in an array
    done

    # Process Files and Aggregate Data
    awk -F, -v header="$header" -v OFS=',' '
    BEGIN {
        print header
        split(header, headerCols, OFS)
    }
    FNR == 1 { next } # Skip header of each file
    {
        rollnum = toupper($1)
        name = tolower($2)
        exam = substr(FILENAME, 1, length(FILENAME)-4) # Remove .csv extension
        marks[rollnum,exam] = $3 # Store marks in a 2D array
        names[rollnum] = name
    }
    END {
        for (rollnum in names) { # Iterate over roll numbers
            str = names[rollnum]
            split(str, words, " ")
            str= ""
            for (i = 1; i < length(words); i++) {
                word = words[i]
                word = toupper(substr(word,1,1)) tolower(substr(word,2))
                str = str word " "
            }
            str = str toupper(substr(words[length(words)],1,1)) tolower(substr(words[length(words)],2))
            printf "%s,%s", rollnum, str
            for (i = 3; i <= length(headerCols); i++) { # Iterate over exams
                exam = headerCols[i]
                if ((rollnum,exam) in marks) {
                    printf ",%s", marks[rollnum,exam]
                } else {
                    printf ",a"
                }
            }
            print ""
        }
    }' "${files[@]}" > temp
    head -n 1 temp > "$MAIN"
    tail -n +2 temp | sort >> "$MAIN" # Sort the data by roll number
fi

if [ -f temp ]; then
    rm temp
fi
echo "submission (combine): Combined ${#files[@]} files into $MAIN."
exit 0
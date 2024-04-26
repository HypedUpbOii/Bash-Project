BEGIN {
    FS = ",";
    OFS = ",";
}
{
    if(NR == 1) { # for calculating number of columns
        if($NF == "total") {
            x = 0;
            print $0;
        }
        else {
            x = 1;
            print $0,"total";
        }
    }
    else {
        sum = 0; # for calculating sum of columns
        printf $1;
        printf ",";
        printf $2;
        printf ",";
        for (i = 3; i < (NF + x); i++) { # iterating through columns
            if ($i == "a") {
                sum += 0;
            }
            else {
                sum += $i;
            }
            printf $i;
            printf ",";
        }
        printf sum;
        print "";
    }
}
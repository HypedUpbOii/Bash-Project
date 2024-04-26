BEGIN{
    FS=","
    sum = 0
    num = 0
    sum_squares = 0
    values[0] = 0
    mode = 0;
    mode_count = 0;
}
{
    # skip the first line
    if (NR != 1) {
        # adding the value to the sum
        sum += $NF
        num += 1
        sum_squares += $NF * $NF
        values[num] = $NF
    }
}
END{
    # calculate the mean, variance, standard deviation, mode, median
    mean = sum / num
    variance = (sum_squares - sum * mean) / num
    print "mean: "mean
    print "variance: "variance
    print "standard deviation: "sqrt(variance)
    # sort the values
    for (i = 1; i <= num - 1; i++) {
        for (j = i + 1; j <= num; j++) {
            if (values[i] > values[j]) {
                temp = values[i]
                values[i] = values[j]
                values[j] = temp
            }
        }
    }
    mode = values[1]
    mode_count = 1
    count = 1
    # find the mode
    for (i = 2; i <= num; i++) {
        if (values[i] == values[i - 1]) {
            count += 1
        } else {
            count = 1
        }
        if (count > mode_count) {
            mode = values[i]
            mode_count = count
        }
    }
    if (num % 2 == 0) {
        median = (values[int(num / 2)] + values[int(num / 2 + 1)]) / 2
    } 
    else {
        median = values[int((num + 1) / 2)]
    }
    print "median: "median
    if (mode_count == 1) {
        mode = 3 * median - 2 * mean
    }
    print "mode: "mode
}
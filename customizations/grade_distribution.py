import numpy as np

file = open('main.csv', 'r')
student_marks = {}
for line in file: # Read the file line by line
    line = line.strip().split(',')
    if line[0] == 'Roll_Number':
        continue
    else:
        student_marks[f"{line[1]}:{line[0]}"] = float(line[-1]) # Store the marks of each student in a dictionary
file.close()

sorted_student_marks = sorted(student_marks.items(), key=lambda x: -x[1]) # Sort the students based on their marks
students_behind = {}
for student in sorted_student_marks: # Calculate the number of students behind each student
    for student2 in sorted_student_marks:
        if student2[1] <= student[1]:
            students_behind[student[0]] = students_behind.get(student[0], 0) + 1

grades = ["AA", "AB", "BB", "BC", "CC", "CD", "DD"]
assigned_students = set()
print("Choose between percentile or marks based grading")
print("1. Percentile based grading")
print("2. Marks based grading")
choice = int(input("Enter your choice: ")) # Ask the user for their choice
file = open('./customizations/grade_allotment.txt', 'w')
if choice == 1:
    prev_cutoff = 100.000001
    for grade in grades:
        print("")
        percentile = float(input(f"Enter required percentile for grade {grade}: ")) # Ask the user for the percentile
        if percentile >= prev_cutoff:  # Check if the current cutoff is higher than previous
            print("Invalid cutoff value. It should be higher than the previous cutoff.")
            file.close()
            file = open('./customizations/grade_allotment.txt', 'w')
            file.close()
            break
        for student in students_behind: # Assign grades to students based on the percentile
            if students_behind[student] / len(students_behind) * 100 >= percentile and student not in assigned_students:
                print(f"{student} has grade {grade}")
                file.write(f"{student.split(':')[1]}:{students_behind[student] / len(students_behind) * 100}:{grade}\n")
                assigned_students.add(student)
        prev_cutoff = percentile
    print("")
    print("Students who have not been assigned a grade:")
    for student in students_behind: # Assign grade F to students who have not been assigned a grade
        if student not in assigned_students:
            print(f"{student} has grade F")
            file.write(f"{student.split(':')[1]}:{students_behind[student] / len(students_behind) * 100}:F\n")
elif choice == 2:
    prev_cutoff = max(student_marks.values()) + 1
    total_students = len(sorted_student_marks)
    for grade in grades:
        print("")
        marks = float(input(f"Enter required marks for grade {grade}: ")) # Ask the user for the marks
        if marks >= prev_cutoff: # Check if the current cutoff is lower than previous
            print("Invalid cutoff value. It should be lower than the previous cutoff.")
            file.close()
            file = open('./customizations/grade_allotment.txt', 'w')
            file.close()
            break
        for student in sorted_student_marks: # Assign grades to students based on the marks
            if student[1] >= marks and student not in assigned_students:
                print(f"{student[0]} has grade {grade}")
                file.write(f"{student[0].split(':')[1]}:{students_behind[student] / len(students_behind) * 100}:{grade}\n")
                assigned_students.add(student)
        prev_cutoff = marks
    print("")
    print("Students who have not been assigned a grade:")
    for student in student_marks: # Assign grade F to students who have not been assigned a grade
        if student not in assigned_students:
            print(f"{student} has grade F")
            file.write(f"{student.split(':')[1]}:{students_behind[student] / len(students_behind) * 100}:F\n")
else:
    print("Invalid choice")
file.close()
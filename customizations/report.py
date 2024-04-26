import sys
import os

rollnum = sys.argv[1].upper()
name = ''
exam_names = []
my_marks = {}
topper_marks = {}
file = open('main.csv', 'r')
for line in file: # Read the file line by line
    line = line.strip().split(',')
    if line[0] == rollnum: # Check if the current line is for the required student
        name = line[1]
        for i in range(0, len(exam_names)): # Store the marks of the student
            if line[i+2] == 'a':
                my_marks[exam_names[i]] = "Absent"
            else:
                my_marks[exam_names[i]] = float(line[i+2])
    if line[0] == 'Roll_Number': # Store the names of the exams
        for i in range(2, len(line)):
            exam_names.append(line[i])
            topper_marks[line[i]] = 0
    else:
        for i in range(0, len(exam_names)): # Store the topper marks of each exam
            if line[i+2] == 'a':
                line[i+2] = 0
            topper_marks[exam_names[i]] = max(topper_marks[exam_names[i]], float(line[i+2]))
file.close()

# Write the LaTeX code to generate the report card
file = open('./customizations/student_report.tex', 'w')
file.write(f'\\documentclass[20pt]{{article}}\n')
file.write(f'\\usepackage{{titlesec}}\n')
file.write(f'\\titleformat*{{\\section}}{{%\n')
file.write(f'    \\fontsize{{20}}{{16}}\\bfseries%\n')
file.write(f'}}\n')
file.write(f'\n')
file.write(f'\\begin{{document}}\n')
file.write(f'\n')
file.write(f'\\font\\myfont=cmr12 at 40pt\n')
file.write(f'\\font\\notmymyfont=cmr12 at 15pt\n')
file.write(f'\\font\\notmyfont=cmr12 at 12pt\n')
file.write(f'\\title{{\\myfont Student Report Card}}\n')
file.write(f'\\author{{}}\n')
file.write(f'\\date{{}}\n')
file.write(f'\\pagenumbering{{gobble}}\n')
file.write(f'\\maketitle\n')
file.write(f'\n')
# Add student information
file.write(f'\\section*{{Student Information}}\n')
file.write(f'\\begin{{tabular}}{{ll}}\n')
file.write(f'    \\textbf{{\\notmymyfont Name:}} & \\notmymyfont {name}\\\\\n')
file.write(f'    \\textbf{{\\notmymyfont Roll Number:}} & \\notmymyfont {rollnum}\\\\\n')
file.write(f'\\end{{tabular}}\n')
file.write(f'\n')
# Add subjects and grades
file.write(f'\\section*{{Subjects and Grades}}\n')
file.write(f'\\begin{{center}}\n')
file.write(f'\\setlength{{\\tabcolsep}}{{2em}}\n')
file.write(f'\\renewcommand{{\\arraystretch}}{{2}}\n')
file.write(f'\\begin{{tabular}}{{ c c c }}\n')
file.write(f'    \\hline\n')
file.write(f'    \\textbf{{\\notmymyfont Exam}} & \\textbf{{\\notmymyfont Marks}} & \\textbf{{\\notmymyfont Topper Marks}}\\\\\n')
file.write(f'    \\hline\n')
# Add marks of the student and topper
for i in range(len(exam_names) - 1):
    file.write(f'    \\notmymyfont {exam_names[i].capitalize()} & \\notmymyfont {my_marks[exam_names[i]]} & \\notmymyfont {topper_marks[exam_names[i]]}\\\\\n')
file.write(f'    \\hline\n')
file.write(f'    \\notmymyfont {exam_names[-1].capitalize()} & \\notmymyfont {my_marks[exam_names[-1]]} & \\notmymyfont {topper_marks[exam_names[-1]]}\\\\\n')
file.write(f'    \\hline\n')
file.write(f'\\end{{tabular}}\n')
file.write(f'\\end{{center}}\n')
file.write(f'\n')
# Add comments
file.write(f'\\section*{{Comments}}\n')
file.write(f'\\notmyfont {name} has secured {my_marks[exam_names[-1]]} marks in the exams conducted.\\\\\\\\\n')
if my_marks[exam_names[-1]] == topper_marks[exam_names[-1]]:
    file.write(f'\\notmyfont {name} has secured the highest marks in the class.\\\\\\\\\n')
# Add grade
if os.path.isfile('./customizations/grade_allotment.txt'):
    file.write(f'\\notmyfont {name} has been assigned the grade ')
    grade_file = open('./customizations/grade_allotment.txt', 'r')
    for line in grade_file:
        line = line.strip().split(':')
        if line[0] == rollnum:
            file.write(f'{line[2]} with {round(float(line[1]),2)} percentile.\\\\\\\\\n')
            break
    grade_file.close()
# Add remarks
remarks_flag = input("Do you want to add any remarks?(Enter 'yes' or 'no'[default]): ")
if remarks_flag == 'yes':
    remarks = input("Enter remarks: ")
    file.write(f'\\notmyfont {remarks}\n')
file.write(f'\n')
file.write(f'\\end{{document}}\n')
file.close()

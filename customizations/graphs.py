import matplotlib.pyplot as plt
import statistics
import numpy as np
import math

marks = []
headers = []
file = open("main.csv", "r")
for line in file: # Read the file line by line
    data = line.strip().split(",")
    if data[0] == "Roll_Number": # Skip the first line
        for i in range(2,len(data)):
            headers.append(data[i].capitalize()) # Store the headers
            marks.append([])
        continue
    for i in range(2,len(data)):
        if data[i] == "a": # Skip absent students
            continue
        else:
            marks[i-2].append(float(data[i])) # Store the marks of each student

file = open("./customizations/graphviewer.html", "w")
# Write the HTML code to display the statistics and graphs
file.write("<html>\n")
file.write("\t<head>\n")
file.write("\t\t<title>Statistics</title>\n")
# Add CSS to style the page
file.write("\t\t<style>\n")
file.write("\t\t\tbody {\n")
file.write("\t\t\t\tfont-family: Arial, sans-serif;\n")
file.write("\t\t\t}\n")
file.write("\t\t\th1 {\n")
file.write("\t\t\t\ttext-align: center;\n")
file.write("\t\t\t}\n")
file.write("\t\t\ttable {\n")
file.write("\t\t\t\twidth: 80%;\n")
file.write("\t\t\t\tborder-collapse: collapse;\n")
file.write("\t\t\t\tmargin: auto;\n")
file.write("\t\t\t}\n")
file.write("\t\t\tth, td {\n")
file.write("\t\t\t\tborder: 1px solid black;\n")
file.write("\t\t\t\tpadding: 8px;\n")
file.write("\t\t\t\ttext-align: center;\n")
file.write("\t\t\t}\n")
file.write("\t\t\tth {\n")
file.write("\t\t\t\tbackground-color: #ff0000;\n")
file.write("\t\t\t\tcolor: white;\n")
file.write("\t\t\t}\n")
file.write("\t\t\ttr:nth-child(even) {\n")
file.write("\t\t\t\tbackground-color: #f2f2f2;\n")
file.write("\t\t\t}\n")
file.write("\t\t\ttr:hover {\n")
file.write("\t\t\t\tbackground-color: #f2f2f2;\n")
file.write("\t\t\t}\n")
file.write("\t\t\tdiv {\n")
file.write("\t\t\t\tmargin-top: 20px;\n")
file.write("\t\t\t\ttext-align: center;\n")
file.write("\t\t\t}\n")
file.write("\t\t\tselect {\n")
file.write("\t\t\t\twidth: 150px;\n")
file.write("\t\t\t\tpadding: 8px;\n")
file.write("\t\t\t\tborder: 1px solid black;\n")
file.write("\t\t\t\tborder-radius: 4px;\n")
file.write("\t\t\t}\n")
file.write("\t\t\timg {\n")
file.write("\t\t\t\twidth: 35%;\n")
file.write("\t\t\t\theight: auto;\n")
file.write("\t\t\t\tmargin-top: 20px;\n")
file.write("\t\t\t\tmargin-bottom: 20px;\n")
file.write("\t\t\t\tborder: 1px solid black;\n")
file.write("\t\t\t\tborder-radius: 4px;\n")
file.write("\t\t\t\tpadding: 8px;\n")
file.write("\t\t\t}\n")
file.write("\t\t</style>\n")
file.write("\t</head>\n")
file.write("\t<body>\n")
# Write the statistics
file.write("\t\t<h1>Statistics</h1>\n")
file.write("\t\t<table>\n")
file.write("\t\t\t<tr>\n")
file.write("\t\t\t\t<th>Exam</th>\n")
file.write("\t\t\t\t<th>Mean</th>\n")
file.write("\t\t\t\t<th>Median</th>\n")
file.write("\t\t\t\t<th>Mode</th>\n")
file.write("\t\t\t\t<th>St. Dev.</th>\n")
file.write("\t\t\t\t<th>75 %ile</th>\n")
file.write("\t\t\t\t<th>90 %ile</th>\n")
file.write("\t\t\t</tr>\n")
for i in range(len(headers)): # Calculate the statistics for each exam
    data = marks[i]
    data.sort()
    mean = round(statistics.mean(data), 2)
    median = statistics.median(data)
    mode = statistics.mode(data)
    std = round(statistics.stdev(data), 2)
    seventyfifth = data[int(0.75 * len(data))]
    ninetieth = data[int(0.9 * len(data))]
    file.write("\t\t\t<tr>\n")
    file.write(f"\t\t\t\t<td>{headers[i]}</td>\n")
    file.write(f"\t\t\t\t<td>{mean}</td>\n")
    file.write(f"\t\t\t\t<td>{median}</td>\n")
    file.write(f"\t\t\t\t<td>{mode}</td>\n")
    file.write(f"\t\t\t\t<td>{std}</td>\n")
    file.write(f"\t\t\t\t<td>{seventyfifth}</td>\n")
    file.write(f"\t\t\t\t<td>{ninetieth}</td>\n")
    file.write("\t\t\t</tr>\n")
file.write("\t\t</table>\n")
file.write("\t\t<div>\n")
# Graph display code
file.write("\t\t<h1>Graphs</h1>\n")
file.write("\t\t<label for='exam'>Exam:</label>\n")
file.write("\t\t<select id='exam' onchange='changeGraph()'>\n")
file.write("\t\t\t<option disabled selected value style=\"display:none\">Select Exam</option>\n")
for i in range(len(headers)):
    file.write(f"\t\t\t<option value='{headers[i]}'>{headers[i]}</option>\n")
file.write("\t\t</select>\n")
file.write("\t\t<label for='graph'>Graph Type:</label>\n")
file.write("\t\t<select id='graph' onchange='changeGraph()'>\n")
file.write("\t\t\t<option disabled selected value style=\"display:none\">Select Graph</option>\n")
file.write("\t\t\t<option value='histogram'>Histogram</option>\n")
file.write("\t\t\t<option value='scatter'>Scatter</option>\n")
file.write("\t\t</select>\n")
file.write("\t\t</div>\n")
file.write("\t\t<div id=\"imgHolder\"><img id=\"graphshower\" src=\"../graphs/default.png\"></div>\n")
for i in range(len(headers)): # Generate the graphs for each exam
    data = marks[i]
    data.sort()
    plt.hist(data, bins=10, color='red', edgecolor='black') # Generate the histogram
    plt.title(f'Marks Distribution for {headers[i]}')
    plt.xticks(np.arange(math.floor(min(data)), math.ceil(max(data)) + math.ceil((max(data) - min(data)) / 10), math.ceil((max(data) - min(data)) / 10)))
    plt.axvline(x=data[int(0.75 * len(data))], linestyle="--", color="black", label="75 %ile")
    plt.axvline(x=data[int(0.9 * len(data))], linestyle="--", color="orange", label="90 %ile")
    plt.legend()
    plt.xlabel('Marks')
    plt.ylabel('Number of students')
    plt.savefig(f'./graphs/{headers[i]}_histogram.png')
    plt.close()
    data = data[::-1]
    plt.scatter(np.arange(len(data)), data, color='red', linewidth=0.5, edgecolor='black') # Generate the scatter plot
    plt.title(f'Marks Distribution for {headers[i]}')
    plt.axhline(y=data[int(0.25 * len(data))], linestyle="--", color="black", label="75 %ile")
    plt.axhline(y=data[int(0.1 * len(data))], linestyle="--", color="orange", label="90 %ile")
    plt.xlabel("Rank")
    plt.ylabel("Marks")
    plt.legend()
    plt.savefig(f'./graphs/{headers[i]}_scatter.png')
    plt.close()
# Add JavaScript to change the graph based on the exam and graph type selected
file.write("\t\t<script>\n")
file.write("\t\t\tfunction changeGraph() {\n")
file.write("\t\t\t\tvar exam = document.getElementById('exam').value;\n")
file.write("\t\t\t\tvar graph = document.getElementById('graph').value;\n")
file.write("\t\t\t\tif (exam && graph) {\n")
file.write("\t\t\t\t\tif (graph == 'histogram') {\n")
file.write("\t\t\t\t\t\tvar img = document.getElementById('graphshower');\n")
file.write("\t\t\t\t\t\timg.src = `../graphs/${exam}_histogram.png`;\n")
file.write("\t\t\t\t\t}\n")
file.write("\t\t\t\t\telse if (graph == 'scatter') {\n")
file.write("\t\t\t\t\t\tvar img = document.getElementById('graphshower');\n")
file.write("\t\t\t\t\t\timg.src = `../graphs/${exam}_scatter.png`;\n")
file.write("\t\t\t\t\t}\n")
file.write("\t\t\t\t}\n")
file.write("\t\t\t}\n")
file.write("\t\t</script>\n")
file.write("\t</body>\n")
file.write("</html>")
file.close()
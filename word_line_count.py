file = "Untitled spreadsheet - Sheet1.csv"

with open(file) as f:
    for i, line in enumerate(f):
        count = 0
        line = line.split(",")
        for word in line:
            count += len(word.split(" "))
        print("line: "+str(i)+", count: "+str(count))

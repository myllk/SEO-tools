import csv

phrase_file = "check_urls_for_phrase/URL List - Locations.csv"
check_file = "check_urls_for_phrase/URL List - URLs.csv"

with open(check_file) as check_csv:
    check_file_reader = csv.reader(check_csv)

    for check_line in check_file_reader:

        with open(phrase_file) as phrase_csv:
            phrase_csv_reader = csv.reader(phrase_csv)

            for phrase in phrase_csv_reader:
                if phrase[0].lower() in check_line[0]:
                    print(phrase[0] + ", " + check_line[0])

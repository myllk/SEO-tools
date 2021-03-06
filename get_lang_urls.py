import enchant
import argparse
import re

# arg setup
parser = argparse.ArgumentParser(description='Return all the URLS in a file that contain english words')
parser.add_argument('-d', '--domain', help='The full domain i.e "https://www.google.com" (this text will be ignored in the search), default: ""', default="")
parser.add_argument('-l', '--lang', help='The language for pyenchant to use, default: en_UK', default="en_UK")
parser.add_argument('-o', '--output_type', help='The output file type (txt or csv), default: csv', default="csv")
parser.add_argument('file', help='Path to the file containing the URLs')
args = parser.parse_args()


# print settings
print("domain: "+args.domain)
print("filename: "+args.file)
print("language: "+args.lang)

# output file names
if args.output_type == "txt":
    lang_output_name = args.file.split('.')[0]+"_"+args.lang+".txt"
    other_output_name = args.file.split('.')[0]+"_other.txt"
    print("matched lines will be appended to: "+lang_output_name)
    print("unmatched lines will be appended to: "+other_output_name)

elif args.output_type == "csv":
    output_name = args.file.split('.')[0]+"_"+args.lang+".csv"
    print("Lines will be appended to: "+output_name)

else:
    print("Invalid output type. Type must be txt or csv")
    exit(1)

# banned chars and create dict obj
banned_chars = [r'\/', r'\.', r'-', r'_', r':']
d = enchant.Dict(args.lang)

# open output files
if args.output_type == "txt":
    lang_output = open(lang_output_name, "w+")
    other_output = open(other_output_name, "w+")

elif args.output_type == "csv":
    output = open(output_name, "w+")
    output.write("url,"+args.lang+"?\n")


# counters for stats
i = 0
i_matched = 0
i_unmatched = 0

print("\nWorking...")
with open(args.file) as f:
    for line in f:
        # loop vars
        found_lang = False
        org_line = line

        # counter
        if i%10 == 0:
            print("Line no: "+str(i))

        # strip domain
        line = re.sub(args.domain, '', line.rstrip())

        # strip punctuation
        for char in banned_chars:
            line = re.sub(char, ' ', line.rstrip())

        # split stripped line into words
        for word in line.split():
            # if any word in the line is a valid word in chosen lang
            if d.check(word):
                # add to lang file, increment counter and stop working on this line
                if args.output_type == "txt":
                    lang_output.write(org_line)
                elif args.output_type == "csv":
                    output.write(org_line.rstrip("\n\r")+",yes\n")
                found_lang = True
                i_matched += 1
                break

        # if no matches found, add to unmatched file and increment counter
        if not found_lang:
            if args.output_type == "txt":
                other_output.write(org_line)
            elif args.output_type == "csv":
                output.write(org_line.rstrip("\n\r")+",no\n")
            i_unmatched += 1

        i += 1

if args.output_type == "txt":
    lang_output.close()
    other_output.close()
elif args.output_type == "csv":
    output.close()

print("Finished working on "+str(i)+" lines")
print(str(i_matched)+" lines matched the language "+args.lang)
print(str(i_unmatched)+" lines did not match the language "+args.lang)

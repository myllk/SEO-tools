# SEO-tools
Some SEO related tools created by me (and anyone else who would like to contribute)

## [get_lang_urls.py](https://github.com/myllk/SEO-tools/blob/master/get_lang_urls.py)
This script takes in a tet list of URLs and gets all the URLs with english words in and splits them into either two text files or a csv with a column for URLs and a column for whether it's the chosen language or not.

### Requirements:
* Python 3
* pyenchant

### Usage:
```
james@HADES:/mnt/e/src/SEO-tools-git$ python3 get_lang_urls.py -h
usage: get_lang_urls.py [-h] [-d DOMAIN] [-l LANG] [-o OUTPUT_TYPE] file

Return all the URLS in a file that contain english words

positional arguments:
  file                  Path to the file containing the URLs

optional arguments:
  -h, --help            show this help message and exit
  -d DOMAIN, --domain DOMAIN
                        The full domain i.e "https://www.google.com" (this
                        text will be ignored in the search), default: ""
  -l LANG, --lang LANG  The language for pyenchant to use, default: en_UK
  -o OUTPUT_TYPE, --output_type OUTPUT_TYPE
                        The output file type (txt or csv), default: csv
```

### Example:
```
james@HADES:/mnt/e/src/SEO-tools-git$ python3 get_lang_urls.py example.txt
domain:
filename: example.txt
language: en_UK
Lines will be appended to: example_en_UK.csv

Working...
Line no: 0
Line no: 10
Line no: 20
Finished working on 28 lines
20 lines matched the language en_UK
8 lines did not match the language en_UK
```

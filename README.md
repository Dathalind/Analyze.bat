# Malware-Analysis-Scripts
A place to keep track of Malware Analysis scripts I have written or had cloned and also use as part of scripts code vibed. 

## pestats.py

Clone of the python file found on this repo: https://github.com/as0ni/pestats

## Analyze.bat

This batch script will allow you to either pass the relative path if you are in the same file path of your sample, or pass the full file path into a command line argument. You can also drag and drop a file on top of the batch script if you have it on your desktop, and it will kick off the instance of running the tools against the file. 

The script will run 4 tools against the file in question:
* Floss
* Detect-It-Easy
* Capa
* pestats.py

Each tool will output a separate json file in the path you are running this batch script. 

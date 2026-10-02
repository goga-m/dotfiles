#!/bin/bash

# Open a file in an opened vim (single instance)
FILE=$1
vim --servername one --remote FILE
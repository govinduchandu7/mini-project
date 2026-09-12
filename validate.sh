#!/bin/bash
set -e

for file in website/index.html website/courses.html website/style.css
do
    if [ ! -s "$file" ]; then
        echo "ERROR: Missing or empty file: $file"
        exit 1
    fi
done

grep -qi "<html" website/index.html

echo "Validation completed successfully"

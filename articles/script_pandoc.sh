#! /usr/bin/env bash
for folder in $(ls .); do
	for page in $(find $folder -type f -name "*.md"); do
	  echo $page 
	  pandoc \
	  -s \
	  $page \
	  -c "../simple.css" \
	  -o "$folder/$(basename $page .md).html"
	done
done


# 	  --number-section \
#	  --toc \
	  --toc-depth=1 \

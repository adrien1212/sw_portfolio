#! /usr/bin/env bash
for folder in $(ls .); do
	for page in $(find $folder -type f -name "*.md"); do
	  echo $page 
	  pandoc \
	  -t asciidoc \
	  -f markdown \
	  -s \
	  $page \
	  -o "$folder/$(basename $page .md).adoc"
	done
done


# 	  --number-section \
#	  --toc \
	  --toc-depth=1 \
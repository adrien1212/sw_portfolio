#! /usr/bin/env bash
for folder in $(ls .); do
	for page in $(find $folder -type f -name "*.adoc"); do
		echo $page 
		asciidoctor \
		-a stylesheet="../custom_ascii.css" \
		-a linkcss \
		$page
	done
done

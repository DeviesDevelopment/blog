#!/bin/bash

if [ -z "$1" ];
then
  echo "Missing title"
  exit 1
fi

DATE=$(date +%Y-%m-%d)
TITLE=$(echo "$1" | tr ' ' '-' | awk '{print tolower($0)}')
hugo new "posts/${DATE}_${TITLE}.md"

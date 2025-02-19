#!/bin/bash

# APIレスポンスのエラーチェック
response=$(gh api "repos/$MDC_REPO_OWNER/$MDC_REPO/contents/$MDC_REPO_DIRECTORY" 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch repository contents"
    exit 1
fi

# get `.mdc` filenames from repository
FILES=$(gh api "repos/$OWNER/$MDC_REPO/contents/$MDC_REPO_DIRECTORY" --jq '.[] | select(.type=="file" and (.name | endswith(".mdc"))) | .name')

# output as JSON
if [ -n "$FILES" ]; then
    # remove `.mdc` prefix from the filename
    FILE_LIST=$(echo "$FILES" | sed 's/\.mdc$//' | jq -R -s -c 'split("\n") | map(select(. != ""))')
    echo "{ \"mdc\": $FILE_LIST }"
else
    echo "{ \"mdc\": [] }"
fi

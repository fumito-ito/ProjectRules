#!/bin/bash

# GitHub リポジトリ情報
OWNER="fumito-ito"
REPO="mdcvalult"
DIRECTORY="mdc"

# GitHub API を使ってディレクトリ内のファイルを取得
FILES=$(gh api "repos/$OWNER/$REPO/contents/$DIRECTORY" --jq '.[] | select(.type=="file" and (.name | endswith(".mdc"))) | .name')

# JSON 形式で出力
if [ -n "$FILES" ]; then
    # `.mdc` を取り除いたファイル名を配列化
    FILE_LIST=$(echo "$FILES" | sed 's/\.mdc$//' | jq -R -s -c 'split("\n") | map(select(. != ""))')
    echo "{ \"mdc\": $FILE_LIST }"
else
    echo "{ \"mdc\": [] }"
fi
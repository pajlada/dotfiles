#!/usr/bin/env bash

approve_and_auto_merge() {
    local PR="$1"
    PR_NUMBER="$(echo "$PR" | jq -r '.number')"
    PR_TITLE="$(echo "$PR" | jq -r '.title')"
    if [ -z "$PR_NUMBER" ] || [ -z "$PR_TITLE" ]; then
        echo "No PR number or title found for '$PR', exiting"
        exit
    fi
    echo "Approving $PR_TITLE ($PR_NUMBER)";
    gh pr review --approve "$PR_NUMBER"
    sleep 2
    echo "Auto-merging $PR_TITLE ($PR_NUMBER)";
    gh pr merge -s --auto "$PR_NUMBER"
}

while read -r PR; do
    if [ -z "$PR" ]; then
        continue
    fi
    approve_and_auto_merge "$PR"
done <<< "$(gh pr list --author "app/dependabot" --draft=0 --state open --json number,title | jq -c -r '.[]')"

while read -r PR; do
    if [ -z "$PR" ]; then
        continue
    fi
    approve_and_auto_merge "$PR"
done <<< "$(gh pr list --author "app/renovate" --draft=0 --state open --json number,title | jq -c -r '.[]')"

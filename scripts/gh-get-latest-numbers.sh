#!/bin/sh

set -e

_issues="$(gh issue list --state all --json number,title | jq '.[]')"
_prs="$(gh pr list --state all --json number,title | jq '.[]')"
# shellcheck disable=2016
_discussions="$(gh api graphql -F owner='{owner}' -F name='{repo}' -f query=' query ($name: String!, $owner: String!) { repository(owner: $owner, name: $name) { discussions(first: 5) { nodes { number title } } } }' | jq '.data.repository.discussions.nodes[]')"

wait

echo "$_issues $_prs $_discussions" | jq -sr 'sort_by(.number) | reverse[:5][] | ((.number | tostring) + "    " + .title)'

#!/bin/bash
# Publish scheduled posts from _drafts to _posts
# This script can be run manually for testing

set -e

# Get current date in America/New_York timezone
CURRENT_DATE=$(TZ=America/New_York date +%Y-%m-%d)
CURRENT_TIMESTAMP=$(TZ=America/New_York date +%s)

echo "Current date (EST): $CURRENT_DATE"
echo "Checking for posts ready to publish..."

PUBLISHED_COUNT=0

# Check if _drafts directory exists
if [ ! -d "_drafts" ]; then
  echo "No _drafts directory found"
  exit 0
fi

# Process each draft file
for draft in _drafts/*.md; do
  # Skip if no files match
  [ -e "$draft" ] || continue

  filename=$(basename "$draft")

  # Extract date from filename (YYYY-MM-DD format)
  if [[ $filename =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2})- ]]; then
    post_date="${BASH_REMATCH[1]}"

    # Handle different date command syntax (GNU vs BSD)
    if date --version >/dev/null 2>&1; then
      # GNU date (Linux)
      post_timestamp=$(date -d "$post_date" +%s)
    else
      # BSD date (macOS)
      post_timestamp=$(date -j -f "%Y-%m-%d" "$post_date" +%s)
    fi

    # Check if post date is today or earlier
    if [ "$post_timestamp" -le "$CURRENT_TIMESTAMP" ]; then
      echo "Publishing: $filename (dated $post_date)"

      # Move to _posts directory
      mkdir -p _posts
      mv "$draft" "_posts/$filename"
      PUBLISHED_COUNT=$((PUBLISHED_COUNT + 1))
    else
      echo "Skipping: $filename (scheduled for $post_date)"
    fi
  else
    echo "Skipping: $filename (no date in filename)"
  fi
done

echo ""
echo "Published $PUBLISHED_COUNT post(s)"

if [ $PUBLISHED_COUNT -gt 0 ]; then
  echo ""
  echo "Posts have been moved to _posts/"
  echo "Review changes and commit when ready:"
  echo "  git add _posts/ _drafts/"
  echo "  git commit -m 'Publish scheduled posts for $CURRENT_DATE'"
  echo "  git push"
fi

#!/bin/zsh

set -e

echo "Pushing to remote..."
PREV_RUN_ID=$(gh run list --limit 1 --json databaseId -q '.[0].databaseId')
git push

# Wait for a new run to be triggered
echo "Waiting for new build to start..."
while true; do
  RUN_ID=$(gh run list --limit 1 --json databaseId -q '.[0].databaseId')
  [[ "$RUN_ID" != "$PREV_RUN_ID" ]] && break
  sleep 2
done
echo "Watching run $RUN_ID..."

gh run watch $RUN_ID --exit-status

echo "Build succeeded. Downloading firmware..."
BUILD_DIR="firmware/$(git log --oneline -1 | sed 's/[^a-zA-Z0-9._-]/_/g')"
rm -rf "$BUILD_DIR"
gh run download $RUN_ID --dir "$BUILD_DIR"

echo "Firmware saved to $BUILD_DIR/firmware/"
ls "$BUILD_DIR/firmware/"

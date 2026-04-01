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
rm -rf ~/Downloads/firmware-latest
gh run download $RUN_ID --dir ~/Downloads/firmware-latest

echo "Firmware saved to ~/Downloads/firmware-latest/firmware/"
ls ~/Downloads/firmware-latest/firmware/

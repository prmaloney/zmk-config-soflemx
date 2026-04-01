#!/bin/zsh

set -e

# Get the latest run ID
RUN_ID=$(gh run list --limit 1 --json databaseId -q '.[0].databaseId')
echo "Watching run $RUN_ID..."

gh run watch $RUN_ID --exit-status

echo "Build succeeded. Downloading firmware..."
rm -rf ~/Downloads/firmware-latest
gh run download $RUN_ID --dir ~/Downloads/firmware-latest

echo "Firmware saved to ~/Downloads/firmware-latest/firmware/"
ls ~/Downloads/firmware-latest/firmware/

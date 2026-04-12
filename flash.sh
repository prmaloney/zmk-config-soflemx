#!/bin/zsh

set -e

FIRMWARE_DIR="${1:-firmware}"

# Pick a build with fzf (inline, no full-screen takeover)
SELECTED=$(ls -td "$FIRMWARE_DIR"/*/firmware 2>/dev/null | sed "s|$FIRMWARE_DIR/||;s|/firmware||" | fzf --height 10 --border --prompt "Select build: ")
if [[ -z "$SELECTED" ]]; then
  echo "No build selected."
  exit 1
fi
LATEST="$FIRMWARE_DIR/$SELECTED/firmware"

echo "Using firmware from: $LATEST"

wait_for_mount() {
  while [[ ! -d /Volumes/NICENANO ]]; do sleep 1; done
}

wait_for_unmount() {
  while [[ -d /Volumes/NICENANO ]]; do sleep 1; done
}

flash() {
  local file="$1"
  local label="$2"
  echo "\n$label"
  read -r "?Put the controller into bootloader mode (double-tap reset), then press Enter..."
  wait_for_mount
  echo "Flashing..."
  cp "$LATEST/$file" /Volumes/NICENANO/
  diskutil eject /Volumes/NICENANO 2>/dev/null || true
  wait_for_unmount
  echo "Done."
}

flash "settings_reset-nice_nano_v2-zmk.uf2"          "Step 1/4: Settings reset — LEFT half"
flash "sofle_left-nice_nano_v2-zmk.uf2"             "Step 2/4: Flash firmware — LEFT half"
flash "settings_reset-nice_nano_v2-zmk.uf2"          "Step 3/4: Settings reset — RIGHT half"
flash "sofle_right-nice_nano_v2-zmk.uf2"            "Step 4/4: Flash firmware — RIGHT half"

echo "\nAll done! Forget the keyboard in Bluetooth settings, then pair fresh."

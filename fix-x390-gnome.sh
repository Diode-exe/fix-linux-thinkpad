#!/usr/bin/env bash
# Fix GNOME issues on ThinkPad X390 Yoga running Linux Mint 22.1
# Author: Rohan
# Version: 1.0
# Tested on Mint 22.1 (Ubuntu 22.04 base)

set -e

echo "=== Fixing GNOME on ThinkPad X390 Yoga ==="

# Ensure running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo bash fix-x390-gnome.sh)"
  exit 1
fi

echo "[1/6] Installing required packages..."
apt update -y
apt install -y xserver-xorg-input-wacom pipewire pipewire-audio pipewire-pulse alsa-firmware-loaders

echo "[2/6] Enabling PipeWire audio..."
systemctl --user --now enable pipewire.service pipewire-pulse.service 2>/dev/null || true

echo "[3/6] Forcing GNOME scaling back to normal..."
sudo -u $SUDO_USER gsettings set org.gnome.desktop.interface scaling-factor 1
sudo -u $SUDO_USER gsettings set org.gnome.desktop.interface text-scaling-factor 1.0

echo "[4/6] Creating TrackPoint config..."
mkdir -p /etc/libinput
cat >/etc/libinput/local-overrides.quirks <<'EOF'
[Trackpoint Override]
MatchName=*TrackPoint*
AttrTrackpointMultiplier=1.0
AttrTrackpointHysteresis=0
EOF

echo "[5/6] Forcing PipeWire to start on next boot..."
loginctl enable-linger $SUDO_USER 2>/dev/null || true

echo "[6/6] Done! Restarting display manager..."
systemctl restart display-manager

echo
echo "✅ All fixes applied!"
echo "➡️  Please reboot and log in using 'GNOME on Xorg'."
echo "➡️  After reboot, check with:"
echo "   pactl info | grep 'Server Name'   (should say PipeWire)"
echo "   xinput | grep -i wacom            (should list pen & touch)"

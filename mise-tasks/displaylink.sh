#!/usr/bin/env bash
#MISE description="Install DisplayLink dock support (self-skips with no DisplayLink hardware)"
#
# Deliberately NOT wired into [tasks.bootstrap]: it needs sudo and only applies
# to machines with a DisplayLink dock on USB. Run it by hand when one is
# plugged in:
#
#   mise run displaylink
#
# There is no declarative equivalent for "install this only if a USB vendor id
# is present" — [bootstrap.packages] selects on os/arch/profile, not hardware.

set -uo pipefail

# Skip unless the DisplayLink dock is plugged in; evdi-dkms also fails on the
# linux-omarchy kernel (no matching headers).
if ! lsusb 2>/dev/null | grep -qi 'displaylink'; then
    echo "No DisplayLink device detected (USB vendor 0x17e9) - skipping."
    exit 0
fi

echo "=== DisplayLink installation ==="

echo "Creating Xorg configuration..."
sudo mkdir -p /etc/X11/xorg.conf.d/
sudo tee /etc/X11/xorg.conf.d/20-evdi.conf > /dev/null << 'EOF'
Section "OutputClass"
    Identifier "DisplayLink"
    MatchDriver "evdi"
    Driver "modesetting"
    Option "AccelMethod" "none"
EndSection
EOF

echo "Installing required packages..."
sudo pacman -S --noconfirm linux-headers
yay -S --noconfirm evdi-dkms
yay -S --noconfirm displaylink

echo "Setting up services..."
sudo modprobe evdi || true
sudo systemctl enable displaylink.service
sudo systemctl start displaylink.service

echo "DisplayLink installation complete! Reboot recommended."

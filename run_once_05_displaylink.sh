#!/bin/bash

# DisplayLink is host-specific USB dock hardware. This script previously ran on
# EVERY fresh machine, building AUR DKMS modules (evdi-dkms) that fail whenever
# the running kernel has no matching headers -- which is exactly the case on
# Omarchy >= 4.0.4, where the default kernel is the bespoke `linux-omarchy`
# (linux-headers does not match it). The failure then cascades into
# `systemctl enable displaylink.service` failing on a service that was never installed.
#
# Skip unless the hardware is actually plugged in.
if ! lsusb 2>/dev/null | grep -qi 'displaylink'; then
    echo "No DisplayLink device detected (USB vendor 0x17e9) - skipping."
    exit 0
fi

install_displaylink() {
    echo "=== DisplayLink Installation ==="
    
    # if yay -Q displaylink &>/dev/null && yay -Q evdi-dkms &>/dev/null; then
    #     echo "DisplayLink already installed, skipping..."
    #     return 0
    # fi
    
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
}

 install_displaylink

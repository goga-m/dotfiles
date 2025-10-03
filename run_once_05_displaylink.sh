#!/bin/bash

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

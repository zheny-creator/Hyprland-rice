#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

cp -r hypr ~/.config && cp -r noctalia ~/.config && cp -r Bibata-Modern-Ice ~/.local/share/icons && cp -r Wallpapers ~
sudo cp -r Bibata-Modern-Ice /usr/share/icons

info "Updating system and installing packages via pacman..."
sudo pacman -Syu
sudo pacman -S hyprland hyprcursor hyprgraphics hyprlang hyprtoolkit hyprutils hyprwire \
    gtk3 gtk4 \
    kitty adw-gtk-theme nemo nwg-look \
    xdg-desktop-portal-hyprland xdg-utils xdg-desktop-portal-gtk papirus-icon-theme

install_noctalia() {
    info "Installing noctalia-shell..."
    if command -v yay &>/dev/null; then
        yay -S --needed noctalia-shell
    elif command -v pacman &>/dev/null && grep -q "chaotic" /etc/pacman.conf; then
        sudo pacman -S noctalia-shell
    else
        error "Cannot install noctalia-shell: no AUR or Chaotic-AUR available."
        return 1
    fi
}

install_yay() {
    info "Installing yay (AUR helper)..."
    if ! command -v git &>/dev/null || ! command -v base-devel &>/dev/null; then
        warn "git and base-devel required. Installing..."
        sudo pacman -S --needed git base-devel
    fi
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
    if command -v yay &>/dev/null; then
        info "yay installed successfully."
        return 0
    else
        error "Failed to install yay."
        return 1
    fi
}

add_chaotic_aur() {
    info "Adding Chaotic-AUR repository..."
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key 3056513887B78AEB
    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
    sudo pacman -Sy
    info "Chaotic-AUR added. You can now install packages via pacman."
}

if ! command -v yay &>/dev/null; then
    echo ""
    warn "yay (AUR helper) not found. noctalia-shell requires AUR or Chaotic-AUR."
    echo "Choose an action:"
    echo "  1) Install yay (AUR helper) from source"
    echo "  2) Add Chaotic-AUR repository (binary AUR packages)"
    echo "  3) Skip noctalia-shell installation"
    read -rp "Your choice [1-3]: " choice

    case "$choice" in
        1)
            install_yay
            if [ $? -eq 0 ]; then
                install_noctalia
            fi
            ;;
        2)
            add_chaotic_aur
            install_noctalia
            ;;
        3)
            warn "Skipping noctalia-shell. You can add AUR/Chaotic-AUR later and install manually."
            ;;
        *)
            error "Invalid choice. Skipping noctalia-shell."
            ;;
    esac
else
    install_noctalia
fi

info "All done!"

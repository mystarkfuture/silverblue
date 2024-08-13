#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

# Convince the installer we are in CI
touch /.dockerenv

### Install packages

# COPR Repos
# Fonts
curl -Lo /etc/yum.repos.d/_copr_atim-ubuntu-fonts-fedora-"${RELEASE}".repo https://copr.fedorainfracloud.org/coprs/atim/ubuntu-fonts/repo/fedora-"${RELEASE}"/atim-ubuntu-fonts-fedora-"${RELEASE}".repo
curl -Lo /etc/yum.repos.d/_copr_che-nerd-fonts-"${RELEASE}".repo https://copr.fedorainfracloud.org/coprs/che/nerd-fonts/repo/fedora-"${RELEASE}"/che-nerd-fonts-fedora-"${RELEASE}".repo
curl -Lo /etc/yum.repos.d/_copr_robot-veracrypt-fedora-"${RELEASE}".repo https://copr.fedorainfracloud.org/coprs/robot/veracrypt/repo/fedora-"${RELEASE}"/robot-veracrypt-fedora-"${RELEASE}".repo

# Homebrew
# Make these so script will work
mkdir -p /var/home
mkdir -p /var/roothome

# Brew Install Script
curl -Lo /tmp/brew-install https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
chmod +x /tmp/brew-install
/tmp/brew-install
tar --zstd -cvf /usr/share/homebrew.tar.zst /home/linuxbrew/.linuxbrew


# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
# # system utils
rpm-ostree install mesa-libGLU
rpm-ostree install bcache-tools
rpm-ostree install bootc
rpm-ostree install pulseaudio-utils
rpm-ostree install krb5-workstation                                 # The krb5-workstation package contains the basic Kerberos programs (kinit,klist,kdestroy,kpasswd)
rpm-ostree install libxcrypt-compat                                 # Compatibility library providing legacy API functions
rpm-ostree install lm_sensors                                       # Hardware monitoring tools
rpm-ostree install openssh-askpass                                  # A passphrase dialog for OpenSSH and X
rpm-ostree install udica                                            # A tool for generating SELinux security policies for containers

# # utilities
rpm-ostree install firewall-config
rpm-ostree install p7zip
rpm-ostree install p7zip-plugins
rpm-ostree install wl-clipboard
rpm-ostree install zoxide
rpm-ostree install stow
rpm-ostree install git
rpm-ostree install ulauncher
rpm-ostree install zsh
rpm-ostree install wireguard-tools
rpm-ostree install fastfetch
rpm-ostree install veracrypt

# # build libs
# rpm-ostree install gcc
rpm-ostree install make
rpm-ostree install python3-pip
# rpm-ostree install flatpak-builder                                  # Tool to build flatpaks from source

# # printer / scanner utils
rpm-ostree install epson-inkjet-printer-escpr
rpm-ostree install epson-inkjet-printer-escpr2
rpm-ostree install printer-driver-brlaser
rpm-ostree install simple-scan
rpm-ostree install foo2zjs
rpm-ostree install hplip

# # gnomme shell extensions
rpm-ostree install gnome-shell-extension-system-monitor
rpm-ostree install gnome-shell-extension-appindicator
rpm-ostree install gnome-shell-extension-blur-my-shell

# # themes, fonts
rpm-ostree install yaru-theme
rpm-ostree install adobe-source-code-pro-fonts
rpm-ostree install jetbrains-mono-fonts-all
rpm-ostree install cascadia-code-fonts
rpm-ostree install powerline-fonts
rpm-ostree install mozilla-fira-mono-fonts
rpm-ostree install google-droid-sans-mono-fonts
rpm-ostree install google-go-mono-fonts
rpm-ostree install ubuntu-family-fonts
rpm-ostree install nerd-fonts

# # development libs
rpm-ostree install podman-compose
rpm-ostree install podman-tui
rpm-ostree install podmansh
rpm-ostree install code

#### Example for enabling a System Unit File

systemctl enable podman.socket
systemctl enable brew-setup.service
systemctl enable brew-upgrade.timer
systemctl enable brew-update.timer
systemctl --global enable podman-auto-update.timer


# modifications to /etc/
# ZRAM conf
cp /usr/lib/systemd/zram-generator.conf /usr/lib/systemd/zram-generator.conf.bkp
echo -e "\n# Default algorithm changed from lzo-rle to zstd \ncompression-algorithm = zstd" | tee -a /usr/lib/systemd/zram-generator.conf
echo -e "# zram conf copied from PopOS\nvm.swappiness = 180\nvm.watermark_boost_factor = 0\nvm.watermark_scale_factor = 125\nvm.page-cluster = 0" | sudo tee -a /etc/sysctl.d/99-vm-zram-parameters.conf

# WiFi configuration
# echo -e "[device]\nwifi.backend=iwd\n" | tee -a /etc/NetworkManager/conf.d/wifi_backend.conf
echo -e "[connection]\nwifi.powersave=2\n" | tee -a /etc/NetworkManager/conf.d/wifi-powersave-off.conf

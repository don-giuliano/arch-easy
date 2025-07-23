#!/bin/bash

set -e

echo "Début de la mise à jour système et config pacman…"
sudo pacman -Syu --noconfirm

# Configuration pacman
sudo sed -i 's/^#Color$/Color/' /etc/pacman.conf
sudo sed -i 's/^#\(ParallelDownloads.*\)/\1\nILoveCandy/' /etc/pacman.conf
sudo sed -i 's/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$(nproc)\"/' /etc/makepkg.conf
sudo sed -i '/^#\[multilib\]/,/^#Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
sudo pacman -S --noconfirm pacman-contrib
sudo systemctl enable paccache.timer

# Repo Chaotic-AUR
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
sudo sed -i '101c\[chaotic-aur]' /etc/pacman.conf
sudo sed -i '102c\Include = /etc/pacman.d/chaotic-mirrorlist' /etc/pacman.conf

sudo pacman -Syu --noconfirm

echo "Installation et optimisation des mirrors…"
sudo rm -f /usr/bin/update-mirrors

sudo tee /usr/bin/update-mirrors > /dev/null << 'EOF'
#!/bin/bash
tmpfile=$(mktemp)
echo "Using temporary file: $tmpfile"
rate-mirrors --save="$tmpfile" arch --max-delay=43200 && \
  sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-backup && \
  sudo mv "$tmpfile" /etc/pacman.d/mirrorlist && \
  sudo pacman -Syyu --noconfirm
EOF

sudo chmod +x /usr/bin/update-mirrors
sudo pacman -S --noconfirm rate-mirrors
update-mirrors

echo "Installation des firmwares, codecs, drivers, applications…"
sudo pacman -S --noconfirm linux-zen-headers mkinitcpio-firmware xone-dongle-firmware xone-dkms-git fwupd fastfetch nano

sudo tee /etc/sysctl.d/99-architect-kernel.conf > /dev/null << 'EOF'
# Kernel performance and memory tuning for desktop systems

# The sysctl swappiness parameter determines the kernel's preference for pushing anonymous pages or page cache to disk in memory-starved situations.
# A low value causes the kernel to prefer freeing up open files (page cache), a high value causes the kernel to try to use swap space,
# and a value of 100 means IO cost is assumed to be equal.
vm.swappiness = 100

# The value controls the tendency of the kernel to reclaim the memory which is used for caching of directory and inode objects (VFS cache).
# Lowering it from the default value of 100 makes the kernel less inclined to reclaim VFS cache (do not set it to 0, this may produce out-of-memory conditions)
vm.vfs_cache_pressure = 50

# Contains, as bytes, the number of pages at which a process which is
# generating disk writes will itself start writing out dirty data.
vm.dirty_bytes = 268435456

# page-cluster controls the number of pages up to which consecutive pages are read in from swap in a single attempt.
# This is the swap counterpart to page cache readahead. The mentioned consecutivity is not in terms of virtual/physical addresses,
# but consecutive on swap space - that means they were swapped out together. (Default is 3)
# increase this value to 1 or 2 if you are using physical swap (1 if ssd, 2 if hdd)
vm.page-cluster = 0

# Contains, as bytes, the number of pages at which the background kernel
# flusher threads will start writing out dirty data.
vm.dirty_background_bytes = 67108864

# The kernel flusher threads will periodically wake up and write old data out to disk.  This
# tunable expresses the interval between those wakeups, in 100'ths of a second (Default is 500).
vm.dirty_writeback_centisecs = 1500

# This action will speed up your boot and shutdown, because one less module is loaded. Additionally disabling watchdog timers increases performance and lowers power consumption
# Disable NMI watchdog
kernel.nmi_watchdog = 0

# Enable the sysctl setting kernel.unprivileged_userns_clone to allow normal users to run unprivileged containers.
kernel.unprivileged_userns_clone = 1

# To hide any kernel messages from the console
kernel.printk = 3 3 3 3

# Restricting access to kernel pointers in the proc filesystem
kernel.kptr_restrict = 2

# Disable Kexec, which allows replacing the current running kernel.
kernel.kexec_load_disabled = 1

# Increase netdev receive queue
# May help prevent losing packets
net.core.netdev_max_backlog = 4096

# Set size of file handles and inode cache
fs.file-max = 2097152

# Increase writeback interval  for xfs
fs.xfs.xfssyncd_centisecs = 10000

# Disable split lock : https://www.phoronix.com/news/Linux-Splitlock-Hurts-Gaming
kernel.split_lock_mitigate = 0
EOF

sudo sysctl --system

sudo tee /usr/bin/fix-key << 'EOF'
#!/bin/bash
sudo rm /var/lib/pacman/sync/*
sudo rm -rf /etc/pacman.d/gnupg/*
sudo pacman-key --init
sudo pacman-key --populate
sudo pacman -Sy --noconfirm archlinux-keyring
sudo pacman --noconfirm -Su
EOF

sudo tee /usr/bin/update-arch << 'EOF'
#!/bin/bash
sudo pacman -Syu --noconfirm
EOF

sudo tee /usr/bin/update-grub << 'EOF'
#!/bin/bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
EOF

sudo tee /usr/bin/install-all-pkg << 'EOF'
#!/bin/bash
sudo pacman -S $(pacman -Qnq) --overwrite='*'
EOF

sudo tee /usr/bin/clean-arch << 'EOF'
#!/bin/bash
sudo pacman -Sc --noconfirm && sudo pacman -Yc --noconfirm
EOF

sudo chmod +x /usr/bin/{fix-key,update-arch,update-grub,install-all-pkg,clean-arch}

for i in "${alias[@]}"; do
    if ! grep -q "${i}" "${HOME}/.bashrc"; then
        echo "${i}" >>"${HOME}/.bashrc"
    fi

done

sudo pacman -S --noconfirm ttf-dejavu ttf-liberation ttf-meslo-nerd noto-fonts-emoji adobe-source-code-pro-fonts otf-font-awesome ttf-droid

sudo pacman -S --noconfirm ark zip unzip p7zip unrar

sudo pacman -S --noconfirm ntfs-3g fuse2 fuse2fs fuse3 exfatprogs btrfs-progs e2fsprogs xfsprogs f2fs-tools udftools dosfstools

sudo pacman -S --noconfirm flac wavpack a52dec lame libdca libmad libmpcdec opus libvorbis faac faad2 libfdk-aac opencore-amr speex

sudo pacman -S --noconfirm aom rav1e svt-av1 schroedinger libdv x264 x265 libmpeg2 xvidcore libtheora libvpx

sudo pacman -S --noconfirm gstreamer gst-plugins-bad gst-plugins-base gst-plugins-ugly gst-plugin-pipewire gstreamer-vaapi gst-plugins-good gst-libav libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau

sudo pacman -S --noconfirm jasper libwebp libavif libheif perl-image-exiftool qt6-imageformats ffmpegthumbnailer

sudo pacman -S --noconfirm wayland

sudo pacman -S --noconfirm plasma-desktop bluedevil breeze-gtk discover kde-gtk-config kdeplasma-addons kgamma kinfocenter kscreen ksshaskpass kwallet-pam kwrited ocean-sound-theme plasma-browser-integration plasma-disks plasma-firewall plasma-nm plasma-pa plasma-systemmonitor plasma-thunderbolt plasma-vault plasma-welcome plasma-workspace-wallpapers powerdevil print-manager sddm sddm-kcm spectacle wacomtablet xdg-desktop-portal-kde konsole

sudo pacman -S --noconfirm ufw gufw
sudo systemctl enable ufw

sudo pacman -S --noconfirm firefox firefox-i18n-fr

sudo pacman -S --noconfirm isoimagewriter kcalc kolourpaint gwenview gnome-disk-utility discord keepassxc kdenlive obs-studio tenacity corectrl lmms mkvtoolnix-gui

sudo pacman -S --noconfirm libreoffice-fresh libreoffice-fresh-fr hunspell-fr

sudo pacman -S --noconfirm virtualbox virtualbox-host-dkms
sudo usermod -aG vboxusers $USER
sudo systemctl enable vboxweb.service

sudo pacman -S --noconfirm ghostscript gsfonts cups cups-filters cups-pdf system-config-printer avahi
sudo systemctl enable --now avahi-daemon
sudo systemctl enable --now cups

sudo pacman -S --noconfirm foomatic-db-engine foomatic-db foomatic-db-ppds foomatic-db-nonfree foomatic-db-nonfree-ppds gutenprint foomatic-db-gutenprint-ppds

sudo pacman -S --noconfirm steam

sudo pacman -S --noconfirm flatpak flatpak-kcm

# Installation Plex sans menu interactif
flatpak install -y flathub app/tv.plex.PlexDesktop

# Installation ProtonVPN flatpak
flatpak install -y protonvpn

systemctl --user enable arch-update.timer
arch-update --tray --enable

sudo systemctl enable sddm
sudo systemctl start sddm

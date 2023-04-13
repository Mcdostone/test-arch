#!/usr/bin/env bash

set -exuo pipefail

# Getting started

## Azerty keyboard
loadkeys fr-latin1

## Internet
iwctl station wlan0 connect $SSID --passphrase $WIFI_PASSPHRASE
timedatectl



## Partitioning https://wiki.archlinux.org/title/Installation_guide#Partition_the_disks
# Delete /dev/sda1, /dev/sda2, /dev/sda3, /dev/sda4
partitions=$(ls /dev/sda* | grep -o '[0-9]' || true)
printf "%s" "$partitions" | xargs -t -I {} bash -c "printf 'd\n{}\nw\n' | fdisk /dev/sda"

## Boot partition
printf 'g\nn\n\n\n+300m\ny\nt\n1\nw\n' | fdisk /dev/sda

## Swap partition
printf 'n\n\n\n+4g\ny\nt\n2\nswap\nw\n' | fdisk /dev/sda

## Root partition
printf 'n\n\n\n\nY\nw\n' | fdisk /dev/sda


sleep 10

## Format partitions https://wiki.archlinux.org/title/Installation_guide#Format_the_partitions
mkfs.ext4 /dev/sda3
mkswap /dev/sda2
mkfs.fat -F 32 /dev/sda1


mount /dev/sda3 /mnt
mount --mkdir /dev/sda1 /mnt/boot
swapon /dev/sda2

sleep 10

## Format partitions https://wiki.archlinux.org/title/Installation_guide#Install_essential_packages
pacstrap -K /mnt base linux linux-firmware

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

pacman -S iwd curl iputils vim dhcpcd sudo base-devel git
systemctl enable iwd
systemctl start iwd
systemctl enable dhcpcd
systemctl start dhcpcd

# Setup zoneinfo
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

# Sync time
hwclock --systohc

sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
sed -i 's/#fr_FR.UTF-8/fr_FR.UTF-8/g' /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=fr-latin1" > /etc/vconsole.conf
echo "yannp" > /etc/hostname


# Install Grub
pacman -S intel-ucode grub efibootmgr

mkdir -p /boot/EFI
mount /dev/sda1 /boot/EFI
grub-install --target=x86_64-efi --efi-directory=/boot --bootlader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg


## Gnome Desktop environment
pacman -S gnome gnome-tweaks gnome-shell-extensions networkmanager gnome-network-displays gnome-shell-extension-dash-to-dock
systemctl enable gdm

## Packages
pacman -S fish firefox-developer-edition

exit

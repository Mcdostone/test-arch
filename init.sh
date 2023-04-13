#!/usr/bin/env bash

set -euo pipefail

# Getting started

## Azerty keyboard
loadkeys fr-latin1

## Internet
iwctl station wlan0 get-networks
iwctl station wlan0 connect $SSID --passphrase $WIFI_PASSPHRASE
timedatectl



## Partitioning https://wiki.archlinux.org/title/Installation_guide#Partition_the_disks
# Delete /dev/sda1, /dev/sda2, /dev/sda3, /dev/sda4
ls /dev/sda* | grep -E '/dev/sda[0-9]+' | grep -o '[0-9]' | xargs -t -I {} bash -c "printf 'd\n{}\nw\n' | fdisk /dev/sda"

## Boot partition
printf 'g\nn\n\n+300m\ny\nt\n1\nw\n' | fdisk /dev/sda

## Swap partition
printf 'n\n\n\n+4g\n\n\nw\n' | fdisk /dev/sda

## Root partition
printf 'n\n\n\n\nw\n' | fdisk /dev/sda


## Format partitions https://wiki.archlinux.org/title/Installation_guide#Format_the_partitions
mkfs.ext4 /dev/sda3
mkswap /dev/sda2
mkfs.fat -F 32 /dev/sda1

mount --mkdir /dev/sda1 /mnt/boot
swapon /dev/sda2


## Format partitions https://wiki.archlinux.org/title/Installation_guide#Install_essential_packages
pacstrap -K /mnt base linux linux-firmware iwd curl iputils vim dhcpcd sudo

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

# Setup zoneinfo
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

# Sync time
hwclock --systohc

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen

locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "KEYMAP=fr-latin1" > /etc/vconsole.conf

echo "yannp" > /etc/hostname


# Install Grub
pacman -S intel-ucode
grub-install --target x --efi+directory=/boot --bootlader+id=GRUB 
grub-mkconfig -o /boot/grub/grub.cfg


## Gnome Desktop environment
sudo pacman -S gnome gnome-tweaks gnome-shell-extensions networkmanager gnome-network-displays gnome-shell-extension-dash-to-dock

## Packages
sudo pacman -S fish firefox-developer-edition

exit

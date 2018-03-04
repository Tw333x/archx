#!/usr/bin/env bash

mkdir -p /mnt/var/cache/pacman/pkg/ && cd /mnt/var/cache/pacman/pkg/
clear

echo "You are here : " && pwd

# SELECT ACTION
echo -e "The whole system packages will be recreate! proceed?(y/n)[n]:\n "
read -p "=> " Answer_Package_Recreate

case "$Answer_Package_Recreate" in
	
	"y"|"Yes"|"YES"|"Y")
		$( pacman -Qq | awk ' { print $1 } ' |sed  's/^.*\// /g' > PackageList.txt)
		;;
	*) 
		echo "No package will be recreate..."
		exit
		;;
esac

# RECREATE PACKAGES FROM LIVE SYSTEM
String=$(cat PackageList.txt)

for Package in $String; do
    bacman $Package
done


rm -f PackageList.txt *.part

cd

# INSTALL PACKAGES TO /MNT
pacstrap /mnt base 2> /dev/null

mkdir -m 755 -p /mnt/boot

cp -avT /run/archiso/bootmnt/arch/boot/$(uname -m)/vmlinuz /mnt/boot/vmlinuz-linux

pacman -r /mnt -U /mnt/var/cache/pacman/pkg/*

chmod 700 /mnt/root

clear

# GENERATE FSTAB
genfstab -U -p /mnt >> /mnt/etc/fstab && cat /mnt/etc/fstab

echo -e '\n Connect internet and execute : curl -s -o chroot_jobs.sh   https://raw.githubusercontent.com/virtualdemon/archx/master/chroot_jobs.sh && chmod +x chroot_jobs.sh && ./chroot_jobs.sh'

# CHROOT TO INSTALLED SYSTEM AND MAKE CUSTOMIZATION
arch-chroot /mnt 


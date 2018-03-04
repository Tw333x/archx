#!/usr/bin/env bash

mkdir -p /mnt/var/cache/pacman/pkg/ && cd /mnt/var/cache/pacman/pkg/
clear

echo "You are here : " && pwd

# SELECT ACTION
echo -e "Which installed packages you want to recreate? :\n1) all \n2) base \n3) base and base-devel\n"
read -p "=> " Answer_Package_Recreate

case "$Answer_Package_Recreate" in
	
	"1"|"all"|"ALL"|"All")
		$( pacman -Qq | awk ' { print $1 } ' |sed  's/^.*\// /g' > PackageList.txt)
		;;
 
  "2"|"base"|"BASE"|"Base") 
    $( pacman -Ss base |grep 'installed' | awk ' { print $1 } ' |sed  's/^.*\// /g' > PackageList.txt)
    ;;
  
  "3"|"base and base-devel"|"bases") 
    $( pacman -Ss base |grep 'installed' | awk ' { print $1 } ' |sed  's/^.*\// /g' > PackageList.txt && pacman -Ss base-devel |grep 'installed' | awk ' { print $1 } ' |sed  's/^.*\// /g' >> PackageList.txt)
    ;;

	*) 
		echo "So will exit..."
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
arch-chroot /mnt /usr/bin/zsh


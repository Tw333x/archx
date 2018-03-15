#!/usr/bin/env bash

# Check internet connection : for offline installation
if [[ ! $( ping -c 3 8.8.8.8 ) ]]; then

    echo  -e "  >> Starting oflline installation \n"
    sleep 3
    else
      echo -e "   >> Internet Connection detected ! exiting..."
      sleep 2
      exit -1
fi

# Create pacman-cache directory and change directory to there
mkdir -p /mnt/var/cache/pacman/pkg/ && cd /mnt/var/cache/pacman/pkg/
clear

echo "You are here : " && pwd

# Recreate live system packages with bacman
read -p "The whole system packages will be recreate! proceed?(y/n)[n]: " Answer_Package_Recreate

case "$Answer_Package_Recreate" in
	
	"y"|"yes"|"Yes"|"YES"|"Y")
        for package in $(pacman -Qq); do 
          bacman $package 
        done
		;;

	*) 
		echo "No package will be recreate..."
		exit
		;;
esac

# Remove corrupted packages
rm -f *.part

# Change directory to ~/
cd

# Pacstrap packages without installation (just for creating the base system directories...)
pacstrap /mnt base 

# Create boot directory in new system
mkdir -m 755 -p /mnt/boot

# Copy vmlinuz-linux from live system  to new system 
cp -avT /run/archiso/bootmnt/arch/boot/$(uname -m)/vmlinuz /mnt/boot/vmlinuz-linux

# Start Offline package installation to /mnt
pacman -r /mnt -U /mnt/var/cache/pacman/pkg/* 2> /dev/null

# Change root directory permissions
chmod 700 /mnt/root

clear

# Generate FSTAB via devices uuid : you can edit it in /etc/fstab
genfstab -U -p /mnt >> /mnt/etc/fstab && cat /mnt/etc/fstab

# Manual for using the chroot_jobs.sh in https://github.com/virtualdemon/archx
echo -e '\nNow you can connect to internet and execute : curl -s -o chroot_jobs.sh   https://raw.githubusercontent.com/virtualdemon/archx/master/chroot_jobs.sh && chmod +x chroot_jobs.sh && ./chroot_jobs.sh'

# Change root to the new installed system in /mnt
arch-chroot /mnt 


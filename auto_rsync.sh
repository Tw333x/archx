#!/usr/bin/env bash

# Copy whole live-system to new system (without excluded directories)
rsync -aAXvP /* /mnt --exclude={/dev/*,/proc/*,/sys/*,/tmp/*,/run/*,/mnt/*,/media/*,/lost+found,/.gvfs}

# Copy vmlinuz-linux to new system
cp -avT /run/archiso/bootmnt/arch/boot/$(uname -m)/vmlinuz /mnt/boot/vmlinuz-linux

# Edit live system rules in new system for daily usage...
sed -i 's/Storage=volatile/#Storage=auto/' /mnt/etc/systemd/journald.conf

rm /mnt/etc/udev/rules.d/81-dhcpcd.rules

rm /mnt/root/{.automated_script.sh,.zlogin}

rm -r /mnt/etc/systemd/system/{choose-mirror.service,pacman-init.service,etc-pacman.d-gnupg.mount,getty@tty1.service.d}

rm /mnt/etc/systemd/scripts/choose-mirror

chmod 700 /mnt/root

# Generate FSTAB with uuid for new system
genfstab -U -p /mnt >> /mnt/etc/fstab && cat /mnt/etc/fstab

# Manual for using the chroot_jobs.sh in https://github.com/virtualdemon/archx
echo -e "\nYou can run this command to start chroot_job scripts : curl -s -o chroot_jobs.sh https://raw.githubusercontent.com/virtualdemon/archx/master/chroot_jobs.sh && chmod +x chroot_jobs.sh && ./chroot_jobs.sh"

# Change root to new system
arch-chroot /mnt 

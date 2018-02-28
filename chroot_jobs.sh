#!/usr/bin/env bash
# before running this script you should install sudo , grub , os-prober with below command:
# pacman -S grub sudo --needed --noconfirm

echo -e "Set a PASSWORD for root user : \n "
passwd

read -p  "Please enter a USERNAME : " USER_NAME_INPUT
useradd -m -g users  -G wheel,storage,power  -s $(which zsh) $USER_NAME_INPUT

echo -e "Set a PASSWORD for $USER_NAME_INPUT : "
passwd $USER_NAME_INPUT

echo -e "Setting timezone(Iran) \n"
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Iran /etc/localtime 
hwclock --systohc --utc

echo -e "Setting hostname \n"
read -p "Please enter youre HOSTNAME : " HOST_NAME_INPUT
echo $HOST_NAME_INPUT > /etc/hostname

echo -e "Setting locale \n"
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen

echo -e "Edit /etc/sudoers (let wheel users to execute sudo!) \n"
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers

echo -e "Start installing BootLoader(grub) \n"
read -p "On which device you want to  install BOOTLOADER ? (Default = /dev/sda) : " DEVICE_INPUT
if [[ "$DEVICE_INPUT" !=  "/dev/sda" &&  ! -z "$DEVICE_INPUT" ]]; then
    grub-install --target=i386-pc --recheck $DEVICE_INPUT
else
    grub-install --target=i386-pc --recheck /dev/sda
fi

echo "Making initramfs \n"
read -p "Which KERNEL did you installed(linux or linux-zen or linux-hardened)? (Default = linux) : " KERNEL_TYPE_INPUT
if [[ "$KERNEL_TYPE_INPUT" !=  "linux" &&  ! -z "$KERNEL_TYPE_INPUT" ]]; then
    mkinitcpio -p $KERNEL_TYPE_INPUT      
else
    mkinitcpio -p linux
fi

echo -e "Making GRUB CONFIG \n"
grub-mkconfig -o /boot/grub/grub.cfg



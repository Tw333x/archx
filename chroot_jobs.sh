#!/usr/bin/env bash

export LC_ALL=C

clear

# Check if user was root continue the script
if [[ $( id -u ) != 0 ]]

then

     echo -e "\n >> Can't install without root user permissions \n exiting"

    exit -1

fi

# Check the internet connection : you should be ONLINE
echo -e "\n    >> Checking internet connection...."
if [[ ! $( ping -c 3 8.8.8.8 ) ]]

then

    echo  -e "    >> Connection is not stable .... \n exiting..."

    exit -1

fi

# Provide pacman for first use :
pacman -Sy
pacman-key --init
pacman-key --populate archlinux
pacman-key --refresh-keys

# Install tools for bootloader installation
echo -e "Installing needed tools ! \n"
if [[ -d "/boot/efi" || -d "/boot/EFI" ]]; then
    echo "  >> EFI partition detected! \n"
    pacman -S grub dosfstools efibootmgr os-prober --needed --noconfirm
    else
        pacman -S grub os-prober --needed --noconfirm
fi

clear

# Set password for root user 
echo -e "Set a PASSWORD for root user : \n "
passwd

# Create a normal user
read -p  "Please enter a USERNAME : " USER_NAME_INPUT
useradd -m -g users  -G wheel,storage,power  -s $(which zsh) $USER_NAME_INPUT

# Set password for new normal user
echo -e "Set a PASSWORD for $USER_NAME_INPUT : "
passwd $USER_NAME_INPUT

# Set timezone to Iran
echo -e "Setting timezone(Iran) \n"
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Iran /etc/localtime 
hwclock --systohc --utc

clear

# Set hostname for new system
echo -e "Setting hostname \n"
read -p "Please enter youre HOSTNAME : " HOST_NAME_INPUT
echo $HOST_NAME_INPUT > /etc/hostname

# Set locale for new system
echo -e "Setting locale \n"
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen

# Add permission for wheel users to run commands with sudo
echo -e "Edit /etc/sudoers (let wheel users to execute sudo!) \n"
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers

clear

# Install grub bootloader
echo -e "Start installing BootLoader(grub) \n"

if [ -d "/boot/efi" ]; then
    echo -e "    >> EFI partition detected !\n"
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch_grub --recheck --debug --force 
  elif [ -d "/boot/EFI" ]; then
    grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=arch_grub --recheck -- debug --force
  else
    read -p "On which device you want to  install BOOTLOADER ? (Default = /dev/sda) : " DEVICE_INPUT
    if [[ "$DEVICE_INPUT" != "/dev/sda" &&  ! -z "$DEVICE_INPUT" ]]; then
        grub-install --target=i386-pc --recheck $DEVICE_INPUT
        else
            grub-install --target=i386-pc --recheck /dev/sda
    fi
  fi

# Make initramfs
echo -e "Making initramfs \n"
read -p "Which KERNEL did you installed(linux or linux-zen or linux-hardened)? (Default = linux) : " KERNEL_TYPE_INPUT
if [[ "$KERNEL_TYPE_INPUT" !=  "linux" &&  ! -z "$KERNEL_TYPE_INPUT" ]]; then
    mkinitcpio -p $KERNEL_TYPE_INPUT      
else
    mkinitcpio -p linux
fi

# Create grub config
echo -e "Making GRUB CONFIG \n"
grub-mkconfig -o /boot/grub/grub.cfg

# Add pacaur_installer script in : /opt/user_bin/pacaur_installer
echo -e "Making pacaur_installer script in /opt/user_bin for install aur: \n"
mkdir -p /opt/user_bin
touch /opt/user_bin/pacaur_installer && chmod +x /opt/user_bin/pacaur_installer

tee -a /opt/user_bin/pacaur_installer << END
#!/usr/bin/env bash
if ! command -v pacaur >/dev/null; then
    tmp=$(mktemp -d)
    function finish {
        rm -rf "$tmp"
    }
    trap finish EXIT
    
    pushd $tmp
    sudo pacman -Syu && sudo pacman -S base-devel --needed
    for pkg in cower pacaur; do
        curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=$pkg && \
            makepkg --needed --noconfirm --skippgpcheck -sri
    done
    popd

    if ! command -v pacaur >/dev/null; then
        >&2 echo "Pacaur wasn't successfully installed"
        exit 1
    fi
fi
END

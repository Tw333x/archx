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

# Add pacaur_installer script in : /mnt/opt/user_bin/pacaur_installer
echo -e "Creating pacaur_installer script in /mnt/opt/user_bin for install aur: \n"
mkdir -p /mnt/opt/user_bin
touch /mnt/opt/user_bin/pacaur_installer && chmod +x /mnt/opt/user_bin/pacaur_installer

tee -a /mnt/opt/user_bin/pacaur_installer << END
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

# Creating chroot_jobs script in : /mnt/opt/user_bin/chroot_jobs
touch /mnt/opt/user_bin/chroot_jobs && chmod +x /mnt/opt/user_bin/chroot_jobs

tee -a /mnt/opt/user_bin/chroot_jobs << END
#!/usr/bin/env bash

export LC_ALL=C

clear

# Check if user was root continue the script
if [[ $( id -u ) != 0 ]];then

     echo -e "\n >> Can't install without root user permissions \n exiting"

    exit

fi

# Check the internet connection : you should be ONLINE
echo -e "\n    >> Checking internet connection...."
if [[ ! $( ping -c 3 8.8.8.8 ) ]];then

    echo  -e "    >> Connection is not stable .... \n Exiting..."
    exit

fi

# Provide pacman for first use :
pacman -Sy
pacman-key --init
pacman-key --populate archlinux
pacman-key --refresh-keys

# Install tools for bootloader installation
echo -e "Installing needed tools ! \n"
if [ -d "/sys/firmware/efi"  ]; then
    echo "  >> EFI detected! \n"
    pacman -S grub dosfstools efibootmgr os-prober --needed --noconfirm
    else
        pacman -S grub os-prober --needed --noconfirm
fi

clear

# Set password for root user
echo -e "Set a PASSWORD for root user : \n "
while [ 1 ]; do
    passwd
    if [ ! $? == "0" ];then
      clear
      echo -e "Set a PASSWORD for root user : \n"
      passwd
    else
      exit
    fi
  done

# Create a normal user
read -p  "Please enter a USERNAME : " USER_NAME_INPUT
useradd -m -g users  -G wheel,storage,power  -s $(which zsh) $USER_NAME_INPUT

# Set password for new normal user
echo -e "Set a PASSWORD for $USER_NAME_INPUT : "
while [ 1 ]; do
  passwd $USER_NAME_INPUT
    if [ ! $? == "0" ];then
      clear
      echo -e "Set a PASSWORD for $USER_NAME_INPUT : \n"
      passwdo $USER_NAME_INPUT
    else
      exit
    fi

# Set timezone
echo -e "Found your timezone path\nPress ARROW KEYS to move and Press q to quit..."
rm -f /etc/localtime
ls -R /usr/share/zoneinfo | less
while [ 1 ];do
  read -p "Enter your selected region (e.g.:(/usr/share/zoneinfo/Iran)): " $SELECTED_REGION
  ln -sf  $SELECTED_REGION /etc/localtime
    if [ ! $? == "0" ];then
      clear
      echo -e "Entered Wrong path...\n"
    else
      exit
    fi
  done
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
if [ -d "/sys/firmware/efi" ]; then
    if [ -d "/boot/efi" ]; then
       echo -e "    >> EFI partition detected !\n"
       grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch_grub --        recheck --debug --force
    elif [ -d "/boot/EFI" ]; then
      echo -e "    >> EFI partition detected !\n"
      grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=arch_grub --         recheck --debug --force
      else
        while [ 1 ]; do
            read -p "Where is esp (EFI) partition mounted (e.g.: /boot , /boot/esp) ? " EFI_MOUNTPOINT
            echo -e "   >> EFI partition is $EFI_MOUNTPOINT"
            if [ -d "$EFI_MOUNTPOINT" ];then
              grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=arch_grub -- recheck --debug --force
              exit
            else
              echo -e "You entered wrong EFI MOUNTPOINT \n"
            fi
          done
        fi
  else
    echo -e "    >> Legacy mode detected... !\n"
    read -p "On which device you want to  install BOOTLOADER ? (Default = /dev/sda) : " DEVICE_INPUT
    if [[ "$DEVICE_INPUT" != "/dev/sda" &&  ! -z "$DEVICE_INPUT" ]]; then
        grub-install --target=i386-pc --recheck $DEVICE_INPUT
        else
            grub-install --target=i386-pc --recheck /dev/sda
    fi
  fi
# Make initramfs
echo -e "Making initramfs \n"
read -p "Which KERNEL did you installed(linux or linux-zen or linux-hardened)? (Default = linux) : "  KERNEL_TYPE_INPUT
if [[ "$KERNEL_TYPE_INPUT" !=  "linux" &&  ! -z "$KERNEL_TYPE_INPUT" ]]; then
    mkinitcpio -p $KERNEL_TYPE_INPUT
else
    mkinitcpio -p linux
fi

# Create grub config
echo -e "Making GRUB CONFIG \n"
grub-mkconfig -o /boot/grub/grub.cfg

END
# Change root to the new installed system in /mnt
clear
read -p "CHROOT time! do you want to use chroot_jobs script for do your chroot jobs? (yes/no/shell) " $CHROOT_MOD_CHOOSE
case "$answer" in
    
    "yes"|"y"|"Y"|"Yes"|"YES"|"YeS"|"yES"|"yeS"|"yEs") 
    $( arch-chroot /mnt /bin/bash -c "/opt/user_bin/chroot_jobs" )
    ;;
	
		"no"|"NO"|"No"|"n"|"N"|"nO") 
			echo -e "Change root in normal mod..\n"
      $( chroot /mnt /bin/bash )
			;;
    
    "Shell"|"shell"|"sh"|"SHELL"|"shel")
      exit
      ;;
    *)
      echo -e "Exiting...\n if you want to use auto chroot_jobs execute : \narch-chroot /bin/bash -c '/opt/user_bin/chroot_jobs'"
esac


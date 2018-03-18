<<<<<<< HEAD
<h1>About ArchX</h1><br/>
ArchX is a ArchLinux installer script which helps you to install ArchLinux while your offline, further more, it uses **bacman** to extract packages from ArchLinux ISO you booted, in addition, it conveys all packages to **/mnt** , on the other hand you are not forced to use Pacstrap script thus you'll have all needed packages installed! 
=======
<h1>About ArchX</h1>
ArchX is a ArchLinux installer script which helps you to install ArchLinux while your offline, further more, it uses **bacman** to extract packages from ArchLinux ISO you booted, in addition, it conveys all packages to **/mnt**, on the other hand you are not forced to use Pacstrap script thus you'll have all needed packages installed! 
>>>>>>> ee7ea6642b38d005710ad2711435faa721f8c6a7

<h2>Archlinux Offline installer! </h2><br/>

1 : Design your hard disk layout with **cfdisk** or **parted** or **gdisk** (for GPT disks) or **fdisk** <br/> 

2 : Format your partitions with `mkfs` (make file systems) (e.g. : `mkfs.ext4 /dev/sda4` or `mkswap /dev/sda7`) <br/>

3 : Mount the partitions on __/mnt__ <br/> 
(i.e. you have four partitions like below: <br/>
<pre>
partition       mountpoint
/dev/sda4       /boot
/dev/sda5       /
/dev/sda6       /home
/dev/sda7       swap area
</pre>
 Prepare swap and mount partitions like following commads:<br/>
<b>`swapon /dev/sda7`</b><br/>
<b>`mount /dev/sda5 /mnt`</b><br/>
<b>`mkdir -p /mnt/{boot,home}`</b><br/>
<b>`mount /dev/sda4 /mnt/boot`</b><br/>
<b>`mount /dev/sda6 /mnt/home`</b><br/>
)<br/>

<h2>5 : Extract and install packages on /mnt :</h2>

<h4>Rebuilding live system installed packages (with bacman)</h4> 

<b>`curl -s -o installer https://raw.githubusercontent.com/virtualdemon/archx/master/installer && chmod +x installer && ./installer` </b>  

6 : You can read script's source before running it to see what will happen ... : `cat installer` <br/>
Also if you need to do your chroot customizations automatically, you can run following command in chroot environment : <br/>
<b>`curl -s -o auto_chroot https://raw.githubusercontent.com/virtualdemon/archx/master/auto_chroot && chmod +x auto_chroot && ./auto_chroot`</b> 
<br/><br/>

8 : When your customization finished you can `exit` and `reboot` system to use your installed arch linux .<br/>

9 : For using pacman (if you didn't execute auto_chroot) as the first time run these commands :<br/>
`pacman -Sy` <br/>
`pacman-key --init` <br/>
`pacman-key --populate archlinux`<br/>
`pacman-key --refresh-keys`<br/>

10 : For using AUR script in `/opt/user_bin/pacaur_installer` just make it execute and install pacaur!


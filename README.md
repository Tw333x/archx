Thanks for using Archx ;<br/>

<h2>Archlinux Offline installer! </h2><br/>

1 : Login to system with "`root`" ; in ArchLinux live system you'll login automatically. <br/>

2 : Design your hard disk layout with **cfdisk** or **parted** or **gdisk** (for GPT disks) or **fdisk** <br/> 

3 : Format your partitions with `mkfs` (make file systems) (e.g. : `mkfs.ext4 /dev/sda4` or `mkswap /dev/sda7`) <br/>

4 : Mount the partitions to __/mnt__ <br/> 
(for example you have four partitions !: <br/>
<pre>
partition       mountpoint
/dev/sda4       /boot
/dev/sda5       /
/dev/sda6       /home
/dev/sda7       swap area
</pre>
you should make swap on and mount partitions!:<br/>
<b>`swapon /dev/sda7`</b><br/>
<b>`mount /dev/sda5 /mnt`</b><br/>
<b>`mkdir -p /mnt/{boot,home}`</b><br/>
<b>`mount /dev/sda4 /mnt/boot`</b><br/>
<b>`mount /dev/sda6 /mnt/home`</b><br/>
)<br/>

<h2>5 : Install to /mnt :</h2>

<h4>With rebuilding live system installed packages (with bacman)</h4> 

<b>`curl -s -o install_system.sh https://raw.githubusercontent.com/virtualdemon/archx/master/auto_bacman.sh && chmod +x install_system.sh && ./install_system.sh` </b>  

<h4>With rsync tool (copy live system to source) </h4>

<b>`curl -s -o install_system.sh https://raw.githubusercontent.com/virtualdemon/archx/master/auto_rsync.sh && chmod +x install_system.sh && ./install_system.sh`</b>
<br/><br/>
6 : You can read this script to see what will happen ... : `cat install_system.sh` <br/>
Also if you want to do your chroot customizations automatically you can run below command in chroot environment : <br/>
<b>`curl -s -o chroot_jobs https://raw.githubusercontent.com/virtualdemon/archx/master/chroot_jobs.sh && chmod +x chroot_jobs && ./chroot_jobs`</b> 
<br/><br/>
7 : After system installation you can make your customization in CHROOT environment <br/>

8 : When your customization finished you can `exit` and `reboot` system to use your installed arch linux .<br/>

9 : For using pacman for first time run this commands :<br/>
`pacman -Sy` <br/>
`pacman-key --init` <br/>
`pacman-key --populate archlinux`<br/>
`pacman-key --refresh-keys`<br/>

10 : For using aur a script exist in `/opt/user_bin/pacaur_installer` just execute that to install pacaur!


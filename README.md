Thanks for installing Archx ;<br/>

<h2>this is an easy way to install ArchLinux ;</h2><br/>

1 : Login to system with "root" user and "archx_root" password <br/>
2 : You can execute <b>startx</b> command to run graphical environment!(if you are already in tty...) <br/>
3 : Design your hard disk layout with cfdisk or parted or gdisk(for GPT disks) or gparted (graphical tool)<br/> 
4 : Format your partitions with mkfs (e.g : mkfs.ext4 /dev/sda4) <br/>
5 : Mount the partitions to /mnt<br/> 
(for example you have four partition !:<br/>
<pre>
partition       mountpoint
/dev/sda4       /boot
/dev/sda5       /
/dev/sda6       /home
/dev/sda7       swap area
</pre>
you should make swap on and mount partitions!:<br/>
<b>swapon /dev/sda7</b><br/>
<b>mount /dev/sda5 /mnt</b><br/>
<b>mkdir -p /mnt/boot /mnt/home</b><br/>
<b>mount /dev/sda4 /mnt/boot</b><br/>
<b>mount /dev/sda6 /mnt/home</b><br/>
)<br/>
6 : Download the installer script :<br/> 
<b>curl -s -o install_system.sh https://raw.githubusercontent.com/virtualdemon/archx/master/install_system.sh && chmod +x install_system.sh && ./install_system.sh
</b><br/> 
7 : You can read this script to see what will happen ... : <b> cat install_system.sh </b><br/>
for information : this script will install base system from the live system and turn off or delete some services ... and download some other files from <b>https://github.com/virtualdemon/archx</b> also you can intall arch linux in way of net-install! <br/><br/>
8 : After system installation you can make your customization in CHROOT environment <br/>
9 : When your customization finished you can <b>exit</b> and <b>reboot</b> system to use your installed arch linux .

install
cmdline

url --url http://archive.kernel.org/centos-vault/7.2.1511/os/x86_64

lang en_US.UTF-8
keyboard us
timezone America/New_York

network --bootproto dhcp --device eth0

rootpw packer

authconfig --enableshadow
firewall --enabled --port 22:tcp
selinux --disabled
firstboot --disabled

bootloader --location mbr --driveorder sda --append "rdblacklist=nouveau nouveau.modeset=0"

clearpart --drives sda --all --initlabel
zerombr

part /boot --fstype ext4 --size 400 --ondisk sda
part pv.01 --size 1 --grow --ondisk sda
volgroup VG_localhost_sys --pesize 4096 pv.01
logvol swap --fstype swap --name LV_swap --vgname VG_localhost_sys --size 1024
logvol / --fstype ext4 --name LV_localhost_sys --vgname VG_localhost_sys --size 1 --grow

reboot

%packages --nobase
@core
%end

%pre
exec < /dev/tty6 > /dev/tty6 2>&1
chvt 6
runcmd() {
  local cmd="$1"

  output=$(eval "$cmd")
  echo "--- $cmd"
  echo "$output"
}

runcmd "modinfo hpsa sg | egrep '^(filename|version):'"
runcmd "lsmod | egrep 'hpsa|cciss|sg'"

echo -n "Press <enter> to continue..."
read text

# Drop into a shell to continue debugging
/bin/sh

chvt 1
exec < /dev/tty1 > /dev/tty1 2>%1
%end

%post
# Intentionally left blank
%end

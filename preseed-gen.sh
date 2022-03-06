#!/bin/bash

test -f preseed/${TARGET}.env || exit -1 && . preseed/${TARGET}.env

cat<<EOF

#############
#
# Localization
#
#############

d-i debian-installer/locale string en
d-i debian-installer/country string US
d-i debian-installer/locale string en_US.UTF-8
d-i debian-installer/language string en

#############
#
# Keyboard
#
#############

# Disable automatic (interactive) keymap detection.
d-i console-setup/ask_detect boolean false
d-i console-setup/layoutcode string us
d-i console-setup/variantcode string
d-i keyboard-configuration/layoutcode string us

d-i mirror/http/proxy string
d-i pkgsel/install-language-support boolean false
tasksel tasksel/first multiselect standard, ubuntu-server

d-i netcfg/use_autoconfig boolean false 
d-i netcfg/disable_autoconfig boolean true 
 
d-i netcfg/choose_interface select ${TARGET_IF}
d-i netcfg/disable_dhcp boolean true
d-i netcfg/get_nameservers string 89.32.32.32
d-i netcfg/get_ipaddress string ${TARGET_IP}
d-i netcfg/get_netmask string ${TARGET_NETMASK}
d-i netcfg/get_gateway string ${TARGET_GATEWAY}
d-i netcfg/confirm_static boolean true 
d-i netcfg/get_hostname string ${TARGET_HOSTNAME}
d-i netcfg/get_domain string sunet.se
d-i netcfg/wireless_wep string

d-i clock-setup/utc-auto boolean true
d-i clock-setup/utc boolean false
d-i time/zone string Europe/Stockholm

# disks & filesystems
d-i partman-auto/disk string /dev/sda /dev/sdb
d-i partman-auto/method string raid
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true
d-i preseed/early_command string umount /media ; dd if=/dev/zero of=/dev/sda bs=1M count=1 ; dd if=/dev/zero of=/dev/sdb bs=1M count=1

# new

# Define physical partitions
d-i     partman-auto/expert_recipe      string		\\
         multiraid ::					\\
              1 1 1 free				\\
                 \$primary{ }				\\
                 \$lvmignore{ }				\\
                 method{ biosgrub }			\\
                 .					\\
              8192 10000 100000000 raid			\\
                 \$primary{ } \$lvmignore{ } method{ raid } raidid{ 1 }	\\
                 .					\\
              64 512 200% linux-swap			\\
                 \$primary{ } \$lvmignore{ } method{ swap } format{ } 	\\
                 .

d-i partman-auto-raid/recipe string	\\
    1 2 0 ext3 / raidid=1 .

d-i mdadm/boot_degraded boolean true
d-i partman-md/confirm boolean true
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman-md/confirm_nooverwrite  boolean true
d-i partman/confirm_nooverwrite boolean true
d-i partman-lvm/confirm_nooverwrite boolean true
d-i partman/mount_style select label

d-i base-installer/install-recommends boolean true 
d-i base-installer/kernel/image string linux-generic 
 
d-i passwd/root-login boolean true 
d-i passwd/make-user boolean false 
d-i passwd/root-password password RuabAjIngyia
d-i passwd/root-password-again password RuabAjIngyia
d-i user-setup/allow-password-weak boolean true 
d-i user-setup/encrypt-home boolean false 
d-i preseed/late_command string in-target mkdir -p /root/.ssh ; cp /cdrom/authorized_keys /target/root/.ssh/authorized_keys ; in-target chmod -R go-rwx /root/.ssh
 
d-i apt-setup/use_mirror boolean true 
 
d-i debian-installer/allow_unauthenticated boolean true 
tasksel tasksel/first multiselect none 
d-i pkgsel/include string openssh-server
d-i pkgsel/upgrade select none
d-i pkgsel/update-policy select unattended-upgrades
d-i pkgsel/install-language-support boolean true 
popularity-contest popularity-contest/participate boolean false 
d-i pkgsel/updatedb boolean true 
 
d-i grub-installer/grub2_instead_of_grub_legacy boolean true 
d-i grub-installer/only_debian boolean true
d-i grub-installer/bootdev string /dev/sda /dev/sdb
 
d-i finish-install/reboot_in_progress note
EOF

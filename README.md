
# cat >preseed/name_of_target.env<EOF
TARGET_IP=...
TARGET_NETMASK=...
TARGET_GATEWAY=...
TARGET_HOSTNAME=name_of_target
TARGET_IF=name_of "first" ethernet if

EOF
# make TARGET=name_of_target

Should produce output in iso directory. Config is highly opinionated - disks are bundled together as mirror. Full disk is used. Edit preseed-gen.sh to change.

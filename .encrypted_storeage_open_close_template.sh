#!/bin/bash

## MOUNT:
#  cryptsetup open --type luks ${drive} red_storage_lvm
#  vgchange -a y red_storage_vg
#  mount /dev/mapper/red_storage_vg-red_storage_lv /mnt
#
## UMOUNT:
#  umount /dev/mapper/red_storage_vg-red_storage_lv
#  vgchange -a n red_storage_vg
#  cryptsetup luksClose red_storage_lvm

NAME="put_the_name_of_your_lukscrypt_here"
lvm_mount="${NAME}_lvm"
vg_mount="${NAME}_vg"
lv_mount="${NAME}_lv"
mount_to="/${NAME}"

drive_location () {
  drive="$(ls -l /dev/sd* | tail -1 | awk '{print $10}')"
  echo "Please confirm this partition: $drive"
  echo "Use partition $drive ? [yes/No]" && read input
  if [ "$input" = "yes" ] || [ "$input" = "YES" ]; then
    echo "Using partition $drive"
  else
    echo "Enter the full path to the partition: " && read drive
    echo "Using partition $drive"
  fi
}

luks_drive_open () {
  drive_location
  mkdir -p $mount_to
  cryptsetup open --type luks $drive $lvm_mount && sleep 2 || exit 1
  vgchange -a y $vg_mount && sleep 2 || exit 1
  mount /dev/mapper/${vg_mount}-${lv_mount} $mount_to || exit 1
  df -h |grep --color=never "Mounted on\|${NAME}"
  echo "$lvm_mount has been mounted to $mount_to."
}

luks_drive_close () {
  umount /dev/mapper/${vg_mount}-${lv_mount} && sleep 2 || exit 1
  vgchange -a n $vg_mount && sleep 2 || exit 1
  cryptsetup luksClose $lvm_mount || exit 1
  rm -rf $mount_to
  echo "${lvm_mount} has been unmounted from ${mount_to}."
}

main () {
  if [ "$1" = "open" ]; then luks_drive_open
  elif [ "$1" = "close" ]; then luks_drive_close
  else
    printf "\nTo MOUNT the volume: \`bash $0 open\`\n"
    printf "\nTo UNmount the volume: \`bash $0 close\`\n\n" && exit 1
  fi
}
main $@

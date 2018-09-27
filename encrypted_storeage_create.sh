#!/bin/bash

#------------------------------------------------------
#  SIDE-NOTE:
#  -when mounting the encrypted LVM partition, do this:
#  cryptsetup open --type luks /dev/sd[x,[X]] lvm_mount_name
#  vgchange -a y lvm_mount_name
#  mount /dev/mapper/lvm_mount_name
#  
#  -and to close the LVM partition, do this:
#  umount /dev/mapper/lvm_mount_name
#  vgchange -a n lvm_mount_name
#  cryptsetup luksClose lvm_mount_name
#------------------------------------------------------


take_input () {
  echo "Do you want to use the last storage device detected ($(ls /dev/sd* |tail -n1))? [enter YES to confirm] " && read CHOICE
  if [ $CHOICE = "YES" ]; then
    DRIVE_PATH="$(ls /dev/sd* |tail -n1)"
  else
    echo "Enter the full path to the store device you want to encrypt " && read DRIVE_PATH
  fi
  echo "Enter a name for this encrypted container here " && read NAME
  LVM_NAME="${NAME}_lvm"
  VOLUME_GROUP_NAME="${NAME}_vg"
  LOGICAL_VOLUME_GROUP_NAME="${NAME}_lv"
  MOUNT_POINT="/${NAME}"
}


## Create partition layout
partition_drive () {
  echo "$DRIVE_PATH will be used, is this correct? [enter YES to confirm] " && read input_check
  [ $input_check = "YES" ] && echo -e "o\nn\np\n1\n\n\nt\n8e\np\nw" | fdisk $DRIVE_PATH
  sleep 3
  PARTITION_PATH="$(ls /dev/sd* |tail -n1)" 
}


## Create and open the LUKS encrypted container at the "system" partition :
create_luks_container () {
  printf "\nFORMATTING ${PARTITION_PATH} TO LUKS ...\n"
  cryptsetup luksFormat ${PARTITION_PATH}
  sleep 1
  printf "\nOPENING THE NEW LUKS DRIVE ...\n"
  cryptsetup open --type luks ${PARTITION_PATH} ${LVM_NAME}
  sleep 1
}


## Create the physical volume :
create_physical_volume () {
  printf "\nSTARTING TO CREATE THE PHYSICAL VOLUME ...\n"
  pvcreate /dev/mapper/${LVM_NAME}
  sleep 1
}


## Create the volume group :
create_volume_group () {
  printf "\nSTARTING TO CREATE THE VOLUME GROUP ...\n"
  vgcreate ${VOLUME_GROUP_NAME} /dev/mapper/${LVM_NAME}
  sleep 1
}


## Create the logical volume on the volume group :
creat_logical_volume () {
  printf "\nSTARTING TO CREATE THE LOGICAL VOLUME ...\n"
  lvcreate -l +100%FREE ${VOLUME_GROUP_NAME} -n ${LOGICAL_VOLUME_GROUP_NAME}
  sleep 1
}


## Format your filesystems on each logical volume :
format_inside_ecrypted_volume () {
  printf "\nFORMATTING THE LOGICAL VOLUME WITH EXT4 ...\n"
  mkfs.ext4 /dev/mapper/${VOLUME_GROUP_NAME}-${LOGICAL_VOLUME_GROUP_NAME}
  sleep 1
}


## Mount your filesystems :
mount_encrypted_vollume () {
  mkdir -p ${MOUNT_POINT}
  printf "\nSTARTING TO MOUNT ${LOGICAL_VOLUME_GROUP_NAME} UNDER ${MOUNT_POINT} ...\n"
  mount /dev/${VOLUME_GROUP_NAME}/${LOGICAL_VOLUME_GROUP_NAME} ${MOUNT_POINT}
}


## Create an open and close script for the ecnrpted volume's name 
create_open_close_script () {
  OPEN_CLOSE_SCRIPT="${HOME}/${NAME}_encrypted_storeage_open_close.sh"
  cp .encrypted_storeage_open_close_template.sh ${OPEN_CLOSE_SCRIPT}
  sed -i "s/## CHANGE THIS!!//g" ${OPEN_CLOSE_SCRIPT}
  sed -i "s/put_the_name_of_your_lukscrypt_here/${NAME}/g" ${OPEN_CLOSE_SCRIPT}
  chmod +x ${OPEN_CLOSE_SCRIPT}
  printf "\nThe script to open and close your new LUKS volume is ${OPEN_CLOSE_SCRIPT}\n"
}


print_help () {
  printf "
\nJust run this with no arguments and it wil prompt you for input.\n
Also, this script will use that last drive plugged into the computer and the last partition of that drive as the LUKS destination.\nEnjoy!\n\n"
}


## DO THIS:
if [[ "$1" = "-h" || "$1" = "--help" ]]; then
  print_help
  exit 0
fi
take_input || exit 1
partition_drive || exit 1
create_luks_container || exit 1
create_physical_volume || exit 1
create_volume_group || exit 1
creat_logical_volume || exit 1
format_inside_ecrypted_volume || exit 1
mount_encrypted_vollume || exit 1
create_open_close_script || exit 1


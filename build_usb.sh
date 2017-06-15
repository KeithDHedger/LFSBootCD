#! /bin/sh

# see if we are asked to do a "light" build
# in this case the stick is already bootable and has the 
# right kernel and all, we are just replacing the root system 
# tarball
LIGHT=
[ "$1" = "LIGHT" ] && LIGHT=1

if [ -z "$TOPDIR" ] ; then
  echo "you must define TOPDIR"
  exit 1
fi

if [ -z "$USBDEV" ] ; then
  echo "you must define USBDEV, for example: export USBDEV=/dev/sdb"
  echo "**** be very careful to chose the right device ****"
  echo "We assume that partition 1 is the partition to use."
  exit 1
fi

source $TOPDIR/settings.sh


# this makes a full device name, such as /dev/sdb1
USBPARTITION="${USBDEV}${USBPARTITIONNUMBER}"

if ! e2fsck $USBPARTITION ; then

    echo "$USBPARTITION does not seem to be formatted properly"
    echo "if this is the right partion, execute mkfs -t ext2 $USBPARTITION"
    exit 1
fi



# now do some surgery of the later /etc/fstab file to add a mount entry
# for the usb stick. We first save the original fstab

cp $TOPDIR/root_tree64/etc/fstab $TOPDIR/fstab_save

# and we get the UUID and generate an entry in the fstab 
BLKID=$(blkid -o export $USBPARTITION | head -1)
echo "$BLKID   /usbstick     auto noauto,ro  0 0" >> $TOPDIR/root_tree32/etc/fstab
echo "$BLKID   /usbstick     auto noauto,ro  0 0" >> $TOPDIR/root_tree64/etc/fstab


# and we make a file which tells us later that we were booted through USB
touch $TOPDIR/root_tree32/var/state/usb-booted
touch $TOPDIR/root_tree64/var/state/usb-booted
sync

sleep 3

#the we build the rootdisk image, and add it to the initial ramdisk 
$TOPDIR/build_diskimage.sh


# and we delete the files again
rm -f $TOPDIR/root_tree32/var/state/usb-booted
rm -f $TOPDIR/root_tree64/var/state/usb-booted


# and we put back the original fstab file 
cp $TOPDIR/fstab_save  $TOPDIR/root_tree32/etc/fstab
cp $TOPDIR/fstab_save  $TOPDIR/root_tree64/etc/fstab

mount $USBPARTITION $TOPDIR/usbstick

if [ -n "$LIGHT" ] ; then
    cp $TOPDIR/cdtree/isolinux/sdisk32.img $TOPDIR/usbstick/boot/
    cp $TOPDIR/cdtree/isolinux/sdisk64.img $TOPDIR/usbstick/boot/
    echo "Almost done, patience...  "
    umount $TOPDIR/usbstick
    echo "done with light build"
    exit 0
fi

# now the meat of the procedure


if [ -d $TOPDIR/usbstick/boot ] ; then
    # the installation sets the immutable bit on this file
    chattr -i $TOPDIR/usbstick/boot/ldlinux.sys
    chmod 644 $TOPDIR/usbstick/boot/ldlinux.sys
    rm -rf $TOPDIR/usbstick/boot
fi

mkdir $TOPDIR/usbstick/boot

cp $TOPDIR/cdtree/isolinux/boot.msg $TOPDIR/usbstick/boot/
cp $TOPDIR/cdtree/isolinux/sdisk32.img  $TOPDIR/usbstick/boot/
cp $TOPDIR/cdtree/isolinux/sdisk64.img  $TOPDIR/usbstick/boot/
cp $TOPDIR/cdtree/isolinux/isolinux.cfg $TOPDIR/usbstick/boot/syslinux.cfg
cp $TOPDIR/cdtree/isolinux/vm32 $TOPDIR/usbstick/boot/
cp $TOPDIR/cdtree/isolinux/vm64 $TOPDIR/usbstick/boot/
dd if=$TOPDIR/syslinux/mbr.bin of=$USBDEV
extlinux --install $TOPDIR/usbstick/boot/

sleep 2
echo "Almost done, patience...  "
umount $TOPDIR/usbstick

echo "done"

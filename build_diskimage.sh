#! /bin/sh 

if [ -z "$TOPDIR" ] ; then
  echo "you must define TOPDIR"
  exit
fi

WHAT="$1"

if [ -z "$WHAT" ] ; then

    echo "building 32 and 64 bit images" 
    WHAT="32 64"
fi

. $TOPDIR/settings.sh




# in case the loop device doesn't exist, we try to load the module
if ! [ -b $LOOP ] ; then
    modprobe loop 
    sleep 5
fi


# if it still doesn't exist, we stop here before we cause damage
if ! [ -b $LOOP ] ; then
    echo "$LOOP doesn't seem to exist - please check!"
    exit 1
fi


oldpwd=`pwd`

for version in $WHAT; do 

echo -n "Creating the $version bit system Ramdisk image.... "

IMAGE=$TOPDIR/cdtree/isolinux/sdisk${version}.img 

echo "Initial Ramdisk contents will be $ISIZE KB"

# delete the existing ramdisk image, if there is one
rm -f $IMAGE


REALSIZE=$ISIZE


# create a file of REALSIZE 
dd if=/dev/zero of=$TOPDIR/sdisk bs=1k count=$REALSIZE

# associate it with ${LOOP}
losetup ${LOOP} $TOPDIR/sdisk

# make an ext2 filesystem on it. We set the amount of unused space to 0%
# and turn down the number of inodes to save space. Note that we
# use the 4KB smaller ISIZE, for reiserfs compatibility.
mke2fs -q -i 16384 -m 0 ${LOOP} $ISIZE

# make sure we have $TOPDIR/loop2
[ -d  $TOPDIR/loop2 ] || mkdir  $TOPDIR/loop2 

# we mount it...
mount ${LOOP} $TOPDIR/loop2 

# ... and delete the lost+found directory 
rm -rf $TOPDIR/loop2/lost+found 

# then we copy the contents of our initrdtree to this filesystem
pushd $TOPDIR/loop2/
	tar -xvpf $TOPDIR/root_tree${version}.tar.xz
	cp $TOPDIR/hostkeys/* etc/ssh
	cp -rp $TOPDIR/xtras{version}/* .
popd

df  $TOPDIR/loop2

# and unmount and divorce ${LOOP}
umount $TOPDIR/loop2
losetup -d ${LOOP} 

# Now we have the image of the initial ramdisk in $TOPDIR/loopfiles/ramdisk. We
# compress this one and write the compressed image to the boot tree:

echo -n "Compressing the $version bit System Ramdisk image.... "

# delete any existing one
rm -f $IMAGE

# and gzip our initial ramdisk image and put it in the right place.
#gzip -9 -c $TOPDIR/sdisk > $IMAGE
bzip2 -c $TOPDIR/sdisk > $IMAGE

echo

rm -f $TOPDIR/sdisk

done

echo "done"

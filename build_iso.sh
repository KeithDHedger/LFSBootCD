#! /bin/sh 

if [ -z $TOPDIR ] ; then
  echo "you must define TOPDIR"
  exit
fi

oldpwd=`pwd`
# go to the top directory of the future CD
cd $TOPDIR/cdtree

#first we need to get rid of editor save files
find $TOPDIR/cdtree -name "*~" -exec rm -f {} \;

# and create the CD image
# you can fill in the info below as follows if you like
# -p "preparer id" - that's your email, for example
# -P "publisher_id" - again you
# -A "Application_id"

echo -n "Creating the CD iso image, $TOPDIR/$BOOTCDNAME ... "
echo
mkisofs -b isolinux/isolinux.bin -c isolinux/boot.cat \
               -o $TOPDIR/$BOOTCDNAME \
               -no-emul-boot -boot-load-size 4 -boot-info-table \
               -J -r -T \
               -p "keithhedger@keithhedger.darktech.org" \
               -A "LFS CD Build System" \
	       .

echo "done"

# go back where we came from
cd $oldpwd

# now we can burn this image to a cd. 


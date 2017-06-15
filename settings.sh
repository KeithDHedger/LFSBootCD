# global configuration and default settings

# which loop device do we use?
LOOP=/dev/loop2

# this is the size, in KB. of the initial ramdisk
# we make. You CANNOT increase this value without
# also changing the kernels (both 32bit and 64bit) 
# to provide ramdisks of at least  that size.  
ISIZE="200000"

# This is the partition number if we build a bootable
# USB stick. Most of them have a partition 1, which we 
# will use.
USBPARTITIONNUMBER=1


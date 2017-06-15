Build a new CD:

You MAY need the git lfs plugin avaialable here:
https://git-lfs.github.com/

All commands marked with * MUST be run as root to preserve permissions ( don't type the *! ).

*make clean

OR to remove the ssh keys folder
*make distclean

Grab external sources etc, this may take some time if you have a slow connection approx download 825M, this includes all the sources to build a functioning LFS system
make SOURCES

*make CD

If removing the hostkeys folder you will have to unpack the root_tree* tarball(s) copy the keys as instructed by make and re-tar the root_tree* folder(s), this will probably change soon.

The bootable iso is bootcd.iso, either use as is for a VM or burn to a DVD r/w ( slightly too big for a cdrom )

See the file "Roll your own Linux Rescue or Setup CD.html" for more details ( original creator ), or online https://www.phenix.bnl.gov/~purschke/RescueCD/


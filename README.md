Build a new CD:

You MAY need the git lfs plugin available here:
https://git-lfs.github.com/

All commands marked with * MUST be run as root to preserve permissions ( don't type the *! ).
Remove source archives as well.
*make clean

This doesn't remove source files/archives.
* make nearlyclean

OR to remove the ssh keys folder
*make distclean

Grab external sources etc, this may take some time if you have a slow connection approx download 1G+, this includes all the sources to build a functioning LFS system
make SOURCES

*make CD

If removing the hostkeys folder you will have to unpack the root_tree* tarball(s) copy the keys as instructed by make and re-tar the root_tree* folder(s), this will probably change soon.

The bootable iso is LFSBootCD-$(VERSION).iso, either use as is for a VM or burn to a DVD r/w ( slightly too big for a cdrom )

See the file "Roll your own Linux Rescue or Setup CD.html" for more details ( original creator ), or online https://www.phenix.bnl.gov/~purschke/RescueCD/

ADDITIONS:
A small static cli text editor is available on the ROM here:
/sbin/kilo
The gpm server is also included and started at boot time.

A pre-built iso is available here:

https://github.com/KeithDHedger/LFSBootCD/releases/download/9.0/LFSBootCDPart00
https://github.com/KeithDHedger/LFSBootCD/releases/download/9.0/LFSBootCDPart01

You must download all parts and then join them together like so:

cat "LFSBootCDPart00" "LFSBootCDPart01" "LFSBootCDPart02" > LFSBootCd.iso

OLD VERSION:
https://www.dropbox.com/s/7o09ayfg9pc3pyo/LFSBootCD-8.2.iso

This uses the ssh public keys in the pulblickeys folder.
This will need to be burnt to a dvd writable if you mean to use a physical disk as it's slightly too large for a cdrom.

BUGS etc.
keithdhedger@gmail.com

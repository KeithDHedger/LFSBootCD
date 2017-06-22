
TOPDIR=$(shell pwd)
ISODEPS=$(shell find  $(TOPDIR)/cdtree -not -name "\.*")
VERSION=8.0
BOOTCDNAME=bootcd-$(VERSION).iso

export TOPDIR BOOTCDNAME

#TESTFOLDER=$(shell find  $(TOPDIR) -iname "testdirexist" )

.PHONY: PACKAGE SOURCES CD USB USBLIGHT KEYS clean distclean 
#TEST TESTFOLDER

#TEST: $(TESTFOLDER)
#	$(TOPDIR)/build_iso.sh

PACKAGE:
	tar -cvaf $(TOPDIR)/bootcd-$(VERSION).tar.xz $(TOPDIR)/$(BOOTCDNAME) $(TOPDIR)/publickeys

CD: $(TOPDIR)/$(BOOTCDNAME)

USB: 
	$(TOPDIR)/build_usb.sh 

USBLIGHT: 
	$(TOPDIR)/build_usb.sh LIGHT

SOURCES:
	$(TOPDIR)/getSources

$(TOPDIR)/$(BOOTCDNAME): SOURCES KEYS $(ISODEPS) $(TOPDIR)/build_iso.sh $(TOPDIR)/Makefile  $(TOPDIR)/cdtree/isolinux/*.msg $(TOPDIR)/cdtree/isolinux/sdisk32.img $(TOPDIR)/cdtree/isolinux/sdisk64.img
	$(TOPDIR)/getSources
	$(TOPDIR)/build_iso.sh

$(TOPDIR)/cdtree/isolinux/sdisk32.img:  $(TOPDIR)/build_diskimage.sh $(TOPDIR)/Makefile 
	$(TOPDIR)/build_diskimage.sh 32

$(TOPDIR)/cdtree/isolinux/sdisk64.img:  $(TOPDIR)/build_diskimage.sh $(TOPDIR)/Makefile 
	$(TOPDIR)/build_diskimage.sh 64

KEYS: $(TOPDIR)/hostkeys/ssh_host_dsa_key  $(TOPDIR)/hostkeys/ssh_host_dsa_key.pub $(TOPDIR)/hostkeys/ssh_host_rsa_key  $(TOPDIR)/hostkeys/ssh_host_rsa_key.pub

$(TOPDIR)/hostkeys/ssh_host_dsa_key:
$(TOPDIR)/hostkeys/ssh_host_dsa_key.pub: 
$(TOPDIR)/hostkeys/ssh_host_rsa_key:
$(TOPDIR)/hostkeys/ssh_host_rsa_key.pub:
	$(TOPDIR)/generate_hostkeys.sh
	cp $(TOPDIR)/hostkeys/*.pub publickeys
	
clean:
	rm -f $(TOPDIR)/$(BOOTCDNAME) $(TOPDIR)/cdtree/isolinux/sdisk32.img  $(TOPDIR)/cdtree/isolinux/sdisk64.img
	rm -rf $(TOPDIR)/loop2

distclean:
	rm -f $(TOPDIR)/$(BOOTCDNAME) $(TOPDIR)/cdtree/isolinux/sdisk32.img  $(TOPDIR)/cdtree/isolinux/sdisk64.img $(TOPDIR)/tftp_area.tar.gz||true
	rm -rf $(TOPDIR)/hostkeys||true
	rm $(TOPDIR)/*~ ||true
	rm -rf $(TOPDIR)/cdtree/LFS/LFSSourceArchives||true
	rm $(TOPDIR)/cdtree/LFS/tools-8.0_32.tar.bz2 $(TOPDIR)/cdtree/LFS/tools-8.0_64.tar.bz2 $(TOPDIR)/root_tree32.tar.xz $(TOPDIR)/root_tree64.tar.xz||true
	rm $(TOPDIR)/bootcd-$(VERSION).tar.xz||true


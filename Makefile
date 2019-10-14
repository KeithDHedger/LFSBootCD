
VERSION=9.0
TOPDIR=$(shell pwd)
ISODEPS=$(shell find  $(TOPDIR)/cdtree -not -name "\.*")
BOOTCDNAME=LFSBootCD-$(VERSION).iso

export TOPDIR BOOTCDNAME

#TESTFOLDER=$(shell find  $(TOPDIR) -iname "testdirexist" )

.PHONY: PACKAGE SOURCES CD USB USBLIGHT KEYS clean distclean 
#TEST TESTFOLDER

#TEST: $(TESTFOLDER)
#	$(TOPDIR)/build_iso.sh

PACKAGE:
	tar -cvaf $(TOPDIR)/bootcd.tar.xz $(TOPDIR)/$(BOOTCDNAME) $(TOPDIR)/publickeys

CD: $(TOPDIR)/$(BOOTCDNAME)

USB: 
	$(TOPDIR)/build_usb.sh 

USBLIGHT: 
	$(TOPDIR)/build_usb.sh LIGHT

SOURCES:
	$(TOPDIR)/getSources

$(TOPDIR)/$(BOOTCDNAME): KEYS $(ISODEPS) $(TOPDIR)/build_iso.sh $(TOPDIR)/Makefile  $(TOPDIR)/cdtree/isolinux/*.msg $(TOPDIR)/cdtree/isolinux/sdisk32.img $(TOPDIR)/cdtree/isolinux/sdisk64.img
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
	rm -rf $(TOPDIR)/cdtree/LFS/*
	rm -f $(TOPDIR)/$(BOOTCDNAME) $(TOPDIR)/cdtree/isolinux/sdisk32.img  $(TOPDIR)/cdtree/isolinux/sdisk64.img
	rm -rf $(TOPDIR)/loop2
	rm -f $(TOPDIR)/wget-list*
	rm -f $(TOPDIR)/gotpkgbuilds

distclean:
	rm -f $(TOPDIR)/$(BOOTCDNAME) $(TOPDIR)/cdtree/isolinux/sdisk32.img  $(TOPDIR)/cdtree/isolinux/sdisk64.img $(TOPDIR)/tftp_area.tar.gz||true
	rm -rf $(TOPDIR)/hostkeys||true
	rm $(TOPDIR)/*~ ||true
	rm -rf $(TOPDIR)/cdtree/LFS/*||true
	rm $(TOPDIR)/root_tree32.tar.xz $(TOPDIR)/root_tree64.tar.xz||true
	rm $(TOPDIR)/bootcd.tar.xz||true

nearlyclean:
	rm -f $(TOPDIR)/$(BOOTCDNAME) $(TOPDIR)/cdtree/isolinux/sdisk32.img  $(TOPDIR)/cdtree/isolinux/sdisk64.img
	rm -rf $(TOPDIR)/cdtree/LFS/LFSPkgBuilds
	rm -rf $(TOPDIR)/cdtree/LFS/gotpkgbuilds






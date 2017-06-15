TOPDIR=$(shell pwd)
ISODEPS=$(shell find  $(TOPDIR)/cdtree -not -name "\.*" )
export TOPDIR

.PHONY: SOURCES CD USB USBLIGHT KEYS clean distclean

CD: $(TOPDIR)/bootcd.iso


USB: 
	$(TOPDIR)/build_usb.sh 

USBLIGHT: 
	$(TOPDIR)/build_usb.sh LIGHT

SOURCES:
	$(TOPDIR)/getSources

$(TOPDIR)/bootcd.iso: SOURCES KEYS $(ISODEPS) $(TOPDIR)/build_iso.sh $(TOPDIR)/Makefile  $(TOPDIR)/cdtree/isolinux/*.msg $(TOPDIR)/cdtree/isolinux/sdisk32.img $(TOPDIR)/cdtree/isolinux/sdisk64.img
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

clean:
	rm -f $(TOPDIR)/bootcd.iso $(TOPDIR)/cdtree/isolinux/sdisk32.img  $(TOPDIR)/cdtree/isolinux/sdisk64.img $(TOPDIR)/tftp_area.tar.gz

distclean:
	rm -f $(TOPDIR)/bootcd.iso $(TOPDIR)/cdtree/isolinux/sdisk32.img  $(TOPDIR)/cdtree/isolinux/sdisk64.img $(TOPDIR)/tftp_area.tar.gz||true
	rm -rf $(TOPDIR)/hostkeys||true
	rm $(TOPDIR)/*~ ||true
	rm -rf $(TOPDIR)/publickeys/*||true
	rm -rf $(TOPDIR)/cdtree/LFS/LFSSourceArchives||true
	rm $(TOPDIR)/cdtree/LFS/tools32.tar.xz $(TOPDIR)/cdtree/LFS/tools64.tar.xz $(TOPDIR)/root_tree32.tar.xz $(TOPDIR)/root_tree64.tar.xz||true





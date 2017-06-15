
PREFIX="/usr"
DESTDIR=
PKGNAME="LFSPkg"
PROGRAM="lfspkg"
HELPER="finddepends"
HELPERCODE="main.cpp"
FUNCTIONS="LFSFunctions"
MANPAGE="${PROGRAM}.1"
RCFILE="lfspkg.rc"

all:
	g++ -o $(HELPER) $(HELPERCODE)

clean:
	rm $(HELPER)||true

install:
	mkdir -vp $(DESTDIR)$(PREFIX)/bin $(DESTDIR)$(PREFIX)/share/$(PKGNAME) $(DESTDIR)/etc $(DESTDIR)$(PREFIX)/share/man/man1||true
	g++ -o $(HELPER) $(HELPERCODE)
	cp $(HELPER) $(PROGRAM) $(DESTDIR)$(PREFIX)/bin
	cp $(MANPAGE) $(DESTDIR)$(PREFIX)/share/man/man1
	cp $(RCFILE) $(DESTDIR)/etc
	cp $(FUNCTIONS) $(DESTDIR)$(PREFIX)/share/$(PKGNAME)

	@echo "**************************************************************"
	@echo "Now set your package options in the file /etc/lfspkg.rc"
	@echo "Or create the file ' ~/.lfspkg.rc' which will be sourced after '/etc/lfspkg.rc'"
	@echo
	@echo "See the manpage for details, but you should set at least:"
	@echo "OUTPUT and SOURCEARCHIVES"
	@echo
	@echo "You should also download the buildscripts from here:"
	@echo "https://github.com/KeithDHedger/LFSPkgBuilds"
	@echo "Place LFSPkgBuildScripts and LFSScripts in / ."
	@echo "If you place them elsewhere set BUILDSCRIPTS in /etc/lfspkg.rc"
	@echo
	@echo "After downloading the build scripts build the database like so:"
	@echo "SIMPLEUPDATE=1 lfspkg -U"
	@echo
	@echo "**************************************************************"

uninstall:
	rm $(DESTDIR)$(PREFIX)/bin/$(HELPER)
	rm $(DESTDIR)$(PREFIX)/bin/$(PROGRAM)
	rm $(DESTDIR)$(PREFIX)/share/man/man1/$(MANPAGE)
	rm -r $(DESTDIR)$(PREFIX)/share/$(PKGNAME)

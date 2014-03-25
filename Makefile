TMP        ?= /tmp
DIST_PREFIX = ${TMP}
BASE        = templer
VERSION     = $(shell sh -c 'git describe --abbrev=0 --tags | tr -d "release-"')

#
# Default action is to build the two binary scripts
#
default: templer templer-generate


#
# Clean temporary/working files
#
clean:
	-@find . \( -name '*.bak' -o -name '*.log' -o -name '*~' \) -delete
	-@test -e ./debian/files && rm -f ./debian/files || true
	-@test -d ./debian/templer && rm -rf ./debian/templer || true
	-@test -d ./examples/simple/output && rm -rf ./examples/simple/output/ || true
	-@test -d ./examples/simple/output && rm -rf ./examples/simple/output/ || true
	-@test -d ./examples/symlinks/output && rm -rf ./examples/simple/output/ || true
	-@test -d ./examples/complex/output && rm -rf ./examples/complex/output/ || true
	-@test -d ./output && rm -rf ./output/ || true
	-@test -e ./templer && rm -f templer || true
	-@test -e ./templer-generate && rm -f templer-generate || true
	-@cd examples && make clean


#
# Run perlcritic against our code
#
critic:
	perlcritic $$(find . -name '*.pm' -o -name '*.in' ) t/*.t



#
# Install to /usr/local/bin
#
install: default
	cp ./templer ./templer-generate /usr/local/bin
	chown root.root /usr/local/bin/templer /usr/local/bin/templer-generate
	chmod 755 /usr/local/bin/templer /usr/local/bin/templer-generate


release: tidy clean
	echo "Release is $(VERSION)"
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)
	rm -f $(DIST_PREFIX)/$(BASE)-$(VERSION).tar.gz
	cp -R . $(DIST_PREFIX)/$(BASE)-$(VERSION)
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)/debian
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)/.git*
	cd $(DIST_PREFIX) && tar -cvf $(DIST_PREFIX)/$(BASE)-$(VERSION).tar $(BASE)-$(VERSION)/
	gzip $(DIST_PREFIX)/$(BASE)-$(VERSION).tar
	mv $(DIST_PREFIX)/$(BASE)-$(VERSION).tar.gz .
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)

#
# Make the main script
#
templer: build-templer
	perl build-templer
	chmod +x templer



#
#  Make the generator script
#
templer-generate: templer-generate.in lib/Templer/Site/New.pm
	cat templer-generate.in lib/Templer/Site/New.pm > templer-generate
	chmod +x templer-generate


#
# Format the code in a standard fashion.
#
tidy:
	perltidy *.in
	perltidy $$(find . -name '*.pm' -print)
	perltidy t/*.t


#
# Run the test suite.
#
test:
	prove t/


#
# Uninstall
#
uninstall:
	rm /usr/local/bin/templer          || true
	rm /usr/local/bin/templer-generate || true

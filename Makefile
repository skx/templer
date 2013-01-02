

clean:
	-@find . \( -name '*.bak' -o -name '*.log' -o -name '*~' \) -delete
	-@test -e ./debian/files && rm -f ./debian/files || true
	-@test -d ./debian/templer && rm -rf ./debian/templer || true
	-@test -d ./examples/simple/output && rm -rf ./examples/simple/output/ || true
	-@test -d ./examples/simple/output && rm -rf ./examples/simple/output/ || true
	-@test -d ./examples/symlinks/output && rm -rf ./examples/simple/output/ || true
	-@test -d ./examples/complex/output && rm -rf ./examples/complex/output/ || true
	-@test -d ./output && rm -rf ./output/ || true

critic:
	perlcritic ./templer
	perlcritic ./templer-generate

install:
	cp ./templer ./templer-generate /usr/local/bin
	chown root.root /usr/local/bin/templer /usr/local/bin/templer-generate
	chmod 755 /usr/local/bin/templer /usr/local/bin/templer-generate

tidy:
	perltidy ./templer
	perltidy ./templer-generate

test:
	prove --shuffle t/


uninstall:
	rm /usr/local/bin/templer          || true
	rm /usr/local/bin/templer-generate || true


examples: clean
	cd ./examples/simple/   ; ../../templer --force
	cd ./examples/complex/  ; ../../templer --force
	cd ./examples/symlinks/ ; ../../templer --force
	rsync -qazr -e "ssh -C" ./examples/ s-steve@steve.org.uk:htdocs/Software/templer/examples/

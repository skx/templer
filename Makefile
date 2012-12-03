

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

tidy:
	perltidy ./templer



examples: clean
	cd ./examples/simple/   ; ../../templer --force
	cd ./examples/complex/  ; ../../templer --force
	cd ./examples/symlinks/ ; ../../templer --force
	rsync -vazr -e "ssh -C" ./examples/ s-steve@steve.org.uk:htdocs/Software/templer/examples/



clean:
	-@find . \( -name '*.bak' -o -name '*~' \) -delete
	-@test -d ./examples/simple/output && rm -rf ./examples/simple/output/ || true
	-@test -d ./examples/complex/output && rm -rf ./examples/complex/output/ || true
	-@test -d ./output && rm -rf ./output/ || true

critic:
	perlcritic ./templer

tidy:
	perltidy ./templer



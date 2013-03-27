
default:
		@echo "make clean   - Clean all examples"
		@echo "make rebuild - Build all examples"

clean:
		rm */output -rf

rebuild:
		for i in */; do cd $$i ; ../../templer ; cd .. ; done


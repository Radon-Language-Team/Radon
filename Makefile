all: build

build:
	@echo "Building..."
	@v run build.vsh

clean:
	@echo "Cleaning up..."
	@rm radon/radon
	@rm -rf radon
	@echo "Done"
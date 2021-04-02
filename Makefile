NAME=packer
VERSION=1.7.1
REVISION=1
PACKER_VERSION=$(VERSION)
MAINT=james.earl.3@gmail.com
DESCRIPTION="See https://www.packer.io"

DEB=$(NAME)_$(VERSION)
DEB_64=$(DEB)_amd64.deb

SRC_64=https://releases.hashicorp.com/packer/$(PACKER_VERSION)/packer_$(PACKER_VERSION)_linux_amd64.zip

.PHONY: dev build publish-gemfury ls uninstall install clean

dev: clean build

build: dist/$(DEB_64)

publish-gemfury:
	fury push dist/$(DEB_64) --public

ls:
	gemfury versions "$(NAME)"

bin/:
	mkdir -p ./bin

dist/:
	mkdir -p ./dist

bin/packer_$(VERSION)_linux_amd64: bin/
	wget -nc -nv -O - $(SRC_64) | gunzip >bin/packer_$(VERSION)_linux_amd64
	chmod +x bin/packer_$(VERSION)_linux_amd64

dist/$(DEB_64): dist/ bin/packer_$(VERSION)_linux_amd64
	fpm -s dir \
		-t deb \
		-p dist/$(DEB_64) \
		-n $(NAME) \
		--provides $(NAME) \
		-v $(VERSION) \
		-a amd64 \
		-m $(MAINT) \
		--deb-no-default-config-files \
		bin/packer_$(VERSION)_linux_amd64=/usr/bin/packer

clean:
	rm -rf dist/*

uninstall:
	sudo apt remove -y $(NAME) || true

install:
	sudo apt install -y --reinstall --allow-downgrades ./dist/$(DEB_64)

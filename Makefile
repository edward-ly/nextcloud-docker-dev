SHELL := /bin/bash

.PHONY: images docker-build pull-all

.ONESHELL:
images: docker/*/Dockerfile docker/Dockerfile.*

.ONESHELL:
pull-all:
	for file in $$(find docker/ -maxdepth 1 -type f -iname 'Dockerfile.*'); do \
		NAME=$$(echo $$file | sed 's/^.*\.//'); \
		echo "=> Pulling image $$NAME"; docker pull "ghcr.io/juliushaertl/nextcloud-dev-$${NAME}"; \
	done
	for file in $$(find docker -maxdepth 2 -type f -iname 'Dockerfile'); do \
		NAME=$$(basename $$(dirname $$file)); \
		echo "=> Pulling image $$NAME"; docker pull "ghcr.io/juliushaertl/nextcloud-dev-$${NAME}"; \
	done

pull-installed:
	docker image ls | grep juliushaertl/nextcloud-dev | cut -f 1 -d " "
	docker image ls | grep juliushaertl/nextcloud-dev | cut -f 1 -d " " | xargs -L 1 docker pull

# Empty target to always build
docker-build:

docker/%/Dockerfile: docker-build
	NAME=$$(basename $$(dirname $@)); \
	echo "=> Building dockerfile" $@ as ghcr.io/juliushaertl/nextcloud-dev-$$NAME:latest; \
	(cd docker && docker build -t ghcr.io/juliushaertl/nextcloud-dev-$$NAME:latest -f $$NAME/Dockerfile .)

docker/Dockerfile.%: docker-build
	NAME=$$(echo $$(basename $@) | sed 's/^.*\.//'); \
	echo "=> Building dockerfile" $@ as ghcr.io/juliushaertl/nextcloud-dev-$$NAME:latest; \
	(cd docker && docker build -t ghcr.io/juliushaertl/nextcloud-dev-$$NAME:latest -f Dockerfile.$$NAME .)

check: dockerfilelint shellcheck

.ONESHELL:
dockerfilelint:
	for file in $$(find docker/ -type f -iname 'Dockerfile.*' -maxdepth 1); do dockerfilelint $$file; done;
	for file in $$(find docker -type f -iname 'Dockerfile' -maxdepth 2); do dockerfilelint $$file; done;

.ONESHELL:
shellcheck:
	for file in $$(find . -type f -iname '*.sh' -not -path './wip/*'); do shellcheck --format=gcc $$file; done;
	for file in $$(find ./scripts -type f); do shellcheck --format=gcc $$file; done;

.ONESHELL:
template-apply:
	cat docker/Dockerfile.php.template | sed 's/php:8.1/php:7.1/' | sed 's/pecl install xdebug/pecl install xdebug-2.9.8/' > docker/Dockerfile.php71
	cat docker/Dockerfile.php.template | sed 's/php:8.1/php:7.2/' | sed 's/pecl install xdebug/pecl install xdebug-3.1.6/' > docker/Dockerfile.php72
	cat docker/Dockerfile.php.template | sed 's/php:8.1/php:7.3/' | sed 's/pecl install xdebug/pecl install xdebug-3.1.6/' > docker/Dockerfile.php73
	cat docker/Dockerfile.php.template | sed 's/php:8.1/php:7.4/' | sed 's/pecl install xdebug/pecl install xdebug-3.1.6/' > docker/Dockerfile.php74
	cat docker/Dockerfile.php.template | sed 's/php:8.1/php:8.0/' > docker/Dockerfile.php80
	cat docker/Dockerfile.php.template | sed 's/php:8.1/php:8.1/' > docker/Dockerfile.php81
	cat docker/Dockerfile.php.template | sed 's/php:8.1/php:8.2/' > docker/php82/Dockerfile

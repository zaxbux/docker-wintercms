#Dockerfile vars
phpver=7.4

#vars
IMAGENAME=zaxbux/wintercms
REPO=docker.io
IMAGEFULLNAME=${REPO}/${IMAGENAME}

.PHONY: help build push all

help:
		@echo "Makefile arguments:"
		@echo ""
		@echo "phpver - PHP Version"
		@echo ""
		@echo "Makefile commands:"
		@echo "build"
		@echo "push"
		@echo "all"

.DEFAULT_GOAL := all

build-fpm:
		@docker build --pull --build-arg PHP_VERSION=${phpver} -t ${IMAGEFULLNAME}:php${phpver}-fpm -f php${phpver}/fpm/Dockerfile .

build-fpm-alpine:
		@docker build --pull --build-arg PHP_VERSION=${phpver} -t ${IMAGEFULLNAME}:php${phpver}-fpm-alpine -f php${phpver}/fpm-alpine/Dockerfile .

push:
		@docker push ${IMAGEFULLNAME}

all: build push
SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -O globstar -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

default:
	make packages

clean:
	# remove anything in .gitignore, including directories
	git clean -fdX

package = natural-deduction
version = 1.6
release = 1
architecture = $(shell bash get-architecture.sh)
maintainer = Eric Johannesson <eric@ericjohannesson.com>
homepage = https://github.com/ericjohannesson/natural-deduction
description = A basic proof assistant for natural deduction in first-order logic
depends = libc6

directory = ${package}_${version}-${release}_${architecture}

define control
Package: ${package}
Version: ${version}
Maintainer: ${maintainer}
Depends: ${depends}
Architecture: ${architecture}
Homepage: ${homepage}
Description: ${description}
endef

${directory}/DEBIAN/control:
	mkdir -p ${directory}/DEBIAN
	echo "${control}" > ${directory}/DEBIAN/control

${directory}/usr/bin/natural-deduction: ../natural-deduction
	mkdir -p ${directory}/usr/bin
	cp ../natural-deduction ${directory}/usr/bin/natural-deduction


${directory}: ${directory}/DEBIAN/control ${directory}/usr/bin/natural-deduction

packages: ${directory}
	dpkg-deb --root-owner-group --build ${directory}
	mkdir -p packages
	mv *.deb packages/

#!/bin/bash

REPO=repo.txt
ARCH="i386 amd64"

BASE="data"
TAG="`date +%Y-%m-%d`"

grep -v '^\s*#' $REPO | while read group base code sections
do
	for section in $sections
	do
		dir="$group/$code/$section"
		for arch in $ARCH
		do
			mkdir -p $BASE/packages/$dir
			mkdir -p $BASE/files/$dir

			packages="$BASE/packages/$dir/Packages.$arch"
			files="$BASE/files/$dir/files.$arch"

			echo -n "[$group] $arch $code $section: " 1>&2

			url="$base/dists/$code/$section/binary-$arch/Packages.gz"
			wget -q -O - $url | gunzip -c > $packages

			echo -n "packages " 1>&2

			grep ^Filename: $packages | cut -d' ' -f 2 | sort -u > $files

			echo "files" 1>&2

		done
	done
done

pushd $BASE > /dev/null 2>&1
bzr init > /dev/null 2>&1
bzr add
bzr commit -m "$TAG"
bzr tag --delete "$TAG" > /dev/null 2>&1
bzr tag "$TAG"
popd > /dev/null 2>&1


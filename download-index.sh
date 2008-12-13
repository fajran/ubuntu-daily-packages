#!/bin/bash

REPO=repo.txt
ARCH=i386
DIR="index"
TAG=`date +%Y-%m-%d`

grep -v '^\s*#' $REPO | while read deb base code sections
do
	dir_base="$DIR/`echo $base | sed 's/[:\/]/_/g'`/$code"
	for section in $sections
	do
		dir="$dir_base/$section/"
		for arch in $ARCH
		do
			mkdir -p $dir
			target="$dir/Packages.$arch"

			url="$base/dists/$code/$section/binary-$arch/Packages.gz"
			wget -q -O - $url | gunzip -c > $target
		done
	done
done

pushd $DIR > /dev/null 2>&1
bzr init > /dev/null 2>&1
bzr add
bzr commit -m "$TAG"
bzr tag --delete "$TAG" > /dev/null 2>&1
bzr tag "$TAG"
popd > /dev/null 2>&1


#!/bin/bash

REPO=repo.txt
ARCH=i386
INDEX_DIR="index"
FILES_DIR="files"
TAG=`date +%Y-%m-%d`

grep -v '^\s*#' $REPO | while read deb base code sections
do
	dir_base="`echo $base | sed 's/[:\/]/_/g'`/$code"
	for section in $sections
	do
		dir="$dir_base/$section/"
		for arch in $ARCH
		do
			mkdir -p "$FILES_DIR/$dir"
			target="$FILES_DIR/$dir/files.$arch"
			packages="$INDEX_DIR/$dir/Packages.$arch"

			grep ^Filename: $packages | cut -d' ' -f 2 | sort -u | sort -n > $target		
		done
	done
done

pushd $FILES_DIR > /dev/null 2>&1
git init > /dev/null 2>&1
git add .
git commit -a -m "$TAG"
git tag -d "$TAG" > /dev/null 2>&1
git tag "$TAG"
popd > /dev/null 2>&1


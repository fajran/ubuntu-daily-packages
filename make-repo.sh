#!/bin/bash

GROUP=ubuntu
ARCHS=i386
DISTS=hardy-updates,hardy-security
SECTIONS=main,universe,multiverse,restricted

BASE=http://nl.archive.ubuntu.com/ubuntu/
WORKDIR=work
DATADIR=data

START=2008-12-24
END=2009-01-06


get_cut_dirs() {
	base=$1
	protocol="`echo $base | cut -d':' -f1`:"
	cnt=0
	
	str=$base
	while [ "$str" != "$protocol" ]; do
		str=`dirname $str`
		cnt=$(( cnt + 1 ))
	done
	
	cnt=$(( cnt - 1 ))
	echo $cnt
}

CD=`get_cut_dirs $BASE`


mkdir -p $WORKDIR
mkdir -p $WORKDIR/files
mkdir -p $WORKDIR/combined
mkdir -p $WORKDIR/download

if [ "${WORKDIR:0:1}" == "/" ]; then
	ABSWORKDIR=$WORKDIR
else
	ABSWORKDIR=`pwd`/$WORKDIR
fi

IFSORIG=$IFS
IFS=,

#
# Gather files
#

pushd $DATADIR > /dev/null 2>&1
for dist in $DISTS; do
	for section in $SECTIONS; do
		for arch in $ARCHS; do
			FILE=files/$GROUP/$dist/$section/files.$arch
			TARGET=$ABSWORKDIR/files/$GROUP.$dist.$section.$arch

			bzr diff -rtag:$START..tag:$END $FILE | grep ^+pool | cut -b2- > $TARGET
		done
	done
done
popd > /dev/null 2>&1

#
# Download files
#

pushd $WORKDIR/download > /dev/null 2>&1
for dist in $DISTS; do
	for section in $SECTIONS; do
		for arch in $ARCHS; do
			FILES=$ABSWORKDIR/files/$GROUP.$dist.$section.$arch
			[ -f files.txt ] && rm files.txt 

			cat $FILES | while read file; do
				if [ ! -f ../combined/$file ]; then
					echo $file >> files.txt
				else
					mkdir -p `dirname $file`
					cp ../combined/$file `dirname $file`
				fi
			done

			if [ -f files.txt ]; then

				wget -q -B $BASE -i files.txt -nH --cut-dirs $CD -r

				rm files.txt

				apt-ftparchive packages pool | tee Packages | gzip -9 -c > Packages.gz
				mkdir -p dists/$dist/$section/binary-$arch
				mv Packages Packages.gz dists/$dist/$section/binary-$arch
				rsync -a . ../combined/
				rm -rf dists

			fi

			[ -d pool ] && rm -rf pool

		done
	done
done
popd > /dev/null 2>&1

#
# Make ISO image
#

pushd $WORKDIR > /dev/null 2>&1
cd combined
ln -s . ubuntu
mkdir .disk
echo "Updates $END" > .disk/info
cd ..

mkisofs -r -J -V "Updates $END" -o updates-$END.iso combined

popd > /dev/null 2>&1


IFS=$IFSORIG



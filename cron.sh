#!/bin/sh

BINDIR=/Users/iang/project/ubuntu-daily-packages/dev/master
WORKDIR=/Users/iang/project/ubuntu-daily-packages/dev/master

pushd $WORKDIR > /dev/null 2>&1

$BINDIR/make-snapshot.sh

popd $WORKDIR > /dev/null 2>&1



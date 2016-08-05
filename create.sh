#!/bin/bash

BASEDIR=`pwd`

if [ -z "$1" -a -z "$2" ]; then
        echo "Usage: $0 <sourcefile> <tag>"
        exit 1
fi

DISTR=$1
tag=$2

TARGETDIR="$BASEDIR/tmp/${tag}-dir.iso"
SOURCEDIR="$BASEDIR/tmp/source.iso"
CONFDIR="$BASEDIR/conf/${tag}"
mkdir -p "$SOURCEDIR" "$TARGETDIR"

sudo mount -o loop "$DISTR" "$SOURCEDIR"
sudo rsync -av "$SOURCEDIR/" "$TARGETDIR"
sudo umount "$SOURCEDIR"

if [ -d "$CONFDIR" ]; then
        sudo rsync -av "$CONFDIR/" "$TARGETDIR"
fi

cd "$TARGETDIR"
md5sum `find  ! -name “md5sum.txt” ! -path “./isolinux/*” -follow -type f` > /tmp/md5sum.txt
sudo mv -f /tmp/md5sum.txt "$TARGETDIR/md5sum.txt"
sudo mkisofs -V "$tag" -force-rr -ucs-level 3 -cache-inodes -J -l -R -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o $BASEDIR/out/$tag.iso "$TARGETDIR"
if [ -n "$TARGETDIR" ]; then
        sudo rm -rf "$TARGETDIR"
fi


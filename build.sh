#!/bin/bash

set -uexo pipefail

CONFIG="$1"
DEVICE_TREE="$2"
HEADER_VERSION="${3:-}"

cd ..
make $CONFIG
make -j $(nproc)
gzip u-boot-nodtb.bin -c > u-boot-nodtb.bin.gz

if [ "$HEADER_VERSION" = "2" ]; then
    # Boot image v2 requires separate --dtb parameter
    MKBOOTIMG_ARGS="--kernel u-boot-nodtb.bin.gz --dtb dts/upstream/src/arm64/$DEVICE_TREE.dtb --pagesize 4096 --base 0x0 --kernel_offset 0x8000 --ramdisk_offset 0x1000000 --tags_offset 0x100 --dtb_offset 0x1f00000 --header_version 2 -o u-boot.img"
else
    # Legacy format: concatenate kernel and dtb
    cat u-boot-nodtb.bin.gz dts/upstream/src/arm64/$DEVICE_TREE.dtb > u-boot-dtb

    MKBOOTIMG_ARGS="--kernel u-boot-dtb --pagesize 4096 --base 0x0 --kernel_offset 0x8000 -o u-boot.img"
fi

mkbootimg $MKBOOTIMG_ARGS
mkdir -p builder/output/
cp u-boot.img builder/output/u-boot.img

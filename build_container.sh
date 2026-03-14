#!/bin/sh

podman run --rm -it -v..:/srv:z -w/srv fedora:43 bash -c \
  "
    dnf -y install bison flex android-tools make gcc glibc-devel openssl-devel openssl-devel-engine gnutls-devel awk xxd
    cd builder
    ./build.sh \"${1}\" \"${2}\" \"${3}\"
  "

#!/bin/sh

GIT_REPO="$1"

# Fix broken apline download links
echo "http://dl-4.alpinelinux.org/alpine/v3.7/main" >> /etc/apk/repositories

apk add build-base gcc abuild binutils cmake git

cd /root
git clone -q --depth 1 $GIT_REPO
cd vlmcsd
make

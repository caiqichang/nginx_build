#!/usr/bin/env bash
set -e

TARGET=$1
PREFIX=$2

export PATH="$PREFIX/bin:$PATH"

BINUTILS=binutils-2.42
GCC=gcc-14.2.0
MINGW=mingw-w64

echo "=== Building 64-bit MinGW UCRT toolchain for $TARGET ==="
echo "Prefix: $PREFIX"

mkdir -p $PREFIX

# -------------------------
# 1. Build binutils
# -------------------------
mkdir -p build-binutils
cd build-binutils

../$BINUTILS/configure \
  --target=$TARGET \
  --prefix=$PREFIX \
  --with-sysroot=$PREFIX \
  --disable-multilib

make -j$(nproc)
make install

cd ..

# -------------------------
# 2. Install MinGW-w64 headers (UCRT)
# -------------------------
cd $MINGW/mingw-w64-headers
./configure --host=$TARGET --prefix=$PREFIX --with-default-msvcrt=ucrt
make install
cd ../..

# -------------------------
# 3. Build GCC (stage 1)
# -------------------------
mkdir -p build-gcc
cd build-gcc

../$GCC/configure \
  --target=$TARGET \
  --prefix=$PREFIX \
  --enable-languages=c,c++ \
  --disable-multilib \
  --disable-nls

make all-gcc -j$(nproc)
make install-gcc

cd ..

# -------------------------
# 4. Build MinGW-w64 CRT (UCRT)
# -------------------------
cd $MINGW/mingw-w64-crt
./configure --host=$TARGET --prefix=$PREFIX --with-default-msvcrt=ucrt
make -j$(nproc)
make install
cd ../..

# -------------------------
# 5. Build GCC (final)
# -------------------------
cd build-gcc
make -j$(nproc)
make install
cd ..

echo "=== 64-bit UCRT Build complete ==="

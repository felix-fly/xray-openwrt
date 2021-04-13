#!/bin/bash

VERSION=latest

platform="$1"
all=",386,amd64,armv5,armv6,armv7,arm64,mips,mipsle,mips64,mips64le,ppc64,ppc64le,s390x,"
result=$(echo $all | grep ",${platform},")
if [[ "$result" != "" ]]
then
  echo "Your router platform: $platform"
else
  echo "Unknown platform: $platform"
  exit
fi

read -p "Enter the xray version(Default: $VERSION):" ver

version=${ver:-"$VERSION"}

float=""
if [[ $platform == "mips" || $platform == "mipsle" ]]
then
  read -r -p "Enable FPU support(soft-float)? [y/N] " input
  case $input in
    [yY][eE][sS]|[yY])
      echo "Yes"
      float="float"
      ;;
    *)
      echo "No"
      float=""
      ;;
  esac
fi

mkdir tmp
cp -r package/* tmp
cd tmp

if [[ $version == "latest" ]]
then
  wget https://github.com/felix-fly/xray-openwrt/releases/latest/download/xray-linux-$platform.tar.gz -O xray.tar.gz
else
  wget https://github.com/felix-fly/xray-openwrt/releases/download/v$version/xray-linux-$platform.tar.gz -O xray.tar.gz
fi

tar -xzvf xray.tar.gz
if [[ $float == "float" ]]
then
  rm -f xray
  mv xray_softfloat xray
else
  rm -f xray_softfloat
fi
rm -f xray.tar.gz

chmod +x xray
filesize=`ls -l xray | awk '{ print $5 }'`

mkdir -p data/usr/bin
mv xray data/usr/bin

sed -i "s/==VERSION==/$version/g" ./control/control
sed -i "s/==SIZE==/$filesize/g" ./control/control

cd control
tar -zcf ../control.tar.gz * --owner=0 --group=0
cd ..
rm -rf control

cd data
tar -zcf ../data.tar.gz * --owner=0 --group=0
cd ..
rm -rf data

tar -zcf ../xray-$version.ipk * --owner=0 --group=0
cd ..
rm -rf tmp

#!/usr/bin/env bash

BASE=$(dirname $(readlink -f "$0"))
TMP=$BASE/tmp
UPX=$BASE/upx

cleanup () { rm -rf $TMP; }
trap cleanup INT TERM ERR

build_v2() {
  cd $BASE/Xray-core
  echo ">>> Compile xray ..."
  if [[ $GOARCH == "mips" || $GOARCH == "mipsle" ]];then
    env CGO_ENABLED=0 go build -o $TMP/xray -trimpath -ldflags "-s -w -buildid=" ./main
    env CGO_ENABLED=0 GOMIPS=softfloat go build -o $TMP/xray_softfloat -trimpath -ldflags "-s -w -buildid=" ./main
  elif [[ $GOOS == "windows" ]];then
    env CGO_ENABLED=0 go build -o $TMP/xray.exe -trimpath -ldflags "-s -w -buildid=" ./main
  elif [[ $GOARCH == "armv5" ]];then
    env CGO_ENABLED=0 GOARCH=arm GOARM=5 go build -o $TMP/xray -trimpath -ldflags "-s -w -buildid=" ./main
  elif [[ $GOARCH == "armv6" ]];then
    env CGO_ENABLED=0 GOARCH=arm GOARM=6 go build -o $TMP/xray -trimpath -ldflags "-s -w -buildid=" ./main
  elif [[ $GOARCH == "armv7" ]];then
    env CGO_ENABLED=0 GOARCH=arm GOARM=7 go build -o $TMP/xray -trimpath -ldflags "-s -w -buildid=" ./main
  elif [[ $GOARCH == "arm64" ]];then
    env CGO_ENABLED=0 GOARCH=arm64 go build -o $TMP/xray -trimpath -ldflags "-s -w -buildid=" ./main
  else
    env CGO_ENABLED=0 go build -o $TMP/xray -trimpath -ldflags "-s -w -buildid=" ./main
  fi
}

packzip() {
  echo ">>> Generating zip package"
  cd $TMP
  $UPX --best --lzma *
  tar -czvf $BASE/bin/xray-${GOOS}-${GOARCH}.tar.gz *
  cd $BASE
}

GOOS=$1
GOARCH=$2

export GOOS GOARCH
export PATH=$PATH:/usr/local/go/bin
export GOROOT=/usr/local/go
go version
echo "Build ARGS: GOOS=${GOOS} GOARCH=${GOARCH}"
build_v2
packzip
cleanup

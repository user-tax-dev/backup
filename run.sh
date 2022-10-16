#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

cd lib
./contabo/snapshot.js &
./pg.js &

wait || { echo "error : $?" >&2; exit 1;}

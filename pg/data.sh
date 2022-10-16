#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR

ROOT=$(dirname $(dirname $DIR))

set -ex

bucket=$1
db=$2
schema=$3

# 避免并发备份的时候误删除
BASE=/tmp/pg/data/$db/$schema

OUT=$BASE/$(date +%Y%m)/$(date +%d)/$db

mkdir -p $OUT
cd $OUT

RESTORE=$schema.pg_restore
TZT=$RESTORE.zst

rm -rf $RESTORE $TZT

pg_dump $PG_URI --data-only -n $schema --format=c -f $RESTORE

zstd -T0 --ultra -22 $RESTORE && rm $RESTORE

openssl enc -aes-256-cbc -salt -in $TZT -out $TZT.enc -pass file:$ROOT/key/backup/backup.key

rm -rf $TZT

rclone copy $BASE/ $bucket && rm -rf $BASE

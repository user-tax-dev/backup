#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

ROOT=$(dirname $(dirname $DIR))

file=/tmp/pg/data/dist/public

openssl enc -d -aes-256-cbc -in $file.pg_restore.zst.enc -pass file:$ROOT/key/backup/backup.key | zstdcat > $file.pg_restore

pg_restore -f $file.sql $file.pg_restore

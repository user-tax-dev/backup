#!/usr/bin/env bash

set -e

DIR=$(
  cd "$(dirname "$0")"
  pwd
)
cd $DIR

PG_DB=$1
mkdir -p table/$PG_DB
FILE=table/$PG_DB/$2

echo $FILE

pg_dump $PG_URI --no-owner --no-acl -s -n $2 -f $FILE.sql &
pg_dump $PG_URI --if-exists --clean --no-owner --no-acl -s -n $2 -f $FILE.drop.sql &

wait || (echo "error : $?" >&2 && exit 1)

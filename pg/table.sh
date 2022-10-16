#!/usr/bin/env bash

set -e

DIR=$(cd "$(dirname "$0")"; pwd)
cd $DIR

PG_DB=$1
mkdir -p table/$PG_DB
FILE=table/$PG_DB/$2.sql
echo $FILE
pg_dump $PG_URI --no-owner --no-acl -s -n $2 -f $FILE
sed  -i '/^-- .* version .*/d' $FILE

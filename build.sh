#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

rm -rf lib
bun run cep -- -c src -o lib
rsync -ravu --include="*.mjs" --include="*/" --exclude="*" src/ lib

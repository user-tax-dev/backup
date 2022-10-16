#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

date "+%Y-%m" > .date

if [ -n "$(git status -s)" ];then
git config user.email "ci@user.tax"
git config user.name "ci"
git add pg/* || true
git add -A
git commit -m'　'
exit 0
fi
exit 1

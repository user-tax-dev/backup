#!/usr/bin/env -S node --es-module-specifier-resolution=node --trace-uncaught --expose-gc --unhandled-rejections=strict
var ROOT, backup, bucket, dump, rmOutdate;

import 'zx/globals';

import {
  dirname,
  join
} from 'path';

import thisdir from '@rmw/thisdir';

import read from '@iuser/read';

import write from '@iuser/write';

import {
  rename,
  readFile,
  opendir
} from 'fs/promises';

import pg from '@iuser/pg';

bucket = 'sj-backup:backup';

rmOutdate = async() => {
  var Path, date, nowym, ref, results, stdout, x, ym;
  ({stdout} = (await $`rclone lsjson ${bucket}`));
  date = new Date();
  nowym = date.getFullYear() * 12 + date.getMonth() + 1;
  ref = JSON.parse(stdout);
  results = [];
  for (x of ref) {
    ({Path} = x);
    if (Path.length === 6) {
      ym = parseInt(Path);
      if (ym) {
        if ((nowym - (parseInt(ym / 100) * 12 + ym % 100)) > 3) {
          results.push((await $`rclone delete ${bucket + '/' + ym}`));
        } else {
          results.push(void 0);
        }
      } else {
        results.push(void 0);
      }
    } else {
      results.push(void 0);
    }
  }
  return results;
};

ROOT = dirname(thisdir(import.meta));

dump = async(mod) => {
  var db, q, ref, schema_name, uri, x;
  uri = 'postgres://' + mod;
  db = mod.split('?')[0].split('/').pop();
  q = (await pg(mod));
  ref = (await q(`select schema_name from information_schema.schemata WHERE schema_name NOT IN ('information_schema', 'pg_catalog')`));
  for (x of ref) {
    [schema_name] = x;
    Object.assign(process.env, {
      PG_URI: uri
    });
    schema_name = schema_name.trim();
    if (schema_name === 'pg_toast') {
      continue;
    }
    await Promise.all([
      (async() => {
        var fp;
        await $`${ROOT}/pg/table.sh ${db} ${schema_name}`;
        fp = `pg/table/${db}/${schema_name}.sql`;
        write(fp,
      read(fp).replaceAll('CREATE SCHEMA ',
      'CREATE SCHEMA IF NOT EXISTS '));
      })(),
      $`${ROOT}/pg/data.sh ${bucket} ${db} ${schema_name}`
    ]);
  }
};

backup = async() => {
  var PG_DIR, i, name, ref, runing;
  PG_DIR = join(dirname(ROOT), 'key/db/pg');
  runing = [];
  ref = (await opendir(PG_DIR));
  for await (i of ref) {
    if (i.isFile()) {
      ({name} = i);
      if (name.endsWith('.mjs')) {
        runing.push(dump(((await import(join(PG_DIR, name)))).default));
      }
    }
  }
  await Promise.all(runing);
};

await Promise.all([backup(), rmOutdate()]);

process.exit();

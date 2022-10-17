#!/usr/bin/env coffee

> zx/globals:
  path > dirname join
  @rmw/thisdir
  @iuser/read
  @iuser/write
  fs/promises > rename readFile opendir
  @iuser/pg

bucket='sj-backup:backup'

rmOutdate = =>
  {stdout} = await $"rclone lsjson #{bucket}"

  date=new Date
  nowym = date.getFullYear()*12 + date.getMonth()+1

  for {Path} from JSON.parse stdout
    if Path.length == 6
      ym = parseInt Path
      if ym
        if (nowym - (parseInt(ym/100)*12+ym%100))>3
          await $"rclone delete #{bucket+'/'+ym}"

ROOT = dirname thisdir(import.meta)


dump = (mod)=>
  uri = 'postgres://'+mod
  db = mod.split('?')[0].split('/').pop()
  q = await pg mod
  for [schema_name] from await q('''select schema_name from information_schema.schemata WHERE schema_name NOT IN ('information_schema', 'pg_catalog')''')
    Object.assign(
      process.env
      PG_URI:uri
    )
    schema_name = schema_name.trim()
    if schema_name == 'pg_toast'
      continue
    await Promise.all [
      $"#{ROOT}/pg/table.sh #{db} #{schema_name}"
      $"#{ROOT}/pg/data.sh #{bucket} #{db} #{schema_name}"
    ]
    fp = "pg/table/#{db}/#{schema_name}.sql"
    write(
      fp
      read(fp).replaceAll('CREATE SCHEMA ','CREATE SCHEMA IF NOT EXIST ')
    )
  return

backup = =>
  PG_DIR = join dirname(ROOT), 'key/db/pg'

  runing = []
  for await i from await opendir PG_DIR
    if i.isFile()
      {name} = i
      if name.endsWith '.mjs'
        runing.push dump(
          (await import(join(PG_DIR,name))).default
        )

  await Promise.all runing
  return

await Promise.all [
  backup()
  rmOutdate()
]

process.exit()

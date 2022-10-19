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
      do =>
        await $"#{ROOT}/pg/table.sh #{db} #{schema_name}"
        fp = join ROOT, "pg/table/#{db}/#{schema_name}.sql"
        create_schema = "CREATE SCHEMA #{schema_name};"
        write(
          fp
          read(fp).replace(
            create_schema
            create_schema+'\nSET search_path TO '+schema_name+';'
          ).replaceAll('CREATE SCHEMA ','CREATE SCHEMA IF NOT EXISTS ').replaceAll(schema_name+'.','').split('\n').filter(
            (i)=>
              if not i
                return false
              return not i.startsWith '--'
          ).join('\n')
        )
        return
      $"#{ROOT}/pg/data.sh #{bucket} #{db} #{schema_name}"
    ]
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

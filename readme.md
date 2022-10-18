## 导入数据

`psql postgres:// 用户名 : 密码 @ 主机 : 端口 / 数据库 < pg/table/user.tax/public.sql`

## 脚本用途

定期快照 : ./src/contabo/snapshot.coffee 

## tar.zst 解压

`tar --zstd -xf xxx.tar.zst`

## zstd 解压

`unzstd public.pg_restore.zst`

## pg_restore 文件查看

`pg_restore -f- ./dist-public.pg_restore`

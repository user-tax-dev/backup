CREATE EXTENSION uint;

CREATE EXTENSION md5hash;

UPDATE
  pg_type
SET oid = 990001
WHERE typname = 'u8';

UPDATE
  pg_type
SET oid = 990002
WHERE typname = 'u16';

UPDATE
  pg_type
SET oid = 990003
WHERE typname = 'u32';

UPDATE
  pg_type
SET oid = 990004
WHERE typname = 'u64';

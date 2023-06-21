PRAGMA page_count;

PRAGMA page_size;

PRAGMA max_page_count;

PRAGMA cache_size;

PRAGMA freelist_count;

pragma default_cache_size;

pragma auto_vacuum;

PRAGMA incremental_vacuum;

PRAGMA stats;

PRAGMA table_list;

PRAGMA user_version;

PRAGMA encoding;


-- Examining the root page

select rowid, * from sqlite_schema



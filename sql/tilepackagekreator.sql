BEGIN TRANSACTION;

DROP TABLE IF EXISTS history;

CREATE TABLE history (
    OBJECTID INTEGER primary key autoincrement not null,
    type TEXT,
    transaction_date INTEGER,
    tile_service_name TEXT,
    tile_service_url TEXT,
    uses_token INTEGER,
    esri_geometry TEXT,
    tpk_app_geometry TEXT,
    buffer INTEGER,
    levels TEXT
    );

COMMIT;

BEGIN TRANSACTION;

DROP TABLE IF EXISTS bookmarks;

CREATE TABLE bookmarks (
    OBJECTID INTEGER primary key autoincrement not null,
    name TEXT,
    tpk_app_geometry TEXT
    );

COMMIT;

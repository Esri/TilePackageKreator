BEGIN TRANSACTION;

DROP TABLE IF EXISTS exports;

CREATE TABLE exports (
    OBJECTID INTEGER primary key autoincrement not null,
    title TEXT,
    description TEXT,
    transaction_date INTEGER,
    tile_service_name TEXT,
    tile_service_url TEXT,
    uses_token INTEGER,
    esri_geometry TEXT,
    tpk_app_geometry TEXT,
    buffer INTEGER,
    levels TEXT,
    package_size TEXT,
    number_of_tiles TEXT,
    local_filepath TEXT,
    download_url TEXT,
    user TEXT
    );

COMMIT;

BEGIN TRANSACTION;

DROP TABLE IF EXISTS uploads;

CREATE TABLE uploads (
    OBJECTID INTEGER primary key autoincrement not null,
    title TEXT,
    transaction_date INTEGER,
    description TEXT,
    published_service_url TEXT,
    user TEXT
    );

COMMIT;

BEGIN TRANSACTION;

DROP TABLE IF EXISTS bookmarks;

CREATE TABLE bookmarks (
    OBJECTID INTEGER primary key autoincrement not null,
    name TEXT,
    tpk_app_geometry TEXT,
    user TEXT
    );

COMMIT;

BEGIN TRANSACTION;

DROP TABLE IF EXISTS other_tile_services;

CREATE TABLE other_tile_services (
    OBJECTID INTEGER primary key autoincrement not null,
    url TEXT,
    user TEXT
    );

COMMIT;

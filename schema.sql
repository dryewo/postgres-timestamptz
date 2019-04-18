CREATE TABLE test(
    n    SERIAL,
    name TEXT,
    ts   TIMESTAMP DEFAULT (now() AT TIME ZONE 'UTC')
);

ALTER DATABASE postgres SET timezone TO 'Etc/GMT+4'

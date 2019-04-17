CREATE TABLE test(
    n    SERIAL,
    name TEXT,
    ts   TIMESTAMPTZ DEFAULT now()
);

ALTER DATABASE postgres SET timezone TO 'Etc/GMT+4'

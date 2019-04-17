CREATE TABLE test(
    n    SERIAL,
    name TEXT,
    ts   TIMESTAMP DEFAULT now(),
    tstz TIMESTAMPTZ DEFAULT now()
);

ALTER DATABASE postgres SET timezone TO 'Etc/GMT+4'

#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'


DB_IMAGE=postgres:11.2
DB_CONTAINER=postgres-timestamptz-db
DB_PORT=5433


cmd_stop-db() {
    docker rm -fv "$DB_CONTAINER" || true
}


cmd_db() {
    set -x
    cmd_stop-db
    docker run -dt --name "$DB_CONTAINER" \
        -p "$DB_PORT:5432" \
        "$DB_IMAGE"
    sleep 1    # TODO implement proper waiting for PostgreSQL to start up
    cat schema.sql | docker exec -i "$DB_CONTAINER" psql -U postgres
    set +x

    echo -e "\nRun this script again to wipe the database."
}


cmd_dbd() {
    docker exec -i "$DB_CONTAINER" psql -U postgres << EOF
SELECT now();
SHOW timezone;
SELECT * FROM test;
SET timezone TO 'Etc/GMT+6';
SHOW timezone;
SELECT * FROM test;
SET timezone TO 'UTC';
SHOW timezone;
SELECT * FROM test;
EOF
}


cmd_psql() {
    docker exec -it "$DB_CONTAINER" psql -U postgres
}


cmd_run() {
    go run . "$@"
}
cmd_r() { cmd_run "$@"; }


# Print all defined cmd_
cmd_help() {
    compgen -A function cmd_
}

# Run multiple commands without args
cmd_mm() {
    for cmd in "$@"; do
        cmd_$cmd
    done
}

if [[ $# -eq 0 ]]; then
    echo Please provide a subcommand
    exit 1
fi

SUBCOMMAND=$1
shift

# Enable verbose mode
#set -x
# Run the subcommand
cmd_${SUBCOMMAND} "$@"

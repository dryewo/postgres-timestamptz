# Timestamps in PostgreSQL

This project is a demonstration of using `TIMESTAMPTZ` and `TIMESTAMP` types for tracking timestamp information in
PostgreSQL tables. Uses Go as application language.

From a distance it might seem that `TIMESTAMP` should be always enough, in the end, we care about absolute timestamp
values, not about its timezone-specific representation. However, this experiment proves the opposite.

**TL;DR** Use `TIMESTAMPTZ`, it yields simpler and less error-prone code. Using `TIMESTAMP` is also possible, but needs
precautions.

## Prerequisites

To run this experiment locally, you will need:

* Go 1.12 or newer
* Docker

## Experiment

This setup includes a database with a simple table (see _schema.sql_) and a program that inserts and selects data from
that table, periodically setting session timezone to random value.

The goal is to prove that using `TIMESTAMPTZ` cannot get you in trouble, and using `TIMESTAMP` will get you in trouble
unless you follow certain rules.

### Phase 1

After cloning this repository, run the following commands in the directory:

```
# Start a PostgreSQL database in a container, listening on port 5433
# Automatically initialize it from schema.sql, set non-default DB timezone
$ ./dev.sh db
...

# Run the program (example output provided)
$ go run .

Time right now:   10:36 CEST   08:36 UTC

Using default timezone from DB
Inserting data with now()
Inserting data with 2019-04-18 10:36:50.169524277 +0200 CEST m=+0.008674364
Setting timezone to Etc/GMT+2
Inserting data with now()
Inserting data with 2019-04-18 10:36:50.175165745 +0200 CEST m=+0.014315740
Setting timezone to Etc/GMT+1
Inserting data with now()
Inserting data with 2019-04-18 10:36:50.179444628 +0200 CEST m=+0.018594579
Setting timezone to Etc/GMT+12
Inserting data with now()
Inserting data with 2019-04-18 10:36:50.184295593 +0200 CEST m=+0.023445513
Setting timezone to Etc/GMT+1
from default now()               07:36 -01   08:36 UTC
from default now()               07:36 -01   08:36 UTC
from default now()               07:36 -01   08:36 UTC
from default now()               07:36 -01   08:36 UTC
from golang time.Now()           07:36 -01   08:36 UTC
from golang time.Now()           07:36 -01   08:36 UTC
from golang time.Now()           07:36 -01   08:36 UTC
from golang time.Now()           07:36 -01   08:36 UTC
from now()                       07:36 -01   08:36 UTC
from now()                       07:36 -01   08:36 UTC
from now()                       07:36 -01   08:36 UTC
from now()                       07:36 -01   08:36 UTC
Setting timezone to Etc/GMT+6
from default now()               02:36 -06   08:36 UTC
from default now()               02:36 -06   08:36 UTC
from default now()               02:36 -06   08:36 UTC
from default now()               02:36 -06   08:36 UTC
from golang time.Now()           02:36 -06   08:36 UTC
from golang time.Now()           02:36 -06   08:36 UTC
from golang time.Now()           02:36 -06   08:36 UTC
from golang time.Now()           02:36 -06   08:36 UTC
from now()                       02:36 -06   08:36 UTC
from now()                       02:36 -06   08:36 UTC
from now()                       02:36 -06   08:36 UTC
from now()                       02:36 -06   08:36 UTC
Setting timezone to UTC
from default now()               08:36 UTC   08:36 UTC
from default now()               08:36 UTC   08:36 UTC
from default now()               08:36 UTC   08:36 UTC
from default now()               08:36 UTC   08:36 UTC
from golang time.Now()           08:36 UTC   08:36 UTC
from golang time.Now()           08:36 UTC   08:36 UTC
from golang time.Now()           08:36 UTC   08:36 UTC
from golang time.Now()           08:36 UTC   08:36 UTC
from now()                       08:36 UTC   08:36 UTC
from now()                       08:36 UTC   08:36 UTC
from now()                       08:36 UTC   08:36 UTC
from now()                       08:36 UTC   08:36 UTC
```

First it deletes all existing rows from the table.  
Then it inserts several rows into the table (4 times 3 different ways of getting a timestamp), randomly changing the session timezone each time.
Then it selects all the rows and prints the obtained timestamp column in both its own timezone and normalized to UTC, this is repeated 3 times, randomly changing the session timezone each time.

As we can see, all the printed values are correct (all within the same hour and minute, but rendered using different timezone), they are the same as the current time printed in the beginning.  
This is the expected result, we don't want the application logic being affected by local timezone.

This implementation uses `TIMESTAMPTZ` and there are no special places where timezones are explicitly converted, neither in the application code nor in the DB schema.

### Phase 2

Now please change `TIMESTAMPTZ` to `TIMESTAMP` and try running the same routine again (both `./dev.db db` and `go run .`). You will see the output similar to this one:

```
Time right now:   10:46 CEST   08:46 UTC

Using default timezone from DB
Inserting data with now()
Inserting data with 2019-04-18 10:46:33.247986514 +0200 CEST m=+0.003596800
Setting timezone to Etc/GMT+6
Inserting data with now()
Inserting data with 2019-04-18 10:46:33.251899658 +0200 CEST m=+0.007509937
Setting timezone to Etc/GMT+10
Inserting data with now()
Inserting data with 2019-04-18 10:46:33.25744439 +0200 CEST m=+0.013054752
Setting timezone to Etc/GMT+8
Inserting data with now()
Inserting data with 2019-04-18 10:46:33.26371519 +0200 CEST m=+0.019325540
Setting timezone to Etc/GMT+6
from default now()             04:46 +0000   04:46 UTC
from default now()             02:46 +0000   02:46 UTC
from default now()             22:46 +0000   22:46 UTC
from default now()             00:46 +0000   00:46 UTC
from golang time.Now()         10:46 +0000   10:46 UTC
from golang time.Now()         10:46 +0000   10:46 UTC
from golang time.Now()         10:46 +0000   10:46 UTC
from golang time.Now()         10:46 +0000   10:46 UTC
from now()                     04:46 +0000   04:46 UTC
from now()                     02:46 +0000   02:46 UTC
from now()                     22:46 +0000   22:46 UTC
from now()                     00:46 +0000   00:46 UTC
Setting timezone to Etc/GMT+2
from default now()             04:46 +0000   04:46 UTC
from default now()             02:46 +0000   02:46 UTC
from default now()             22:46 +0000   22:46 UTC
from default now()             00:46 +0000   00:46 UTC
from golang time.Now()         10:46 +0000   10:46 UTC
from golang time.Now()         10:46 +0000   10:46 UTC
from golang time.Now()         10:46 +0000   10:46 UTC
from golang time.Now()         10:46 +0000   10:46 UTC
from now()                     04:46 +0000   04:46 UTC
from now()                     02:46 +0000   02:46 UTC
from now()                     22:46 +0000   22:46 UTC
from now()                     00:46 +0000   00:46 UTC
Setting timezone to UTC
from default now()             04:46 +0000   04:46 UTC
from default now()             02:46 +0000   02:46 UTC
from default now()             22:46 +0000   22:46 UTC
from default now()             00:46 +0000   00:46 UTC
from golang time.Now()         10:46 +0000   10:46 UTC
from golang time.Now()         10:46 +0000   10:46 UTC
from golang time.Now()         10:46 +0000   10:46 UTC
from golang time.Now()         10:46 +0000   10:46 UTC
from now()                     04:46 +0000   04:46 UTC
from now()                     02:46 +0000   02:46 UTC
from now()                     22:46 +0000   22:46 UTC
from now()                     00:46 +0000   00:46 UTC
```

Notice that **not a single value is correct** (08:46 UTC) now.

As an exercise, you can try to debug this and find workarounds to make the output correct again.

### Phase 3

**SPOILER ALERT**

You can check out `timestamp` branch and diff it with `master`:

```
$ git checkout timestamp
$ git diff master
```

Alternatively, take a look at the PR in this repo to see what changes are needed to make it work with `TIMESTAMP`.

If you run the experiment in `timestamp` branch (`./dev.sh db`, `go run .`), the output will show the same correct timestamp printed everywhere.

In a nutshell, the following rules must be followed when programming against `TIMESTAMP` column:

1. Always use `TIMESTAMP DEFAULT (now() AT TIME ZONE 'UTC')` instead of `TIMESTAMP DEFAULT now()`.
2. Always use `now() AT TIME ZONE 'UTC'` instead of `now()` in `INSERT` or statements.
   * same applies for time conditions involving `now()` in `SELECT` or `UPDATE` statements.
3. Always convert the timestamp using `time.Time.UTC()` method in Go programs when passing it to the DB library:  
   `db.MustExec("INSERT INTO test (ts) VALUES ($1);", now.UTC())`

It's easy to occasionally forget to follow one of these rules, which will lead to bugs.

## Learnings

1. `time.Time` type in Go actually contains time zone information, just like `TIMESTAMPTZ`.
2. `now()` function in PostgreSQL returns a value of type `TIMESTAMPTZ`.
3. When assigning a value of `TIMESTAMPTZ` to a field of type `TIMESTAMP`, current session timezone is used for
   rendering the time, but timezone info is discarded, thus yielding incorrect saved value.
4. The counter-intuitive outcome of the experiment (storing redundant timezone information makes the solution more robust)
   can be explained by the way other software components work:
   * DB and client functions actually pay attention to the current session time zone and do the necessary conversions
     automatically when working with timestamps. To support `TIMESTAMP`, these conversions need to be explicitly disabled,
     which requires discipline and also provides distraction for the programmer.
5. There is no value we gain by using `TIMESTAMP` instead of `TIMESTAMPTZ`, but there is price we need to pay.

## Additional reading

* [Understanding PostgreSQL Timestamp Data Types](http://www.postgresqltutorial.com/postgresql-timestamp/)


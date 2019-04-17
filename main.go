package main

import (
	"fmt"
	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
	"math/rand"
	"time"
)

type Test struct {
	N    int
	Name string
	Ts   time.Time
	Tstz time.Time
}

func main() {
	rand.Seed(time.Now().UnixNano())
	db := sqlx.MustConnect("postgres", "postgres://postgres:@localhost:5433/postgres?sslmode=disable")

	now := time.Now()
	form := "15:04 MST"
	fmt.Printf("Time right now: % 12v% 12v\n\n", now.Format(form), now.UTC().Format(form))

	db.MustExec("DELETE FROM test;")

	fmt.Println("Using default timezone from DB")
	insertData(db)

	for i := 0; i < 5; i++ {
		setRandomTimezone(db)
		insertData(db)
	}

	for i := 0; i < 2; i++ {
		setRandomTimezone(db)
		dumpAll(db)
	}

	setTimezone(db, "UTC")
	dumpAll(db)
}

func dumpAll(db *sqlx.DB) {
	form := "15:04 MST"
	rows := []Test{}
	db.Select(&rows, "SELECT * FROM test ORDER BY name, n;")
	for _, r := range rows {
		fmt.Printf("% 5d     %-35v% 12v% 12v          % 12v% 12v\n", r.N, r.Name, r.Ts.Format(form), r.Ts.UTC().Format(form), r.Tstz.Format(form), r.Tstz.UTC().Format(form))
	}
}

func setRandomTimezone(db *sqlx.DB) {
	tz := fmt.Sprintf("Etc/GMT+%d", rand.Intn(12)+1)
	setTimezone(db, tz)
}

func setTimezone(db *sqlx.DB, tz string) {
	fmt.Printf("Setting timezone to %v\n", tz)
	db.MustExec("SET timezone TO '" + tz + "'")
}

func insertData(db *sqlx.DB) {
	now := time.Now()
	query := `INSERT INTO test (name, ts, tstz) VALUES ($1, $2, $3);`
	fmt.Println("Inserting data with now()")
	db.MustExec("INSERT INTO test (name) VALUES ('from default now()')")
	db.MustExec("INSERT INTO test (name, ts, tstz) VALUES ('from now()', now(), now())")
	fmt.Printf("Inserting data with %v\n", now)
	db.MustExec(query, "from golang time.Now()", now, now)
}

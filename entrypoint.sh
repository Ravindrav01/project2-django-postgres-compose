#!/bin/sh
# Wait for Postgres, apply migrations, then start the server.
set -e

echo ">> Waiting for PostgreSQL at ${POSTGRES_HOST:-db}:${POSTGRES_PORT:-5432}..."
python - <<'PY'
import os, time, psycopg
for i in range(30):
    try:
        psycopg.connect(
            host=os.getenv("POSTGRES_HOST", "db"),
            port=os.getenv("POSTGRES_PORT", "5432"),
            dbname=os.getenv("POSTGRES_DB", "postgres"),
            user=os.getenv("POSTGRES_USER", "postgres"),
            password=os.getenv("POSTGRES_PASSWORD", "postgres"),
        ).close()
        print(">> PostgreSQL is up.")
        break
    except Exception:
        time.sleep(2)
else:
    raise SystemExit(">> PostgreSQL not reachable, giving up.")
PY

echo ">> Applying migrations..."
python manage.py migrate --noinput

exec "$@"

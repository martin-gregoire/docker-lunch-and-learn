import logging
import os
import time

import psycopg2
from flask import Flask, jsonify, request
# from pythonjsonlogger import jsonlogger  # uncomment when adding python-json-logger

_handler = logging.StreamHandler()
# _handler.setFormatter(jsonlogger.JsonFormatter("%(asctime)s %(levelname)s %(message)s"))
logging.getLogger().addHandler(_handler)
logging.getLogger().setLevel(logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

DATABASE_URL = os.environ["DATABASE_URL"]


def _db():
    return psycopg2.connect(DATABASE_URL)


def _init_db(retries: int = 10, delay: int = 2) -> None:
    for attempt in range(retries):
        try:
            with _db() as conn:
                with conn.cursor() as cur:
                    cur.execute(
                        "CREATE TABLE IF NOT EXISTS items "
                        "(id SERIAL PRIMARY KEY, name TEXT NOT NULL)"
                    )
                    cur.execute("SELECT COUNT(*) FROM items")
                    if cur.fetchone()[0] == 0:
                        cur.executemany(
                            "INSERT INTO items (name) VALUES (%s)",
                            [("Docker",), ("Kubernetes",), ("Containers",)],
                        )
            return
        except Exception:
            if attempt < retries - 1:
                time.sleep(delay)
            else:
                raise


@app.route("/api/health")
def health():
    return jsonify({"status": "ok"})


@app.route("/api/items")
def get_items():
    with _db() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT id, name FROM items ORDER BY id")
            rows = cur.fetchall()
    items = [{"id": r[0], "name": r[1]} for r in rows]
    logger.info("items requested", extra={"count": len(items), "path": request.path})
    return jsonify(items)


_init_db()

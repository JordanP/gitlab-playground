import contextlib
import os

import flask
import psycopg2


def make_app():
    app = flask.Flask(__name__)

    @app.route('/')
    def homepage():
        db_url = os.getenv("DATABASE_URL")
        version = os.getenv("VERSION", "unknown")
        with contextlib.closing(psycopg2.connect(db_url)) as conn:
            with contextlib.closing(conn.cursor()) as cur:
                cur.execute("SELECT to_char(current_date, 'Day');")
                day = cur.fetchone()[0].rstrip()
                return 'Today is a %s. Running version %s' % (day, version)

    return app

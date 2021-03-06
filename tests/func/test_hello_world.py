import time
from datetime import datetime

import flask.testing


def test_hello_world(test_client: flask.testing.Client):
    time.sleep(5)
    resp = test_client.get("/")
    assert resp.status_code == 200
    today = datetime.today().strftime('%A')
    assert f"Today is a {today}. Running version unknown" in \
           resp.get_data(as_text=True)

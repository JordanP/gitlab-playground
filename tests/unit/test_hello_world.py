import requests

from hello_world import some_func


def test_requests():
    print(requests)
    resp = requests.get("https://google.fr")
    assert resp.status_code == 200


def test_some_func():
    assert some_func() == 42

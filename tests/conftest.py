import pytest

from hello_world import make_app


@pytest.fixture()
def test_app():
    app = make_app()
    yield app


@pytest.fixture()
def test_app_with_ctx(test_app):
    with test_app.app_context():
        yield test_app


@pytest.fixture()
def test_client(test_app_with_ctx):
    yield test_app_with_ctx.test_client()

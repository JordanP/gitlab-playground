# Python 3.7 + Python.h (/usr/local/include/python3.7m/Python.h): 143M
FROM python:3.7-slim-stretch as build

# https://medium.com/@greut/building-a-python-package-a-docker-image-using-pipenv-233d8793b6cc

# ARG directive set the variable only during the build
# https://github.com/moby/moby/issues/4032#issuecomment-192327844
ARG DEBIAN_FRONTEND=noninteractive

ENV LC_ALL=C.UTF-8 LANG=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

RUN apt-get update --quiet \
 && apt-get install -y --quiet --no-install-recommends \
        gcc \
        libc-dev \
        libpq-dev \
 && python3 -m pip install --no-cache-dir --upgrade pip wheel pipenv \
 && rm -rf /var/lib/apt/lists/*


WORKDIR /app

COPY Pipfile Pipfile.lock ./

# --system installs packages system wide, i.e no virtualenv
# --deploy will fail a build if the Pipfile.lock is out–of–date
# --dev also installs dev-packages
RUN pipenv install --deploy --dev \
 && pipenv lock -r > requirements.txt

COPY hello_world/app.py setup.py setup.cfg ./
COPY hello_world hello_world

RUN PBR_VERSION=1.0.0 pipenv run python setup.py bdist_wheel

COPY tests tests

#ARG VERSION This doesn't play nicely with docker cache
#ENV VERSION ${VERSION}
CMD ["pipenv", "run", "flask", "run", "--host", "0.0.0.0", "--port", "5000"]
EXPOSE 5000




# Python 3.7: 69MB
FROM debian:buster-slim as run

ARG DEBIAN_FRONTEND=noninteractive

COPY --from=build /app/dist/*.whl .

RUN apt-get update --quiet \
 && apt-get install -y --quiet --no-install-recommends \
        gcc \
        libpq-dev \
        python3-dev \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        uwsgi-plugin-python3 \
 && python3 -m pip install --no-cache-dir *.whl \
 && apt-get purge -y --auto-remove python3-pip python3-wheel gcc python3-dev python3-setuptools \
 && apt-get clean -y \
 && rm -f *.whl \
 && rm -rf /var/lib/apt/lists/* \
 && useradd --system --create-home --user-group --home-dir /app _uwsgi

USER _uwsgi
#ADD static /app/static

ENTRYPOINT ["/usr/bin/uwsgi", \
            "--master", \
            "--die-on-term", \
            "--plugin", "python3", \
            "--chdir", "/app"]
CMD ["--http-socket", "0.0.0.0:5000", \
     "--processes", "2", \
     "--threads", "2", \
#     "--check-static", "static", \
     "--module", "hello_world.app:app"]

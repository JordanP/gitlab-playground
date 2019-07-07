# Python 3.7 + Python.h (/usr/local/include/python3.7m/Python.h): 143M
FROM python:3.7-slim-stretch as build

# https://medium.com/@greut/building-a-python-package-a-docker-image-using-pipenv-233d8793b6cc

# ARG directive set the variable only during the build
# https://github.com/moby/moby/issues/4032#issuecomment-192327844
ARG DEBIAN_FRONTEND=noninteractive

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update --quiet \
 && apt-get install -y --quiet \
        libpq-dev \
        gcc \
 && python3 -m pip install --upgrade pip wheel pipenv \
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

RUN apt-get update --quiet && apt-get install -y --quiet \
        libpq-dev \
        python3-wheel \
        python3-pip \
        uwsgi-plugin-python3 \
 && python3 -m pip install *.whl \
 && apt-get remove -y python3-pip python3-wheel \
 && apt-get autoremove -y \
 && apt-get clean -y \
 && rm -f *.whl \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /app \
 && useradd _uwsgi --no-create-home --user-group

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

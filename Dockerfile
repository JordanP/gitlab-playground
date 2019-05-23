FROM ubuntu:18.04 as run
#

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update && apt-get install -y \
    python3 python3-venv python3-pip libpq-dev \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip wheel
RUN pip3 install pipenv

WORKDIR /app

COPY Pipfile Pipfile.lock ./

# --system installs packages system wide, i.e no virtualenv
# --deploy will fail a build if the Pipfile.lock is out–of–date
RUN pipenv install --deploy --system

COPY app.py .
COPY hello_world hello_world

ARG VERSION
ENV VERSION ${VERSION}
CMD ["flask", "run", "--host", "0.0.0.0", "--port", "5000"]
EXPOSE 5000


FROM run as test
COPY tests tests
RUN pipenv install --system --deploy --dev






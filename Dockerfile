FROM python:3.11.4-alpine3.18
LABEL maintainer="mnavunawa"

ENV PYTHONUNBUFFERED 1
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./scripts /scripts
COPY ./app /app
WORKDIR /app
EXPOSE 9000

ARG DEV=false

RUN python -m venv  /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client libpq jpeg-dev && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        postgresql-dev musl-dev gcc zlib zlib-dev linux-headers && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    /py/bin/pip install -r /tmp/requirements.dev.txt && \
    if [$DEV == "true"];\
        then /py/bin/pip install -r /tmp/requirements.dev.txt; \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user && \
    mkdir -p /vol/web/media && \
    mkdir -p /vol/web/static && \
    chown -R django-user:django-user /vol && \
    chmod -R 755 /vol && \
    chmod -R +x /scripts

ENV PATH="/scripts/:/py/bin:$PATH"
USER django-user

CMD ["run.sh"]



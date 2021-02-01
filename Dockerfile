FROM python:3.6-alpine AS build
COPY . /src
RUN pip install --upgrade pip \
    && pip install wheel
RUN cd /src \
    && python setup.py bdist_wheel -d /deps

FROM python:3.6-alpine
MAINTAINER scielo-dev@googlegroups.com

COPY --from=build /deps/* /deps/
COPY production.ini /app/config.ini
COPY start.sh /app/start.sh
COPY requirements.txt .
COPY api/static/* /app/static/

RUN apk add --no-cache --virtual .build-deps \
        gcc g++ mariadb-dev \
    && pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && pip install --no-index --find-links=file:///deps -U scielo-sushiapi \
    && apk --purge del .build-deps \
    && rm -rf /deps

RUN chmod +x /app/start.sh

WORKDIR /app

EXPOSE 6543

ENV PYTHONUNBUFFERED 1
ENV MARIADB_STRING_CONNECTION "mysql://user:pass@localhost:port/database"
ENV APPLICATION_URL "http://127.0.0.1:6543"

USER nobody

CMD ["/app/start.sh"]

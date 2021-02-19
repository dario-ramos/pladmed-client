FROM alpine:3.7

COPY ./scamper ./scamper
COPY ./docker-entrypoint.sh .
COPY ./src/requirements.txt .

# Register daily cron job for client time synchronization
RUN mkdir /etc/cron.d
COPY ./time-sync/crontab /etc/cron.d/timesync
RUN chmod 0644 /etc/cron.d/timesync
RUN touch /var/log/cron.log
RUN crontab /etc/cron.d/timesync

RUN apk add gcc g++ libffi-dev musl-dev zlib-dev linux-headers make bind-tools \
    && cd scamper && ./configure && make && make install \
    && apk del gcc g++ libffi-dev musl-dev zlib-dev linux-headers make

RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools
RUN pip3 install -r requirements.txt

RUN chmod -R +x scamper/

ENV HOME=/src
WORKDIR $HOME

ENTRYPOINT ["/bin/sh"]

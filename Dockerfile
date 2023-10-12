FROM python:alpine

ENV PUID="1000" \
    PGID="1000" \
    UMASK="002" \
    ON_DOCKER=True \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    PYTHONUNBUFFERED=1

ARG OVERLAY_ARCH
ARG OVERLAY_VERSION=v2.2.0.3
ARG TTYD_ARCH
ARG TTYD_VERSION=1.7.3

WORKDIR /usr/src/app

COPY /root /
COPY . .

ADD https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}-installer /tmp/
RUN chmod +x /tmp/s6-overlay-${OVERLAY_ARCH}-installer && \
    /tmp/s6-overlay-${OVERLAY_ARCH}-installer / && \
    rm /tmp/s6-overlay-${OVERLAY_ARCH}-installer

RUN apk add --update --virtual=build-dependencies postgresql-dev wget gcc g++ cargo && \
    apk add --update --no-cache bash shadow libpq nodejs npm coreutils curl wget && \
    wget https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.${TTYD_ARCH} -O /usr/bin/ttyd && \
    chmod +x /usr/bin/ttyd && \
    pip install --no-cache -U pip && \
    pip install --no-cache-dir -r requirements.txt && \
    apk --purge del build-dependencies && \
    python -m venv pilot-env && \
    chmod +x ./start.sh && \
    /bin/bash -c "source pilot-env/bin/activate" && \
    useradd -u 1000 -U -d "/usr/src/app" -s /bin/false pilot && \
    usermod -G users pilot

CMD ["/usr/src/app/start.sh"]

RUN pip install -r requirements.txt
WORKDIR /usr/src/app/pilot

VOLUME ["/workspace"]

EXPOSE 7681

ENTRYPOINT ["/init"]
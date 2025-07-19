FROM debian:stable-slim

RUN apt-get update \
    && apt-get install -y tor --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

COPY torrc /etc/tor/torrc

RUN mkdir -p /var/lib/tor/hidden_service \
    && chown debian-tor:debian-tor /var/lib/tor/hidden_service \
    && chmod 700 /var/lib/tor/hidden_service

USER debian-tor

CMD ["tor", "-f", "/etc/tor/torrc"]

FROM debian:stable-slim

RUN apt-get update \
    && apt-get install -y nginx --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

COPY nginx.conf /etc/nginx/nginx.conf
COPY html/index.html /var/www/html/index.html

CMD ["nginx", "-g", "daemon off;"]
FROM nginx:stable-alpine

RUN adduser -D -u 1000 www-data

COPY ./nginx.conf /etc/nginx/nginx.conf

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]


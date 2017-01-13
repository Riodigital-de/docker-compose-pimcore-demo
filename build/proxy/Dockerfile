FROM nginx:stable-alpine

RUN adduser -D -u 1000 www-data

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]


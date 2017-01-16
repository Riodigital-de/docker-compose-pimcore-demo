FROM alpine:3.4

ARG ENCRYPT
ARG DB_TYPE
ARG BACKUP_CYCLE

COPY ./bin /tmp/bin

# this is technically not 100% correct, as it checks if DB_TYPE is not unset, but not if its is not set to null or ""
# but i still cant figure out how exactly the shell variable expansion works
# see
# http://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
RUN if [ "$ENCRYPT" = "true" ] || [ -n "$DB_TYPE" ]; then apk update; fi

RUN if [ "$ENCRYPT" = "true" ]; then apk add gnupg && mkdir /root/.gnupg ; fi


RUN if [ "$DB_TYPE" = "postgres" ]; then \
        # postgresql-client is insufficient, that package only contains the bare client withput any tools whatsoever
        apk add postgresql && \
        mv /tmp/bin/db/postgres /etc/periodic/${BACKUP_CYCLE}/postgres; \
    elif [ "$DB_TYPE" = "mysql" ]; then \
        # the mariadb-client package does include tools
        # thank you alpine package maintainers for your impeccable attention to consistency
        apk add mariadb-client && \
        mv /tmp/bin/db/mysql /etc/periodic/${BACKUP_CYCLE}/mysql; \
    fi

RUN mv /tmp/bin/volumes/* /etc/periodic/${BACKUP_CYCLE}/

RUN chmod -R +x /etc/periodic/${BACKUP_CYCLE}

CMD ["crond", "-l", "2", "-f"]
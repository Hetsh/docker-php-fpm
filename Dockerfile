FROM library/alpine:20200319
RUN apk add --no-cache \
    php7-fpm=7.3.17-r2

# App user
ARG OLD_USER="xfs"
ARG APP_USER="http"
ARG	APP_UID=33
ARG OLD_GROUP="xfs"
ARG APP_GROUP="http"
ARG	APP_GID=33
RUN sed -i "s|$OLD_USER:x:$APP_UID:$APP_GID:X Font Server:/etc/X11/fs:|$APP_USER:x:$APP_UID:$APP_GID:::|" /etc/passwd && \
    sed -i "s|$OLD_GROUP:x:$APP_GID:$OLD_USER|$APP_GROUP:x:$APP_GID:|" /etc/group

# Configuration
ARG CONF_DIR="/etc/php7/php-fpm.d"
ARG WWW_CONF="$CONF_DIR/www.conf"
RUN sed -i "s|user.*|user = $APP_USER|" "$WWW_CONF" && \
    sed -i "s|group.*|group = $APP_GROUP|" "$WWW_CONF" && \
    sed -i "s|;env\[PATH\]|env\[PATH\]|" "$WWW_CONF" && \
    sed -i "s|listen.*|listen = 9000|" "$WWW_CONF" && \
    sed -i "s|;catch_workers_output.*|catch_workers_output = yes|" "$WWW_CONF" && \
    sed -i "s|;decorate_workers_output.*|decorate_workers_output = no|" "$WWW_CONF"

# Volumes
ARG SRV_DIR="/srv"
ARG LOG_DIR="/var/log/php7"
RUN chown -R "$APP_USER":"$APP_GROUP" "$SRV_DIR" "$LOG_DIR"
VOLUME ["$CONF_DIR", "$SRV_DIR", "$LOG_DIR"]

#      PHP-FPM
EXPOSE 9000/tcp

WORKDIR "$SRV_DIR"
ENTRYPOINT ["php-fpm7", "--nodaemonize"]

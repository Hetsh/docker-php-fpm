FROM library/alpine:20200428
RUN apk add --no-cache \
    php7-fpm=7.3.18-r0

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
ARG PHP_DIR="/etc/php7"
ARG INI_CONF="$PHP_DIR/php.ini"
ARG CONF_DIR="$PHP_DIR/php-fpm.d"
ARG WWW_CONF="$CONF_DIR/www.conf"
RUN sed -i "s|^include_path|;include_path|" "$INI_CONF" && \
    sed -i "s|^user.*|user = $APP_USER|" "$WWW_CONF" && \
    sed -i "s|^group.*|group = $APP_GROUP|" "$WWW_CONF" && \
    sed -i "s|^;env\[PATH\]|env\[PATH\]|" "$WWW_CONF" && \
    sed -i "s|^listen.*|listen = 9000\n;listen = /run/php7/php-fpm.sock|" "$WWW_CONF" && \
    sed -i "s|^;listen\.owner.*|listen.owner = $APP_USER|" "$WWW_CONF" && \
    sed -i "s|^;listen\.group.*|listen.owner = $APP_GROUP|" "$WWW_CONF" && \
    sed -i "s|^;catch_workers_output.*|catch_workers_output = yes|" "$WWW_CONF" && \
    sed -i "s|^;decorate_workers_output.*|decorate_workers_output = no|" "$WWW_CONF"

# Volumes
ARG SRV_DIR="/srv"
ARG SOCK_DIR="/run/php7"
ARG LOG_DIR="/var/log/php7"
RUN mkdir "$SOCK_DIR" && \
    chmod 750 "$SOCK_DIR" && \
    chown -R "$APP_USER":"$APP_GROUP" "$SRV_DIR" "$SOCK_DIR" "$LOG_DIR"
VOLUME ["$CONF_DIR", "$SRV_DIR", "$SOCK_DIR" , "$LOG_DIR"]

#      PHP-FPM
EXPOSE 9000/tcp

WORKDIR "$SRV_DIR"
ENTRYPOINT ["php-fpm7", "--nodaemonize"]

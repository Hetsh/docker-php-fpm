FROM library/alpine:20210212
RUN apk add --no-cache \
        php7=7.4.21-r0 \
        php7-fpm=7.4.21-r0

# App user
ARG OLD_USER="xfs"
ARG APP_USER="http"
ARG APP_UID=33
ARG OLD_GROUP="xfs"
ARG APP_GROUP="http"
ARG APP_GID=33
# "Hijacking" user xfs for same uid & gid as user http on archlinux
RUN sed -i "s|$OLD_USER:x:$APP_UID:$APP_GID:X Font Server:/etc/X11/fs:|$APP_USER:x:$APP_UID:$APP_GID:::|" /etc/passwd && \
    sed -i "s|$OLD_GROUP:x:$APP_GID:$OLD_USER|$APP_GROUP:x:$APP_GID:|" /etc/group

# Remove PHP version from paths & executable
ARG BIN_DIR="/usr/bin"
ARG SBIN_DIR="/usr/sbin"
ARG PHP_DIR="/etc/php"
ARG PHP7_DIR="/etc/php7"
ARG LOG7_DIR="/var/log/php7"
ARG LOG_DIR="/var/log/php"
ARG INI_CONF="$PHP7_DIR/php.ini"
ARG FPM_CONF="$PHP7_DIR/php-fpm.conf"
ARG WWW_CONF="$PHP7_DIR/php-fpm.d/www.conf"
RUN sed -i "s|$PHP7_DIR|$PHP_DIR|" "$INI_CONF" && \
    sed -i "s|$PHP7_DIR|$PHP_DIR|" "$FPM_CONF" && \
    sed -i "s|$PHP7_DIR|$PHP_DIR|" "$WWW_CONF" && \
    sed -i "s|$LOG7_DIR|$LOG_DIR|" "$INI_CONF" && \
    sed -i "s|$LOG7_DIR|$LOG_DIR|" "$FPM_CONF" && \
    sed -i "s|$LOG7_DIR|$LOG_DIR|" "$WWW_CONF" && \
    mv "$PHP7_DIR" "$PHP_DIR" && \
    ln -s "$PHP_DIR" "$PHP7_DIR" && \
    mv "$LOG7_DIR" "$LOG_DIR" && \
    ln -s "$LOG_DIR" "$LOG7_DIR" && \
    mv "$SBIN_DIR/php-fpm7" "$SBIN_DIR/php-fpm" && \
    ln -s "$SBIN_DIR/php-fpm" "$SBIN_DIR/php-fpm7"

# Configuration
ARG SOCK7_DIR="/run/php7"
ARG SOCK_DIR="/run/php"
ARG INI_CONF="$PHP_DIR/php.ini"
ARG FPM_CONF="$PHP_DIR/php-fpm.conf"
ARG WWW_CONF="$PHP_DIR/php-fpm.d/www.conf"
RUN sed -i "s|^include_path|;include_path|" "$INI_CONF" && \
    sed -i "s|^;error_log[ =]\+php_errors\.log|error_log = $LOG_DIR/error\.log|" "$INI_CONF" && \
    sed -i "s|^;daemonize[ =].*|daemonize = no|" "$FPM_CONF" && \
    sed -i "s|^;log_level[ =].*|log_level = notice|" "$FPM_CONF" && \
    sed -i "s|^;access\.log[ =].*|access\.log = $LOG_DIR/access\.log|" "$WWW_CONF" && \
    sed -i "s|^user[ =].*|user = $APP_USER|" "$WWW_CONF" && \
    sed -i "s|^group[ =].*|group = $APP_GROUP|" "$WWW_CONF" && \
    sed -i "s|^;env\[PATH\]|env\[PATH\]|" "$WWW_CONF" && \
    sed -i "s|^;clear_env[ =].*|clear_env = no|" "$WWW_CONF" && \
    sed -i "s|^listen.*|listen = 9000\n;listen = $SOCK_DIR/php-fpm.sock|" "$WWW_CONF" && \
    sed -i "s|^;listen\.owner[ =].*|listen.owner = $APP_USER|" "$WWW_CONF" && \
    sed -i "s|^;listen\.group[ =].*|listen.group = $APP_GROUP|" "$WWW_CONF" && \
    sed -i "s|^;catch_workers_output[ =].*|catch_workers_output = yes|" "$WWW_CONF" && \
    sed -i "s|^;decorate_workers_output[ =].*|decorate_workers_output = no|" "$WWW_CONF"

# Volumes
ARG SRV_DIR="/srv"
RUN mkdir "$SOCK_DIR" && \
    ln -s "$SOCK_DIR" "$SOCK7_DIR" && \
    chmod 750 "$SOCK_DIR" && \
    chown -R "$APP_USER":"$APP_GROUP" "$SRV_DIR" "$SOCK_DIR" "$LOG_DIR"
VOLUME ["$SRV_DIR", "$SOCK_DIR" , "$LOG_DIR"]

#      PHP-FPM
EXPOSE 9000/tcp

WORKDIR "$SRV_DIR"
ENTRYPOINT ["php-fpm"]

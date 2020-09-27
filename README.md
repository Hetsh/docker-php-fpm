# PHP-FPM
Super small and easy to setup PHP FastCGI Process Manager.

## Running the server
```bash
docker run --detach --publish 9000:9000 --mount type=bind,source="/path/to/app",target="/path/to/app" --name php-fpm hetsh/php-fpm
```
The php source files of your app must to be mounted, so that FPM can access them.

## Stopping the container
```bash
docker stop php-fpm
```

## Configuration
Adjustments can be made via a custom `php.ini` file. It can be mounted readonly:
```bash
--mount type=bind,readonly,source="/path/to/php.ini",target="/etc/php7/php.ini"
```

## Automate startup and shutdown via systemd
The systemd unit can be found in my GitHub [repository](https://github.com/Hetsh/docker-php-fpm).
```bash
systemctl enable php-fpm.service --now
```
By default, the systemd service assumes `/srv` for website data and `/etc/localtime` for timezone.
Since this is a personal systemd unit file, you might need to adjust some parameters to suit your setup.

## Fork Me!
This is an open project (visit [GitHub](https://github.com/Hetsh/docker-php-fpm)).
Please feel free to ask questions, file an issue or contribute to it.
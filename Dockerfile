FROM alpine:3.7

ENV MOODLE_GIT_VERSION="MOODLE_34_STABLE"
ENV TIMEZONE="America/Sao_Paulo"

RUN apk update && apk upgrade

RUN apk --no-cache add \
bash \
openntpd \
tzdata \
git \
vim \
curl

RUN rm -f /etc/localtime && ln -fs /usr/share/zoneinfo/$TIMEZONE /etc/localtime

RUN apk --no-cache add \
apache2 \
php7 \
php7-apache2 \
php7-iconv \
php7-curl \
php7-mysqli \
php7-xml \
php7-gd \
php7-mbstring \
php7-xmlrpc \
php7-soap \
php7-intl 

RUN cd /var/www/localhost/htdocs/ && git clone -b $MOODLE_GIT_VERSION git://git.moodle.org/moodle.git --depth=1

RUN echo -e '<?php \nphpinfo(); \n?>' > /var/www/localhost/htdocs/phpinfo.php

RUN chown -R apache:apache /var/www/localhost/htdocs/ && chmod -R 755 /var/www/localhost/htdocs/

RUN mkdir /var/www/localhost/moodledata

RUN chown -R apache:apache /var/www/localhost/moodledata && chmod -R 755 /var/www/localhost/moodledata

RUN cp /usr/bin/php7 /usr/bin/php \
    && rm -f /var/cache/apk/*

RUN mkdir /run/apache2 

RUN echo -e '#!/bin/sh \nrm -rf /run/apache2/* /tmp/apache2* \nexec /usr/sbin/httpd -D FOREGROUND' > /usr/local/bin/docker-entrypoint.sh
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh

RUN ln -s usr/local/bin/docker-entrypoint.sh /

EXPOSE 80 443

VOLUME /var/www/localhost/moodledata

ENTRYPOINT ["docker-entrypoint.sh"]

HEALTHCHECK --interval=3m --timeout=30s CMD curl -f http://localhost/moodle || exit 1

FROM debian:bookworm-slim

LABEL maintainer="alufers <alufers@wp.pl>"

ARG PHORGE_SHA=226f3150933dfd735da17f19147e2648a5f54e63
ARG ARCANIST_SHA=788098096e113f34f0fafef23e4d16a2e80d64ca

ENV SSH_PORT=8022 
ENV GIT_USER=git 
ENV MYSQL_PORT=3306
ENV PROTOCOL=http

EXPOSE 8022 80 443

# TODO: Once Phorge is updated to support PHP 8.0, 
# we can use PHP from debian repo instead of sury.org

RUN apt-get update -y && apt-get install -y wget lsb-release && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" >> /etc/apt/sources.list.d/php.list && \
    apt-get update -y && \
    apt-get -y install \
    mercurial subversion sudo apt-transport-https ca-certificates wget git \
    php7.4 php7.4-mysql php7.4-gd php7.4-curl php7.4-apcu php7.4-cli php7.4-json php7.4-mbstring php7.4-fpm php7.4-zip php-pear \
    nginx supervisor procps python3-pygments imagemagick curl

RUN mkdir -p /var/www/phorge/phorge \
    mkdir -p /var/www/phorge/arcanist \
    && cd /var/www/phorge/phorge && git init \
    && git remote add origin https://we.phorge.it/source/phorge.git \
    && git fetch --depth=1 origin $PHORGE_SHA \
    && git checkout FETCH_HEAD \
    && cd /var/www/phorge/arcanist && git init \
    && git remote add origin https://we.phorge.it/source/arcanist.git \
    && git fetch --depth=1 origin master \
    && git checkout FETCH_HEAD


# #copy nginx config
COPY ./configs/nginx-ph.conf /etc/nginx/sites-available/phorge.conf
COPY ./configs/nginx.conf /etc/nginx/nginx.conf
# add phorge to nginx sites-enabled and remove default
RUN ln -s /etc/nginx/sites-available/phorge.conf /etc/nginx/sites-enabled/phorge.conf \
    && rm /etc/nginx/sites-enabled/default


#copy php config
COPY ./configs/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY ./configs/php.ini /etc/php/7.4/fpm/php.ini
COPY ./configs/php-fpm.conf /etc/php/7.4/fpm/php-fpm.conf

#copy supervisord config
COPY ./configs/supervisord.conf /etc/supervisord.conf
COPY ./scripts/startup.sh /startup.sh

RUN mkdir -p /run/php && chown www-data:www-data /run/php \
    && chmod +x /startup.sh

# #copy startup script
RUN mkdir -p /var/repo/ && rm -rf /var/cache/apt
CMD [ "/startup.sh" ]

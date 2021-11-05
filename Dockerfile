FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN set -x; buildDeps='vim wget curl git nginx  php7.4 php7.4-fpm php7.4-cli php7.4-mysql php7.4-curl php7.4-json php7.4-common php7.4-opcache php7.4-mbstring php7.4-zip php7.4-xml php-pear php7.4-dev php7.4-gd zlib1g-dev' \
    && sed -i s/archive.ubuntu.com/mirrors.aliyun.com/g /etc/apt/sources.list \
    && sed -i s/security.ubuntu.com/mirrors.aliyun.com/g /etc/apt/sources.list \
    && apt-get clean  \
    && apt-get update \
    && apt-get install -y $buildDeps \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
  
COPY nginx.default.conf /etc/nginx/sites-available/
COPY plug.vim  ~/.vim/autoload/
 
RUN set -x; ln -s /etc/nginx/sites-available/nginx.default.conf /etc/nginx/sites-enabled/ \
    && pecl channel-update pecl.php.net \
    && mkdir -p /tmp/pear/cache \
    && pecl install redis \
    && echo "extension=redis.so" | tee -a /etc/php/7.4/*/php.ini \
    && printf "yes\n" | pecl install xlswriter \
    && echo "extension=xlswriter.so" | tee -a /etc/php/7.4/*/php.ini \
    && printf "yes\n" | pecl install  swoole\
    && echo "extension=swoole.so" | tee -a /etc/php/7.4/cli/php.ini \
    && apt-get purge -y --auto-remove $buildDeps \
    && wget http://upos-sz-staticks3.bilivideo.com/appstaticboss/vim-vide-20200812.tgz && tar xvf ./vim-vide-20200812.tgz -C ~ 



WORKDIR /data/www

EXPOSE 8080

STOPSIGNAL SIGTERM

CMD ["sh","-c","/etc/init.d/php7.4-fpm start && nginx -g \"daemon off;\""]

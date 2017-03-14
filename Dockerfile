FROM python:3.5

# setup uWSGI
RUN pip install uwsgi


# setup NGINX
ENV NGINX_VERSION 1.11.10-1~jessie

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys ABF5BD827BD9BF62 \
	&& echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install -y ca-certificates nginx=${NGINX_VERSION} gettext-base \
	&& rm -rf /var/lib/apt/lists/*


# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log
EXPOSE 80 443


# make NGINX run in foreground
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
# update NGINX config
RUN rm /etc/nginx/conf.d/default.conf
# copy the modified Nginx conf
COPY docker-config/nginx.conf /etc/nginx/conf.d/
# copy uWSGI ini file to enable default dynamic uwsgi process number
COPY docker-config/uwsgi.ini /etc/uwsgi/

# install Supervisord
RUN apt-get update && apt-get install -y supervisor \
&& rm -rf /var/lib/apt/lists/*
# custom Supervisord config
COPY docker-config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord"]

# install flask
RUN pip install flask
# cofigure nginx for flask
COPY docker-config/nginx.conf /etc/nginx/conf.d

COPY ./app /app
WORKDIR /app

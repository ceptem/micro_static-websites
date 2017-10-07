FROM        nginx:latest
LABEL       maintainer="raphael@ceptem.com"
ADD         www /usr/share/nginx
ADD         conf /etc/nginx

FROM nginx:1.23-alpine

COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY ./index.html /var/www/index.html

CMD ["nginx", "-g", "daemon off;"]
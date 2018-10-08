FROM nginx:alpine
RUN mkdir -p "/var/www/staging/public" && mkdir -p "/var/www/prod/public"

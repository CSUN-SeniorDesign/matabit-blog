# nginx image built on top of alpine linux
FROM nginx:alpine

ARG BUILD_VAR

# Create environment folders and copy index file for test
RUN mkdir -p "/var/www/staging/matabit-blog/public" \
    && mkdir -p "/var/www/prod/matabit-blog/public" \
    && cp /usr/share/nginx/html/index.html \
       /var/www/prod/matabit-blog/public \
    && cp /usr/share/nginx/html/index.html \
        /var/www/staging/matabit-blog/public

# Copy content of public folder to docker image
COPY public /var/www/$BUILD_VAR/matabit-blog/public

# add custom nginx config
COPY nginx.template /etc/nginx/conf.d/default.conf

# expose port 80 for HTTP
EXPOSE 80
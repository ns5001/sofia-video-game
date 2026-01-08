FROM nginxinc/nginx-unprivileged:alpine
COPY game_source/build/web/ /usr/share/nginx/html/
EXPOSE 8080

FROM nginxinc/nginx-unprivileged:alpine
COPY delivery/game_source/build/web/ /usr/share/nginx/html/
EXPOSE 8080
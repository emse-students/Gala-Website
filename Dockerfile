# Gala website: static HTML served by nginx.
#
# Two stages. The first recompresses the images WITHOUT a visible change (PNG lossless through
# oxipng, JPEG capped at quality 85 through jpegoptim) so the repository keeps the originals and
# the image ships the small copies. The second is the server: nginx-unprivileged, so the container
# never runs as root.
FROM alpine:3.23 AS optimize
RUN apk add --no-cache oxipng jpegoptim
WORKDIR /site
COPY images ./images
RUN find images -name '*.png' -print0 | xargs -0 -n1 -P4 oxipng --opt 4 --strip safe --quiet \
 && find images -name '*.jpg' -print0 | xargs -0 jpegoptim --max=85 --strip-all --all-progressive --quiet \
 && du -sh images

FROM nginxinc/nginx-unprivileged:1.29-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY security-headers.conf /etc/nginx/security-headers.conf
COPY *.html style.css /usr/share/nginx/html/
COPY fonts /usr/share/nginx/html/fonts
COPY --from=optimize /site/images /usr/share/nginx/html/images
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/healthz || exit 1

# nginx/Dockerfile
FROM nginx:stable-alpine

COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf

# Copier les assets React buildés + public Laravel
COPY --from=builder /app/dist /var/www/html/react
COPY --from=backend /var/www/html/public /var/www/html/public

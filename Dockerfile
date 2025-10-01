FROM node:alpine AS build

COPY package.json package.json
RUN npm install
COPY . .
RUN npm run build

FROM nginx:stable-alpine

COPY --from=build /build /usr/share/nginx/build
# COPY --from=build /build /var/www/pp-maksim.ru/build
# COPY --from=build nginx.conf /etc/nginx/sites-available/pp-maksim.ru.conf
EXPOSE 3000
CMD [ "nginx", "-g", "daemon off;" ]
FROM node:alpine AS build

WORKDIR /app

COPY package.json package.json
RUN npm install
COPY . .
RUN npm run build

FROM nginx:stable-alpine

COPY --from=build /app/build /usr/share/nginx/html
# COPY --from=build /build /var/www/rsp/build
# COPY ./nginx/nginx.conf /etc/nginx/sites-available/rsp.conf

EXPOSE 3000
CMD [ "nginx", "-g", "daemon off;" ]
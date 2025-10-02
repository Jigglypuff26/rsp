FROM node:alpine AS build

WORKDIR /app

COPY package.json package.json
RUN npm install
COPY . .
RUN npm run build

FROM nginx:stable-alpine

COPY --from=build-stage /app/build /var/www/rsp/build
COPY ./nginx/nginx.conf /etc/nginx/sites-available/rsp.conf
# COPY --from=build /build /var/www/rsp/build
# COPY --from=build /nginx/nginx.conf /etc/nginx/sites-available/rsp.conf

EXPOSE 3000
CMD [ "nginx", "-g", "daemon off;" ]
FROM node:alpine AS build

COPY package.json package.json
RUN npm install
COPY . .
RUN npm run build

FROM nginx:stable-alpine

COPY --from=build /build /var/www/rsp/build
COPY --from=nginx nginx.conf /etc/nginx/sites-available/rsp.conf

EXPOSE 3000
CMD [ "nginx", "-g", "daemon off;" ]
FROM node:alpine AS build

WORKDIR /app

COPY package.json package.json
RUN npm install
COPY . .
RUN npm run build

FROM nginx:stable-alpine

COPY --from=build  --chmod=755 /app/build /var/www/rsp/build
COPY --from=build  --chmod=755 /app/nginx/nginx.conf /etc/nginx/sites-available/rsp.conf

EXPOSE 80
CMD [ "nginx", "-g", "daemon off;" ]
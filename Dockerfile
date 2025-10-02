FROM node:alpine AS BUILD_IMAGE

WORKDIR /app

COPY package.json package.json
RUN npm install
COPY . .
RUN npm run build

FROM nginx:stable-alpine

COPY --from=BUILD_IMAGE /app/dist /var/www/rsp/build
COPY --from=BUILD_IMAGE /app/nginx/nginx.conf /etc/nginx/sites-available/rsp.conf

EXPOSE 3000
CMD [ "nginx", "-g", "daemon off;" ]
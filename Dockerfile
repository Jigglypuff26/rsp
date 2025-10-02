FROM node:alpine AS build.image

WORKDIR /app

COPY package.json package.json
RUN npm install
COPY . .
RUN npm run build

FROM nginx:stable-alpine

RUN echo "fooo" > ${HOME}/test.txt

COPY --from=build.image /app/build /var/www/rsp/build
COPY --from=build.image /app/nginx/nginx.conf /etc/nginx/sites-available/rsp.conf

EXPOSE 3000
CMD [ "nginx", "-g", "daemon off;" ]
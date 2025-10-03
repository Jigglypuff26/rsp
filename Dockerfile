# =====================
FROM node:alpine AS build-rsp

WORKDIR /app

COPY package.json package.json
RUN npm install
COPY . .
RUN npm run build

FROM nginx:stable-alpine

COPY --from=build-rsp /app/build /usr/share/nginx/html
COPY --from=build-rsp /app/nginx/rsp.conf /etc/nginx/sites-available/rsp.conf

# EXPOSE 80
EXPOSE 443
CMD [ "nginx", "-g", "daemon off;" ]
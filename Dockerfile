FROM node:alpine AS build

WORKDIR /app
COPY package.json package.json
RUN npm install
COPY . .
RUN npm run build

# production environment
FROM nginx:stable-alpine
COPY --from=build /app/build /var/www/rsp/build
COPY --from=build /app/nginx/nginx.conf /etc/nginx/sites-available/rsp.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

# =====================
# FROM node:alpine AS build

# WORKDIR /app

# COPY package.json package.json
# RUN npm install
# COPY . .
# RUN npm run build

# FROM nginx:stable-alpine

# COPY --from=build /app/build /var/www/rsp/build
# COPY --from=build /app/nginx/nginx.conf /etc/nginx/sites-available/rsp.conf

# EXPOSE 80
# CMD [ "nginx", "-g", "daemon off;" ]
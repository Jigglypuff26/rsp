
# Use Node.js image to build the React app
FROM node:alpine AS build

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the entire project
COPY . .

# Build the React app
RUN npm run build

# Use Nginx to serve the build files
FROM nginx:alpine

# Copy the built files from the previous step
COPY --from=build /app/build /usr/share/nginx/html
COPY --from=build /app/nginx/nginx.conf /etc/nginx/sites-available/rsp.conf

# Copy the custom Nginx configuration
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 3000
EXPOSE 3000

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

# FROM node:alpine AS build

# WORKDIR /app

# COPY package.json package.json
# RUN npm install
# COPY . .
# RUN npm run build

# FROM nginx:stable-alpine

# COPY --from=build /app/build /var/www/rsp/build
# COPY --from=build /app/nginx/nginx.conf /etc/nginx/sites-available/rsp.conf

# EXPOSE 3000
# CMD [ "nginx", "-g", "daemon off;" ]
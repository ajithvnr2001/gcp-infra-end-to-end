# Use lightweight NGINX Alpine image
FROM nginx:alpine

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy frontend code to nginx directory
COPY index.html /usr/share/nginx/html/
COPY index.css /usr/share/nginx/html/
COPY app.js /usr/share/nginx/html/

# Expose port (Nginx default is 80)
EXpose 80

CMD ["nginx", "-g", "daemon off;"]

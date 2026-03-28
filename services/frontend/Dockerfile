# Use unprivileged NGINX Alpine image for GKE Autopilot compliance
FROM nginxinc/nginx-unprivileged:alpine

# The unprivileged image runs as non-root user and serves on 8080

# Copy frontend code to nginx directory (path is slightly different or same)
COPY index.html /usr/share/nginx/html/
COPY index.css /usr/share/nginx/html/
COPY app.js /usr/share/nginx/html/

# Expose port (Nginx unprivileged default is 8080)
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]

# Multi-stage build for React frontend
FROM node:20-alpine AS build
WORKDIR /app

# Copy package files
COPY vite-project/package*.json ./

# Install dependencies (use npm install due to lock file sync issues)
RUN npm install

# Copy source code
COPY vite-project/ ./

# Build for production
RUN npm run build

# Production stage with nginx
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# Remove default nginx static assets
RUN rm -rf ./*

# Copy built assets from build stage
COPY --from=build /app/dist .

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/health || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

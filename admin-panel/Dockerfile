FROM node:22-alpine AS build

WORKDIR /app

COPY admin-panel/package.json admin-panel/package-lock.json ./
RUN npm ci

COPY admin-panel/ ./

# The panel and the API share one origin behind nginx, so a relative base URL
# avoids CORS and survives a change of host or NodePort.
ARG VITE_API_BASE_URL=/api/
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL

RUN npm run build

FROM nginx:1.27-alpine

COPY admin-panel/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
COPY get-token.html /usr/share/nginx/html/get-token.html

EXPOSE 80

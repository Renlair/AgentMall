FROM --platform=$BUILDPLATFORM node:22-alpine AS build
WORKDIR /build
COPY vue/package*.json ./
RUN npm ci
COPY vue/ ./
ENV VITE_BASE_URL=/api
RUN npm run build

FROM nginx:stable-alpine
COPY --from=build /build/dist /usr/share/nginx/html
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80

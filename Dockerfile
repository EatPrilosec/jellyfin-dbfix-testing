# syntax=docker/dockerfile:1

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY source/ .

RUN dotnet restore Jellyfin.sln
RUN dotnet publish Jellyfin.Server/Jellyfin.Server.csproj \
    -c Release \
    -r linux-x64 \
    --self-contained true \
    -p:PublishTrimmed=false \
    -o /app/publish

FROM node:24-alpine AS web-build
WORKDIR /web
RUN apk add --no-cache wget
RUN wget -q https://github.com/jellyfin/jellyfin-web/archive/master.tar.gz -O - | tar xz --strip-components=1

RUN npm ci
RUN npm run build:production

FROM jellyfin/jellyfin:latest AS runtime

# Copy the forked Jellyfin runtime output into the official Jellyfin container base.
# This preserves the official image filesystem, environment, entrypoint, and web assets.
COPY --from=build /app/publish /jellyfin

# Replace web assets with the latest from master branch
COPY --from=web-build /web/dist /jellyfin/jellyfin-web

RUN chmod +x /jellyfin/jellyfin || true

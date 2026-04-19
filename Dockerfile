# syntax=docker/dockerfile:1

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY source/ .

RUN dotnet restore Jellyfin.sln
RUN dotnet publish Jellyfin.Server/Jellyfin.Server.csproj \
    -c Release \
    -r linux-x64 \
    --self-contained false \
    -p:PublishTrimmed=false \
    -o /app/publish

FROM mcr.microsoft.com/dotnet/runtime:10.0 AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      libfontconfig1 \
      libglib2.0-0 \
      libgdk-pixbuf2.0-0 \
      libx11-6 \
      libxkbcommon0 \
      libxcb1 \
      libxrender1 \
      libxi6 \
      libxrandr2 \
      libasound2t64 \
      libnss3 \
      libxcomposite1 \
      libxdamage1 \
      libxfixes3 \
      libxext6 \
      libatk1.0-0 \
      libcairo2 \
      libpango-1.0-0 \
      libxss1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app/publish .

ENV JELLYFIN_HOME=/config
ENV JELLYFIN_CACHE=/cache
ENV ASPNETCORE_URLS=http://+:8096

VOLUME /config /cache
EXPOSE 8096
ENTRYPOINT ["dotnet", "Jellyfin.Server.dll"]

FROM maven:3.5.4-jdk-8-alpine AS builder
COPY pom.xml .
COPY src src/
RUN mvn install -DskipTests

FROM open-liberty as server-setup
COPY --from=builder /target/LibertyProject.zip /config/
USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip \
    && unzip /config/LibertyProject.zip \
    && mv /wlp/usr/servers/sampleAppServer/* /config/ \
    && rm -rf /config/wlp \
    && rm -rf /config/LibertyProject.zip 

FROM open-liberty
LABEL maintainer="Graham Charters" vendor="IBM" github="https://github.com/WASdev/ci.maven"
COPY --chown=1001:0 --from=server-setup /config/ /config/
# user.dir environment variable is /opt/ol/wlp/output/defaultServer/resources/
COPY resources /opt/ol/wlp/output/defaultServer/resources/
EXPOSE 9080 9443
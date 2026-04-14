# =========================
# STAGE 1: BUILD PLUGINS
# =========================
FROM gradle:8.7-jdk21 AS builder

WORKDIR /app
COPY . .

RUN gradle clean preparePlugins


# =========================
# STAGE 2: KAFKA CONNECT
# =========================
FROM confluentinc/cp-kafka-connect:7.6.0

USER root

# copy plugins
COPY --from=builder /app/build/plugins-expanded /usr/share/java/plugins

# permissions
RUN chown -R appuser:appuser /usr/share/java/plugins

USER appuser

# config
ENV CONNECT_PLUGIN_PATH="/usr/share/java,/usr/share/java/plugins"

ENV CONNECT_BOOTSTRAP_SERVERS=localhost:9092
ENV CONNECT_GROUP_ID=connect-cluster

ENV CONNECT_CONFIG_STORAGE_TOPIC=connect-configs
ENV CONNECT_OFFSET_STORAGE_TOPIC=connect-offsets
ENV CONNECT_STATUS_STORAGE_TOPIC=connect-status

EXPOSE 8083
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
# These environment variables are now managed via Kubernetes ConfigMap for easier deployment.
# See k8s-configmap.yaml for details.
ENV CONNECT_PLUGIN_PATH="/usr/share/java,/usr/share/java/plugins"

EXPOSE 8083
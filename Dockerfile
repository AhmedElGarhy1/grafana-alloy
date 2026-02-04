# Grafana Alloy - minimal image with bundled config
FROM grafana/alloy:latest

COPY config.alloy /etc/alloy/config.alloy
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Alloy UI (Railway sets PORT; locally use ALLOY_PORT or 12345)
# 3500 = Loki push API (for log ingestion)
EXPOSE 12345 3500

ENTRYPOINT ["/entrypoint.sh"]

FROM nousresearch/hermes-agent:latest

ENV HERMES_DASHBOARD=1 \
    HERMES_DASHBOARD_HOST=0.0.0.0 \
    HERMES_DASHBOARD_PORT=9119

EXPOSE 9119

# Readiness probe. Hermes boots slowly (s6 init + skill sync), so during a
# redeploy the dashboard isn't listening for ~1-2 min. This HEALTHCHECK lets
# Coolify keep the OLD container serving until the NEW one is healthy, avoiding
# the 502 Bad Gateway window on every deploy.
HEALTHCHECK --interval=15s --timeout=5s --start-period=150s --retries=6 \
  CMD curl -fsS -o /dev/null http://127.0.0.1:9119/login || exit 1

CMD ["gateway", "run"]

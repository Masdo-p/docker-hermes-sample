FROM nousresearch/hermes-agent:latest
ENV HERMES_DASHBOARD=1 \
    HERMES_DASHBOARD_HOST=0.0.0.0 \
    HERMES_DASHBOARD_PORT=9119
EXPOSE 9119
CMD ["gateway", "run"]

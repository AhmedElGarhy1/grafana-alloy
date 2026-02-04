# Grafana Alloy (Docker)

Minimal [Grafana Alloy](https://grafana.com/docs/alloy/latest/) setup for **metrics** (Prometheus → Grafana Cloud) and **logs** (Loki → Grafana Cloud). All settings are controlled via **environment variables** (no editing `config.alloy` for URLs or secrets).

## Quick start

1. Copy `.env.example` to `.env` and set all **required** variables (Grafana URLs, usernames, token, backend address).
2. Run:
   ```bash
   docker compose up -d
   ```
3. **Alloy UI**: `http://<your-server>:12345` (or `ALLOY_PORT` from `.env`).
4. **Loki push API**: `http://<your-server>:3500/loki/api/v1/push` (for sending logs from your apps).

## Environment variables (everything via env)

| Variable | Required | Description |
|----------|----------|-------------|
| `GRAFANA_PROMETHEUS_URL` | Yes | Grafana Cloud Prometheus remote-write URL (e.g. `https://prometheus-prod-XX-prod-eu-west-2.grafana.net/api/prom/push`). |
| `GRAFANA_PROMETHEUS_USERNAME` | Yes | Grafana Cloud Prometheus instance ID (number from Cloud console). |
| `GRAFANA_CLOUD_TOKEN` | Yes | Grafana Cloud API token (used for both Metrics and Loki). |
| `HESSITY_BACKEND_ADDRESS` | Yes | Backend to scrape for metrics: `host:port` (must expose `/metrics`). |
| `GRAFANA_LOKI_URL` | Yes | Grafana Cloud Loki push URL (e.g. `https://logs-prod-XXX.grafana.net/loki/api/v1/push`). |
| `GRAFANA_LOKI_USERNAME` | Yes | Grafana Cloud Loki instance ID (often same as Prometheus). |
| `ALLOY_PORT` | No | Port for Alloy UI (default `12345`). On Railway, use `PORT` (set by platform). |
| `LOKI_SOURCE_PORT` | No | Port for Loki push API (default `3500`). |

Use `.env` for local/docker-compose; use **Railway → Variables** for production.

## Loki (logs)

Alloy is configured to:

1. **Receive logs** on port **3500** via the Loki push API:
   - `POST /loki/api/v1/push` — Loki `logproto` format.
   - `POST /loki/api/v1/raw` — newline-delimited or NDJSON.
2. **Forward them** to Grafana Cloud Loki using `GRAFANA_LOKI_URL`, `GRAFANA_LOKI_USERNAME`, and `GRAFANA_CLOUD_TOKEN`.

From another service (e.g. your backend on Railway), send logs to:

- `http://<alloy-service-host>:3500/loki/api/v1/push` (same project: e.g. `http://alloy.railway.internal:3500/loki/api/v1/push`).

No config file changes needed—set `GRAFANA_LOKI_URL` and `GRAFANA_LOKI_USERNAME` in `.env` or Railway Variables.

## Files

| File | Purpose |
|------|--------|
| `Dockerfile` | Builds from `grafana/alloy`, bundles `config.alloy`. Exposes 12345 (UI) and 3500 (Loki API). |
| `config.alloy` | Metrics (scrape + remote_write) and Loki (source.api + write). All values from `sys.env(...)`. |
| `.env` | Local/Railway settings; not committed. Copy from `.env.example`. |
| `docker-compose.yml` | Runs Alloy with `.env`, ports 12345 and 3500. |

## Custom config on the host

To override the bundled config, uncomment the `config.alloy` volume in `docker-compose.yml` and edit `./config.alloy`. Restart with `docker compose up -d --force-recreate`.

## Deploy on Railway

1. Connect the repo and deploy. Railway will use the `Dockerfile` and set `PORT` for the Alloy UI. **Do not** set `PORT` in Variables.
2. In **Variables**, set all **required** env vars from the table above (Prometheus URL/username, Loki URL/username, `GRAFANA_CLOUD_TOKEN`, `HESSITY_BACKEND_ADDRESS`).
3. Other services in the same project can push logs to `http://<this-service>.railway.internal:3500/loki/api/v1/push`.

## Build and run without compose

```bash
docker build -t grafana-alloy:local .
docker run -d --name alloy \
  -p 12345:12345 -p 3500:3500 \
  -e GRAFANA_PROMETHEUS_URL=... \
  -e GRAFANA_PROMETHEUS_USERNAME=... \
  -e GRAFANA_CLOUD_TOKEN=... \
  -e HESSITY_BACKEND_ADDRESS=... \
  -e GRAFANA_LOKI_URL=... \
  -e GRAFANA_LOKI_USERNAME=... \
  grafana-alloy:local
```

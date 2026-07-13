# OPEN-PROM climate-model web app

This directory packages the climate assessment runner as a private Streamlit
service for a Linux Docker host connected to the organisation's VPN. It does not
run GAMS or the wider OPEN-PROM model; users upload the IAMC `emissions.csv`
produced by OPEN-PROM and download the climate-assessment workbook.

## Security model

The default Compose configuration publishes Streamlit only on host loopback
(`127.0.0.1:8501`). Put an authenticated TLS reverse proxy in front of it, or set
`STREAMLIT_BIND_ADDRESS` to the server's VPN-interface address if VPN membership
is the sole access control. Do not bind it to `0.0.0.0` on an internet-facing
host. The container runs as a non-root user, drops Linux capabilities, uses a
read-only root filesystem, and serialises assessments to avoid exhausting the
host.

Streamlit itself is not the authentication boundary. Authentication, TLS,
request-size limits, and access logging belong at the reverse proxy or company
identity-aware proxy.

## Required private asset

Obtain the full AR6 emissions infilling database used by your existing workflow
and place it on the Docker host, for example:

```text
/srv/climate-assets/infilling.csv
```

The small example infiller from climate-assessment is not selected automatically
because it is not appropriate for production assessments.

## Start CICERO-SCM

1. Install Docker Engine and the Docker Compose plugin on an internal Linux host.
2. Copy `.env.example` to `.env` and set `INFILLING_DATABASE_HOST` to the host
   path of the infilling database.
3. Build and run the app:

   ```bash
   docker compose build
   docker compose up -d
   docker compose logs -f climate-models
   ```

4. Connect through the VPN and reverse proxy, or browse to
   `http://<vpn-interface-ip>:8501` if `STREAMLIT_BIND_ADDRESS` was explicitly set
   to that VPN-interface IP.

The image pins `iiasa/climate-assessment` to release `v0.1.6`. Change
`CLIMATE_ASSESSMENT_REF` only after validating the workflow, because that project
documents its interfaces as subject to change.

## Enable MAGICC

MAGICC is deliberately not included in the image. After accepting the applicable
licence, store its Linux executable and probabilistic distribution under a
private host directory. Then:

1. Uncomment the two MAGICC volumes in `compose.yaml`.
2. Set all `MAGICC_*` values shown in `.env.example`.
3. Ensure the defaults have been copied into MAGICC's run directory as described
   by the climate-assessment documentation.
4. Recreate the service with `docker compose up -d --build`.

Never commit the MAGICC executable, probabilistic distribution, `.env`, uploaded
emissions, or generated workbooks.

## Operations

- Only one assessment is allowed at a time. Additional attempts receive a busy
  message instead of competing for CPU and memory.
- Jobs are stored in the `climate-jobs` Docker volume and removed after 24 hours
  by default. Set `JOB_RETENTION_HOURS` to match organisational retention rules.
- The default assessment timeout is four hours.
- Back up only outputs that must be retained; uploaded pathways may contain
  sensitive scenario information.

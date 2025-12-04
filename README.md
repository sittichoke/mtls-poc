# mTLS Proof of Concept

This project demonstrates a minimal mutual TLS (mTLS) setup. An Nginx gateway terminates HTTPS, enforces client certificate authentication, and forwards verified requests to a Go HTTP API container running inside the same Docker network.

## Architecture
- **Gateway**: `nginx:1.27.0-alpine` container listening on `8443` (host) -> `443` (container). Loads certificates from `./certs`, validates client certs, and forwards `X-SSL-Client-*` headers to the API.
- **API**: Simple Go service exposing `/hello` on port `8080`. Returns the forwarded client certificate metadata for visibility.
- **Certificates**: Generated locally via the scripts under `certs/` and bind-mounted into the gateway container.
- **Docs**: `documents/deployment.puml` contains a PlantUML deployment diagram matching the above components.

```
host
├── api/        # Go HTTP service and Dockerfile
├── nginx/      # Nginx reverse-proxy config
├── certs/      # TLS assets + helper scripts
├── docker-compose.yaml
├── curl_ok.bash / curl_failed.bash
└── documents/deployment.puml
```

## Prerequisites
- Docker Engine + Docker Compose plugin
- OpenSSL (used by the certificate helper scripts)
- `curl` (or another HTTPS client that can present a certificate)
- macOS / Linux shell (commands below use Bash syntax)

## 1. Generate certificates
All commands execute from the repository root unless specified.

```bash
cd certs
bash 1_create_root_ca.bash       # creates ca.key + ca.crt
bash 2_create_server_cert.bash   # creates server.* files signed by the CA
bash 3_create_client_cert.bash   # creates client.* files signed by the CA
cd -
```

(Optional) Trust `certs/ca.crt` in your OS keychain so browsers consider it valid.

## 2. Build and run the stack
```bash
docker compose pull gateway        # grabs the nginx base image
docker compose up --build -d
```

Key ports:
- `8443`: HTTPS endpoint that enforces mTLS
- `8080`: Internal API port (not published outside Docker)

View container status:
```bash
docker compose ps
docker compose logs -f gateway api
```

## 3. Verify mTLS behavior
Without a client cert the handshake fails:
```bash
bash ./curl_failed.bash
```

With the signed client cert/key the request succeeds:
```bash
bash ./curl_ok.bash
```

Successful responses look like:
```json
{
  "message": "Hello from Go API behind mTLS gateway",
  "client_subject": "CN=test-client,O=MyClient,ST=Bangkok,C=TH",
  "client_verify": "SUCCESS"
}
```

## Stopping everything
```bash
docker compose down
```

## Troubleshooting
- **Missing nginx image**: ensure `docker-compose.yaml` references an existing tag such as `nginx:1.27.0-alpine`, then rerun `docker compose pull gateway`.
- **Certificate verify failed**: confirm the host running `curl` uses `certs/client.crt` + `certs/client.key` signed by `certs/ca.crt`, and that the gateway volume mounts map the certs directory correctly.
- **Port already in use**: free `8443` or change the published port inside `docker-compose.yaml`.

## Next steps
- Import the PlantUML diagram (`documents/deployment.puml`) into any UML viewer if you need a visual overview.
- Update the Go API to use TLS end-to-end if you want fully encrypted service-to-service traffic.

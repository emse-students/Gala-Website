# Gala website

Static site for the Gala des Mines Saint-Etienne, served at https://gala.emse.fr.

## Deployment

A push to `main` runs `.github/workflows/deploy.yml`: GitHub builds the Docker image (images are
recompressed at build time, the originals stay in git), pushes it to
`ghcr.io/emse-students/gala-website`, and the `gala-ecole` self-hosted runner on the Portail-etu
host pulls it and restarts the container, published on `127.0.0.1:3002`. The host's nginx
(`gala.conf`) terminates TLS and proxies to it.

Pull requests only run `ci.yml` (build and answer every page); they never reach the host.

Repository variables: `GALA_RUNNER_LABEL` (`gala-ecole`), `GALA_DEPLOY_DIR` (`/srv/gala`).

Local preview: `docker build -t gala . && docker run --rm -p 8080:8080 gala`.

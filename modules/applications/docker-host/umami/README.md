# Umami with Docker Compose

A standalone Umami 3.5.0 and PostgreSQL 15 project. Docker Engine and Docker Compose
are sufficient; Nix is optional host integration.

## Start

Copy this directory to a writable directory on the target host. Create the private
environment file, then fill each empty secret with a different `openssl rand -hex 32`
value. Hex passwords are safe to interpolate into the PostgreSQL connection URL.
Set `UMAMI_BIND_IP` to the host's LAN address; Motherbase currently uses `192.168.5.153`.

```sh
cp .env.example .env
chmod 600 .env
# Edit .env before continuing.
docker compose config --quiet
docker compose up -d
docker compose ps
curl --fail http://motherbase.local:8989/api/heartbeat
```

Allow TCP 8989 from the LAN in the host firewall. The first login at
`http://motherbase.local:8989` is `admin` / `umami`; change the password immediately.
On another host, use its hostname or IP. The default bind address exposes port 8989
on all IPv4 interfaces, so set the LAN address before starting on a multi-interface host.
The database has no published port and uses an internal network.

On Nix-managed Motherbase, SOPS supplies the same environment variables through
`compose-umami.service`. The `/opt/umami` project directory is immutable; do not
create a `.env` there or manually start a second instance.

## Move to another host

Copy this directory and transfer `.env` securely, keeping its permissions and all
three secrets unchanged. For a Nix-managed source, obtain the environment file
from `systemctl show compose-umami -p EnvironmentFiles` and transfer it securely;
never commit it or paste its contents into logs. Change only `UMAMI_BIND_IP` on
the destination. Preserve the application and encryption secrets to retain sessions
and two-factor authentication data.

Stop application writes and export the database on the source. On Nix-managed
Motherbase, run these commands in a root shell with its EnvironmentFile loaded
and exported, so Compose receives the same variables as the systemd service.

```sh
docker compose stop umami
umask 077
docker compose exec -T db pg_dump -U umami -d umami -Fc > umami.dump
```

Transfer the dump securely. With a fresh database volume on the destination:

```sh
docker compose up -d --wait db
docker compose exec -T db pg_restore -U umami -d umami --no-owner --no-acl < umami.dump
docker compose up -d
docker compose ps
```

Verify the destination before retiring the source. If migration fails, restart the
source with `docker compose start umami`. Do not point two hosts at the same database.
The named volume is `umami_umami-db-data`; `docker compose down` preserves it,
while `docker compose down -v` deletes it. Back up before upgrading either image.

This endpoint uses HTTP on the LAN. Public HTTPS websites require an HTTPS tracker
endpoint reachable by their visitors.

Based on the [official Umami Compose project](https://github.com/umami-software/umami/blob/master/docker-compose.yml)
and [installation documentation](https://docs.umami.is/docs/install).

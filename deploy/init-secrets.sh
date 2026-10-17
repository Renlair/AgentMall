#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if [[ -e .env ]]; then
  echo '.env already exists; preserving it.'
  exit 0
fi
umask 077
{
  printf 'MYSQL_ROOT_PASSWORD=%s\n' "$(openssl rand -hex 24)"
  printf 'DB_PASSWORD=%s\n' "$(openssl rand -hex 24)"
  printf 'ADMIN_INITIAL_PASSWORD=%s\n' "$(openssl rand -hex 18)"
  printf 'BIND_ADDRESS=127.0.0.1\nHTTP_PORT=8080\n'
} > .env
echo 'Generated fresh secrets in .env (mode 600); values not printed.'

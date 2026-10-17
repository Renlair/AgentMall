#!/bin/bash
# Run once as root from this checked-out directory. Never prints private keys.
set -euo pipefail
umask 077
cd "$(dirname "$0")"
test "$(id -u)" = 0 || { echo 'Run as root'; exit 1; }
test -f /root/agentmall/.env
test -f /root/agentmall/compose.yaml
if ! getent passwd agentmall-ci >/dev/null; then
  useradd --system --home-dir /var/lib/agentmall-ci --shell /bin/bash agentmall-ci
fi
install -d -m 750 -o root -g agentmall-ci /var/lib/agentmall-ci /var/lib/agentmall-ci/.ssh
install -d -m 700 -o root -g root /var/lib/agentmall-deploy
install -m 755 -o root -g root receive-release.py /usr/local/sbin/agentmall-ci-deploy
key=/root/agentmall-ci-github-ed25519
if ! test -f "$key"; then
  ssh-keygen -q -t ed25519 -N '' -C agentmall-github-actions -f "$key"
fi
# The private key remains on the server for the owner to paste privately into GitHub Actions Secrets.
printf 'restrict,command="/usr/bin/sudo -n /usr/local/sbin/agentmall-ci-deploy" %s\n' "$(cat "$key.pub")" > /var/lib/agentmall-ci/.ssh/authorized_keys
chown root:agentmall-ci /var/lib/agentmall-ci/.ssh/authorized_keys
chmod 640 /var/lib/agentmall-ci/.ssh/authorized_keys
sudoers=$(mktemp)
trap 'rm -f "$sudoers"' EXIT
printf 'agentmall-ci ALL=(root) NOPASSWD: /usr/local/sbin/agentmall-ci-deploy ""\n' > "$sudoers"
visudo -cf "$sudoers" >/dev/null
install -m 440 -o root -g root "$sudoers" /etc/sudoers.d/agentmall-ci
python3 - <<'PY'
p='/usr/local/sbin/agentmall-ci-deploy'
compile(open(p).read(),p,'exec')
PY
printf 'Restricted deployment account installed. Private key saved root-only; no secrets printed.\n'

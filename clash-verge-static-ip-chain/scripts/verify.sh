#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <expected-public-ip>" >&2
  exit 64
fi

expected_ip="$1"
controller_socket="/var/run/clash-verge-service/users/$(id -u)/verge-mihomo.sock"
failures=0

check_equal() {
  local label="$1"
  local actual="$2"
  if [[ "$actual" == "$expected_ip" ]]; then
    printf 'PASS %-24s %s\n' "$label" "$actual"
  else
    printf 'FAIL %-24s expected=%s actual=%s\n' "$label" "$expected_ip" "${actual:-<empty>}"
    failures=$((failures + 1))
  fi
}

if [[ -S "$controller_socket" ]]; then
  config_json="$(curl --silent --show-error --max-time 5 \
    --unix-socket "$controller_socket" http://localhost/configs)"
  tun_state="$(python3 -c 'import json,sys; print(str(json.load(sys.stdin).get("tun",{}).get("enable",False)).lower())' <<<"$config_json")"
  if [[ "$tun_state" == "true" ]]; then
    echo "PASS TUN enabled"
  else
    echo "FAIL TUN is disabled; full-device routing is not active"
    failures=$((failures + 1))
  fi
else
  echo "FAIL Mihomo controller socket not found: $controller_socket"
  failures=$((failures + 1))
fi

unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY

endpoints=(
  "https://api.ipify.org"
  "https://ifconfig.me/ip"
  "https://icanhazip.com"
)

for endpoint in "${endpoints[@]}"; do
  actual="$(curl -4 --silent --show-error --location --max-time 20 "$endpoint" | tr -d '\r\n[:space:]' || true)"
  check_equal "$endpoint" "$actual"
done

google_status="$(curl -4 --silent --show-error --location --max-time 20 \
  --output /dev/null --write-out '%{http_code}' https://www.google.com/generate_204 || true)"
if [[ "$google_status" == "204" ]]; then
  echo "PASS Google connectivity       HTTP 204"
else
  echo "FAIL Google connectivity       HTTP ${google_status:-000}"
  failures=$((failures + 1))
fi

ip_site_status="$(curl -4 --silent --show-error --location --max-time 20 \
  --output /dev/null --write-out '%{http_code}' https://ip.me || true)"
if [[ "$ip_site_status" =~ ^(2|3)[0-9][0-9]$ ]]; then
  echo "PASS ip.me reachability        HTTP $ip_site_status"
else
  echo "FAIL ip.me reachability        HTTP ${ip_site_status:-000}"
  failures=$((failures + 1))
fi

if (( failures > 0 )); then
  echo "Verification failed: $failures check(s) did not pass." >&2
  exit 1
fi

echo "Verification passed: full-device egress is $expected_ip."


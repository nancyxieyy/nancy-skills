# Troubleshooting

## Public IP is the access network's IP

- TUN is off, or the app bypasses macOS system proxy settings.
- Enable TUN and retest without `curl -x`.
- Verify `auto-route` and `auto-detect-interface` in the running config, not only the UI.

## Public IP is a subscription-node IP

- The entry group is selecting a normal node rather than the static proxy.
- A rule may bypass the intended entry group.
- Inspect the live controller's `now` value for the rule-entry group and test in Global mode only as a diagnostic.

## Static proxy works at the office but not at home or on mobile data

- The access network may not reach the proxy directly.
- Add `dialer-proxy: <UPSTREAM_GROUP>` so the static connection is established through a working subscription node.
- Verify the upstream group contains no static proxy; otherwise the config can recurse.

## `ERR_CONNECTION_CLOSED`

- Check for an HTTP-versus-SOCKS5 protocol mismatch first.
- Test credentials and endpoint availability without logging the secrets.
- Inspect Clash logs for authentication failures, timeouts, and recursive dialer errors.

## `127.0.0.1:<port>/callback` is refused

- This is a local OAuth callback, unrelated to the public exit IP.
- Confirm the app that initiated login is still open and listening on that exact port.
- Restart login from the originating app and use the newly generated callback. Do not reuse or share the old callback URL.
- Keep `127.0.0.1`, `localhost`, and `::1` local.

## A site returns HTTP 403

- A completed TLS connection followed by 403 proves the route reached the site.
- The block can be caused by bot protection, account policy, shared-IP reputation, or geography.
- Test in a normal browser and inspect the rendered challenge. Do not mislabel 403 as a broken proxy.

## Multiple computers use one static account

- The proxy provider may enforce one active session, source-IP binding, or a concurrency limit.
- Test two devices at the same time or ask the provider. Do not infer unlimited sharing because one friend can connect.
- Even when concurrent connections work, websites may flag several users sharing one identity-bearing IP.

## Subscription refresh removes the static proxy

- A raw edit was made to generated YAML.
- Move the custom proxy into a Clash Verge Enhancement/Merge script attached to the subscription, reload, and verify the live config again.


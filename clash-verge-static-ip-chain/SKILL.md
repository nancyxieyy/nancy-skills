---
name: clash-verge-static-ip-chain
description: Configure, repair, or verify a persistent two-hop static-egress setup in Clash Verge Rev on macOS, combining a user's own subscription node with an authenticated static HTTP/SOCKS proxy and a single TUN on/off switch. Use when the user needs the same public IP across home, office, or phone-hotspot networks, or when a direct static proxy works on one access network but not another.
---

# Clash Verge static-IP chain

Build this route on macOS:

`Mac -> user's subscription node/group -> authenticated static proxy -> Internet`

The subscription node supplies reachability; the final proxy supplies the public IP. The result is not valid until an IP check reports the static proxy's IP without an explicit `curl -x` argument.

## Required inputs

Collect these without repeating secrets in chat or command output:

- Clash Verge Rev already installed, or permission to install it.
- User-owned subscription URL.
- Static proxy host, port, protocol, username, and password.
- Expected public exit IP.

Never commit subscription tokens, proxy credentials, callback codes, generated runtime configs, or screenshots containing them. Use placeholders in reusable artifacts. Do not assume a vendor's UI protocol label is correct; verify HTTP and SOCKS5 behavior when necessary.

## Workflow

1. Inspect the existing Clash Verge configuration and preserve unrelated profiles/settings. Back up any file that must be edited.
2. Confirm the subscription alone reaches the Internet and identify:
   - an upstream group that chooses only subscription nodes, such as `自动选择`;
   - the entry group used by rules, often `SELECT`.
3. Read [references/deployment.md](references/deployment.md) and install the static proxy with `dialer-proxy` pointing to the upstream group. Never point `dialer-proxy` to a group that contains the static proxy itself; that creates a loop.
4. Put the generated proxy in the entry group and select it. Prefer an Enhancement/Merge script attached to the subscription so subscription refreshes do not erase the static proxy.
5. For full-device behavior, enable `虚拟网卡模式` (TUN), keep `auto-route` and `auto-detect-interface` enabled, and turn off the redundant macOS `系统代理`. This makes the TUN switch the single user-facing on/off control.
6. Keep localhost and private networks local. A refused `127.0.0.1:<port>/callback` means the initiating app is not listening; it is not evidence that the proxy chain failed.
7. Run `scripts/verify.sh <EXPECTED_IP>`. Also inspect the running controller state and test normal browsing. A site returning HTTP 403 after a successful TLS connection is application-layer blocking or bot protection, not a transport failure.
8. If any invariant fails, read [references/troubleshooting.md](references/troubleshooting.md), repair, and rerun the verification.

## Completion criteria

Report completion only when all of these are true:

- The running Mihomo config shows TUN enabled.
- The static proxy is alive and its `dialer-proxy` resolves to a subscription-only group.
- The rule-entry group currently selects the static proxy.
- At least three independent public-IP endpoints report the expected static IP with no explicit proxy flag.
- Google connectivity succeeds and at least one normal IP-information site loads.
- `127.0.0.1` and `localhost` remain local.
- The enhancement survives a subscription refresh or its persistence mechanism is otherwise demonstrated.

If the provider limits simultaneous sessions, do not claim that one static-proxy account supports multiple computers. Test concurrency or ask the provider; sharing one exit IP may also trigger account or website risk controls.


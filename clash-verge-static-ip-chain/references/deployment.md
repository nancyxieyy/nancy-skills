# Deployment procedure

Use this procedure for Clash Verge Rev on macOS. UI labels may differ slightly by version.

## 1. Preflight

1. Record the installed app and Mihomo versions.
2. Confirm the user's subscription works by itself on the current access network.
3. Identify the current profile and its proxy groups from the live controller when possible. The usual controller socket is:

   ```text
   /var/run/clash-verge-service/users/<UID>/verge-mihomo.sock
   ```

4. Locate, but do not print, the profile directory. A common location is:

   ```text
   ~/Library/Application Support/io.github.clash-verge-rev.clash-verge-rev/profiles
   ```

5. Back up only the file being changed. Do not copy credentials into the repository, a transcript, or a shell history entry.

## 2. Determine the two groups

Choose two distinct roles:

- `UPSTREAM_GROUP`: contains only the user's ordinary subscription nodes and can automatically choose a working transport node.
- `ENTRY_GROUP`: receives rule traffic and allows the user to select the static proxy.

For example, `自动选择` can be the upstream group and `SELECT` the entry group. The same group must not fill both roles if adding the static proxy to it would make the static proxy dial through itself.

## 3. Verify the static proxy protocol

Do not trust the vendor label blindly. Test the endpoint through a known-working subscription path when direct access varies by network. Avoid putting credentials directly on a shared command line or in committed files.

Useful interpretations:

- HTTP proxy succeeds: use `type: http`.
- SOCKS5 succeeds: use `type: socks5`.
- TCP connection succeeds but requests close immediately: often a protocol mismatch.
- Direct static proxy works at the office but fails at home/mobile: use `dialer-proxy` through the subscription group.

## 4. Install a persistent enhancement

Start from [../assets/enhancement-template.js](../assets/enhancement-template.js). Substitute the local values only in the user's Clash profile or in Clash Verge's Enhancement editor. Do not substitute real secrets in the repository copy.

The important invariant is:

```yaml
dialer-proxy: <UPSTREAM_GROUP>
```

The script must add the static proxy to `ENTRY_GROUP`, while `UPSTREAM_GROUP` must remain free of that static proxy. If the subscription uses different names, adapt the constants after inspecting the live profile rather than guessing.

After applying the enhancement, reload the subscription/profile and verify the generated runtime configuration through the controller API. Do not expose the runtime YAML because it contains credentials.

## 5. Select the egress

In Clash Verge:

1. Select the static proxy in the entry group used by rules.
2. If the UI exposes `GLOBAL`, ensure it does not point somewhere unexpected; selecting the static proxy there is useful for global-mode tests.
3. Keep Rule mode when local/private resources must remain reachable. Confirm that ordinary public traffic ultimately enters the selected entry group.

## 6. Make one on/off switch

On the Clash Verge home screen:

1. Open `虚拟网卡模式`.
2. Enable TUN.
3. Confirm the live config shows:
   - `tun.enable: true`
   - `tun.auto-route: true`
   - `tun.auto-detect-interface: true`
4. Open `系统代理` and disable it. TUN already captures traffic, and leaving both enabled creates two controls with confusing state.

The user's normal control is now:

- TUN on: fixed public exit through the chain.
- TUN off: normal access-network routing.

Because TUN auto-detects the physical interface, this works when switching among Wi-Fi, company networks, and a phone hotspot. USB tethering or managed corporate security software can impose additional routing restrictions and must be tested separately.

## 7. Validate

Run:

```bash
./scripts/verify.sh <EXPECTED_STATIC_IP>
```

Then manually confirm:

- the browser opens an IP-information site and shows the same IP;
- required foreign sites load;
- a local OAuth callback still reaches the originating app while that app is actively listening;
- turning TUN off restores the ordinary public IP, and turning it back on restores the static IP.

Never reuse an OAuth callback URL: its code is normally short-lived and one-time.


// Clash Verge Rev enhancement template.
// Replace placeholders only in the user's local profile/editor.
// Never commit subscription tokens or proxy credentials.

function main(config, profileName) {
  const STATIC_NAME = "<STATIC_PROXY_NAME>";
  const STATIC_TYPE = "socks5"; // Change to "http" only after protocol verification.
  const STATIC_SERVER = "<STATIC_HOST>";
  const STATIC_PORT = 443;
  const STATIC_USERNAME = "<STATIC_USERNAME>";
  const STATIC_PASSWORD = "<STATIC_PASSWORD>";

  // These must be different roles. UPSTREAM_GROUP must not contain STATIC_NAME.
  const UPSTREAM_GROUP = "<UPSTREAM_SUBSCRIPTION_GROUP>";
  const ENTRY_GROUP = "<RULE_ENTRY_GROUP>";

  config.proxies = Array.isArray(config.proxies) ? config.proxies : [];
  config["proxy-groups"] = Array.isArray(config["proxy-groups"])
    ? config["proxy-groups"]
    : [];

  config.proxies = config.proxies.filter((proxy) => proxy.name !== STATIC_NAME);
  config.proxies.push({
    name: STATIC_NAME,
    type: STATIC_TYPE,
    server: STATIC_SERVER,
    port: STATIC_PORT,
    username: STATIC_USERNAME,
    password: STATIC_PASSWORD,
    "dialer-proxy": UPSTREAM_GROUP,
  });

  const upstream = config["proxy-groups"].find(
    (group) => group.name === UPSTREAM_GROUP && Array.isArray(group.proxies),
  );
  if (!upstream) {
    throw new Error(`Upstream group not found: ${UPSTREAM_GROUP}`);
  }
  if (upstream.proxies.includes(STATIC_NAME)) {
    throw new Error("Refusing recursive chain: upstream group contains static proxy");
  }

  const entry = config["proxy-groups"].find(
    (group) => group.name === ENTRY_GROUP && Array.isArray(group.proxies),
  );
  if (!entry) {
    throw new Error(`Entry group not found: ${ENTRY_GROUP}`);
  }
  if (!entry.proxies.includes(STATIC_NAME)) {
    entry.proxies.push(STATIC_NAME);
  }

  return config;
}


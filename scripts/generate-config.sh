#!/bin/sh
# Generates OpenWrt config files from environment variables (GitHub Secrets).
# Called during CI before image build.

set -e

FILES_DIR="${1:-files}"

mkdir -p "$FILES_DIR/etc/config"
mkdir -p "$FILES_DIR/etc/uci-defaults"

# ── Wireless ──────────────────────────────────────────────────────────────────
cat > "$FILES_DIR/etc/config/wireless" << EOF
config wifi-device 'radio0'
	option type 'mac80211'
	option path 'platform/soc/18000000.wifi'
	option band '2g'
	option htmode 'HE20'
	option channel '1'
	option country 'RU'
	option cell_density '0'

config wifi-iface 'default_radio0'
	option device 'radio0'
	option network 'lan'
	option mode 'ap'
	option ssid '${WIFI_SSID}'
	option encryption 'psk2'
	option key '${WIFI_PASSWORD}'

config wifi-device 'radio1'
	option type 'mac80211'
	option path 'platform/soc/18000000.wifi+1'
	option band '5g'
	option htmode 'VHT80'
	option channel '36'
	option country 'RU'
	option cell_density '0'

config wifi-iface 'default_radio1'
	option device 'radio1'
	option network 'lan'
	option mode 'ap'
	option ssid '${WIFI_SSID}'
	option encryption 'psk2'
	option key '${WIFI_PASSWORD}'

config wifi-iface 'wifinet2'
	option device 'radio1'
	option network 'wwan'
	option mode 'sta'
	option ssid '${WWAN_SSID}'
	option encryption 'psk2'
	option key '${WWAN_PASSWORD}'
EOF

# ── Network (LAN + WWAN) ──────────────────────────────────────────────────────
cat > "$FILES_DIR/etc/config/network" << EOF
config interface 'loopback'
	option device 'lo'
	option proto 'static'
	option ipaddr '127.0.0.1'
	option netmask '255.0.0.0'

config device
	option name 'br-lan'
	option type 'bridge'
	list ports 'lan1'
	list ports 'lan2'
	list ports 'lan3'

config interface 'lan'
	option device 'br-lan'
	option proto 'static'
	option ipaddr '192.168.2.1'
	option netmask '255.255.255.0'

config interface 'wan'
	option device 'wan'
	option proto 'dhcp'

config interface 'wan6'
	option device 'wan'
	option proto 'dhcpv6'

config interface 'wwan'
	option proto 'dhcp'
EOF

# ── Root password + LuCI theme (runs on first boot) ──────────────────────────
PASSWD_HASH=$(openssl passwd -6 "${ROOT_PASSWORD}")

cat > "$FILES_DIR/etc/uci-defaults/99-24spark" << EOF
#!/bin/sh

# Set root password
echo "root:${PASSWD_HASH}" | chpasswd -e

# Set 24spark as default LuCI theme
uci set luci.main.mediaurlbase='/luci-static/24spark'
uci commit luci

# Set hostname
uci set system.@system[0].hostname='24spark-router'
uci commit system

# Disable IPv6 RA warnings (no upstream IPv6)
uci set dhcp.odhcpd.maindhcp='0'
uci commit dhcp

# Enable zram-swap (64 MB compressed) so LuCI can start alongside sing-box
if [ -f /etc/init.d/zram-swap ]; then
  /etc/init.d/zram-swap enable
  /etc/init.d/zram-swap start
fi

exit 0
EOF

chmod +x "$FILES_DIR/etc/uci-defaults/99-24spark"

echo "Config files generated successfully."

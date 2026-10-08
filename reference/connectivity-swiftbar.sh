#!/bin/bash
#
# Connectivity indicator for SwiftBar
# Menu-bar dot showing healthy / slow / offline, based on a real HTTPS request
# (the same kind of traffic a prompt uses), not a ping: train and hotel Wi-Fi
# often filter pings or sit behind a login page while ping still answers.
#
# <bitbar.title>Connectivity</bitbar.title>
# <bitbar.version>2.0</bitbar.version>
# <bitbar.author>built for Cristian</bitbar.author>
# <bitbar.desc>Menu-bar dot showing healthy / slow / offline based on an HTTPS request to 1.1.1.1.</bitbar.desc>
# <swiftbar.runInBash>true</swiftbar.runInBash>
# <swiftbar.hideAbout>true</swiftbar.hideAbout>

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# ---- tunables ----
URL="https://1.1.1.1/cdn-cgi/trace"   # Cloudflare, by IP: no DNS dependency (DNS dies first on trains)
SLOW_RTT_MS=200     # TCP connect time above this => "slow" (comparable to the old ping threshold)
SLOW_TOTAL_MS=1500  # whole request above this => "slow"
TIMEOUT=3           # hard cap in seconds for the whole probe

# ---- probe ----
# A login page (captive portal) can't fake Cloudflare's certificate, so it shows up as a failure => offline.
res=$(curl -sS -o /dev/null -m "$TIMEOUT" -w '%{http_code} %{time_connect} %{time_total}' "$URL" 2>/dev/null)
code=$(printf '%s' "$res" | awk '{print $1}')
rtt=$(printf '%s' "$res" | awk '{printf "%d", $2*1000}')
total=$(printf '%s' "$res" | awk '{printf "%d", $3*1000}')

# ---- classify ----
if [ "$code" != "200" ]; then
  state="offline"
elif [ "$rtt" -gt "$SLOW_RTT_MS" ] || [ "$total" -gt "$SLOW_TOTAL_MS" ]; then
  state="slow"
else
  state="healthy"
fi

# ---- render menu-bar title ----
case "$state" in
  healthy) echo "🟢 ${rtt}ms" ;;
  slow)    echo "🟡 ${rtt}ms" ;;
  offline) echo "🔴 offline" ;;
esac

# ---- dropdown ----
echo "---"
echo "Status: $state | size=12"
if [ "$state" = "offline" ]; then
  echo "No HTTPS reply within ${TIMEOUT}s (code ${code:-000}) | size=12"
else
  echo "Connect: ${rtt} ms  ·  full request: ${total} ms | size=12"
fi
echo "Target: $URL | size=12"
echo "Updated: $(date '+%H:%M:%S') | size=12"
echo "---"
echo "Run full speed test (networkQuality) | bash=/usr/bin/networkQuality param1=-v terminal=true"
echo "Refresh now | refresh=true"

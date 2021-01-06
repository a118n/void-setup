#! /usr/bin/env bash
set -euo pipefail

wpa_passphrase MGTS_GPON5_51EF pYq4RQmT > /etc/wpa_supplicant/wpa_supplicant-wlp5s0.conf
wpa_supplicant -B -iwlp5s0 -c /etc/wpa_supplicant/wpa_supplicant-wlp5s0.conf

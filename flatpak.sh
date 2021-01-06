#! /usr/bin/env bash

set -euo pipefail

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.spotify.Client
flatpak install -y flathub com.valvesoftware.Steam
flatpak install -y flathub com.visualstudio.code
flatpak install -y flathub com.gigitux.youp

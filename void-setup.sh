#! /usr/bin/env bash
set -euo pipefail

# Connect to Wi-Fi
wpa_passphrase MGTS_GPON5_51EF pYq4RQmT | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf
# sudo wpa_supplicant -B -iwlp5s0 -c /etc/wpa_supplicant/wpa_supplicant-wlp5s0.conf
sudo ln -sfv /etc/sv/dhcpcd /var/service/
sudo ln -sfv /etc/sv/wpa_supplicant /var/service

# Wait for DHCP to aquire lease
sleep 20s

# Upgrade system
# Run it two times in case system was installed via local source and XBPS is outdated
sudo xbps-install -Syu && sudo xbps-install -Syu

# Install necessary software
sudo xbps-install -y xtools socklog-void bind-utils chrony bash-completion vim git curl wget neofetch mesa-dri mesa-vaapi mesa-vdpau vulkan-loader mesa-vulkan-radeon alsa-utils bluez dbus elogind ntfs-3g xdg-user-dirs terminus-font google-fonts-ttf dejavu-fonts-ttf docker docker-compose sway kitty wofi unzip flatpak

# Install Cascadia Code
CascadiaCodeVersion="2009.22"
cd /tmp
curl -LO https://github.com/microsoft/cascadia-code/releases/download/v${CascadiaCodeVersion}/CascadiaCode-${CascadiaCodeVersion}.zip
unzip CascadiaCode-${CascadiaCodeVersion}.zip -d cascadiacode
mkdir -pv ~/.local/share/fonts
cp -fv /tmp/cascadiacode/ttf/static/*.ttf ~/.local/share/fonts/
rm -rfv /tmp/cascadiacode
rm -rfv /tmp/CascadiaCode-${CascadiaCodeVersion}.zip

# Configure fonts
sudo ln -sfv /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/
sudo ln -sfv /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
sudo ln -sfv /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
sudo ln -sfv /usr/share/fontconfig/conf.avail/50-user.conf /etc/fonts/conf.d/
sudo ln -sfv /usr/share/fontconfig/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/
sudo xbps-reconfigure -f fontconfig

# Pretty up fonts #1
mkdir -pv ~/.config/fontconfig
cat <<-EOF > ~/.config/fontconfig/fonts.conf
<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
<fontconfig>
    <match target="font">
        <edit mode="assign" name="antialias">
            <bool>true</bool>
        </edit>
        <edit mode="assign" name="hinting">
            <bool>true</bool>
        </edit>
        <edit mode="assign" name="autohint">
            <bool>false</bool>
        </edit>
        <edit mode="assign" name="hintstyle">
            <const>hintslight</const>
        </edit>
        <edit mode="assign" name="rgba">
            <const>rgb</const>
        </edit>
        <edit mode="assign" name="lcdfilter">
            <const>lcddefault</const>
        </edit>
        <edit mode="assign" name="embeddedbitmap">
            <bool>false</bool>
        </edit>
    </match>
</fontconfig>
EOF

# Pretty up fonts #2
# cat <<-EOF > ~/.Xresources
# ! Pretty up fonts
# Xft.antialias: 1
# Xft.autohint: 0
# Xft.dpi: 96
# Xft.hinting: 1
# Xft.hintstyle: hintslight
# Xft.lcdfilter: lcddefault
# Xft.rgba: rgb
# EOF

# PulseAudio fix for Scarlett 2i4
# mkdir -p ~/.config/pulse
# cat <<-EOF > ~/.config/pulse/default.pa
# .include /etc/pulse/default.pa

# # Focusrite Scarlett 2i4 config

# # Remap outputs 1&2 separately
# load-module module-remap-sink sink_name=speakers sink_properties="device.description='Speakers'" remix=no master=alsa_output.usb-Focusrite_Scarlett_2i4_USB-00.analog-surround-40 channels=2 master_channel_map=front-left,front-right channel_map=front-left,front-right

# # Remap outputs 3&4 separately
# load-module module-remap-sink sink_name=aux sink_properties="device.description='Aux'" remix=no master=alsa_output.usb-Focusrite_Scarlett_2i4_USB-00.analog-surround-40 channels=2 master_channel_map=rear-left,rear-right channel_map=front-left,front-right

# # Remap input 1 separately
# load-module module-remap-source source_name=input-1 source_properties="device.description='Input 1'" master=alsa_input.usb-Focusrite_Scarlett_2i4_USB-00.analog-stereo remix=no channels=2 master_channel_map=front-left,front-left channel_map=left,right

# # Remap input 2 separately
# load-module module-remap-source source_name=input-2 source_properties="device.description='Input 2'" master=alsa_input.usb-Focusrite_Scarlett_2i4_USB-00.analog-stereo remix=no channels=2 master_channel_map=front-right,front-right  channel_map=left,right
# EOF

# Add user to necessary groups
sudo usermod -aG bluetooth,docker,socklog $USER

# Set time to localtime
sudo sed -i 's/#HARDWARECLOCK="UTC"/HARDWARECLOCK=localtime/' /etc/rc.conf

# Set console font to Terminus large
sudo sed -i 's/#FONT="lat9w-16"/FONT=ter-132n/' /etc/rc.conf

# Configure monitor for GNOME & GDM
# cat <<-EOF > ~/.config/monitors.xml
# <monitors version="2">
#     <configuration>
#         <logicalmonitor>
#             <x>0</x>
#             <y>0</y>
#             <scale>1</scale>
#             <primary>yes</primary>
#             <monitor>
#                 <monitorspec>
#                     <connector>DP-1</connector>
#                     <vendor>DEL</vendor>
#                     <product>DELL S3220DGF</product>
#                     <serial>8VQM4W2</serial>
#                 </monitorspec>
#                 <mode>
#                     <width>2560</width>
#                     <height>1440</height>
#                     <rate>164.05659484863281</rate>
#                 </mode>
#             </monitor>
#         </logicalmonitor>
#     </configuration>
# </monitors>
# EOF
# sudo cp ~/.config/monitors.xml /var/lib/gdm/.config/monitors.xml
# sudo chown gdm:gdm /var/lib/gdm/.config/monitors.xml

# Enable TearFree for AMD GPU
# sudo mkdir -p /etc/X11/xorg.conf.d
# cat <<-EOF | sudo tee /etc/X11/xorg.conf.d/20-amdgpu.conf
# Section "Device"
#   Identifier "AMD"
#   Driver "amdgpu"
#   Option "TearFree" "true"
#   EndSection
# EOF

# Enable necessary services
# sudo rm -f /var/service/dhcpcd
sudo rm -fv /var/service/agetty-tty{4,5,6}
sudo ln -sfv /etc/sv/socklog-unix /var/service/
sudo ln -sfv /etc/sv/chronyd /var/service/
sudo ln -sfv /etc/sv/nanoklogd /var/service/
sudo ln -sfv /etc/sv/dbus /var/service/
sudo ln -sfv /etc/sv/alsa /var/service/
sudo ln -sfv /etc/sv/bluetoothd /var/service/
sudo ln -sfv /etc/sv/docker /var/service/
# sudo ln -sf /etc/sv/NetworkManager /var/service/
# sudo ln -sf /etc/sv/gdm /var/service/

# Reboot
sudo reboot

#!/bin/bash

echo "Installing Bluetooth A2DP Dependencies"
sudo apt-get update
sudo apt-get -y install bluez bluez-tools pulseaudio-module-bluetooth

echo "Setting up permissions"
sudo usermod -a -G lp volumio
sudo usermod -a -G pulse-access,audio volumio

echo "Enable Bluetooth Modules"
sudo cat <<EOT >> /etc/pulse/system.pa
.ifexists module-bluetooth-policy.so
load-module module-bluetooth-policy
.endif
.ifexists module-bluetooth-discover.so
load-module module-bluetooth-discover
.endif
.ifexists module-bluez5-device.so
load-module module-bluez5-device
.endif
.ifexists module-bluez5-discover.so
load-module module-bluez5-discover
.endif
EOT

echo "Create startup script"
sudo cat <<EOT > /etc/systemd/system/pulseaudio.service 
[Unit]
Description=Pulse Audio
[Service]
Type=simple
ExecStart=/usr/bin/pulseaudio --system --disallow-exit --disallow-module-loading --disable-shm --daemonize
[Install]
WantedBy=multi-user.target
EOT

echo "Start service"
sudo systemctl daemon-reload
sudo systemctl enable pulseaudio.service
sudo systemctl start pulseaudio.service

echo "Bluetooth configuration"
sudo cat <<EOT > /etc/bluetooth/audio.conf
[General]
Enable=Source,Sink,Media,Socket
HFP=true
Class=0x20041C
EOT

sudo sed -i '/Name =/c\Name = volumio' /etc/bluetooth/main.conf
sudo sed -i '/Class =/c\Class = 0x20041C' /etc/bluetooth/main.conf




#required to end the plugin install
echo "plugininstallend"
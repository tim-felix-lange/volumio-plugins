#!/bin/bash
config=$(sudo hciconfig -a)
if [ ${config:+1} ]
then
    mac=$(echo "$config" | grep -w 'BD Address:' |  tr -d '[[:space:]]')
    mac=${mac:10:17}
    sudo cat <<EOT > /var/lib/bluetooth/$mac/settings
	[General]
	Discoverable=true
	Alias=volumio
	Class=0x20041C
	EOT
	sudo hciconfig hci0 up
	
else
    echo "No BT adapter found"
fi
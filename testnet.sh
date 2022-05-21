#!/bin/bash

spaces='   '
net_manager_stat=$(sudo systemctl status NetworkManager | grep Active: | cut -d '(' -f 1 | cut -d ':' -f 2 | xargs)
net_stat=$(sudo systemctl status network | grep Active: | cut -d '(' -f 1 | cut -d ':' -f 2 | xargs)
firewall_stat=$(sudo systemctl status firewalld | grep Active: | cut -d '(' -f 1 | cut -d ':' -f 2 | xargs)
SELinux_stat=$(sestatus | grep 'SELinux status:' | cut -d ':' -f 2 | xargs)

# Get blue and red int
for int in $(sudo lshw -class network | grep "ens*" | grep logical | cut -d ':' -f 2)
do
	if [ -n "$(ip addr show $int | grep 172.16)" ]
	then
		red_int=$int
		red_ip=$(ip addr show $red_int | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
	else
		blue_int=$int
		blue_ip=$(ip addr show $blue_int | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
	fi
done
default_gateway_ip="$(ip route show | grep default | cut -d ' ' -f 3 | xargs)"

### Services status display
echo Services status
echo '++++++++++++++++++++++++++++++++++++'

echo Network Manager: "$net_manager_stat"
echo Network: "$net_stat"
echo Firewalld: "$firewall_stat"
echo iptables:
echo "$(sudo systemctl status iptables | xargs)"
echo SELinux: "$SELinux_stat"
echo

### Network settings display
echo Network settings
echo '++++++++++++++++++++++++++++++++++++'

# Display red and blue interfaces
echo Red interface
echo "$spaces"interface name: "$red_int"
echo "$spaces"ip: "$red_ip"

echo Blue interface
echo "$spaces"interface name: "$blue_int"
echo "$spaces"ip: "$blue_ip"

# Loop with newline
IFS=$'\n'

# Display dns server
echo DNS server
for nameserver in $(grep "nameserver" /etc/resolv.conf)
do
	echo "$spaces""$nameserver"
done

# Display hostname resolution
echo Hostname resolution: "$(cat /etc/nsswitch.conf | grep ^hosts | cut -d ':' -f 2 | xargs)"

# Display hosts file content
echo Hosts file content:
for host in $(cat /etc/hosts)
do
	echo "$spaces""$host"
done

# Display default gateway
echo Default gateway: "$default_gateway_ip"
echo

### Ping results display
echo Ping results
echo '++++++++++++++++++++++++++++++++++++'

echo 'Server --> client'
ping nguy0936-clt.example72.lab -c 3
echo

echo 'Server -> default gateway('"$default_gateway_ip"')'
ping $default_gateway_ip -c 3
echo

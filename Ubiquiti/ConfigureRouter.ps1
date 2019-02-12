scp.exe -r ubnt@192.168.2.1:/config/auth D:\git\SeDevOps\Ubiquiti\authCopy
scp.exe ubnt@192.168.2.1:/etc/hosts D:\git\SeDevOps\Ubiquiti\hosts
ssh ubnt@192.168.2.1

# https://help.ubnt.com/hc/en-us/articles/115015971688-EdgeRouter-OpenVPN-Server

LV
Riga
csharp.company
struggleendlessly@hotmail.com

# https://help.ubnt.com/hc/en-us/articles/115015971688-EdgeRouter-OpenVPN-Server
openssl rsa -in /config/auth/client_phone.key -out /config/auth/client_phone-no-pass.key
# UDP

set firewall name WAN_LOCAL rule 40 action accept
set firewall name WAN_LOCAL rule 40 description openvpn
set firewall name WAN_LOCAL rule 40 destination port 1194
set firewall name WAN_LOCAL rule 40 protocol udp

set interfaces openvpn vtun1 description 'OpenVPN server UDP'
set interfaces openvpn vtun1 mode server
set interfaces openvpn vtun1 server subnet 172.16.2.0/24
set interfaces openvpn vtun1 server push-route 192.168.2.0/24
set interfaces openvpn vtun1 server name-server 192.168.2.1

set interfaces openvpn vtun1 tls ca-cert-file /config/auth/cacert.pem
set interfaces openvpn vtun1 tls cert-file /config/auth/server.pem
set interfaces openvpn vtun1 tls key-file /config/auth/server.key
set interfaces openvpn vtun1 tls dh-file /config/auth/dh.pem

# TCP
set firewall name WAN_LOCAL rule 50 action accept
set firewall name WAN_LOCAL rule 50 description openvpn
set firewall name WAN_LOCAL rule 50 destination port 443
set firewall name WAN_LOCAL rule 50 protocol tcp

set interfaces openvpn vtun0 description 'OpenVPN server TCP'
set interfaces openvpn vtun0 mode server
set interfaces openvpn vtun0 protocol tcp-passive
set interfaces openvpn vtun0 local-port 443
set interfaces openvpn vtun0 server subnet 172.16.1.0/24
set interfaces openvpn vtun0 server push-route 192.168.2.0/24
set interfaces openvpn vtun0 server name-server 192.168.2.1
set interfaces openvpn vtun0 openvpn-option --tls-server
set interfaces openvpn vtun0 openvpn-option "--persist-key"
set interfaces openvpn vtun0 openvpn-option "--persist-tun"
set interfaces openvpn vtun0 openvpn-option "--duplicate-cn"

set interfaces openvpn vtun0 tls ca-cert-file /config/auth/cacert.pem
set interfaces openvpn vtun0 tls cert-file /config/auth/server.pem
set interfaces openvpn vtun0 tls key-file /config/auth/server.key
set interfaces openvpn vtun0 tls dh-file /config/auth/dh.pem
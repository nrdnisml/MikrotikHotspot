# jan/18/2020 13:08:26 by RouterOS 6.42.9
# software id = 4RT7-XCC3
#
# model = RouterBOARD 750G r3
# serial number = 6F38083515DD
/interface ethernet
set [ find default-name=ether1 ] name=eth1-internet
set [ find default-name=ether2 ] name=eth2-home
set [ find default-name=ether3 ] name=eth3-hotspot
set [ find default-name=ether4 ] name=eth4
set [ find default-name=ether5 ] name=eth5
/interface ovpn-client
add comment=MyTunnel-DNS connect-to=103.28.22.201 mac-address=\
    FE:4E:61:9F:B6:CD mode=ethernet name=MyTunnel-DNS password=tunnel.my.id \
    port=12000 user=dns
/interface vlan
add interface=eth2-home name=vlan_leli vlan-id=200
add interface=eth2-home name=vlan_pendik vlan-id=300
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip firewall layer7-protocol
add name=speedtest regexp="^.+(speedtest).*\\\$"
/ip hotspot profile
set [ find default=yes ] html-directory=flash/hotspot
/ip hotspot user profile
set [ find default=yes ] incoming-packet-mark=up on-login=":put (\",,0,,,noexp\
    ,\")\r\
    \n\r\
    \n:local datetime [/system clock get date];\r\
    \n:local timedate [/system clock get time];\r\
    \n/queue simple add max-limit=768k/1M name=\"\$address\" comment=(\"user_h\
    otspot\") parent=\"3. HOTSPOT DAN HOME\" \\ target=\$address\r\
    \n" outgoing-packet-mark=down shared-users=unlimited status-autorefresh=\
    15s transparent-proxy=yes
add name=Tes on-login=":put (\",rem,45000,1m,0,,Disable,\"); {:local date [ /s\
    ystem clock get date ];:local year [ :pick \$date 7 11 ];:local month [ :p\
    ick \$date 0 3 ];:local comment [ /ip hotspot user get [/ip hotspot user f\
    ind where name=\"\$user\"] comment]; :local ucode [:pic \$comment 0 2]; :i\
    f (\$ucode = \"vc\" or \$ucode = \"up\" or \$comment = \"\") do={ /sys sch\
    \_add name=\"\$user\" disable=no start-date=\$date interval=\"1m\"; :delay\
    \_2s; :local exp [ /sys sch get [ /sys sch find where name=\"\$user\" ] ne\
    xt-run]; :local getxp [len \$exp]; :if (\$getxp = 15) do={ :local d [:pic \
    \$exp 0 6]; :local t [:pic \$exp 7 16]; :local s (\"/\"); :local exp (\"\$\
    d\$s\$year \$t\"); /ip hotspot user set comment=\$exp [find where name=\"\
    \$user\"];}; :if (\$getxp = 8) do={ /ip hotspot user set comment=\"\$date \
    \$exp\" [find where name=\"\$user\"];}; :if (\$getxp > 15) do={ /ip hotspo\
    t user set comment=\$exp [find where name=\"\$user\"];}; /sys sch remove [\
    find where name=\"\$user\"]}}" parent-queue=none transparent-proxy=yes
/ip pool
add name=pool_leli ranges=172.16.2.3-172.16.2.254
add name=pool_PPPoE ranges=192.168.10.2-192.168.10.254
add name=pool_pendik ranges=172.16.3.5-172.16.3.254
add name=dhcp_pool10 ranges=192.168.12.15-192.168.12.254
/ip dhcp-server
add add-arp=yes address-pool=pool_pendik disabled=no interface=vlan_pendik \
    lease-time=1d10m name=dhcp2
add add-arp=yes address-pool=pool_leli disabled=no interface=vlan_leli \
    lease-time=1d10m name=dhcp3
add add-arp=yes address-pool=dhcp_pool10 always-broadcast=yes disabled=no \
    interface=eth3-hotspot lease-time=1d10m name=dhcp1
/ppp profile
add local-address=192.168.10.1 name=PPPoE on-down=":log error \"\$user logout\
    \"\r\
    \n:log error \"\$user logout\"\r\
    \n/queue simple remove [find name=\"\$user\"] ;\r\
    \n" on-up=":local address [/ppp active get [/ppp active  find name=\"\$use\
    r\"] address]\r\
    \n:log warning \"\$user login dengan ip \$address\"\r\
    \n:log warning \"\$user login dengan ip \$address\"\r\
    \n:local datetime [/system clock get date];\r\
    \n:local timedate [/system clock get time];\r\
    \n[/queue simple add max-limit=1M/3M name=(\"\$user\") comment=\"user_pppo\
    e\" parent=\"3.2 HOME\" \\ target=\"\$address\"];\r\
    \n" only-one=yes remote-address=pool_PPPoE
/queue simple
add max-limit=2M/3M name="1. PORT GAME DOWN" packet-marks=\
    "PORT GAME DOWNLOAD,PORT GAME UPLOAD" priority=1/1 target="192.168.12.0/24\
    ,192.168.10.0/24,vlan_leli,vlan_pendik,172.16.0.0/24,192.168.1.0/24,172.16\
    .4.0/24"
/queue tree
add name="4.ICMP DOWN" packet-mark="ICMP DOWNLOAD" parent=global priority=1
add name="5.ICMP UP" packet-mark="ICMP UPLOAD" parent=global priority=1
/queue type
add kind=pcq name=pcq-download pcq-classifier=dst-address \
    pcq-dst-address6-mask=64 pcq-src-address6-mask=64
add kind=pcq name=pq-upload pcq-classifier=src-address pcq-dst-address6-mask=\
    64 pcq-src-address6-mask=64
/queue simple
add max-limit=20M/20M name="2. ICMP DOWN" packet-marks=\
    "ICMP DOWNLOAD,ICMP UPLOAD" priority=1/1 queue=default/default target="eth\
    1-internet,192.168.12.0/24,vlan_leli,vlan_pendik,172.16.0.0/24,192.168.10.\
    0/24,172.16.4.0/24"
add max-limit=5M/25M name=ALLTRAFFIC packet-marks="SOSMED DOWNLOAD,SOSMED UPLO\
    AD,YOUTUBE DOWNLOAD,YOUTUBE UPLOAD,PORT BERAT DOWNLOAD,PORT BERAT UPLOAD,G\
    LOBAL DOWNLOAD,GLOBAL UPLOAD" priority=3/3 queue=pq-upload/pcq-download \
    target="192.168.10.0/24,eth2-home,vlan_leli,vlan_pendik,172.16.0.0/24,192.\
    168.12.0/24,172.16.4.0/24"
add max-limit=2M/20M name="3.1 HOTSPOT" parent=ALLTRAFFIC priority=5/5 queue=\
    default/default target=eth2-home,192.168.12.0/24
add max-limit=2M/9M name="3.2 HOME" parent=ALLTRAFFIC queue=\
    pq-upload/pcq-download target=\
    vlan_pendik,vlan_leli,MyTunnel-DNS,192.168.10.0/24
add comment=user_pppoe max-limit=1M/3M name=mail parent="3.2 HOME" target=\
    192.168.10.3/32
/ip hotspot user profile
add incoming-packet-mark=down !keepalive-timeout mac-cookie-timeout=1d name=\
    TRIALuser on-login=":put (\",,0,,,noexp,Disable,\")\r\
    \n" outgoing-packet-mark=up parent-queue="3.1 HOTSPOT" queue-type=\
    default-small rate-limit="512K/768K 1M/2M 768K/1000k 8" shared-users=30 \
    transparent-proxy=yes
add !idle-timeout !keepalive-timeout mac-cookie-timeout=1d name=1hari \
    on-login=":put (\",ntfc,3000,1d,0,,Enable,\"); {:local date [ /system cloc\
    k get date ];:local year [ :pick \$date 7 11 ];:local month [ :pick \$date\
    \_0 3 ];:local comment [ /ip hotspot user get [/ip hotspot user find where\
    \_name=\"\$user\"] comment]; :local ucode [:pic \$comment 0 2]; :if (\$uco\
    de = \"vc\" or \$ucode = \"up\" or \$comment = \"\") do={ /sys sch add nam\
    e=\"\$user\" disable=no start-date=\$date interval=\"1d\"; :delay 2s; :loc\
    al exp [ /sys sch get [ /sys sch find where name=\"\$user\" ] next-run]; :\
    local getxp [len \$exp]; :if (\$getxp = 15) do={ :local d [:pic \$exp 0 6]\
    ; :local t [:pic \$exp 7 16]; :local s (\"/\"); :local exp (\"\$d\$s\$year\
    \_\$t\"); /ip hotspot user set comment=\$exp [find where name=\"\$user\"];\
    }; :if (\$getxp = 8) do={ /ip hotspot user set comment=\"\$date \$exp\" [f\
    ind where name=\"\$user\"];}; :if (\$getxp > 15) do={ /ip hotspot user set\
    \_comment=\$exp [find where name=\"\$user\"];}; /sys sch remove [find wher\
    e name=\"\$user\"]; :local mac \$\"mac-address\"; :local time [/system clo\
    ck get time ]; /system script add name=\"\$date-|-\$time-|-\$user-|-3000-|\
    -\$address-|-\$mac-|-1d-|-1hari-|-\$comment\" owner=\"\$month\$year\" sour\
    ce=\$date comment=mikhmon; [:local mac \$\"mac-address\"; /ip hotspot user\
    \_set mac-address=\$mac [find where name=\$user]]}}" on-logout="\r\
    \n" open-status-page=http-login parent-queue="3.1 HOTSPOT" queue-type=\
    default-small rate-limit="256K/768K 1M/2M 768K/1M 8" transparent-proxy=\
    yes
add !idle-timeout !keepalive-timeout mac-cookie-timeout=2d name=2hari \
    on-login=":put (\",ntfc,5000,2d,0,,Enable,\"); {:local date [ /system cloc\
    k get date ];:local year [ :pick \$date 7 11 ];:local month [ :pick \$date\
    \_0 3 ];:local comment [ /ip hotspot user get [/ip hotspot user find where\
    \_name=\"\$user\"] comment]; :local ucode [:pic \$comment 0 2]; :if (\$uco\
    de = \"vc\" or \$ucode = \"up\" or \$comment = \"\") do={ /sys sch add nam\
    e=\"\$user\" disable=no start-date=\$date interval=\"2d\"; :delay 2s; :loc\
    al exp [ /sys sch get [ /sys sch find where name=\"\$user\" ] next-run]; :\
    local getxp [len \$exp]; :if (\$getxp = 15) do={ :local d [:pic \$exp 0 6]\
    ; :local t [:pic \$exp 7 16]; :local s (\"/\"); :local exp (\"\$d\$s\$year\
    \_\$t\"); /ip hotspot user set comment=\$exp [find where name=\"\$user\"];\
    }; :if (\$getxp = 8) do={ /ip hotspot user set comment=\"\$date \$exp\" [f\
    ind where name=\"\$user\"];}; :if (\$getxp > 15) do={ /ip hotspot user set\
    \_comment=\$exp [find where name=\"\$user\"];}; /sys sch remove [find wher\
    e name=\"\$user\"]; :local mac \$\"mac-address\"; :local time [/system clo\
    ck get time ]; /system script add name=\"\$date-|-\$time-|-\$user-|-5000-|\
    -\$address-|-\$mac-|-2d-|-2hari-|-\$comment\" owner=\"\$month\$year\" sour\
    ce=\$date comment=mikhmon; [:local mac \$\"mac-address\"; /ip hotspot user\
    \_set mac-address=\$mac [find where name=\$user]]}}" on-logout="\r\
    \n" open-status-page=http-login parent-queue="3.1 HOTSPOT" queue-type=\
    default-small rate-limit="256K/768K 1M/2M 768K/1M 8" transparent-proxy=\
    yes
add !idle-timeout !keepalive-timeout mac-cookie-timeout=1w name=7hari \
    on-login=":put (\",ntfc,15000,7d,0,,Enable,\"); {:local date [ /system clo\
    ck get date ];:local year [ :pick \$date 7 11 ];:local month [ :pick \$dat\
    e 0 3 ];:local comment [ /ip hotspot user get [/ip hotspot user find where\
    \_name=\"\$user\"] comment]; :local ucode [:pic \$comment 0 2]; :if (\$uco\
    de = \"vc\" or \$ucode = \"up\" or \$comment = \"\") do={ /sys sch add nam\
    e=\"\$user\" disable=no start-date=\$date interval=\"7d\"; :delay 2s; :loc\
    al exp [ /sys sch get [ /sys sch find where name=\"\$user\" ] next-run]; :\
    local getxp [len \$exp]; :if (\$getxp = 15) do={ :local d [:pic \$exp 0 6]\
    ; :local t [:pic \$exp 7 16]; :local s (\"/\"); :local exp (\"\$d\$s\$year\
    \_\$t\"); /ip hotspot user set comment=\$exp [find where name=\"\$user\"];\
    }; :if (\$getxp = 8) do={ /ip hotspot user set comment=\"\$date \$exp\" [f\
    ind where name=\"\$user\"];}; :if (\$getxp > 15) do={ /ip hotspot user set\
    \_comment=\$exp [find where name=\"\$user\"];}; /sys sch remove [find wher\
    e name=\"\$user\"]; :local mac \$\"mac-address\"; :local time [/system clo\
    ck get time ]; /system script add name=\"\$date-|-\$time-|-\$user-|-15000-\
    |-\$address-|-\$mac-|-7d-|-7hari-|-\$comment\" owner=\"\$month\$year\" sou\
    rce=\$date comment=mikhmon; [:local mac \$\"mac-address\"; /ip hotspot use\
    r set mac-address=\$mac [find where name=\$user]]}}" on-logout="\r\
    \n" open-status-page=http-login parent-queue="3.1 HOTSPOT" queue-type=\
    default-small rate-limit="256K/768K 1M/2M 768K/1M 8" transparent-proxy=\
    yes
add !keepalive-timeout name=VIP on-login=":put (\",,0,,,noexp,Enable,\"); [:lo\
    cal mac \$\"mac-address\"; /ip hotspot user set mac-address=\$mac [find wh\
    ere name=\$user]]\
    \n\
    \n:local datetime [/system clock get date];\r\
    \n\r\
    \n\r\
    \n" parent-queue="3.1 HOTSPOT" queue-type=default-small rate-limit=\
    "512K/768K 1M/3M 768K/2M 8" transparent-proxy=yes
add !idle-timeout !keepalive-timeout name=BINDING on-login=":put (\",,0,,,noex\
    p,Enable,\"); [:local mac \$\"mac-address\"; /ip hotspot user set mac-addr\
    ess=\$mac [find where name=\$user]]\r\
    \n\r\
    \n" parent-queue="3.1 HOTSPOT" queue-type=default-small rate-limit=\
    "256K/512K 1M/1M 768K/1M 8" transparent-proxy=yes
/ip hotspot profile
add dns-name=melati.spot hotspot-address=192.168.12.1 html-directory=\
    flash/melatiTemplate http-cookie-lifetime=2d login-by=\
    mac,cookie,http-chap,http-pap,trial,mac-cookie mac-auth-mode=\
    mac-as-username-and-password name=melatispot trial-uptime-limit=10m \
    trial-user-profile=TRIALuser
/ip hotspot
add address-pool=dhcp_pool10 addresses-per-mac=1 disabled=no idle-timeout=\
    none interface=eth3-hotspot name=server1 profile=melatispot
/queue simple
add burst-limit=1M/3M burst-threshold=1M/1500k burst-time=8s/8s max-limit=\
    1M/3M name=1.PENDIK parent="3.2 HOME" target=vlan_pendik
add burst-limit=1M/3M burst-threshold=1M/2500k burst-time=8s/8s max-limit=\
    1M/2M name=2.LELI parent="3.2 HOME" queue=pq-upload/pcq-download target=\
    vlan_leli
/queue tree
add max-limit=20M name="GLOBAL DOWN" parent=global queue=pcq-download-default
add name="GLOBAL UP" packet-mark="GLOBAL UPLOAD" parent=global queue=\
    pcq-upload-default
add name="1.YT DOWN" packet-mark="YOUTUBE DOWNLOAD" parent="GLOBAL DOWN" \
    queue=pcq-download
add name="1.YT UP" packet-mark="YOUTUBE UPLOAD" parent="GLOBAL UP" queue=\
    pcq-upload-default
add name="2. SOSMED DOWN" packet-mark="SOSMED DOWNLOAD" parent="GLOBAL DOWN" \
    queue=pcq-download
add name="2. SOSMED UP" packet-mark="SOSMED UPLOAD" parent="GLOBAL UP" queue=\
    pcq-upload-default
add name="3. UPLOAD ALL" packet-mark="GLOBAL UPLOAD" parent="GLOBAL UP" \
    queue=pcq-upload-default
add name="3. DOWNLOAD ALL" packet-mark="GLOBAL DOWNLOAD" parent="GLOBAL DOWN" \
    queue=pcq-download
add name="4. TRAFIK BERAT DOWN" packet-mark="PORT BERAT DOWNLOAD" parent=\
    "GLOBAL DOWN" queue=pcq-download
add name="4. TRAFIK BERAT UPLOAD" packet-mark="PORT BERAT UPLOAD" parent=\
    "GLOBAL UP" queue=pcq-upload-default
add max-limit=3M name="1.PORT GAME DOWN" packet-mark="PORT GAME DOWNLOAD" \
    parent=global priority=1 queue=pcq-download
add max-limit=2M name="2.PORT GAME UP" packet-mark="PORT GAME UPLOAD" parent=\
    global priority=1 queue=pcq-upload-default
/interface detect-internet
set detect-interface-list=all
/interface pppoe-server server
add default-profile=PPPoE disabled=no interface=eth2-home \
    one-session-per-host=yes service-name=PPPOErumahan
add default-profile=PPPoE disabled=no interface=eth3-hotspot \
    one-session-per-host=yes service-name=service1
/ip address
add address=192.168.12.1/24 interface=eth3-hotspot network=192.168.12.0
add address=172.16.3.1/24 interface=vlan_pendik network=172.16.3.0
add address=172.16.2.1/24 interface=vlan_leli network=172.16.2.0
/ip cloud
set ddns-enabled=yes
/ip dhcp-client
add dhcp-options=hostname,clientid disabled=no interface=eth1-internet
/ip dhcp-server network
add address=10.0.0.0/24 gateway=10.0.0.1
add address=172.16.1.0/24 dns-server=8.8.8.8,118.98.44.10 gateway=172.16.1.1
add address=172.16.2.0/24 dns-server=8.8.8.8,118.98.44.10 gateway=172.16.2.1
add address=172.16.3.0/24 gateway=172.16.3.1
add address=172.16.4.0/24 dns-server=118.98.44.100,8.8.8.8 gateway=172.16.4.1
add address=192.168.12.0/24 dns-server=192.168.12.1,118.98.44.10 domain=\
    melati.spot gateway=192.168.12.1
/ip dns
set allow-remote-requests=yes servers="192.168.12.1,176.103.130.130,176.103.13\
    0.131,139.99.74.182,54.39.97.51,163.172.170.19,51.158.168.202"
/ip firewall address-list
add address=192.168.12.0/24 list="IP LOCAL"
add address=192.168.10.0/24 list="IP LOCAL"
add address=172.16.0.0/24 list="IP LOCAL"
add address=172.16.2.0/24 list="IP LOCAL"
add address=172.16.3.0/24 list="IP LOCAL"
add address=192.168.1.0/24 list="IP LOCAL"
/ip firewall filter
# inactive time
add action=drop chain=hs-input log=yes log-prefix="drop zahro" protocol=tcp \
    src-mac-address=24:FD:52:03:46:15 time=\
    21h15m-4h,sun,mon,tue,wed,thu,fri,sat
# inactive time
add action=drop chain=hs-input log=yes log-prefix="drop zahro" protocol=udp \
    src-mac-address=24:FD:52:03:46:15 time=21h15m-4h,sun,mon,tue,wed,thu,fri
add action=drop chain=forward comment=log-modem dst-address=192.168.1.1 log=\
    yes log-prefix=log-modem src-mac-address=!A4:D9:90:37:57:51
add action=passthrough chain=unused-hs-chain comment=\
    "place hotspot rules here" disabled=yes
add action=passthrough chain=unused-hs-chain comment=\
    "place hotspot rules here" disabled=yes
/ip firewall mangle
add action=mark-connection chain=postrouting comment="GLOBAL TRAFFIC" \
    connection-mark="!PORT GAME" new-connection-mark="GLOBAL TRAFFIC" \
    packet-mark="!ICMP DOWN" passthrough=yes
add action=mark-packet chain=forward connection-mark="GLOBAL TRAFFIC" \
    in-interface=eth1-internet new-packet-mark="GLOBAL DOWNLOAD" passthrough=\
    yes
add action=mark-packet chain=forward connection-mark="GLOBAL TRAFFIC" \
    new-packet-mark="GLOBAL UPLOAD" out-interface=eth1-internet passthrough=\
    yes
add action=mark-connection chain=postrouting comment=GAME dst-address-list=\
    "IP GAME ONLINE" new-connection-mark="PORT GAME" passthrough=yes
add action=mark-packet chain=forward connection-mark="PORT GAME" \
    in-interface=eth1-internet new-packet-mark="PORT GAME DOWNLOAD" \
    passthrough=yes
add action=mark-packet chain=forward connection-mark="PORT GAME" \
    new-packet-mark="PORT GAME UPLOAD" out-interface=eth1-internet \
    passthrough=yes
add action=mark-connection chain=postrouting comment=\
    "INPUT PORT GAME TO WEIGHT TRAFFIC" connection-mark="PORT GAME" \
    connection-rate=200k-100M new-connection-mark="PORT BERAT" passthrough=\
    yes
add action=mark-packet chain=forward connection-mark="PORT BERAT" \
    in-interface=eth1-internet new-packet-mark="PORT BERAT DOWNLOAD" \
    passthrough=yes
add action=mark-packet chain=forward connection-mark="PORT BERAT" \
    new-packet-mark="PORT BERAT UPLOAD" out-interface=eth1-internet \
    passthrough=yes
add action=mark-connection chain=postrouting comment=\
    "RETURN PORT WEIGHT TO PORT GAME" connection-mark="PORT BERAT" \
    connection-rate=0-200k new-connection-mark="PORT GAME" passthrough=yes
add action=mark-connection chain=postrouting comment=ICMP \
    new-connection-mark=ICMP passthrough=yes protocol=icmp
add action=mark-packet chain=forward connection-mark=ICMP in-interface=\
    eth1-internet new-packet-mark="ICMP DOWNLOAD" passthrough=yes
add action=mark-packet chain=forward connection-mark=ICMP new-packet-mark=\
    "ICMP UPLOAD" out-interface=eth1-internet passthrough=yes
add action=mark-connection chain=postrouting comment=SOSMED dst-address-list=\
    "IP SOSMED" new-connection-mark=SOSMED passthrough=yes
add action=mark-packet chain=forward connection-mark=SOSMED in-interface=\
    eth1-internet new-packet-mark="SOSMED DOWNLOAD" passthrough=yes
add action=mark-packet chain=forward connection-mark=SOSMED new-packet-mark=\
    "SOSMED UPLOAD" out-interface=eth1-internet passthrough=yes
add action=mark-connection chain=postrouting comment=YOUTUBE \
    dst-address-list="IP YOUTUBE" new-connection-mark=YT passthrough=yes
add action=mark-packet chain=forward connection-mark=YT in-interface=\
    eth1-internet new-packet-mark="YOUTUBE DOWNLOAD" passthrough=yes
add action=mark-packet chain=forward connection-mark=YT new-packet-mark=\
    "YOUTUBE UPLOAD" out-interface=eth1-internet passthrough=yes
/ip firewall nat
add action=passthrough chain=unused-hs-chain comment=\
    "place hotspot rules here"
add action=masquerade chain=srcnat out-interface=eth1-internet
add action=masquerade chain=srcnat comment="masquerade hotspot network" \
    src-address=192.168.12.0/24
add action=passthrough chain=unused-hs-chain comment=\
    "place hotspot rules here" disabled=yes
add action=accept chain=srcnat disabled=yes
add action=masquerade chain=srcnat comment=MyTunnel-DNS out-interface=\
    MyTunnel-DNS
/ip firewall raw
add action=add-dst-to-address-list address-list="IP YOUTUBE" \
    address-list-timeout=1d chain=prerouting comment=YOUTUBE.COM content=\
    googlevideo.com dst-address-list="!IP LOCAL"
add action=add-dst-to-address-list address-list="IP SOSMED" \
    address-list-timeout=1d chain=prerouting comment=INSTAGRAM content=\
    .cdninstagram.com dst-address-list="!IP LOCAL"
add action=add-dst-to-address-list address-list="IP SOSMED" \
    address-list-timeout=1d chain=prerouting comment=INSTAGRAM content=\
    scontent-sin6-2.cdninstagram.com dst-address-list="!IP LOCAL"
add action=add-dst-to-address-list address-list="IP SOSMED" \
    address-list-timeout=1d chain=prerouting comment=INSTAGRAM content=\
    .instagram. dst-address-list="!IP LOCAL"
add action=add-dst-to-address-list address-list="IP SOSMED" \
    address-list-timeout=1d chain=prerouting comment=WHATSAPP content=\
    .whatsapp.net dst-address-list="!IP LOCAL"
add action=add-dst-to-address-list address-list="IP SOSMED" \
    address-list-timeout=1d chain=prerouting comment=WHATSAPP content=\
    .whatsapp.com dst-address-list="!IP LOCAL"
add action=add-dst-to-address-list address-list="IP SOSMED" \
    address-list-timeout=1d chain=prerouting comment=fb content=.facebook.com \
    dst-address-list="!IP LOCAL"
add action=add-dst-to-address-list address-list="IP SOSMED" \
    address-list-timeout=1d chain=prerouting comment=fb content=.facebook.net \
    dst-address-list="!IP LOCAL"
add action=add-dst-to-address-list address-list="IP SOSMED" \
    address-list-timeout=1d chain=prerouting comment=fb content=.fbcdn.net \
    dst-address-list="!IP LOCAL"
add action=add-dst-to-address-list address-list="IP SOSMED" \
    address-list-timeout=1d chain=prerouting comment=twitter content=\
    .twitter.com dst-address-list="!IP LOCAL"
add action=add-dst-to-address-list address-list="IP SOSMED" \
    address-list-timeout=1d chain=prerouting comment=twitter content=\
    twitter.com dst-address-list="!IP LOCAL"
add action=add-dst-to-address-list address-list="IP SOSMED" \
    address-list-timeout=1d chain=prerouting comment=twitter content=\
    .twimg.com dst-address-list="!IP LOCAL"
add action=add-dst-to-address-list address-list="IP SOSMED" \
    address-list-timeout=1d chain=prerouting comment=.telegram.org content=\
    .telegram.org dst-address-list="!IP LOCAL"
add action=add-dst-to-address-list address-list="IP SOSMED" \
    address-list-timeout=1d chain=prerouting comment=.telegram.org content=\
    telegram.org dst-address-list="!IP LOCAL"
add action=add-dst-to-address-list address-list="IP SOSMED" \
    address-list-timeout=1d chain=prerouting comment=tiktokcdn.com content=\
    tiktokcdn.com dst-address-list="!IP LOCAL"
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=DOTA2 dst-address-list=\
    "!IP LOCAL" dst-port=27000-28998 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=PALADINS \
    dst-address-list="!IP LOCAL" dst-port=9000-9999 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=WARFRAME \
    dst-address-list="!IP LOCAL" dst-port=6695-6699 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="POINT BLANK - Zepetto" \
    dst-address-list="!IP LOCAL" dst-port=39190-39200,49001-49190 protocol=\
    tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="FIFA ONLINE" \
    dst-address-list="!IP LOCAL" dst-port=7770-7790 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=LOL dst-address-list=\
    "!IP LOCAL" dst-port=2080-2099 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=HON dst-address-list=\
    "!IP LOCAL" dst-port=11031 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=DRAGONNEST \
    dst-address-list="!IP LOCAL" dst-port=14300-14440 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="LOST SAGA" \
    dst-address-list="!IP LOCAL" dst-port=14000-14050 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="BLACK SQUAD" \
    dst-address-list="!IP LOCAL" dst-port=61000,62000 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="ECHO OF SOUL (EOS)" \
    dst-address-list="!IP LOCAL" dst-port=7800 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=CROSSFIRE \
    dst-address-list="!IP LOCAL" dst-port=10009 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="IDOL STREET" \
    dst-address-list="!IP LOCAL" dst-port=2001-2010 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="RF ONLINE" \
    dst-address-list="!IP LOCAL" dst-port=27780 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="ROHAN ONLINE" \
    dst-address-list="!IP LOCAL" dst-port=22100 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="PERFECT WORLD" \
    dst-address-list="!IP LOCAL" dst-port=29000 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=AYODANCE \
    dst-address-list="!IP LOCAL" dst-port=18900-18910 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="COUNTER-STRIKE ONLINE" \
    dst-address-list="!IP LOCAL" dst-port=36567,8001 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=AYOOKE dst-address-list=\
    "!IP LOCAL" dst-port=28001-28010 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="SPECIAL FORCE" \
    dst-address-list="!IP LOCAL" dst-port=27920-27940 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=X-SHOT dst-address-list=\
    "!IP LOCAL" dst-port=7320-7350 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="MERCENARY OPS" \
    dst-address-list="!IP LOCAL" dst-port=6000-6125 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="PERFECT WORLD" \
    dst-address-list="!IP LOCAL" dst-port=29000 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="LINE GET RICH" \
    dst-address-list="!IP LOCAL" dst-port=10500-10515 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="COC (CLASH OF CLANS)" \
    dst-address-list="!IP LOCAL" dst-port=9330-9340 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="DOMINO QQ" \
    dst-address-list="!IP LOCAL" dst-port=9122,11000-11150 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=\
    "SEVEN KNIGHTS (NETMARBLE)" dst-address-list="!IP LOCAL" dst-port=\
    12000-12010 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="CLASH ROYALE (CRY)" \
    dst-address-list="!IP LOCAL" dst-port=9330-9340 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="LAST EMPIRE WAR Z" \
    dst-address-list="!IP LOCAL" dst-port=9930-9940 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=MOSTLY dst-address-list=\
    "!IP LOCAL" dst-port=9933 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="SHINOBI HEROES" \
    dst-address-list="!IP LOCAL" dst-port=10005-10020 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=\
    "NARUTO LITTLE NINJA (CHINA)" dst-address-list="!IP LOCAL" dst-port=\
    6170-6180 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=\
    "POINT BLANK MOBILE / PB MOBILE" dst-address-list="!IP LOCAL" dst-port=\
    44590-44610 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=\
    "MOBILE LEGENDS: BANG BANG (ML)" dst-address-list="!IP LOCAL" dst-port=\
    5501-5508,5551-5558,5601-5608,5651-5658,30097-30147 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=\
    "MOBILE LEGENDS: BANG BANG (ML)" dst-address-list="!IP LOCAL" dst-port=\
    5501-5508,5551-5558,5601-5608,5651-5658,30097-30147 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=\
    "ARENA OF VALOR (AOV)  GARENA" dst-address-list="!IP LOCAL" dst-port=\
    10001-10094 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=\
    "ARENA OF VALOR (AOV)  GARENA" dst-address-list="!IP LOCAL" dst-port=\
    10101-10201,10080-10110,17000-18000 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="DANCE UP INDO" \
    dst-address-list="!IP LOCAL" dst-port=10000-10010 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="BOOYA CAPSA SUSUN" \
    dst-address-list="!IP LOCAL" dst-port=7090-7100 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="BOOYA DOMINO QIUQIU" \
    dst-address-list="!IP LOCAL" dst-port=7020-7030 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="Free fire garena" \
    dst-address-list="!IP LOCAL" dst-port=39698,39003,39779 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=DOTA2 dst-address-list=\
    "!IP LOCAL" dst-port=27000-28998 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=PUBG dst-address-list=\
    "!IP LOCAL" dst-port=7086-7995,12070-12460,41182-41192 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=PUBG dst-address-list=\
    "!IP LOCAL" dst-port=10012,17500 protocol=tcp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=PALADINS \
    dst-address-list="!IP LOCAL" dst-port=9000-9999 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=BLACKRETRIBUTION \
    dst-address-list="!IP LOCAL" dst-port=7020-7050,8200-8220,9000-9020 \
    protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="LEFT4DEAD 2" \
    dst-address-list="!IP LOCAL" dst-port=4360-4390 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=WARFRAME \
    dst-address-list="!IP LOCAL" dst-port=4950-4955 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="LAST MAN TANDING" \
    dst-address-list="!IP LOCAL" dst-port=34000-34025,3500 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="POINT BLANK - Zepetto" \
    dst-address-list="!IP LOCAL" dst-port=40000-40010 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="FIFA ONLINE" \
    dst-address-list="!IP LOCAL" dst-port=16300-16350 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=LOL dst-address-list=\
    "!IP LOCAL" dst-port=5100 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=HON dst-address-list=\
    "!IP LOCAL" dst-port=11100-11125,11440-11460 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=DRAGONNEST \
    dst-address-list="!IP LOCAL" dst-port=15000-15500 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="LOST SAGA" \
    dst-address-list="!IP LOCAL" dst-port=14000-14050 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="BLACK SQUAD" \
    dst-address-list="!IP LOCAL" dst-port=50000-50100 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="ECHO OF SOUL (EOS)" \
    dst-address-list="!IP LOCAL" dst-port=5355 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=CROSSFIRE \
    dst-address-list="!IP LOCAL" dst-port=12060-12070 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="COUNTER-STRIKE ONLINE" \
    dst-address-list="!IP LOCAL" dst-port=8001 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=AYOOKE dst-address-list=\
    "!IP LOCAL" dst-port=26001-26010 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="SPECIAL FORCE" \
    dst-address-list="!IP LOCAL" dst-port=30000-30030 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=X-SHOT dst-address-list=\
    "!IP LOCAL" dst-port=7800-7850,30000 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=ROBLOX dst-address-list=\
    "!IP LOCAL" dst-port=56849-57729,60275-64632 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="RULES OF SURVIVAL" \
    dst-address-list="!IP LOCAL" dst-port=24000-24050 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="CLASH ROYALE (CRY)" \
    dst-address-list="!IP LOCAL" dst-port=9330-9340 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="DREAM LEAGUE SOCCER" \
    dst-address-list="!IP LOCAL" dst-port=60970-60980 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="RPG TORAM ONLINE" \
    dst-address-list="!IP LOCAL" dst-port=30100-30110 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=\
    "ARENA OF VALOR (AOV)  GARENA" dst-address-list="!IP LOCAL" dst-port=\
    10080,17000 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment="Free fire garena" \
    dst-address-list="!IP LOCAL" dst-port=10000-10007,7008 protocol=udp
add action=add-dst-to-address-list address-list="IP GAME ONLINE" \
    address-list-timeout=1d chain=prerouting comment=PUBG dst-address-list=\
    "!IP LOCAL" dst-port="10491,10010,10013,10612,20002,20001,20000,12235,1374\
    8,13972,13894,11455,10096,10039" protocol=udp
/ip hotspot ip-binding
add comment="hp zzh" mac-address=1C:B7:2C:47:C9:73
add comment="hp udin" mac-address=A4:D9:90:37:57:51 type=bypassed
add comment="hp ms dvd" mac-address=14:DD:A9:B0:23:F5
add comment="hp iin" mac-address=34:97:F6:C6:0F:DA type=bypassed
add comment="lp udin" disabled=yes mac-address=54:27:1E:46:A8:03 type=\
    bypassed
add mac-address=40:40:A7:56:5E:98
add comment="lp dvd" mac-address=AC:9E:17:9B:CE:A4
add comment="lp dvd" mac-address=10:08:B1:43:98:EF
add comment="lp iin" mac-address=24:FD:52:03:46:15
add comment="hp buknik" mac-address=4C:49:E3:15:CC:E1
add comment="sony putih" mac-address=30:A8:DB:CB:AE:AB
add comment="lp fsl" mac-address=24:FD:52:B5:13:FB
add comment="lp zizah" mac-address=50:AF:73:02:32:E4
add comment=FERI mac-address=F0:6D:78:3F:31:24
add comment=nsm2 mac-address=B4:FB:E4:5C:DC:00 type=bypassed
add comment=nsm2feri mac-address=68:72:51:76:55:5D type=bypassed
add comment=mikrotikferi mac-address=B8:69:F4:3B:55:73 type=bypassed
add comment=7glink mac-address=44:D1:FA:41:46:D1 type=bypassed
add comment=f609feri mac-address=D4:76:EA:DD:DB:23 type=bypassed
add comment="lp udin lan" mac-address=40:16:7E:95:9D:AC
add comment="hp nia" mac-address=80:AD:16:75:AC:62
add comment=riski disabled=yes mac-address=74:C6:3B:B9:E6:CD type=bypassed
add address=192.168.12.5 comment="AP MikroTik" type=bypassed
add comment=nfl mac-address=64:B0:A6:37:70:0C type=bypassed
add comment=blacklist disabled=yes mac-address=3C:B6:B7:3F:E7:1F type=blocked
add comment="AP TENDA MASJID" mac-address=D8:32:14:61:41:99 type=bypassed
add comment="AP TENDA MASJID" mac-address=D8:32:14:61:41:98 type=bypassed
add comment="AP TENDA ANDRE" mac-address=D8:32:14:60:AD:61 type=bypassed
add mac-address=0C:98:38:D7:52:FF type=bypassed
add comment="hp mas faisal" mac-address=D0:9C:7A:0F:91:2A type=bypassed
add comment="AP TENDA ISAL" mac-address=58:D9:D5:B3:F3:91 type=bypassed
/ip hotspot user
add comment=up- limit-uptime=12h name=ASLYJ password=8309 profile=1hari
add comment=up- limit-uptime=12h name=AEYJN password=2340 profile=1hari
add comment=up- limit-uptime=12h name=AUCWR password=5212 profile=1hari
add comment=up- name=BHABX password=7395 profile=2hari
add name=BBAXX password=7890
add name=BFUTG password=3677
add comment=up- name=BVEKS password=7758 profile=2hari
add comment=up- name=CCBZC password=2727 profile=7hari
add mac-address=48:D2:24:45:6E:A8 name=CEK password=1 profile=BINDING
add mac-address=54:27:1E:46:A8:03 name=54:27:1E:46:A8:03 password=\
    54:27:1E:46:A8:03 profile=VIP
add mac-address=1C:B7:2C:47:C9:73 name=1C:B7:2C:47:C9:73 password=\
    1C:B7:2C:47:C9:73 profile=BINDING
add mac-address=34:97:F6:C6:0F:DA name=34:97:F6:C6:0F:DA password=\
    34:97:F6:C6:0F:DA profile=BINDING
add mac-address=40:40:A7:56:5E:98 name=40:40:A7:56:5E:98 password=\
    40:40:A7:56:5E:98 profile=BINDING
add mac-address=10:08:B1:43:98:EF name=10:08:B1:43:98:EF password=\
    10:08:B1:43:98:EF profile=VIP
add name=AC:9E:17:9B:CE:A4 password=AC:9E:17:9B:CE:A4 profile=VIP
add mac-address=24:FD:52:03:46:15 name=24:FD:52:03:46:15 password=\
    24:FD:52:03:46:15 profile=BINDING
add mac-address=4C:49:E3:15:CC:E1 name=4C:49:E3:15:CC:E1 password=\
    4C:49:E3:15:CC:E1 profile=BINDING
add name=30:A8:DB:CB:AE:AB password=30:A8:DB:CB:AE:AB profile=BINDING
add name=24:FD:52:B5:13:FB password=24:FD:52:B5:13:FB profile=BINDING
add mac-address=50:AF:73:02:32:E4 name=50:AF:73:02:32:E4 password=\
    50:AF:73:02:32:E4 profile=BINDING
add mac-address=34:E9:11:2A:E1:65 name=34:E9:11:2A:E1:65 password=\
    34:E9:11:2A:E1:65 profile=BINDING
add mac-address=14:DD:A9:B0:23:F5 name=14:DD:A9:B0:23:F5 password=\
    14:DD:A9:B0:23:F5 profile=VIP
add mac-address=40:16:7E:95:9D:AC name=40:16:7E:95:9D:AC password=\
    40:16:7E:95:9D:AC profile=BINDING
add comment="hp udin" disabled=yes mac-address=A4:D9:90:37:57:51 name=\
    A4:D9:90:37:57:51 password=A4:D9:90:37:57:51 profile=BINDING
add mac-address=80:AD:16:75:AC:62 name=80:AD:16:75:AC:62 password=\
    80:AD:16:75:AC:62 profile=BINDING
add comment=up-881-09.20.19-7H20Sept19 name=CXGCN password=5778 profile=7hari
add comment="jan/07/2020 11:03:02" limit-uptime=1s mac-address=\
    24:79:F3:6D:00:5D name=CKYUV password=5837 profile=7hari
add comment="jan/06/2020 08:28:03" limit-uptime=1s mac-address=\
    C0:87:EB:4A:C9:1F name=CUJUS password=9668 profile=7hari
add comment="jan/04/2020 21:42:42" limit-uptime=1s mac-address=\
    2C:FF:EE:96:FA:23 name=CHXCH password=6989 profile=7hari
add comment="jan/02/2020 17:24:24" limit-uptime=1s mac-address=\
    C0:87:EB:D5:D4:69 name=CWVSZ password=6279 profile=7hari
add comment="jan/10/2020 20:31:56" limit-uptime=1s mac-address=\
    E0:99:71:C7:B6:9F name=CBRZF password=2788 profile=7hari
add comment="jan/21/2020 10:04:59" mac-address=08:7F:98:C7:BC:29 name=CVITV \
    password=7326 profile=7hari
add comment=up-869-09.28.19-feri7h name=CRRET password=4648 profile=7hari
add comment="jan/10/2020 06:38:40" limit-uptime=1s mac-address=\
    A4:D9:90:28:BB:33 name=CRSPJ password=9925 profile=7hari
add comment="jan/24/2020 19:33:47" mac-address=A4:D9:90:28:BB:33 name=CTNZE \
    password=9633 profile=7hari
add comment="jan/02/2020 07:30:12" limit-uptime=1s mac-address=\
    A4:D9:90:28:BB:33 name=CAMYM password=6358 profile=7hari
add comment="jan/13/2020 22:02:33" limit-uptime=1s mac-address=\
    08:7F:98:C7:BC:29 name=CTXTY password=2495 profile=7hari
add comment=up-869-09.28.19-feri7h name=CNSNA password=2397 profile=7hari
add comment="jan/17/2020 07:01:57" limit-uptime=1s mac-address=\
    A4:D9:90:28:BB:33 name=CIGGT password=5394 profile=7hari
add comment=up-402-10.12.19-2hari101219 name=BEGPP password=9299 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BJHMV password=2786 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BUEJR password=8834 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BHYFA password=4323 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BDNAA password=6843 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BEYWR password=6923 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BDMES password=8889 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BNJUY password=2364 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BBASK password=3853 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BLEPW password=3444 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BGKEK password=2795 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BREWE password=5325 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BPFGS password=5586 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BYHHR password=6226 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BSNZX password=7579 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BPEDT password=2879 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BXWXA password=7628 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BHHYN password=4473 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BPGAZ password=7339 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BKJXL password=6363 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BMBSZ password=6684 profile=\
    2hari
add comment=feri mac-address=F0:6D:78:3F:31:24 name=F0:6D:78:3F:31:24 \
    password=F0:6D:78:3F:31:24 profile=BINDING
add comment=up-347-10.20.19-1hariferi20ct name=AAJVX password=9857 profile=\
    1hari
add comment=up- name=BPYFU password=7982 profile=2hari
add comment="vc-Hp Ulfa" mac-address=80:AD:16:76:6E:5E name=80:AD:16:76:6E:5E \
    password=80:AD:16:76:6E:5E profile=BINDING
add comment=up-780-11.28.19-2HARI2811 name=BKUZN password=7296 profile=2hari
add comment=up-780-11.28.19-2HARI2811 name=BXITA password=2686 profile=2hari
add comment=up-780-11.28.19-2HARI2811 name=BJXUH password=8537 profile=2hari
add comment=up-780-11.28.19-2HARI2811 name=BEGIX password=4469 profile=2hari
add comment="jan/05/2020 20:43:51" limit-uptime=1s mac-address=\
    08:7F:98:C7:BC:29 name=BXFXW password=6948 profile=2hari
add comment="jan/04/2020 14:54:59" limit-uptime=1s mac-address=\
    18:02:AE:9F:82:7F name=BMBPN password=8676 profile=2hari
add comment="jan/06/2020 14:32:06" limit-uptime=1s mac-address=\
    08:7F:98:B0:5B:A1 name=BXJGT password=3479 profile=2hari
add comment="jan/03/2020 17:27:19" limit-uptime=1s mac-address=\
    08:7F:98:C7:BC:29 name=BGNEI password=5376 profile=2hari
add comment=up-780-11.28.19-2HARI2811 name=BGWTB password=3533 profile=2hari
add comment="jan/02/2020 09:26:01" limit-uptime=1s mac-address=\
    C0:87:EB:EE:62:DB name=AIVDE password=9736 profile=1hari
add comment="jan/02/2020 16:02:52" limit-uptime=1s mac-address=\
    0C:98:38:FC:E3:AF name=AWHZD password=9334 profile=1hari
add comment="jan/04/2020 15:07:05" limit-uptime=1s mac-address=\
    00:27:15:53:63:97 name=ADCBM password=5727 profile=1hari
add comment="jan/05/2020 18:46:07" limit-uptime=1s mac-address=\
    00:27:15:53:63:97 name=AVDEG password=4329 profile=1hari
add comment="jan/04/2020 16:32:54" limit-uptime=1s mac-address=\
    2C:5D:34:99:CF:2B name=ARIRK password=4247 profile=1hari
add comment="jan/06/2020 23:33:54" limit-uptime=1s mac-address=\
    00:27:15:53:63:97 name=AJWTF password=5746 profile=1hari
add comment="jan/06/2020 21:59:53" limit-uptime=1s mac-address=\
    08:7F:98:C7:BC:29 name=AJVEN password=4942 profile=1hari
add comment="jan/06/2020 21:40:58" limit-uptime=1s mac-address=\
    48:88:CA:0B:65:02 name=AFEMM password=4428 profile=1hari
add comment=up-905-12.20.19- name=ASRUJ password=8796 profile=1hari
add comment=up-905-12.20.19- name=APWMN password=2896 profile=1hari
add comment=up-905-12.20.19- name=AUMSM password=6647 profile=1hari
add comment=up-905-12.20.19- name=AYFBA password=8978 profile=1hari
add comment=up-905-12.20.19- name=AWYIY password=8787 profile=1hari
add comment=up-905-12.20.19- name=AFFHX password=2469 profile=1hari
add comment=up-905-12.20.19- name=AWYUT password=6865 profile=1hari
add comment=up-905-12.20.19- name=AMVHC password=8779 profile=1hari
add comment=up-905-12.20.19- name=AWPWV password=7962 profile=1hari
add comment=up-905-12.20.19- name=ATZBR password=9327 profile=1hari
add comment=up-905-12.20.19- name=AWVSG password=4486 profile=1hari
add comment=up-905-12.20.19- name=AYUMM password=6865 profile=1hari
add comment=up-905-12.20.19- name=AUPFC password=5739 profile=1hari
add comment=up-905-12.20.19- name=ACCSU password=7649 profile=1hari
add comment=up-905-12.20.19- name=ASAMF password=2382 profile=1hari
add comment=up-905-12.20.19- name=AFBNH password=4443 profile=1hari
add comment=up-905-12.20.19- name=APZMT password=2772 profile=1hari
add comment=up-905-12.20.19- name=AIPCF password=4365 profile=1hari
add comment=up-905-12.20.19- name=AJPEP password=7579 profile=1hari
add comment=up-905-12.20.19- name=AKTKM password=8395 profile=1hari
add comment=up-905-12.20.19- name=AFURU password=7327 profile=1hari
add comment=up-905-12.20.19- name=AMKKC password=8374 profile=1hari
add comment=up-905-12.20.19- name=AANUG password=2263 profile=1hari
add comment=up-905-12.20.19- name=ANVEA password=4562 profile=1hari
add comment=up-905-12.20.19- name=AUYRD password=2246 profile=1hari
add comment=up-905-12.20.19- name=AMTSH password=3767 profile=1hari
add comment=up-905-12.20.19- name=AMXEI password=5238 profile=1hari
add comment=up-905-12.20.19- name=AKFXZ password=6992 profile=1hari
add comment=up-905-12.20.19- name=AEKMY password=4349 profile=1hari
add comment=up-905-12.20.19- name=AJHUY password=5554 profile=1hari
add comment=up-905-12.20.19- name=AWPMV password=7588 profile=1hari
add comment="jan/05/2020 19:31:38" limit-uptime=1s mac-address=\
    20:5E:F7:FA:47:BC name=BNTUS password=5883 profile=2hari
add comment="jan/15/2020 19:35:21" limit-uptime=1s mac-address=\
    0C:A8:A7:11:EF:5C name=BFGBF password=4293 profile=2hari
add comment="jan/06/2020 19:08:15" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=BLDHF password=5396 profile=2hari
add comment="jan/13/2020 18:38:02" limit-uptime=1s mac-address=\
    60:72:8D:62:53:EB name=BXKBC password=7443 profile=2hari
add comment="jan/09/2020 20:54:36" limit-uptime=1s mac-address=\
    20:5E:F7:FA:47:BC name=BEDHF password=6577 profile=2hari
add comment="jan/15/2020 15:51:41" limit-uptime=1s mac-address=\
    A4:D9:90:74:41:79 name=BDMFZ password=8276 profile=2hari
add comment="jan/14/2020 00:29:44" limit-uptime=1s mac-address=\
    20:5E:F7:FA:47:BC name=BAAJF password=8385 profile=2hari
add comment="jan/06/2020 22:01:35" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=BTLKX password=6682 profile=2hari
add comment="jan/13/2020 20:26:27" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=BWMDP password=6942 profile=2hari
add comment="jan/18/2020 22:11:48" mac-address=6C:D7:1F:23:3C:79 name=BJFWH \
    password=5878 profile=2hari
add comment="jan/11/2020 21:29:11" limit-uptime=1s mac-address=\
    20:5E:F7:FA:47:BC name=BEVFU password=6735 profile=2hari
add comment="jan/06/2020 20:01:05" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=BBMVT password=6989 profile=2hari
add comment="jan/13/2020 20:07:03" limit-uptime=1s mac-address=\
    0C:98:38:FC:E3:AF name=BRCGB password=3624 profile=2hari
add comment="jan/18/2020 21:00:21" mac-address=74:29:AF:E8:0E:17 name=BJVWN \
    password=4568 profile=2hari
add comment="jan/16/2020 19:12:34" limit-uptime=1s mac-address=\
    74:29:AF:E8:0E:17 name=BLMNS password=8765 profile=2hari
add comment="jan/04/2020 21:59:50" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=BZWYY password=8836 profile=2hari
add comment="jan/09/2020 21:51:50" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=BVRUA password=9838 profile=2hari
add comment="jan/13/2020 20:09:31" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=BPMUT password=8432 profile=2hari
add comment="jan/06/2020 20:37:42" limit-uptime=1s mac-address=\
    6C:D7:1F:23:3C:79 name=BJPHT password=4592 profile=2hari
add comment="jan/04/2020 17:43:51" limit-uptime=1s mac-address=\
    6C:D7:1F:23:3C:79 name=BRNMF password=3677 profile=2hari
add comment="jan/05/2020 18:29:57" limit-uptime=1s mac-address=\
    CC:2D:83:90:04:D7 name=BRLSC password=8939 profile=2hari
add comment="jan/13/2020 14:44:11" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=BCZMB password=7447 profile=2hari
add comment="jan/13/2020 10:50:13" limit-uptime=1s mac-address=\
    20:F7:7C:21:6E:89 name=BWYUV password=7577 profile=2hari
add comment="jan/02/2020 21:52:18" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=BPZEE password=6326 profile=2hari
add comment="jan/09/2020 23:42:27" limit-uptime=1s mac-address=\
    38:A4:ED:A1:2E:37 name=BAPPS password=9225 profile=2hari
add comment="jan/10/2020 10:25:01" limit-uptime=1s mac-address=\
    4C:1A:3D:83:30:70 name=BERBG password=9837 profile=2hari
add comment="jan/13/2020 12:20:47" limit-uptime=1s mac-address=\
    C4:0B:CB:E3:2B:3C name=BHXGA password=3749 profile=2hari
add comment="jan/13/2020 06:02:27" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=BUPNR password=2385 profile=2hari
add comment="jan/05/2020 13:41:56" limit-uptime=1s mac-address=\
    20:5E:F7:76:C8:12 name=BLTFC password=9662 profile=2hari
add comment="jan/16/2020 11:23:26" limit-uptime=1s mac-address=\
    20:5E:F7:FA:47:BC name=BKZKA password=2848 profile=2hari
add comment="jan/13/2020 20:44:29" limit-uptime=1s mac-address=\
    CC:2D:83:90:04:D7 name=BSNKE password=7358 profile=2hari
add comment="jan/12/2020 20:15:07" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=BNVKK password=2995 profile=2hari
add comment="jan/02/2020 09:32:41" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=BXTCU password=9786 profile=2hari
add comment="jan/02/2020 20:14:16" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=BMAFX password=8329 profile=2hari
add comment="jan/14/2020 22:50:40" limit-uptime=1s mac-address=\
    6C:D7:1F:23:3C:79 name=BCLNR password=6454 profile=2hari
add comment="jan/10/2020 16:50:15" limit-uptime=1s mac-address=\
    C0:87:EB:35:15:4B name=BLWVT password=9754 profile=2hari
add comment="jan/11/2020 19:52:33" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=BGWTW password=6938 profile=2hari
add comment="jan/07/2020 19:04:03" limit-uptime=1s mac-address=\
    74:29:AF:E8:0E:17 name=BJFBW password=5325 profile=2hari
add comment="jan/02/2020 10:20:10" limit-uptime=1s mac-address=\
    A8:DB:03:0B:C2:F3 name=BNHDH password=3744 profile=2hari
add comment="jan/05/2020 00:15:51" limit-uptime=1s mac-address=\
    38:A4:ED:A1:2E:37 name=BCVTE password=2524 profile=2hari
add comment="jan/10/2020 16:13:26" limit-uptime=1s mac-address=\
    00:0A:F5:C2:FC:7C name=BRLMP password=8784 profile=2hari
add comment="jan/11/2020 19:35:14" limit-uptime=1s mac-address=\
    0C:98:38:FC:E3:AF name=BXADJ password=2342 profile=2hari
add comment="jan/06/2020 20:49:39" limit-uptime=1s mac-address=\
    0C:98:38:FC:E3:AF name=BSEME password=7753 profile=2hari
add comment="jan/14/2020 17:54:18" limit-uptime=1s mac-address=\
    74:29:AF:E8:0E:17 name=BSLTL password=2355 profile=2hari
add comment="jan/09/2020 19:27:27" limit-uptime=1s mac-address=\
    74:29:AF:E8:0E:17 name=BDCTZ password=8263 profile=2hari
add comment="jan/02/2020 18:28:16" limit-uptime=1s mac-address=\
    00:0A:F5:C2:FC:7C name=BRZYB password=5579 profile=2hari
add comment="jan/06/2020 22:23:26" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=BWSAN password=7374 profile=2hari
add comment="jan/02/2020 21:00:49" limit-uptime=1s mac-address=\
    00:0A:F5:4E:69:4C name=BLULJ password=7593 profile=2hari
add comment="jan/10/2020 20:38:35" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=BDPUS password=8879 profile=2hari
add comment="jan/07/2020 21:48:47" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=BHBVA password=5293 profile=2hari
add comment="jan/09/2020 19:25:20" limit-uptime=1s mac-address=\
    0C:98:38:FC:E3:AF name=BUYFF password=3356 profile=2hari
add comment="jan/05/2020 12:07:51" limit-uptime=1s mac-address=\
    00:0A:F5:C2:FC:7C name=BDYWB password=7829 profile=2hari
add comment="jan/02/2020 11:05:53" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=BYKRK password=5756 profile=2hari
add comment="jan/04/2020 14:51:28" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=BWKGL password=2484 profile=2hari
add comment="jan/10/2020 19:14:16" limit-uptime=1s mac-address=\
    CC:2D:83:AA:45:CD name=BTMDC password=7622 profile=2hari
add comment="jan/08/2020 12:30:58" limit-uptime=1s mac-address=\
    00:0A:F5:C2:FC:7C name=BHMXB password=8235 profile=2hari
add comment="jan/11/2020 17:44:45" limit-uptime=1s mac-address=\
    60:72:8D:62:53:EB name=BLEJD password=4695 profile=2hari
add comment="jan/04/2020 19:32:30" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=BVFFA password=9895 profile=2hari
add comment="jan/14/2020 07:57:23" limit-uptime=1s mac-address=\
    20:5E:F7:76:C8:12 name=BWGYF password=2846 profile=2hari
add comment="jan/10/2020 19:04:02" limit-uptime=1s mac-address=\
    20:F7:7C:21:6E:89 name=BSLAZ password=7799 profile=2hari
add comment="jan/08/2020 08:57:28" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=BMUHH password=3285 profile=2hari
add comment="jan/11/2020 15:06:07" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=BBYNZ password=3845 profile=2hari
add comment="jan/05/2020 11:11:18" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=BCVKU password=7652 profile=2hari
add comment=up-441-12.23.19-2hariudin name=BSKFM password=7956 profile=2hari
add comment="jan/02/2020 22:08:45" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=BTTRA password=7372 profile=2hari
add comment="jan/07/2020 20:39:51" limit-uptime=1s mac-address=\
    20:5E:F7:FA:47:BC name=BFSUP password=3669 profile=2hari
add comment="jan/09/2020 14:01:56" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=BZZGA password=7672 profile=2hari
add comment="jan/04/2020 18:45:37" limit-uptime=1s mac-address=\
    0C:98:38:FC:E3:AF name=BUMAB password=2393 profile=2hari
add comment="jan/06/2020 21:43:03" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=BFXRK password=3292 profile=2hari
add comment="jan/04/2020 07:50:40" limit-uptime=1s mac-address=\
    A4:D9:90:74:41:79 name=BMTEG password=6866 profile=2hari
add comment="jan/09/2020 19:36:36" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=BXMAL password=9929 profile=2hari
add comment="jan/07/2020 08:14:40" limit-uptime=1s mac-address=\
    C0:87:EB:35:15:4B name=BBDFK password=4842 profile=2hari
add comment="jan/08/2020 20:04:52" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=BEXPY password=7373 profile=2hari
add comment="jan/03/2020 16:48:11" limit-uptime=1s mac-address=\
    F4:D6:20:BD:64:66 name=BCPXW password=6892 profile=2hari
add comment="jan/08/2020 22:08:53" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=BDPGP password=4978 profile=2hari
add comment="jan/12/2020 11:19:52" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=BDFKT password=5266 profile=2hari
add comment="jan/03/2020 09:43:54" limit-uptime=1s mac-address=\
    4C:1A:3D:83:30:70 name=BARPN password=7523 profile=2hari
add comment="jan/11/2020 22:31:39" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=BCLFE password=3589 profile=2hari
add comment="jan/12/2020 17:51:00" limit-uptime=1s mac-address=\
    00:0A:F5:C2:FC:7C name=BKUES password=5754 profile=2hari
add mac-address=64:B0:A6:37:70:0C name=64:B0:A6:37:70:0C password=\
    64:B0:A6:37:70:0C profile=BINDING
add comment=up- mac-address=3C:B6:B7:4C:3E:41 name=ROBBI password=123 \
    profile=VIP
add mac-address=2C:33:7A:0B:D9:AF name=2C:33:7A:0B:D9:AF password=\
    2C:33:7A:0B:D9:AF profile=BINDING
add comment="jan/02/2020 22:15:12" limit-uptime=1s mac-address=\
    18:89:5B:86:BB:08 name=AUWGV password=8876 profile=1hari
add name=user1
add comment="jan/04/2020 12:33:49" limit-uptime=1s mac-address=\
    08:7F:98:B0:5B:A1 name=ACHWC password=3745 profile=1hari
add comment="jan/02/2020 19:04:50" limit-uptime=1s mac-address=\
    10:2A:B3:49:D9:BB name=AFITZ password=9226 profile=1hari
add comment=up-258-01.01.20-1hariUdin name=AUBBE password=2499 profile=1hari
add comment=up-258-01.01.20-1hariUdin name=AXMHX password=2874 profile=1hari
add comment=up-258-01.01.20-1hariUdin name=ASAYR password=6662 profile=1hari
add comment=up-258-01.01.20-1hariUdin name=AXJSD password=5769 profile=1hari
add comment=up-258-01.01.20-1hariUdin name=AGHFD password=4738 profile=1hari
add comment="jan/10/2020 20:12:53" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=ARRKK password=9554 profile=1hari
add comment="jan/15/2020 20:03:57" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=ARABV password=4783 profile=1hari
add comment="jan/14/2020 23:22:52" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=ABFUX password=8233 profile=1hari
add comment="jan/14/2020 18:29:55" limit-uptime=1s mac-address=\
    3C:95:09:E7:6D:13 name=ATAHN password=5552 profile=1hari
add comment="jan/14/2020 16:17:14" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=AFDMJ password=8627 profile=1hari
add comment="jan/13/2020 17:58:18" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=AMIAH password=8296 profile=1hari
add comment="jan/12/2020 05:45:46" limit-uptime=1s mac-address=\
    08:7F:98:E1:84:ED name=ADJTA password=2887 profile=1hari
add comment="jan/03/2020 11:36:45" limit-uptime=1s mac-address=\
    60:72:8D:62:53:EB name=AZBFF password=5657 profile=1hari
add comment=up-258-01.01.20-1hariUdin name=AUBIU password=6965 profile=1hari
add comment=up-258-01.01.20-1hariUdin name=AECXG password=4895 profile=1hari
add comment=up-258-01.01.20-1hariUdin name=ABANN password=4947 profile=1hari
add comment=up-258-01.01.20-1hariUdin name=ADMAI password=4248 profile=1hari
add comment=up-258-01.01.20-1hariUdin name=ACHDK password=3896 profile=1hari
add comment=up-258-01.01.20-1hariUdin name=AVFRN password=6287 profile=1hari
add comment=up-258-01.01.20-1hariUdin name=AXZFK password=4569 profile=1hari
add comment=up-258-01.01.20-1hariUdin name=ADGTW password=2833 profile=1hari
add comment="jan/18/2020 11:12:20" limit-uptime=1s mac-address=\
    28:31:66:9A:D1:99 name=AIZVM password=7932 profile=1hari
add comment="jan/18/2020 11:10:26" limit-uptime=1s mac-address=\
    18:89:5B:86:BB:08 name=AFTGF password=8654 profile=1hari
add comment=up-258-01.01.20-1hariUdin name=APGWT password=4487 profile=1hari
add comment=up-258-01.01.20-1hariUdin name=ABKGT password=7289 profile=1hari
add comment=up-258-01.01.20-1hariUdin name=AMZHZ password=2649 profile=1hari
add comment="jan/18/2020 20:17:04" mac-address=08:8C:2C:E5:59:4D name=APPUG \
    password=9523 profile=1hari
add comment="jan/18/2020 20:31:59" mac-address=F0:6D:78:42:12:1A name=ADAGH \
    password=2687 profile=1hari
add comment=up-258-01.01.20-1hariUdin name=AWATY password=4742 profile=1hari
add comment="jan/19/2020 11:25:38" mac-address=18:89:5B:86:BB:08 name=AMITV \
    password=4542 profile=1hari
add comment="jan/08/2020 14:45:10" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=AVVCS password=8766 profile=1hari
add comment="jan/12/2020 11:05:10" limit-uptime=1s mac-address=\
    C0:87:EB:EE:62:DB name=APBRH password=7383 profile=1hari
add comment="jan/14/2020 07:42:05" limit-uptime=1s mac-address=\
    CC:2D:83:99:B0:19 name=AMYAN password=7786 profile=1hari
add comment="jan/16/2020 19:37:41" limit-uptime=1s mac-address=\
    6C:D7:1F:27:2E:83 name=AIDAZ password=5837 profile=1hari
add comment=up-258-01.01.20-1hariUdin name=AXJIK password=7594 profile=1hari
add comment=up-258-01.01.20-1hariUdin name=AXNWT password=4369 profile=1hari
add comment="jan/09/2020 12:30:08" limit-uptime=1s mac-address=\
    84:4B:F5:2A:51:C1 name=AAFEM password=9926 profile=1hari
add comment="jan/05/2020 22:53:52" limit-uptime=1s mac-address=\
    6C:D7:1F:27:2E:83 name=ACGDN password=4597 profile=1hari
add comment="jan/08/2020 07:13:08" limit-uptime=1s mac-address=\
    00:27:15:53:63:97 name=AXJKR password=4534 profile=1hari
add comment="jan/08/2020 12:38:24" limit-uptime=1s mac-address=\
    08:7F:98:F4:18:B1 name=ABIYM password=7643 profile=1hari
add comment="jan/04/2020 16:23:30" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=AKYFW password=2738 profile=1hari
add comment="jan/03/2020 11:08:44" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=AUVDM password=3662 profile=1hari
add comment="jan/03/2020 23:03:12" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=ATUKE password=9838 profile=1hari
add comment="jan/04/2020 14:37:49" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=ADPXR password=9487 profile=1hari
add comment="jan/05/2020 17:33:19" limit-uptime=1s mac-address=\
    C0:87:EB:EE:62:DB name=ATZDP password=2835 profile=1hari
add comment="jan/10/2020 19:14:15" limit-uptime=1s mac-address=\
    6C:D7:1F:27:2E:83 name=AFSBW password=9928 profile=1hari
add comment="jan/03/2020 21:20:08" limit-uptime=1s mac-address=\
    E4:F8:EF:85:DC:C0 name=AKMHCY password=5637 profile=1hari
add comment=up-258-01.01.20-1hariUdin name=ABDTD password=3546 profile=1hari
add comment="jan/06/2020 09:22:12" limit-uptime=1s mac-address=\
    60:72:8D:62:53:EB name=AXJZT password=9435 profile=1hari
add comment="jan/08/2020 14:36:02" limit-uptime=1s mac-address=\
    6C:D7:1F:27:2E:83 name=ARZWN password=6859 profile=1hari
add comment="jan/08/2020 19:07:24" limit-uptime=1s mac-address=\
    60:72:8D:62:53:EB name=AARBI password=7829 profile=1hari
add comment="jan/08/2020 19:01:17" limit-uptime=1s mac-address=\
    00:90:4C:C5:12:38 name=AXCJA password=3979 profile=1hari
add comment="jan/09/2020 20:10:15" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=AXERE password=7298 profile=1hari
add comment="jan/16/2020 16:36:14" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=AWPMP password=2975 profile=1hari
add comment="jan/17/2020 19:42:21" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=AMCSB password=9485 profile=1hari
add comment="jan/17/2020 19:35:17" limit-uptime=1s mac-address=\
    60:72:8D:62:53:EB name=APKAG password=2886 profile=1hari
add comment=up-258-01.01.20-1hariUdin name=AVIEA password=4467 profile=1hari
add comment="jan/18/2020 19:25:56" mac-address=5C:66:6C:D0:1F:37 name=AZRAB \
    password=5694 profile=1hari
add comment=up-258-01.01.20-1hariUdin name=AWZEC password=2355 profile=1hari
add comment="jan/17/2020 16:58:52" limit-uptime=1s mac-address=\
    3C:95:09:E7:6D:13 name=ACDKY password=9297 profile=1hari
add comment="jan/06/2020 09:49:49" limit-uptime=1s mac-address=\
    34:8B:75:02:80:83 name=AYRGX password=9389 profile=1hari
add comment="jan/17/2020 13:30:52" limit-uptime=1s mac-address=\
    C4:E1:A1:F7:5A:6D name=AAJXR password=5962 profile=1hari
add comment="jan/17/2020 07:45:35" limit-uptime=1s mac-address=\
    4C:1A:3D:83:30:70 name=AENMZ password=6886 profile=1hari
add comment="jan/16/2020 23:36:27" limit-uptime=1s mac-address=\
    88:5A:06:66:12:E5 name=AFVYP password=7823 profile=1hari
add comment="jan/12/2020 22:45:00" limit-uptime=1s mac-address=\
    6C:D7:1F:23:3C:79 name=AWYWG password=9648 profile=1hari
add comment="jan/14/2020 17:52:10" limit-uptime=1s mac-address=\
    18:89:5B:86:BB:08 name=AVSBU password=8833 profile=1hari
add comment="jan/05/2020 19:12:16" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=AVVHV password=3358 profile=1hari
add comment="jan/13/2020 17:47:22" limit-uptime=1s mac-address=\
    18:89:5B:86:BB:08 name=ASAHD password=7798 profile=1hari
add comment="jan/11/2020 21:41:50" limit-uptime=1s mac-address=\
    74:29:AF:E8:0E:17 name=ADCWN password=4836 profile=1hari
add comment="jan/08/2020 06:36:30" limit-uptime=1s mac-address=\
    4C:1A:3D:83:30:70 name=AYWRT password=5632 profile=1hari
add comment="jan/16/2020 22:39:02" limit-uptime=1s mac-address=\
    18:89:5B:86:BB:08 name=AVXKM password=3562 profile=1hari
add comment="jan/15/2020 19:19:39" limit-uptime=1s mac-address=\
    18:89:5B:86:BB:08 name=AMCBN password=2423 profile=1hari
add comment="jan/11/2020 22:30:37" limit-uptime=1s mac-address=\
    18:89:5B:86:BB:08 name=AVDES password=9263 profile=1hari
add comment="jan/08/2020 22:17:03" limit-uptime=1s mac-address=\
    6C:D7:1F:23:3C:79 name=AKWPP password=6369 profile=1hari
add comment="jan/04/2020 22:06:32" limit-uptime=1s mac-address=\
    28:31:66:9A:D1:99 name=ADXAB password=6622 profile=1hari
add comment="jan/07/2020 21:54:43" limit-uptime=1s mac-address=\
    6C:D7:1F:23:3C:79 name=ATBEW password=8975 profile=1hari
add comment="jan/15/2020 19:34:18" limit-uptime=1s mac-address=\
    20:16:D8:F0:C0:CD name=AWCYS password=2237 profile=1hari
add comment="jan/04/2020 18:32:27" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=AHUYH password=2747 profile=1hari
add comment="jan/04/2020 16:08:34" limit-uptime=1s mac-address=\
    64:B8:53:4F:CD:B1 name=AXUYM password=5682 profile=1hari
add comment="jan/12/2020 08:49:48" limit-uptime=1s mac-address=\
    A4:D9:90:74:41:79 name=AHXTA password=9466 profile=1hari
add comment="jan/13/2020 14:48:51" limit-uptime=1s mac-address=\
    34:8B:75:02:80:83 name=AGXAP password=6932 profile=1hari
add comment="jan/10/2020 22:23:55" limit-uptime=1s mac-address=\
    18:89:5B:86:BB:08 name=ARMRY password=8254 profile=1hari
add comment="jan/15/2020 21:18:36" limit-uptime=1s mac-address=\
    5C:66:6C:D0:1F:37 name=AAMFW password=6428 profile=1hari
add comment="jan/04/2020 16:36:11" limit-uptime=1s mac-address=\
    18:89:5B:86:BB:08 name=AGRPB password=5797 profile=1hari
add comment="jan/16/2020 15:11:30" limit-uptime=1s mac-address=\
    6C:D7:1F:23:3C:79 name=ACPMH password=5764 profile=1hari
add comment="jan/17/2020 10:06:46" limit-uptime=1s mac-address=\
    5C:66:6C:D0:1F:37 name=AFDSJ password=2497 profile=1hari
add comment="jan/11/2020 14:28:39" limit-uptime=1s mac-address=\
    6C:D7:1F:23:3C:79 name=AMCXB password=2276 profile=1hari
add comment="jan/09/2020 10:24:03" limit-uptime=1s mac-address=\
    34:8B:75:02:80:83 name=APEWZ password=4966 profile=1hari
add comment="jan/14/2020 19:01:34" limit-uptime=1s mac-address=\
    5C:66:6C:D0:1F:37 name=AGDIZ password=6545 profile=1hari
add comment="jan/13/2020 15:36:21" limit-uptime=1s mac-address=\
    A4:D9:90:74:41:79 name=AGSDU password=6582 profile=1hari
add comment="jan/17/2020 17:23:14" limit-uptime=1s mac-address=\
    08:7F:98:B0:5B:A1 name=ARYCZ password=7724 profile=1hari
add comment="jan/09/2020 16:02:02" limit-uptime=1s mac-address=\
    08:7F:98:B0:5B:A1 name=ASMUR password=9748 profile=1hari
add comment=up-432-01.01.20-1HariFeri name=ANPME password=9657 profile=1hari
add comment=up-432-01.01.20-1HariFeri name=ABZAM password=5246 profile=1hari
add comment="jan/15/2020 16:06:15" limit-uptime=1s mac-address=\
    80:91:33:83:39:2B name=AZIBG password=3965 profile=1hari
add comment="jan/02/2020 19:37:49" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=AZMKF password=9297 profile=1hari
add comment=up-432-01.01.20-1HariFeri name=AWEXE password=4245 profile=1hari
add comment="jan/11/2020 13:46:35" limit-uptime=1s mac-address=\
    18:02:AE:9F:82:7F name=AIDCW password=4753 profile=1hari
add comment=up-432-01.01.20-1HariFeri name=AFDXY password=6788 profile=1hari
add comment=up-432-01.01.20-1HariFeri name=AEXZF password=7862 profile=1hari
add comment="jan/13/2020 23:42:37" limit-uptime=1s mac-address=\
    00:27:15:53:63:97 name=ABEDN password=7926 profile=1hari
add comment=up-432-01.01.20-1HariFeri name=AMTCN password=2743 profile=1hari
add comment="jan/11/2020 18:47:39" limit-uptime=1s mac-address=\
    00:27:15:53:63:97 name=AHHPZ password=7827 profile=1hari
add comment="jan/16/2020 18:40:10" limit-uptime=1s mac-address=\
    18:02:AE:9F:82:7F name=AGSJR password=5297 profile=1hari
add comment=up-432-01.01.20-1HariFeri name=ACNGF password=8372 profile=1hari
add comment=up-432-01.01.20-1HariFeri name=ANSZP password=7236 profile=1hari
add comment="jan/13/2020 16:18:06" limit-uptime=1s mac-address=\
    18:02:AE:9F:82:7F name=AHWEI password=8328 profile=1hari
add comment=up-432-01.01.20-1HariFeri name=AFVTI password=9638 profile=1hari
add comment="jan/10/2020 21:10:21" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=AAGGI password=8839 profile=1hari
add comment=up-432-01.01.20-1HariFeri name=AJASA password=3894 profile=1hari
add comment=up-432-01.01.20-1HariFeri name=AEURD password=8225 profile=1hari
add comment=up-432-01.01.20-1HariFeri name=ABHXM password=5643 profile=1hari
add comment="jan/13/2020 09:07:07" limit-uptime=1s mac-address=\
    08:7F:98:B0:5B:A1 name=AWIEV password=8964 profile=1hari
add comment=up-432-01.01.20-1HariFeri name=AETGW password=6965 profile=1hari
add comment="jan/10/2020 14:29:02" limit-uptime=1s mac-address=\
    C0:87:EB:C0:28:19 name=AYBZH password=7485 profile=1hari
add comment="jan/16/2020 17:05:32" limit-uptime=1s mac-address=\
    08:7F:98:B0:5B:A1 name=AVEYA password=7859 profile=1hari
add comment="jan/09/2020 18:46:57" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=AMWYS password=6489 profile=1hari
add comment="jan/09/2020 19:46:02" limit-uptime=1s mac-address=\
    18:02:AE:9F:82:7F name=AWUVA password=8599 profile=1hari
add comment="jan/11/2020 18:56:35" limit-uptime=1s mac-address=\
    C0:87:EB:C0:28:19 name=ANTDW password=5967 profile=1hari
add comment=up-432-01.01.20-1HariFeri name=AIKWX password=9643 profile=1hari
add comment="jan/09/2020 11:09:33" limit-uptime=1s mac-address=\
    A8:DB:03:0B:C2:F3 name=CWMHM password=4939 profile=7hari
add comment="jan/16/2020 13:52:27" limit-uptime=1s mac-address=\
    A8:DB:03:0B:C2:F3 name=CNZGU password=9982 profile=7hari
add comment="jan/11/2020 08:05:29" limit-uptime=1s mac-address=\
    A4:D9:90:74:41:79 name=CHWGN password=2385 profile=7hari
add comment="jan/12/2020 11:51:23" limit-uptime=1s mac-address=\
    08:8C:2C:02:A3:A3 name=CZVAR password=5493 profile=7hari
add comment=up-652-01.01.20- name=CDSHU password=7427 profile=7hari
add comment=up-652-01.01.20- name=CTDWT password=7789 profile=7hari
add comment="jan/20/2020 19:21:14" mac-address=C0:87:EB:4A:C9:1F name=CHZLF \
    password=2497 profile=7hari
add comment=up-652-01.01.20- name=CVXVB password=8236 profile=7hari
add comment=up-652-01.01.20- name=CWTSX password=5544 profile=7hari
add comment="jan/13/2020 18:18:45" limit-uptime=1s mac-address=\
    C0:87:EB:4A:C9:1F name=CFDVP password=7438 profile=7hari
add comment=up-652-01.01.20- name=CSYZV password=6547 profile=7hari
add comment=up-652-01.01.20- name=CZWYH password=6678 profile=7hari
add comment=up-652-01.01.20- name=CXRJY password=5598 profile=7hari
add comment=up-652-01.01.20- name=CCBDH password=3896 profile=7hari
add comment=up-652-01.01.20- name=CKVXG password=4537 profile=7hari
add comment=up-652-01.01.20- name=CPTKM password=7279 profile=7hari
add comment=up-652-01.01.20- name=CHLMV password=9523 profile=7hari
add comment=up-652-01.01.20- name=CJVWY password=9323 profile=7hari
add comment=up-652-01.01.20- name=CNNEP password=5455 profile=7hari
add comment=up-652-01.01.20- name=CNKHN password=3492 profile=7hari
add comment="jan/23/2020 23:42:30" mac-address=88:5A:06:66:12:E5 name=CCDZP \
    password=8355 profile=7hari
add comment=up-652-01.01.20- name=CALXK password=3566 profile=7hari
add comment=up-652-01.01.20- name=CAEWV password=9223 profile=7hari
add comment=up-652-01.01.20- name=CWZPL password=2679 profile=7hari
add comment="jan/23/2020 22:46:45" mac-address=A8:DB:03:0B:C2:F3 name=CGSWF \
    password=2836 profile=7hari
add comment=up-652-01.01.20- name=CBZJU password=7659 profile=7hari
add comment=up-652-01.01.20- name=CXSXW password=9797 profile=7hari
add comment="jan/18/2020 18:38:23" mac-address=E0:99:71:C7:B6:9F name=CPLEG \
    password=4777 profile=7hari
add comment=up-652-01.01.20- name=CWCBT password=6546 profile=7hari
add comment=up-652-01.01.20- name=CLKEA password=7673 profile=7hari
add mac-address=0C:98:38:D7:52:FF name=user2 profile=BINDING
add comment="jan/03/2020 12:00:26" limit-uptime=1s mac-address=\
    20:5E:F7:FA:47:BC name=AIKUD password=5528 profile=1hari
add comment=up-747-01.05.20-2hariferi name=BAVGF password=3469 profile=2hari
add comment=up-747-01.05.20-2hariferi name=BRWDD password=7599 profile=2hari
add comment="jan/08/2020 19:43:32" limit-uptime=1s mac-address=\
    18:02:AE:9F:82:7F name=BUZBV password=2667 profile=2hari
add comment="jan/16/2020 19:29:27" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=BDXRZ password=3437 profile=2hari
add comment=up-747-01.05.20-2hariferi name=BPJSJ password=6589 profile=2hari
add comment=up-747-01.05.20-2hariferi name=BUDYT password=3899 profile=2hari
add comment=up-747-01.05.20-2hariferi name=BMZDW password=7256 profile=2hari
add comment=up-747-01.05.20-2hariferi name=BMRBL password=9996 profile=2hari
add comment="jan/10/2020 07:56:37" limit-uptime=1s mac-address=\
    00:27:15:53:63:97 name=BMWLH password=5447 profile=2hari
add comment=up-747-01.05.20-2hariferi name=BGHBE password=3947 profile=2hari
add comment=up-747-01.05.20-2hariferi name=BPXRU password=7574 profile=2hari
add comment=up-747-01.05.20-2hariferi name=BEFXW password=9624 profile=2hari
add comment="jan/18/2020 20:08:00" mac-address=60:A4:D0:B9:1E:48 name=BVDRE \
    password=7345 profile=2hari
add comment=up-747-01.05.20-2hariferi name=BDJNM password=5935 profile=2hari
add comment="jan/14/2020 01:02:01" limit-uptime=1s mac-address=\
    38:A4:ED:A1:2E:37 name=BBRLN password=3749 profile=2hari
add comment=up-747-01.05.20-2hariferi name=BFTBC password=5269 profile=2hari
add comment=up-747-01.05.20-2hariferi name=BLJDX password=3872 profile=2hari
add comment=up-747-01.05.20-2hariferi name=BKGKT password=3849 profile=2hari
add comment="jan/18/2020 18:45:12" mac-address=18:02:AE:9F:82:7F name=BYGSF \
    password=9846 profile=2hari
add comment="jan/19/2020 05:05:32" mac-address=1C:77:F6:E0:DE:02 name=BTCRF \
    password=4555 profile=2hari
add comment="jan/14/2020 21:12:46" limit-uptime=1s mac-address=\
    60:A4:D0:B9:1E:48 name=BMLBM password=3545 profile=2hari
add comment=up-747-01.05.20-2hariferi name=BBCSU password=3794 profile=2hari
add comment=up-747-01.05.20-2hariferi name=BDVGU password=2879 profile=2hari
add comment=up-747-01.05.20-2hariferi name=BNHPF password=6678 profile=2hari
add comment="jan/17/2020 01:15:41" limit-uptime=1s mac-address=\
    00:27:15:53:63:97 name=BYJHZ password=6858 profile=2hari
add comment="jan/15/2020 18:08:51" limit-uptime=1s mac-address=\
    18:02:AE:9F:82:7F name=BBUHT password=6487 profile=2hari
add comment="jan/11/2020 21:51:34" limit-uptime=1s mac-address=\
    60:A4:D0:B9:1E:48 name=BUEFE password=6753 profile=2hari
add comment=up-747-01.05.20-2hariferi name=BTKXD password=3742 profile=2hari
add comment=up-747-01.05.20-2hariferi name=BTFAH password=4392 profile=2hari
add comment=up-747-01.05.20-2hariferi name=BLHHN password=5828 profile=2hari
add comment="jan/13/2020 22:53:18" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=BBVWD password=2974 profile=2hari
add comment="jan/15/2020 06:19:13" limit-uptime=1s mac-address=\
    00:0A:F5:C2:FC:7C name=BHDBP password=6755 profile=2hari
add comment="jan/15/2020 06:49:38" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=BJJIR password=2927 profile=2hari
add comment="jan/15/2020 13:46:57" limit-uptime=1s mac-address=\
    4C:5C:FF:46:FE:99 name=BWWSD password=9462 profile=2hari
add comment="jan/15/2020 11:10:38" limit-uptime=1s mac-address=\
    20:F7:7C:21:6E:89 name=BTAWF password=7456 profile=2hari
add comment="jan/15/2020 12:06:21" limit-uptime=1s mac-address=\
    A4:D9:90:37:57:51 name=BTSNX password=4426 profile=2hari
add comment="jan/17/2020 16:09:54" limit-uptime=1s mac-address=\
    4C:5C:FF:46:FE:99 name=BXBKH password=5932 profile=2hari
add comment="jan/17/2020 12:15:10" limit-uptime=1s mac-address=\
    00:0A:F5:C2:FC:7C name=BHMKY password=4687 profile=2hari
add comment="jan/17/2020 22:38:27" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=BSRHM password=5772 profile=2hari
add comment="jan/16/2020 23:07:52" limit-uptime=1s mac-address=\
    A4:D9:90:37:57:51 name=BUGXT password=6462 profile=2hari
add comment="jan/17/2020 17:30:09" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=BHEWJ password=7944 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BBBZF password=4567 profile=2hari
add comment="jan/18/2020 14:48:50" mac-address=0C:98:38:1D:99:0B name=BUSZZ \
    password=4798 profile=2hari
add comment="jan/16/2020 19:25:38" limit-uptime=1s mac-address=\
    60:72:8D:62:53:EB name=BEVRL password=4366 profile=2hari
add comment="jan/19/2020 12:32:00" mac-address=00:0A:F5:C2:FC:7C name=BCDTH \
    password=4886 profile=2hari
add comment="jan/16/2020 23:51:22" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=BEMXJ password=7466 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BFPAJ password=6575 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BAEUA password=5988 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BFAYD password=3576 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BTWEK password=6924 profile=2hari
add comment="jan/19/2020 19:03:32" mac-address=2C:56:DC:E7:15:E1 name=BCJKR \
    password=3289 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BELFM password=9652 profile=2hari
add comment="jan/19/2020 16:47:13" mac-address=4C:5C:FF:46:FE:99 name=BVTMV \
    password=6296 profile=2hari
add comment="jan/16/2020 09:41:05" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=BPAXH password=7699 profile=2hari
add comment="jan/17/2020 16:47:07" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=BHBEU password=3634 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BUPCW password=8263 profile=2hari
add comment="jan/15/2020 22:32:46" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=BTHLJ password=4664 profile=2hari
add comment="jan/19/2020 16:36:44" mac-address=B4:CB:57:36:FA:A7 name=BWCYC \
    password=4936 profile=2hari
add comment="jan/15/2020 22:51:00" limit-uptime=1s mac-address=\
    0C:98:38:FC:E3:AF name=BYPHU password=6926 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BTPJB password=2492 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BZVVV password=4969 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BLAJU password=3489 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BXAWR password=5437 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BALZD password=7679 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BRDMD password=8296 profile=2hari
add comment="jan/18/2020 16:22:22" mac-address=20:F7:7C:21:6E:89 name=BLWEG \
    password=5583 profile=2hari
add comment="jan/18/2020 16:32:47" mac-address=C0:87:EB:35:15:4B name=BFGUJ \
    password=6586 profile=2hari
add comment="jan/19/2020 00:00:56" mac-address=28:83:35:94:FE:E2 name=BTFZC \
    password=7796 profile=2hari
add comment="jan/18/2020 20:11:51" mac-address=0C:98:38:FC:E3:AF name=BSJRH \
    password=6379 profile=2hari
add comment="jan/19/2020 02:10:43" mac-address=38:A4:ED:A1:2E:37 name=BWNJS \
    password=3524 profile=2hari
add comment="jan/18/2020 16:49:00" mac-address=08:7F:98:E1:84:ED name=BZLBZ \
    password=2585 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BVWJZ password=2753 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BBMBJ password=8393 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BPCYZ password=3584 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BBMSM password=9423 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BFJCS password=8647 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BWLXH password=5955 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BTNWC password=7393 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BNKTW password=3288 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BBUFG password=8479 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BAHCC password=4745 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BFXED password=5959 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BJECC password=8784 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BFZTU password=4943 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BNATV password=7464 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BCBWB password=6546 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BPWXF password=9447 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BVCPC password=3544 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BLRSJ password=5733 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BJDYW password=3963 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BEKBF password=4739 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BUDWH password=5883 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BUCAV password=5238 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BZCHM password=2326 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BDVPC password=2949 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BBALK password=2262 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BKLTC password=9465 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BZXDA password=5428 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BMCMW password=3299 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BUULJ password=2377 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BLSVH password=8448 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BJPHK password=2559 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BFFUM password=7288 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BVKVE password=5344 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BWVGJ password=9452 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BCEXT password=2439 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BHGKZ password=6936 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BFXNY password=3238 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BRUCH password=6394 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BFRWW password=6348 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BVEKJ password=8883 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BBGSN password=4852 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BVRHC password=6884 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BUYDX password=4886 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BRZWP password=6597 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BGNEZ password=8434 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BHHYV password=8523 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BRDVV password=6563 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BWSRT password=6952 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BWSBH password=6835 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BFYXJ password=6982 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BXEXP password=2887 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BLEUT password=9434 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BUSGN password=8364 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BNKFV password=7387 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BMDHF password=9253 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BLRGP password=7654 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BBPYR password=5553 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BEUYC password=2533 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BMZCU password=4455 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BVXEJ password=8894 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BUHXR password=5668 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BFZAG password=9697 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BXSGE password=9486 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BMBLZ password=4893 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BWZGL password=8625 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BRCMJ password=2529 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BRFWL password=2466 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BPCCL password=3749 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BGLAD password=6529 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BKBHG password=7463 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BUSVR password=5265 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BBADW password=6596 profile=2hari
add comment="jan/19/2020 19:28:47" mac-address=4C:1A:3D:83:30:70 name=BCWDU \
    password=7343 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BPYNC password=7253 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BGZCR password=3823 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BYVNC password=3222 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BGCRF password=3895 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BCRDV password=9672 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BDEUN password=5498 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BDLHF password=3655 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BWFMP password=2425 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BAFCJ password=7249 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BKFWH password=9734 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BUALF password=6247 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BVFUV password=4755 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BGTLV password=8546 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BAEGZ password=9287 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BTKZC password=4457 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BCCJX password=8934 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BZBDC password=3772 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BAABM password=3382 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BBTXW password=5527 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BVXJW password=8259 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BZGFG password=2756 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BKTFY password=8423 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BUWEL password=9526 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BWMUT password=3296 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BKKTJ password=4778 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BDGVE password=9383 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BXXWZ password=9444 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BGAMK password=9882 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BEJNG password=8632 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BGTUJ password=4292 profile=2hari
add comment="jan/19/2020 13:47:19" mac-address=20:5E:F7:FA:47:BC name=BHVWH \
    password=3329 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BCKPA password=2634 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BJFUC password=8322 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BVBBJ password=3758 profile=2hari
add comment=up-323-01.13.20-2hariudin name=BEPFP password=8825 profile=2hari
/ip hotspot walled-garden
add comment="place hotspot rules here" disabled=yes
add dst-host=laksa19.github.io server=server1
add dst-host=*.intergram.*
add dst-host=fonts.googleapis.com
add dst-host=*.bindaud.*
/ip hotspot walled-garden ip
add action=accept disabled=no !dst-address !dst-address-list dst-host=\
    laksa19.github.io !dst-port !protocol !src-address !src-address-list
add action=accept disabled=no !dst-address !dst-address-list dst-host=\
    *.bindaud.* !dst-port !protocol !src-address !src-address-list
add action=accept disabled=no !dst-address !dst-address-list dst-host=\
    fonts.googleapis.com !dst-port !protocol !src-address !src-address-list
/ip route
add disabled=yes distance=1 gateway=eth1-internet
add check-gateway=ping comment=MyTunnel-DNS distance=1 dst-address=8.8.4.4/32 \
    gateway=10.0.32.1
add check-gateway=ping comment=MyTunnel-DNS distance=1 dst-address=8.8.8.8/32 \
    gateway=10.0.32.1
add check-gateway=ping comment=MyTunnel-DNS distance=1 dst-address=\
    51.158.168.202/32 gateway=10.0.32.1
add check-gateway=ping comment=MyTunnel-DNS distance=1 dst-address=\
    54.39.97.51/32 gateway=10.0.32.1
add check-gateway=ping comment=MyTunnel-DNS distance=1 dst-address=\
    139.99.74.182/32 gateway=10.0.32.1
add check-gateway=ping comment=MyTunnel-DNS distance=1 dst-address=\
    163.172.170.19/32 gateway=10.0.32.1
add check-gateway=ping comment=MyTunnel-DNS distance=1 dst-address=\
    176.103.130.130/32 gateway=10.0.32.1
add check-gateway=ping comment=MyTunnel-DNS distance=1 dst-address=\
    176.103.130.131/32 gateway=10.0.32.1
add check-gateway=ping comment=MyTunnel-DNS distance=1 dst-address=\
    176.103.130.132/32 gateway=10.0.32.1
add check-gateway=ping comment=MyTunnel-DNS distance=1 dst-address=\
    176.103.130.134/32 gateway=10.0.32.1
/ip service
set telnet disabled=yes
/ppp secret
add name=udin password=udin profile=PPPoE remote-address=192.168.10.2 \
    service=pppoe
add name=mail password=mail profile=PPPoE remote-address=192.168.10.3 \
    service=pppoe
/system clock
set time-zone-name=Asia/Jakarta
/system logging
add action=disk prefix=-> topics=hotspot,info,debug
add action=disk prefix=-> topics=hotspot,info,debug
add action=disk prefix=-> topics=hotspot,info,debug
/system ntp client
set enabled=yes primary-ntp=202.65.114.202 secondary-ntp=36.86.63.182
/system routerboard settings
set silent-boot=no
/system scheduler
add interval=5s name=force-update on-event="/ip cloud force-update" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=apr/09/2019 start-time=07:34:50
add comment="Monitor Profile 1bln" interval=2m53s name=1bln on-event=":local d\
    ateint do={:local montharray ( \"jan\",\"feb\",\"mar\",\"apr\",\"may\",\"j\
    un\",\"jul\",\"aug\",\"sep\",\"oct\",\"nov\",\"dec\" );:local days [ :pick\
    \_\$d 4 6 ];:local month [ :pick \$d 0 3 ];:local year [ :pick \$d 7 11 ];\
    :local monthint ([ :find \$montharray \$month]);:local month (\$monthint +\
    \_1);:if ( [len \$month] = 1) do={:local zero (\"0\");:return [:tonum (\"\
    \$year\$zero\$month\$days\")];} else={:return [:tonum (\"\$year\$month\$da\
    ys\")];}}; :local timeint do={ :local hours [ :pick \$t 0 2 ]; :local minu\
    tes [ :pick \$t 3 5 ]; :return (\$hours * 60 + \$minutes) ; }; :local date\
    \_[ /system clock get date ]; :local time [ /system clock get time ]; :loc\
    al today [\$dateint d=\$date] ; :local curtime [\$timeint t=\$time] ; :for\
    each i in [ /ip hotspot user find where profile=\"1bln\" ] do={ :local com\
    ment [ /ip hotspot user get \$i comment]; :local name [ /ip hotspot user g\
    et \$i name]; :local gettime [:pic \$comment 12 20]; :if ([:pic \$comment \
    3] = \"/\" and [:pic \$comment 6] = \"/\") do={:local expd [\$dateint d=\$\
    comment] ; :local expt [\$timeint t=\$gettime] ; :if ((\$expd < \$today an\
    d \$expt < \$curtime) or (\$expd < \$today and \$expt > \$curtime) or (\$e\
    xpd = \$today and \$expt < \$curtime)) do={ [ /ip hotspot user remove \$i \
    ]; [ /ip hotspot active remove [find where user=\$name] ];}}}" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=may/03/2019 start-time=02:21:24
add comment="Monitor Profile 10hari" interval=2m45s name=10hari on-event=":loc\
    al dateint do={:local montharray ( \"jan\",\"feb\",\"mar\",\"apr\",\"may\"\
    ,\"jun\",\"jul\",\"aug\",\"sep\",\"oct\",\"nov\",\"dec\" );:local days [ :\
    pick \$d 4 6 ];:local month [ :pick \$d 0 3 ];:local year [ :pick \$d 7 11\
    \_];:local monthint ([ :find \$montharray \$month]);:local month (\$monthi\
    nt + 1);:if ( [len \$month] = 1) do={:local zero (\"0\");:return [:tonum (\
    \"\$year\$zero\$month\$days\")];} else={:return [:tonum (\"\$year\$month\$\
    days\")];}}; :local timeint do={ :local hours [ :pick \$t 0 2 ]; :local mi\
    nutes [ :pick \$t 3 5 ]; :return (\$hours * 60 + \$minutes) ; }; :local da\
    te [ /system clock get date ]; :local time [ /system clock get time ]; :lo\
    cal today [\$dateint d=\$date] ; :local curtime [\$timeint t=\$time] ; :fo\
    reach i in [ /ip hotspot user find where profile=\"10hari\" ] do={ :local \
    comment [ /ip hotspot user get \$i comment]; :local name [ /ip hotspot use\
    r get \$i name]; :local gettime [:pic \$comment 12 20]; :if ([:pic \$comme\
    nt 3] = \"/\" and [:pic \$comment 6] = \"/\") do={:local expd [\$dateint d\
    =\$comment] ; :local expt [\$timeint t=\$gettime] ; :if ((\$expd < \$today\
    \_and \$expt < \$curtime) or (\$expd < \$today and \$expt > \$curtime) or \
    (\$expd = \$today and \$expt < \$curtime)) do={ [ /ip hotspot user remove \
    \$i ]; [ /ip hotspot active remove [find where user=\$name] ];}}}" \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=may/03/2019 start-time=01:58:35
add comment="Monitor Profile 7hari" interval=2m13s name=7hari on-event=":local\
    \_dateint do={:local montharray ( \"jan\",\"feb\",\"mar\",\"apr\",\"may\",\
    \"jun\",\"jul\",\"aug\",\"sep\",\"oct\",\"nov\",\"dec\" );:local days [ :p\
    ick \$d 4 6 ];:local month [ :pick \$d 0 3 ];:local year [ :pick \$d 7 11 \
    ];:local monthint ([ :find \$montharray \$month]);:local month (\$monthint\
    \_+ 1);:if ( [len \$month] = 1) do={:local zero (\"0\");:return [:tonum (\
    \"\$year\$zero\$month\$days\")];} else={:return [:tonum (\"\$year\$month\$\
    days\")];}}; :local timeint do={ :local hours [ :pick \$t 0 2 ]; :local mi\
    nutes [ :pick \$t 3 5 ]; :return (\$hours * 60 + \$minutes) ; }; :local da\
    te [ /system clock get date ]; :local time [ /system clock get time ]; :lo\
    cal today [\$dateint d=\$date] ; :local curtime [\$timeint t=\$time] ; :fo\
    reach i in [ /ip hotspot user find where profile=\"7hari\" ] do={ :local c\
    omment [ /ip hotspot user get \$i comment]; :local name [ /ip hotspot user\
    \_get \$i name]; :local gettime [:pic \$comment 12 20]; :if ([:pic \$comme\
    nt 3] = \"/\" and [:pic \$comment 6] = \"/\") do={:local expd [\$dateint d\
    =\$comment] ; :local expt [\$timeint t=\$gettime] ; :if ((\$expd < \$today\
    \_and \$expt < \$curtime) or (\$expd < \$today and \$expt > \$curtime) or \
    (\$expd = \$today and \$expt < \$curtime)) do={ [ /ip hotspot user set lim\
    it-uptime=1s \$i ]; [ /ip hotspot active remove [find where user=\$name] ]\
    ;}}}" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=may/03/2019 start-time=01:19:42
add comment="Monitor Profile 2hari" interval=2m18s name=2hari on-event=":local\
    \_dateint do={:local montharray ( \"jan\",\"feb\",\"mar\",\"apr\",\"may\",\
    \"jun\",\"jul\",\"aug\",\"sep\",\"oct\",\"nov\",\"dec\" );:local days [ :p\
    ick \$d 4 6 ];:local month [ :pick \$d 0 3 ];:local year [ :pick \$d 7 11 \
    ];:local monthint ([ :find \$montharray \$month]);:local month (\$monthint\
    \_+ 1);:if ( [len \$month] = 1) do={:local zero (\"0\");:return [:tonum (\
    \"\$year\$zero\$month\$days\")];} else={:return [:tonum (\"\$year\$month\$\
    days\")];}}; :local timeint do={ :local hours [ :pick \$t 0 2 ]; :local mi\
    nutes [ :pick \$t 3 5 ]; :return (\$hours * 60 + \$minutes) ; }; :local da\
    te [ /system clock get date ]; :local time [ /system clock get time ]; :lo\
    cal today [\$dateint d=\$date] ; :local curtime [\$timeint t=\$time] ; :fo\
    reach i in [ /ip hotspot user find where profile=\"2hari\" ] do={ :local c\
    omment [ /ip hotspot user get \$i comment]; :local name [ /ip hotspot user\
    \_get \$i name]; :local gettime [:pic \$comment 12 20]; :if ([:pic \$comme\
    nt 3] = \"/\" and [:pic \$comment 6] = \"/\") do={:local expd [\$dateint d\
    =\$comment] ; :local expt [\$timeint t=\$gettime] ; :if ((\$expd < \$today\
    \_and \$expt < \$curtime) or (\$expd < \$today and \$expt > \$curtime) or \
    (\$expd = \$today and \$expt < \$curtime)) do={ [ /ip hotspot user set lim\
    it-uptime=1s \$i ]; [ /ip hotspot active remove [find where user=\$name] ]\
    ;}}}" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=aug/06/2019 start-time=02:25:39
add comment="Monitor Profile 1hari" interval=2m39s name=1hari on-event=":local\
    \_dateint do={:local montharray ( \"jan\",\"feb\",\"mar\",\"apr\",\"may\",\
    \"jun\",\"jul\",\"aug\",\"sep\",\"oct\",\"nov\",\"dec\" );:local days [ :p\
    ick \$d 4 6 ];:local month [ :pick \$d 0 3 ];:local year [ :pick \$d 7 11 \
    ];:local monthint ([ :find \$montharray \$month]);:local month (\$monthint\
    \_+ 1);:if ( [len \$month] = 1) do={:local zero (\"0\");:return [:tonum (\
    \"\$year\$zero\$month\$days\")];} else={:return [:tonum (\"\$year\$month\$\
    days\")];}}; :local timeint do={ :local hours [ :pick \$t 0 2 ]; :local mi\
    nutes [ :pick \$t 3 5 ]; :return (\$hours * 60 + \$minutes) ; }; :local da\
    te [ /system clock get date ]; :local time [ /system clock get time ]; :lo\
    cal today [\$dateint d=\$date] ; :local curtime [\$timeint t=\$time] ; :fo\
    reach i in [ /ip hotspot user find where profile=\"1hari\" ] do={ :local c\
    omment [ /ip hotspot user get \$i comment]; :local name [ /ip hotspot user\
    \_get \$i name]; :local gettime [:pic \$comment 12 20]; :if ([:pic \$comme\
    nt 3] = \"/\" and [:pic \$comment 6] = \"/\") do={:local expd [\$dateint d\
    =\$comment] ; :local expt [\$timeint t=\$gettime] ; :if ((\$expd < \$today\
    \_and \$expt < \$curtime) or (\$expd < \$today and \$expt > \$curtime) or \
    (\$expd = \$today and \$expt < \$curtime)) do={ [ /ip hotspot user set lim\
    it-uptime=1s \$i ]; [ /ip hotspot active remove [find where user=\$name] ]\
    ;}}}" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=aug/06/2019 start-time=05:15:36
add comment="Monitor Profile 6D" interval=2m58s name=6D on-event=":local datei\
    nt do={:local montharray ( \"jan\",\"feb\",\"mar\",\"apr\",\"may\",\"jun\"\
    ,\"jul\",\"aug\",\"sep\",\"oct\",\"nov\",\"dec\" );:local days [ :pick \$d\
    \_4 6 ];:local month [ :pick \$d 0 3 ];:local year [ :pick \$d 7 11 ];:loc\
    al monthint ([ :find \$montharray \$month]);:local month (\$monthint + 1);\
    :if ( [len \$month] = 1) do={:local zero (\"0\");:return [:tonum (\"\$year\
    \$zero\$month\$days\")];} else={:return [:tonum (\"\$year\$month\$days\")]\
    ;}}; :local timeint do={ :local hours [ :pick \$t 0 2 ]; :local minutes [ \
    :pick \$t 3 5 ]; :return (\$hours * 60 + \$minutes) ; }; :local date [ /sy\
    stem clock get date ]; :local time [ /system clock get time ]; :local toda\
    y [\$dateint d=\$date] ; :local curtime [\$timeint t=\$time] ; :foreach i \
    in [ /ip hotspot user find where profile=\"6D\" ] do={ :local comment [ /i\
    p hotspot user get \$i comment]; :local name [ /ip hotspot user get \$i na\
    me]; :local gettime [:pic \$comment 12 20]; :if ([:pic \$comment 3] = \"/\
    \" and [:pic \$comment 6] = \"/\") do={:local expd [\$dateint d=\$comment]\
    \_; :local expt [\$timeint t=\$gettime] ; :if ((\$expd < \$today and \$exp\
    t < \$curtime) or (\$expd < \$today and \$expt > \$curtime) or (\$expd = \
    \$today and \$expt < \$curtime)) do={ [ /ip hotspot user remove \$i ]; [ /\
    ip hotspot active remove [find where user=\$name] ];}}}" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=aug/07/2019 start-time=04:18:20
add comment="Reset Report Pendapatan" interval=1d name=ResetReportPendapatan \
    on-event=ResetReportPendapatan policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=aug/21/2019 start-time=00:00:01
add name="del pppoe" on-event=\
    "/queue simple remove [find where comment=\"user_pppoe\"]" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-time=startup
add comment="Monitor Profile 5hari" interval=2m35s name=5hari on-event=":local\
    \_dateint do={:local montharray ( \"jan\",\"feb\",\"mar\",\"apr\",\"may\",\
    \"jun\",\"jul\",\"aug\",\"sep\",\"oct\",\"nov\",\"dec\" );:local days [ :p\
    ick \$d 4 6 ];:local month [ :pick \$d 0 3 ];:local year [ :pick \$d 7 11 \
    ];:local monthint ([ :find \$montharray \$month]);:local month (\$monthint\
    \_+ 1);:if ( [len \$month] = 1) do={:local zero (\"0\");:return [:tonum (\
    \"\$year\$zero\$month\$days\")];} else={:return [:tonum (\"\$year\$month\$\
    days\")];}}; :local timeint do={ :local hours [ :pick \$t 0 2 ]; :local mi\
    nutes [ :pick \$t 3 5 ]; :return (\$hours * 60 + \$minutes) ; }; :local da\
    te [ /system clock get date ]; :local time [ /system clock get time ]; :lo\
    cal today [\$dateint d=\$date] ; :local curtime [\$timeint t=\$time] ; :fo\
    reach i in [ /ip hotspot user find where profile=\"5hari\" ] do={ :local c\
    omment [ /ip hotspot user get \$i comment]; :local name [ /ip hotspot user\
    \_get \$i name]; :local gettime [:pic \$comment 12 20]; :if ([:pic \$comme\
    nt 3] = \"/\" and [:pic \$comment 6] = \"/\") do={:local expd [\$dateint d\
    =\$comment] ; :local expt [\$timeint t=\$gettime] ; :if ((\$expd < \$today\
    \_and \$expt < \$curtime) or (\$expd < \$today and \$expt > \$curtime) or \
    (\$expd = \$today and \$expt < \$curtime)) do={ [ /ip hotspot user remove \
    \$i ]; [ /ip hotspot active remove [find where user=\$name] ];}}}" \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=dec/11/2019 start-time=03:22:32
add comment="Monitor Profile Tes" interval=2m38s name=Tes on-event=":local dat\
    eint do={:local montharray ( \"jan\",\"feb\",\"mar\",\"apr\",\"may\",\"jun\
    \",\"jul\",\"aug\",\"sep\",\"oct\",\"nov\",\"dec\" );:local days [ :pick \
    \$d 4 6 ];:local month [ :pick \$d 0 3 ];:local year [ :pick \$d 7 11 ];:l\
    ocal monthint ([ :find \$montharray \$month]);:local month (\$monthint + 1\
    );:if ( [len \$month] = 1) do={:local zero (\"0\");:return [:tonum (\"\$ye\
    ar\$zero\$month\$days\")];} else={:return [:tonum (\"\$year\$month\$days\"\
    )];}}; :local timeint do={ :local hours [ :pick \$t 0 2 ]; :local minutes \
    [ :pick \$t 3 5 ]; :return (\$hours * 60 + \$minutes) ; }; :local date [ /\
    system clock get date ]; :local time [ /system clock get time ]; :local to\
    day [\$dateint d=\$date] ; :local curtime [\$timeint t=\$time] ; :foreach \
    i in [ /ip hotspot user find where profile=\"Tes\" ] do={ :local comment [\
    \_/ip hotspot user get \$i comment]; :local name [ /ip hotspot user get \$\
    i name]; :local gettime [:pic \$comment 12 20]; :if ([:pic \$comment 3] = \
    \"/\" and [:pic \$comment 6] = \"/\") do={:local expd [\$dateint d=\$comme\
    nt] ; :local expt [\$timeint t=\$gettime] ; :if ((\$expd < \$today and \$e\
    xpt < \$curtime) or (\$expd < \$today and \$expt > \$curtime) or (\$expd =\
    \_\$today and \$expt < \$curtime)) do={ [ /ip hotspot user remove \$i ]; [\
    \_/ip hotspot active remove [find where user=\$name] ];}}}" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=jan/13/2020 start-time=04:57:33
/system script
add comment=mikhmon name="apr/09/2019-|-07:30:47-|-AVRNP-|-3000-|-192.168.12.2\
    17-|-B0:E2:35:35:41:61-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/09/2019
add comment=mikhmon name="apr/09/2019-|-07:32:37-|-CHBXM-|-15000-|-192.168.12.\
    91-|-C0:87:EB:4A:C9:1F-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/09/2019
add comment=mikhmon name="apr/09/2019-|-07:38:53-|-Leli-|-55000-|-192.168.12.9\
    3-|-3C:B6:B7:1C:E3:83-|-30d-|-1bln-|-" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/09/2019
add comment=mikhmon name="apr/09/2019-|-07:40:46-|-faris-|-15000-|-192.168.12.\
    12-|-28:FA:A0:D4:98:E0-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/09/2019
add comment=mikhmon name="apr/09/2019-|-14:53:42-|-BWUOB-|-5000-|-192.168.12.8\
    6-|-F0:6D:78:42:12:1A-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/09/2019
add comment=mikhmon name="apr/09/2019-|-15:05:30-|-CDVJX-|-15000-|-192.168.12.\
    15-|-E0:99:71:C7:B6:9F-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/09/2019
add comment=mikhmon name="apr/09/2019-|-15:35:46-|-CGWOJ-|-15000-|-192.168.12.\
    227-|-CC:2D:83:BA:71:8F-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/09/2019
add comment=mikhmon name="apr/09/2019-|-15:36:18-|-BLHQP-|-5000-|-192.168.12.2\
    3-|-54:A0:50:C5:3F:B1-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/09/2019
add comment=mikhmon name="apr/09/2019-|-15:49:51-|-BMOYA-|-5000-|-192.168.12.9\
    7-|-00:0A:00:D5:C3:D8-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/09/2019
add comment=mikhmon name="apr/09/2019-|-15:52:12-|-CTDEX-|-15000-|-192.168.12.\
    28-|-08:8C:2C:02:A3:A3-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/09/2019
add comment=mikhmon name="apr/09/2019-|-16:13:00-|-CQOQY-|-15000-|-192.168.12.\
    43-|-56:F5:9B:4E:49:77-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/09/2019
add comment=mikhmon name="apr/09/2019-|-16:31:20-|-CZUKF-|-15000-|-192.168.12.\
    47-|-00:27:15:67:75:4B-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/09/2019
add comment=mikhmon name="apr/09/2019-|-16:46:02-|-BYDIR-|-5000-|-192.168.12.2\
    07-|-A0:8D:16:24:9D:3F-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/09/2019
add comment=mikhmon name="apr/09/2019-|-17:23:36-|-BVJCY-|-5000-|-192.168.12.2\
    2-|-10:F6:81:D6:97:63-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/09/2019
add comment=mikhmon name="apr/09/2019-|-19:16:25-|-CARQG-|-15000-|-192.168.12.\
    58-|-1C:B7:2C:47:C9:73-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/09/2019
add comment=mikhmon name="apr/09/2019-|-20:58:47-|-BYOYR-|-5000-|-192.168.12.2\
    4-|-C0:87:EB:D8:F1:93-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/09/2019
add comment=mikhmon name="apr/09/2019-|-21:37:49-|-BSQTC-|-5000-|-192.168.12.7\
    2-|-8C:BF:A6:68:FC:5C-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/09/2019
add comment=mikhmon name="apr/09/2019-|-23:26:07-|-ACYDS-|-3000-|-192.168.12.1\
    07-|-0C:A8:A7:48:10:18-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/09/2019
add comment=mikhmon name="apr/10/2019-|-07:47:41-|-BLEVW-|-5000-|-192.168.12.9\
    5-|-18:F0:E4:6C:02:34-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/10/2019
add comment=mikhmon name="apr/10/2019-|-09:53:50-|-BQYKG-|-5000-|-192.168.12.9\
    9-|-0A:0B:E1:EE:0F:CC-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/10/2019
add comment=mikhmon name="apr/10/2019-|-12:39:05-|-CURUK-|-15000-|-192.168.12.\
    48-|-34:97:F6:C6:0F:DA-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/10/2019
add comment=mikhmon name="apr/10/2019-|-14:33:20-|-APBNQ-|-3000-|-192.168.12.1\
    15-|-00:27:15:63:22:FB-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/10/2019
add comment=mikhmon name="apr/10/2019-|-18:04:12-|-BOQXG-|-5000-|-192.168.12.7\
    1-|-3C:95:09:E7:6D:13-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/10/2019
add comment=mikhmon name="apr/10/2019-|-19:13:34-|-AZPZT-|-3000-|-192.168.12.1\
    31-|-64:B8:53:5D:10:33-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/10/2019
add comment=mikhmon name="apr/10/2019-|-20:19:15-|-ALYNV-|-3000-|-192.168.12.4\
    2-|-00:27:15:09:64:82-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/10/2019
add comment=mikhmon name="apr/10/2019-|-20:47:55-|-AIWKY-|-3000-|-192.168.12.6\
    0-|-08:EE:8B:F5:DA:26-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/10/2019
add comment=mikhmon name="apr/11/2019-|-14:36:47-|-AORZK-|-3000-|-192.168.12.1\
    15-|-00:27:15:63:22:FB-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/11/2019
add comment=mikhmon name="apr/11/2019-|-14:43:35-|-ASVIN-|-3000-|-192.168.12.1\
    07-|-0C:A8:A7:48:10:18-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/11/2019
add comment=mikhmon name="apr/11/2019-|-19:07:01-|-AMWTG-|-3000-|-192.168.12.1\
    86-|-1C:87:2C:3F:F5:68-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/11/2019
add comment=mikhmon name="apr/11/2019-|-20:42:14-|-AUTWZ-|-3000-|-192.168.12.2\
    4-|-C0:87:EB:D8:F1:93-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/11/2019
add comment=mikhmon name="apr/11/2019-|-21:45:53-|-AVUHA-|-3000-|-192.168.12.6\
    0-|-08:EE:8B:F5:DA:26-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/11/2019
add comment=mikhmon name="apr/12/2019-|-04:37:27-|-AVJRS-|-3000-|-192.168.12.9\
    7-|-00:0A:00:D5:C3:D8-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/12/2019
add comment=mikhmon name="apr/12/2019-|-07:34:05-|-AVGNI-|-3000-|-192.168.12.8\
    6-|-F0:6D:78:42:12:1A-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/12/2019
add comment=mikhmon name="apr/12/2019-|-11:47:29-|-AVPLU-|-3000-|-192.168.12.9\
    5-|-18:F0:E4:6C:02:34-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/12/2019
add comment=mikhmon name="apr/12/2019-|-13:32:15-|-AIGIZ-|-3000-|-192.168.12.9\
    9-|-0A:0B:E1:EE:0F:CC-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/12/2019
add comment=mikhmon name="apr/12/2019-|-13:32:24-|-APQUF-|-3000-|-192.168.12.1\
    31-|-64:B8:53:5D:10:33-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/12/2019
add comment=mikhmon name="apr/12/2019-|-13:40:52-|-AGJSP-|-3000-|-192.168.12.9\
    9-|-0A:0B:E1:EE:0F:CC-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/12/2019
add comment=mikhmon name="apr/12/2019-|-16:06:32-|-ADFCC-|-3000-|-192.168.12.2\
    3-|-54:A0:50:C5:3F:B1-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/12/2019
add comment=mikhmon name="apr/12/2019-|-16:11:39-|-AZBQM-|-3000-|-192.168.12.1\
    19-|-A0:8D:16:24:9D:3F-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/12/2019
add comment=mikhmon name="apr/12/2019-|-19:08:21-|-ACWRH-|-3000-|-192.168.12.1\
    86-|-1C:87:2C:3F:F5:68-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/12/2019
add comment=mikhmon name="apr/12/2019-|-19:20:05-|-BLFHO-|-5000-|-192.168.12.2\
    2-|-10:F6:81:D6:97:63-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/12/2019
add comment=mikhmon name="apr/12/2019-|-22:38:11-|-BTKCP-|-5000-|-192.168.12.2\
    4-|-C0:87:EB:D8:F1:93-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/12/2019
add comment=mikhmon name="apr/13/2019-|-04:49:36-|-AJBTB-|-3000-|-192.168.12.2\
    3-|-54:A0:50:C5:3F:B1-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/13/2019
add comment=mikhmon name="apr/13/2019-|-09:52:15-|-CJGAT-|-15000-|-192.168.12.\
    54-|-C0:87:EB:4A:C9:1F-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/13/2019
add comment=mikhmon name="apr/13/2019-|-11:48:14-|-BZYXJ-|-5000-|-192.168.12.9\
    5-|-18:F0:E4:6C:02:34-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/13/2019
add comment=mikhmon name="apr/13/2019-|-11:59:44-|-AAGSK-|-3000-|-192.168.12.9\
    7-|-00:0A:00:D5:C3:D8-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/13/2019
add comment=mikhmon name="apr/13/2019-|-12:47:49-|-AGWHO-|-3000-|-192.168.12.3\
    9-|-00:27:15:63:22:FB-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/13/2019
add comment=mikhmon name="apr/13/2019-|-13:48:45-|-BVRBD-|-5000-|-192.168.12.1\
    47-|-20:5E:F7:6D:E6:3A-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/13/2019
add comment=mikhmon name="apr/13/2019-|-14:14:43-|-BWFZP-|-5000-|-192.168.12.9\
    9-|-0A:0B:E1:EE:0F:CC-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/13/2019
add comment=mikhmon name="apr/13/2019-|-16:22:41-|-AJKBO-|-3000-|-192.168.12.5\
    6-|-20:5E:F7:71:AA:F0-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/13/2019
add comment=mikhmon name="apr/13/2019-|-16:48:35-|-AXDPW-|-3000-|-192.168.12.7\
    1-|-3C:95:09:E7:6D:13-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/13/2019
add comment=mikhmon name="apr/13/2019-|-16:55:53-|-BJZDL-|-5000-|-192.168.12.2\
    41-|-A0:8D:16:24:9D:3F-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/13/2019
add comment=mikhmon name="apr/13/2019-|-19:02:03-|-BHUOJ-|-5000-|-192.168.12.8\
    6-|-F0:6D:78:42:12:1A-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/13/2019
add comment=mikhmon name="apr/13/2019-|-22:10:13-|-AVNET-|-3000-|-192.168.12.1\
    31-|-64:B8:53:5D:10:33-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/13/2019
add comment=mikhmon name="apr/14/2019-|-07:44:43-|-BQCCK-|-5000-|-192.168.12.1\
    07-|-0C:A8:A7:48:10:18-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/14/2019
add comment=mikhmon name="apr/14/2019-|-11:48:24-|-AJCPK-|-3000-|-192.168.12.6\
    0-|-08:EE:8B:F5:DA:26-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/14/2019
add comment=mikhmon name="apr/14/2019-|-18:24:26-|-BCFEP-|-5000-|-192.168.12.5\
    7-|-88:D5:0C:08:6B:3C-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/14/2019
add comment=mikhmon name="apr/14/2019-|-19:33:33-|-BXUIE-|-5000-|-192.168.12.1\
    46-|-80:AD:16:76:6E:5E-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/14/2019
add comment=mikhmon name="apr/14/2019-|-19:48:12-|-CYXCX-|-15000-|-192.168.12.\
    12-|-28:FA:A0:D4:98:E0-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/14/2019
add comment=mikhmon name="apr/14/2019-|-20:00:52-|-CWSDU-|-15000-|-192.168.12.\
    43-|-56:F5:9B:4E:49:77-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/14/2019
add comment=mikhmon name="apr/14/2019-|-20:03:16-|-BRIRB-|-5000-|-192.168.12.1\
    86-|-1C:87:2C:3F:F5:68-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/14/2019
add comment=mikhmon name="apr/14/2019-|-20:13:07-|-BNAZQ-|-5000-|-192.168.12.2\
    3-|-54:A0:50:C5:3F:B1-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/14/2019
add comment=mikhmon name="apr/15/2019-|-12:21:32-|-AGPAQ-|-3000-|-192.168.12.1\
    4-|-20:5E:F7:30:5E:78-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/15/2019
add comment=mikhmon name="apr/15/2019-|-12:34:24-|-AHZNW-|-3000-|-192.168.12.9\
    7-|-00:0A:00:D5:C3:D8-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/15/2019
add comment=mikhmon name="apr/15/2019-|-12:50:45-|-AMJFH-|-3000-|-192.168.12.1\
    83-|-00:27:15:63:22:FB-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/15/2019
add comment=mikhmon name="apr/15/2019-|-13:34:47-|-BKPAA-|-5000-|-192.168.12.9\
    5-|-18:F0:E4:6C:02:34-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/15/2019
add comment=mikhmon name="apr/15/2019-|-14:30:15-|-CWNGH-|-15000-|-192.168.12.\
    147-|-20:5E:F7:6D:E6:3A-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/15/2019
add comment=mikhmon name="apr/15/2019-|-17:10:15-|-BEATK-|-5000-|-192.168.12.1\
    86-|-1C:87:2C:3F:F5:68-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/15/2019
add comment=mikhmon name="apr/15/2019-|-19:06:15-|-BSNHM-|-5000-|-192.168.12.8\
    6-|-F0:6D:78:42:12:1A-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/15/2019
add comment=mikhmon name="apr/15/2019-|-19:21:34-|-BVRVE-|-5000-|-192.168.12.1\
    68-|-A0:8D:16:24:9D:3F-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/15/2019
add comment=mikhmon name="apr/16/2019-|-13:28:44-|-AQXHL-|-3000-|-192.168.12.1\
    2-|-00:0A:00:D5:C3:D8-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/16/2019
add comment=mikhmon name="apr/16/2019-|-14:14:29-|-BOKWF-|-5000-|-192.168.12.2\
    4-|-C0:87:EB:D8:F1:93-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/16/2019
add comment=mikhmon name="apr/16/2019-|-17:56:56-|-BZSPO-|-5000-|-192.168.12.8\
    5-|-B4:C0:F5:07:F8:7B-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/16/2019
add comment=mikhmon name="apr/16/2019-|-19:42:46-|-CXQAM-|-15000-|-192.168.12.\
    15-|-E0:99:71:C7:B6:9F-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/16/2019
add comment=mikhmon name="apr/16/2019-|-20:36:08-|-AYAGK-|-3000-|-192.168.12.1\
    11-|-24:FD:52:03:46:15-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/16/2019
add comment=mikhmon name="apr/16/2019-|-20:36:42-|-BDRLR-|-5000-|-192.168.12.7\
    -|-20:5E:F7:E8:78:B2-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/16/2019
add comment=mikhmon name="apr/16/2019-|-20:38:06-|-BBZVN-|-5000-|-192.168.12.1\
    44-|-C0:87:EB:D5:D4:69-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/16/2019
add comment=mikhmon name="apr/16/2019-|-20:51:40-|-BPTGN-|-5000-|-192.168.12.3\
    5-|-34:97:F6:C6:0F:DA-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/16/2019
add comment=mikhmon name="apr/17/2019-|-07:01:35-|-ARAWJ-|-3000-|-192.168.12.2\
    9-|-0C:98:38:6A:6A:51-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/17/2019
add comment=mikhmon name="apr/17/2019-|-07:30:29-|-BGSPM-|-5000-|-192.168.12.1\
    1-|-0A:0B:E1:EE:0F:CC-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/17/2019
add comment=mikhmon name="apr/17/2019-|-09:23:58-|-BPUTX-|-5000-|-192.168.12.2\
    3-|-54:A0:50:C5:3F:B1-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/17/2019
add comment=mikhmon name="apr/17/2019-|-11:21:03-|-BVFAX-|-5000-|-192.168.12.1\
    28-|-88:D5:0C:08:6B:3C-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/17/2019
add comment=mikhmon name="apr/17/2019-|-13:27:34-|-BWEXV-|-5000-|-192.168.12.1\
    86-|-1C:87:2C:3F:F5:68-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/17/2019
add comment=mikhmon name="apr/18/2019-|-12:51:27-|-AANGQ-|-3000-|-192.168.12.9\
    5-|-18:F0:E4:6C:02:34-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/18/2019
add comment=mikhmon name="apr/18/2019-|-14:38:04-|-BARZJ-|-5000-|-192.168.12.6\
    0-|-F0:6D:78:42:12:1A-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/18/2019
add comment=mikhmon name="apr/18/2019-|-19:08:33-|-BYXTL-|-5000-|-192.168.12.2\
    30-|-1C:77:F6:E0:DE:02-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/18/2019
add comment=mikhmon name="apr/18/2019-|-19:14:38-|-BODTU-|-5000-|-192.168.12.2\
    4-|-C0:87:EB:D8:F1:93-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/18/2019
add comment=mikhmon name="apr/18/2019-|-19:36:17-|-CBGJE-|-15000-|-192.168.12.\
    19-|-CC:2D:83:BA:71:8F-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/18/2019
add comment=mikhmon name="apr/19/2019-|-08:29:12-|-AAWSB-|-3000-|-192.168.12.1\
    07-|-0C:A8:A7:48:10:18-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/19/2019
add comment=mikhmon name="apr/19/2019-|-10:09:22-|-AYUQX-|-3000-|-192.168.12.2\
    7-|-4C:1A:3D:86:13:05-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/19/2019
add comment=mikhmon name="apr/19/2019-|-10:10:02-|-AISTA-|-3000-|-192.168.12.2\
    5-|-1C:DD:EA:88:C1:2C-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/19/2019
add comment=mikhmon name="apr/19/2019-|-10:38:18-|-AXNYT-|-3000-|-192.168.12.3\
    1-|-80:AD:16:76:6E:5E-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/19/2019
add comment=mikhmon name="apr/19/2019-|-10:50:30-|-AKIHD-|-3000-|-192.168.12.3\
    3-|-C4:3A:BE:63:5C:44-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/19/2019
add comment=mikhmon name="apr/19/2019-|-12:51:23-|-BSVPT-|-5000-|-192.168.12.1\
    7-|-A0:8D:16:24:9D:3F-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/19/2019
add comment=mikhmon name="apr/19/2019-|-13:10:39-|-BRWJX-|-5000-|-192.168.12.1\
    7-|-A0:8D:16:24:9D:3F-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/19/2019
add comment=mikhmon name="apr/19/2019-|-13:42:53-|-CKUNC-|-15000-|-192.168.12.\
    186-|-1C:87:2C:3F:F5:68-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/19/2019
add comment=mikhmon name="apr/19/2019-|-16:38:20-|-BQUBO-|-5000-|-192.168.12.2\
    2-|-CC:2D:83:A7:D7:0D-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/19/2019
add comment=mikhmon name="apr/19/2019-|-19:19:03-|-BQMJI-|-5000-|-192.168.12.2\
    3-|-54:A0:50:C5:3F:B1-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/19/2019
add comment=mikhmon name="apr/20/2019-|-06:43:37-|-BXRZB-|-5000-|-192.168.12.1\
    44-|-C0:87:EB:D5:D4:69-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/20/2019
add comment=mikhmon name="apr/20/2019-|-07:02:45-|-AEWCO-|-3000-|-192.168.12.3\
    1-|-80:AD:16:76:6E:5E-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/20/2019
add comment=mikhmon name="apr/20/2019-|-09:13:15-|-BHHZI-|-5000-|-192.168.12.9\
    9-|-2C:56:DC:E7:15:E1-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/20/2019
add comment=mikhmon name="apr/20/2019-|-09:58:39-|-BTUDF-|-5000-|-192.168.12.9\
    5-|-18:F0:E4:6C:02:34-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/20/2019
add comment=mikhmon name="apr/20/2019-|-14:59:31-|-BSZNO-|-5000-|-192.168.12.4\
    1-|-C0:87:EB:35:15:4B-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/20/2019
add comment=mikhmon name="apr/20/2019-|-15:52:19-|-CYMHX-|-15000-|-192.168.12.\
    54-|-C0:87:EB:4A:C9:1F-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/20/2019
add comment=mikhmon name="apr/20/2019-|-19:42:03-|-CNVWB-|-15000-|-192.168.12.\
    164-|-08:8C:2C:02:A3:A3-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/20/2019
add comment=mikhmon name="apr/20/2019-|-22:30:07-|-BAWLV-|-5000-|-192.168.12.2\
    4-|-C0:87:EB:D8:F1:93-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/20/2019
add comment=mikhmon name="apr/21/2019-|-06:41:24-|-BNFLJ-|-5000-|-192.168.12.3\
    1-|-80:AD:16:76:6E:5E-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/21/2019
add comment=mikhmon name="apr/21/2019-|-07:59:44-|-AZSQY-|-3000-|-192.168.12.1\
    76-|-00:27:15:24:17:D0-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/21/2019
add comment=mikhmon name="apr/21/2019-|-08:01:52-|-ASCOF-|-3000-|-192.168.12.1\
    77-|-50:8F:4C:CF:32:C7-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/21/2019
add comment=mikhmon name="apr/21/2019-|-08:07:31-|-AEFOT-|-3000-|-192.168.12.1\
    68-|-00:0A:00:D5:C3:D8-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/21/2019
add comment=mikhmon name="apr/21/2019-|-08:24:31-|-ALFAC-|-3000-|-192.168.12.2\
    9-|-0C:98:38:6A:6A:51-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/21/2019
add comment=mikhmon name="apr/21/2019-|-08:53:15-|-BCZFM-|-5000-|-192.168.12.1\
    79-|-0A:0B:E1:EE:0F:CC-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/21/2019
add comment=mikhmon name="apr/21/2019-|-15:24:27-|-ANWIF-|-3000-|-192.168.12.2\
    38-|-08:EE:8B:F5:DA:26-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/21/2019
add comment=mikhmon name="apr/21/2019-|-16:46:25-|-BXYQB-|-5000-|-192.168.12.1\
    36-|-A0:8D:16:24:9D:3F-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/21/2019
add comment=mikhmon name="apr/21/2019-|-17:18:03-|-BBYRJ-|-5000-|-192.168.12.3\
    3-|-C4:3A:BE:63:5C:44-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/21/2019
add comment=mikhmon name="apr/21/2019-|-19:48:27-|-ALLYQ-|-3000-|-192.168.12.2\
    02-|-74:51:BA:33:FC:F4-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/21/2019
add comment=mikhmon name="apr/22/2019-|-05:41:36-|-AXRKS-|-3000-|-192.168.12.1\
    97-|-00:0A:00:DD:51:88-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/22/2019
add comment=mikhmon name="apr/22/2019-|-06:57:42-|-BGZSE-|-5000-|-192.168.12.6\
    4-|-28:FA:A0:D4:98:E0-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/22/2019
add comment=mikhmon name="apr/22/2019-|-08:03:37-|-AOKOT-|-3000-|-192.168.12.1\
    76-|-00:27:15:24:17:D0-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/22/2019
add comment=mikhmon name="apr/22/2019-|-08:18:20-|-BTALZ-|-5000-|-192.168.12.1\
    07-|-0C:A8:A7:48:10:18-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/22/2019
add comment=mikhmon name="apr/22/2019-|-11:36:50-|-BRIEL-|-5000-|-192.168.12.9\
    5-|-18:F0:E4:6C:02:34-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/22/2019
add comment=mikhmon name="apr/22/2019-|-16:07:18-|-BTFFH-|-5000-|-192.168.12.2\
    3-|-54:A0:50:C5:3F:B1-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/22/2019
add comment=mikhmon name="apr/22/2019-|-16:25:36-|-BMJXB-|-5000-|-192.168.12.2\
    38-|-08:EE:8B:F5:DA:26-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/22/2019
add comment=mikhmon name="apr/22/2019-|-19:03:05-|-BGFDY-|-5000-|-192.168.12.3\
    6-|-F4:60:E2:30:CF:98-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/22/2019
add comment=mikhmon name="apr/22/2019-|-19:17:01-|-AXCGJ-|-3000-|-192.168.12.2\
    9-|-0C:98:38:6A:6A:51-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/22/2019
add comment=mikhmon name="apr/22/2019-|-19:29:56-|-AMEJB-|-3000-|-192.168.12.2\
    11-|-00:27:15:84:48:CC-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/22/2019
add comment=mikhmon name="apr/22/2019-|-22:30:54-|-BLGLO-|-5000-|-192.168.12.2\
    4-|-C0:87:EB:D8:F1:93-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/22/2019
add comment=mikhmon name="apr/23/2019-|-16:30:43-|-COWOX-|-15000-|-192.168.12.\
    13-|-80:AD:16:76:6E:5E-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/23/2019
add comment=mikhmon name="apr/23/2019-|-17:40:07-|-AHUNJ-|-3000-|-192.168.12.9\
    0-|-A4:12:32:F3:3F:AB-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/23/2019
add comment=mikhmon name="apr/23/2019-|-17:58:52-|-BCRBY-|-5000-|-192.168.12.5\
    -|-A0:8D:16:24:9D:3F-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/23/2019
add comment=mikhmon name="apr/23/2019-|-20:13:44-|-AZTBS-|-3000-|-192.168.12.1\
    12-|-8C:BF:A6:68:FC:5C-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/23/2019
add comment=mikhmon name="apr/23/2019-|-20:56:05-|-BMRXP-|-5000-|-192.168.12.1\
    16-|-1C:77:F6:E0:DE:02-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/23/2019
add comment=mikhmon name="apr/23/2019-|-23:24:11-|-AUNUA-|-3000-|-192.168.12.1\
    24-|-B0:E2:35:35:41:61-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/23/2019
add comment=mikhmon name="apr/24/2019-|-06:29:28-|-AWMSU-|-3000-|-192.168.12.1\
    13-|-24:2E:02:8D:5E:F4-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/24/2019
add comment=mikhmon name="apr/24/2019-|-08:08:24-|-ATOWJ-|-3000-|-192.168.12.1\
    37-|-24:92:0E:48:57:36-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/24/2019
add comment=mikhmon name=apr/24/2019-|-10:32:42-|-Faris-|-10000 owner=apr2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=apr/24/2019
add comment=mikhmon name="apr/24/2019-|-11:01:30-|-AJXOL-|-3000-|-192.168.12.8\
    3-|-20:5E:F7:30:5E:78-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/24/2019
add comment=mikhmon name="apr/24/2019-|-13:45:00-|-ANXSQ-|-3000-|-192.168.12.1\
    7-|-0C:98:38:6A:6A:51-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/24/2019
add comment=mikhmon name="apr/24/2019-|-13:58:13-|-BBOIJ-|-5000-|-192.168.12.1\
    2-|-18:F0:E4:6C:02:34-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/24/2019
add comment=mikhmon name="apr/24/2019-|-14:40:20-|-ATXPO-|-3000-|-192.168.12.1\
    48-|-00:0A:00:D5:C3:D8-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/24/2019
add comment=mikhmon name="apr/24/2019-|-16:09:43-|-AHINJ-|-3000-|-192.168.12.3\
    3-|-C4:3A:BE:63:5C:44-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/24/2019
add comment=mikhmon name="apr/24/2019-|-17:52:07-|-BULND-|-5000-|-192.168.12.4\
    1-|-C0:87:EB:35:15:4B-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/24/2019
add comment=mikhmon name="apr/24/2019-|-18:07:06-|-BDEFR-|-5000-|-192.168.12.2\
    3-|-54:A0:50:C5:3F:B1-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/24/2019
add comment=mikhmon name="apr/24/2019-|-19:18:29-|-ACAWX-|-3000-|-192.168.12.4\
    5-|-F0:6D:78:42:12:1A-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/24/2019
add comment=mikhmon name="apr/24/2019-|-19:58:42-|-BMNVW-|-5000-|-192.168.12.1\
    27-|-C0:87:EB:45:A0:57-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/24/2019
add comment=mikhmon name="apr/24/2019-|-20:36:22-|-BNLSO-|-5000-|-192.168.12.2\
    38-|-08:EE:8B:F5:DA:26-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/24/2019
add comment=mikhmon name="apr/24/2019-|-22:34:07-|-AYJCT-|-3000-|-192.168.12.2\
    4-|-C0:87:EB:D8:F1:93-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/24/2019
add comment=mikhmon name="apr/25/2019-|-05:19:34-|-CBRNI-|-15000-|-192.168.12.\
    11-|-CC:2D:83:BA:71:8F-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/25/2019
add comment=mikhmon name="apr/25/2019-|-07:00:41-|-AUUYO-|-3000-|-192.168.12.1\
    13-|-24:2E:02:8D:5E:F4-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/25/2019
add comment=mikhmon name="apr/25/2019-|-07:18:33-|-ADIUR-|-3000-|-192.168.12.1\
    81-|-00:27:15:24:17:D0-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/25/2019
add comment=mikhmon name="apr/25/2019-|-13:16:14-|-AHODU-|-3000-|-192.168.12.7\
    3-|-10:92:66:74:CA:EF-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/25/2019
add comment=mikhmon name="apr/25/2019-|-13:53:59-|-AULCE-|-3000-|-192.168.12.1\
    53-|-20:5E:F7:6D:E6:3A-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/25/2019
add comment=mikhmon name="apr/25/2019-|-18:29:14-|-BXGLM-|-5000-|-192.168.12.5\
    -|-A0:8D:16:24:9D:3F-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/25/2019
add comment=mikhmon name="apr/25/2019-|-18:46:39-|-Leli-|-55000-|-192.168.12.9\
    3-|-3C:B6:B7:1C:E3:83-|-30d-|-1bln-|-up-" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/25/2019
add comment=mikhmon name="apr/25/2019-|-19:06:22-|-ANIOG-|-3000-|-192.168.12.1\
    48-|-00:0A:00:D5:C3:D8-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/25/2019
add comment=mikhmon name="apr/25/2019-|-19:11:27-|-AUPMW-|-3000-|-192.168.12.2\
    06-|-8C:BF:A6:4F:C3:55-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/25/2019
add comment=mikhmon name="apr/25/2019-|-19:14:59-|-AFXWP-|-3000-|-192.168.12.8\
    3-|-20:5E:F7:30:5E:78-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/25/2019
add comment=mikhmon name="apr/25/2019-|-19:32:40-|-BWBRN-|-5000-|-192.168.12.3\
    3-|-C4:3A:BE:63:5C:44-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/25/2019
add comment=mikhmon name="apr/25/2019-|-20:25:05-|-BYEIP-|-5000-|-192.168.12.2\
    4-|-C0:87:EB:D8:F1:93-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/25/2019
add comment=mikhmon name="apr/26/2019-|-09:02:28-|-CBZVF-|-15000-|-192.168.12.\
    54-|-C0:87:EB:4A:C9:1F-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/26/2019
add comment=mikhmon name="apr/26/2019-|-09:26:57-|-BPQVJ-|-5000-|-192.168.12.4\
    5-|-F0:6D:78:42:12:1A-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/26/2019
add comment=mikhmon name="apr/26/2019-|-10:53:07-|-BYQOV-|-5000-|-192.168.12.2\
    33-|-CC:2D:83:A7:D7:0D-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/26/2019
add comment=mikhmon name="apr/26/2019-|-12:53:48-|-AXQBH-|-3000-|-192.168.12.1\
    7-|-0C:98:38:6A:6A:51-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/26/2019
add comment=mikhmon name="apr/26/2019-|-14:13:41-|-AWGTQ-|-3000-|-192.168.12.2\
    36-|-38:A4:ED:A1:2E:37-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/26/2019
add comment=mikhmon name="apr/26/2019-|-16:14:33-|-AQLUO-|-3000-|-192.168.12.1\
    53-|-20:5E:F7:6D:E6:3A-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/26/2019
add comment=mikhmon name="apr/26/2019-|-16:57:34-|-BKJAE-|-5000-|-192.168.12.1\
    2-|-18:F0:E4:6C:02:34-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/26/2019
add comment=mikhmon name="apr/26/2019-|-17:00:15-|-ANZBN-|-3000-|-192.168.12.2\
    22-|-20:5E:F7:30:5E:78-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/26/2019
add comment=mikhmon name="apr/26/2019-|-19:13:51-|-BIPNE-|-5000-|-192.168.12.3\
    1-|-1C:87:2C:3F:F5:68-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/26/2019
add comment=mikhmon name="apr/27/2019-|-07:49:35-|-CNTBV-|-15000-|-192.168.12.\
    127-|-C0:87:EB:45:A0:57-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/27/2019
add comment=mikhmon name="apr/27/2019-|-08:50:55-|-BOSWC-|-5000-|-192.168.12.1\
    44-|-C0:87:EB:D5:D4:69-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/27/2019
add comment=mikhmon name="apr/27/2019-|-13:25:15-|-BARPR-|-5000-|-192.168.12.2\
    3-|-54:A0:50:C5:3F:B1-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/27/2019
add comment=mikhmon name="apr/27/2019-|-17:54:06-|-ARBVU-|-3000-|-192.168.12.5\
    0-|-B4:C0:F5:07:F8:7B-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/27/2019
add comment=mikhmon name="apr/28/2019-|-06:21:38-|-AKKUT-|-3000-|-192.168.12.7\
    3-|-10:92:66:74:CA:EF-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/28/2019
add comment=mikhmon name="apr/28/2019-|-08:27:20-|-AVFSV-|-3000-|-192.168.12.5\
    6-|-00:27:15:24:17:D0-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/28/2019
add comment=mikhmon name="apr/28/2019-|-09:55:29-|-BRWAS-|-5000-|-192.168.12.4\
    5-|-F0:6D:78:42:12:1A-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/28/2019
add comment=mikhmon name="apr/28/2019-|-12:41:16-|-BKWPL-|-5000-|-192.168.12.1\
    7-|-0C:98:38:6A:6A:51-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/28/2019
add comment=mikhmon name="apr/28/2019-|-12:49:19-|-AOBRH-|-3000-|-192.168.12.3\
    2-|-38:A4:ED:A1:2E:37-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/28/2019
add comment=mikhmon name="apr/28/2019-|-12:54:31-|-AGBHN-|-3000-|-192.168.12.1\
    53-|-20:5E:F7:6D:E6:3A-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/28/2019
add comment=mikhmon name="apr/28/2019-|-12:54:48-|-BWEVK-|-5000-|-192.168.12.6\
    0-|-28:FA:A0:D4:98:E0-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/28/2019
add comment=mikhmon name="apr/28/2019-|-15:09:07-|-BRZFL-|-5000-|-192.168.12.4\
    4-|-2C:56:DC:E7:15:E1-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/28/2019
add comment=mikhmon name="apr/28/2019-|-17:09:15-|-CSHHL-|-15000-|-192.168.12.\
    91-|-4C:49:E3:15:CC:E1-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/28/2019
add comment=mikhmon name="apr/28/2019-|-18:47:41-|-BHNIL-|-5000-|-192.168.12.2\
    9-|-C0:87:EB:D8:F1:93-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/28/2019
add comment=mikhmon name="apr/29/2019-|-08:12:18-|-CQCDI-|-15000-|-192.168.12.\
    15-|-E0:99:71:C7:B6:9F-|-7d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/29/2019
add comment=mikhmon name="apr/29/2019-|-08:17:02-|-BKGVT-|-5000-|-192.168.12.7\
    0-|-24:2E:02:8D:5E:F4-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/29/2019
add comment=mikhmon name="apr/29/2019-|-09:14:42-|-AJQWF-|-3000-|-192.168.12.7\
    3-|-10:92:66:74:CA:EF-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/29/2019
add comment=mikhmon name="apr/29/2019-|-10:51:38-|-BJCRX-|-5000-|-192.168.12.1\
    2-|-18:F0:E4:6C:02:34-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/29/2019
add comment=mikhmon name="apr/29/2019-|-13:02:17-|-BSNRZ-|-5000-|-192.168.12.2\
    3-|-54:A0:50:C5:3F:B1-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/29/2019
add comment=mikhmon name="apr/29/2019-|-13:05:18-|-BTJBH-|-5000-|-192.168.12.2\
    2-|-C4:3A:BE:63:5C:44-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/29/2019
add comment=mikhmon name="apr/29/2019-|-14:41:54-|-ASPYE-|-3000-|-192.168.12.5\
    8-|-20:5E:F7:30:5E:78-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/29/2019
add comment=mikhmon name="apr/29/2019-|-16:20:20-|-ACMKJ-|-3000-|-192.168.12.1\
    53-|-20:5E:F7:6D:E6:3A-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/29/2019
add comment=mikhmon name="apr/29/2019-|-17:46:22-|-ARJIT-|-3000-|-192.168.12.7\
    1-|-3C:95:09:E7:6D:13-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/29/2019
add comment=mikhmon name="apr/29/2019-|-19:14:36-|-BSCGK-|-5000-|-192.168.12.5\
    -|-1C:87:2C:3F:F5:68-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/29/2019
add comment=mikhmon name="apr/30/2019-|-11:52:38-|-BIQJR-|-5000-|-192.168.12.1\
    44-|-C0:87:EB:D5:D4:69-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/30/2019
add comment=mikhmon name="apr/30/2019-|-14:03:51-|-ALZJL-|-3000-|-192.168.12.6\
    1-|-00:27:15:63:22:FB-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/30/2019
add comment=mikhmon name="apr/30/2019-|-17:52:19-|-BESKX-|-5000-|-192.168.12.4\
    5-|-F0:6D:78:42:12:1A-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/30/2019
add comment=mikhmon name=apr/30/2019-|-19:04:31-|-Nafis-|-10000 owner=apr2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=apr/30/2019
add comment=mikhmon name="apr/30/2019-|-19:35:52-|-ASZKF-|-3000-|-192.168.12.9\
    0-|-00:0A:00:D5:C3:D8-|-1d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/30/2019
add comment=mikhmon name="apr/30/2019-|-19:58:57-|-BRXTD-|-5000-|-192.168.12.2\
    9-|-C0:87:EB:D8:F1:93-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/30/2019
add comment=mikhmon name="apr/30/2019-|-19:58:59-|-BGUFR-|-5000-|-192.168.12.1\
    1-|-0C:98:38:6A:6A:51-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/30/2019
add comment=mikhmon name="apr/30/2019-|-20:47:04-|-BMBGV-|-5000-|-192.168.12.9\
    7-|-88:D5:0C:08:6B:3C-|-2d" owner=apr2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    apr/30/2019
add comment=mikhmon name=apr/30/2019-|-21:58:33-|-Nafis-|-10000 owner=apr2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=apr/30/2019
add comment=mikhmon name="may/05/2019-|-20:02:58-|-AWLPS-|-3000-|-192.168.12.9\
    7-|-60:72:8D:62:53:EB-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/05/2019
add comment=mikhmon name="may/05/2019-|-20:21:11-|-BKWHM-|-5000-|-192.168.12.4\
    1-|-C0:87:EB:35:15:4B-|-2d-|-2hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/05/2019
add comment=mikhmon name="may/05/2019-|-20:57:26-|-AZCII-|-3000-|-192.168.12.7\
    3-|-10:92:66:74:CA:EF-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/05/2019
add comment=mikhmon name="may/05/2019-|-21:10:50-|-BLHXP-|-5000-|-192.168.12.1\
    04-|-10:F6:81:D6:97:63-|-2d-|-2hari-|-up-994-04.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/05/2019
add comment=mikhmon name="may/05/2019-|-22:36:31-|-BRSBS-|-5000-|-192.168.12.3\
    5-|-50:29:F5:E0:02:2D-|-2d-|-2hari-|-up-pndik" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/05/2019
add comment=mikhmon name="may/05/2019-|-22:47:36-|-BIJKM-|-5000-|-192.168.12.4\
    0-|-D4:1A:3F:40:44:8F-|-2d-|-2hari-|-up-pndik" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/05/2019
add comment=mikhmon name="may/06/2019-|-11:09:10-|-ACFDH-|-3000-|-192.168.12.1\
    1-|-0C:98:38:6A:6A:51-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/06/2019
add comment=mikhmon name="may/06/2019-|-11:24:08-|-CUEQR-|-15000-|-192.168.12.\
    15-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-562-12.02.18-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/06/2019
add comment=mikhmon name="may/06/2019-|-13:15:57-|-BUNFX-|-5000-|-192.168.12.4\
    3-|-80:AD:16:76:6E:5E-|-2d-|-2hari-|-up-994-04.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/06/2019
add comment=mikhmon name="may/06/2019-|-13:27:48-|-AFFVY-|-3000-|-192.168.12.4\
    4-|-0C:A8:A7:48:10:18-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/06/2019
add comment=mikhmon name="may/06/2019-|-13:29:26-|-BNMQQ-|-5000-|-192.168.12.7\
    8-|-24:2E:02:8D:5E:F4-|-2d-|-2hari-|-up-994-04.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/06/2019
add comment=mikhmon name="may/06/2019-|-14:06:42-|-BQQIF-|-5000-|-192.168.12.2\
    0-|-18:F0:E4:6C:02:34-|-2d-|-2hari-|-up-994-04.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/06/2019
add comment=mikhmon name="may/06/2019-|-15:09:19-|-BXZNE-|-5000-|-192.168.12.7\
    8-|-24:2E:02:8D:5E:F4-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/06/2019
add comment=mikhmon name="may/06/2019-|-17:19:19-|-BGEGZ-|-5000-|-192.168.12.6\
    1-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/06/2019
add comment=mikhmon name="may/06/2019-|-18:01:58-|-BDCUU-|-5000-|-192.168.12.2\
    3-|-54:A0:50:C5:3F:B1-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/06/2019
add comment=mikhmon name="may/07/2019-|-02:32:25-|-ATZII-|-3000-|-192.168.12.1\
    1-|-0C:98:38:6A:6A:51-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/07/2019
add comment=mikhmon name="may/07/2019-|-09:45:14-|-BJYZE-|-5000-|-192.168.12.1\
    6-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/07/2019
add comment=mikhmon name="may/07/2019-|-10:40:13-|-BDXIS-|-5000-|-192.168.12.6\
    9-|-20:5E:F7:6D:E6:3A-|-2d-|-2hari-|-up-994-04.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/07/2019
add comment=mikhmon name="may/07/2019-|-11:25:10-|-BUDFB-|-5000-|-192.168.12.7\
    7-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/07/2019
add comment=mikhmon name="may/07/2019-|-12:58:10-|-BDJCE-|-5000-|-192.168.12.4\
    2-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-994-04.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/07/2019
add comment=mikhmon name="may/07/2019-|-16:16:38-|-AZFOX-|-3000-|-192.168.12.9\
    4-|-60:72:8D:62:53:EB-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/07/2019
add comment=mikhmon name="may/07/2019-|-16:57:04-|-ATZII-|-3000-|-192.168.12.1\
    1-|-0C:98:38:6A:6A:51-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/07/2019
add comment=mikhmon name="may/07/2019-|-20:06:12-|-BFHCV-|-5000-|-192.168.12.1\
    05-|-C4:3A:BE:63:5C:44-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/07/2019
add comment=mikhmon name="may/07/2019-|-21:04:04-|-BZQGF-|-5000-|-192.168.12.1\
    44-|-C0:87:EB:D5:D4:69-|-2d-|-2hari-|-up-994-04.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/07/2019
add comment=mikhmon name="may/07/2019-|-21:04:40-|-BUHOG-|-5000-|-192.168.12.4\
    6-|-20:5E:F7:E8:78:B2-|-2d-|-2hari-|-up-994-04.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/07/2019
add comment=mikhmon name="may/08/2019-|-01:47:35-|-AJXLS-|-3000-|-192.168.12.2\
    9-|-C0:87:EB:D8:F1:93-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/08/2019
add comment=mikhmon name="may/08/2019-|-08:31:19-|-AZPVZ-|-3000-|-192.168.12.7\
    3-|-10:92:66:74:CA:EF-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/08/2019
add comment=mikhmon name="may/08/2019-|-09:32:22-|-ACMKG-|-3000-|-192.168.12.2\
    9-|-C0:87:EB:D8:F1:93-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/08/2019
add comment=mikhmon name="may/08/2019-|-13:05:02-|-BZKFM-|-5000-|-192.168.12.4\
    4-|-0C:A8:A7:48:10:18-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/08/2019
add comment=mikhmon name="may/08/2019-|-14:21:34-|-BZDZI-|-5000-|-192.168.12.5\
    -|-D4:1A:3F:40:44:8F-|-2d-|-2hari-|-up-pndik" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/08/2019
add comment=mikhmon name="may/08/2019-|-18:13:40-|-BDYNH-|-5000-|-192.168.12.3\
    8-|-18:F0:E4:6C:02:34-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/08/2019
add comment=mikhmon name="may/08/2019-|-19:50:00-|-BEGBL-|-5000-|-192.168.12.6\
    1-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-994-04.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/08/2019
add comment=mikhmon name="may/08/2019-|-20:34:43-|-AYPND-|-3000-|-192.168.12.2\
    9-|-C0:87:EB:D8:F1:93-|-1d-|-1hari-|-up-pndik" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/08/2019
add comment=mikhmon name="may/08/2019-|-21:00:16-|-AAMHP-|-3000-|-192.168.12.1\
    30-|-80:AD:16:75:AC:62-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/08/2019
add comment=mikhmon name="may/08/2019-|-22:43:25-|-BMEHC-|-5000-|-192.168.12.1\
    4-|-50:29:F5:E0:02:2D-|-2d-|-2hari-|-up-pndik" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/08/2019
add comment=mikhmon name="may/08/2019-|-22:45:17-|-BIGUL-|-5000-|-192.168.12.2\
    3-|-54:A0:50:C5:3F:B1-|-2d-|-2hari-|-up-994-04.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/08/2019
add comment=mikhmon name="may/09/2019-|-08:30:18-|-BXDFP-|-5000-|-192.168.12.3\
    5-|-CC:2D:83:BA:71:8F-|-2d-|-2hari-|-up-pndik" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/09/2019
add comment=mikhmon name="may/09/2019-|-11:29:03-|-BJRFD-|-5000-|-192.168.12.6\
    9-|-20:5E:F7:6D:E6:3A-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/09/2019
add comment=mikhmon name="may/09/2019-|-12:21:33-|-BXVWR-|-5000-|-192.168.12.1\
    6-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/09/2019
add comment=mikhmon name="may/09/2019-|-13:00:00-|-ALPGI-|-3000-|-192.168.12.6\
    7-|-24:2E:02:8D:5E:F4-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/09/2019
add comment=mikhmon name="may/09/2019-|-17:12:04-|-AWIXS-|-3000-|-192.168.12.1\
    04-|-10:F6:81:D6:97:63-|-1d-|-1hari-|-up-pndik" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/09/2019
add comment=mikhmon name="may/09/2019-|-18:02:46-|-AVEYJ-|-3000-|-192.168.12.9\
    4-|-60:72:8D:62:53:EB-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/09/2019
add comment=mikhmon name="may/09/2019-|-18:27:46-|-BJPPG-|-5000-|-192.168.12.7\
    7-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/09/2019
add comment=mikhmon name="may/09/2019-|-19:47:08-|-BXDJC-|-5000-|-192.168.12.2\
    00-|-B4:C0:F5:07:F8:7B-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/09/2019
add comment=mikhmon name="may/09/2019-|-20:01:18-|-ATBGP-|-3000-|-192.168.12.2\
    9-|-C0:87:EB:D8:F1:93-|-1d-|-1hari-|-up-pndik" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/09/2019
add comment=mikhmon name="may/09/2019-|-23:36:47-|-BPTFP-|-5000-|-192.168.12.1\
    05-|-C4:3A:BE:63:5C:44-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/09/2019
add comment=mikhmon name="may/10/2019-|-08:57:06-|-BTUCW-|-5000-|-192.168.12.4\
    2-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-994-04.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/10/2019
add comment=mikhmon name="may/10/2019-|-10:22:59-|-COWFN-|-15000-|-192.168.12.\
    54-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-562-12.02.18-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/10/2019
add comment=mikhmon name="may/10/2019-|-12:56:55-|-BHBSR-|-5000-|-192.168.12.2\
    2-|-80:AD:16:76:6E:5E-|-2d-|-2hari-|-up-994-04.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/10/2019
add comment=mikhmon name="may/10/2019-|-17:41:51-|-AMBPA-|-3000-|-192.168.12.4\
    1-|-C0:87:EB:35:15:4B-|-1d-|-1hari-|-up-pndik" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/10/2019
add comment=mikhmon name="may/10/2019-|-18:00:21-|-AYUXC-|-3000-|-192.168.12.1\
    04-|-10:F6:81:D6:97:63-|-1d-|-1hari-|-up-pndik" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/10/2019
add comment=mikhmon name="may/10/2019-|-18:04:20-|-ADWEC-|-3000-|-192.168.12.6\
    7-|-24:2E:02:8D:5E:F4-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/10/2019
add comment=mikhmon name="may/10/2019-|-18:15:42-|-BMHVG-|-5000-|-192.168.12.1\
    44-|-C0:87:EB:D5:D4:69-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/10/2019
add comment=mikhmon name="may/10/2019-|-19:59:47-|-ABRUA-|-3000-|-192.168.12.2\
    06-|-8C:BF:A6:4F:C3:55-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/10/2019
add comment=mikhmon name="may/10/2019-|-20:23:47-|-AXILI-|-3000-|-192.168.12.8\
    -|-0A:0B:E1:EE:0F:CC-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/10/2019
add comment=mikhmon name="may/10/2019-|-21:09:37-|-AYXUF-|-3000-|-192.168.12.2\
    9-|-C0:87:EB:D8:F1:93-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/10/2019
add comment=mikhmon name="may/11/2019-|-04:41:02-|-BNHXO-|-5000-|-192.168.12.6\
    9-|-20:5E:F7:6D:E6:3A-|-2d-|-2hari-|-up-994-04.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/11/2019
add comment=mikhmon name="may/11/2019-|-06:05:07-|-BQOBK-|-5000-|-192.168.12.3\
    8-|-18:F0:E4:6C:02:34-|-2d-|-2hari-|-up-994-04.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/11/2019
add comment=mikhmon name="may/11/2019-|-06:13:47-|-BAFGW-|-5000-|-192.168.12.2\
    30-|-28:83:35:94:FE:E2-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/11/2019
add comment=mikhmon name="may/11/2019-|-15:16:23-|-BXVWR-|-5000-|-192.168.12.1\
    6-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/11/2019
add comment=mikhmon name="may/11/2019-|-19:46:30-|-CNSPH-|-15000-|-192.168.12.\
    35-|-CC:2D:83:BA:71:8F-|-7d-|-7hari-|-up-562-12.02.18-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/11/2019
add comment=mikhmon name="may/11/2019-|-21:09:20-|-AVNKD-|-3000-|-192.168.12.9\
    5-|-20:5E:F7:EC:1B:86-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/11/2019
add comment=mikhmon name="may/11/2019-|-21:28:53-|-AONSD-|-3000-|-192.168.12.8\
    -|-0A:0B:E1:EE:0F:CC-|-1d-|-1hari-|-up-628-04.07.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/11/2019
add comment=mikhmon name="may/11/2019-|-21:30:26-|-ASKCD-|-3000-|-192.168.12.2\
    9-|-C0:87:EB:D8:F1:93-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/11/2019
add comment=mikhmon name="may/11/2019-|-23:28:07-|-BRFDA-|-5000-|-192.168.12.1\
    02-|-1C:87:2C:C2:8E:63-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/11/2019
add comment=mikhmon name="may/12/2019-|-02:48:50-|-BMRUT-|-5000-|-192.168.12.4\
    4-|-0C:A8:A7:48:10:18-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/12/2019
add comment=mikhmon name="may/12/2019-|-08:56:46-|-ABXEZ-|-3000-|-192.168.12.1\
    20-|-0C:A8:A7:3F:04:14-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/12/2019
add comment=mikhmon name="may/12/2019-|-09:07:12-|-BAVSS-|-5000-|-192.168.12.4\
    2-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/12/2019
add comment=mikhmon name="may/12/2019-|-14:49:50-|-AUNMJ-|-3000-|-192.168.12.1\
    37-|-2C:56:DC:E7:15:E1-|-1d-|-1hari-|-up-628-04.07.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/12/2019
add comment=mikhmon name="may/12/2019-|-17:22:49-|-BSCXD-|-5000-|-192.168.12.2\
    3-|-54:A0:50:C5:3F:B1-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/12/2019
add comment=mikhmon name="may/12/2019-|-19:03:57-|-BZFWR-|-5000-|-192.168.12.2\
    2-|-80:AD:16:76:6E:5E-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/12/2019
add comment=mikhmon name="may/12/2019-|-19:42:17-|-BIGDU-|-5000-|-192.168.12.1\
    55-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/12/2019
add comment=mikhmon name="may/12/2019-|-20:06:00-|-BPVRV-|-5000-|-192.168.12.2\
    00-|-B4:C0:F5:07:F8:7B-|-2d-|-2hari-|-up-994-04.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/12/2019
add comment=mikhmon name="may/12/2019-|-20:10:01-|-BHWZI-|-5000-|-192.168.12.1\
    6-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/12/2019
add comment=mikhmon name="may/12/2019-|-20:50:04-|-ARFUN-|-3000-|-192.168.12.7\
    6-|-20:5E:F7:C2:C5:A2-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/12/2019
add comment=mikhmon name="may/13/2019-|-01:28:21-|-AFMMS-|-3000-|-192.168.12.2\
    9-|-C0:87:EB:D8:F1:93-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/13/2019
add comment=mikhmon name="may/13/2019-|-07:16:49-|-BVVNP-|-5000-|-192.168.12.1\
    05-|-C4:3A:BE:63:5C:44-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/13/2019
add comment=mikhmon name="may/13/2019-|-09:03:28-|-AGSNO-|-3000-|-192.168.12.1\
    1-|-0C:98:38:6A:6A:51-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/13/2019
add comment=mikhmon name="may/13/2019-|-13:18:05-|-AXPAI-|-3000-|-192.168.12.6\
    9-|-20:5E:F7:6D:E6:3A-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/13/2019
add comment=mikhmon name="may/13/2019-|-14:49:15-|-AENCU-|-3000-|-192.168.12.8\
    -|-0A:0B:E1:EE:0F:CC-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/13/2019
add comment=mikhmon name="may/13/2019-|-17:37:58-|-BMIHC-|-5000-|-192.168.12.3\
    8-|-18:F0:E4:6C:02:34-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/13/2019
add comment=mikhmon name="may/13/2019-|-18:25:05-|-CZYIR-|-15000-|-192.168.12.\
    18-|-08:8C:2C:02:A3:A3-|-7d-|-7hari-|-up-562-12.02.18-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/13/2019
add comment=mikhmon name="may/13/2019-|-20:25:19-|-CEDOZ-|-15000-|-192.168.12.\
    15-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-562-12.02.18-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/13/2019
add comment=mikhmon name="may/13/2019-|-20:37:21-|-BXQPH-|-5000-|-192.168.12.2\
    06-|-8C:BF:A6:4F:C3:55-|-2d-|-2hari-|-up-994-04.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/13/2019
add comment=mikhmon name="may/14/2019-|-02:36:45-|-ATYMB-|-3000-|-192.168.12.8\
    -|-F8:84:F2:8B:81:C6-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/14/2019
add comment=mikhmon name="may/14/2019-|-03:25:31-|-BVZMH-|-5000-|-192.168.12.1\
    02-|-1C:87:2C:C2:8E:63-|-2d-|-2hari-|-up-994-04.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/14/2019
add comment=mikhmon name="may/14/2019-|-03:27:18-|-BZTKR-|-5000-|-192.168.12.2\
    9-|-C0:87:EB:D8:F1:93-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/14/2019
add comment=mikhmon name="may/14/2019-|-03:54:56-|-BVAFX-|-5000-|-192.168.12.4\
    4-|-0C:A8:A7:48:10:18-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/14/2019
add comment=mikhmon name="may/14/2019-|-06:53:21-|-AFBDQ-|-3000-|-192.168.12.4\
    7-|-48:FC:B6:0C:A9:F7-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/14/2019
add comment=mikhmon name="may/14/2019-|-09:45:33-|-BEBWS-|-5000-|-192.168.12.4\
    2-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/14/2019
add comment=mikhmon name="may/14/2019-|-18:38:19-|-AIDHC-|-3000-|-192.168.12.6\
    9-|-20:5E:F7:6D:E6:3A-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/14/2019
add comment=mikhmon name="may/14/2019-|-21:56:42-|-BPMDJ-|-5000-|-192.168.12.3\
    2-|-0A:0B:E1:EE:0F:CC-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/14/2019
add comment=mikhmon name="may/15/2019-|-09:05:24-|-AOONM-|-3000-|-192.168.12.1\
    51-|-00:27:15:63:22:FB-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/15/2019
add comment=mikhmon name="may/15/2019-|-09:33:44-|-AEMJK-|-3000-|-192.168.12.1\
    52-|-70:78:8B:C0:C5:2D-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/15/2019
add comment=mikhmon name="may/15/2019-|-10:11:55-|-AXRUI-|-3000-|-192.168.12.4\
    7-|-48:FC:B6:0C:A9:F7-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/15/2019
add comment=mikhmon name="may/15/2019-|-11:55:02-|-BOCXL-|-5000-|-192.168.12.2\
    2-|-80:AD:16:76:6E:5E-|-2d-|-2hari-|-up-994-04.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/15/2019
add comment=mikhmon name="may/15/2019-|-13:23:56-|-BASAA-|-5000-|-192.168.12.2\
    3-|-54:A0:50:C5:3F:B1-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/15/2019
add comment=mikhmon name="may/15/2019-|-15:25:26-|-AJHDR-|-3000-|-192.168.12.6\
    4-|-20:5E:F7:30:5E:78-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/15/2019
add comment=mikhmon name="may/15/2019-|-16:18:57-|-BQTLN-|-5000-|-192.168.12.1\
    53-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-994-04.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/15/2019
add comment=mikhmon name="may/15/2019-|-18:35:56-|-BJZGR-|-5000-|-192.168.12.3\
    8-|-18:F0:E4:6C:02:34-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/15/2019
add comment=mikhmon name="may/15/2019-|-19:56:41-|-BZRUJ-|-5000-|-192.168.12.1\
    55-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-494-05.05.19-050519b" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/15/2019
add comment=mikhmon name="may/15/2019-|-20:14:25-|-AIYPK-|-3000-|-192.168.12.1\
    6-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/15/2019
add comment=mikhmon name="may/15/2019-|-20:36:56-|-AIIMZ-|-3000-|-192.168.12.4\
    2-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/15/2019
add comment=mikhmon name="may/15/2019-|-22:10:24-|-AEHNJ-|-3000-|-192.168.12.6\
    9-|-20:5E:F7:6D:E6:3A-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/15/2019
add comment=mikhmon name="may/16/2019-|-03:23:15-|-ABAGX-|-3000-|-192.168.12.5\
    -|-B4:C0:F5:07:F8:7B-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/16/2019
add comment=mikhmon name="may/16/2019-|-11:40:39-|-AFSJV-|-3000-|-192.168.12.1\
    44-|-C0:87:EB:D5:D4:69-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/16/2019
add comment=mikhmon name="may/16/2019-|-20:00:35-|-AEFNI-|-3000-|-192.168.12.2\
    9-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/16/2019
add comment=mikhmon name="may/16/2019-|-20:05:32-|-ASUMC-|-3000-|-192.168.12.1\
    6-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/16/2019
add comment=mikhmon name="may/16/2019-|-23:00:44-|-ARBVA-|-3000-|-192.168.12.7\
    6-|-20:5E:F7:C2:C5:A2-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/16/2019
add comment=mikhmon name="may/16/2019-|-23:08:02-|-AWJAP-|-3000-|-192.168.12.6\
    9-|-20:5E:F7:6D:E6:3A-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/16/2019
add comment=mikhmon name="may/17/2019-|-03:43:49-|-AXFJJ-|-3000-|-192.168.12.4\
    1-|-0C:A8:A7:48:10:18-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/17/2019
add comment=mikhmon name="may/17/2019-|-07:03:46-|-AFIRY-|-3000-|-192.168.12.1\
    44-|-C0:87:EB:D5:D4:69-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/17/2019
add comment=mikhmon name="may/17/2019-|-11:12:36-|-CNFTA-|-15000-|-192.168.12.\
    13-|-CC:2D:83:BA:71:8F-|-7d-|-7hari-|-up-562-12.02.18-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/17/2019
add comment=mikhmon name="may/17/2019-|-12:19:53-|-ACHUJ-|-3000-|-192.168.12.5\
    -|-B4:C0:F5:07:F8:7B-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/17/2019
add comment=mikhmon name="may/17/2019-|-14:57:46-|-AVPKW-|-3000-|-192.168.12.8\
    5-|-80:AD:16:76:6E:5E-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/17/2019
add comment=mikhmon name="may/17/2019-|-16:08:13-|-AGGXW-|-3000-|-192.168.12.1\
    6-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/17/2019
add comment=mikhmon name="may/17/2019-|-17:55:15-|-BIRRP-|-5000-|-192.168.12.6\
    6-|-4C:49:E3:FF:91:25-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/17/2019
add comment=mikhmon name="may/17/2019-|-18:33:27-|-CFPOM-|-15000-|-192.168.12.\
    22-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-562-12.02.18-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/17/2019
add comment=mikhmon name="may/17/2019-|-20:15:37-|-AXTOG-|-3000-|-192.168.12.6\
    9-|-20:5E:F7:6D:E6:3A-|-1d-|-1hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/17/2019
add comment=mikhmon name="may/17/2019-|-20:46:39-|-BNWIG-|-5000-|-192.168.12.2\
    9-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/17/2019
add comment=mikhmon name="may/18/2019-|-04:01:58-|-AEURN-|-3000-|-192.168.12.4\
    1-|-0C:A8:A7:48:10:18-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/18/2019
add comment=mikhmon name="may/18/2019-|-08:29:03-|-AXPGJ-|-3000-|-192.168.12.8\
    5-|-80:AD:16:76:6E:5E-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/18/2019
add comment=mikhmon name="may/18/2019-|-12:23:52-|-ARXPP-|-3000-|-192.168.12.5\
    -|-B4:C0:F5:07:F8:7B-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/18/2019
add comment=mikhmon name="may/18/2019-|-12:38:48-|-BMGSY-|-5000-|-192.168.12.1\
    6-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/18/2019
add comment=mikhmon name="may/18/2019-|-14:16:38-|-BREVM-|-5000-|-192.168.12.1\
    40-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/18/2019
add comment=mikhmon name="may/18/2019-|-20:40:42-|-AUDHF-|-3000-|-192.168.12.3\
    6-|-0C:98:38:6A:6A:51-|-1d-|-1hari-|-up-861-05.05.19-050519" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/18/2019
add comment=mikhmon name="may/19/2019-|-18:38:47-|-BIKYC-|-5000-|-192.168.12.2\
    43-|-18:F0:E4:6C:02:34-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/19/2019
add comment=mikhmon name="may/19/2019-|-20:49:27-|-AVHVK-|-3000-|-192.168.12.2\
    9-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/19/2019
add comment=mikhmon name="may/19/2019-|-21:57:28-|-CZUMZ-|-15000-|-192.168.12.\
    70-|-C4:3A:BE:63:5C:44-|-7d-|-7hari-|-up-562-12.02.18-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/19/2019
add comment=mikhmon name="may/20/2019-|-03:38:55-|-BUKNZ-|-5000-|-192.168.12.4\
    1-|-0C:A8:A7:48:10:18-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/20/2019
add comment=mikhmon name="may/20/2019-|-13:22:56-|-AADYN-|-3000-|-192.168.12.3\
    3-|-24:2E:02:8D:5E:F4-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/20/2019
add comment=mikhmon name="may/20/2019-|-14:28:18-|-AMZFV-|-3000-|-192.168.12.3\
    9-|-1C:C3:EB:38:50:97-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/20/2019
add comment=mikhmon name="may/21/2019-|-03:03:35-|-BSZFZ-|-5000-|-192.168.12.1\
    5-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/21/2019
add comment=mikhmon name="may/21/2019-|-11:50:04-|-BVQGM-|-5000-|-192.168.12.5\
    7-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/21/2019
add comment=mikhmon name="may/21/2019-|-13:46:41-|-AXNKA-|-3000-|-192.168.12.6\
    1-|-24:2E:02:8D:5E:F4-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/21/2019
add comment=mikhmon name="may/21/2019-|-16:23:29-|-AZPGY-|-3000-|-192.168.12.8\
    3-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/21/2019
add comment=mikhmon name="may/21/2019-|-19:40:32-|-BTYPE-|-5000-|-192.168.12.6\
    1-|-24:2E:02:8D:5E:F4-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/21/2019
add comment=mikhmon name="may/21/2019-|-19:43:17-|-BQEUC-|-5000-|-192.168.12.2\
    8-|-C0:87:EB:D5:D4:69-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/21/2019
add comment=mikhmon name="may/21/2019-|-19:43:17-|-BVAIX-|-5000-|-192.168.12.1\
    59-|-20:5E:F7:E8:78:B2-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/21/2019
add comment=mikhmon name="may/21/2019-|-19:45:55-|-APXNF-|-3000-|-192.168.12.2\
    6-|-0C:98:38:6A:6A:51-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/21/2019
add comment=mikhmon name="may/22/2019-|-04:57:58-|-BMVPR-|-5000-|-192.168.12.4\
    1-|-0C:A8:A7:48:10:18-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/22/2019
add comment=mikhmon name="may/22/2019-|-10:18:03-|-BVGJP-|-5000-|-192.168.12.2\
    43-|-18:F0:E4:6C:02:34-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/22/2019
add comment=mikhmon name="may/22/2019-|-12:01:48-|-BDTXJ-|-5000-|-192.168.12.1\
    48-|-84:4B:F5:2A:51:C1-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/22/2019
add comment=mikhmon name="may/22/2019-|-17:59:12-|-ASDXA-|-3000-|-192.168.12.1\
    81-|-3C:95:09:E7:6D:13-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/22/2019
add comment=mikhmon name="may/22/2019-|-20:32:56-|-ARRYT-|-3000-|-192.168.12.1\
    1-|-E0:99:71:C7:B6:9F-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/22/2019
add comment=mikhmon name="may/23/2019-|-06:52:44-|-ARFZM-|-3000-|-192.168.12.1\
    16-|-80:AD:16:76:6E:5E-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/23/2019
add comment=mikhmon name="may/23/2019-|-09:37:10-|-AAKVU-|-3000-|-192.168.12.2\
    6-|-0C:98:38:6A:6A:51-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/23/2019
add comment=mikhmon name="may/23/2019-|-09:43:57-|-AFEJD-|-3000-|-192.168.12.2\
    9-|-2C:56:DC:E7:15:E1-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/23/2019
add comment=mikhmon name="may/23/2019-|-10:21:39-|-BCYYG-|-5000-|-192.168.12.1\
    5-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/23/2019
add comment=mikhmon name="may/23/2019-|-15:39:57-|-APAII-|-3000-|-192.168.12.5\
    7-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/23/2019
add comment=mikhmon name="may/23/2019-|-20:49:59-|-BGBKV-|-5000-|-192.168.12.2\
    22-|-1C:87:2C:C2:8E:63-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/23/2019
add comment=mikhmon name="may/24/2019-|-12:24:29-|-CZDLN-|-15000-|-192.168.12.\
    28-|-C0:87:EB:D5:D4:69-|-7d-|-7hari-|-up-562-12.02.18-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/24/2019
add comment=mikhmon name="may/24/2019-|-15:38:59-|-BFKRY-|-5000-|-192.168.12.5\
    7-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/24/2019
add comment=mikhmon name="may/24/2019-|-16:02:34-|-AMTJK-|-3000-|-192.168.12.2\
    7-|-48:88:CA:BA:37:9B-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/24/2019
add comment=mikhmon name="may/24/2019-|-18:15:49-|-AFAFS-|-3000-|-192.168.12.2\
    6-|-0C:98:38:6A:6A:51-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/24/2019
add comment=mikhmon name="may/24/2019-|-19:35:09-|-AUZWF-|-3000-|-192.168.12.2\
    06-|-00:27:15:24:17:D0-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/24/2019
add comment=mikhmon name="may/25/2019-|-03:10:33-|-BNIZB-|-5000-|-192.168.12.6\
    0-|-0C:A8:A7:48:10:18-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/25/2019
add comment=mikhmon name="may/25/2019-|-09:31:23-|-BHNXZ-|-5000-|-192.168.12.1\
    9-|-18:F0:E4:6C:02:34-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/25/2019
add comment=mikhmon name="may/25/2019-|-10:03:14-|-AURBJ-|-3000-|-192.168.12.2\
    3-|-D4:AE:05:F8:4C:01-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/25/2019
add comment=mikhmon name="may/25/2019-|-10:18:38-|-CZKXG-|-15000-|-192.168.12.\
    22-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-562-12.02.18-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/25/2019
add comment=mikhmon name="may/25/2019-|-10:27:23-|-BKKYQ-|-5000-|-192.168.12.1\
    7-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/25/2019
add comment=mikhmon name="may/25/2019-|-11:01:39-|-nafis-|-20000-|-192.168.12.\
    27-|-28:FA:A0:D4:98:E0-|-10d-|-10hari-|-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/25/2019
add comment=mikhmon name="may/25/2019-|-11:59:12-|-AAMDC-|-3000-|-192.168.12.1\
    14-|-8C:BF:A6:4F:C3:55-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/25/2019
add comment=mikhmon name="may/25/2019-|-21:12:03-|-BRGOH-|-5000-|-192.168.12.7\
    7-|-E0:99:71:C7:B6:9F-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/25/2019
add comment=mikhmon name="may/25/2019-|-22:06:07-|-Leli-|-5000-|-192.168.12.93\
    -|-3C:B6:B7:1C:E3:83-|-2d-|-2hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/25/2019
add comment=mikhmon name="may/26/2019-|-01:19:38-|-BGNDH-|-5000-|-192.168.12.8\
    -|-54:A0:50:C5:3F:B1-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/26/2019
add comment=mikhmon name="may/26/2019-|-07:35:20-|-BNYGU-|-5000-|-192.168.12.1\
    54-|-1C:87:2C:C2:8E:63-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/26/2019
add comment=mikhmon name="may/26/2019-|-08:14:36-|-CZYIR-|-15000-|-192.168.12.\
    87-|-08:8C:2C:02:A3:A3-|-7d-|-7hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/26/2019
add comment=mikhmon name="may/26/2019-|-10:12:52-|-AIEYT-|-3000-|-192.168.12.2\
    06-|-00:27:15:24:17:D0-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/26/2019
add comment=mikhmon name="may/26/2019-|-11:43:08-|-AMIAN-|-3000-|-192.168.12.1\
    62-|-48:88:CA:BA:37:9B-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/26/2019
add comment=mikhmon name="may/26/2019-|-15:51:42-|-BOPAX-|-5000-|-192.168.12.5\
    7-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/26/2019
add comment=mikhmon name="may/26/2019-|-17:52:10-|-user1-|-5000-|-192.168.12.1\
    03-|-80:AD:16:76:6E:5E-|-2d-|-2hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/26/2019
add comment=mikhmon name="may/26/2019-|-19:49:48-|-BJHGI-|-5000-|-192.168.12.1\
    05-|-2C:57:31:F0:77:09-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/26/2019
add comment=mikhmon name="may/26/2019-|-21:16:19-|-BVASA-|-5000-|-192.168.12.1\
    88-|-CC:2D:83:A7:D7:0D-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/26/2019
add comment=mikhmon name="may/27/2019-|-03:46:14-|-BEEHC-|-5000-|-192.168.12.6\
    0-|-0C:A8:A7:48:10:18-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/27/2019
add comment=mikhmon name="may/27/2019-|-06:51:21-|-BVFZS-|-5000-|-192.168.12.2\
    13-|-24:2E:02:8D:5E:F4-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/27/2019
add comment=mikhmon name="may/27/2019-|-09:53:19-|-BYTGF-|-5000-|-192.168.12.1\
    40-|-4C:49:E3:FF:91:25-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/27/2019
add comment=mikhmon name="may/27/2019-|-10:00:36-|-BXPJB-|-5000-|-192.168.12.1\
    9-|-18:F0:E4:6C:02:34-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/27/2019
add comment=mikhmon name="may/27/2019-|-11:51:26-|-BCWQS-|-5000-|-192.168.12.1\
    7-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/27/2019
add comment=mikhmon name="may/27/2019-|-17:34:31-|-ARTJC-|-3000-|-192.168.12.7\
    0-|-C4:3A:BE:63:5C:44-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/27/2019
add comment=mikhmon name="may/27/2019-|-17:53:57-|-AJHNN-|-3000-|-192.168.12.2\
    23-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/27/2019
add comment=mikhmon name="may/27/2019-|-17:58:24-|-BZFEI-|-5000-|-192.168.12.4\
    6-|-20:5E:F7:E8:78:B2-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/27/2019
add comment=mikhmon name="may/27/2019-|-23:00:43-|-CEDOZ-|-15000-|-192.168.12.\
    77-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-" owner=may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/27/2019
add comment=mikhmon name="may/28/2019-|-10:05:02-|-AWRTX-|-3000-|-192.168.12.6\
    2-|-48:88:CA:BA:37:9B-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/28/2019
add comment=mikhmon name="may/28/2019-|-11:51:59-|-BXYZW-|-5000-|-192.168.12.6\
    7-|-00:27:15:24:17:D0-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/28/2019
add comment=mikhmon name="may/28/2019-|-16:23:31-|-BUCSJ-|-5000-|-192.168.12.5\
    7-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/28/2019
add comment=mikhmon name="may/28/2019-|-21:17:52-|-AWRCV-|-3000-|-192.168.12.1\
    24-|-00:27:15:84:48:CC-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/28/2019
add comment=mikhmon name="may/28/2019-|-21:27:29-|-AMMMV-|-3000-|-192.168.12.1\
    25-|-48:FC:B6:0C:A9:F7-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/28/2019
add comment=mikhmon name="may/28/2019-|-22:23:20-|-BTQEX-|-5000-|-192.168.12.8\
    1-|-20:5E:F7:EC:1B:86-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/28/2019
add comment=mikhmon name="may/29/2019-|-08:12:05-|-BWRXO-|-5000-|-192.168.12.2\
    02-|-C0:87:EB:D8:F1:93-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/29/2019
add comment=mikhmon name="may/29/2019-|-11:20:48-|-ATUID-|-3000-|-192.168.12.5\
    0-|-24:2E:02:8D:5E:F4-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/29/2019
add comment=mikhmon name="may/29/2019-|-12:17:26-|-BODYP-|-5000-|-192.168.12.4\
    7-|-1C:77:F6:49:70:C0-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/29/2019
add comment=mikhmon name="may/29/2019-|-14:55:55-|-BBTWT-|-5000-|-192.168.12.1\
    7-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/29/2019
add comment=mikhmon name="may/29/2019-|-17:37:21-|-BUWPV-|-5000-|-192.168.12.1\
    70-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/29/2019
add comment=mikhmon name="may/29/2019-|-18:16:15-|-ANTDF-|-3000-|-192.168.12.1\
    6-|-0C:98:38:6A:6A:51-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/29/2019
add comment=mikhmon name="may/29/2019-|-20:21:28-|-BTZPF-|-5000-|-192.168.12.4\
    6-|-20:5E:F7:E8:78:B2-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/29/2019
add comment=mikhmon name="may/30/2019-|-10:41:52-|-BSHPF-|-5000-|-192.168.12.6\
    -|-80:AD:16:76:6E:5E-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/30/2019
add comment=mikhmon name="may/30/2019-|-15:45:06-|-BCMWE-|-5000-|-192.168.12.5\
    0-|-24:2E:02:8D:5E:F4-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/30/2019
add comment=mikhmon name="may/30/2019-|-17:48:44-|-BABRC-|-5000-|-192.168.12.7\
    0-|-C4:3A:BE:63:5C:44-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/30/2019
add comment=mikhmon name="may/30/2019-|-20:00:40-|-BVZCP-|-5000-|-192.168.12.5\
    7-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/30/2019
add comment=mikhmon name="may/30/2019-|-22:30:15-|-ACEFD-|-3000-|-192.168.12.8\
    1-|-20:5E:F7:EC:1B:86-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/30/2019
add comment=mikhmon name="may/31/2019-|-03:51:20-|-BMZZW-|-5000-|-192.168.12.7\
    7-|-E0:99:71:C7:B6:9F-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/31/2019
add comment=mikhmon name="may/31/2019-|-18:08:38-|-BYJXT-|-5000-|-192.168.12.4\
    6-|-20:5E:F7:E8:78:B2-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/31/2019
add comment=mikhmon name="may/31/2019-|-19:47:14-|-BFVVP-|-5000-|-192.168.12.1\
    70-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=\
    may2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    may/31/2019
add comment=mikhmon name="may/31/2019-|-20:57:02-|-BIPUZ-|-5000-|-192.168.12.1\
    7-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/31/2019
add comment=mikhmon name="may/31/2019-|-21:26:03-|-BKTCP-|-5000-|-192.168.12.5\
    9-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-463-03.10.19-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/31/2019
add comment=mikhmon name="may/31/2019-|-21:36:49-|-CIAQX-|-15000-|-192.168.12.\
    28-|-C0:87:EB:D5:D4:69-|-7d-|-7hari-|-up-562-12.02.18-" owner=may2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=may/31/2019
add comment=mikhmon name="jun/01/2019-|-08:45:43-|-BCBWB-|-5000-|-192.168.12.9\
    3-|-4C:49:E3:FF:91:25-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/01/2019
add comment=mikhmon name="jun/01/2019-|-11:22:06-|-BAHDE-|-5000-|-192.168.12.6\
    -|-80:AD:16:76:6E:5E-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/01/2019
add comment=mikhmon name="jun/01/2019-|-13:20:27-|-BPTWJ-|-5000-|-192.168.12.1\
    3-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/01/2019
add comment=mikhmon name="jun/01/2019-|-14:26:09-|-CIBHY-|-15000-|-192.168.12.\
    7-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-562-12.02.18-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/01/2019
add comment=mikhmon name="jun/01/2019-|-18:10:33-|-BTCDZ-|-5000-|-192.168.12.4\
    8-|-1C:87:2C:C2:8E:63-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/01/2019
add comment=mikhmon name="jun/01/2019-|-18:44:47-|-BXAVZ-|-5000-|-192.168.12.5\
    1-|-20:F7:7C:37:91:13-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/01/2019
add comment=mikhmon name="jun/01/2019-|-18:47:02-|-AIGZI-|-3000-|-192.168.12.1\
    5-|-0C:98:38:6A:6A:51-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/01/2019
add comment=mikhmon name="jun/01/2019-|-21:15:24-|-AKNRT-|-3000-|-192.168.12.8\
    3-|-20:5E:F7:EC:1B:86-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/01/2019
add comment=mikhmon name="jun/01/2019-|-22:11:26-|-BPTOH-|-5000-|-192.168.12.8\
    1-|-C4:3A:BE:63:5C:44-|-2d-|-2hari-|-up-463-03.10.19-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/01/2019
add comment=mikhmon name="jun/02/2019-|-08:15:58-|-BUABD-|-5000-|-192.168.12.1\
    24-|-18:F0:E4:6C:02:34-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/02/2019
add comment=mikhmon name="jun/02/2019-|-10:38:11-|-BSIKN-|-5000-|-192.168.12.9\
    -|-88:D5:0C:08:6B:3C-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/02/2019
add comment=mikhmon name="jun/02/2019-|-20:05:45-|-BNIPT-|-5000-|-192.168.12.5\
    9-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-463-03.10.19-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/02/2019
add comment=mikhmon name="jun/02/2019-|-21:50:51-|-AVRAP-|-3000-|-192.168.12.8\
    3-|-20:5E:F7:EC:1B:86-|-1d-|-1hari-|-up-419-05.18.19-18Mei" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/02/2019
add comment=mikhmon name="jun/03/2019-|-11:26:53-|-BNUHZ-|-5000-|-192.168.12.3\
    8-|-0C:A8:A7:48:10:18-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/03/2019
add comment=mikhmon name="jun/03/2019-|-11:28:35-|-BFWIB-|-5000-|-192.168.12.1\
    23-|-24:2E:02:8D:5E:F4-|-2d-|-2hari-|-up-463-03.10.19-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/03/2019
add comment=mikhmon name="jun/03/2019-|-13:20:23-|-BRLUY-|-5000-|-192.168.12.6\
    -|-80:AD:16:76:6E:5E-|-2d-|-2hari-|-up-463-03.10.19-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/03/2019
add comment=mikhmon name="jun/03/2019-|-16:25:56-|-BDYXG-|-5000-|-192.168.12.1\
    3-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-463-03.10.19-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/03/2019
add comment=mikhmon name="jun/03/2019-|-17:14:45-|-BMIEF-|-5000-|-192.168.12.1\
    70-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-267-05.15.19-15Mei" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/03/2019
add comment=mikhmon name="jun/03/2019-|-20:37:30-|-BCOGH-|-5000-|-192.168.12.1\
    01-|-C0:87:EB:D8:F1:93-|-2d-|-2hari-|-up-463-03.10.19-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/03/2019
add comment=mikhmon name="jun/03/2019-|-21:21:39-|-CQNVL-|-15000-|-192.168.12.\
    31-|-08:8C:2C:02:A3:A3-|-7d-|-7hari-|-up-562-12.02.18-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/03/2019
add comment=mikhmon name="jun/03/2019-|-22:52:21-|-AZJZO-|-3000-|-192.168.12.8\
    3-|-20:5E:F7:EC:1B:86-|-1d-|-1hari-|-up-628-04.07.19-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/03/2019
add comment=mikhmon name="jun/03/2019-|-23:28:23-|-ATLYA-|-5000-|-192.168.12.8\
    1-|-C4:3A:BE:63:5C:44-|-2d-|-2hari-|-up-628-04.07.19-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/03/2019
add comment=mikhmon name="jun/04/2019-|-16:18:44-|-AVEFW-|-3000-|-192.168.12.8\
    2-|-CC:2D:83:90:04:D7-|-1d-|-1hari-|-up-" owner=jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/04/2019
add comment=mikhmon name="jun/04/2019-|-19:13:57-|-AUCRW-|-3000-|-192.168.12.8\
    0-|-0C:98:38:7D:20:DB-|-1d-|-1hari-|-up-628-04.07.19-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/04/2019
add comment=mikhmon name="jun/04/2019-|-19:59:33-|-AKMZE-|-3000-|-192.168.12.1\
    10-|-08:7F:98:E1:84:ED-|-1d-|-1hari-|-up-628-04.07.19-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/04/2019
add comment=mikhmon name="jun/04/2019-|-20:36:30-|-AQJDF-|-3000-|-192.168.12.1\
    18-|-00:27:15:84:48:CC-|-1d-|-1hari-|-up-628-04.07.19-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/04/2019
add comment=mikhmon name="jun/04/2019-|-20:54:40-|-ALDQZ-|-3000-|-192.168.12.8\
    6-|-48:FC:B6:0C:A9:F7-|-1d-|-1hari-|-up-628-04.07.19-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/04/2019
add comment=mikhmon name="jun/05/2019-|-05:37:02-|-AUQKM-|-3000-|-192.168.12.1\
    32-|-00:27:15:03:31:9B-|-1d-|-1hari-|-up-628-04.07.19-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/05/2019
add comment=mikhmon name="jun/05/2019-|-16:59:47-|-ATAAC-|-5000-|-192.168.12.1\
    85-|-B4:C0:F5:07:F8:7B-|-2d-|-2hari-|-up-628-04.07.19-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/05/2019
add comment=mikhmon name="jun/05/2019-|-23:03:07-|-ACYGM-|-5000-|-192.168.12.1\
    01-|-C0:87:EB:D8:F1:93-|-2d-|-2hari-|-up-628-04.07.19-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/05/2019
add comment=mikhmon name="jun/07/2019-|-19:27:21-|-AYKBX-|-3000-|-192.168.12.1\
    68-|-0C:98:38:6A:6A:51-|-1d-|-1hari-|-up-628-04.07.19-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/07/2019
add comment=mikhmon name="jun/08/2019-|-07:44:53-|-AZSHC-|-3000-|-192.168.12.1\
    68-|-0C:98:38:6A:6A:51-|-1d-|-1hari-|-up-628-04.07.19-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/08/2019
add comment=mikhmon name="jun/08/2019-|-07:44:56-|-AMFID-|-3000-|-192.168.12.2\
    13-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-" owner=jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/08/2019
add comment=mikhmon name="jun/08/2019-|-09:55:13-|-CUUCL-|-15000-|-192.168.12.\
    81-|-C4:3A:BE:63:5C:44-|-7d-|-7hari-|-up-562-12.02.18-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/08/2019
add comment=mikhmon name="jun/08/2019-|-11:15:27-|-AJVDX-|-3000-|-192.168.12.2\
    38-|-CC:2D:83:82:6F:1E-|-1d-|-1hari-|-up-628-04.07.19-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/08/2019
add comment=mikhmon name="jun/08/2019-|-11:52:00-|-AXDVC-|-3000-|-192.168.12.1\
    97-|-30:A8:DB:CB:AE:AB-|-1d-|-1hari-|-up-628-04.07.19-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/08/2019
add comment=mikhmon name="jun/08/2019-|-11:56:57-|-ALUXK-|-3000-|-192.168.12.4\
    2-|-24:2E:02:8D:5E:F4-|-1d-|-1hari-|-up-628-04.07.19-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/08/2019
add comment=mikhmon name="jun/08/2019-|-14:35:20-|-CMFPA-|-15000-|-192.168.12.\
    9-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-562-12.02.18-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/08/2019
add comment=mikhmon name="jun/08/2019-|-16:25:48-|-ARXQW-|-5000-|-192.168.12.1\
    70-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-628-04.07.19-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/08/2019
add comment=mikhmon name="jun/08/2019-|-17:53:44-|-BSKBP-|-5000-|-192.168.12.6\
    -|-80:AD:16:76:6E:5E-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/08/2019
add comment=mikhmon name="jun/08/2019-|-19:11:33-|-BHZEW-|-5000-|-192.168.12.1\
    7-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/08/2019
add comment=mikhmon name="jun/08/2019-|-19:28:41-|-BJHZA-|-5000-|-192.168.12.1\
    28-|-E0:99:71:C7:B6:9F-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/08/2019
add comment=mikhmon name="jun/08/2019-|-21:02:59-|-BCBGP-|-5000-|-192.168.12.2\
    8-|-C0:87:EB:D5:D4:69-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/08/2019
add comment=mikhmon name="jun/09/2019-|-08:06:17-|-CWDSP-|-15000-|-192.168.12.\
    120-|-C0:87:EB:EE:62:DB-|-7d-|-7hari-|-up-562-12.02.18-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/09/2019
add comment=mikhmon name="jun/09/2019-|-12:39:06-|-BNTKC-|-5000-|-192.168.12.1\
    03-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/09/2019
add comment=mikhmon name="jun/09/2019-|-12:42:54-|-BGIZX-|-5000-|-192.168.12.8\
    7-|-0C:98:38:6A:6A:51-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/09/2019
add comment=mikhmon name="jun/09/2019-|-17:10:55-|-ADHIZ-|-3000-|-192.168.12.4\
    2-|-24:2E:02:8D:5E:F4-|-1d-|-1hari-|-up-" owner=jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/09/2019
add comment=mikhmon name="jun/09/2019-|-18:08:32-|-BPGHB-|-5000-|-192.168.12.1\
    45-|-80:AD:16:75:AC:62-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/09/2019
add comment=mikhmon name="jun/10/2019-|-08:33:56-|-ARIPT-|-3000-|-192.168.12.7\
    5-|-10:92:66:74:CA:EF-|-1d-|-1hari-|-up-" owner=jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/10/2019
add comment=mikhmon name="jun/10/2019-|-11:09:43-|-BYIKA-|-5000-|-192.168.12.1\
    97-|-30:A8:DB:CB:AE:AB-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/10/2019
add comment=mikhmon name="jun/10/2019-|-17:58:01-|-BDMXY-|-5000-|-192.168.12.6\
    -|-80:AD:16:76:6E:5E-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/10/2019
add comment=mikhmon name="jun/10/2019-|-18:30:33-|-BFWDP-|-5000-|-192.168.12.2\
    7-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/10/2019
add comment=mikhmon name="jun/10/2019-|-18:57:57-|-BAHDH-|-5000-|-192.168.12.2\
    51-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/10/2019
add comment=mikhmon name="jun/10/2019-|-22:11:16-|-CNQYH-|-15000-|-192.168.12.\
    128-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-562-12.02.18-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/10/2019
add comment=mikhmon name="jun/11/2019-|-09:00:50-|-BEHKA-|-5000-|-192.168.12.3\
    7-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/11/2019
add comment=mikhmon name="jun/11/2019-|-11:16:27-|-APEMW-|-3000-|-192.168.12.1\
    23-|-20:5E:F7:30:5E:78-|-1d-|-1hari-|-up-" owner=jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/11/2019
add comment=mikhmon name="jun/11/2019-|-12:56:34-|-AZVMT-|-3000-|-192.168.12.7\
    6-|-24:92:0E:48:57:36-|-1d-|-1hari-|-up-628-04.07.19-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/11/2019
add comment=mikhmon name="jun/11/2019-|-16:51:10-|-AFLVP-|-3000-|-192.168.12.1\
    01-|-0C:98:38:6A:6A:51-|-1d-|-1hari-|-up-" owner=jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/11/2019
add comment=mikhmon name="jun/11/2019-|-17:41:09-|-BIIYV-|-5000-|-192.168.12.2\
    0-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/11/2019
add comment=mikhmon name="jun/11/2019-|-17:59:27-|-BHHAJ-|-5000-|-192.168.12.1\
    70-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/11/2019
add comment=mikhmon name="jun/11/2019-|-18:19:19-|-BHABX-|-5000-|-192.168.12.1\
    12-|-74:29:AF:37:D8:01-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/11/2019
add comment=mikhmon name="jun/11/2019-|-19:56:28-|-BEBNY-|-5000-|-192.168.12.1\
    09-|-88:D5:0C:08:6B:3C-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/11/2019
add comment=mikhmon name="jun/11/2019-|-20:08:00-|-BPUJP-|-5000-|-192.168.12.9\
    2-|-C0:87:EB:35:15:4B-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/11/2019
add comment=mikhmon name="jun/12/2019-|-07:43:15-|-AJEIM-|-3000-|-192.168.12.7\
    5-|-10:92:66:74:CA:EF-|-1d-|-1hari-|-up-628-04.07.19-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/12/2019
add comment=mikhmon name="jun/12/2019-|-11:41:18-|-CNBKE-|-15000-|-192.168.12.\
    197-|-30:A8:DB:CB:AE:AB-|-7d-|-7hari-|-up-562-12.02.18-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/12/2019
add comment=mikhmon name="jun/12/2019-|-14:32:58-|-BRHWY-|-5000-|-192.168.12.1\
    04-|-24:2E:02:8D:5E:F4-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/12/2019
add comment=mikhmon name="jun/12/2019-|-15:26:20-|-BXAHC-|-5000-|-192.168.12.1\
    23-|-20:5E:F7:30:5E:78-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/12/2019
add comment=mikhmon name="jun/12/2019-|-17:44:34-|-AEXCY-|-3000-|-192.168.12.1\
    01-|-0C:98:38:6A:6A:51-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/12/2019
add comment=mikhmon name="jun/12/2019-|-18:41:06-|-BMFNV-|-5000-|-192.168.12.2\
    1-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/12/2019
add comment=mikhmon name="jun/12/2019-|-19:06:12-|-BKDXR-|-5000-|-192.168.12.2\
    51-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/12/2019
add comment=mikhmon name="jun/12/2019-|-20:18:55-|-AXDZX-|-3000-|-192.168.12.6\
    -|-80:AD:16:76:6E:5E-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/12/2019
add comment=mikhmon name="jun/12/2019-|-22:37:24-|-BAJYF-|-5000-|-192.168.12.2\
    11-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/12/2019
add comment=mikhmon name="jun/13/2019-|-00:40:08-|-AGIXR-|-3000-|-192.168.12.1\
    5-|-38:A4:ED:A1:2E:37-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/13/2019
add comment=mikhmon name="jun/13/2019-|-07:35:51-|-CKZQZ-|-15000-|-192.168.12.\
    39-|-2C:57:31:F0:77:09-|-7d-|-7hari-|-up-562-12.02.18-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/13/2019
add comment=mikhmon name="jun/13/2019-|-17:40:18-|-BVUPG-|-5000-|-192.168.12.9\
    0-|-18:F0:E4:6C:02:34-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/13/2019
add comment=mikhmon name="jun/13/2019-|-18:55:13-|-BJCYA-|-5000-|-192.168.12.2\
    8-|-C0:87:EB:D5:D4:69-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/13/2019
add comment=mikhmon name="jun/13/2019-|-18:58:52-|-BSSCC-|-5000-|-192.168.12.7\
    7-|-20:5E:F7:E8:78:B2-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/13/2019
add comment=mikhmon name="jun/13/2019-|-19:28:25-|-BTJNC-|-5000-|-192.168.12.2\
    10-|-0C:98:38:6A:6A:51-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/13/2019
add comment=mikhmon name="jun/13/2019-|-22:36:09-|-ACUDU-|-3000-|-192.168.12.1\
    26-|-0C:98:38:7D:20:DB-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/13/2019
add comment=mikhmon name="jun/13/2019-|-22:40:49-|-BVYNU-|-5000-|-192.168.12.1\
    05-|-C0:87:EB:D8:F1:93-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/13/2019
add comment=mikhmon name="jun/14/2019-|-00:17:49-|-AUTVM-|-3000-|-192.168.12.1\
    5-|-38:A4:ED:A1:2E:37-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/14/2019
add comment=mikhmon name="jun/14/2019-|-10:37:39-|-BARGP-|-5000-|-192.168.12.6\
    -|-80:AD:16:76:6E:5E-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/14/2019
add comment=mikhmon name="jun/14/2019-|-12:08:07-|-BUWDJ-|-5000-|-192.168.12.1\
    70-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/14/2019
add comment=mikhmon name="jun/14/2019-|-20:40:37-|-BGCVE-|-5000-|-192.168.12.2\
    0-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/14/2019
add comment=mikhmon name="jun/14/2019-|-23:11:17-|-BRCJH-|-5000-|-192.168.12.2\
    11-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/14/2019
add comment=mikhmon name="jun/15/2019-|-00:21:18-|-BUXBF-|-5000-|-192.168.12.1\
    5-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/15/2019
add comment=mikhmon name="jun/15/2019-|-08:46:00-|-AXYAE-|-3000-|-192.168.12.9\
    0-|-18:F0:E4:6C:02:34-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/15/2019
add comment=mikhmon name="jun/15/2019-|-10:29:13-|-BDPAX-|-5000-|-192.168.12.1\
    27-|-28:83:35:94:FE:E2-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/15/2019
add comment=mikhmon name="jun/15/2019-|-22:58:27-|-BBSBV-|-5000-|-192.168.12.1\
    05-|-C0:87:EB:D8:F1:93-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/15/2019
add comment=mikhmon name="jun/16/2019-|-07:18:39-|-BEBHP-|-5000-|-192.168.12.2\
    1-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/16/2019
add comment=mikhmon name="jun/16/2019-|-07:21:28-|-BFFHG-|-5000-|-192.168.12.2\
    51-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/16/2019
add comment=mikhmon name="jun/16/2019-|-07:22:11-|-BXJMY-|-5000-|-192.168.12.2\
    36-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/16/2019
add comment=mikhmon name="jun/16/2019-|-09:57:04-|-ANIWR-|-3000-|-192.168.12.1\
    55-|-24:2E:02:8D:5E:F4-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/16/2019
add comment=mikhmon name="jun/16/2019-|-10:26:57-|-BWWVF-|-5000-|-192.168.12.1\
    03-|-20:5E:F7:EC:1B:86-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/16/2019
add comment=mikhmon name="jun/16/2019-|-12:13:12-|-BRDMK-|-5000-|-192.168.12.9\
    0-|-18:F0:E4:6C:02:34-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/16/2019
add comment=mikhmon name="jun/16/2019-|-12:38:33-|-AZVSG-|-3000-|-192.168.12.1\
    16-|-2C:56:DC:E7:15:E1-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/16/2019
add comment=mikhmon name="jun/16/2019-|-12:48:12-|-BYRXD-|-5000-|-192.168.12.1\
    31-|-1C:77:F6:4E:FF:D4-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/16/2019
add comment=mikhmon name="jun/16/2019-|-14:49:10-|-BBCKX-|-5000-|-192.168.12.2\
    8-|-C0:87:EB:D5:D4:69-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/16/2019
add comment=mikhmon name="jun/16/2019-|-17:06:21-|-BAMHN-|-5000-|-192.168.12.1\
    70-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/16/2019
add comment=mikhmon name="jun/16/2019-|-17:52:24-|-CEWBK-|-15000-|-192.168.12.\
    120-|-C0:87:EB:EE:62:DB-|-7d-|-7hari-|-up-562-12.02.18-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/16/2019
add comment=mikhmon name="jun/16/2019-|-20:02:05-|-ASTHR-|-3000-|-192.168.12.2\
    10-|-0C:98:38:6A:6A:51-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/16/2019
add comment=mikhmon name="jun/16/2019-|-20:48:50-|-BPFUE-|-5000-|-192.168.12.2\
    0-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/16/2019
add comment=mikhmon name="jun/16/2019-|-23:17:13-|-BAFYF-|-5000-|-192.168.12.2\
    11-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/16/2019
add comment=mikhmon name="jun/17/2019-|-00:23:55-|-BMCPE-|-5000-|-192.168.12.1\
    5-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/17/2019
add comment=mikhmon name="jun/17/2019-|-05:52:15-|-CYHTB-|-15000-|-192.168.12.\
    128-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-562-12.02.18-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/17/2019
add comment=mikhmon name="jun/17/2019-|-08:21:01-|-BZMNG-|-5000-|-192.168.12.1\
    48-|-C4:3A:BE:63:5C:44-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/17/2019
add comment=mikhmon name="jun/17/2019-|-10:39:45-|-AIBTA-|-3000-|-192.168.12.6\
    -|-80:AD:16:76:6E:5E-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/17/2019
add comment=mikhmon name="jun/17/2019-|-16:27:43-|-BHCWA-|-5000-|-192.168.12.1\
    15-|-3C:95:09:E7:6D:13-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/17/2019
add comment=mikhmon name="jun/17/2019-|-16:32:44-|-CTOJK-|-15000-|-192.168.12.\
    32-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-562-12.02.18-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/17/2019
add comment=mikhmon name="jun/17/2019-|-18:52:20-|-BCTWA-|-5000-|-192.168.12.1\
    65-|-0C:A8:A7:B4:5E:7E-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/17/2019
add comment=mikhmon name="jun/17/2019-|-21:00:43-|-BVBGM-|-5000-|-192.168.12.2\
    10-|-0C:98:38:6A:6A:51-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/17/2019
add comment=mikhmon name="jun/18/2019-|-00:31:34-|-AXITU-|-3000-|-192.168.12.2\
    28-|-20:5E:F7:C2:C5:A2-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/18/2019
add comment=mikhmon name="jun/18/2019-|-06:25:22-|-BEAWH-|-5000-|-192.168.12.9\
    -|-C0:87:EB:D8:F1:93-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/18/2019
add comment=mikhmon name="jun/18/2019-|-07:05:35-|-BKSHN-|-5000-|-192.168.12.9\
    0-|-18:F0:E4:6C:02:34-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/18/2019
add comment=mikhmon name="jun/18/2019-|-10:06:05-|-BMJUA-|-5000-|-192.168.12.4\
    9-|-1C:87:2C:C2:8E:63-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/18/2019
add comment=mikhmon name="jun/18/2019-|-14:20:35-|-AISAK-|-3000-|-192.168.12.7\
    2-|-24:2E:02:8D:5E:F4-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/18/2019
add comment=mikhmon name="jun/18/2019-|-18:28:03-|-CQVES-|-15000-|-192.168.12.\
    6-|-80:AD:16:76:6E:5E-|-7d-|-7hari-|-up-562-12.02.18-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/18/2019
add comment=mikhmon name="jun/18/2019-|-18:54:04-|-AGXBG-|-3000-|-192.168.12.2\
    51-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/18/2019
add comment=mikhmon name="jun/18/2019-|-19:17:10-|-BKNEE-|-5000-|-192.168.12.2\
    2-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/18/2019
add comment=mikhmon name="jun/18/2019-|-20:46:52-|-BMVZJ-|-5000-|-192.168.12.1\
    23-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/18/2019
add comment=mikhmon name="jun/19/2019-|-10:01:28-|-ATDCT-|-3000-|-192.168.12.1\
    70-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/19/2019
add comment=mikhmon name="jun/19/2019-|-11:20:59-|-ADFAY-|-3000-|-192.168.12.1\
    5-|-38:A4:ED:A1:2E:37-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/19/2019
add comment=mikhmon name="jun/19/2019-|-13:22:02-|-BXTUV-|-5000-|-192.168.12.6\
    -|-80:AD:16:76:6E:5E-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/19/2019
add comment=mikhmon name="jun/19/2019-|-19:08:36-|-BCBFV-|-5000-|-192.168.12.2\
    51-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/19/2019
add comment=mikhmon name="jun/19/2019-|-20:08:24-|-BCBHZ-|-5000-|-192.168.12.1\
    2-|-0C:A8:A7:B4:5E:7E-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/19/2019
add comment=mikhmon name="jun/19/2019-|-23:01:36-|-BKMFA-|-5000-|-192.168.12.1\
    48-|-C4:3A:BE:63:5C:44-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/19/2019
add comment=mikhmon name="jun/20/2019-|-04:50:50-|-BHTXN-|-5000-|-192.168.12.1\
    8-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/20/2019
add comment=mikhmon name="jun/20/2019-|-09:00:54-|-BDSKF-|-5000-|-192.168.12.1\
    70-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/20/2019
add comment=mikhmon name="jun/20/2019-|-16:46:44-|-BEFEH-|-5000-|-192.168.12.3\
    8-|-0C:A8:A7:48:10:18-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/20/2019
add comment=mikhmon name="jun/20/2019-|-19:09:54-|-AGFBJ-|-3000-|-192.168.12.9\
    0-|-18:F0:E4:6C:02:34-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/20/2019
add comment=mikhmon name="jun/20/2019-|-19:49:26-|-CDFRO-|-15000-|-192.168.12.\
    12-|-0C:A8:A7:B4:5E:7E-|-7d-|-7hari-|-up-562-12.02.18-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/20/2019
add comment=mikhmon name="jun/21/2019-|-09:44:11-|-CANFB-|-15000-|-192.168.12.\
    6-|-80:AD:16:76:6E:5E-|-7d-|-7hari-|-up-562-12.02.18-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/21/2019
add comment=mikhmon name="jun/21/2019-|-09:59:42-|-AJBDK-|-3000-|-192.168.12.1\
    5-|-38:A4:ED:A1:2E:37-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/21/2019
add comment=mikhmon name="jun/21/2019-|-11:43:50-|-AHCZJ-|-3000-|-192.168.12.4\
    6-|-34:E9:11:0E:B9:B1-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/21/2019
add comment=mikhmon name="jun/21/2019-|-12:18:53-|-AYYCY-|-3000-|-192.168.12.2\
    12-|-1C:87:2C:C2:8E:63-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/21/2019
add comment=mikhmon name="jun/21/2019-|-13:11:51-|-BUNZX-|-5000-|-192.168.12.9\
    0-|-18:F0:E4:6C:02:34-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/21/2019
add comment=mikhmon name="jun/21/2019-|-13:37:06-|-AZPVV-|-3000-|-192.168.12.5\
    8-|-08:7F:98:D0:15:6B-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/21/2019
add comment=mikhmon name="jun/21/2019-|-14:10:03-|-BGJYW-|-5000-|-192.168.12.1\
    23-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/21/2019
add comment=mikhmon name="jun/21/2019-|-14:21:11-|-BDDMA-|-5000-|-192.168.12.2\
    34-|-0A:0B:E1:EE:0F:CC-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/21/2019
add comment=mikhmon name="jun/21/2019-|-16:49:58-|-BXZHS-|-5000-|-192.168.12.6\
    6-|-00:0A:00:DD:51:88-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/21/2019
add comment=mikhmon name="jun/21/2019-|-16:50:49-|-BMGZX-|-5000-|-192.168.12.2\
    8-|-C0:87:EB:D5:D4:69-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/21/2019
add comment=mikhmon name="jun/21/2019-|-17:08:18-|-BGIBY-|-5000-|-192.168.12.6\
    7-|-20:5E:F7:E8:78:B2-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/21/2019
add comment=mikhmon name="jun/21/2019-|-18:55:47-|-BAWBF-|-5000-|-192.168.12.2\
    41-|-C0:87:EB:6F:7F:B7-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/21/2019
add comment=mikhmon name="jun/21/2019-|-19:22:29-|-BFYXV-|-5000-|-192.168.12.2\
    2-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/21/2019
add comment=mikhmon name="jun/22/2019-|-07:21:10-|-BCEGN-|-5000-|-192.168.12.1\
    48-|-C4:3A:BE:63:5C:44-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/22/2019
add comment=mikhmon name="jun/22/2019-|-09:48:46-|-AUJBR-|-3000-|-192.168.12.1\
    70-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/22/2019
add comment=mikhmon name="jun/22/2019-|-10:35:54-|-BSJJR-|-5000-|-192.168.12.1\
    8-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/22/2019
add comment=mikhmon name="jun/22/2019-|-12:00:06-|-BXEKZ-|-5000-|-192.168.12.2\
    51-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/22/2019
add comment=mikhmon name="jun/22/2019-|-12:18:28-|-BVFJX-|-5000-|-192.168.12.1\
    36-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/22/2019
add comment=mikhmon name="jun/22/2019-|-19:03:44-|-BJRXM-|-5000-|-192.168.12.1\
    63-|-B4:C0:F5:07:F8:7B-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/22/2019
add comment=mikhmon name="jun/22/2019-|-20:12:40-|-BXWYU-|-5000-|-192.168.12.1\
    27-|-28:83:35:94:FE:E2-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/22/2019
add comment=mikhmon name="jun/22/2019-|-20:41:04-|-BZXGC-|-5000-|-192.168.12.1\
    92-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/22/2019
add comment=mikhmon name="jun/23/2019-|-09:24:05-|-CJUTY-|-15000-|-192.168.12.\
    32-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-562-12.02.18-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/23/2019
add comment=mikhmon name="jun/23/2019-|-10:33:56-|-AJSIX-|-3000-|-192.168.12.1\
    37-|-0C:A8:A7:48:10:18-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/23/2019
add comment=mikhmon name="jun/23/2019-|-11:27:13-|-AYCKR-|-3000-|-192.168.12.1\
    88-|-0C:98:38:6A:6A:51-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/23/2019
add comment=mikhmon name="jun/23/2019-|-13:18:55-|-BTDJR-|-5000-|-192.168.12.4\
    0-|-7C:46:85:7A:1C:BF-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/23/2019
add comment=mikhmon name="jun/23/2019-|-17:43:45-|-BNSXU-|-5000-|-192.168.12.9\
    2-|-C0:87:EB:35:15:4B-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/23/2019
add comment=mikhmon name="jun/23/2019-|-20:05:21-|-BYUUN-|-5000-|-192.168.12.2\
    2-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/23/2019
add comment=mikhmon name="jun/23/2019-|-23:01:36-|-BWJSK-|-5000-|-192.168.12.9\
    6-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/23/2019
add comment=mikhmon name="jun/23/2019-|-23:13:54-|-BWVVF-|-5000-|-192.168.12.9\
    7-|-34:31:11:F9:B8:12-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/23/2019
add comment=mikhmon name="jun/23/2019-|-23:27:40-|-BYGVJ-|-5000-|-192.168.12.9\
    9-|-88:5A:06:66:12:E5-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/23/2019
add comment=mikhmon name="jun/24/2019-|-00:33:04-|-BRVMC-|-5000-|-192.168.12.1\
    5-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/24/2019
add comment=mikhmon name="jun/24/2019-|-07:31:21-|-AZMXZ-|-3000-|-192.168.12.9\
    0-|-18:F0:E4:6C:02:34-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/24/2019
add comment=mikhmon name="jun/24/2019-|-11:39:39-|-AYXHC-|-3000-|-192.168.12.1\
    70-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/24/2019
add comment=mikhmon name="jun/24/2019-|-12:41:17-|-BHHHA-|-5000-|-192.168.12.1\
    85-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/24/2019
add comment=mikhmon name="jun/24/2019-|-18:31:46-|-CLSOS-|-15000-|-192.168.12.\
    77-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-562-12.02.18-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/24/2019
add comment=mikhmon name="jun/24/2019-|-19:26:20-|-APJJI-|-3000-|-192.168.12.1\
    65-|-0C:98:38:6A:6A:51-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/24/2019
add comment=mikhmon name="jun/24/2019-|-20:13:10-|-BTWCY-|-5000-|-192.168.12.1\
    8-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/24/2019
add comment=mikhmon name="jun/25/2019-|-01:28:53-|-BXGXN-|-5000-|-192.168.12.1\
    48-|-C4:3A:BE:63:5C:44-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/25/2019
add comment=mikhmon name="jun/25/2019-|-10:30:00-|-BCBWW-|-5000-|-192.168.12.9\
    0-|-18:F0:E4:6C:02:34-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/25/2019
add comment=mikhmon name="jun/25/2019-|-14:44:55-|-BNWPM-|-5000-|-192.168.12.1\
    70-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/25/2019
add comment=mikhmon name="jun/25/2019-|-16:25:06-|-CNQRF-|-15000-|-192.168.12.\
    88-|-08:8C:2C:02:A3:A3-|-7d-|-7hari-|-up-562-12.02.18-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/25/2019
add comment=mikhmon name="jun/25/2019-|-17:29:12-|-BPXPG-|-5000-|-192.168.12.1\
    3-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/25/2019
add comment=mikhmon name="jun/25/2019-|-19:02:29-|-BPUWX-|-5000-|-192.168.12.5\
    9-|-CC:2D:83:A7:D7:0D-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/25/2019
add comment=mikhmon name="jun/25/2019-|-19:13:53-|-AZBUX-|-3000-|-192.168.12.1\
    13-|-20:5E:F7:EC:1B:86-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/25/2019
add comment=mikhmon name="jun/25/2019-|-19:25:39-|-BSCXK-|-5000-|-192.168.12.1\
    16-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/25/2019
add comment=mikhmon name="jun/25/2019-|-19:50:02-|-ATVFY-|-3000-|-192.168.12.1\
    65-|-0C:98:38:6A:6A:51-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/25/2019
add comment=mikhmon name="jun/25/2019-|-19:53:22-|-BZAWU-|-5000-|-192.168.12.1\
    17-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/25/2019
add comment=mikhmon name="jun/25/2019-|-22:41:15-|-BAZXH-|-5000-|-192.168.12.9\
    6-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/25/2019
add comment=mikhmon name="jun/25/2019-|-22:41:55-|-BPESU-|-5000-|-192.168.12.1\
    38-|-34:E9:11:2A:E1:65-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/25/2019
add comment=mikhmon name="jun/26/2019-|-00:49:21-|-BJVTD-|-5000-|-192.168.12.1\
    39-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/26/2019
add comment=mikhmon name="jun/26/2019-|-08:55:15-|-BAWNH-|-5000-|-192.168.12.6\
    7-|-20:5E:F7:E8:78:B2-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/26/2019
add comment=mikhmon name="jun/26/2019-|-14:59:24-|-ADEAA-|-3000-|-192.168.12.1\
    81-|-0C:A8:A7:48:10:18-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/26/2019
add comment=mikhmon name="jun/26/2019-|-17:11:21-|-BDZBX-|-5000-|-192.168.12.2\
    2-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/26/2019
add comment=mikhmon name="jun/26/2019-|-18:20:13-|-BWPSZ-|-5000-|-192.168.12.2\
    8-|-C0:87:EB:D5:D4:69-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/26/2019
add comment=mikhmon name="jun/26/2019-|-19:01:22-|-BJYZC-|-5000-|-192.168.12.1\
    85-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/26/2019
add comment=mikhmon name="jun/26/2019-|-19:20:03-|-BDBKS-|-5000-|-192.168.12.1\
    65-|-0C:98:38:6A:6A:51-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/26/2019
add comment=mikhmon name="jun/26/2019-|-19:40:00-|-AEWXA-|-3000-|-192.168.12.1\
    94-|-B4:C0:F5:07:F8:7B-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/26/2019
add comment=mikhmon name="jun/26/2019-|-20:16:24-|-BRDDW-|-5000-|-192.168.12.1\
    1-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/26/2019
add comment=mikhmon name="jun/27/2019-|-08:42:59-|-AEKVG-|-3000-|-192.168.12.2\
    23-|-00:0A:00:DD:51:88-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/27/2019
add comment=mikhmon name="jun/27/2019-|-10:03:30-|-ADMBT-|-3000-|-192.168.12.2\
    21-|-1C:7B:21:A5:C5:93-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/27/2019
add comment=mikhmon name="jun/27/2019-|-11:17:30-|-BIGYU-|-5000-|-192.168.12.9\
    0-|-18:F0:E4:6C:02:34-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/27/2019
add comment=mikhmon name="jun/27/2019-|-19:26:05-|-ASENR-|-3000-|-192.168.12.1\
    94-|-B4:C0:F5:07:F8:7B-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/27/2019
add comment=mikhmon name="jun/27/2019-|-21:56:50-|-ATFFP-|-3000-|-192.168.12.1\
    3-|-70:5E:55:A6:F8:99-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/27/2019
add comment=mikhmon name="jun/27/2019-|-22:19:15-|-AZTEB-|-3000-|-192.168.12.1\
    82-|-0C:98:38:10:73:AB-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/27/2019
add comment=mikhmon name="jun/27/2019-|-22:51:35-|-BVEHH-|-5000-|-192.168.12.2\
    08-|-88:5A:06:66:12:E5-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/27/2019
add comment=mikhmon name="jun/27/2019-|-22:53:26-|-BTZFS-|-5000-|-192.168.12.9\
    6-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/27/2019
add comment=mikhmon name="jun/27/2019-|-23:57:04-|-CSKMK-|-15000-|-192.168.12.\
    148-|-C4:3A:BE:63:5C:44-|-7d-|-7hari-|-up-562-12.02.18-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/27/2019
add comment=mikhmon name="jun/28/2019-|-01:34:07-|-BNDWV-|-5000-|-192.168.12.1\
    5-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/28/2019
add comment=mikhmon name="jun/28/2019-|-16:33:15-|-BPCIV-|-5000-|-192.168.12.1\
    17-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/28/2019
add comment=mikhmon name="jun/28/2019-|-18:02:36-|-APVAR-|-3000-|-192.168.12.1\
    70-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/28/2019
add comment=mikhmon name="jun/28/2019-|-19:22:49-|-ASZIC-|-3000-|-192.168.12.1\
    13-|-20:5E:F7:EC:1B:86-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/28/2019
add comment=mikhmon name="jun/28/2019-|-20:23:09-|-BXMYI-|-5000-|-192.168.12.1\
    09-|-0C:98:38:6A:6A:51-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/28/2019
add comment=mikhmon name="jun/29/2019-|-04:50:01-|-BHFAF-|-5000-|-192.168.12.1\
    1-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/29/2019
add comment=mikhmon name="jun/29/2019-|-07:51:13-|-BEZGS-|-5000-|-192.168.12.1\
    81-|-0C:A8:A7:48:10:18-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/29/2019
add comment=mikhmon name="jun/29/2019-|-08:31:23-|-BBGSN-|-5000-|-192.168.12.5\
    7-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/29/2019
add comment=mikhmon name="jun/29/2019-|-08:33:43-|-AKYHF-|-3000-|-192.168.12.1\
    56-|-24:79:F3:6D:00:5D-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/29/2019
add comment=mikhmon name="jun/29/2019-|-09:18:35-|-CHIND-|-15000-|-192.168.12.\
    6-|-80:AD:16:76:6E:5E-|-7d-|-7hari-|-up-562-12.02.18-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/29/2019
add comment=mikhmon name="jun/29/2019-|-11:31:29-|-BCRTG-|-5000-|-192.168.12.9\
    0-|-18:F0:E4:6C:02:34-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/29/2019
add comment=mikhmon name="jun/29/2019-|-12:57:20-|-BNIVG-|-5000-|-192.168.12.1\
    2-|-0C:A8:A7:B4:5E:7E-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/29/2019
add comment=mikhmon name="jun/29/2019-|-14:29:58-|-BPASJ-|-5000-|-192.168.12.2\
    2-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/29/2019
add comment=mikhmon name="jun/29/2019-|-18:16:50-|-BYEGA-|-5000-|-192.168.12.6\
    7-|-20:5E:F7:E8:78:B2-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/29/2019
add comment=mikhmon name="jun/30/2019-|-08:04:19-|-ARFZC-|-5000-|-192.168.12.2\
    38-|-1C:87:2C:C2:8E:63-|-2d-|-2hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/30/2019
add comment=mikhmon name="jun/30/2019-|-09:02:19-|-BDUZT-|-5000-|-192.168.12.1\
    70-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/30/2019
add comment=mikhmon name="jun/30/2019-|-09:25:00-|-ACEKE-|-3000-|-192.168.12.1\
    56-|-24:79:F3:6D:00:5D-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/30/2019
add comment=mikhmon name="jun/30/2019-|-10:33:51-|-BGRTM-|-5000-|-192.168.12.5\
    9-|-CC:2D:83:A7:D7:0D-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/30/2019
add comment=mikhmon name="jun/30/2019-|-13:13:04-|-CSKXW-|-15000-|-192.168.12.\
    29-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-562-12.02.18-" owner=jun2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jun/30/2019
add comment=mikhmon name="jun/30/2019-|-16:15:10-|-ARAVD-|-3000-|-192.168.12.1\
    15-|-3C:95:09:E7:6D:13-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/30/2019
add comment=mikhmon name="jun/30/2019-|-19:25:59-|-BXPPY-|-5000-|-192.168.12.1\
    42-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/30/2019
add comment=mikhmon name="jun/30/2019-|-22:10:41-|-AIZYZ-|-3000-|-192.168.12.1\
    13-|-20:5E:F7:EC:1B:86-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jun2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jun/30/2019
add comment=mikhmon name="jul/01/2019-|-11:25:40-|-BVUUJ-|-5000-|-192.168.12.2\
    37-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/01/2019
add comment=mikhmon name="jul/01/2019-|-11:31:23-|-AVMNI-|-3000-|-192.168.12.1\
    56-|-24:79:F3:6D:00:5D-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/01/2019
add comment=mikhmon name="jul/01/2019-|-12:01:10-|-BUYAT-|-5000-|-192.168.12.9\
    0-|-18:F0:E4:6C:02:34-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/01/2019
add comment=mikhmon name="jul/01/2019-|-13:15:06-|-BHZFU-|-5000-|-192.168.12.1\
    1-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/01/2019
add comment=mikhmon name="jul/01/2019-|-13:18:51-|-BYTJS-|-5000-|-192.168.12.1\
    17-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/01/2019
add comment=mikhmon name="jul/01/2019-|-13:27:59-|-ARYUF-|-3000-|-192.168.12.2\
    07-|-20:5E:F7:90:4B:64-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/01/2019
add comment=mikhmon name="jul/01/2019-|-18:38:58-|-BXDRF-|-5000-|-192.168.12.1\
    94-|-B4:C0:F5:07:F8:7B-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/01/2019
add comment=mikhmon name="jul/01/2019-|-19:07:53-|-BDFFV-|-5000-|-192.168.12.1\
    2-|-0C:A8:A7:B4:5E:7E-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/01/2019
add comment=mikhmon name="jul/01/2019-|-19:09:26-|-BIDHR-|-5000-|-192.168.12.2\
    8-|-C0:87:EB:D5:D4:69-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/01/2019
add comment=mikhmon name="jul/01/2019-|-20:00:55-|-BAFDX-|-5000-|-192.168.12.1\
    09-|-0C:98:38:6A:6A:51-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/01/2019
add comment=mikhmon name="jul/02/2019-|-11:45:11-|-BXGTJ-|-5000-|-192.168.12.1\
    81-|-0C:A8:A7:48:10:18-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/02/2019
add comment=mikhmon name="jul/02/2019-|-12:12:44-|-ABHIP-|-3000-|-192.168.12.1\
    56-|-24:79:F3:6D:00:5D-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/02/2019
add comment=mikhmon name="jul/02/2019-|-15:50:11-|-ASGGJ-|-3000-|-192.168.12.3\
    8-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/02/2019
add comment=mikhmon name="jul/02/2019-|-19:19:21-|-BTENR-|-5000-|-192.168.12.2\
    2-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/02/2019
add comment=mikhmon name="jul/02/2019-|-19:50:54-|-BGPFU-|-5000-|-192.168.12.1\
    11-|-CC:2D:83:A7:D7:0D-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/02/2019
add comment=mikhmon name="jul/02/2019-|-21:18:57-|-BAKHP-|-5000-|-192.168.12.9\
    6-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/02/2019
add comment=mikhmon name="jul/02/2019-|-21:32:06-|-Aziz-|-3000-|-192.168.12.13\
    0-|-68:05:71:EA:EF:29-|-1d-|-1hari-|-up-" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/02/2019
add comment=mikhmon name="jul/02/2019-|-23:36:05-|-BPYPP-|-5000-|-192.168.12.1\
    5-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/02/2019
add comment=mikhmon name="jul/03/2019-|-08:48:02-|-AAPEH-|-3000-|-192.168.12.1\
    54-|-70:0B:C0:61:13:87-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/03/2019
add comment=mikhmon name="jul/03/2019-|-08:51:27-|-AKPMF-|-3000-|-192.168.12.1\
    70-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/03/2019
add comment=mikhmon name="jul/03/2019-|-09:20:26-|-BXGZC-|-5000-|-192.168.12.1\
    42-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/03/2019
add comment=mikhmon name="jul/03/2019-|-12:13:05-|-BBZRV-|-5000-|-192.168.12.1\
    79-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/03/2019
add comment=mikhmon name="jul/03/2019-|-12:38:56-|-ABSDZ-|-3000-|-192.168.12.1\
    56-|-24:79:F3:6D:00:5D-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/03/2019
add comment=mikhmon name="jul/03/2019-|-13:13:02-|-AWMZD-|-3000-|-192.168.12.3\
    8-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/03/2019
add comment=mikhmon name="jul/03/2019-|-15:15:02-|-BUDNH-|-5000-|-192.168.12.9\
    0-|-18:F0:E4:6C:02:34-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/03/2019
add comment=mikhmon name="jul/03/2019-|-19:35:19-|-ATHHD-|-3000-|-192.168.12.1\
    09-|-0C:98:38:6A:6A:51-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/03/2019
add comment=mikhmon name="jul/04/2019-|-09:57:20-|-ACDEM-|-3000-|-192.168.12.1\
    70-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/04/2019
add comment=mikhmon name="jul/04/2019-|-12:50:08-|-ADCWT-|-3000-|-192.168.12.1\
    56-|-24:79:F3:6D:00:5D-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/04/2019
add comment=mikhmon name="jul/04/2019-|-17:57:08-|-BVCAS-|-5000-|-192.168.12.9\
    2-|-C0:87:EB:35:15:4B-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/04/2019
add comment=mikhmon name="jul/04/2019-|-21:09:00-|-AXTGK-|-3000-|-192.168.12.1\
    09-|-0C:98:38:6A:6A:51-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/04/2019
add comment=mikhmon name="jul/04/2019-|-21:12:00-|-AEINN-|-3000-|-192.168.12.1\
    1-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/04/2019
add comment=mikhmon name="jul/05/2019-|-10:16:07-|-AXVVB-|-3000-|-192.168.12.1\
    56-|-24:79:F3:6D:00:5D-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/05/2019
add comment=mikhmon name="jul/05/2019-|-10:20:12-|-BWDVC-|-5000-|-192.168.12.9\
    6-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/05/2019
add comment=mikhmon name="jul/05/2019-|-12:25:47-|-BECMY-|-5000-|-192.168.12.1\
    1-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/05/2019
add comment=mikhmon name="jul/05/2019-|-12:53:12-|-BPBSM-|-5000-|-192.168.12.1\
    70-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/05/2019
add comment=mikhmon name="jul/05/2019-|-15:21:58-|-BZUET-|-5000-|-192.168.12.7\
    7-|-E0:99:71:C7:B6:9F-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/05/2019
add comment=mikhmon name="jul/05/2019-|-16:49:04-|-BCZIU-|-5000-|-192.168.12.1\
    2-|-0C:A8:A7:B4:5E:7E-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/05/2019
add comment=mikhmon name="jul/05/2019-|-16:51:24-|-BDAPJ-|-5000-|-192.168.12.9\
    0-|-18:F0:E4:6C:02:34-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/05/2019
add comment=mikhmon name="jul/05/2019-|-18:23:11-|-CMDUY-|-15000-|-192.168.12.\
    120-|-C0:87:EB:EE:62:DB-|-7d-|-7hari-|-up-513-06.30.19-7hr_30juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/05/2019
add comment=mikhmon name="jul/05/2019-|-19:07:36-|-BZGME-|-5000-|-192.168.12.1\
    48-|-C4:3A:BE:63:5C:44-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/05/2019
add comment=mikhmon name="jul/05/2019-|-19:09:57-|-BKTXB-|-5000-|-192.168.12.8\
    7-|-00:27:15:24:17:D0-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/05/2019
add comment=mikhmon name="jul/05/2019-|-19:47:04-|-BECPT-|-5000-|-192.168.12.1\
    09-|-0C:98:38:6A:6A:51-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/05/2019
add comment=mikhmon name="jul/05/2019-|-22:50:10-|-AGEUM-|-3000-|-192.168.12.2\
    03-|-20:5E:F7:FA:47:BC-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/05/2019
add comment=mikhmon name="jul/05/2019-|-22:58:17-|-ADYAJ-|-3000-|-192.168.12.1\
    72-|-88:5A:06:66:12:E5-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/05/2019
add comment=mikhmon name="jul/05/2019-|-22:59:36-|-BTYVN-|-5000-|-192.168.12.1\
    5-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/05/2019
add comment=mikhmon name="jul/05/2019-|-23:03:47-|-AUNZY-|-3000-|-192.168.12.1\
    76-|-68:05:71:EA:EF:29-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/05/2019
add comment=mikhmon name="jul/05/2019-|-23:37:25-|-BHSNW-|-5000-|-192.168.12.1\
    27-|-28:83:35:94:FE:E2-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/05/2019
add comment=mikhmon name="jul/06/2019-|-01:00:36-|-ASPJG-|-3000-|-192.168.12.1\
    81-|-0C:A8:A7:48:10:18-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/06/2019
add comment=mikhmon name="jul/06/2019-|-19:05:07-|-BNBSR-|-5000-|-192.168.12.3\
    8-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/06/2019
add comment=mikhmon name="jul/06/2019-|-20:02:38-|-BTINY-|-5000-|-192.168.12.9\
    2-|-C0:87:EB:35:15:4B-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/06/2019
add comment=mikhmon name="jul/06/2019-|-20:13:29-|-BMYEJ-|-5000-|-192.168.12.1\
    42-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/06/2019
add comment=mikhmon name="jul/06/2019-|-23:30:42-|-BJVIF-|-5000-|-192.168.12.2\
    2-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/06/2019
add comment=mikhmon name="jul/07/2019-|-10:24:01-|-BCTVU-|-5000-|-192.168.12.9\
    6-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/07/2019
add comment=mikhmon name="jul/07/2019-|-12:35:25-|-BHMFR-|-5000-|-192.168.12.1\
    60-|-0C:98:38:D7:52:FF-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/07/2019
add comment=mikhmon name="jul/07/2019-|-12:38:52-|-BJWBG-|-5000-|-192.168.12.1\
    1-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/07/2019
add comment=mikhmon name="jul/07/2019-|-16:45:46-|-BXXVZ-|-5000-|-192.168.12.2\
    8-|-C0:87:EB:D5:D4:69-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/07/2019
add comment=mikhmon name="jul/07/2019-|-17:20:31-|-CVHLE-|-15000-|-192.168.12.\
    29-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-562-12.02.18-" owner=jul2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jul/07/2019
add comment=mikhmon name="jul/07/2019-|-18:06:10-|-BUTFE-|-5000-|-192.168.12.1\
    2-|-0C:A8:A7:B4:5E:7E-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/07/2019
add comment=mikhmon name="jul/07/2019-|-18:25:04-|-BWDNF-|-5000-|-192.168.12.1\
    70-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/07/2019
add comment=mikhmon name="jul/07/2019-|-18:37:12-|-AUBPR-|-3000-|-192.168.12.2\
    38-|-60:72:8D:62:53:EB-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/07/2019
add comment=mikhmon name="jul/07/2019-|-19:03:30-|-ASMUE-|-3000-|-192.168.12.2\
    34-|-20:5E:F7:EC:1B:86-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/07/2019
add comment=mikhmon name="jul/07/2019-|-19:25:41-|-BKTMT-|-5000-|-192.168.12.8\
    7-|-00:27:15:24:17:D0-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/07/2019
add comment=mikhmon name="jul/07/2019-|-19:53:01-|-CAVXN-|-15000-|-192.168.12.\
    77-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-513-06.30.19-7hr_30juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/07/2019
add comment=mikhmon name="jul/07/2019-|-21:19:43-|-BNDTC-|-5000-|-192.168.12.1\
    48-|-C4:3A:BE:63:5C:44-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/07/2019
add comment=mikhmon name="jul/08/2019-|-05:54:03-|-BSICF-|-5000-|-192.168.12.1\
    09-|-0C:98:38:6A:6A:51-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/08/2019
add comment=mikhmon name="jul/08/2019-|-08:01:55-|-ABURI-|-3000-|-192.168.12.1\
    56-|-24:79:F3:6D:00:5D-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/08/2019
add comment=mikhmon name="jul/08/2019-|-09:33:14-|-BDCVB-|-5000-|-192.168.12.9\
    0-|-18:F0:E4:6C:02:34-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/08/2019
add comment=mikhmon name="jul/08/2019-|-16:21:46-|-APGUW-|-3000-|-192.168.12.1\
    49-|-E0:62:67:3B:CA:60-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/08/2019
add comment=mikhmon name="jul/08/2019-|-18:34:17-|-BGCAK-|-5000-|-192.168.12.6\
    -|-80:AD:16:76:6E:5E-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=jul2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jul/08/2019
add comment=mikhmon name="jul/08/2019-|-18:42:21-|-AWRBN-|-3000-|-192.168.12.2\
    08-|-A4:12:32:F3:3F:AB-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/08/2019
add comment=mikhmon name="jul/08/2019-|-18:45:03-|-AGFBY-|-3000-|-192.168.12.2\
    38-|-60:72:8D:62:53:EB-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/08/2019
add comment=mikhmon name="jul/08/2019-|-19:11:49-|-AGITC-|-3000-|-192.168.12.3\
    8-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/08/2019
add comment=mikhmon name="jul/08/2019-|-19:54:30-|-AYZEF-|-3000-|-192.168.12.2\
    34-|-20:5E:F7:EC:1B:86-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/08/2019
add comment=mikhmon name="jul/08/2019-|-23:33:52-|-BXESB-|-5000-|-192.168.12.1\
    17-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/08/2019
add comment=mikhmon name="jul/09/2019-|-10:32:29-|-BFMRT-|-5000-|-192.168.12.9\
    6-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/09/2019
add comment=mikhmon name="jul/09/2019-|-16:21:16-|-BZHXK-|-5000-|-192.168.12.1\
    81-|-0C:A8:A7:48:10:18-|-2d-|-2hari-|-up-921-06.08.19-B8juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/09/2019
add comment=mikhmon name="jul/09/2019-|-17:10:48-|-BENPZ-|-5000-|-192.168.12.2\
    2-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/09/2019
add comment=mikhmon name="jul/09/2019-|-19:24:48-|-AKBUW-|-3000-|-192.168.12.1\
    1-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/09/2019
add comment=mikhmon name="jul/09/2019-|-19:26:38-|-BTNPV-|-5000-|-192.168.12.3\
    8-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/09/2019
add comment=mikhmon name="jul/10/2019-|-06:17:42-|-BVPZG-|-5000-|-192.168.12.1\
    2-|-0C:A8:A7:B4:5E:7E-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/10/2019
add comment=mikhmon name="jul/10/2019-|-16:56:30-|-AUIFI-|-3000-|-192.168.12.1\
    70-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/10/2019
add comment=mikhmon name="jul/10/2019-|-18:44:57-|-CJXMJ-|-15000-|-192.168.12.\
    6-|-80:AD:16:76:6E:5E-|-7d-|-7hari-|-up-513-06.30.19-7hr_30juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/10/2019
add comment=mikhmon name="jul/10/2019-|-18:55:05-|-ASVAK-|-3000-|-192.168.12.1\
    02-|-F4:60:E2:30:CF:98-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/10/2019
add comment=mikhmon name="jul/10/2019-|-19:02:07-|-BKKRM-|-5000-|-192.168.12.9\
    0-|-18:F0:E4:6C:02:34-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/10/2019
add comment=mikhmon name="jul/10/2019-|-19:27:18-|-BBDFS-|-5000-|-192.168.12.1\
    1-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/10/2019
add comment=mikhmon name="jul/10/2019-|-21:11:13-|-AMKKG-|-3000-|-192.168.12.2\
    34-|-20:5E:F7:EC:1B:86-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/10/2019
add comment=mikhmon name="jul/11/2019-|-06:55:26-|-ACNZT-|-3000-|-192.168.12.1\
    48-|-C4:3A:BE:63:5C:44-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/11/2019
add comment=mikhmon name="jul/11/2019-|-09:08:57-|-AWTDZ-|-3000-|-192.168.12.1\
    49-|-E0:62:67:3B:CA:60-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/11/2019
add comment=mikhmon name="jul/11/2019-|-10:16:11-|-AAEIB-|-3000-|-192.168.12.2\
    53-|-20:5E:F7:EC:E7:56-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/11/2019
add comment=mikhmon name="jul/11/2019-|-10:29:38-|-ASNBZ-|-3000-|-192.168.12.2\
    1-|-24:2E:02:8D:5E:F4-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/11/2019
add comment=mikhmon name="jul/11/2019-|-10:36:19-|-BZYKM-|-5000-|-192.168.12.9\
    6-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/11/2019
add comment=mikhmon name="jul/11/2019-|-14:33:41-|-BTFCR-|-5000-|-192.168.12.2\
    34-|-24:79:F3:52:26:EB-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/11/2019
add comment=mikhmon name="jul/11/2019-|-14:36:57-|-AXVDP-|-3000-|-192.168.12.2\
    33-|-0C:A8:A7:FE:B7:88-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/11/2019
add comment=mikhmon name="jul/11/2019-|-15:10:27-|-BSFTS-|-5000-|-192.168.12.1\
    17-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/11/2019
add comment=mikhmon name="jul/11/2019-|-16:38:23-|-BAPYT-|-5000-|-192.168.12.2\
    8-|-C0:87:EB:D5:D4:69-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/11/2019
add comment=mikhmon name="jul/11/2019-|-16:39:29-|-BTPTM-|-5000-|-192.168.12.6\
    7-|-20:5E:F7:E8:78:B2-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/11/2019
add comment=mikhmon name="jul/12/2019-|-06:40:34-|-BNHGU-|-5000-|-192.168.12.1\
    27-|-28:83:35:94:FE:E2-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/12/2019
add comment=mikhmon name="jul/12/2019-|-07:59:29-|-ATDSE-|-3000-|-192.168.12.3\
    8-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/12/2019
add comment=mikhmon name="jul/12/2019-|-08:11:47-|-BZJAG-|-5000-|-192.168.12.1\
    48-|-C4:3A:BE:63:5C:44-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/12/2019
add comment=mikhmon name="jul/12/2019-|-12:32:15-|-BVSYD-|-5000-|-192.168.12.1\
    81-|-0C:A8:A7:48:10:18-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/12/2019
add comment=mikhmon name="jul/12/2019-|-12:51:14-|-BDMCP-|-5000-|-192.168.12.1\
    2-|-0C:A8:A7:B4:5E:7E-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/12/2019
add comment=mikhmon name="jul/12/2019-|-13:15:34-|-AXDDC-|-3000-|-192.168.12.2\
    38-|-60:72:8D:62:53:EB-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/12/2019
add comment=mikhmon name="jul/12/2019-|-13:24:11-|-BNJDY-|-5000-|-192.168.12.1\
    1-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/12/2019
add comment=mikhmon name="jul/12/2019-|-16:46:24-|-BXASP-|-5000-|-192.168.12.1\
    70-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/12/2019
add comment=mikhmon name="jul/12/2019-|-19:53:38-|-AJICK-|-3000-|-192.168.12.6\
    8-|-20:5E:F7:EC:1B:86-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/12/2019
add comment=mikhmon name="jul/13/2019-|-06:48:00-|-CDJZW-|-15000-|-192.168.12.\
    120-|-C0:87:EB:EE:62:DB-|-7d-|-7hari-|-up-513-06.30.19-7hr_30juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/13/2019
add comment=mikhmon name="jul/13/2019-|-10:09:56-|-AGBRF-|-3000-|-192.168.12.2\
    13-|-24:2E:02:8D:5E:F4-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/13/2019
add comment=mikhmon name="jul/13/2019-|-12:51:58-|-AZEBD-|-3000-|-192.168.12.8\
    1-|-54:27:58:78:10:60-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/13/2019
add comment=mikhmon name="jul/13/2019-|-12:52:43-|-AIKJM-|-3000-|-192.168.12.2\
    27-|-70:5E:55:A6:F9:77-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/13/2019
add comment=mikhmon name="jul/13/2019-|-17:36:24-|-CEICK-|-15000-|-192.168.12.\
    51-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-513-06.30.19-7hr_30juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/13/2019
add comment=mikhmon name="jul/13/2019-|-17:52:06-|-AHHGC-|-3000-|-192.168.12.2\
    38-|-60:72:8D:62:53:EB-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/13/2019
add comment=mikhmon name="jul/13/2019-|-18:05:23-|-AUIGK-|-3000-|-192.168.12.1\
    35-|-10:92:66:74:CA:EF-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/13/2019
add comment=mikhmon name="jul/13/2019-|-19:18:42-|-BHNNZ-|-5000-|-192.168.12.2\
    6-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/13/2019
add comment=mikhmon name="jul/13/2019-|-19:26:27-|-ADIPA-|-3000-|-192.168.12.3\
    8-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/13/2019
add comment=mikhmon name="jul/14/2019-|-01:01:01-|-BCEPD-|-5000-|-192.168.12.9\
    6-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/14/2019
add comment=mikhmon name="jul/14/2019-|-08:46:19-|-ACIFT-|-3000-|-192.168.12.1\
    96-|-00:0A:00:DD:51:88-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/14/2019
add comment=mikhmon name="jul/14/2019-|-14:31:20-|-AMHUR-|-3000-|-192.168.12.2\
    13-|-24:2E:02:8D:5E:F4-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/14/2019
add comment=mikhmon name="jul/14/2019-|-15:26:05-|-AFRXY-|-3000-|-192.168.12.1\
    38-|-1C:99:4C:E4:2D:96-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/14/2019
add comment=mikhmon name="jul/14/2019-|-19:23:22-|-BNTPT-|-5000-|-192.168.12.6\
    2-|-C0:87:EB:D5:D4:69-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/14/2019
add comment=mikhmon name="jul/14/2019-|-19:25:05-|-BTZDB-|-5000-|-192.168.12.4\
    3-|-20:5E:F7:E8:78:B2-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/14/2019
add comment=mikhmon name="jul/14/2019-|-19:31:57-|-AMVYZ-|-3000-|-192.168.12.1\
    1-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/14/2019
add comment=mikhmon name="jul/14/2019-|-19:32:57-|-BWVRM-|-5000-|-192.168.12.9\
    3-|-0C:A8:A7:B4:5E:7E-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/14/2019
add comment=mikhmon name="jul/14/2019-|-20:55:15-|-BFYBW-|-5000-|-192.168.12.1\
    81-|-0C:A8:A7:48:10:18-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/14/2019
add comment=mikhmon name="jul/15/2019-|-05:47:51-|-BNTBY-|-5000-|-192.168.12.1\
    48-|-C4:3A:BE:63:5C:44-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/15/2019
add comment=mikhmon name="jul/15/2019-|-16:08:37-|-AYEZD-|-3000-|-192.168.12.1\
    19-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/15/2019
add comment=mikhmon name="jul/15/2019-|-16:47:06-|-AJXBE-|-3000-|-192.168.12.1\
    35-|-10:92:66:74:CA:EF-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/15/2019
add comment=mikhmon name="jul/15/2019-|-16:56:03-|-ANMFD-|-3000-|-192.168.12.4\
    2-|-CC:2D:83:90:04:D7-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/15/2019
add comment=mikhmon name="jul/15/2019-|-18:02:43-|-AYPZI-|-3000-|-192.168.12.8\
    1-|-54:27:58:78:10:60-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/15/2019
add comment=mikhmon name="jul/15/2019-|-18:07:54-|-AGXWA-|-3000-|-192.168.12.2\
    34-|-24:79:F3:52:26:EB-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/15/2019
add comment=mikhmon name="jul/15/2019-|-21:32:40-|-ATBSJ-|-3000-|-192.168.12.8\
    1-|-54:27:58:78:10:60-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/15/2019
add comment=mikhmon name="jul/15/2019-|-21:39:51-|-AJNCC-|-3000-|-192.168.12.7\
    4-|-1C:87:2C:C2:8E:63-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/15/2019
add comment=mikhmon name="jul/15/2019-|-23:24:45-|-ANBAZ-|-3000-|-192.168.12.1\
    72-|-38:A4:ED:A1:2E:37-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/15/2019
add comment=mikhmon name="jul/16/2019-|-14:03:37-|-AHARS-|-3000-|-192.168.12.3\
    8-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/16/2019
add comment=mikhmon name="jul/16/2019-|-16:18:43-|-AETTR-|-3000-|-192.168.12.2\
    13-|-24:2E:02:8D:5E:F4-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/16/2019
add comment=mikhmon name="jul/16/2019-|-17:53:54-|-ANUSR-|-3000-|-192.168.12.9\
    0-|-18:F0:E4:6C:02:34-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/16/2019
add comment=mikhmon name="jul/16/2019-|-17:57:53-|-ANMDA-|-3000-|-192.168.12.4\
    2-|-CC:2D:83:90:04:D7-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/16/2019
add comment=mikhmon name="jul/16/2019-|-18:02:02-|-AUESK-|-3000-|-192.168.12.1\
    19-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/16/2019
add comment=mikhmon name="jul/16/2019-|-19:58:42-|-CFXZI-|-15000-|-192.168.12.\
    77-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-513-06.30.19-7hr_30juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/16/2019
add comment=mikhmon name="jul/16/2019-|-20:30:39-|-ADKTD-|-3000-|-192.168.12.9\
    3-|-0C:A8:A7:B4:5E:7E-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/16/2019
add comment=mikhmon name="jul/17/2019-|-11:03:08-|-BAVMH-|-5000-|-192.168.12.1\
    35-|-10:92:66:74:CA:EF-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/17/2019
add comment=mikhmon name="jul/17/2019-|-11:28:48-|-AMYRG-|-3000-|-192.168.12.1\
    8-|-E0:62:67:3B:CA:60-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/17/2019
add comment=mikhmon name="jul/17/2019-|-11:36:57-|-ACRMZ-|-3000-|-192.168.12.9\
    3-|-0C:A8:A7:B4:5E:7E-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/17/2019
add comment=mikhmon name="jul/17/2019-|-11:40:40-|-AFNNH-|-3000-|-192.168.12.9\
    0-|-18:F0:E4:6C:02:34-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/17/2019
add comment=mikhmon name="jul/17/2019-|-14:53:02-|-AWJZS-|-3000-|-192.168.12.3\
    8-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/17/2019
add comment=mikhmon name="jul/17/2019-|-17:54:08-|-AMENS-|-3000-|-192.168.12.2\
    6-|-F4:60:E2:30:CF:98-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/17/2019
add comment=mikhmon name="jul/17/2019-|-18:06:24-|-AEDMY-|-3000-|-192.168.12.1\
    19-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/17/2019
add comment=mikhmon name="jul/17/2019-|-18:20:14-|-AYZDJ-|-3000-|-192.168.12.6\
    2-|-C0:87:EB:D5:D4:69-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/17/2019
add comment=mikhmon name="jul/17/2019-|-18:21:36-|-AUGNH-|-3000-|-192.168.12.4\
    3-|-20:5E:F7:E8:78:B2-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/17/2019
add comment=mikhmon name="jul/17/2019-|-21:32:10-|-AXJKD-|-3000-|-192.168.12.2\
    16-|-C4:0B:CB:E3:2B:3C-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/17/2019
add comment=mikhmon name="jul/18/2019-|-06:00:43-|-BGPRB-|-5000-|-192.168.12.1\
    48-|-C4:3A:BE:63:5C:44-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/18/2019
add comment=mikhmon name="jul/18/2019-|-17:50:25-|-CDVYR-|-15000-|-192.168.12.\
    25-|-EC:D0:9F:CB:40:07-|-7d-|-7hari-|-up-513-06.30.19-7hr_30juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/18/2019
add comment=mikhmon name="jul/18/2019-|-17:59:44-|-ADNFG-|-3000-|-192.168.12.2\
    6-|-F4:60:E2:30:CF:98-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/18/2019
add comment=mikhmon name="jul/18/2019-|-18:12:20-|-AAIIR-|-3000-|-192.168.12.1\
    4-|-68:05:71:EA:EF:29-|-1d-|-1hari-|-up-758-07.18.19-" owner=jul2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jul/18/2019
add comment=mikhmon name="jul/18/2019-|-18:39:26-|-AKNPS-|-3000-|-192.168.12.6\
    2-|-C0:87:EB:D5:D4:69-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/18/2019
add comment=mikhmon name="jul/18/2019-|-19:07:17-|-AIXZH-|-3000-|-192.168.12.4\
    3-|-20:5E:F7:E8:78:B2-|-1d-|-1hari-|-up-924-06.12.19-A12juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/18/2019
add comment=mikhmon name="jul/18/2019-|-19:13:45-|-BXIJP-|-5000-|-192.168.12.3\
    8-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/18/2019
add comment=mikhmon name="jul/18/2019-|-19:59:36-|-AZITR-|-3000-|-192.168.12.1\
    1-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/18/2019
add comment=mikhmon name="jul/19/2019-|-01:29:21-|-BBAXX-|-5000-|-192.168.12.1\
    72-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/19/2019
add comment=mikhmon name="jul/19/2019-|-12:46:44-|-BZXHY-|-5000-|-192.168.12.1\
    19-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/19/2019
add comment=mikhmon name="jul/19/2019-|-17:54:23-|-BZTJN-|-5000-|-192.168.12.9\
    3-|-0C:A8:A7:B4:5E:7E-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/19/2019
add comment=mikhmon name="jul/19/2019-|-18:03:14-|-AMKUF-|-3000-|-192.168.12.1\
    1-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/19/2019
add comment=mikhmon name="jul/19/2019-|-18:09:53-|-BFUTG-|-5000-|-192.168.12.1\
    35-|-10:92:66:74:CA:EF-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/19/2019
add comment=mikhmon name="jul/19/2019-|-19:18:23-|-ABANV-|-3000-|-192.168.12.8\
    1-|-54:27:58:78:10:60-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/19/2019
add comment=mikhmon name="jul/19/2019-|-19:47:25-|-BWXHG-|-5000-|-192.168.12.1\
    4-|-68:05:71:EA:EF:29-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/19/2019
add comment=mikhmon name="jul/19/2019-|-19:54:30-|-AJKKW-|-3000-|-192.168.12.1\
    38-|-1C:99:4C:E4:2D:96-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/19/2019
add comment=mikhmon name="jul/20/2019-|-05:51:32-|-BYIWS-|-5000-|-192.168.12.9\
    8-|-28:83:35:94:FE:E2-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/20/2019
add comment=mikhmon name="jul/20/2019-|-07:22:39-|-BWVXR-|-5000-|-192.168.12.1\
    48-|-C4:3A:BE:63:5C:44-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/20/2019
add comment=mikhmon name="jul/20/2019-|-10:36:19-|-BRZFB-|-5000-|-192.168.12.9\
    6-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/20/2019
add comment=mikhmon name="jul/20/2019-|-12:28:14-|-BNDTH-|-5000-|-192.168.12.1\
    16-|-60:72:8D:62:53:EB-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/20/2019
add comment=mikhmon name="jul/20/2019-|-16:55:19-|-BJYHA-|-5000-|-192.168.12.1\
    1-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/20/2019
add comment=mikhmon name="jul/21/2019-|-12:52:10-|-BZTJN-|-0-|-192.168.12.97-|\
    -0C:A8:A7:B4:5E:7E-|-1d 12h" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/21/2019
add comment=mikhmon name="jul/21/2019-|-13:00:24-|-BTVPD-|-5000-|-192.168.12.1\
    35-|-10:92:66:74:CA:EF-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/21/2019
add comment=mikhmon name="jul/21/2019-|-13:11:11-|-cek-|-0-|-192.168.12.114-|-\
    A4:D9:90:37:57:51-|-2m" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/21/2019
add comment=mikhmon name="jul/21/2019-|-13:17:42-|-cek1-|-0-|-192.168.12.114-|\
    -A4:D9:90:37:57:51-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/21/2019
add comment=mikhmon name="jul/21/2019-|-13:19:59-|-AYKHG-|-3000-|-192.168.12.8\
    1-|-54:27:58:78:10:60-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/21/2019
add comment=mikhmon name="jul/21/2019-|-13:36:31-|-BJYHA-|-5000-|-192.168.12.1\
    1-|-00:0A:00:D5:C3:D8-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/21/2019
add comment=mikhmon name="jul/21/2019-|-16:18:21-|-BWVXR-|-5000-|-192.168.12.1\
    48-|-C4:3A:BE:63:5C:44-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/21/2019
add comment=mikhmon name="jul/21/2019-|-16:25:21-|-BWHRI-|-5000-|-192.168.12.3\
    8-|-F0:6D:78:42:12:1A-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/21/2019
add comment=mikhmon name="jul/21/2019-|-16:52:30-|-BWXHG-|-0-|-192.168.12.14-|\
    -68:05:71:EA:EF:29-|-1d 12h" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/21/2019
add comment=mikhmon name="jul/21/2019-|-17:31:07-|-BRZFB-|-5000-|-192.168.12.9\
    6-|-1C:77:F6:E0:DE:02-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/21/2019
add comment=mikhmon name="jul/21/2019-|-17:51:47-|-CDVJZ-|-15000-|-192.168.12.\
    32-|-C0:87:EB:D5:D4:69-|-7d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/21/2019
add comment=mikhmon name="jul/21/2019-|-18:01:03-|-CZSTR-|-15000-|-192.168.12.\
    94-|-C0:87:EB:EE:62:DB-|-7d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/21/2019
add comment=mikhmon name="jul/21/2019-|-18:23:43-|-CVWVF-|-15000-|-192.168.12.\
    25-|-EC:D0:9F:CB:40:07-|-7d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/21/2019
add comment=mikhmon name="jul/21/2019-|-19:40:51-|-BZXHY-|-0-|-192.168.12.119-\
    |-08:8C:2C:E5:59:4D-|-1d 12h" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/21/2019
add comment=mikhmon name="jul/21/2019-|-21:19:58-|-BHJPM-|-5000-|-192.168.12.1\
    9-|-38:A4:ED:A1:2E:37-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/21/2019
add comment=mikhmon name="jul/21/2019-|-21:52:49-|-BYIWS-|-5000-|-192.168.12.6\
    2-|-28:83:35:94:FE:E2-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/21/2019
add comment=mikhmon name="jul/21/2019-|-23:03:38-|-BAJRU-|-5000-|-192.168.12.1\
    7-|-88:5A:06:66:12:E5-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/21/2019
add comment=mikhmon name="jul/22/2019-|-09:42:49-|-CKZIH-|-15000-|-192.168.12.\
    55-|-C0:87:EB:4A:C9:1F-|-7d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/22/2019
add comment=mikhmon name="jul/22/2019-|-13:26:07-|-ATRKD-|-3000-|-192.168.12.6\
    7-|-1C:7B:21:A5:C5:93-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/22/2019
add comment=mikhmon name="jul/22/2019-|-13:26:28-|-BNDTH-|-5000-|-192.168.12.4\
    2-|-60:72:8D:62:53:EB-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/22/2019
add comment=mikhmon name="jul/22/2019-|-13:31:56-|-BYPVV-|-5000-|-192.168.12.1\
    35-|-10:92:66:74:CA:EF-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/22/2019
add comment=mikhmon name="jul/22/2019-|-14:22:20-|-BRUBP-|-5000-|-192.168.12.4\
    3-|-20:5E:F7:E8:78:B2-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/22/2019
add comment=mikhmon name="jul/22/2019-|-17:36:54-|-BURMJ-|-5000-|-192.168.12.1\
    19-|-08:8C:2C:E5:59:4D-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/22/2019
add comment=mikhmon name="jul/22/2019-|-18:37:21-|-AHCCZ-|-3000-|-192.168.12.1\
    11-|-0C:98:38:6A:6A:51-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/22/2019
add comment=mikhmon name="jul/22/2019-|-18:41:20-|-ACCKW-|-3000-|-192.168.12.7\
    8-|-2C:56:DC:E7:15:E1-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/22/2019
add comment=mikhmon name="jul/22/2019-|-19:12:07-|-BMUYG-|-5000-|-192.168.12.9\
    6-|-1C:77:F6:E0:DE:02-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/22/2019
add comment=mikhmon name="jul/22/2019-|-19:34:58-|-BADHE-|-5000-|-192.168.12.9\
    5-|-80:AD:16:75:AC:62-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/22/2019
add comment=mikhmon name="jul/22/2019-|-20:39:32-|-BGAUP-|-5000-|-192.168.12.1\
    27-|-0C:A8:A7:48:10:18-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/22/2019
add comment=mikhmon name="jul/22/2019-|-20:47:39-|-AJKKW-|-3000-|-192.168.12.6\
    6-|-1C:99:4C:E4:2D:96-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/22/2019
add comment=mikhmon name="jul/22/2019-|-22:34:41-|-BVBME-|-5000-|-192.168.12.5\
    2-|-CC:2D:83:90:04:D7-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/22/2019
add comment=mikhmon name="jul/23/2019-|-16:48:34-|-BJPGH-|-5000-|-192.168.12.3\
    8-|-F0:6D:78:42:12:1A-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/23/2019
add comment=mikhmon name="jul/23/2019-|-16:49:36-|-AIZXW-|-3000-|-192.168.12.1\
    11-|-0C:98:38:6A:6A:51-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/23/2019
add comment=mikhmon name="jul/23/2019-|-17:13:33-|-BHCWA-|-5000-|-192.168.12.2\
    27-|-3C:95:09:E7:6D:13-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/23/2019
add comment=mikhmon name="jul/23/2019-|-17:16:38-|-AUIKW-|-3000-|-192.168.12.1\
    1-|-00:0A:00:D5:C3:D8-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/23/2019
add comment=mikhmon name="jul/23/2019-|-19:38:39-|-BUAFC-|-5000-|-192.168.12.1\
    07-|-1C:87:2C:3F:F5:68-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/23/2019
add comment=mikhmon name="jul/23/2019-|-20:00:04-|-BWMDH-|-5000-|-192.168.12.9\
    7-|-0C:A8:A7:B4:5E:7E-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/23/2019
add comment=mikhmon name="jul/23/2019-|-22:38:45-|-BUJMA-|-5000-|-192.168.12.6\
    2-|-28:83:35:94:FE:E2-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/23/2019
add comment=mikhmon name="jul/23/2019-|-23:11:58-|-BJZCK-|-5000-|-192.168.12.1\
    9-|-38:A4:ED:A1:2E:37-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/23/2019
add comment=mikhmon name="jul/24/2019-|-13:16:14-|-AFTKZ-|-3000-|-192.168.12.1\
    11-|-0C:98:38:6A:6A:51-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/24/2019
add comment=mikhmon name="jul/24/2019-|-14:06:12-|-BNPTH-|-5000-|-192.168.12.1\
    35-|-10:92:66:74:CA:EF-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/24/2019
add comment=mikhmon name="jul/24/2019-|-14:59:15-|-BAKXG-|-5000-|-192.168.12.1\
    82-|-C4:0B:CB:E3:2B:3C-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/24/2019
add comment=mikhmon name="jul/24/2019-|-17:54:01-|-BDZSV-|-5000-|-192.168.12.5\
    6-|-18:F0:E4:6C:02:34-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/24/2019
add comment=mikhmon name="jul/24/2019-|-17:56:20-|-BYMXF-|-5000-|-192.168.12.1\
    1-|-00:0A:00:D5:C3:D8-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/24/2019
add comment=mikhmon name="jul/24/2019-|-18:35:00-|-BZAER-|-5000-|-192.168.12.1\
    19-|-08:8C:2C:E5:59:4D-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/24/2019
add comment=mikhmon name="jul/24/2019-|-18:57:41-|-BEGBU-|-5000-|-192.168.12.2\
    6-|-F4:60:E2:30:CF:98-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/24/2019
add comment=mikhmon name="jul/24/2019-|-20:21:40-|-BWRTZ-|-5000-|-192.168.12.7\
    7-|-E0:99:71:C7:B6:9F-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/24/2019
add comment=mikhmon name="jul/24/2019-|-22:50:13-|-BSRDX-|-5000-|-192.168.12.9\
    6-|-1C:77:F6:E0:DE:02-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/24/2019
add comment=mikhmon name="jul/24/2019-|-23:03:35-|-AKIWY-|-3000-|-192.168.12.1\
    99-|-34:31:11:F9:B8:12-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/24/2019
add comment=mikhmon name="jul/24/2019-|-23:16:56-|-AVNZE-|-3000-|-192.168.12.9\
    6-|-1C:77:F6:E0:DE:02-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/24/2019
add comment=mikhmon name="jul/25/2019-|-11:19:00-|-BVCDA-|-5000-|-192.168.12.1\
    27-|-0C:A8:A7:48:10:18-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/25/2019
add comment=mikhmon name="jul/25/2019-|-17:02:23-|-BCHFZ-|-5000-|-192.168.12.1\
    35-|-10:92:66:74:CA:EF-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/25/2019
add comment=mikhmon name="jul/25/2019-|-17:47:43-|-AXEBT-|-3000-|-192.168.12.2\
    24-|-30:CB:F8:DC:47:AD-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/25/2019
add comment=mikhmon name="jul/25/2019-|-19:03:26-|-BBCUP-|-5000-|-192.168.12.1\
    11-|-0C:98:38:6A:6A:51-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/25/2019
add comment=mikhmon name="jul/25/2019-|-19:24:16-|-BTDHI-|-5000-|-192.168.12.3\
    8-|-F0:6D:78:42:12:1A-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/25/2019
add comment=mikhmon name="jul/25/2019-|-19:28:50-|-APXKB-|-3000-|-192.168.12.6\
    6-|-1C:99:4C:E4:2D:96-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/25/2019
add comment=mikhmon name="jul/25/2019-|-20:26:28-|-CISTJ-|-15000-|-192.168.12.\
    235-|-08:8C:2C:02:A3:A3-|-7d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/25/2019
add comment=mikhmon name="jul/25/2019-|-20:30:09-|-BFDER-|-5000-|-192.168.12.9\
    5-|-80:AD:16:75:AC:62-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/25/2019
add comment=mikhmon name="jul/25/2019-|-22:55:24-|-ABZDJ-|-3000-|-192.168.12.6\
    2-|-28:83:35:94:FE:E2-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/25/2019
add comment=mikhmon name="jul/25/2019-|-23:03:00-|-BSRDX-|-5000-|-192.168.12.9\
    6-|-1C:77:F6:E0:DE:02-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/25/2019
add comment=mikhmon name="jul/25/2019-|-23:26:27-|-ANGBA-|-3000-|-192.168.12.1\
    9-|-38:A4:ED:A1:2E:37-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/25/2019
add comment=mikhmon name="jul/26/2019-|-11:04:38-|-AEFBE-|-3000-|-192.168.12.2\
    21-|-A4:D9:90:37:57:51-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/26/2019
add comment=mikhmon name="jul/26/2019-|-11:26:23-|-BAKXG-|-0-|-192.168.12.182-\
    |-C4:0B:CB:E3:2B:3C-|-13h-|-reset1d-|-up-Reset lihin" owner=jul2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jul/26/2019
add comment=mikhmon name="jul/26/2019-|-18:06:15-|-ATEWD-|-3000-|-192.168.12.1\
    1-|-00:0A:00:D5:C3:D8-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/26/2019
add comment=mikhmon name="jul/26/2019-|-18:31:01-|-APXDK-|-3000-|-192.168.12.3\
    0-|-8C:BF:A6:4F:C3:55-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/26/2019
add comment=mikhmon name="jul/26/2019-|-18:33:32-|-BCRTN-|-5000-|-192.168.12.9\
    7-|-0C:A8:A7:B4:5E:7E-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/26/2019
add comment=mikhmon name="jul/26/2019-|-18:38:48-|-BYGPU-|-5000-|-192.168.12.1\
    04-|-24:79:F3:52:26:EB-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/26/2019
add comment=mikhmon name="jul/26/2019-|-19:37:59-|-AREPP-|-3000-|-192.168.12.2\
    51-|-34:E9:11:3B:E0:B3-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/26/2019
add comment=mikhmon name="jul/26/2019-|-23:28:07-|-BYCPM-|-5000-|-192.168.12.1\
    23-|-88:5A:06:66:12:E5-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/26/2019
add comment=mikhmon name="jul/27/2019-|-00:23:24-|-APKTF-|-3000-|-192.168.12.6\
    2-|-28:83:35:94:FE:E2-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/27/2019
add comment=mikhmon name="jul/27/2019-|-07:26:57-|-AZSKN-|-3000-|-192.168.12.1\
    48-|-C4:3A:BE:63:5C:44-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/27/2019
add comment=mikhmon name="jul/27/2019-|-14:31:06-|-ATXZZ-|-3000-|-192.168.12.5\
    2-|-CC:2D:83:90:04:D7-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/27/2019
add comment=mikhmon name="jul/27/2019-|-18:04:11-|-BJYUN-|-5000-|-192.168.12.9\
    5-|-80:AD:16:75:AC:62-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/27/2019
add comment=mikhmon name="jul/27/2019-|-19:07:45-|-BAAVI-|-5000-|-192.168.12.1\
    11-|-0C:98:38:6A:6A:51-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/27/2019
add comment=mikhmon name="jul/27/2019-|-19:11:24-|-BGYBG-|-5000-|-192.168.12.1\
    1-|-00:0A:00:D5:C3:D8-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/27/2019
add comment=mikhmon name="jul/27/2019-|-19:29:14-|-BGNTZ-|-5000-|-192.168.12.3\
    8-|-F0:6D:78:42:12:1A-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/27/2019
add comment=mikhmon name="jul/28/2019-|-08:27:53-|-AFBVY-|-3000-|-192.168.12.1\
    0-|-D8:32:14:61:41:99-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/28/2019
add comment=mikhmon name="jul/28/2019-|-08:34:22-|-AJYPP-|-3000-|-192.168.12.2\
    48-|-D8:32:14:61:41:99-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/28/2019
add comment=mikhmon name="jul/28/2019-|-08:34:55-|-BBPFS-|-5000-|-192.168.12.5\
    3-|-70:5E:55:A6:F8:99-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/28/2019
add comment=mikhmon name="jul/28/2019-|-10:17:50-|-AXRJD-|-3000-|-192.168.12.1\
    61-|-D8:CE:3A:67:9C:BB-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/28/2019
add comment=mikhmon name="jul/28/2019-|-10:20:49-|-AXEJX-|-3000-|-192.168.12.1\
    62-|-CC:07:E4:40:B9:36-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/28/2019
add comment=mikhmon name="jul/28/2019-|-15:35:55-|-BTJXJ-|-5000-|-192.168.12.1\
    48-|-C4:3A:BE:63:5C:44-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/28/2019
add comment=mikhmon name="jul/28/2019-|-16:03:49-|-AYBVI-|-3000-|-192.168.12.9\
    6-|-1C:77:F6:E0:DE:02-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/28/2019
add comment=mikhmon name="jul/29/2019-|-14:21:45-|-CEBGU-|-15000-|-192.168.12.\
    119-|-08:8C:2C:E5:59:4D-|-7d-|-7hari-|-up-513-06.30.19-7hr_30juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/29/2019
add comment=mikhmon name="jul/29/2019-|-14:23:21-|-BNUEJ-|-5000-|-192.168.12.1\
    19-|-08:8C:2C:E5:59:4D-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/29/2019
add comment=mikhmon name="jul/29/2019-|-16:58:24-|-CHTXG-|-15000-|-192.168.12.\
    51-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-513-06.30.19-7hr_30juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/29/2019
add comment=mikhmon name="jul/29/2019-|-17:19:11-|-BIFTM-|-5000-|-192.168.12.9\
    7-|-0C:A8:A7:B4:5E:7E-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/29/2019
add comment=mikhmon name="jul/29/2019-|-18:26:12-|-BHSGT-|-5000-|-192.168.12.1\
    11-|-0C:98:38:6A:6A:51-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/29/2019
add comment=mikhmon name="jul/29/2019-|-19:13:32-|-BEJJY-|-5000-|-192.168.12.1\
    1-|-00:0A:00:D5:C3:D8-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/29/2019
add comment=mikhmon name="jul/29/2019-|-19:46:15-|-BXJAW-|-5000-|-192.168.12.1\
    57-|-C0:87:EB:45:A0:57-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/29/2019
add comment=mikhmon name="jul/30/2019-|-05:37:47-|-CEPDG-|-15000-|-192.168.12.\
    94-|-C0:87:EB:EE:62:DB-|-7d-|-7hari-|-up-513-06.30.19-7hr_30juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/30/2019
add comment=mikhmon name="jul/30/2019-|-11:01:27-|-AFJVH-|-3000-|-192.168.12.5\
    3-|-70:5E:55:A6:F8:99-|-1d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/30/2019
add comment=mikhmon name="jul/30/2019-|-19:23:20-|-CYGEF-|-15000-|-192.168.12.\
    25-|-EC:D0:9F:CB:40:07-|-7d-|-7hari-|-up-513-06.30.19-7hr_30juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/30/2019
add comment=mikhmon name="jul/31/2019-|-16:25:37-|-BWFWE-|-5000-|-192.168.12.2\
    8-|-0C:A8:A7:48:10:18-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/31/2019
add comment=mikhmon name="jul/31/2019-|-17:21:04-|-BHFTF-|-5000-|-192.168.12.4\
    4-|-20:5E:F7:E8:78:B2-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/31/2019
add comment=mikhmon name="jul/31/2019-|-17:23:39-|-CHIIB-|-15000-|-192.168.12.\
    32-|-C0:87:EB:D5:D4:69-|-7d-|-7hari-|-up-513-06.30.19-7hr_30juni" owner=\
    jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/31/2019
add comment=mikhmon name="jul/31/2019-|-18:09:18-|-BHHTP-|-5000-|-192.168.12.9\
    7-|-0C:A8:A7:B4:5E:7E-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/31/2019
add comment=mikhmon name="jul/31/2019-|-19:15:04-|-BAXWG-|-5000-|-192.168.12.1\
    1-|-00:0A:00:D5:C3:D8-|-2d" owner=jul2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jul/31/2019
add comment=mikhmon name="aug/01/2019-|-12:52:08-|-AKYWH-|-3000-|-192.168.12.6\
    6-|-1C:99:4C:E4:2D:96-|-1d" owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/01/2019
add comment=mikhmon name="aug/01/2019-|-12:55:06-|-AAGNM-|-3000-|-192.168.12.1\
    50-|-4C:6F:9C:78:2C:0D-|-1d" owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/01/2019
add comment=mikhmon name="aug/03/2019-|-13:02:17-|-BPGRS-|-5000-|-192.168.12.1\
    1-|-00:0A:00:D5:C3:D8-|-2d" owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/03/2019
add comment=mikhmon name="aug/03/2019-|-13:23:37-|-BFCMR-|-5000-|-192.168.12.9\
    7-|-0C:A8:A7:B4:5E:7E-|-2d" owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/03/2019
add comment=mikhmon name="aug/03/2019-|-23:16:05-|-BXCIY-|-5000-|-192.168.12.3\
    0-|-1C:77:F6:E0:DE:02-|-2d" owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/03/2019
add comment=mikhmon name="aug/03/2019-|-23:26:14-|-BATDU-|-5000-|-192.168.12.1\
    9-|-38:A4:ED:A1:2E:37-|-2d" owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/03/2019
add comment=mikhmon name="aug/04/2019-|-07:43:46-|-AIHXE-|-3000-|-192.168.12.1\
    81-|-C4:3A:BE:63:5C:44-|-1d" owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/04/2019
add comment=mikhmon name="aug/04/2019-|-18:44:54-|-AJPEB-|-3000-|-192.168.12.2\
    06-|-08:7F:98:B0:5B:A1-|-1d" owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/04/2019
add comment=mikhmon name="aug/04/2019-|-19:23:39-|-BZNZH-|-5000-|-192.168.12.2\
    8-|-0C:A8:A7:48:10:18-|-2d" owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/04/2019
add comment=mikhmon name="aug/04/2019-|-21:10:38-|-CUEGH-|-15000-|-192.168.12.\
    230-|-08:7F:98:C7:BC:29-|-7d-|-7hari-|-up-" owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/04/2019
add comment=mikhmon name="aug/04/2019-|-22:27:52-|-CXDST-|-15000-|-192.168.12.\
    230-|-20:5E:F7:FA:47:BC-|-7d-|-7hari-|-up-513-06.30.19-7hr_30juni" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/04/2019
add comment=mikhmon name="aug/05/2019-|-12:52:26-|-BRVFD-|-5000-|-192.168.12.4\
    2-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/05/2019
add comment=mikhmon name="aug/05/2019-|-14:16:41-|-CVXTV-|-15000-|-192.168.12.\
    242-|-A4:D9:90:28:BB:33-|-7d-|-7hari-|-up-513-06.30.19-7hr_30juni" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/05/2019
add comment=mikhmon name="aug/05/2019-|-18:18:02-|-AGIKU-|-3000-|-192.168.12.7\
    0-|-2C:56:DC:E7:15:E1-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/05/2019
add comment=mikhmon name="aug/05/2019-|-19:03:47-|-BEDFW-|-5000-|-192.168.12.7\
    9-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/05/2019
add comment=mikhmon name="aug/06/2019-|-04:44:31-|-ATUVF-|-3000-|-192.168.12.3\
    4-|-1C:7B:21:A5:C5:93-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/06/2019
add comment=mikhmon name="aug/06/2019-|-08:27:19-|-CBDSU-|-15000-|-192.168.12.\
    68-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-513-06.30.19-7hr_30juni" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/06/2019
add comment=mikhmon name="aug/06/2019-|-08:59:10-|-AFIGM-|-3000-|-192.168.12.1\
    04-|-0C:98:38:1D:99:0B-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/06/2019
add comment=mikhmon name="aug/06/2019-|-15:14:08-|-BYRHH-|-5000-|-192.168.12.8\
    2-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/06/2019
add comment=mikhmon name="aug/06/2019-|-15:30:00-|-BVFJB-|-5000-|-192.168.12.6\
    7-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/06/2019
add comment=mikhmon name="aug/06/2019-|-17:19:20-|-CXZPS-|-15000-|-192.168.12.\
    15-|-C0:87:EB:EE:62:DB-|-7d-|-7hari-|-up-513-06.30.19-7hr_30juni" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/06/2019
add comment=mikhmon name="aug/06/2019-|-18:16:14-|-AJRPN-|-3000-|-192.168.12.1\
    25-|-08:7F:98:E1:84:ED-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/06/2019
add comment=mikhmon name="aug/06/2019-|-18:58:51-|-BEVMP-|-5000-|-192.168.12.7\
    7-|-E0:99:71:C7:B6:9F-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/06/2019
add comment=mikhmon name="aug/06/2019-|-19:31:21-|-BHKVK-|-5000-|-192.168.12.7\
    0-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/06/2019
add comment=mikhmon name="aug/06/2019-|-19:33:32-|-BMZJR-|-5000-|-192.168.12.5\
    9-|-0C:A8:A7:48:10:18-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/06/2019
add comment=mikhmon name="aug/07/2019-|-06:48:00-|-BMJCK-|-5000-|-192.168.12.1\
    28-|-88:5A:06:66:12:E5-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/07/2019
add comment=mikhmon name="aug/07/2019-|-12:56:21-|-BFZRW-|-5000-|-192.168.12.4\
    2-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/07/2019
add comment=mikhmon name="aug/07/2019-|-14:07:16-|-BGNVH-|-5000-|-192.168.12.1\
    42-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/07/2019
add comment=mikhmon name="aug/07/2019-|-19:27:17-|-CUEGH-|-0-|-192.168.12.51-|\
    -08:7F:98:C7:BC:29-|-6d-|-6D-|-up-" owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/07/2019
add comment=mikhmon name="aug/07/2019-|-19:35:12-|-CFUNX-|-15000-|-192.168.12.\
    58-|-0C:98:38:6A:6A:51-|-7d-|-7hari-|-up-513-06.30.19-7hr_30juni" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/07/2019
add comment=mikhmon name="aug/08/2019-|-00:48:21-|-BBGDC-|-5000-|-192.168.12.8\
    2-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/08/2019
add comment=mikhmon name="aug/08/2019-|-04:55:40-|-AXISI-|-3000-|-192.168.12.1\
    3-|-1C:7B:21:A5:C5:93-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/08/2019
add comment=mikhmon name="aug/08/2019-|-14:21:19-|-AWWWI-|-3000-|-192.168.12.5\
    7-|-34:E9:11:3B:E0:B3-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/08/2019
add comment=mikhmon name="aug/08/2019-|-17:22:11-|-ANIRE-|-3000-|-192.168.12.1\
    0-|-A4:D9:90:37:57:51-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/08/2019
add comment=mikhmon name="aug/08/2019-|-17:57:34-|-ATJVB-|-3000-|-192.168.12.1\
    25-|-08:7F:98:E1:84:ED-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/08/2019
add comment=mikhmon name="aug/08/2019-|-20:57:31-|-BDFCI-|-5000-|-192.168.12.1\
    07-|-20:5E:F7:FA:47:BC-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/08/2019
add comment=mikhmon name="aug/08/2019-|-21:32:33-|-CHVNJ-|-15000-|-192.168.12.\
    121-|-08:8C:2C:02:A3:A3-|-7d-|-7hari-|-up-513-06.30.19-7hr_30juni" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/08/2019
add comment=mikhmon name="aug/09/2019-|-11:17:21-|-BNRBH-|-5000-|-192.168.12.7\
    0-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/09/2019
add comment=mikhmon name="aug/09/2019-|-12:25:21-|-BFZAZ-|-5000-|-192.168.12.1\
    17-|-58:44:98:BA:56:06-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/09/2019
add comment=mikhmon name="aug/09/2019-|-12:32:16-|-ASTXJ-|-3000-|-192.168.12.3\
    4-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/09/2019
add comment=mikhmon name="aug/09/2019-|-16:17:57-|-BFZGY-|-5000-|-192.168.12.4\
    2-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/09/2019
add comment=mikhmon name="aug/09/2019-|-17:50:21-|-ARMCB-|-3000-|-192.168.12.1\
    42-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/09/2019
add comment=mikhmon name="aug/09/2019-|-18:35:27-|-CXSDM-|-15000-|-192.168.12.\
    243-|-C0:87:EB:D5:D4:69-|-7d-|-7hari-|-up-513-06.30.19-7hr_30juni" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/09/2019
add comment=mikhmon name="aug/09/2019-|-18:35:37-|-BXEKC-|-5000-|-192.168.12.1\
    22-|-20:5E:F7:E8:78:B2-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/09/2019
add comment=mikhmon name="aug/09/2019-|-19:24:49-|-BNAVK-|-5000-|-192.168.12.7\
    9-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/09/2019
add comment=mikhmon name="aug/09/2019-|-19:59:47-|-AWBZY-|-3000-|-192.168.12.1\
    62-|-08:EE:8B:F5:DA:26-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/09/2019
add comment=mikhmon name="aug/09/2019-|-20:09:39-|-BANNF-|-5000-|-192.168.12.2\
    04-|-1C:77:F6:5B:E2:CC-|-2d-|-2hari-|-up-563-06.30.19-2hari_30jn" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/09/2019
add comment=mikhmon name="aug/09/2019-|-23:47:44-|-AVZHV-|-3000-|-192.168.12.6\
    7-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/09/2019
add comment=mikhmon name="aug/10/2019-|-08:14:18-|-BUAWD-|-5000-|-192.168.12.2\
    17-|-C4:0B:CB:E3:2B:3C-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/10/2019
add comment=mikhmon name="aug/10/2019-|-11:34:25-|-AIMPF-|-3000-|-192.168.12.1\
    25-|-08:7F:98:E1:84:ED-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/10/2019
add comment=mikhmon name="aug/10/2019-|-12:05:03-|-AVBCR-|-3000-|-192.168.12.1\
    9-|-60:72:8D:62:53:EB-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/10/2019
add comment=mikhmon name="aug/10/2019-|-12:17:46-|-AHAGB-|-3000-|-192.168.12.2\
    21-|-00:0A:00:DD:51:88-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/10/2019
add comment=mikhmon name="aug/10/2019-|-12:39:59-|-BUAWD-|-5000-|-192.168.12.2\
    17-|-C4:0B:CB:E3:2B:3C-|-2d-|-2hari-|-up-" owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/10/2019
add comment=mikhmon name="aug/10/2019-|-15:23:48-|-BWBAV-|-5000-|-192.168.12.8\
    2-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/10/2019
add comment=mikhmon name="aug/10/2019-|-17:45:33-|-ANEII-|-3000-|-192.168.12.1\
    3-|-1C:7B:21:A5:C5:93-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/10/2019
add comment=mikhmon name="aug/10/2019-|-21:44:04-|-BMCEU-|-5000-|-192.168.12.8\
    6-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/10/2019
add comment=mikhmon name="aug/10/2019-|-23:02:50-|-AIDPI-|-3000-|-192.168.12.1\
    25-|-08:7F:98:E1:84:ED-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/10/2019
add comment=mikhmon name="aug/11/2019-|-00:15:04-|-BHXNI-|-5000-|-192.168.12.3\
    5-|-C4:3A:BE:63:5C:44-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/11/2019
add comment=mikhmon name="aug/11/2019-|-06:03:56-|-BNKIE-|-5000-|-192.168.12.5\
    5-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/11/2019
add comment=mikhmon name="aug/11/2019-|-10:01:43-|-AZAIZ-|-3000-|-192.168.12.1\
    91-|-24:2E:02:8D:5E:F4-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/11/2019
add comment=mikhmon name="aug/11/2019-|-10:19:24-|-BMVXE-|-5000-|-192.168.12.1\
    42-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/11/2019
add comment=mikhmon name="aug/11/2019-|-10:59:19-|-AYVRV-|-3000-|-192.168.12.2\
    03-|-8C:BF:A6:4F:C3:55-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/11/2019
add comment=mikhmon name="aug/11/2019-|-11:01:01-|-AVCZZ-|-3000-|-192.168.12.3\
    4-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/11/2019
add comment=mikhmon name="aug/11/2019-|-13:07:10-|-ATIPA-|-5000-|-192.168.12.1\
    62-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/11/2019
add comment=mikhmon name="aug/11/2019-|-16:17:25-|-ACNYU-|-3000-|-192.168.12.7\
    0-|-2C:56:DC:E7:15:E1-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/11/2019
add comment=mikhmon name="aug/11/2019-|-16:49:33-|-AXXMP-|-3000-|-192.168.12.3\
    9-|-C0:EE:FB:05:DA:78-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/11/2019
add comment=mikhmon name="aug/11/2019-|-17:01:43-|-BBRZS-|-5000-|-192.168.12.4\
    2-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/11/2019
add comment=mikhmon name="aug/11/2019-|-17:27:19-|-ADHTA-|-3000-|-192.168.12.1\
    9-|-60:72:8D:62:53:EB-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/11/2019
add comment=mikhmon name="aug/11/2019-|-18:28:00-|-BMPSJ-|-5000-|-192.168.12.1\
    46-|-0C:A8:A7:48:10:18-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/11/2019
add comment=mikhmon name="aug/11/2019-|-20:30:37-|-BCBHT-|-5000-|-192.168.12.8\
    2-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/11/2019
add comment=mikhmon name="aug/12/2019-|-11:53:17-|-BGEIK-|-5000-|-192.168.12.5\
    8-|-0C:98:38:6A:6A:51-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/12/2019
add comment=mikhmon name="aug/12/2019-|-14:39:15-|-BWCIX-|-5000-|-192.168.12.5\
    1-|-08:7F:98:C7:BC:29-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/12/2019
add comment=mikhmon name="aug/12/2019-|-15:33:18-|-ACASG-|-5000-|-192.168.12.7\
    9-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/12/2019
add comment=mikhmon name="aug/12/2019-|-17:10:00-|-AJUFT-|-3000-|-192.168.12.3\
    9-|-C0:EE:FB:05:DA:78-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/12/2019
add comment=mikhmon name="aug/12/2019-|-19:47:43-|-AMRHK-|-5000-|-192.168.12.4\
    2-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/12/2019
add comment=mikhmon name="aug/12/2019-|-19:51:40-|-ATAJJ-|-3000-|-192.168.12.1\
    25-|-08:7F:98:E1:84:ED-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/12/2019
add comment=mikhmon name="aug/12/2019-|-20:44:52-|-ABJGV-|-3000-|-192.168.12.1\
    50-|-F0:6D:78:78:4A:70-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/12/2019
add comment=mikhmon name="aug/13/2019-|-07:38:51-|-CYXNN-|-15000-|-192.168.12.\
    242-|-A4:D9:90:28:BB:33-|-7d-|-7hari-|-up-513-06.30.19-7hr_30juni" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/13/2019
add comment=mikhmon name="aug/13/2019-|-09:32:04-|-CWYMV-|-15000-|-192.168.12.\
    68-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-513-06.30.19-7hr_30juni" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/13/2019
add comment=mikhmon name="aug/13/2019-|-11:25:36-|-AADIE-|-3000-|-192.168.12.5\
    7-|-18:F0:E4:6C:02:34-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/13/2019
add comment=mikhmon name="aug/13/2019-|-12:35:38-|-BFAFC-|-5000-|-192.168.12.1\
    42-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/13/2019
add comment=mikhmon name="aug/13/2019-|-13:18:17-|-AKHII-|-3000-|-192.168.12.3\
    4-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/13/2019
add comment=mikhmon name="aug/13/2019-|-14:45:17-|-BSMGL-|-5000-|-192.168.12.7\
    0-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/13/2019
add comment=mikhmon name="aug/13/2019-|-17:27:34-|-ANYGC-|-3000-|-192.168.12.1\
    07-|-34:E9:11:48:E1:CD-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/13/2019
add comment=mikhmon name="aug/13/2019-|-18:13:02-|-BACAX-|-5000-|-192.168.12.1\
    13-|-58:44:98:BA:56:06-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/13/2019
add comment=mikhmon name="aug/13/2019-|-18:18:11-|-BMDVS-|-5000-|-192.168.12.8\
    6-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/13/2019
add comment=mikhmon name="aug/13/2019-|-18:22:13-|-BLVZK-|-5000-|-192.168.12.8\
    1-|-0C:A8:A7:B4:5E:7E-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/13/2019
add comment=mikhmon name="aug/13/2019-|-20:42:24-|-BFHPD-|-5000-|-192.168.12.5\
    5-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/13/2019
add comment=mikhmon name="aug/13/2019-|-21:00:23-|-BGCBA-|-5000-|-192.168.12.1\
    34-|-C0:87:EB:5A:BC:3F-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/13/2019
add comment=mikhmon name="aug/13/2019-|-23:38:43-|-BCDBI-|-5000-|-192.168.12.8\
    2-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/13/2019
add comment=mikhmon name="aug/14/2019-|-10:25:48-|-CJJVW-|-15000-|-192.168.12.\
    15-|-C0:87:EB:EE:62:DB-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/14/2019
add comment=mikhmon name="aug/14/2019-|-12:58:20-|-AXYBY-|-3000-|-192.168.12.2\
    14-|-00:27:15:38:F8:33-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/14/2019
add comment=mikhmon name="aug/14/2019-|-13:00:05-|-BVNCH-|-5000-|-192.168.12.1\
    46-|-0C:A8:A7:48:10:18-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/14/2019
add comment=mikhmon name="aug/14/2019-|-13:23:54-|-BBEKM-|-5000-|-192.168.12.1\
    96-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/14/2019
add comment=mikhmon name="aug/14/2019-|-15:02:50-|-BBYDV-|-5000-|-192.168.12.5\
    1-|-08:7F:98:C7:BC:29-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/14/2019
add comment=mikhmon name="aug/14/2019-|-18:18:09-|-AKXXR-|-3000-|-192.168.12.2\
    3-|-74:23:44:5C:38:28-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/14/2019
add comment=mikhmon name="aug/14/2019-|-19:57:00-|-BCFWN-|-5000-|-192.168.12.4\
    2-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/14/2019
add comment=mikhmon name="aug/15/2019-|-00:17:41-|-BFCCY-|-5000-|-192.168.12.2\
    17-|-C4:0B:CB:E3:2B:3C-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/15/2019
add comment=mikhmon name="aug/15/2019-|-06:34:18-|-BCMLS-|-5000-|-192.168.12.8\
    9-|-58:44:98:31:1F:B5-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/15/2019
add comment=mikhmon name="aug/15/2019-|-10:25:33-|-AXHTF-|-3000-|-192.168.12.9\
    4-|-7C:03:5E:C9:04:FB-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/15/2019
add comment=mikhmon name="aug/15/2019-|-13:03:45-|-BUGAG-|-5000-|-192.168.12.7\
    9-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/15/2019
add comment=mikhmon name="aug/15/2019-|-14:18:02-|-AMCCT-|-3000-|-192.168.12.1\
    69-|-34:E9:11:4C:78:81-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/15/2019
add comment=mikhmon name="aug/15/2019-|-16:07:52-|-ABTUM-|-3000-|-192.168.12.1\
    72-|-F4:0E:22:03:16:0E-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/15/2019
add comment=mikhmon name="aug/15/2019-|-18:17:04-|-BTTFM-|-5000-|-192.168.12.7\
    0-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/15/2019
add comment=mikhmon name="aug/15/2019-|-19:07:58-|-BAGKE-|-5000-|-192.168.12.5\
    3-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/15/2019
add comment=mikhmon name="aug/15/2019-|-19:13:54-|-CKCBW-|-15000-|-192.168.12.\
    77-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/15/2019
add comment=mikhmon name="aug/15/2019-|-21:44:39-|-ADFKZ-|-3000-|-192.168.12.6\
    1-|-0C:98:38:1D:99:0B-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/15/2019
add comment=mikhmon name="aug/16/2019-|-10:52:03-|-AGHKA-|-3000-|-192.168.12.1\
    25-|-08:7F:98:E1:84:ED-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/16/2019
add comment=mikhmon name="aug/16/2019-|-13:35:11-|-BSUZS-|-5000-|-192.168.12.1\
    42-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/16/2019
add comment=mikhmon name="aug/16/2019-|-18:31:08-|-CMSPK-|-15000-|-192.168.12.\
    51-|-08:7F:98:C7:BC:29-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/16/2019
add comment=mikhmon name="aug/16/2019-|-18:43:02-|-BLZWH-|-5000-|-192.168.12.1\
    96-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/16/2019
add comment=mikhmon name="aug/16/2019-|-19:11:30-|-BWTBR-|-5000-|-192.168.12.8\
    1-|-0C:A8:A7:B4:5E:7E-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/16/2019
add comment=mikhmon name="aug/16/2019-|-20:02:18-|-BSPKE-|-5000-|-192.168.12.4\
    2-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/16/2019
add comment=mikhmon name="aug/17/2019-|-08:12:30-|-AYKPN-|-3000-|-192.168.12.1\
    99-|-00:0A:00:DD:51:88-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/17/2019
add comment=mikhmon name="aug/17/2019-|-08:13:09-|-ARCUK-|-3000-|-192.168.12.1\
    9-|-60:72:8D:62:53:EB-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/17/2019
add comment=mikhmon name="aug/17/2019-|-09:53:38-|-BGFVH-|-5000-|-192.168.12.2\
    51-|-2C:57:31:F0:77:09-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/17/2019
add comment=mikhmon name="aug/17/2019-|-09:55:31-|-ANSXB-|-3000-|-192.168.12.2\
    52-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/17/2019
add comment=mikhmon name="aug/17/2019-|-10:06:20-|-CYBVK-|-15000-|-192.168.12.\
    243-|-C0:87:EB:D5:D4:69-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/17/2019
add comment=mikhmon name="aug/17/2019-|-10:24:17-|-AIXKB-|-3000-|-192.168.12.9\
    2-|-1C:99:4C:E4:2D:96-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/17/2019
add comment=mikhmon name="aug/17/2019-|-10:24:43-|-ARZTC-|-3000-|-192.168.12.9\
    4-|-7C:03:5E:C9:04:FB-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/17/2019
add comment=mikhmon name="aug/17/2019-|-10:55:06-|-ADDXY-|-3000-|-192.168.12.3\
    4-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/17/2019
add comment=mikhmon name="aug/17/2019-|-11:20:02-|-AXEIT-|-3000-|-192.168.12.1\
    25-|-08:7F:98:E1:84:ED-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/17/2019
add comment=mikhmon name="aug/17/2019-|-11:59:49-|-AMUKF-|-3000-|-192.168.12.4\
    1-|-A4:D9:90:37:57:51-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/17/2019
add comment=mikhmon name="aug/17/2019-|-14:34:40-|-AWAEX-|-3000-|-192.168.12.5\
    6-|-0C:A8:A7:89:E6:66-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/17/2019
add comment=mikhmon name="aug/17/2019-|-15:59:53-|-AMHHM-|-3000-|-192.168.12.2\
    30-|-8C:BF:A6:4F:C3:55-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/17/2019
add comment=mikhmon name="aug/17/2019-|-20:20:26-|-BKMBZ-|-5000-|-192.168.12.5\
    0-|-58:44:98:BA:56:06-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/17/2019
add comment=mikhmon name="aug/18/2019-|-09:39:11-|-BVBWG-|-5000-|-192.168.12.5\
    3-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/18/2019
add comment=mikhmon name="aug/18/2019-|-10:58:59-|-ARTET-|-3000-|-192.168.12.3\
    4-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/18/2019
add comment=mikhmon name="aug/18/2019-|-13:57:34-|-AMKVI-|-3000-|-192.168.12.5\
    4-|-20:5E:F7:FA:47:BC-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/18/2019
add comment=mikhmon name="aug/18/2019-|-15:01:22-|-BPBPB-|-5000-|-192.168.12.7\
    9-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/18/2019
add comment=mikhmon name="aug/18/2019-|-15:17:52-|-APJIP-|-3000-|-192.168.12.1\
    99-|-00:0A:00:DD:51:88-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/18/2019
add comment=mikhmon name="aug/18/2019-|-17:49:12-|-BJNVA-|-5000-|-192.168.12.1\
    42-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/18/2019
add comment=mikhmon name="aug/18/2019-|-20:16:37-|-BJCXJ-|-5000-|-192.168.12.1\
    44-|-DC:85:DE:46:43:23-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/18/2019
add comment=mikhmon name="aug/19/2019-|-00:13:32-|-ATVDG-|-3000-|-192.168.12.1\
    59-|-38:A4:ED:A1:2E:37-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/19/2019
add comment=mikhmon name="aug/19/2019-|-06:50:54-|-BLWMF-|-5000-|-192.168.12.7\
    0-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/19/2019
add comment=mikhmon name="aug/19/2019-|-18:12:12-|-CBCAE-|-15000-|-192.168.12.\
    200-|-EC:D0:9F:CB:40:07-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/19/2019
add comment=mikhmon name="aug/19/2019-|-19:22:49-|-ADEAW-|-3000-|-192.168.12.1\
    34-|-C0:87:EB:5A:BC:3F-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/19/2019
add comment=mikhmon name="aug/19/2019-|-21:44:56-|-ASWEI-|-3000-|-192.168.12.6\
    1-|-0C:98:38:1D:99:0B-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/19/2019
add comment=mikhmon name="aug/20/2019-|-09:12:43-|-AFTSH-|-3000-|-192.168.12.1\
    59-|-38:A4:ED:A1:2E:37-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/20/2019
add comment=mikhmon name="aug/20/2019-|-10:09:41-|-CTHTK-|-15000-|-192.168.12.\
    242-|-A4:D9:90:28:BB:33-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/20/2019
add comment=mikhmon name="aug/20/2019-|-11:02:45-|-CFFLF-|-15000-|-192.168.12.\
    68-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/20/2019
add comment=mikhmon name="aug/20/2019-|-11:58:52-|-BPFGL-|-5000-|-192.168.12.1\
    46-|-0C:A8:A7:48:10:18-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/20/2019
add comment=mikhmon name="aug/20/2019-|-14:46:24-|-ASHCS-|-3000-|-192.168.12.3\
    4-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/20/2019
add comment=mikhmon name="aug/20/2019-|-18:20:57-|-BJVNG-|-5000-|-192.168.12.7\
    9-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/20/2019
add comment=mikhmon name="aug/20/2019-|-19:27:40-|-AYXNI-|-3000-|-192.168.12.1\
    34-|-C0:87:EB:5A:BC:3F-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/20/2019
add comment=mikhmon name="aug/20/2019-|-19:36:22-|-AZUSC-|-3000-|-192.168.12.1\
    06-|-7C:03:5E:C9:04:FB-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/20/2019
add comment=mikhmon name="aug/21/2019-|-06:22:45-|-BGVTE-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/21/2019
add comment=mikhmon name="aug/21/2019-|-08:22:41-|-AANXS-|-3000-|-192.168.12.1\
    40-|-D8:16:C1:21:3E:08-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/21/2019
add comment=mikhmon name="aug/21/2019-|-08:52:27-|-BZAMR-|-5000-|-192.168.12.1\
    42-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/21/2019
add comment=mikhmon name="aug/21/2019-|-09:18:06-|-AFFEK-|-3000-|-192.168.12.6\
    1-|-0C:98:38:1D:99:0B-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/21/2019
add comment=mikhmon name="aug/21/2019-|-10:00:35-|-BJRNE-|-5000-|-192.168.12.1\
    02-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/21/2019
add comment=mikhmon name="aug/21/2019-|-10:00:45-|-ASRGS-|-3000-|-192.168.12.1\
    51-|-CC:2D:83:90:04:D7-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/21/2019
add comment=mikhmon name="aug/21/2019-|-10:22:26-|-AKCMR-|-3000-|-192.168.12.1\
    45-|-24:2E:02:8D:5E:F4-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/21/2019
add comment=nurudinismail69@gmail.com-|-1m-|- name=BackupEmail owner=nrdnisml \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=":log info \"backup beginning now\";:local date [/system clock get \
    date];:local day [:pick \$date 4 6];:local month [:pick \$date 0 3];:local\
    \_year [:pick \$date 7 11];:local datebc \"\$day-|-\$month-|-\$year\";:glo\
    bal backupfile (\"Backup-\" . [/system identity get name] . \":\$datebc\")\
    ;export file=\$backupfile;:log info \"backup pausing for 15s\";:delay 15s;\
    :log info \"backup being emailed\";/tool e-mail send to=\"nurudinismail69@\
    gmail.com\" subject=([/system identity get name] . \" Backup\") from=<mela\
    tispot> body=(\"Ini adalah e-mail otomatis yang dibuat oleh \" . [/system \
    identity get name]) file=\$backupfile;:delay 30s;/file remove \$backupfile\
    ;:log info \"backup finished\""
add comment=-|-Jul-|-,-|-Aug-|-,-|-Oct-|-,-|-Nov-|-,-|-Dec-|- name=\
    RekapPendapatan owner=nrdnisml policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    0,805000,0,0,0
add comment="Report Pendapatan" name=ReportPendapatan owner=nrdnisml policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=0
add comment="Reset Report Pendapatan" name=ResetReportPendapatan owner=\
    nrdnisml policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":\
    if ([/system clock get date]~\"/01/\") do={:local tgl [/system clock get d\
    ate];:local bl [:pick \$tgl 0 3];if (\$bl = \"jan\") do={:set \$bl \"Dec\"\
    ;:local pend [/system script get ReportPendapatan source];:local pendBul [\
    /system script get RekapPendapatan source];:local nmBul [/system script ge\
    t RekapPendapatan comment];:local toPB (\"\$pendBul\" .\",\". \"\$pend\");\
    :local toPBc (\"\$nmBul\" .\",-|-\". \"\$bl\".\"-|-\");[/system script set\
    \_comment=\"\$toPBc\" RekapPendapatan];[/system script set source=\"\$toPB\
    \" RekapPendapatan];[/system script set source=\"0\" ReportPendapatan];[/s\
    ystem sch re ResetReportPendapatan];[/undo];[/system scr re ResetReportPen\
    dapatan];[/undo]} else={if (\$bl = \"feb\") do={:set \$bl \"Jan\";:local p\
    end [/system script get ReportPendapatan source];[/system script set comme\
    nt=\"-|-Jan-|-\" RekapPendapatan];[/system script set source=\"\$pend\" Re\
    kapPendapatan];[/system script set source=\"0\" ReportPendapatan];[/system\
    \_sch re ResetReportPendapatan];[/undo];[/system scr re ResetReportPendapa\
    tan];[/undo]} else={if (\$bl = \"mar\") do={:set \$bl \"Feb\";:local pend \
    [/system script get ReportPendapatan source];:local pendBul [/system scrip\
    t get RekapPendapatan source];:local nmBul [/system script get RekapPendap\
    atan comment];:local toPB (\"\$pendBul\" .\",\". \"\$pend\");:local toPBc \
    (\"\$nmBul\" .\",-|-\". \"\$bl\".\"-|-\");[/system script set comment=\"\$\
    toPBc\" RekapPendapatan];[/system script set source=\"\$toPB\" RekapPendap\
    atan];[/system script set source=\"0\" ReportPendapatan];[/system sch re R\
    esetReportPendapatan];[/undo];[/system scr re ResetReportPendapatan];[/und\
    o]} else={if (\$bl = \"apr\") do={:set \$bl \"Mar\";:local pend [/system s\
    cript get ReportPendapatan source];:local pendBul [/system script get Reka\
    pPendapatan source];:local nmBul [/system script get RekapPendapatan comme\
    nt];:local toPB (\"\$pendBul\" .\",\". \"\$pend\");:local toPBc (\"\$nmBul\
    \" .\",-|-\". \"\$bl\".\"-|-\");[/system script set comment=\"\$toPBc\" Re\
    kapPendapatan];[/system script set source=\"\$toPB\" RekapPendapatan];[/sy\
    stem script set source=\"0\" ReportPendapatan];[/system sch re ResetReport\
    Pendapatan];[/undo];[/system scr re ResetReportPendapatan];[/undo]} else={\
    if (\$bl = \"may\") do={:set \$bl \"Apr\";:local pend [/system script get \
    ReportPendapatan source];:local pendBul [/system script get RekapPendapata\
    n source];:local nmBul [/system script get RekapPendapatan comment];:local\
    \_toPB (\"\$pendBul\" .\",\". \"\$pend\");:local toPBc (\"\$nmBul\" .\",-|\
    -\". \"\$bl\".\"-|-\");[/system script set comment=\"\$toPBc\" RekapPendap\
    atan];[/system script set source=\"\$toPB\" RekapPendapatan];[/system scri\
    pt set source=\"0\" ReportPendapatan];[/system sch re ResetReportPendapata\
    n];[/undo];[/system scr re ResetReportPendapatan];[/undo]} else={if (\$bl \
    = \"jun\") do={:set \$bl \"May\";:local pend [/system script get ReportPen\
    dapatan source];:local pendBul [/system script get RekapPendapatan source]\
    ;:local nmBul [/system script get RekapPendapatan comment];:local toPB (\"\
    \$pendBul\" .\",\". \"\$pend\");:local toPBc (\"\$nmBul\" .\",-|-\". \"\$b\
    l\".\"-|-\");[/system script set comment=\"\$toPBc\" RekapPendapatan];[/sy\
    stem script set source=\"\$toPB\" RekapPendapatan];[/system script set sou\
    rce=\"0\" ReportPendapatan];[/system sch re ResetReportPendapatan];[/undo]\
    ;[/system scr re ResetReportPendapatan];[/undo]} else={if (\$bl = \"jul\")\
    \_do={:set \$bl \"Jun\";:local pend [/system script get ReportPendapatan s\
    ource];:local pendBul [/system script get RekapPendapatan source];:local n\
    mBul [/system script get RekapPendapatan comment];:local toPB (\"\$pendBul\
    \" .\",\". \"\$pend\");:local toPBc (\"\$nmBul\" .\",-|-\". \"\$bl\".\"-|-\
    \");[/system script set comment=\"\$toPBc\" RekapPendapatan];[/system scri\
    pt set source=\"\$toPB\" RekapPendapatan];[/system script set source=\"0\"\
    \_ReportPendapatan];[/system sch re ResetReportPendapatan];[/undo];[/syste\
    m scr re ResetReportPendapatan];[/undo]} else={if (\$bl = \"aug\") do={:se\
    t \$bl \"Jul\";:local pend [/system script get ReportPendapatan source];:l\
    ocal pendBul [/system script get RekapPendapatan source];:local nmBul [/sy\
    stem script get RekapPendapatan comment];:local toPB (\"\$pendBul\" .\",\"\
    . \"\$pend\");:local toPBc (\"\$nmBul\" .\",-|-\". \"\$bl\".\"-|-\");[/sys\
    tem script set comment=\"\$toPBc\" RekapPendapatan];[/system script set so\
    urce=\"\$toPB\" RekapPendapatan];[/system script set source=\"0\" ReportPe\
    ndapatan];[/system sch re ResetReportPendapatan];[/undo];[/system scr re R\
    esetReportPendapatan];[/undo]} else={if (\$bl = \"sep\") do={:set \$bl \"A\
    ug\";:local pend [/system script get ReportPendapatan source];:local pendB\
    ul [/system script get RekapPendapatan source];:local nmBul [/system scrip\
    t get RekapPendapatan comment];:local toPB (\"\$pendBul\" .\",\". \"\$pend\
    \");:local toPBc (\"\$nmBul\" .\",-|-\". \"\$bl\".\"-|-\");[/system script\
    \_set comment=\"\$toPBc\" RekapPendapatan];[/system script set source=\"\$\
    toPB\" RekapPendapatan];[/system script set source=\"0\" ReportPendapatan]\
    ;[/system sch re ResetReportPendapatan];[/undo];[/system scr re ResetRepor\
    tPendapatan];[/undo]} else={if (\$bl = \"Oct\") do={:set \$bl \"Sep\";:loc\
    al pend [/system script get ReportPendapatan source];:local pendBul [/syst\
    em script get RekapPendapatan source];:local nmBul [/system script get Rek\
    apPendapatan comment];:local toPB (\"\$pendBul\" .\",\". \"\$pend\");:loca\
    l toPBc (\"\$nmBul\" .\",-|-\". \"\$bl\".\"-|-\");[/system script set comm\
    ent=\"\$toPBc\" RekapPendapatan];[/system script set source=\"\$toPB\" Rek\
    apPendapatan];[/system script set source=\"0\" ReportPendapatan];[/system \
    sch re ResetReportPendapatan];[/undo];[/system scr re ResetReportPendapata\
    n];[/undo]} else={if (\$bl = \"nov\") do={:set \$bl \"Oct\";:local pend [/\
    system script get ReportPendapatan source];:local pendBul [/system script \
    get RekapPendapatan source];:local nmBul [/system script get RekapPendapat\
    an comment];:local toPB (\"\$pendBul\" .\",\". \"\$pend\");:local toPBc (\
    \"\$nmBul\" .\",-|-\". \"\$bl\".\"-|-\");[/system script set comment=\"\$t\
    oPBc\" RekapPendapatan];[/system script set source=\"\$toPB\" RekapPendapa\
    tan];[/system script set source=\"0\" ReportPendapatan];[/system sch re Re\
    setReportPendapatan];[/undo];[/system scr re ResetReportPendapatan];[/undo\
    ]} else={if (\$bl = \"dec\") do={:set \$bl \"Nov\";:local pend [/system sc\
    ript get ReportPendapatan source];:local pendBul [/system script get Rekap\
    Pendapatan source];:local nmBul [/system script get RekapPendapatan commen\
    t];:local toPB (\"\$pendBul\" .\",\". \"\$pend\");:local toPBc (\"\$nmBul\
    \" .\",-|-\". \"\$bl\".\"-|-\");[/system script set comment=\"\$toPBc\" Re\
    kapPendapatan];[/system script set source=\"\$toPB\" RekapPendapatan];[/sy\
    stem script set source=\"0\" ReportPendapatan];[/system sch re ResetReport\
    Pendapatan];[/undo];[/system scr re ResetReportPendapatan];[/undo]}}}}}}}}\
    }}}}}"
add comment=mikhmon name="aug/21/2019-|-13:04:19-|-user1-|-3000-|-192.168.12.4\
    1-|-A4:D9:90:37:57:51-|-1d-|-1hari-|-" owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/21/2019
add comment=mikhmon name="aug/21/2019-|-17:22:23-|-CJNBS-|-15000-|-192.168.12.\
    15-|-C0:87:EB:EE:62:DB-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/21/2019
add comment=mikhmon name="aug/22/2019-|-11:33:32-|-AFUWM-|-3000-|-192.168.12.1\
    59-|-38:A4:ED:A1:2E:37-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/22/2019
add comment=mikhmon name="aug/22/2019-|-12:09:49-|-ADJJU-|-3000-|-192.168.12.1\
    3-|-C0:87:EB:5A:BC:3F-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/22/2019
add comment=mikhmon name="aug/22/2019-|-19:08:36-|-BLBXZ-|-5000-|-192.168.12.6\
    1-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/22/2019
add comment=mikhmon name="aug/22/2019-|-19:17:44-|-BWVCG-|-5000-|-192.168.12.7\
    9-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/22/2019
add comment=mikhmon name="aug/22/2019-|-20:44:09-|-BNUZD-|-5000-|-192.168.12.1\
    13-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/22/2019
add comment=mikhmon name="aug/22/2019-|-20:57:18-|-BMCLF-|-5000-|-192.168.12.5\
    9-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/22/2019
add comment=mikhmon name="aug/22/2019-|-22:33:20-|-AUYCB-|-3000-|-192.168.12.2\
    09-|-F0:6D:78:78:4A:70-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/22/2019
add comment=mikhmon name="aug/23/2019-|-12:27:21-|-ADMRS-|-3000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/23/2019
add comment=mikhmon name="aug/23/2019-|-12:33:39-|-BSFYE-|-5000-|-192.168.12.1\
    59-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/23/2019
add comment=mikhmon name="aug/23/2019-|-12:44:56-|-BFHXT-|-5000-|-192.168.12.1\
    3-|-C0:87:EB:5A:BC:3F-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/23/2019
add comment=mikhmon name="aug/23/2019-|-16:32:05-|-BURGE-|-5000-|-192.168.12.1\
    02-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/23/2019
add comment=mikhmon name="aug/23/2019-|-16:58:13-|-ACTPE-|-3000-|-192.168.12.1\
    40-|-D8:16:C1:21:3E:08-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/23/2019
add comment=mikhmon name="aug/23/2019-|-18:58:56-|-BHPLZ-|-5000-|-192.168.12.5\
    3-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/23/2019
add comment=mikhmon name="aug/23/2019-|-22:53:22-|-CNCPG-|-15000-|-192.168.12.\
    77-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/23/2019
add comment=mikhmon name="aug/24/2019-|-13:03:10-|-AJBZA-|-3000-|-192.168.12.3\
    4-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/24/2019
add comment=mikhmon name="aug/24/2019-|-15:20:44-|-BCWZS-|-5000-|-192.168.12.2\
    52-|-D4:A1:48:26:10:2D-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/24/2019
add comment=mikhmon name="aug/24/2019-|-16:26:36-|-BZFEY-|-5000-|-192.168.12.5\
    1-|-08:7F:98:C7:BC:29-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/24/2019
add comment=mikhmon name="aug/24/2019-|-19:01:43-|-BKTBV-|-5000-|-192.168.12.8\
    1-|-0C:A8:A7:B4:5E:7E-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/24/2019
add comment=mikhmon name="aug/24/2019-|-19:28:29-|-BNCMD-|-5000-|-192.168.12.1\
    42-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/24/2019
add comment=mikhmon name="aug/24/2019-|-19:29:02-|-BUURG-|-5000-|-192.168.12.7\
    9-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/24/2019
add comment=mikhmon name="aug/24/2019-|-20:04:11-|-BDJLL-|-5000-|-192.168.12.1\
    40-|-D8:16:C1:21:3E:08-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/24/2019
add comment=mikhmon name="aug/24/2019-|-22:29:25-|-BSYZR-|-5000-|-192.168.12.5\
    9-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/24/2019
add comment=mikhmon name="aug/25/2019-|-09:29:15-|-BCKPK-|-5000-|-192.168.12.1\
    13-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/25/2019
add comment=mikhmon name="aug/25/2019-|-13:07:36-|-AGEFJ-|-3000-|-192.168.12.3\
    4-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/25/2019
add comment=mikhmon name="aug/25/2019-|-16:39:41-|-BSCPZ-|-5000-|-192.168.12.1\
    3-|-C0:87:EB:5A:BC:3F-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/25/2019
add comment=mikhmon name="aug/25/2019-|-19:13:18-|-CETZX-|-15000-|-192.168.12.\
    243-|-C0:87:EB:D5:D4:69-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/25/2019
add comment=mikhmon name="aug/26/2019-|-16:54:10-|-CXDFY-|-15000-|-192.168.12.\
    51-|-08:7F:98:C7:BC:29-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/26/2019
add comment=mikhmon name="aug/26/2019-|-19:15:59-|-AYTNI-|-3000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/26/2019
add comment=mikhmon name="aug/26/2019-|-21:48:09-|-BLGKA-|-5000-|-192.168.12.6\
    1-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/26/2019
add comment=mikhmon name="aug/27/2019-|-01:56:07-|-ANCKP-|-3000-|-192.168.12.1\
    19-|-F0:6D:78:78:4A:70-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/27/2019
add comment=mikhmon name="aug/27/2019-|-08:23:28-|-BVXXE-|-5000-|-192.168.12.5\
    9-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/27/2019
add comment=mikhmon name="aug/27/2019-|-10:11:47-|-AZDMZ-|-3000-|-192.168.12.3\
    8-|-CC:2D:83:82:38:49-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/27/2019
add comment=mikhmon name="aug/27/2019-|-16:07:11-|-ACWCA-|-3000-|-192.168.12.1\
    40-|-D8:16:C1:21:3E:08-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/27/2019
add comment=mikhmon name="aug/27/2019-|-17:24:30-|-BSEEW-|-5000-|-192.168.12.1\
    3-|-C0:87:EB:5A:BC:3F-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/27/2019
add comment=mikhmon name="aug/27/2019-|-17:54:22-|-CVFZJ-|-15000-|-192.168.12.\
    242-|-A4:D9:90:28:BB:33-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/27/2019
add comment=mikhmon name="aug/27/2019-|-17:55:50-|-BFVDV-|-5000-|-192.168.12.5\
    3-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/27/2019
add comment=mikhmon name="aug/27/2019-|-18:22:49-|-BBSPV-|-5000-|-192.168.12.7\
    9-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/27/2019
add comment=mikhmon name="aug/27/2019-|-18:49:56-|-CSZXG-|-15000-|-192.168.12.\
    68-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/27/2019
add comment=mikhmon name="aug/27/2019-|-21:47:51-|-AKKXF-|-3000-|-192.168.12.1\
    9-|-0C:A8:A7:48:10:18-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/27/2019
add comment=mikhmon name="aug/27/2019-|-22:19:21-|-BDBTK-|-5000-|-192.168.12.1\
    14-|-74:29:AF:37:D8:01-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/27/2019
add comment=mikhmon name="aug/28/2019-|-12:18:19-|-AWFKV-|-3000-|-192.168.12.5\
    6-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/28/2019
add comment=mikhmon name="aug/28/2019-|-13:17:07-|-BZBDM-|-5000-|-192.168.12.2\
    52-|-D4:A1:48:26:10:2D-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/28/2019
add comment=mikhmon name="aug/28/2019-|-13:20:01-|-AHGZV-|-3000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/28/2019
add comment=mikhmon name="aug/28/2019-|-18:05:10-|-ATEBZ-|-3000-|-192.168.12.3\
    6-|-3C:95:09:E7:6D:13-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/28/2019
add comment=mikhmon name="aug/28/2019-|-18:06:01-|-AAAMV-|-3000-|-192.168.12.6\
    0-|-08:7F:98:E1:84:ED-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/28/2019
add comment=mikhmon name="aug/28/2019-|-19:03:19-|-BHGTB-|-5000-|-192.168.12.1\
    42-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/28/2019
add comment=mikhmon name="aug/28/2019-|-22:23:04-|-BJGUJ-|-5000-|-192.168.12.1\
    65-|-C4:0B:CB:E3:2B:3C-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/28/2019
add comment=mikhmon name="aug/29/2019-|-07:06:09-|-BUJDC-|-5000-|-192.168.12.1\
    05-|-58:44:98:BA:56:06-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/29/2019
add comment=mikhmon name="aug/29/2019-|-10:24:40-|-AVPFM-|-3000-|-192.168.12.1\
    14-|-74:29:AF:37:D8:01-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/29/2019
add comment=mikhmon name="aug/29/2019-|-18:26:40-|-CDVBJ-|-15000-|-192.168.12.\
    94-|-EC:D0:9F:CB:40:07-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/29/2019
add comment=mikhmon name="aug/29/2019-|-19:07:57-|-CFLRP-|-15000-|-192.168.12.\
    15-|-C0:87:EB:EE:62:DB-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/29/2019
add comment=mikhmon name="aug/29/2019-|-19:12:39-|-BVWNX-|-5000-|-192.168.12.6\
    1-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/29/2019
add comment=mikhmon name="aug/29/2019-|-19:49:28-|-BHJNE-|-5000-|-192.168.12.7\
    9-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/29/2019
add comment=mikhmon name="aug/29/2019-|-19:56:21-|-AKAKM-|-3000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/29/2019
add comment=mikhmon name="aug/29/2019-|-20:09:18-|-BRVFR-|-5000-|-192.168.12.1\
    22-|-20:5E:F7:E8:78:B2-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/29/2019
add comment=mikhmon name="aug/30/2019-|-15:01:30-|-AGKHH-|-3000-|-192.168.12.2\
    39-|-70:5E:55:A6:F8:99-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/30/2019
add comment=mikhmon name="aug/30/2019-|-17:53:00-|-AJMDH-|-3000-|-192.168.12.5\
    3-|-F4:60:E2:30:CF:98-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/30/2019
add comment=mikhmon name="aug/30/2019-|-18:48:08-|-AHNAN-|-3000-|-192.168.12.8\
    1-|-0C:A8:A7:B4:5E:7E-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/30/2019
add comment=mikhmon name="aug/30/2019-|-20:47:07-|-BBUNC-|-5000-|-192.168.12.1\
    3-|-C0:87:EB:5A:BC:3F-|-2d-|-2hari-|-up-557-08.13.19-2hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/30/2019
add comment=mikhmon name="aug/30/2019-|-22:54:30-|-ARVSN-|-3000-|-192.168.12.1\
    14-|-74:29:AF:37:D8:01-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/30/2019
add comment=mikhmon name="aug/31/2019-|-07:12:00-|-AZHDN-|-3000-|-192.168.12.6\
    0-|-08:7F:98:E1:84:ED-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/31/2019
add comment=mikhmon name="aug/31/2019-|-07:29:00-|-AESMD-|-3000-|-192.168.12.2\
    10-|-18:F0:E4:6C:02:34-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/31/2019
add comment=mikhmon name="aug/31/2019-|-08:09:08-|-AYRJR-|-3000-|-192.168.12.1\
    18-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/31/2019
add comment=mikhmon name="aug/31/2019-|-11:59:03-|-BVIMX-|-5000-|-192.168.12.2\
    53-|-7C:03:5E:C9:04:FB-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/31/2019
add comment=mikhmon name="aug/31/2019-|-18:13:49-|-AWHPR-|-3000-|-192.168.12.5\
    3-|-F4:60:E2:30:CF:98-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/31/2019
add comment=mikhmon name="aug/31/2019-|-19:05:28-|-AMZNZ-|-3000-|-192.168.12.1\
    42-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/31/2019
add comment=mikhmon name="aug/31/2019-|-19:44:50-|-ASWFT-|-3000-|-192.168.12.8\
    1-|-0C:A8:A7:B4:5E:7E-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/31/2019
add comment=mikhmon name="aug/31/2019-|-19:54:09-|-ADWMF-|-3000-|-192.168.12.7\
    9-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/31/2019
add comment=mikhmon name="aug/31/2019-|-20:37:46-|-AVTPP-|-3000-|-192.168.12.7\
    0-|-0C:98:38:6A:6A:51-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/31/2019
add comment=mikhmon name="aug/31/2019-|-21:39:10-|-CJXUD-|-15000-|-192.168.12.\
    77-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/31/2019
add comment=mikhmon name="aug/31/2019-|-21:41:32-|-AINCU-|-3000-|-192.168.12.2\
    39-|-70:5E:55:A6:F8:99-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=aug2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    aug/31/2019
add comment=mikhmon name="sep/10/2019-|-11:47:48-|-BXRXP-|-5000-|-192.168.12.1\
    42-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/10/2019
add comment=mikhmon name="sep/10/2019-|-12:53:27-|-BXDWX-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/10/2019
add comment=mikhmon name="sep/10/2019-|-16:01:29-|-BGWMI-|-5000-|-192.168.12.1\
    56-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/10/2019
add comment=mikhmon name="sep/10/2019-|-21:29:28-|-BCGDU-|-5000-|-192.168.12.5\
    6-|-F0:6D:78:78:4A:70-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/10/2019
add comment=mikhmon name="sep/11/2019-|-16:38:52-|-BAXMC-|-5000-|-192.168.12.2\
    33-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/11/2019
add comment=mikhmon name="sep/11/2019-|-17:04:31-|-CYKBH-|-15000-|-192.168.12.\
    68-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/11/2019
add comment=mikhmon name="sep/11/2019-|-17:16:12-|-AERIF-|-3000-|-192.168.12.4\
    5-|-3C:95:09:E7:6D:13-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/11/2019
add comment=mikhmon name="sep/11/2019-|-17:50:51-|-BSTZN-|-5000-|-192.168.12.5\
    3-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/11/2019
add comment=mikhmon name="sep/11/2019-|-17:54:05-|-BSHEW-|-5000-|-192.168.12.1\
    76-|-58:44:98:BA:56:06-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/11/2019
add comment=mikhmon name="sep/11/2019-|-17:57:34-|-CZVTW-|-15000-|-192.168.12.\
    51-|-08:7F:98:C7:BC:29-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/11/2019
add comment=mikhmon name="sep/11/2019-|-18:56:24-|-AKMNE-|-3000-|-192.168.12.1\
    3-|-C0:87:EB:5A:BC:3F-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/11/2019
add comment=mikhmon name="sep/11/2019-|-19:01:35-|-AYCEJ-|-3000-|-192.168.12.2\
    39-|-70:5E:55:A6:F8:99-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/11/2019
add comment=mikhmon name="sep/11/2019-|-19:26:14-|-BFDEB-|-5000-|-192.168.12.1\
    96-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/11/2019
add comment=mikhmon name="sep/11/2019-|-20:03:40-|-AYHJU-|-3000-|-192.168.12.5\
    5-|-08:EE:8B:F5:DA:26-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/11/2019
add comment=mikhmon name="sep/11/2019-|-20:10:09-|-AEKMH-|-3000-|-192.168.12.1\
    80-|-00:0A:F5:C2:FC:7C-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/11/2019
add comment=mikhmon name="sep/12/2019-|-05:30:36-|-Aziz-|-3000-|-192.168.12.20\
    1-|-68:05:71:EA:EF:29-|-1d-|-1hari-|-up-" owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/12/2019
add comment=mikhmon name="sep/12/2019-|-06:41:45-|-BADDB-|-5000-|-192.168.12.2\
    03-|-10:2A:B3:49:D9:BB-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/12/2019
add comment=mikhmon name="sep/12/2019-|-08:31:56-|-AIZWA-|-3000-|-192.168.12.6\
    1-|-0C:98:38:1D:99:0B-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/12/2019
add comment=mikhmon name="sep/12/2019-|-11:58:13-|-AERMG-|-3000-|-192.168.12.1\
    60-|-7C:03:5E:C9:04:FB-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/12/2019
add comment=mikhmon name="sep/12/2019-|-13:50:54-|-BZARK-|-5000-|-192.168.12.7\
    9-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/12/2019
add comment=mikhmon name="sep/12/2019-|-19:10:24-|-AGBFA-|-3000-|-192.168.12.1\
    3-|-C0:87:EB:5A:BC:3F-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/12/2019
add comment=mikhmon name="sep/12/2019-|-19:23:57-|-ARNVH-|-3000-|-192.168.12.2\
    39-|-70:5E:55:A6:F8:99-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/12/2019
add comment=mikhmon name="sep/12/2019-|-20:11:55-|-CRBSE-|-15000-|-192.168.12.\
    121-|-08:8C:2C:02:A3:A3-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/12/2019
add comment=mikhmon name="sep/12/2019-|-23:32:24-|-BFEAK-|-5000-|-192.168.12.1\
    59-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/12/2019
add comment=mikhmon name="sep/13/2019-|-05:44:47-|-BRMAJ-|-5000-|-192.168.12.2\
    43-|-48:88:CA:0B:65:02-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/13/2019
add comment=mikhmon name="sep/13/2019-|-11:06:11-|-BJKRC-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/13/2019
add comment=mikhmon name="sep/13/2019-|-11:59:51-|-AGFTE-|-3000-|-192.168.12.2\
    54-|-F4:F5:DB:10:02:37-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/13/2019
add comment=mikhmon name="sep/13/2019-|-17:09:11-|-BNGHZ-|-5000-|-192.168.12.2\
    33-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/13/2019
add comment=mikhmon name="sep/13/2019-|-19:40:42-|-BCBRW-|-5000-|-192.168.12.9\
    6-|-C0:87:EB:35:15:4B-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/13/2019
add comment=mikhmon name="sep/13/2019-|-19:41:33-|-BKEIA-|-5000-|-192.168.12.1\
    56-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/13/2019
add comment=mikhmon name="sep/13/2019-|-20:36:04-|-BNCDM-|-5000-|-192.168.12.2\
    39-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/13/2019
add comment=mikhmon name="sep/13/2019-|-20:57:58-|-AFDMA-|-3000-|-192.168.12.1\
    3-|-C0:87:EB:5A:BC:3F-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/13/2019
add comment=mikhmon name="sep/13/2019-|-20:58:25-|-BXMNM-|-5000-|-192.168.12.1\
    96-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/13/2019
add comment=mikhmon name="sep/13/2019-|-20:59:10-|-ARMCZ-|-3000-|-192.168.12.8\
    6-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/13/2019
add comment=mikhmon name="sep/14/2019-|-11:51:00-|-BVRJK-|-5000-|-192.168.12.1\
    6-|-08:7F:98:B0:5B:A1-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/14/2019
add comment=mikhmon name="sep/14/2019-|-14:03:33-|-BEZFW-|-5000-|-192.168.12.7\
    9-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/14/2019
add comment=mikhmon name="sep/14/2019-|-16:30:30-|-ABEYA-|-3000-|-192.168.12.5\
    5-|-08:EE:8B:F5:DA:26-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/14/2019
add comment=mikhmon name="sep/14/2019-|-16:54:35-|-BYSDE-|-5000-|-192.168.12.1\
    60-|-7C:03:5E:C9:04:FB-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/14/2019
add comment=mikhmon name="sep/14/2019-|-19:00:49-|-ANMWG-|-3000-|-192.168.12.1\
    14-|-60:72:8D:62:53:EB-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/14/2019
add comment=mikhmon name="sep/14/2019-|-19:03:24-|-AMIJW-|-3000-|-192.168.12.1\
    16-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/14/2019
add comment=mikhmon name="sep/14/2019-|-19:39:59-|-BTGYU-|-5000-|-192.168.12.6\
    1-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/14/2019
add comment=mikhmon name="sep/15/2019-|-04:55:14-|-ABZTU-|-3000-|-192.168.12.1\
    42-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/15/2019
add comment=mikhmon name="sep/15/2019-|-09:29:06-|-AWKYT-|-3000-|-192.168.12.1\
    94-|-0C:A8:A7:48:10:18-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/15/2019
add comment=mikhmon name="sep/15/2019-|-12:38:41-|-BUZRX-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/15/2019
add comment=mikhmon name="sep/15/2019-|-15:39:45-|-BZGDG-|-5000-|-192.168.12.1\
    3-|-C0:87:EB:5A:BC:3F-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/15/2019
add comment=mikhmon name="sep/15/2019-|-16:18:21-|-BRIHX-|-5000-|-192.168.12.8\
    6-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/15/2019
add comment=mikhmon name="sep/15/2019-|-18:08:20-|-BWRAU-|-5000-|-192.168.12.5\
    3-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/15/2019
add comment=mikhmon name="sep/15/2019-|-20:36:57-|-BJZXY-|-5000-|-192.168.12.5\
    5-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/15/2019
add comment=mikhmon name="sep/15/2019-|-22:41:36-|-BXCAR-|-5000-|-192.168.12.1\
    66-|-74:29:AF:37:D8:01-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/15/2019
add comment=mikhmon name="sep/16/2019-|-12:48:53-|-ANZJX-|-3000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/16/2019
add comment=mikhmon name="sep/16/2019-|-18:03:21-|-BKKEI-|-5000-|-192.168.12.2\
    33-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/16/2019
add comment=mikhmon name="sep/16/2019-|-19:27:12-|-BPKJI-|-5000-|-192.168.12.7\
    9-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/16/2019
add comment=mikhmon name="sep/16/2019-|-20:04:56-|-BBYJY-|-5000-|-192.168.12.1\
    96-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/16/2019
add comment=mikhmon name="sep/16/2019-|-21:38:07-|-AVYZH-|-3000-|-192.168.12.1\
    9-|-0C:A8:A7:48:10:18-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/16/2019
add comment=mikhmon name="sep/17/2019-|-01:50:16-|-BRBGG-|-5000-|-192.168.12.2\
    00-|-C4:0B:CB:E3:2B:3C-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/17/2019
add comment=mikhmon name="sep/17/2019-|-07:37:05-|-BGFJF-|-5000-|-192.168.12.1\
    3-|-C0:87:EB:5A:BC:3F-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/17/2019
add comment=mikhmon name="sep/17/2019-|-09:40:22-|-CYFNG-|-15000-|-192.168.12.\
    242-|-A4:D9:90:28:BB:33-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/17/2019
add comment=mikhmon name="sep/17/2019-|-14:48:55-|-BIBSX-|-5000-|-192.168.12.2\
    53-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/17/2019
add comment=mikhmon name="sep/17/2019-|-16:43:38-|-BYKGJ-|-5000-|-192.168.12.7\
    5-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/17/2019
add comment=mikhmon name="sep/17/2019-|-17:28:14-|-AIHJK-|-3000-|-192.168.12.8\
    6-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/17/2019
add comment=mikhmon name="sep/17/2019-|-18:16:08-|-ADGTK-|-3000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/17/2019
add comment=mikhmon name="sep/17/2019-|-18:40:13-|-BBACS-|-5000-|-192.168.12.1\
    56-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/17/2019
add comment=mikhmon name="sep/17/2019-|-18:40:17-|-ASCSH-|-3000-|-192.168.12.8\
    5-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/17/2019
add comment=mikhmon name="sep/17/2019-|-18:55:44-|-BXUCR-|-5000-|-192.168.12.8\
    8-|-E0:06:E6:79:95:19-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/17/2019
add comment=mikhmon name="sep/17/2019-|-19:17:49-|-AHUFX-|-3000-|-192.168.12.1\
    42-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/17/2019
add comment=mikhmon name="sep/17/2019-|-19:37:16-|-BYZHW-|-5000-|-192.168.12.5\
    4-|-90:94:97:72:FD:B7-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/17/2019
add comment=mikhmon name="sep/17/2019-|-21:36:15-|-CLEYL-|-15000-|-192.168.12.\
    77-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/17/2019
add comment=mikhmon name="sep/17/2019-|-21:38:22-|-BZPIG-|-5000-|-192.168.12.1\
    66-|-74:29:AF:37:D8:01-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/17/2019
add comment=mikhmon name="sep/17/2019-|-21:59:39-|-BHHAD-|-5000-|-192.168.12.1\
    9-|-0C:A8:A7:48:10:18-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/17/2019
add comment=mikhmon name="sep/18/2019-|-11:37:47-|-BWACA-|-5000-|-192.168.12.1\
    31-|-F4:F5:DB:10:02:37-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/18/2019
add comment=mikhmon name="sep/18/2019-|-17:25:25-|-CKFAA-|-15000-|-192.168.12.\
    68-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/18/2019
add comment=mikhmon name="sep/18/2019-|-17:40:07-|-BUEHH-|-5000-|-192.168.12.2\
    7-|-CC:2D:83:A7:D7:0D-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/18/2019
add comment=mikhmon name="sep/18/2019-|-17:56:40-|-AIHCE-|-3000-|-192.168.12.1\
    62-|-1C:7B:21:A5:C5:93-|-1d-|-1hari-|-up-584-07.17.19-17juli" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/18/2019
add comment=mikhmon name="sep/18/2019-|-18:21:07-|-BTBJY-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/18/2019
add comment=mikhmon name="sep/18/2019-|-19:00:52-|-BFIJJ-|-5000-|-192.168.12.8\
    6-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/18/2019
add comment=mikhmon name="sep/18/2019-|-19:16:36-|-AECJY-|-3000-|-192.168.12.1\
    73-|-CC:2D:83:90:04:D7-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/18/2019
add comment=mikhmon name="sep/18/2019-|-19:20:12-|-BTRGV-|-5000-|-192.168.12.5\
    3-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/18/2019
add comment=mikhmon name="sep/19/2019-|-14:02:35-|-BXFSG-|-5000-|-192.168.12.7\
    9-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/19/2019
add comment=mikhmon name="sep/19/2019-|-16:20:27-|-CXXEE-|-15000-|-192.168.12.\
    51-|-08:7F:98:C7:BC:29-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/19/2019
add comment=mikhmon name="sep/19/2019-|-18:35:49-|-BJKWM-|-5000-|-192.168.12.2\
    33-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/19/2019
add comment=mikhmon name="sep/19/2019-|-19:03:33-|-BVDMW-|-5000-|-192.168.12.7\
    5-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/19/2019
add comment=mikhmon name="sep/19/2019-|-19:19:01-|-BFBIV-|-5000-|-192.168.12.1\
    96-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/19/2019
add comment=mikhmon name="sep/19/2019-|-21:58:36-|-BMIHG-|-5000-|-192.168.12.1\
    66-|-74:29:AF:37:D8:01-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/19/2019
add comment=mikhmon name="sep/20/2019-|-12:13:29-|-AEDYR-|-3000-|-192.168.12.1\
    7-|-60:72:8D:62:53:EB-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/20/2019
add comment=mikhmon name="sep/20/2019-|-13:04:30-|-AMFNV-|-3000-|-192.168.12.1\
    3-|-C0:87:EB:5A:BC:3F-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/20/2019
add comment=mikhmon name="sep/20/2019-|-18:24:57-|-BVVRW-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/20/2019
add comment=mikhmon name="sep/20/2019-|-18:41:41-|-CZBJR-|-15000-|-192.168.12.\
    77-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/20/2019
add comment=mikhmon name="sep/20/2019-|-18:53:25-|-AMNVT-|-3000-|-192.168.12.1\
    42-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/20/2019
add comment=mikhmon name="sep/20/2019-|-18:56:11-|-AFIMX-|-3000-|-192.168.12.1\
    0-|-08:7F:98:E1:84:ED-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/20/2019
add comment=mikhmon name="sep/20/2019-|-19:19:11-|-BSJNB-|-5000-|-192.168.12.1\
    56-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/20/2019
add comment=mikhmon name="sep/20/2019-|-19:37:23-|-BVXWC-|-5000-|-192.168.12.8\
    6-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/20/2019
add comment=mikhmon name="sep/20/2019-|-23:21:13-|-ANYGW-|-3000-|-192.168.12.1\
    92-|-0C:98:38:94:60:51-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/20/2019
add comment=mikhmon name="sep/20/2019-|-23:22:54-|-ADFTS-|-3000-|-192.168.12.5\
    5-|-08:EE:8B:F5:DA:26-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/20/2019
add comment=mikhmon name="sep/20/2019-|-23:26:46-|-AKBMI-|-3000-|-192.168.12.2\
    30-|-34:31:11:F9:B8:12-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/20/2019
add comment=mikhmon name="sep/21/2019-|-12:54:11-|-BEXXR-|-5000-|-192.168.12.1\
    9-|-0C:A8:A7:48:10:18-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/21/2019
add comment=mikhmon name="sep/21/2019-|-13:21:25-|-BSYGZ-|-5000-|-192.168.12.2\
    13-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/21/2019
add comment=mikhmon name="sep/21/2019-|-15:02:27-|-BVDIU-|-5000-|-192.168.12.7\
    9-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/21/2019
add comment=mikhmon name="sep/21/2019-|-16:39:52-|-BMEJI-|-5000-|-192.168.12.5\
    3-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/21/2019
add comment=mikhmon name="sep/21/2019-|-18:03:11-|-APXHJ-|-3000-|-192.168.12.2\
    33-|-1C:87:2C:3F:F5:68-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/21/2019
add comment=mikhmon name="sep/21/2019-|-19:36:31-|-BFXDH-|-5000-|-192.168.12.1\
    96-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/21/2019
add comment=mikhmon name="sep/21/2019-|-23:21:08-|-BPVGI-|-5000-|-192.168.12.2\
    39-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/21/2019
add comment=mikhmon name="sep/21/2019-|-23:24:40-|-BEEGS-|-5000-|-192.168.12.1\
    92-|-0C:98:38:94:60:51-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/21/2019
add comment=mikhmon name="sep/22/2019-|-10:13:38-|-AWHKP-|-3000-|-192.168.12.5\
    5-|-08:EE:8B:F5:DA:26-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/22/2019
add comment=mikhmon name="sep/22/2019-|-15:39:06-|-AXGHN-|-3000-|-192.168.12.1\
    15-|-C0:87:EB:5A:BC:3F-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/22/2019
add comment=mikhmon name="sep/22/2019-|-19:09:39-|-BHFEX-|-5000-|-192.168.12.9\
    6-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/22/2019
add comment=mikhmon name="sep/22/2019-|-19:28:38-|-AGYDR-|-3000-|-192.168.12.1\
    5-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/22/2019
add comment=mikhmon name="sep/22/2019-|-19:52:53-|-AHDYF-|-3000-|-192.168.12.1\
    84-|-00:0A:F5:4E:69:4C-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/22/2019
add comment=mikhmon name="sep/22/2019-|-20:13:32-|-BSVJY-|-5000-|-192.168.12.1\
    90-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/22/2019
add comment=mikhmon name="sep/23/2019-|-13:25:32-|-AVARE-|-3000-|-192.168.12.3\
    9-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/23/2019
add comment=mikhmon name="sep/23/2019-|-13:45:56-|-BEKWV-|-5000-|-192.168.12.1\
    01-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/23/2019
add comment=mikhmon name="sep/23/2019-|-15:53:42-|-BPKXH-|-5000-|-192.168.12.3\
    5-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/23/2019
add comment=mikhmon name="sep/23/2019-|-17:43:54-|-CXWXH-|-15000-|-192.168.12.\
    206-|-08:8C:2C:02:A3:A3-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/23/2019
add comment=mikhmon name="sep/23/2019-|-19:07:39-|-AKGVV-|-3000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/23/2019
add comment=mikhmon name="sep/23/2019-|-20:17:11-|-BZNWK-|-5000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/23/2019
add comment=mikhmon name="sep/23/2019-|-20:49:54-|-BPTDK-|-5000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/23/2019
add comment=mikhmon name="sep/23/2019-|-21:03:23-|-BXCDS-|-5000-|-192.168.12.4\
    0-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/23/2019
add comment=mikhmon name="sep/23/2019-|-21:06:48-|-AJACR-|-3000-|-192.168.12.1\
    15-|-C0:87:EB:5A:BC:3F-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/23/2019
add comment=mikhmon name="sep/23/2019-|-23:24:28-|-BYBXP-|-5000-|-192.168.12.1\
    34-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/23/2019
add comment=mikhmon name="sep/24/2019-|-00:35:50-|-BMWEK-|-5000-|-192.168.12.5\
    9-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/24/2019
add comment=mikhmon name="sep/24/2019-|-10:41:20-|-BGBJD-|-5000-|-192.168.12.2\
    7-|-CC:2D:83:A7:D7:0D-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/24/2019
add comment=mikhmon name="sep/24/2019-|-12:37:29-|-AZXNK-|-3000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/24/2019
add comment=mikhmon name="sep/24/2019-|-12:53:27-|-ANCDX-|-3000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/24/2019
add comment=mikhmon name="sep/24/2019-|-17:53:34-|-AFRFB-|-3000-|-192.168.12.1\
    5-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/24/2019
add comment=mikhmon name="sep/24/2019-|-19:58:19-|-BFJNI-|-5000-|-192.168.12.1\
    90-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/24/2019
add comment=mikhmon name="sep/24/2019-|-21:59:25-|-AJVTX-|-3000-|-192.168.12.1\
    19-|-6C:D7:1F:23:3C:79-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/24/2019
add comment=mikhmon name="sep/25/2019-|-11:28:52-|-BVBWB-|-5000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/25/2019
add comment=mikhmon name="sep/25/2019-|-12:43:32-|-BKMJR-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/25/2019
add comment=mikhmon name="sep/25/2019-|-13:14:01-|-BUERX-|-5000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/25/2019
add comment=mikhmon name="sep/25/2019-|-13:55:48-|-CUPHL-|-15000-|-192.168.12.\
    84-|-A4:D9:90:28:BB:33-|-7d-|-7hari-|-up-749-08.13.19-7hr130819" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/25/2019
add comment=mikhmon name="sep/25/2019-|-14:45:18-|-BRRIM-|-5000-|-192.168.12.1\
    01-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/25/2019
add comment=mikhmon name="sep/25/2019-|-18:36:41-|-CEJKV-|-15000-|-192.168.12.\
    4-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/25/2019
add comment=mikhmon name="sep/25/2019-|-18:38:12-|-BJWJV-|-5000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/25/2019
add comment=mikhmon name="sep/25/2019-|-22:21:32-|-BFPRS-|-5000-|-192.168.12.9\
    6-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/25/2019
add comment=mikhmon name="sep/26/2019-|-00:56:40-|-BNHIT-|-5000-|-192.168.12.5\
    9-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/26/2019
add comment=mikhmon name="sep/26/2019-|-07:03:12-|-AKYYY-|-3000-|-192.168.12.1\
    15-|-C0:87:EB:5A:BC:3F-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/26/2019
add comment=mikhmon name="sep/26/2019-|-10:23:59-|-BDFTG-|-5000-|-192.168.12.1\
    34-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/26/2019
add comment=mikhmon name="sep/26/2019-|-12:00:22-|-BFRFU-|-5000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/26/2019
add comment=mikhmon name="sep/26/2019-|-14:41:45-|-ADFMD-|-3000-|-192.168.12.1\
    19-|-6C:D7:1F:23:3C:79-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/26/2019
add comment=mikhmon name="sep/26/2019-|-17:10:21-|-BHADB-|-5000-|-192.168.12.1\
    39-|-08:7F:98:C7:BC:29-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/26/2019
add comment=mikhmon name="sep/26/2019-|-17:50:14-|-BAHFI-|-5000-|-192.168.12.4\
    0-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/26/2019
add comment=mikhmon name="sep/26/2019-|-18:13:53-|-BNJTB-|-5000-|-192.168.12.1\
    90-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/26/2019
add comment=mikhmon name="sep/26/2019-|-18:36:14-|-AYAST-|-3000-|-192.168.12.3\
    9-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/26/2019
add comment=mikhmon name="sep/27/2019-|-06:31:41-|-AXVUX-|-3000-|-192.168.12.2\
    28-|-0C:98:38:94:60:51-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/27/2019
add comment=mikhmon name="sep/27/2019-|-09:24:18-|-ARRWZ-|-3000-|-192.168.12.5\
    0-|-08:7F:98:E1:84:ED-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/27/2019
add comment=mikhmon name="sep/27/2019-|-12:42:33-|-BUCPF-|-5000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/27/2019
add comment=mikhmon name="sep/27/2019-|-18:39:41-|-BSHBV-|-5000-|-192.168.12.3\
    9-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/27/2019
add comment=mikhmon name="sep/27/2019-|-18:56:30-|-AUFKS-|-3000-|-192.168.12.1\
    5-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/27/2019
add comment=mikhmon name="sep/27/2019-|-19:12:38-|-BUXUU-|-5000-|-192.168.12.1\
    19-|-6C:D7:1F:23:3C:79-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/27/2019
add comment=mikhmon name="sep/27/2019-|-20:24:37-|-ATTDK-|-3000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/27/2019
add comment=mikhmon name="sep/27/2019-|-21:34:13-|-ARIEL-|-15000-|-192.168.12.\
    42-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-" owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/27/2019
add comment=mikhmon name="sep/28/2019-|-12:22:57-|-BBBUA-|-5000-|-192.168.12.3\
    5-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/28/2019
add comment=mikhmon name="sep/28/2019-|-12:30:39-|-BVJJM-|-5000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/28/2019
add comment=mikhmon name="sep/28/2019-|-14:38:53-|-BUBVT-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/28/2019
add comment=mikhmon name="sep/28/2019-|-17:45:33-|-AAYVB-|-3000-|-192.168.12.1\
    26-|-60:72:8D:62:53:EB-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/28/2019
add comment=mikhmon name="sep/28/2019-|-18:30:35-|-BIWDZ-|-5000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/28/2019
add comment=mikhmon name="sep/28/2019-|-18:54:12-|-BRUAD-|-5000-|-192.168.12.7\
    6-|-C0:87:EB:35:15:4B-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/28/2019
add comment=mikhmon name="sep/28/2019-|-19:02:17-|-BIMUA-|-5000-|-192.168.12.1\
    90-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/28/2019
add comment=mikhmon name="sep/28/2019-|-19:11:34-|-BMSWY-|-5000-|-192.168.12.1\
    01-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/28/2019
add comment=mikhmon name="sep/28/2019-|-19:20:27-|-BIDJZ-|-5000-|-192.168.12.1\
    34-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/28/2019
add comment=mikhmon name="sep/28/2019-|-20:59:11-|-AIEWZ-|-3000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/28/2019
add comment=mikhmon name="sep/28/2019-|-21:32:25-|-AYAHD-|-3000-|-192.168.12.1\
    39-|-08:7F:98:C7:BC:29-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/28/2019
add comment=mikhmon name="sep/28/2019-|-21:51:27-|-ANXNR-|-3000-|-192.168.12.1\
    28-|-08:7F:98:E1:84:ED-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/28/2019
add comment=mikhmon name="sep/28/2019-|-21:51:54-|-AFHMC-|-3000-|-192.168.12.1\
    92-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/28/2019
add comment=mikhmon name="sep/29/2019-|-09:38:10-|-AHHXY-|-3000-|-192.168.12.2\
    41-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/29/2019
add comment=mikhmon name="sep/29/2019-|-10:38:41-|-BARGZ-|-5000-|-192.168.12.5\
    9-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/29/2019
add comment=mikhmon name="sep/29/2019-|-12:59:11-|-AKSFR-|-3000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/29/2019
add comment=mikhmon name="sep/29/2019-|-13:33:52-|-AXTFE-|-3000-|-192.168.12.1\
    5-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/29/2019
add comment=mikhmon name="sep/29/2019-|-13:39:35-|-BFCSF-|-5000-|-192.168.12.6\
    9-|-68:05:71:EA:EF:29-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/29/2019
add comment=mikhmon name="sep/29/2019-|-18:15:26-|-AGEPD-|-3000-|-192.168.12.1\
    26-|-60:72:8D:62:53:EB-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/29/2019
add comment=mikhmon name="sep/29/2019-|-18:55:47-|-BHWGD-|-5000-|-192.168.12.3\
    9-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/29/2019
add comment=mikhmon name="sep/29/2019-|-19:16:15-|-ABZFT-|-3000-|-192.168.12.1\
    06-|-00:0A:F5:4E:69:4C-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/29/2019
add comment=mikhmon name="sep/29/2019-|-19:38:40-|-BDPRR-|-5000-|-192.168.12.9\
    6-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/29/2019
add comment=mikhmon name="sep/29/2019-|-21:35:06-|-AZTNF-|-3000-|-192.168.12.1\
    39-|-08:7F:98:C7:BC:29-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/29/2019
add comment=mikhmon name="sep/30/2019-|-16:42:13-|-AYUCX-|-3000-|-192.168.12.3\
    5-|-2C:56:DC:E7:15:E1-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/30/2019
add comment=mikhmon name="sep/30/2019-|-17:05:44-|-BZAJB-|-5000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/30/2019
add comment=mikhmon name="sep/30/2019-|-18:46:06-|-AXFZC-|-3000-|-192.168.12.1\
    5-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-434-08.27.19-1hari27Agustus" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/30/2019
add comment=mikhmon name="sep/30/2019-|-18:58:04-|-BJMNV-|-5000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/30/2019
add comment=mikhmon name="sep/30/2019-|-19:00:50-|-BIGXF-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/30/2019
add comment=mikhmon name="sep/30/2019-|-19:43:13-|-BWHUR-|-5000-|-192.168.12.1\
    92-|-6C:D7:1F:27:2E:83-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/30/2019
add comment=mikhmon name="sep/30/2019-|-19:45:18-|-AJTYI-|-3000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/30/2019
add comment=mikhmon name="sep/30/2019-|-20:08:15-|-BVARV-|-5000-|-192.168.12.1\
    34-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=sep2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    sep/30/2019
add comment=mikhmon name="oct/01/2019-|-11:55:28-|-BNPMR-|-5000-|-192.168.12.5\
    9-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/01/2019
add comment=mikhmon name="oct/01/2019-|-14:59:30-|-BGPZS-|-5000-|-192.168.12.3\
    5-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/01/2019
add comment=mikhmon name="oct/01/2019-|-16:00:51-|-BUTJV-|-5000-|-192.168.12.1\
    39-|-08:7F:98:C7:BC:29-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/01/2019
add comment=mikhmon name="oct/01/2019-|-17:52:33-|-BKSYS-|-5000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/01/2019
add comment=mikhmon name="oct/01/2019-|-19:28:15-|-BZYBX-|-5000-|-192.168.12.1\
    01-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/01/2019
add comment=mikhmon name="oct/01/2019-|-20:14:21-|-BVNVP-|-5000-|-192.168.12.2\
    21-|-30:CB:F8:E0:09:43-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/01/2019
add comment=mikhmon name="oct/01/2019-|-20:19:24-|-BHNWR-|-5000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/01/2019
add comment=mikhmon name="oct/01/2019-|-22:32:38-|-BNJWC-|-5000-|-192.168.12.3\
    6-|-C4:0B:CB:E3:2B:3C-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/01/2019
add comment=mikhmon name="oct/02/2019-|-01:05:37-|-BVBIC-|-5000-|-192.168.12.3\
    9-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/02/2019
add comment=mikhmon name="oct/02/2019-|-14:36:15-|-BCRJS-|-5000-|-192.168.12.1\
    5-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/02/2019
add comment=mikhmon name="oct/02/2019-|-16:05:03-|-BYWIS-|-5000-|-192.168.12.8\
    8-|-24:79:F3:52:26:EB-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/02/2019
add comment=mikhmon name="oct/02/2019-|-16:37:16-|-BEPSM-|-5000-|-192.168.12.1\
    26-|-60:72:8D:62:53:EB-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/02/2019
add comment=mikhmon name="oct/02/2019-|-18:33:41-|-CURUM-|-15000-|-192.168.12.\
    84-|-A4:D9:90:28:BB:33-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/02/2019
add comment=mikhmon name="oct/02/2019-|-19:46:33-|-ADCCE-|-3000-|-192.168.12.1\
    92-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/02/2019
add comment=mikhmon name="oct/02/2019-|-22:24:14-|-BPVKU-|-5000-|-192.168.12.1\
    34-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/02/2019
add comment=mikhmon name="oct/03/2019-|-06:25:00-|-BGEXG-|-5000-|-192.168.12.6\
    7-|-80:AD:16:76:6E:5E-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/03/2019
add comment=mikhmon name="oct/03/2019-|-07:50:39-|-AJXZH-|-3000-|-192.168.12.2\
    54-|-74:23:44:5C:38:28-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/03/2019
add comment=mikhmon name="oct/03/2019-|-08:51:26-|-CSPXV-|-15000-|-192.168.12.\
    4-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/03/2019
add comment=mikhmon name="oct/03/2019-|-11:08:03-|-BGUWP-|-5000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/03/2019
add comment=mikhmon name="oct/03/2019-|-11:51:52-|-BUPBT-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/03/2019
add comment=mikhmon name="oct/03/2019-|-14:18:37-|-BRKDB-|-5000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/03/2019
add comment=mikhmon name="oct/03/2019-|-15:03:12-|-BRIKY-|-5000-|-192.168.12.3\
    5-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/03/2019
add comment=mikhmon name="oct/03/2019-|-17:04:19-|-ATXYA-|-3000-|-192.168.12.1\
    05-|-08:EE:8B:F5:DA:26-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/03/2019
add comment=mikhmon name="oct/03/2019-|-19:48:29-|-BINCK-|-5000-|-192.168.12.1\
    01-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/03/2019
add comment=mikhmon name="oct/03/2019-|-19:52:09-|-BKDAT-|-5000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/03/2019
add comment=mikhmon name="oct/03/2019-|-23:06:45-|-BDZSN-|-5000-|-192.168.12.1\
    77-|-00:08:22:3E:23:03-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/03/2019
add comment=mikhmon name="oct/04/2019-|-07:13:19-|-BCXYK-|-5000-|-192.168.12.5\
    9-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/04/2019
add comment=mikhmon name="oct/04/2019-|-10:23:32-|-BHPIP-|-5000-|-192.168.12.3\
    9-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/04/2019
add comment=mikhmon name="oct/04/2019-|-10:54:24-|-BPZWU-|-5000-|-192.168.12.4\
    6-|-C0:87:EB:D5:D4:69-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/04/2019
add comment=mikhmon name="oct/04/2019-|-11:25:09-|-BWCFT-|-5000-|-192.168.12.3\
    6-|-C4:0B:CB:E3:2B:3C-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/04/2019
add comment=mikhmon name="oct/04/2019-|-19:35:44-|-BZHDD-|-5000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/04/2019
add comment=mikhmon name="oct/04/2019-|-20:26:50-|-BKMYP-|-5000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/04/2019
add comment=mikhmon name="oct/04/2019-|-22:51:39-|-BSSYS-|-5000-|-192.168.12.1\
    34-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/04/2019
add comment=mikhmon name="oct/04/2019-|-22:54:45-|-AVAYH-|-3000-|-192.168.12.1\
    39-|-08:7F:98:C7:BC:29-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/04/2019
add comment=mikhmon name="oct/05/2019-|-04:03:26-|-CXVUC-|-15000-|-192.168.12.\
    254-|-74:23:44:5C:38:28-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/05/2019
add comment=mikhmon name="oct/05/2019-|-09:01:32-|-APNWT-|-3000-|-192.168.12.1\
    05-|-08:EE:8B:F5:DA:26-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/05/2019
add comment=mikhmon name="oct/05/2019-|-11:45:59-|-BVBDR-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/05/2019
add comment=mikhmon name="oct/05/2019-|-16:56:39-|-ADFVV-|-3000-|-192.168.12.1\
    5-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/05/2019
add comment=mikhmon name="oct/05/2019-|-17:13:24-|-BHRXG-|-5000-|-192.168.12.9\
    8-|-00:08:22:9A:BA:FB-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/05/2019
add comment=mikhmon name="oct/05/2019-|-18:08:51-|-ACZAY-|-3000-|-192.168.12.1\
    24-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/05/2019
add comment=mikhmon name="oct/05/2019-|-19:41:58-|-AWMAI-|-3000-|-192.168.12.2\
    20-|-E0:06:E6:79:95:19-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/05/2019
add comment=mikhmon name="oct/05/2019-|-19:48:34-|-BWNIX-|-5000-|-192.168.12.3\
    5-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/05/2019
add comment=mikhmon name="oct/05/2019-|-20:07:51-|-ADWEM-|-3000-|-192.168.12.2\
    24-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/05/2019
add comment=mikhmon name="oct/05/2019-|-20:41:03-|-CURSM-|-15000-|-192.168.12.\
    206-|-08:8C:2C:02:A3:A3-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/05/2019
add comment=mikhmon name="oct/05/2019-|-21:56:25-|-CUKVP-|-15000-|-192.168.12.\
    42-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/05/2019
add comment=mikhmon name="oct/05/2019-|-22:18:14-|-BZSAN-|-5000-|-192.168.12.1\
    01-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-513-07.16.19-2hari16juli" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/05/2019
add comment=mikhmon name="oct/06/2019-|-07:30:21-|-CIAWC-|-15000-|-192.168.12.\
    139-|-08:7F:98:C7:BC:29-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/06/2019
add comment=mikhmon name="oct/06/2019-|-12:41:50-|-ARKSH-|-3000-|-192.168.12.1\
    05-|-08:EE:8B:F5:DA:26-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/06/2019
add comment=mikhmon name="oct/06/2019-|-12:49:23-|-BGWHD-|-5000-|-192.168.12.8\
    8-|-24:79:F3:52:26:EB-|-2d-|-2hari-|-up-744-10.05.19-" owner=oct2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=oct/06/2019
add comment=mikhmon name="oct/06/2019-|-18:53:24-|-BFPEW-|-5000-|-192.168.12.3\
    9-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-744-10.05.19-" owner=oct2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=oct/06/2019
add comment=mikhmon name="oct/06/2019-|-19:40:48-|-AEVKH-|-3000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/06/2019
add comment=mikhmon name="oct/06/2019-|-20:04:13-|-BADIK-|-5000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/06/2019
add comment=mikhmon name="oct/06/2019-|-22:56:15-|-BXAMZ-|-5000-|-192.168.12.1\
    34-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-744-10.05.19-" owner=oct2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=oct/06/2019
add comment=mikhmon name="oct/07/2019-|-13:13:33-|-BBGZG-|-5000-|-192.168.12.2\
    41-|-34:31:11:F9:B8:12-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/07/2019
add comment=mikhmon name="oct/07/2019-|-14:52:48-|-BYPOA-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-744-10.05.19-" owner=oct2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=oct/07/2019
add comment=mikhmon name="oct/07/2019-|-16:24:26-|-BHFSH-|-5000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-744-10.05.19-" owner=oct2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=oct/07/2019
add comment=mikhmon name="oct/07/2019-|-16:34:09-|-ATCKY-|-3000-|-192.168.12.1\
    26-|-60:72:8D:62:53:EB-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/07/2019
add comment=mikhmon name="oct/07/2019-|-17:47:45-|-AYXEF-|-3000-|-192.168.12.1\
    5-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/07/2019
add comment=mikhmon name="oct/07/2019-|-19:12:50-|-AZFAN-|-3000-|-192.168.12.2\
    24-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/07/2019
add comment=mikhmon name="oct/07/2019-|-19:17:40-|-ATDDW-|-3000-|-192.168.12.1\
    05-|-08:EE:8B:F5:DA:26-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/07/2019
add comment=mikhmon name="oct/07/2019-|-19:21:36-|-BTVPE-|-5000-|-192.168.12.4\
    6-|-C0:87:EB:D5:D4:69-|-2d-|-2hari-|-up-744-10.05.19-" owner=oct2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=oct/07/2019
add comment=mikhmon name="oct/07/2019-|-19:21:53-|-BZYTF-|-5000-|-192.168.12.1\
    31-|-C0:87:EB:04:A5:2B-|-2d-|-2hari-|-up-744-10.05.19-" owner=oct2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=oct/07/2019
add comment=mikhmon name="oct/07/2019-|-19:44:04-|-BDILI-|-5000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-744-10.05.19-" owner=oct2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=oct/07/2019
add comment=mikhmon name="oct/07/2019-|-20:09:47-|-AKNDV-|-3000-|-192.168.12.1\
    15-|-C0:87:EB:5A:BC:3F-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/07/2019
add comment=mikhmon name="oct/08/2019-|-07:31:00-|-BMFNH-|-5000-|-192.168.12.1\
    01-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-744-10.05.19-" owner=oct2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=oct/08/2019
add comment=mikhmon name="oct/08/2019-|-12:02:47-|-BUTMP-|-5000-|-192.168.12.3\
    6-|-C4:0B:CB:E3:2B:3C-|-2d-|-2hari-|-up-744-10.05.19-" owner=oct2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=oct/08/2019
add comment=mikhmon name="oct/08/2019-|-12:45:40-|-BYEJD-|-5000-|-192.168.12.5\
    9-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/08/2019
add comment=mikhmon name="oct/08/2019-|-16:08:12-|-BYSQN-|-5000-|-192.168.12.3\
    5-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-744-10.05.19-" owner=oct2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=oct/08/2019
add comment=mikhmon name="oct/08/2019-|-16:36:25-|-BVNYR-|-5000-|-192.168.12.9\
    8-|-00:08:22:9A:BA:FB-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/08/2019
add comment=mikhmon name="oct/08/2019-|-18:10:42-|-BPMTB-|-5000-|-192.168.12.2\
    32-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-744-10.05.19-" owner=oct2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=oct/08/2019
add comment=mikhmon name="oct/08/2019-|-19:15:42-|-ADATN-|-3000-|-192.168.12.2\
    24-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/08/2019
add comment=mikhmon name="oct/08/2019-|-19:55:39-|-AETCT-|-3000-|-192.168.12.2\
    27-|-7C:03:5E:C9:04:FB-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/08/2019
add comment=mikhmon name="oct/08/2019-|-20:03:48-|-APBXE-|-3000-|-192.168.12.3\
    9-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/08/2019
add comment=mikhmon name="oct/08/2019-|-20:53:39-|-ABUCC-|-3000-|-192.168.12.2\
    20-|-E0:06:E6:79:95:19-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/08/2019
add comment=mikhmon name="oct/08/2019-|-21:52:28-|-BDNBF-|-5000-|-192.168.12.1\
    05-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-744-10.05.19-" owner=oct2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=oct/08/2019
add comment=mikhmon name="oct/08/2019-|-22:42:49-|-BUBME-|-5000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/08/2019
add comment=mikhmon name="oct/09/2019-|-13:33:44-|-APDKV-|-3000-|-192.168.12.1\
    15-|-C0:87:EB:5A:BC:3F-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/09/2019
add comment=mikhmon name="oct/09/2019-|-14:56:15-|-BGQFE-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-744-10.05.19-" owner=oct2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=oct/09/2019
add comment=mikhmon name="oct/09/2019-|-16:48:49-|-BXOYS-|-5000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-744-10.05.19-" owner=oct2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=oct/09/2019
add comment=mikhmon name="oct/09/2019-|-18:10:10-|-ANBWW-|-3000-|-192.168.12.1\
    21-|-68:05:71:EA:EF:29-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/09/2019
add comment=mikhmon name="oct/09/2019-|-19:31:06-|-ADHDA-|-3000-|-192.168.12.2\
    24-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/09/2019
add comment=mikhmon name="oct/09/2019-|-19:36:08-|-BEKDE-|-5000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-744-10.05.19-" owner=oct2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=oct/09/2019
add comment=mikhmon name="oct/09/2019-|-19:46:05-|-BINHW-|-5000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-744-10.05.19-" owner=oct2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=oct/09/2019
add comment=mikhmon name="oct/09/2019-|-20:33:18-|-AIBYJ-|-3000-|-192.168.12.3\
    9-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/09/2019
add comment=mikhmon name="oct/10/2019-|-06:18:03-|-CIHPB-|-15000-|-192.168.12.\
    84-|-A4:D9:90:28:BB:33-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/10/2019
add comment=mikhmon name="oct/10/2019-|-14:21:46-|-BMESP-|-5000-|-192.168.12.5\
    4-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-744-10.05.19-" owner=oct2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=oct/10/2019
add comment=mikhmon name="oct/10/2019-|-14:36:26-|-BNVLY-|-5000-|-192.168.12.1\
    5-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-744-10.05.19-" owner=oct2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=oct/10/2019
add comment=mikhmon name="oct/10/2019-|-15:18:29-|-BPEKF-|-5000-|-192.168.12.3\
    5-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-744-10.05.19-" owner=oct2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=oct/10/2019
add comment=mikhmon name="oct/10/2019-|-15:43:44-|-CIDTH-|-15000-|-192.168.12.\
    4-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/10/2019
add comment=mikhmon name="oct/10/2019-|-16:12:36-|-AYGSA-|-3000-|-192.168.12.6\
    1-|-F4:0E:22:03:16:0E-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/10/2019
add comment=mikhmon name="oct/10/2019-|-16:19:38-|-AJRTE-|-3000-|-192.168.12.1\
    24-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/10/2019
add comment=mikhmon name="oct/10/2019-|-16:34:54-|-ADGHD-|-3000-|-192.168.12.6\
    8-|-0C:98:38:94:60:51-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/10/2019
add comment=mikhmon name="oct/10/2019-|-18:54:12-|-AKHJU-|-3000-|-192.168.12.8\
    5-|-38:E6:0A:82:FD:6D-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/10/2019
add comment=mikhmon name="oct/10/2019-|-18:57:25-|-AFDCC-|-3000-|-192.168.12.8\
    3-|-E4:C4:83:53:D3:CB-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/10/2019
add comment=mikhmon name="oct/10/2019-|-19:00:17-|-AMIRA-|-3000-|-192.168.12.8\
    8-|-3C:95:09:E7:6D:13-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/10/2019
add comment=mikhmon name="oct/10/2019-|-19:34:38-|-ACTRA-|-3000-|-192.168.12.9\
    7-|-08:7F:98:C6:65:AF-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/10/2019
add comment=mikhmon name="oct/10/2019-|-19:35:39-|-ADBEK-|-3000-|-192.168.12.2\
    24-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/10/2019
add comment=mikhmon name="oct/10/2019-|-19:37:36-|-BPAAC-|-5000-|-192.168.12.1\
    31-|-C0:87:EB:04:A5:2B-|-2d-|-2hari-|-up-744-10.05.19-" owner=oct2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=oct/10/2019
add comment=mikhmon name="oct/10/2019-|-22:57:39-|-BQPGB-|-5000-|-192.168.12.1\
    7-|-C0:87:EB:D5:D4:69-|-2d-|-2hari-|-up-744-10.05.19-" owner=oct2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=oct/10/2019
add comment=mikhmon name="oct/11/2019-|-04:34:55-|-BKIWD-|-5000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/11/2019
add comment=mikhmon name="oct/11/2019-|-09:27:34-|-AHVGK-|-3000-|-192.168.12.5\
    5-|-6C:D7:1F:27:38:79-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/11/2019
add comment=mikhmon name="oct/11/2019-|-13:04:24-|-AFWIS-|-3000-|-192.168.12.3\
    9-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/11/2019
add comment=mikhmon name="oct/11/2019-|-14:10:05-|-AVECV-|-3000-|-192.168.12.1\
    20-|-00:08:22:FC:7A:FC-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/11/2019
add comment=mikhmon name="oct/11/2019-|-16:58:12-|-ATKVZ-|-3000-|-192.168.12.1\
    05-|-08:EE:8B:F5:DA:26-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/11/2019
add comment=mikhmon name="oct/11/2019-|-17:29:57-|-AYDYA-|-3000-|-192.168.12.1\
    24-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/11/2019
add comment=mikhmon name="oct/11/2019-|-17:34:07-|-BYFUT-|-5000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-744-10.05.19-" owner=oct2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=oct/11/2019
add comment=mikhmon name="oct/11/2019-|-18:40:18-|-ASKCN-|-3000-|-192.168.12.1\
    61-|-C0:87:EB:EE:62:DB-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/11/2019
add comment=mikhmon name="oct/11/2019-|-18:52:35-|-AKFPC-|-3000-|-192.168.12.1\
    44-|-0C:98:38:94:60:51-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/11/2019
add comment=mikhmon name="oct/11/2019-|-18:55:34-|-ANHBI-|-3000-|-192.168.12.1\
    89-|-00:0A:F5:4E:69:4C-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/11/2019
add comment=mikhmon name="oct/11/2019-|-19:18:37-|-AYYTB-|-3000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/11/2019
add comment=mikhmon name="oct/11/2019-|-19:42:01-|-APPSM-|-3000-|-192.168.12.1\
    01-|-0C:98:38:1D:99:0B-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/11/2019
add comment=mikhmon name="oct/11/2019-|-19:56:35-|-AXWGS-|-3000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/11/2019
add comment=mikhmon name="oct/11/2019-|-20:09:40-|-AHXHC-|-3000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/11/2019
add comment=mikhmon name="oct/12/2019-|-01:22:40-|-ANARZ-|-3000-|-192.168.12.3\
    6-|-C4:0B:CB:E3:2B:3C-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/12/2019
add comment=mikhmon name="oct/12/2019-|-10:41:12-|-BTYAW-|-5000-|-192.168.12.1\
    44-|-0C:98:38:94:60:51-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/12/2019
add comment=mikhmon name="oct/12/2019-|-11:23:26-|-AVCGN-|-3000-|-192.168.12.4\
    8-|-68:05:71:EA:EF:29-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/12/2019
add comment=mikhmon name="oct/12/2019-|-13:20:31-|-ASYIR-|-3000-|-192.168.12.1\
    34-|-70:5E:55:A6:F8:99-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/12/2019
add comment=mikhmon name="oct/12/2019-|-13:57:31-|-BBBZX-|-5000-|-192.168.12.2\
    2-|-6C:D7:1F:23:3C:79-|-2d-|-2hari-|-up-" owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/12/2019
add comment=mikhmon name="oct/12/2019-|-17:43:41-|-AHXAM-|-3000-|-192.168.12.2\
    27-|-60:72:8D:62:53:EB-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/12/2019
add comment=mikhmon name="oct/12/2019-|-18:42:19-|-AYVUV-|-3000-|-192.168.12.3\
    5-|-2C:56:DC:E7:15:E1-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/12/2019
add comment=mikhmon name="oct/12/2019-|-19:18:59-|-AUVZP-|-3000-|-192.168.12.1\
    61-|-C0:87:EB:EE:62:DB-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/12/2019
add comment=mikhmon name="oct/12/2019-|-19:21:46-|-AEGPE-|-3000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/12/2019
add comment=mikhmon name="oct/12/2019-|-19:41:02-|-BJERU-|-5000-|-192.168.12.1\
    5-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/12/2019
add comment=mikhmon name="oct/12/2019-|-20:00:11-|-BTAZU-|-5000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/12/2019
add comment=mikhmon name="oct/12/2019-|-20:02:41-|-CSIVR-|-15000-|-192.168.12.\
    42-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/12/2019
add comment=mikhmon name="oct/12/2019-|-20:07:50-|-BLSHZ-|-5000-|-192.168.12.5\
    4-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/12/2019
add comment=mikhmon name="oct/12/2019-|-20:08:01-|-ANCPG-|-3000-|-192.168.12.2\
    48-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/12/2019
add comment=mikhmon name="oct/12/2019-|-20:29:11-|-ABDVX-|-3000-|-192.168.12.1\
    01-|-0C:98:38:1D:99:0B-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/12/2019
add comment=mikhmon name="oct/12/2019-|-21:12:47-|-AXZIS-|-3000-|-192.168.12.2\
    50-|-7C:03:5E:C9:04:FB-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/12/2019
add comment=mikhmon name="oct/12/2019-|-22:48:56-|-AEIFD-|-3000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/12/2019
add comment=mikhmon name="oct/13/2019-|-01:26:14-|-AZESC-|-3000-|-192.168.12.3\
    6-|-C4:0B:CB:E3:2B:3C-|-1d-|-1hari-|-up-593-10.02.19-1hari2Okt" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/13/2019
add comment=mikhmon name="oct/13/2019-|-05:43:51-|-CKIFS-|-15000-|-192.168.12.\
    254-|-74:23:44:5C:38:28-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/13/2019
add comment=mikhmon name="oct/13/2019-|-09:29:35-|-BXSXK-|-5000-|-192.168.12.1\
    05-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/13/2019
add comment=mikhmon name="oct/13/2019-|-09:43:39-|-AXVJV-|-3000-|-192.168.12.2\
    37-|-B0:E2:35:DC:34:67-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/13/2019
add comment=mikhmon name="oct/13/2019-|-11:09:23-|-CCCYC-|-15000-|-192.168.12.\
    17-|-C0:87:EB:D5:D4:69-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/13/2019
add comment=mikhmon name="oct/13/2019-|-14:19:27-|-AKATM-|-3000-|-192.168.12.1\
    2-|-78:36:CC:C6:A4:65-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/13/2019
add comment=mikhmon name="oct/13/2019-|-15:25:59-|-BSBDC-|-5000-|-192.168.12.1\
    9-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/13/2019
add comment=mikhmon name="oct/13/2019-|-16:17:48-|-BBGUX-|-5000-|-192.168.12.1\
    34-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/13/2019
add comment=mikhmon name="oct/13/2019-|-19:21:12-|-BDREW-|-5000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/13/2019
add comment=mikhmon name="oct/13/2019-|-19:36:35-|-BVDPP-|-5000-|-192.168.12.3\
    5-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/13/2019
add comment=mikhmon name="oct/13/2019-|-19:40:55-|-AGASC-|-3000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/13/2019
add comment=mikhmon name="oct/13/2019-|-20:16:36-|-ARRGM-|-3000-|-192.168.12.2\
    48-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/13/2019
add comment=mikhmon name="oct/13/2019-|-22:32:42-|-CCBRS-|-15000-|-192.168.12.\
    206-|-08:8C:2C:02:A3:A3-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/13/2019
add comment=mikhmon name="oct/14/2019-|-00:08:04-|-BGFMZ-|-5000-|-192.168.12.5\
    9-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/14/2019
add comment=mikhmon name="oct/14/2019-|-06:16:50-|-AYDHY-|-3000-|-192.168.12.7\
    9-|-F0:6D:78:3F:31:24-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/14/2019
add comment=mikhmon name="oct/14/2019-|-08:34:53-|-BEEKE-|-5000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/14/2019
add comment=mikhmon name="oct/14/2019-|-11:47:41-|-BMMXD-|-5000-|-192.168.12.1\
    01-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/14/2019
add comment=mikhmon name="oct/14/2019-|-14:40:22-|-CWVJE-|-15000-|-192.168.12.\
    139-|-08:7F:98:C7:BC:29-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/14/2019
add comment=mikhmon name="oct/14/2019-|-19:02:19-|-BCVHZ-|-5000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/14/2019
add comment=mikhmon name="oct/14/2019-|-19:43:06-|-BCWHX-|-5000-|-192.168.12.2\
    2-|-6C:D7:1F:23:3C:79-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/14/2019
add comment=mikhmon name="oct/14/2019-|-19:43:14-|-BUVHV-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/14/2019
add comment=mikhmon name="oct/14/2019-|-20:03:12-|-BMKWR-|-5000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/14/2019
add comment=mikhmon name="oct/14/2019-|-20:19:33-|-AUMGV-|-3000-|-192.168.12.2\
    48-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/14/2019
add comment=mikhmon name="oct/15/2019-|-08:36:44-|-BGBNE-|-5000-|-192.168.12.1\
    29-|-00:08:22:02:42:1D-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/15/2019
add comment=mikhmon name="oct/15/2019-|-13:26:42-|-ABTPD-|-3000-|-192.168.12.1\
    24-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/15/2019
add comment=mikhmon name="oct/15/2019-|-13:54:05-|-BTXUT-|-5000-|-192.168.12.5\
    4-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/15/2019
add comment=mikhmon name="oct/15/2019-|-18:08:01-|-BZFFD-|-5000-|-192.168.12.1\
    34-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/15/2019
add comment=mikhmon name="oct/15/2019-|-18:48:10-|-APGEC-|-3000-|-192.168.12.1\
    5-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/15/2019
add comment=mikhmon name="oct/15/2019-|-18:55:41-|-BLAUF-|-5000-|-192.168.12.1\
    9-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/15/2019
add comment=mikhmon name="oct/15/2019-|-20:33:43-|-BPNFN-|-5000-|-192.168.12.1\
    05-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/15/2019
add comment=mikhmon name="oct/16/2019-|-07:38:18-|-AMWUS-|-3000-|-192.168.12.6\
    3-|-88:5A:06:66:12:E5-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/16/2019
add comment=mikhmon name="oct/16/2019-|-09:38:18-|-BHRUF-|-5000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/16/2019
add comment=mikhmon name="oct/16/2019-|-13:18:28-|-AJJVW-|-3000-|-192.168.12.2\
    08-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/16/2019
add comment=mikhmon name="oct/16/2019-|-16:06:55-|-ADACA-|-3000-|-192.168.12.8\
    2-|-68:05:71:EA:EF:29-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/16/2019
add comment=mikhmon name="oct/16/2019-|-17:19:14-|-ANYNH-|-3000-|-192.168.12.1\
    61-|-C0:87:EB:EE:62:DB-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/16/2019
add comment=mikhmon name="oct/16/2019-|-18:05:12-|-AWWCZ-|-3000-|-192.168.12.3\
    5-|-2C:56:DC:E7:15:E1-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/16/2019
add comment=mikhmon name="oct/16/2019-|-18:10:43-|-BSWFX-|-5000-|-192.168.12.1\
    01-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/16/2019
add comment=mikhmon name="oct/16/2019-|-18:59:53-|-BCNSD-|-5000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/16/2019
add comment=mikhmon name="oct/16/2019-|-19:05:15-|-BMBGE-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/16/2019
add comment=mikhmon name="oct/16/2019-|-19:55:49-|-BFERD-|-5000-|-192.168.12.2\
    31-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/16/2019
add comment=mikhmon name="oct/16/2019-|-21:53:53-|-ARYTX-|-3000-|-192.168.12.2\
    2-|-6C:D7:1F:23:3C:79-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/16/2019
add comment=mikhmon name="oct/17/2019-|-01:04:37-|-BDVCS-|-5000-|-192.168.12.5\
    9-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/17/2019
add comment=mikhmon name="oct/17/2019-|-09:16:56-|-BYCVT-|-5000-|-192.168.12.4\
    7-|-80:AD:16:76:6E:5E-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/17/2019
add comment=mikhmon name="oct/17/2019-|-14:29:33-|-BCPRS-|-5000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/17/2019
add comment=mikhmon name="oct/17/2019-|-14:31:28-|-BGJEM-|-5000-|-192.168.12.1\
    5-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/17/2019
add comment=mikhmon name="oct/17/2019-|-18:23:02-|-BUBBZ-|-5000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/17/2019
add comment=mikhmon name="oct/17/2019-|-18:56:34-|-BXLVX-|-5000-|-192.168.12.8\
    8-|-2C:57:31:F0:77:09-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/17/2019
add comment=mikhmon name="oct/17/2019-|-19:12:47-|-CJHGS-|-15000-|-192.168.12.\
    14-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/17/2019
add comment=mikhmon name="oct/18/2019-|-12:02:18-|-BDTBA-|-5000-|-192.168.12.5\
    4-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/18/2019
add comment=mikhmon name="oct/18/2019-|-12:39:57-|-AUSCD-|-3000-|-192.168.12.1\
    69-|-0C:98:38:94:60:51-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/18/2019
add comment=mikhmon name="oct/18/2019-|-18:35:37-|-BEPUF-|-5000-|-192.168.12.1\
    01-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/18/2019
add comment=mikhmon name="oct/18/2019-|-19:09:05-|-BXDYR-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/18/2019
add comment=mikhmon name="oct/18/2019-|-19:13:46-|-BUSZT-|-5000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/18/2019
add comment=mikhmon name="oct/18/2019-|-20:47:11-|-BMXZN-|-5000-|-192.168.12.1\
    05-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/18/2019
add comment=mikhmon name="oct/18/2019-|-20:54:24-|-BGPSC-|-5000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/18/2019
add comment=mikhmon name="oct/19/2019-|-10:42:16-|-BTJSF-|-5000-|-192.168.12.4\
    7-|-80:AD:16:76:6E:5E-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/19/2019
add comment=mikhmon name="oct/19/2019-|-10:57:29-|-AXPDL-|-3000-|-192.168.12.1\
    49-|-DC:85:DE:38:D3:57-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/19/2019
add comment=mikhmon name="oct/19/2019-|-13:31:19-|-BSYJT-|-5000-|-192.168.12.3\
    5-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/19/2019
add comment=mikhmon name="oct/19/2019-|-14:01:58-|-BZRNE-|-5000-|-192.168.12.1\
    69-|-0C:98:38:94:60:51-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/19/2019
add comment=mikhmon name="oct/19/2019-|-14:06:57-|-BVLND-|-5000-|-192.168.12.2\
    2-|-6C:D7:1F:23:3C:79-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/19/2019
add comment=mikhmon name="oct/19/2019-|-14:10:32-|-ABJTE-|-3000-|-192.168.12.1\
    24-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-838-09.28.19-feri1h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/19/2019
add comment=mikhmon name="oct/19/2019-|-15:36:38-|-AZTJS-|-3000-|-192.168.12.1\
    61-|-C0:87:EB:EE:62:DB-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/19/2019
add comment=mikhmon name="oct/19/2019-|-16:28:16-|-APPUW-|-3000-|-192.168.12.4\
    6-|-20:5E:F7:30:5E:78-|-1d-|-1hari-|-up-" owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/19/2019
add comment=mikhmon name="oct/19/2019-|-18:04:17-|-ARBED-|-3000-|-192.168.12.2\
    52-|-60:72:8D:62:53:EB-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/19/2019
add comment=mikhmon name="oct/19/2019-|-18:21:29-|-BIBWI-|-5000-|-192.168.12.6\
    3-|-00:08:22:04:48:45-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/19/2019
add comment=mikhmon name="oct/19/2019-|-18:57:54-|-BNKCF-|-5000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/19/2019
add comment=mikhmon name="oct/19/2019-|-20:44:40-|-CZGRC-|-15000-|-192.168.12.\
    42-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/19/2019
add comment=mikhmon name="oct/19/2019-|-21:21:26-|-AETVJ-|-3000-|-192.168.12.1\
    8-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/19/2019
add comment=mikhmon name="oct/19/2019-|-23:00:37-|-BMVSR-|-5000-|-192.168.12.1\
    34-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/19/2019
add comment=mikhmon name="oct/19/2019-|-23:44:31-|-BPDDZ-|-5000-|-192.168.12.3\
    4-|-C4:0B:CB:E3:2B:3C-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/19/2019
add comment=mikhmon name="oct/20/2019-|-16:44:13-|-CTHIA-|-15000-|-192.168.12.\
    17-|-C0:87:EB:D5:D4:69-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/20/2019
add comment=mikhmon name="oct/20/2019-|-16:47:08-|-BUCTW-|-5000-|-192.168.12.1\
    31-|-C0:87:EB:04:A5:2B-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/20/2019
add comment=mikhmon name="oct/20/2019-|-18:57:12-|-BSCGR-|-5000-|-192.168.12.1\
    01-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/20/2019
add comment=mikhmon name="oct/20/2019-|-19:44:26-|-BTEJA-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/20/2019
add comment=mikhmon name="oct/20/2019-|-20:08:14-|-BCYUW-|-5000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/20/2019
add comment=mikhmon name="oct/20/2019-|-20:31:52-|-AEJLH-|-3000-|-192.168.12.2\
    19-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/20/2019
add comment=mikhmon name="oct/20/2019-|-20:33:59-|-BVFIC-|-5000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/20/2019
add comment=mikhmon name="oct/20/2019-|-20:57:21-|-BGHRG-|-5000-|-192.168.12.1\
    05-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/20/2019
add comment=mikhmon name="oct/21/2019-|-10:56:33-|-BBFNE-|-5000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/21/2019
add comment=mikhmon name="oct/21/2019-|-11:28:33-|-CGWNY-|-15000-|-192.168.12.\
    245-|-74:23:44:5C:38:28-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/21/2019
add comment=mikhmon name="oct/21/2019-|-11:33:55-|-BUPYY-|-5000-|-192.168.12.1\
    40-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/21/2019
add comment=mikhmon name="oct/21/2019-|-11:41:25-|-AWBTC-|-3000-|-192.168.12.4\
    7-|-80:AD:16:76:6E:5E-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/21/2019
add comment=mikhmon name="oct/21/2019-|-15:05:51-|-BBXBM-|-5000-|-192.168.12.1\
    39-|-08:7F:98:C7:BC:29-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/21/2019
add comment=mikhmon name="oct/21/2019-|-18:04:04-|-AJXUD-|-3000-|-192.168.12.1\
    57-|-3C:95:09:E7:6D:13-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/21/2019
add comment=mikhmon name="oct/21/2019-|-18:22:33-|-BMMEW-|-5000-|-192.168.12.2\
    10-|-C0:87:EB:16:52:21-|-2d-|-2hari-|-up-402-10.12.19-2hari101219" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/21/2019
add comment=mikhmon name="oct/21/2019-|-19:38:32-|-BBFUC-|-5000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/21/2019
add comment=mikhmon name="oct/21/2019-|-21:27:47-|-APIKU-|-3000-|-192.168.12.1\
    90-|-0C:A8:A7:D5:69:D4-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/21/2019
add comment=mikhmon name="oct/22/2019-|-08:15:52-|-AWTUX-|-3000-|-192.168.12.1\
    73-|-24:79:F3:6F:AA:6D-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/22/2019
add comment=mikhmon name="oct/22/2019-|-09:08:35-|-BCHWC-|-5000-|-192.168.12.3\
    5-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/22/2019
add comment=mikhmon name="oct/22/2019-|-13:01:49-|-BCDEP-|-5000-|-192.168.12.4\
    7-|-80:AD:16:76:6E:5E-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/22/2019
add comment=mikhmon name="oct/22/2019-|-16:27:17-|-CMCXN-|-15000-|-192.168.12.\
    206-|-08:8C:2C:02:A3:A3-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/22/2019
add comment=mikhmon name="oct/22/2019-|-18:54:36-|-BYZNI-|-5000-|-192.168.12.1\
    31-|-C0:87:EB:04:A5:2B-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/22/2019
add comment=mikhmon name="oct/22/2019-|-19:48:31-|-BFITZ-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/22/2019
add comment=mikhmon name="oct/22/2019-|-20:19:14-|-BTYBU-|-5000-|-192.168.12.1\
    01-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/22/2019
add comment=mikhmon name="oct/22/2019-|-20:55:28-|-BYZAH-|-5000-|-192.168.12.2\
    2-|-6C:D7:1F:23:3C:79-|-2d-|-2hari-|-up-739-09.28.19-feri2h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/22/2019
add comment=mikhmon name="oct/22/2019-|-21:12:51-|-AFWWT-|-3000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/22/2019
add comment=mikhmon name="oct/23/2019-|-06:43:28-|-AXFXK-|-3000-|-192.168.12.1\
    58-|-0C:98:38:94:60:51-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/23/2019
add comment=mikhmon name="oct/23/2019-|-11:54:19-|-BWBUX-|-5000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/23/2019
add comment=mikhmon name="oct/23/2019-|-12:58:01-|-AWDMV-|-3000-|-192.168.12.7\
    1-|-F4:F5:DB:10:02:37-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/23/2019
add comment=mikhmon name="oct/23/2019-|-15:44:09-|-CESTX-|-15000-|-192.168.12.\
    139-|-08:7F:98:C7:BC:29-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/23/2019
add comment=mikhmon name="oct/23/2019-|-17:09:01-|-BAEDY-|-5000-|-192.168.12.1\
    05-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/23/2019
add comment=mikhmon name="oct/23/2019-|-17:22:47-|-BBPMY-|-5000-|-192.168.12.2\
    19-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/23/2019
add comment=mikhmon name="oct/23/2019-|-17:44:23-|-BVRDV-|-5000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/23/2019
add comment=mikhmon name="oct/23/2019-|-18:53:52-|-BRBPW-|-5000-|-192.168.12.1\
    40-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/23/2019
add comment=mikhmon name="oct/23/2019-|-19:54:39-|-BFDXN-|-5000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/23/2019
add comment=mikhmon name="oct/23/2019-|-22:30:58-|-BPFEX-|-5000-|-192.168.12.4\
    7-|-80:AD:16:76:6E:5E-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/23/2019
add comment=mikhmon name="oct/24/2019-|-08:13:48-|-AZNBR-|-3000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/24/2019
add comment=mikhmon name="oct/24/2019-|-14:56:23-|-BDEFV-|-5000-|-192.168.12.3\
    5-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/24/2019
add comment=mikhmon name="oct/24/2019-|-19:42:48-|-AWBAU-|-3000-|-192.168.12.1\
    71-|-74:29:AF:E8:0E:17-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/24/2019
add comment=mikhmon name="oct/24/2019-|-19:52:15-|-BIXWG-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/24/2019
add comment=mikhmon name="oct/25/2019-|-06:05:11-|-BVHPF-|-5000-|-192.168.12.1\
    01-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/25/2019
add comment=mikhmon name="oct/25/2019-|-07:56:55-|-CFUCP-|-15000-|-192.168.12.\
    14-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/25/2019
add comment=mikhmon name="oct/25/2019-|-17:10:45-|-BWVAT-|-5000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/25/2019
add comment=mikhmon name="oct/25/2019-|-18:15:15-|-BGWEV-|-5000-|-192.168.12.2\
    34-|-2C:57:31:F0:77:09-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/25/2019
add comment=mikhmon name="oct/25/2019-|-18:57:33-|-BMYEC-|-5000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/25/2019
add comment=mikhmon name="oct/25/2019-|-19:32:48-|-AXHYC-|-3000-|-192.168.12.1\
    58-|-0C:98:38:94:60:51-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/25/2019
add comment=mikhmon name="oct/25/2019-|-20:10:49-|-CCMSK-|-15000-|-192.168.12.\
    47-|-80:AD:16:76:6E:5E-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/25/2019
add comment=mikhmon name="oct/25/2019-|-20:19:16-|-BDBTE-|-5000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/25/2019
add comment=mikhmon name="oct/25/2019-|-20:19:50-|-AWKTY-|-3000-|-192.168.12.2\
    19-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/25/2019
add comment=mikhmon name="oct/25/2019-|-21:00:21-|-BWHZD-|-5000-|-192.168.12.2\
    54-|-24:79:F3:52:26:EB-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/25/2019
add comment=mikhmon name="oct/25/2019-|-21:08:30-|-CAFBG-|-15000-|-192.168.12.\
    166-|-60:A4:D0:B9:1E:48-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/25/2019
add comment=mikhmon name="oct/25/2019-|-21:34:53-|-BIXZH-|-5000-|-192.168.12.1\
    05-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/25/2019
add comment=mikhmon name="oct/25/2019-|-22:41:46-|-ACKKI-|-3000-|-192.168.12.1\
    34-|-70:5E:55:A6:F8:99-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/25/2019
add comment=mikhmon name="oct/26/2019-|-12:31:13-|-BIVDE-|-5000-|-192.168.12.2\
    14-|-1C:99:4C:E4:2D:96-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/26/2019
add comment=mikhmon name="oct/26/2019-|-19:10:46-|-BFNUJ-|-5000-|-192.168.12.1\
    40-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/26/2019
add comment=mikhmon name="oct/26/2019-|-20:54:23-|-CPMCE-|-15000-|-192.168.12.\
    55-|-A4:D9:90:28:BB:33-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/26/2019
add comment=mikhmon name="oct/26/2019-|-21:15:21-|-CMNCU-|-15000-|-192.168.12.\
    42-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/26/2019
add comment=mikhmon name="oct/27/2019-|-11:43:11-|-APUIN-|-3000-|-192.168.12.2\
    47-|-0C:A8:A7:D5:69:D4-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/27/2019
add comment=mikhmon name="oct/27/2019-|-19:03:46-|-BUHAZ-|-5000-|-192.168.12.1\
    35-|-2C:57:31:F0:77:09-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/27/2019
add comment=mikhmon name="oct/27/2019-|-20:05:01-|-BMYAT-|-5000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/27/2019
add comment=mikhmon name="oct/27/2019-|-20:22:36-|-BFMIR-|-5000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-138-10.20.19-2hari20Oct" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/27/2019
add comment=mikhmon name="oct/28/2019-|-08:23:07-|-ADUIW-|-3000-|-192.168.12.2\
    19-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/28/2019
add comment=mikhmon name="oct/28/2019-|-12:10:00-|-AZNDE-|-3000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/28/2019
add comment=mikhmon name="oct/28/2019-|-16:15:42-|-CIJCX-|-15000-|-192.168.12.\
    245-|-74:23:44:5C:38:28-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/28/2019
add comment=mikhmon name="oct/28/2019-|-16:25:25-|-AABPH-|-3000-|-192.168.12.2\
    47-|-0C:A8:A7:D5:69:D4-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/28/2019
add comment=mikhmon name="oct/28/2019-|-19:01:28-|-AABYC-|-3000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/28/2019
add comment=mikhmon name="oct/28/2019-|-19:28:01-|-AMSPK-|-3000-|-192.168.12.1\
    40-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/28/2019
add comment=mikhmon name="oct/29/2019-|-08:08:36-|-CNNZP-|-15000-|-192.168.12.\
    34-|-24:2E:02:8D:5E:F4-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/29/2019
add comment=mikhmon name="oct/29/2019-|-12:25:25-|-AGZEE-|-3000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/29/2019
add comment=mikhmon name="oct/29/2019-|-12:38:13-|-AKZEV-|-3000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/29/2019
add comment=mikhmon name="oct/29/2019-|-13:21:53-|-ARLPZ-|-3000-|-192.168.12.2\
    19-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/29/2019
add comment=mikhmon name="oct/29/2019-|-14:27:01-|-AGNUP-|-3000-|-192.168.12.1\
    01-|-0C:98:38:1D:99:0B-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/29/2019
add comment=mikhmon name="oct/29/2019-|-20:24:57-|-ALPJG-|-3000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/29/2019
add comment=mikhmon name="oct/30/2019-|-01:44:31-|-CCFHE-|-15000-|-192.168.12.\
    252-|-6C:D7:1F:27:38:79-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/30/2019
add comment=mikhmon name="oct/30/2019-|-12:28:09-|-AVYKW-|-3000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/30/2019
add comment=mikhmon name="oct/30/2019-|-16:17:34-|-ANLLG-|-3000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/30/2019
add comment=mikhmon name="oct/30/2019-|-16:17:57-|-AUHUH-|-3000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/30/2019
add comment=mikhmon name="oct/30/2019-|-16:48:31-|-AGKKJ-|-3000-|-192.168.12.1\
    05-|-08:EE:8B:F5:DA:26-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/30/2019
add comment=mikhmon name="oct/30/2019-|-17:56:37-|-ANPSH-|-3000-|-192.168.12.1\
    40-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/30/2019
add comment=mikhmon name="oct/30/2019-|-19:24:14-|-ANGWT-|-3000-|-192.168.12.2\
    19-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/30/2019
add comment=mikhmon name="oct/30/2019-|-20:27:41-|-ATAVZ-|-3000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/30/2019
add comment=mikhmon name="oct/31/2019-|-14:20:28-|-AERUN-|-3000-|-192.168.12.1\
    39-|-08:7F:98:C7:BC:29-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/31/2019
add comment=mikhmon name="oct/31/2019-|-16:08:29-|-AIAYR-|-3000-|-192.168.12.3\
    8-|-68:05:71:EA:EF:29-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/31/2019
add comment=mikhmon name="oct/31/2019-|-16:39:33-|-ARNYG-|-3000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/31/2019
add comment=mikhmon name="oct/31/2019-|-18:17:41-|-BXGPA-|-5000-|-192.168.12.1\
    40-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/31/2019
add comment=mikhmon name="oct/31/2019-|-18:55:10-|-AUBEJ-|-3000-|-192.168.12.1\
    58-|-0C:98:38:94:60:51-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/31/2019
add comment=mikhmon name="oct/31/2019-|-19:05:08-|-AEXSH-|-3000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/31/2019
add comment=mikhmon name="oct/31/2019-|-19:20:38-|-BUHJU-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/31/2019
add comment=mikhmon name="oct/31/2019-|-19:22:30-|-BMDHK-|-5000-|-192.168.12.8\
    6-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/31/2019
add comment=mikhmon name="oct/31/2019-|-19:42:47-|-BHMCP-|-5000-|-192.168.12.1\
    05-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/31/2019
add comment=mikhmon name="oct/31/2019-|-20:15:25-|-ANGBF-|-3000-|-192.168.12.2\
    19-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=oct2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    oct/31/2019
add comment=mikhmon name="nov/01/2019-|-09:33:00-|-CUTMU-|-15000-|-192.168.12.\
    14-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/01/2019
add comment=mikhmon name="nov/01/2019-|-18:59:06-|-BHDUN-|-5000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/01/2019
add comment=mikhmon name="nov/01/2019-|-19:51:24-|-BYDVE-|-5000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/01/2019
add comment=mikhmon name="nov/01/2019-|-20:03:23-|-BZBTP-|-5000-|-192.168.12.1\
    31-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/01/2019
add comment=mikhmon name="nov/02/2019-|-09:12:28-|-BNKYH-|-5000-|-192.168.12.2\
    54-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/02/2019
add comment=mikhmon name="nov/02/2019-|-12:24:43-|-BANIP-|-5000-|-192.168.12.4\
    7-|-80:AD:16:76:6E:5E-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/02/2019
add comment=mikhmon name="nov/02/2019-|-13:12:43-|-BPAVI-|-5000-|-192.168.12.7\
    4-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/02/2019
add comment=mikhmon name="nov/02/2019-|-13:48:07-|-APGRM-|-3000-|-192.168.12.1\
    39-|-08:7F:98:C7:BC:29-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/02/2019
add comment=mikhmon name="nov/02/2019-|-18:55:55-|-BZRAK-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/02/2019
add comment=mikhmon name="nov/02/2019-|-19:40:09-|-BGFMP-|-5000-|-192.168.12.7\
    6-|-C0:87:EB:35:15:4B-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/02/2019
add comment=mikhmon name="nov/02/2019-|-19:46:43-|-agoszz-|-3000-|-192.168.12.\
    92-|-C0:87:EB:FF:54:C9-|-1d-|-1hari-|-" owner=nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/02/2019
add comment=mikhmon name="nov/02/2019-|-20:05:10-|-ABYVW-|-3000-|-192.168.12.1\
    53-|-C0:87:EB:EE:62:DB-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/02/2019
add comment=mikhmon name="nov/02/2019-|-20:25:45-|-BJAAB-|-5000-|-192.168.12.1\
    05-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/02/2019
add comment=mikhmon name="nov/02/2019-|-21:02:04-|-ATGNB-|-3000-|-192.168.12.2\
    50-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/02/2019
add comment=mikhmon name="nov/02/2019-|-21:12:19-|-AFVTV-|-3000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/02/2019
add comment=mikhmon name="nov/02/2019-|-23:05:35-|-CEPRJ-|-15000-|-192.168.12.\
    42-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/02/2019
add comment=mikhmon name="nov/03/2019-|-08:41:49-|-BDYKI-|-5000-|-192.168.12.2\
    41-|-C4:0B:CB:E3:2B:3C-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/03/2019
add comment=mikhmon name="nov/03/2019-|-08:48:01-|-BKZPP-|-5000-|-192.168.12.1\
    40-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/03/2019
add comment=mikhmon name="nov/03/2019-|-14:51:17-|-ADGYF-|-3000-|-192.168.12.1\
    24-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/03/2019
add comment=mikhmon name="nov/03/2019-|-17:45:22-|-BBVRD-|-5000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/03/2019
add comment=mikhmon name="nov/03/2019-|-17:45:37-|-BNTMA-|-5000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/03/2019
add comment=mikhmon name="nov/03/2019-|-17:58:55-|-BBAIK-|-5000-|-192.168.12.1\
    93-|-00:0A:F5:4E:69:4C-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/03/2019
add comment=mikhmon name="nov/03/2019-|-19:54:59-|-ATMTK-|-3000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/03/2019
add comment=mikhmon name="nov/03/2019-|-20:25:54-|-BDJTK-|-5000-|-192.168.12.2\
    33-|-0C:A8:A7:D5:69:D4-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/03/2019
add comment=mikhmon name="nov/04/2019-|-07:02:37-|-BBIFK-|-5000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/04/2019
add comment=mikhmon name="nov/04/2019-|-15:11:26-|-AUFIX-|-3000-|-192.168.12.1\
    39-|-08:7F:98:C7:BC:29-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/04/2019
add comment=mikhmon name="nov/04/2019-|-19:01:04-|-AESGN-|-3000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/04/2019
add comment=mikhmon name="nov/04/2019-|-19:58:57-|-AYZPM-|-3000-|-192.168.12.2\
    19-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/04/2019
add comment=mikhmon name="nov/04/2019-|-20:35:24-|-BPYFU-|-5000-|-192.168.12.4\
    7-|-80:AD:16:76:6E:5E-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/04/2019
add comment=mikhmon name="nov/04/2019-|-21:27:32-|-AJDWA-|-3000-|-192.168.12.2\
    53-|-20:A6:0C:17:A8:9C-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/04/2019
add comment=mikhmon name="nov/05/2019-|-10:38:49-|-BHWEZ-|-5000-|-192.168.12.2\
    3-|-10:2A:B3:49:D9:BB-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/05/2019
add comment=mikhmon name="nov/05/2019-|-13:17:43-|-BVXZH-|-5000-|-192.168.12.1\
    11-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/05/2019
add comment=mikhmon name="nov/05/2019-|-16:00:09-|-ALLSM-|-3000-|-192.168.12.1\
    43-|-EC:D0:9F:D5:B7:0F-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/05/2019
add comment=mikhmon name="nov/05/2019-|-18:43:02-|-BTGFM-|-5000-|-192.168.12.1\
    57-|-3C:95:09:E7:6D:13-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/05/2019
add comment=mikhmon name="nov/05/2019-|-19:04:10-|-BJTDZ-|-5000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/05/2019
add comment=mikhmon name="nov/05/2019-|-19:05:17-|-BIZVY-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/05/2019
add comment=mikhmon name="nov/05/2019-|-19:32:58-|-BIUXC-|-5000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/05/2019
add comment=mikhmon name="nov/05/2019-|-20:22:51-|-ANCDG-|-3000-|-192.168.12.2\
    19-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/05/2019
add comment=mikhmon name="nov/05/2019-|-21:07:24-|-BYVFU-|-5000-|-192.168.12.1\
    86-|-18:02:AE:9F:82:7F-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/05/2019
add comment=mikhmon name="nov/06/2019-|-11:21:19-|-BYWZZ-|-5000-|-192.168.12.1\
    40-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/06/2019
add comment=mikhmon name="nov/06/2019-|-11:42:01-|-BWVHK-|-5000-|-192.168.12.2\
    33-|-0C:A8:A7:D5:69:D4-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/06/2019
add comment=mikhmon name="nov/06/2019-|-11:44:38-|-BBCXD-|-5000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/06/2019
add comment=mikhmon name="nov/06/2019-|-12:48:04-|-AJYDT-|-3000-|-192.168.12.3\
    2-|-C0:87:EB:C0:28:19-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/06/2019
add comment=mikhmon name="nov/06/2019-|-12:57:09-|-APPBC-|-3000-|-192.168.12.7\
    0-|-60:72:8D:62:53:EB-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/06/2019
add comment=mikhmon name="nov/06/2019-|-15:47:55-|-BFJMN-|-5000-|-192.168.12.1\
    44-|-CC:2D:83:AA:45:CD-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/06/2019
add comment=mikhmon name="nov/06/2019-|-19:55:45-|-AAUWG-|-3000-|-192.168.12.1\
    39-|-08:7F:98:C7:BC:29-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/06/2019
add comment=mikhmon name="nov/07/2019-|-11:17:05-|-CWSIS-|-15000-|-192.168.12.\
    153-|-A4:D9:90:28:BB:33-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/07/2019
add comment=mikhmon name="nov/07/2019-|-11:32:20-|-BWUVR-|-5000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/07/2019
add comment=mikhmon name="nov/07/2019-|-11:42:36-|-BKSMZ-|-5000-|-192.168.12.8\
    6-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/07/2019
add comment=mikhmon name="nov/07/2019-|-18:20:21-|-BSMIM-|-5000-|-192.168.12.1\
    05-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/07/2019
add comment=mikhmon name="nov/07/2019-|-19:32:38-|-BYCEE-|-5000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/07/2019
add comment=mikhmon name="nov/07/2019-|-19:40:17-|-BTUYR-|-5000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/07/2019
add comment=mikhmon name="nov/07/2019-|-21:34:52-|-BDUBM-|-5000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/07/2019
add comment=mikhmon name="nov/08/2019-|-00:20:08-|-BWXKG-|-5000-|-192.168.12.2\
    41-|-C4:0B:CB:E3:2B:3C-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/08/2019
add comment=mikhmon name="nov/08/2019-|-08:11:58-|-CVJHZ-|-15000-|-192.168.12.\
    84-|-34:E9:11:1E:F3:BB-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/08/2019
add comment=mikhmon name="nov/08/2019-|-08:34:37-|-CIYVR-|-15000-|-192.168.12.\
    161-|-3C:B6:B7:31:00:49-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/08/2019
add comment=mikhmon name="nov/08/2019-|-11:57:27-|-APNWR-|-3000-|-192.168.12.1\
    24-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/08/2019
add comment=mikhmon name="nov/08/2019-|-12:11:18-|-BTEIH-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/08/2019
add comment=mikhmon name="nov/08/2019-|-12:12:58-|-BXFZX-|-5000-|-192.168.12.7\
    4-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/08/2019
add comment=mikhmon name="nov/08/2019-|-12:43:19-|-CPWHU-|-15000-|-192.168.12.\
    139-|-08:7F:98:C7:BC:29-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/08/2019
add comment=mikhmon name="nov/08/2019-|-12:59:06-|-AFVKL-|-3000-|-192.168.12.1\
    43-|-EC:D0:9F:D5:B7:0F-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/08/2019
add comment=mikhmon name="nov/08/2019-|-17:20:20-|-AGFMG-|-3000-|-192.168.12.2\
    19-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/08/2019
add comment=mikhmon name="nov/08/2019-|-17:56:27-|-CTDDS-|-15000-|-192.168.12.\
    14-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/08/2019
add comment=mikhmon name="nov/08/2019-|-20:57:17-|-AWSHJ-|-3000-|-192.168.12.2\
    9-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/08/2019
add comment=mikhmon name="nov/08/2019-|-21:49:56-|-AUWMF-|-3000-|-192.168.12.6\
    0-|-70:5E:55:A6:F8:99-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/08/2019
add comment=mikhmon name="nov/09/2019-|-07:13:46-|-BUEKN-|-5000-|-192.168.12.1\
    40-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/09/2019
add comment=mikhmon name="nov/09/2019-|-07:41:43-|-BGUGI-|-5000-|-192.168.12.1\
    86-|-18:02:AE:9F:82:7F-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/09/2019
add comment=mikhmon name="nov/09/2019-|-08:41:25-|-ASGZU-|-3000-|-192.168.12.2\
    54-|-C0:87:EB:EE:62:DB-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/09/2019
add comment=mikhmon name="nov/09/2019-|-12:00:42-|-ANYMU-|-3000-|-192.168.12.1\
    24-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/09/2019
add comment=mikhmon name="nov/09/2019-|-14:59:17-|-BCWHK-|-5000-|-192.168.12.1\
    44-|-CC:2D:83:AA:45:CD-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/09/2019
add comment=mikhmon name="nov/09/2019-|-16:34:34-|-ulfa-|-5000-|-192.168.12.47\
    -|-80:AD:16:76:6E:5E-|-2d-|-2hari-|-up-" owner=nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/09/2019
add comment=mikhmon name="nov/09/2019-|-17:07:31-|-BACKY-|-5000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/09/2019
add comment=mikhmon name="nov/09/2019-|-17:08:56-|-BXSTD-|-5000-|-192.168.12.4\
    6-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/09/2019
add comment=mikhmon name="nov/09/2019-|-18:57:48-|-AHSSZ-|-3000-|-192.168.12.2\
    12-|-E0:06:E6:79:95:19-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/09/2019
add comment=mikhmon name="nov/09/2019-|-19:20:59-|-BPVPA-|-5000-|-192.168.12.1\
    05-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/09/2019
add comment=mikhmon name="nov/09/2019-|-20:31:31-|-BFXPD-|-5000-|-192.168.12.1\
    7-|-C0:87:EB:D5:D4:69-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/09/2019
add comment=mikhmon name="nov/09/2019-|-21:01:58-|-ACHZH-|-3000-|-192.168.12.2\
    9-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/09/2019
add comment=mikhmon name="nov/09/2019-|-21:11:17-|-BJSWM-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/09/2019
add comment=mikhmon name="nov/09/2019-|-22:51:39-|-AXGYL-|-3000-|-192.168.12.2\
    53-|-20:A6:0C:17:A8:9C-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/09/2019
add comment=mikhmon name="nov/09/2019-|-22:57:45-|-BUJUB-|-5000-|-192.168.12.1\
    11-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/09/2019
add comment=mikhmon name="nov/10/2019-|-07:06:56-|-BDNBR-|-5000-|-192.168.12.2\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/10/2019
add comment=mikhmon name="nov/10/2019-|-07:18:23-|-ANECZ-|-3000-|-192.168.12.5\
    1-|-7C:03:5E:C9:04:FB-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/10/2019
add comment=mikhmon name="nov/10/2019-|-07:48:50-|-AWESK-|-3000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/10/2019
add comment=mikhmon name="nov/10/2019-|-11:22:34-|-AKAHR-|-3000-|-192.168.12.1\
    58-|-0C:98:38:94:60:51-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/10/2019
add comment=mikhmon name="nov/10/2019-|-14:48:22-|-ABCJE-|-3000-|-192.168.12.6\
    3-|-1C:99:4C:E4:2D:96-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/10/2019
add comment=mikhmon name="nov/10/2019-|-17:47:59-|-ADBRB-|-3000-|-192.168.12.4\
    1-|-08:7F:98:E1:84:ED-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/10/2019
add comment=mikhmon name="nov/10/2019-|-18:29:34-|-ACGGA-|-3000-|-192.168.12.1\
    57-|-3C:95:09:E7:6D:13-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/10/2019
add comment=mikhmon name="nov/10/2019-|-20:28:23-|-BDDZF-|-5000-|-192.168.12.5\
    7-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/10/2019
add comment=mikhmon name="nov/10/2019-|-21:05:47-|-BVXUW-|-5000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/10/2019
add comment=mikhmon name="nov/10/2019-|-21:21:13-|-BDIIC-|-5000-|-192.168.12.2\
    41-|-C4:0B:CB:E3:2B:3C-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/10/2019
add comment=mikhmon name="nov/10/2019-|-21:25:53-|-CYKXG-|-15000-|-192.168.12.\
    42-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/10/2019
add comment=mikhmon name="nov/10/2019-|-21:36:17-|-BTNNX-|-5000-|-192.168.12.2\
    19-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/10/2019
add comment=mikhmon name="nov/11/2019-|-10:44:32-|-BWEJT-|-5000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/11/2019
add comment=mikhmon name="nov/11/2019-|-18:27:40-|-BIRNA-|-5000-|-192.168.12.1\
    44-|-CC:2D:83:AA:45:CD-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/11/2019
add comment=mikhmon name="nov/11/2019-|-18:38:45-|-BDZZG-|-5000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/11/2019
add comment=mikhmon name="nov/11/2019-|-18:54:04-|-AGGTW-|-3000-|-192.168.12.4\
    1-|-08:7F:98:E1:84:ED-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/11/2019
add comment=mikhmon name="nov/11/2019-|-19:04:18-|-ALRSP-|-3000-|-192.168.12.1\
    57-|-3C:95:09:E7:6D:13-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/11/2019
add comment=mikhmon name="nov/11/2019-|-19:07:56-|-BTRPN-|-5000-|-192.168.12.4\
    6-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/11/2019
add comment=mikhmon name="nov/11/2019-|-19:59:20-|-AYXLX-|-3000-|-192.168.12.1\
    86-|-18:02:AE:9F:82:7F-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/11/2019
add comment=mikhmon name="nov/11/2019-|-20:20:36-|-BVHEN-|-5000-|-192.168.12.1\
    05-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/11/2019
add comment=mikhmon name="nov/12/2019-|-11:13:25-|-BYPAJ-|-5000-|-192.168.12.1\
    80-|-84:4B:F5:2A:51:C1-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/12/2019
add comment=mikhmon name="nov/12/2019-|-16:43:54-|-BEWMA-|-5000-|-192.168.12.9\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/12/2019
add comment=mikhmon name="nov/12/2019-|-17:54:57-|-AXEYC-|-3000-|-192.168.12.1\
    40-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/12/2019
add comment=mikhmon name="nov/12/2019-|-17:57:26-|-CRSPM-|-15000-|-192.168.12.\
    27-|-A4:D9:90:28:BB:33-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/12/2019
add comment=mikhmon name="nov/12/2019-|-21:50:58-|-BGPUI-|-5000-|-192.168.12.1\
    86-|-18:02:AE:9F:82:7F-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/12/2019
add comment=mikhmon name="nov/13/2019-|-13:20:05-|-ARYHU-|-3000-|-192.168.12.1\
    24-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-347-10.20.19-1hariferi20ct" \
    owner=nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/13/2019
add comment=mikhmon name="nov/13/2019-|-13:34:57-|-BNRDV-|-5000-|-192.168.12.1\
    11-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/13/2019
add comment=mikhmon name="nov/13/2019-|-13:55:23-|-BWPKC-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/13/2019
add comment=mikhmon name="nov/13/2019-|-18:06:02-|-BPIPA-|-5000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-675-09.02.19-2Hari2Sept19" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/13/2019
add comment=mikhmon name="nov/13/2019-|-18:50:52-|-AZDUJ-|-3000-|-192.168.12.5\
    1-|-7C:03:5E:C9:04:FB-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/13/2019
add comment=mikhmon name="nov/13/2019-|-19:10:22-|-ANSSR-|-3000-|-192.168.12.1\
    43-|-C0:87:EB:EE:62:DB-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/13/2019
add comment=mikhmon name="nov/13/2019-|-19:29:43-|-BSTWN-|-5000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/13/2019
add comment=mikhmon name="nov/13/2019-|-19:30:30-|-AYEDM-|-3000-|-192.168.12.2\
    19-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/13/2019
add comment=mikhmon name="nov/13/2019-|-20:21:37-|-AZNZS-|-3000-|-192.168.12.1\
    93-|-94:87:E0:70:1D:79-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/13/2019
add comment=mikhmon name="nov/13/2019-|-21:16:49-|-BNZTF-|-5000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/13/2019
add comment=mikhmon name="nov/13/2019-|-23:22:46-|-BJVVW-|-5000-|-192.168.12.2\
    31-|-0C:A8:A7:D5:69:D4-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/13/2019
add comment=mikhmon name="nov/14/2019-|-15:23:18-|-BYKWV-|-5000-|-192.168.12.4\
    6-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/14/2019
add comment=mikhmon name="nov/14/2019-|-17:32:41-|-BJUZH-|-5000-|-192.168.12.1\
    44-|-CC:2D:83:AA:45:CD-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/14/2019
add comment=mikhmon name="nov/14/2019-|-17:41:53-|-ARVHX-|-3000-|-192.168.12.1\
    39-|-08:7F:98:C7:BC:29-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/14/2019
add comment=mikhmon name="nov/14/2019-|-17:52:09-|-ALZBR-|-3000-|-192.168.12.1\
    40-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/14/2019
add comment=mikhmon name="nov/14/2019-|-19:46:15-|-BZMDJ-|-5000-|-192.168.12.1\
    05-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/14/2019
add comment=mikhmon name="nov/14/2019-|-19:47:30-|-BFNZV-|-5000-|-192.168.12.6\
    0-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/14/2019
add comment=mikhmon name="nov/15/2019-|-12:13:27-|-ADCLK-|-3000-|-192.168.12.1\
    24-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/15/2019
add comment=mikhmon name="nov/15/2019-|-16:07:09-|-BCWFH-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/15/2019
add comment=mikhmon name="nov/15/2019-|-18:11:39-|-BJZMF-|-5000-|-192.168.12.1\
    40-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/15/2019
add comment=mikhmon name="nov/15/2019-|-18:12:46-|-BIZKX-|-5000-|-192.168.12.1\
    39-|-08:7F:98:C7:BC:29-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/15/2019
add comment=mikhmon name="nov/15/2019-|-18:14:24-|-ABZAC-|-3000-|-192.168.12.1\
    57-|-3C:95:09:E7:6D:13-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/15/2019
add comment=mikhmon name="nov/15/2019-|-18:37:14-|-ATVPM-|-3000-|-192.168.12.1\
    86-|-18:02:AE:9F:82:7F-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/15/2019
add comment=mikhmon name="nov/15/2019-|-19:15:06-|-AHDBC-|-3000-|-192.168.12.6\
    5-|-00:0A:F5:C2:FC:7C-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/15/2019
add comment=mikhmon name="nov/15/2019-|-19:33:18-|-BUCFJ-|-5000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/15/2019
add comment=mikhmon name="nov/15/2019-|-19:44:32-|-BYAWZ-|-5000-|-192.168.12.5\
    7-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/15/2019
add comment=mikhmon name="nov/15/2019-|-20:36:30-|-AXHKJ-|-3000-|-192.168.12.4\
    1-|-08:7F:98:E1:84:ED-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/15/2019
add comment=mikhmon name="nov/16/2019-|-13:14:01-|-ARDAK-|-3000-|-192.168.12.1\
    24-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/16/2019
add comment=mikhmon name="nov/16/2019-|-15:43:52-|-BXVNH-|-5000-|-192.168.12.9\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/16/2019
add comment=mikhmon name="nov/16/2019-|-16:05:31-|-CVFNI-|-15000-|-192.168.12.\
    14-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/16/2019
add comment=mikhmon name="nov/16/2019-|-19:43:23-|-BSHDA-|-5000-|-192.168.12.2\
    6-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/16/2019
add comment=mikhmon name="nov/16/2019-|-21:28:21-|-ALYFD-|-3000-|-192.168.12.1\
    86-|-18:02:AE:9F:82:7F-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/16/2019
add comment=mikhmon name="nov/16/2019-|-21:28:22-|-AKBEL-|-3000-|-192.168.12.9\
    7-|-24:79:F3:72:43:8D-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/16/2019
add comment=mikhmon name="nov/16/2019-|-21:29:36-|-AUSZH-|-3000-|-192.168.12.9\
    4-|-C0:87:EB:CC:E6:21-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/16/2019
add comment=mikhmon name="nov/17/2019-|-00:42:35-|-BJNCN-|-5000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/17/2019
add comment=mikhmon name="nov/17/2019-|-05:32:04-|-BGVGG-|-5000-|-192.168.12.1\
    38-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/17/2019
add comment=mikhmon name="nov/17/2019-|-16:02:28-|-AVJVN-|-3000-|-192.168.12.2\
    06-|-EC:D0:9F:D5:B7:0F-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/17/2019
add comment=mikhmon name="nov/17/2019-|-16:23:35-|-BGJBY-|-5000-|-192.168.12.1\
    05-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/17/2019
add comment=mikhmon name="nov/17/2019-|-17:14:04-|-ACJMD-|-3000-|-192.168.12.1\
    24-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/17/2019
add comment=mikhmon name="nov/17/2019-|-18:02:59-|-ATXVS-|-3000-|-192.168.12.2\
    19-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/17/2019
add comment=mikhmon name="nov/17/2019-|-19:25:20-|-BJMYP-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/17/2019
add comment=mikhmon name="nov/18/2019-|-13:10:20-|-AEMVN-|-3000-|-192.168.12.1\
    86-|-18:02:AE:9F:82:7F-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/18/2019
add comment=mikhmon name="nov/18/2019-|-14:38:59-|-CAPZD-|-15000-|-192.168.12.\
    139-|-08:7F:98:C7:BC:29-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/18/2019
add comment=mikhmon name="nov/18/2019-|-16:42:53-|-CEBBX-|-15000-|-192.168.12.\
    42-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/18/2019
add comment=mikhmon name="nov/18/2019-|-17:37:39-|-CAGCA-|-15000-|-192.168.12.\
    27-|-A4:D9:90:28:BB:33-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/18/2019
add comment=mikhmon name="nov/18/2019-|-17:52:18-|-BVKNU-|-5000-|-192.168.12.1\
    40-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/18/2019
add comment=mikhmon name="nov/18/2019-|-19:50:23-|-BEFUV-|-5000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/18/2019
add comment=mikhmon name="nov/18/2019-|-19:57:22-|-BUMRH-|-5000-|-192.168.12.9\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/18/2019
add comment=mikhmon name="nov/18/2019-|-20:03:35-|-BNNEI-|-5000-|-192.168.12.2\
    6-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/18/2019
add comment=mikhmon name="nov/19/2019-|-16:05:34-|-BSEJD-|-5000-|-192.168.12.1\
    59-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/19/2019
add comment=mikhmon name="nov/19/2019-|-18:08:51-|-AVDVP-|-3000-|-192.168.12.4\
    1-|-08:7F:98:E1:84:ED-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/19/2019
add comment=mikhmon name="nov/19/2019-|-19:27:54-|-AWFNV-|-3000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/19/2019
add comment=mikhmon name="nov/19/2019-|-23:41:23-|-BGFNK-|-5000-|-192.168.12.1\
    86-|-18:02:AE:9F:82:7F-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/19/2019
add comment=mikhmon name="nov/20/2019-|-17:25:37-|-ARPLZ-|-3000-|-192.168.12.1\
    84-|-1C:7B:21:A5:C5:93-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/20/2019
add comment=mikhmon name="nov/20/2019-|-18:27:39-|-ALNWL-|-3000-|-192.168.12.1\
    57-|-3C:95:09:E7:6D:13-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/20/2019
add comment=mikhmon name="nov/20/2019-|-18:35:18-|-BRTMR-|-5000-|-192.168.12.1\
    40-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/20/2019
add comment=mikhmon name="nov/20/2019-|-19:31:52-|-BUCYW-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/20/2019
add comment=mikhmon name="nov/20/2019-|-20:07:12-|-BNSAN-|-5000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/20/2019
add comment=mikhmon name="nov/20/2019-|-20:21:36-|-BMCVM-|-5000-|-192.168.12.2\
    6-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/20/2019
add comment=mikhmon name="nov/20/2019-|-20:23:17-|-ANFYJ-|-3000-|-192.168.12.4\
    1-|-08:7F:98:E1:84:ED-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/20/2019
add comment=mikhmon name="nov/21/2019-|-12:38:12-|-BCMKM-|-5000-|-192.168.12.1\
    37-|-08:7F:98:F3:9E:7D-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/21/2019
add comment=mikhmon name="nov/21/2019-|-19:32:42-|-BDCRY-|-5000-|-192.168.12.9\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/21/2019
add comment=mikhmon name="nov/21/2019-|-20:14:19-|-BKSMB-|-5000-|-192.168.12.1\
    7-|-C0:87:EB:D5:D4:69-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/21/2019
add comment=mikhmon name="nov/21/2019-|-20:50:35-|-BYCGI-|-5000-|-192.168.12.1\
    05-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/21/2019
add comment=mikhmon name="nov/21/2019-|-20:59:34-|-BSAUN-|-5000-|-192.168.12.2\
    10-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/21/2019
add comment=mikhmon name="nov/22/2019-|-11:17:32-|-BUKZI-|-5000-|-192.168.12.1\
    59-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/22/2019
add comment=mikhmon name="nov/22/2019-|-12:18:28-|-AFBYC-|-3000-|-192.168.12.1\
    86-|-18:02:AE:9F:82:7F-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/22/2019
add comment=mikhmon name="nov/22/2019-|-16:56:12-|-CUSGK-|-15000-|-192.168.12.\
    139-|-08:7F:98:C7:BC:29-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/22/2019
add comment=mikhmon name="nov/22/2019-|-17:58:00-|-CIDAX-|-15000-|-192.168.12.\
    145-|-08:8C:2C:02:A3:A3-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/22/2019
add comment=mikhmon name="nov/22/2019-|-18:21:09-|-AYFNG-|-3000-|-192.168.12.1\
    43-|-C0:87:EB:EE:62:DB-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/22/2019
add comment=mikhmon name="nov/22/2019-|-19:06:08-|-BZJYD-|-5000-|-192.168.12.2\
    6-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/22/2019
add comment=mikhmon name="nov/22/2019-|-20:24:38-|-BKGMA-|-5000-|-192.168.12.1\
    87-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/22/2019
add comment=mikhmon name="nov/22/2019-|-20:56:30-|-BMTXU-|-5000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/22/2019
add comment=mikhmon name="nov/22/2019-|-21:02:43-|-BTVKK-|-5000-|-192.168.12.2\
    19-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/22/2019
add comment=mikhmon name="nov/23/2019-|-12:46:01-|-BYYMS-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/23/2019
add comment=mikhmon name="nov/23/2019-|-14:56:10-|-BFZVJ-|-5000-|-192.168.12.2\
    3-|-88:D5:0C:08:6B:3C-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/23/2019
add comment=mikhmon name="nov/23/2019-|-16:28:19-|-BBYVT-|-5000-|-192.168.12.1\
    97-|-08:7F:98:E1:84:ED-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/23/2019
add comment=mikhmon name="nov/23/2019-|-19:55:56-|-ADAZB-|-3000-|-192.168.12.1\
    62-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/23/2019
add comment=mikhmon name="nov/24/2019-|-05:37:11-|-ANCFT-|-3000-|-192.168.12.1\
    43-|-C0:87:EB:EE:62:DB-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/24/2019
add comment=mikhmon name="nov/24/2019-|-07:07:18-|-CHDYS-|-15000-|-192.168.12.\
    124-|-24:79:F3:6D:00:5D-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/24/2019
add comment=mikhmon name="nov/24/2019-|-07:13:31-|-CPEWI-|-15000-|-192.168.12.\
    14-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/24/2019
add comment=mikhmon name="nov/24/2019-|-07:34:13-|-BEXMY-|-5000-|-192.168.12.9\
    0-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/24/2019
add comment=mikhmon name="nov/24/2019-|-08:23:11-|-APYLD-|-3000-|-192.168.12.1\
    56-|-0C:A8:A7:3F:04:14-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/24/2019
add comment=mikhmon name="nov/24/2019-|-08:41:59-|-ADHAS-|-3000-|-192.168.12.1\
    70-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/24/2019
add comment=mikhmon name="nov/24/2019-|-14:10:51-|-BMTJS-|-5000-|-192.168.12.1\
    7-|-C0:87:EB:D5:D4:69-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/24/2019
add comment=mikhmon name="nov/24/2019-|-20:27:26-|-BPEZY-|-5000-|-192.168.12.1\
    01-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/24/2019
add comment=mikhmon name="nov/24/2019-|-21:53:48-|-BTNYV-|-5000-|-192.168.12.1\
    05-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/24/2019
add comment=mikhmon name="nov/25/2019-|-15:35:04-|-AAALR-|-3000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/25/2019
add comment=mikhmon name="nov/25/2019-|-17:12:53-|-AZUZR-|-3000-|-192.168.12.2\
    6-|-00:0A:F5:C2:FC:7C-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/25/2019
add comment=mikhmon name="nov/25/2019-|-19:19:38-|-AWMLJ-|-3000-|-192.168.12.1\
    10-|-18:02:AE:9F:24:65-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/25/2019
add comment=mikhmon name="nov/25/2019-|-19:20:38-|-AXTWE-|-3000-|-192.168.12.1\
    40-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/25/2019
add comment=mikhmon name="nov/25/2019-|-19:32:59-|-AWXMT-|-3000-|-192.168.12.4\
    1-|-CC:2D:83:90:04:D7-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/25/2019
add comment=mikhmon name="nov/26/2019-|-05:03:49-|-ASEKB-|-3000-|-192.168.12.1\
    97-|-08:7F:98:E1:84:ED-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/26/2019
add comment=mikhmon name="nov/26/2019-|-09:00:31-|-ADAGR-|-3000-|-192.168.12.1\
    80-|-84:4B:F5:2A:51:C1-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/26/2019
add comment=mikhmon name="nov/26/2019-|-15:36:59-|-APZGN-|-3000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/26/2019
add comment=mikhmon name="nov/26/2019-|-16:52:19-|-AYFBF-|-3000-|-192.168.12.9\
    0-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/26/2019
add comment=mikhmon name="nov/26/2019-|-19:27:25-|-AFFLF-|-3000-|-192.168.12.2\
    6-|-00:0A:F5:C2:FC:7C-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/26/2019
add comment=mikhmon name="nov/26/2019-|-20:18:46-|-CHCVT-|-15000-|-192.168.12.\
    42-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/26/2019
add comment=mikhmon name="nov/26/2019-|-21:29:26-|-BFEHE-|-5000-|-192.168.12.5\
    5-|-18:02:AE:9F:82:7F-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/26/2019
add comment=mikhmon name="nov/26/2019-|-21:56:53-|-AXVBJ-|-3000-|-192.168.12.1\
    05-|-08:EE:8B:F5:DA:26-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/26/2019
add comment=mikhmon name="nov/26/2019-|-22:05:04-|-BMZVJ-|-5000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/26/2019
add comment=mikhmon name="nov/27/2019-|-00:16:32-|-ADKJX-|-3000-|-192.168.12.1\
    01-|-0C:98:38:1D:99:0B-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/27/2019
add comment=mikhmon name="nov/27/2019-|-12:51:27-|-AUSZE-|-3000-|-192.168.12.2\
    10-|-70:5E:55:A6:F8:99-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/27/2019
add comment=mikhmon name="nov/27/2019-|-13:37:16-|-AYVCP-|-3000-|-192.168.12.1\
    59-|-2C:56:DC:E7:15:E1-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/27/2019
add comment=mikhmon name="nov/27/2019-|-15:38:02-|-ATDDB-|-3000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/27/2019
add comment=mikhmon name="nov/27/2019-|-19:30:05-|-AZBAG-|-3000-|-192.168.12.4\
    1-|-CC:2D:83:90:04:D7-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/27/2019
add comment=mikhmon name="nov/27/2019-|-19:40:25-|-ASRES-|-3000-|-192.168.12.2\
    6-|-00:0A:F5:C2:FC:7C-|-1d-|-1hari-|-up-880-10.12.19-1hari121019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/27/2019
add comment=mikhmon name="nov/28/2019-|-13:34:57-|-AVDCF-|-3000-|-192.168.12.1\
    70-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/28/2019
add comment=mikhmon name="nov/28/2019-|-19:18:03-|-CRWSW-|-15000-|-192.168.12.\
    90-|-F0:6D:78:42:12:1A-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/28/2019
add comment=mikhmon name="nov/28/2019-|-20:06:36-|-AAAPS-|-3000-|-192.168.12.1\
    59-|-2C:56:DC:E7:15:E1-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/28/2019
add comment=mikhmon name="nov/29/2019-|-05:47:05-|-BKMVU-|-5000-|-192.168.12.2\
    6-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/29/2019
add comment=mikhmon name="nov/29/2019-|-11:49:20-|-BFPRX-|-5000-|-192.168.12.1\
    09-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/29/2019
add comment=mikhmon name="nov/29/2019-|-12:02:20-|-AAMER-|-3000-|-192.168.12.5\
    5-|-18:02:AE:9F:82:7F-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/29/2019
add comment=mikhmon name="nov/29/2019-|-13:37:34-|-BAXEU-|-5000-|-192.168.12.9\
    6-|-1C:99:4C:E4:2D:96-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/29/2019
add comment=mikhmon name="nov/29/2019-|-17:05:02-|-CZGNU-|-15000-|-192.168.12.\
    139-|-08:7F:98:C7:BC:29-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/29/2019
add comment=mikhmon name="nov/29/2019-|-18:15:54-|-AMHTG-|-3000-|-192.168.12.1\
    40-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/29/2019
add comment=mikhmon name="nov/29/2019-|-18:46:50-|-BSGIS-|-5000-|-192.168.12.1\
    59-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/29/2019
add comment=mikhmon name="nov/29/2019-|-18:54:34-|-BWFMZ-|-5000-|-192.168.12.4\
    1-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/29/2019
add comment=mikhmon name="nov/30/2019-|-09:44:09-|-CGDNU-|-15000-|-192.168.12.\
    17-|-C0:87:EB:D5:D4:69-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/30/2019
add comment=mikhmon name="nov/30/2019-|-10:49:39-|-AIVFK-|-3000-|-192.168.12.1\
    43-|-C0:87:EB:EE:62:DB-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/30/2019
add comment=mikhmon name="nov/30/2019-|-12:27:15-|-BRPUS-|-5000-|-192.168.12.5\
    5-|-18:02:AE:9F:82:7F-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/30/2019
add comment=mikhmon name="nov/30/2019-|-13:16:54-|-ATKES-|-3000-|-192.168.12.4\
    5-|-24:79:F3:C3:C3:83-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/30/2019
add comment=mikhmon name="nov/30/2019-|-13:18:24-|-ATZLN-|-3000-|-192.168.12.4\
    6-|-CC:2D:83:8B:94:86-|-1d-|-1hari-|-up-627-11.03.19-" owner=nov2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=nov/30/2019
add comment=mikhmon name="nov/30/2019-|-14:29:10-|-BYRDR-|-5000-|-192.168.12.1\
    01-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/30/2019
add comment=mikhmon name="nov/30/2019-|-21:41:30-|-AIVTM-|-3000-|-192.168.12.1\
    40-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/30/2019
add comment=mikhmon name="nov/30/2019-|-21:42:54-|-AKABN-|-3000-|-192.168.12.8\
    9-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    nov2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    nov/30/2019
add comment=mikhmon name="dec/01/2019-|-06:23:05-|-AHJGL-|-3000-|-192.168.12.1\
    70-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-627-11.03.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/01/2019
add comment=mikhmon name="dec/01/2019-|-07:00:56-|-ALSXW-|-3000-|-192.168.12.1\
    05-|-EC:D0:9F:D5:B7:0F-|-1d-|-1hari-|-up-627-11.03.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/01/2019
add comment=mikhmon name="dec/01/2019-|-07:34:27-|-BCGUF-|-5000-|-192.168.12.2\
    6-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/01/2019
add comment=mikhmon name="dec/01/2019-|-08:23:50-|-AAWPS-|-3000-|-192.168.12.1\
    38-|-C0:EE:FB:05:DA:78-|-1d-|-1hari-|-up-627-11.03.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/01/2019
add comment=mikhmon name="dec/01/2019-|-08:34:45-|-CMSKW-|-15000-|-192.168.12.\
    14-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/01/2019
add comment=mikhmon name="dec/01/2019-|-18:58:08-|-ASHMP-|-3000-|-192.168.12.5\
    2-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/01/2019
add comment=mikhmon name="dec/01/2019-|-22:04:04-|-CBAWZ-|-15000-|-192.168.12.\
    93-|-A8:DB:03:0B:C2:F3-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/01/2019
add comment=mikhmon name="dec/01/2019-|-22:07:20-|-AYRYC-|-3000-|-192.168.12.4\
    4-|-A4:D9:90:74:41:79-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/01/2019
add comment=mikhmon name="dec/01/2019-|-22:16:43-|-ABXMJ-|-3000-|-192.168.12.1\
    64-|-3C:B6:B7:3F:E7:1F-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/01/2019
add comment=mikhmon name="dec/01/2019-|-23:48:57-|-BPRSG-|-5000-|-192.168.12.2\
    2-|-6C:D7:1F:23:3C:79-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/01/2019
add comment=mikhmon name="dec/02/2019-|-00:26:36-|-BHSVH-|-5000-|-192.168.12.1\
    66-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/02/2019
add comment=mikhmon name="dec/02/2019-|-04:15:58-|-CUFSI-|-15000-|-192.168.12.\
    104-|-A4:D9:90:28:BB:33-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/02/2019
add comment=mikhmon name="dec/02/2019-|-07:32:48-|-ASJGC-|-3000-|-192.168.12.1\
    05-|-EC:D0:9F:D5:B7:0F-|-1d-|-1hari-|-up-627-11.03.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/02/2019
add comment=mikhmon name="dec/02/2019-|-10:48:30-|-CKDHB-|-15000-|-192.168.12.\
    124-|-24:79:F3:6D:00:5D-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/02/2019
add comment=mikhmon name="dec/02/2019-|-12:47:48-|-ARMGG-|-3000-|-192.168.12.1\
    70-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-627-11.03.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/02/2019
add comment=mikhmon name="dec/02/2019-|-14:07:06-|-ABNYZ-|-3000-|-192.168.12.1\
    59-|-2C:56:DC:E7:15:E1-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/02/2019
add comment=mikhmon name="dec/02/2019-|-17:24:45-|-AHCFT-|-3000-|-192.168.12.4\
    5-|-18:89:5B:86:BB:08-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/02/2019
add comment=mikhmon name="dec/02/2019-|-17:57:40-|-AFSTV-|-3000-|-192.168.12.1\
    40-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/02/2019
add comment=mikhmon name="dec/02/2019-|-18:05:31-|-AGCDM-|-3000-|-192.168.12.1\
    38-|-C0:EE:FB:05:DA:78-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/02/2019
add comment=mikhmon name="dec/02/2019-|-18:06:14-|-ARTCR-|-3000-|-192.168.12.5\
    6-|-18:02:AE:9F:82:7F-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/02/2019
add comment=mikhmon name="dec/02/2019-|-19:10:31-|-BBXXE-|-5000-|-192.168.12.6\
    0-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/02/2019
add comment=mikhmon name="dec/02/2019-|-20:49:32-|-BZMUP-|-5000-|-192.168.12.3\
    3-|-0C:A8:A7:BF:1D:6C-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/02/2019
add comment=mikhmon name="dec/02/2019-|-22:01:33-|-CFDSY-|-15000-|-192.168.12.\
    132-|-20:5E:F7:FA:47:BC-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/02/2019
add comment=mikhmon name="dec/02/2019-|-22:14:51-|-BUKPS-|-5000-|-192.168.12.4\
    4-|-A4:D9:90:74:41:79-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/02/2019
add comment=mikhmon name="dec/03/2019-|-11:57:31-|-BFAYF-|-5000-|-192.168.12.1\
    23-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/03/2019
add comment=mikhmon name="dec/03/2019-|-16:04:19-|-AVSBN-|-3000-|-192.168.12.8\
    4-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/03/2019
add comment=mikhmon name="dec/03/2019-|-17:17:09-|-BIYPW-|-5000-|-192.168.12.9\
    7-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/03/2019
add comment=mikhmon name="dec/03/2019-|-17:32:47-|-BCAHR-|-5000-|-192.168.12.5\
    0-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/03/2019
add comment=mikhmon name="dec/03/2019-|-19:57:22-|-AFNIT-|-3000-|-192.168.12.3\
    4-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/03/2019
add comment=mikhmon name="dec/03/2019-|-20:23:26-|-BTBJB-|-5000-|-192.168.12.1\
    59-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/03/2019
add comment=mikhmon name="dec/03/2019-|-20:36:17-|-BSUMP-|-5000-|-192.168.12.5\
    1-|-18:89:5B:86:BB:08-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/03/2019
add comment=mikhmon name="dec/03/2019-|-21:05:30-|-BBIAF-|-5000-|-192.168.12.1\
    38-|-4C:1A:3D:83:30:70-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/03/2019
add comment=mikhmon name="dec/03/2019-|-21:56:30-|-BFEYM-|-5000-|-192.168.12.2\
    8-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/03/2019
add comment=mikhmon name="dec/04/2019-|-01:11:26-|-AHFZT-|-3000-|-192.168.12.5\
    2-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/04/2019
add comment=mikhmon name="dec/04/2019-|-16:16:03-|-BYVFY-|-5000-|-192.168.12.4\
    3-|-64:CC:2E:23:2F:F8-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/04/2019
add comment=mikhmon name="dec/04/2019-|-16:30:12-|-AGJIM-|-3000-|-192.168.12.5\
    5-|-F4:D6:20:95:A6:64-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/04/2019
add comment=mikhmon name="dec/04/2019-|-18:30:11-|-BHSGF-|-5000-|-192.168.12.9\
    0-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/04/2019
add comment=mikhmon name="dec/04/2019-|-20:31:03-|-ARIFR-|-3000-|-192.168.12.2\
    54-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/04/2019
add comment=mikhmon name="dec/05/2019-|-12:29:59-|-ACKYN-|-3000-|-192.168.12.8\
    2-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/05/2019
add comment=mikhmon name="dec/05/2019-|-16:03:28-|-AGTFR-|-3000-|-192.168.12.3\
    5-|-A4:D9:90:74:41:79-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/05/2019
add comment=mikhmon name="dec/05/2019-|-18:21:11-|-BMNEJ-|-5000-|-192.168.12.7\
    6-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/05/2019
add comment=mikhmon name="dec/05/2019-|-20:11:15-|-BCUMG-|-5000-|-192.168.12.1\
    9-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/05/2019
add comment=mikhmon name="dec/05/2019-|-20:35:48-|-AGEAR-|-3000-|-192.168.12.2\
    54-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/05/2019
add comment=mikhmon name="dec/05/2019-|-21:27:19-|-AXWPB-|-3000-|-192.168.12.4\
    1-|-6C:D7:1F:23:3C:79-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/05/2019
add comment=mikhmon name="dec/06/2019-|-11:07:59-|-BBNTU-|-5000-|-192.168.12.1\
    59-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/06/2019
add comment=mikhmon name="dec/06/2019-|-12:11:21-|-BAKYF-|-5000-|-192.168.12.2\
    32-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/06/2019
add comment=mikhmon name="dec/06/2019-|-12:38:22-|-BNXNK-|-5000-|-192.168.12.6\
    0-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/06/2019
add comment=mikhmon name="dec/06/2019-|-16:59:52-|-BTBYC-|-5000-|-192.168.12.3\
    0-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/06/2019
add comment=mikhmon name="dec/06/2019-|-17:42:03-|-AUDNZ-|-3000-|-192.168.12.5\
    6-|-18:02:AE:9F:82:7F-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/06/2019
add comment=mikhmon name="dec/06/2019-|-17:46:05-|-BTBME-|-5000-|-192.168.12.6\
    4-|-08:7F:98:C7:BC:29-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/06/2019
add comment=mikhmon name="dec/06/2019-|-18:07:58-|-APGAP-|-3000-|-192.168.12.3\
    5-|-A4:D9:90:74:41:79-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/06/2019
add comment=mikhmon name="dec/06/2019-|-18:09:59-|-BRNMP-|-5000-|-192.168.12.5\
    1-|-18:89:5B:86:BB:08-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/06/2019
add comment=mikhmon name="dec/06/2019-|-19:21:45-|-BTJGB-|-5000-|-192.168.12.9\
    0-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/06/2019
add comment=mikhmon name="dec/06/2019-|-20:15:58-|-AZPGC-|-3000-|-192.168.12.8\
    2-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/06/2019
add comment=mikhmon name="dec/06/2019-|-20:19:04-|-BFIJR-|-5000-|-192.168.12.1\
    15-|-E0:99:71:C7:B6:9F-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/06/2019
add comment=mikhmon name="dec/06/2019-|-21:32:17-|-AXSSG-|-3000-|-192.168.12.4\
    1-|-6C:D7:1F:23:3C:79-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/06/2019
add comment=mikhmon name="dec/07/2019-|-10:31:10-|-AVMNM-|-3000-|-192.168.12.1\
    43-|-C0:87:EB:EE:62:DB-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/07/2019
add comment=mikhmon name="dec/07/2019-|-12:53:51-|-AZNGF-|-3000-|-192.168.12.2\
    7-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/07/2019
add comment=mikhmon name="dec/07/2019-|-16:02:49-|-AKMVN-|-3000-|-192.168.12.2\
    9-|-EC:D0:9F:D5:B7:0F-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/07/2019
add comment=mikhmon name="dec/07/2019-|-16:59:11-|-BNVPD-|-5000-|-192.168.12.4\
    3-|-64:CC:2E:23:2F:F8-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/07/2019
add comment=mikhmon name="dec/07/2019-|-19:35:50-|-ATUGE-|-3000-|-192.168.12.9\
    6-|-78:24:AF:E8:5D:B8-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/07/2019
add comment=mikhmon name="dec/07/2019-|-22:03:45-|-AMAZI-|-3000-|-192.168.12.3\
    6-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/07/2019
add comment=mikhmon name="dec/07/2019-|-22:10:44-|-BYPMR-|-5000-|-192.168.12.4\
    1-|-6C:D7:1F:23:3C:79-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/07/2019
add comment=mikhmon name="dec/08/2019-|-01:18:54-|-BHRZV-|-5000-|-192.168.12.3\
    5-|-A4:D9:90:74:41:79-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/08/2019
add comment=mikhmon name="dec/08/2019-|-07:34:53-|-ASXUK-|-3000-|-192.168.12.2\
    54-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/08/2019
add comment=mikhmon name="dec/08/2019-|-08:26:54-|-BFCSK-|-5000-|-192.168.12.5\
    0-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/08/2019
add comment=mikhmon name="dec/08/2019-|-08:37:21-|-ARJFM-|-3000-|-192.168.12.1\
    46-|-1C:7B:21:A5:C5:93-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/08/2019
add comment=mikhmon name="dec/08/2019-|-11:17:12-|-CEEFK-|-15000-|-192.168.12.\
    46-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/08/2019
add comment=mikhmon name="dec/08/2019-|-13:48:11-|-BZJJJ-|-5000-|-192.168.12.7\
    5-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/08/2019
add comment=mikhmon name="dec/08/2019-|-13:50:35-|-AYKXS-|-3000-|-192.168.12.5\
    6-|-18:02:AE:9F:82:7F-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/08/2019
add comment=mikhmon name="dec/08/2019-|-18:11:20-|-APKTA-|-3000-|-192.168.12.8\
    2-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/08/2019
add comment=mikhmon name="dec/08/2019-|-18:34:43-|-AARSX-|-3000-|-192.168.12.1\
    57-|-24:79:F3:52:26:EB-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/08/2019
add comment=mikhmon name="dec/08/2019-|-19:41:52-|-BGYBG-|-5000-|-192.168.12.1\
    28-|-C0:87:EB:D5:D4:69-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/08/2019
add comment=mikhmon name="dec/08/2019-|-19:44:14-|-BIIRN-|-5000-|-192.168.12.4\
    7-|-CC:2D:83:AA:45:CD-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/08/2019
add comment=mikhmon name="dec/08/2019-|-20:00:11-|-ACWAY-|-3000-|-192.168.12.1\
    69-|-70:5E:55:A6:F8:99-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/08/2019
add comment=mikhmon name="dec/08/2019-|-20:00:34-|-AJPMH-|-3000-|-192.168.12.1\
    9-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/08/2019
add comment=mikhmon name="dec/08/2019-|-21:15:18-|-BHFPV-|-5000-|-192.168.12.6\
    4-|-08:7F:98:C7:BC:29-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/08/2019
add comment=mikhmon name="dec/08/2019-|-21:17:19-|-BBPIR-|-5000-|-192.168.12.1\
    16-|-4C:1A:3D:83:30:70-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/08/2019
add comment=mikhmon name="dec/08/2019-|-22:11:55-|-BBVYT-|-5000-|-192.168.12.1\
    90-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/08/2019
add comment=mikhmon name="dec/08/2019-|-22:15:05-|-CMRYA-|-15000-|-192.168.12.\
    37-|-A8:DB:03:0B:C2:F3-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/08/2019
add comment=mikhmon name="dec/08/2019-|-22:27:27-|-AICEX-|-3000-|-192.168.12.9\
    6-|-78:24:AF:E8:5D:B8-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/08/2019
add comment=mikhmon name="dec/09/2019-|-07:19:19-|-BSCWS-|-5000-|-192.168.12.3\
    0-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/09/2019
add comment=mikhmon name="dec/09/2019-|-12:43:23-|-AKUUC-|-3000-|-192.168.12.2\
    16-|-C0:EE:FB:05:DA:78-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/09/2019
add comment=mikhmon name="dec/09/2019-|-13:23:21-|-BBJHS-|-5000-|-192.168.12.2\
    22-|-3C:B6:B7:3F:E7:1F-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/09/2019
add comment=mikhmon name="dec/09/2019-|-13:50:56-|-ANAFB-|-3000-|-192.168.12.5\
    1-|-18:89:5B:86:BB:08-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/09/2019
add comment=mikhmon name="dec/09/2019-|-16:45:09-|-AYUCT-|-3000-|-192.168.12.1\
    85-|-2C:56:DC:E7:15:E1-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/09/2019
add comment=mikhmon name="dec/09/2019-|-17:12:40-|-BRGEG-|-5000-|-192.168.12.1\
    5-|-24:79:F3:6D:00:5D-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/09/2019
add comment=mikhmon name="dec/09/2019-|-19:21:05-|-AENJN-|-3000-|-192.168.12.2\
    38-|-3C:95:09:E7:6D:13-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/09/2019
add comment=mikhmon name="dec/09/2019-|-19:24:12-|-AMPJM-|-3000-|-192.168.12.2\
    40-|-08:7F:98:E1:84:ED-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/09/2019
add comment=mikhmon name="dec/09/2019-|-20:04:17-|-AGASA-|-3000-|-192.168.12.1\
    9-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/09/2019
add comment=mikhmon name="dec/09/2019-|-20:36:47-|-AKDUB-|-3000-|-192.168.12.8\
    2-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/09/2019
add comment=mikhmon name="dec/09/2019-|-21:27:12-|-CSUTM-|-15000-|-192.168.12.\
    115-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/09/2019
add comment=mikhmon name="dec/09/2019-|-21:59:16-|-BEKIY-|-5000-|-192.168.12.2\
    48-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/09/2019
add comment=mikhmon name="dec/09/2019-|-22:49:02-|-BBTXF-|-5000-|-192.168.12.4\
    1-|-6C:D7:1F:23:3C:79-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/09/2019
add comment=mikhmon name="dec/10/2019-|-01:22:43-|-CUNHD-|-15000-|-192.168.12.\
    35-|-A4:D9:90:74:41:79-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/10/2019
add comment=mikhmon name="dec/10/2019-|-11:24:31-|-BEEWD-|-5000-|-192.168.12.5\
    0-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/10/2019
add comment=mikhmon name="dec/10/2019-|-12:01:59-|-AVWPP-|-3000-|-192.168.12.1\
    57-|-24:79:F3:52:26:EB-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/10/2019
add comment=mikhmon name="dec/10/2019-|-13:54:58-|-BVJCD-|-5000-|-192.168.12.3\
    1-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/10/2019
add comment=mikhmon name="dec/10/2019-|-13:56:08-|-AFJDS-|-3000-|-192.168.12.5\
    1-|-18:89:5B:86:BB:08-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/10/2019
add comment=mikhmon name="dec/10/2019-|-19:18:54-|-AEPGV-|-3000-|-192.168.12.2\
    54-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/10/2019
add comment=mikhmon name="dec/10/2019-|-21:04:23-|-AEYNS-|-3000-|-192.168.12.1\
    9-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/10/2019
add comment=mikhmon name="dec/10/2019-|-21:30:42-|-BBXSV-|-5000-|-192.168.12.6\
    4-|-08:7F:98:C7:BC:29-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/10/2019
add comment=mikhmon name="dec/10/2019-|-21:44:05-|-AAWPP-|-3000-|-192.168.12.5\
    6-|-18:02:AE:9F:82:7F-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/10/2019
add comment=mikhmon name="dec/11/2019-|-06:40:38-|-ARASH-|-3000-|-192.168.12.1\
    16-|-4C:1A:3D:83:30:70-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/11/2019
add comment=mikhmon name="dec/11/2019-|-10:05:47-|-BVJYU-|-5000-|-192.168.12.4\
    3-|-64:CC:2E:23:2F:F8-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/11/2019
add comment=mikhmon name="dec/11/2019-|-13:45:59-|-BDSAA-|-5000-|-192.168.12.3\
    0-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/11/2019
add comment=mikhmon name="dec/11/2019-|-15:43:56-|-AXNHE-|-3000-|-192.168.12.5\
    1-|-18:89:5B:86:BB:08-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/11/2019
add comment=mikhmon name="dec/11/2019-|-17:01:34-|-AGZGI-|-3000-|-192.168.12.2\
    22-|-3C:B6:B7:3F:E7:1F-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/11/2019
add comment=mikhmon name="dec/11/2019-|-19:15:18-|-ARGEG-|-3000-|-192.168.12.9\
    5-|-A4:C9:39:E3:4F:25-|-1d-|-1hari-|-up-" owner=dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/11/2019
add comment=mikhmon name="dec/11/2019-|-19:33:54-|-BAAEB-|-5000-|-192.168.12.9\
    4-|-1C:87:2C:3F:F5:68-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/11/2019
add comment=mikhmon name="dec/11/2019-|-20:12:25-|-BWHWE-|-5000-|-192.168.12.1\
    01-|-08:7F:98:E1:84:ED-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/11/2019
add comment=mikhmon name="dec/11/2019-|-21:31:23-|-BSIJH-|-5000-|-192.168.12.1\
    90-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/11/2019
add comment=mikhmon name="dec/11/2019-|-21:43:55-|-BHWSF-|-5000-|-192.168.12.1\
    9-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/11/2019
add comment=mikhmon name="dec/11/2019-|-21:48:06-|-ATVGB-|-3000-|-192.168.12.5\
    6-|-18:02:AE:9F:82:7F-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/11/2019
add comment=mikhmon name="dec/11/2019-|-23:39:52-|-BIPRM-|-5000-|-192.168.12.1\
    69-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/11/2019
add comment=mikhmon name="dec/12/2019-|-10:37:13-|-AVHGT-|-3000-|-192.168.12.8\
    2-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/12/2019
add comment=mikhmon name="dec/12/2019-|-12:09:37-|-BPEPF-|-5000-|-192.168.12.5\
    0-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/12/2019
add comment=mikhmon name="dec/12/2019-|-12:19:27-|-ASUMJ-|-3000-|-192.168.12.2\
    54-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/12/2019
add comment=mikhmon name="dec/12/2019-|-12:29:57-|-AGEED-|-3000-|-192.168.12.6\
    0-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/12/2019
add comment=mikhmon name="dec/12/2019-|-12:55:21-|-AJDID-|-3000-|-192.168.12.4\
    1-|-6C:D7:1F:23:3C:79-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/12/2019
add comment=mikhmon name="dec/12/2019-|-16:38:54-|-AABCP-|-3000-|-192.168.12.5\
    1-|-18:89:5B:86:BB:08-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/12/2019
add comment=mikhmon name="dec/12/2019-|-19:35:50-|-ADMNV-|-3000-|-192.168.12.2\
    16-|-C0:EE:FB:05:DA:78-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/12/2019
add comment=mikhmon name="dec/12/2019-|-19:56:51-|-BEIWI-|-5000-|-192.168.12.2\
    00-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/12/2019
add comment=mikhmon name="dec/12/2019-|-20:53:55-|-BRWGN-|-5000-|-192.168.12.1\
    17-|-20:5E:F7:FA:47:BC-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/12/2019
add comment=mikhmon name="dec/12/2019-|-21:36:36-|-AITCR-|-3000-|-192.168.12.2\
    22-|-3C:B6:B7:3F:E7:1F-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/12/2019
add comment=mikhmon name="dec/12/2019-|-21:36:48-|-AHHHX-|-3000-|-192.168.12.2\
    45-|-08:4A:CF:55:2F:FC-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/12/2019
add comment=mikhmon name="dec/13/2019-|-09:22:15-|-CJXKE-|-15000-|-192.168.12.\
    64-|-08:7F:98:C7:BC:29-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/13/2019
add comment=mikhmon name="dec/13/2019-|-11:41:29-|-BGHSM-|-5000-|-192.168.12.4\
    3-|-64:CC:2E:23:2F:F8-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/13/2019
add comment=mikhmon name="dec/13/2019-|-12:00:42-|-BNWRX-|-5000-|-192.168.12.1\
    85-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/13/2019
add comment=mikhmon name="dec/13/2019-|-15:01:20-|-ACPVS-|-3000-|-192.168.12.6\
    0-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/13/2019
add comment=mikhmon name="dec/13/2019-|-18:13:21-|-ASSWR-|-3000-|-192.168.12.5\
    1-|-18:89:5B:86:BB:08-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/13/2019
add comment=mikhmon name="dec/13/2019-|-19:33:52-|-AAEGE-|-3000-|-192.168.12.2\
    54-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/13/2019
add comment=mikhmon name="dec/13/2019-|-19:37:12-|-AGHNF-|-3000-|-192.168.12.8\
    2-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/13/2019
add comment=mikhmon name="dec/13/2019-|-21:36:17-|-BTFMK-|-5000-|-192.168.12.4\
    1-|-6C:D7:1F:23:3C:79-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/13/2019
add comment=mikhmon name="dec/13/2019-|-21:42:34-|-BFWHD-|-5000-|-192.168.12.2\
    22-|-3C:B6:B7:3F:E7:1F-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/13/2019
add comment=mikhmon name="dec/13/2019-|-23:43:30-|-BXVZC-|-5000-|-192.168.12.1\
    69-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/13/2019
add comment=mikhmon name="dec/14/2019-|-01:21:25-|-BVVNZ-|-5000-|-192.168.12.6\
    3-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/14/2019
add comment=mikhmon name="dec/14/2019-|-07:30:10-|-BXYAU-|-5000-|-192.168.12.3\
    0-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/14/2019
add comment=mikhmon name="dec/14/2019-|-07:35:24-|-ASAJC-|-3000-|-192.168.12.2\
    16-|-C0:EE:FB:05:DA:78-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/14/2019
add comment=mikhmon name="dec/14/2019-|-10:36:49-|-AIGII-|-3000-|-192.168.12.8\
    0-|-C0:87:EB:EE:62:DB-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/14/2019
add comment=mikhmon name="dec/14/2019-|-11:24:15-|-AEBEH-|-3000-|-192.168.12.2\
    7-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/14/2019
add comment=mikhmon name="dec/14/2019-|-12:03:31-|-AXDKG-|-3000-|-192.168.12.7\
    3-|-1C:99:4C:E4:2D:96-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/14/2019
add comment=mikhmon name="dec/14/2019-|-12:55:29-|-BUYHS-|-5000-|-192.168.12.1\
    9-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/14/2019
add comment=mikhmon name="dec/14/2019-|-13:32:46-|-BRJWY-|-5000-|-192.168.12.5\
    0-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/14/2019
add comment=mikhmon name="dec/14/2019-|-16:15:01-|-APWPX-|-3000-|-192.168.12.1\
    24-|-EC:D0:9F:D5:B7:0F-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/14/2019
add comment=mikhmon name="dec/14/2019-|-18:13:55-|-BGKMR-|-5000-|-192.168.12.1\
    46-|-A4:D9:90:63:AF:9D-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/14/2019
add comment=mikhmon name="dec/14/2019-|-19:54:40-|-BEEWG-|-5000-|-192.168.12.2\
    54-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/14/2019
add comment=mikhmon name="dec/14/2019-|-20:05:46-|-AVDGR-|-3000-|-192.168.12.4\
    5-|-18:02:AE:9F:82:7F-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/14/2019
add comment=mikhmon name="dec/14/2019-|-21:20:19-|-BNWHI-|-5000-|-192.168.12.1\
    90-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/14/2019
add comment=mikhmon name="dec/14/2019-|-21:53:39-|-BZSTV-|-5000-|-192.168.12.1\
    25-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/14/2019
add comment=mikhmon name="dec/14/2019-|-21:56:05-|-AHIUM-|-3000-|-192.168.12.1\
    01-|-08:7F:98:E1:84:ED-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/14/2019
add comment=mikhmon name="dec/14/2019-|-23:52:21-|-BNFTE-|-5000-|-192.168.12.5\
    1-|-18:89:5B:86:BB:08-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/14/2019
add comment=mikhmon name="dec/15/2019-|-08:02:34-|-ACCUC-|-3000-|-192.168.12.4\
    9-|-D0:9C:7A:03:E1:9C-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/15/2019
add comment=mikhmon name="dec/15/2019-|-10:46:35-|-BECCB-|-5000-|-192.168.12.7\
    5-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/15/2019
add comment=mikhmon name="dec/15/2019-|-10:53:28-|-BMUNY-|-5000-|-192.168.12.1\
    86-|-24:79:F3:52:26:EB-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/15/2019
add comment=mikhmon name="dec/15/2019-|-10:53:41-|-AYTPZ-|-3000-|-192.168.12.1\
    85-|-0C:98:38:FC:E3:AF-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/15/2019
add comment=mikhmon name="dec/15/2019-|-10:53:57-|-ASBUJ-|-3000-|-192.168.12.8\
    0-|-C0:87:EB:EE:62:DB-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/15/2019
add comment=mikhmon name="dec/15/2019-|-11:23:29-|-CCMIY-|-15000-|-192.168.12.\
    117-|-20:5E:F7:FA:47:BC-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/15/2019
add comment=mikhmon name="dec/15/2019-|-11:38:30-|-ABVHP-|-3000-|-192.168.12.2\
    16-|-C0:EE:FB:05:DA:78-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/15/2019
add comment=mikhmon name="dec/15/2019-|-11:45:53-|-CMFBD-|-15000-|-192.168.12.\
    43-|-64:CC:2E:23:2F:F8-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/15/2019
add comment=mikhmon name="dec/15/2019-|-14:03:55-|-BDYWF-|-5000-|-192.168.12.6\
    0-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/15/2019
add comment=mikhmon name="dec/15/2019-|-14:34:26-|-BXVDP-|-5000-|-192.168.12.8\
    2-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/15/2019
add comment=mikhmon name="dec/15/2019-|-16:26:17-|-CNHGG-|-15000-|-192.168.12.\
    46-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/15/2019
add comment=mikhmon name="dec/15/2019-|-19:16:02-|-BCVCJ-|-5000-|-192.168.12.8\
    3-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/15/2019
add comment=mikhmon name="dec/15/2019-|-19:19:02-|-BHSVE-|-5000-|-192.168.12.2\
    00-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/15/2019
add comment=mikhmon name="dec/15/2019-|-20:52:00-|-BJRXC-|-5000-|-192.168.12.4\
    5-|-18:02:AE:9F:82:7F-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/15/2019
add comment=mikhmon name="dec/15/2019-|-21:13:59-|-BFBIA-|-5000-|-192.168.12.2\
    32-|-C4:0B:CB:E3:2B:3C-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/15/2019
add comment=mikhmon name="dec/15/2019-|-21:41:00-|-CFTII-|-15000-|-192.168.12.\
    141-|-08:8C:2C:02:A3:A3-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/15/2019
add comment=mikhmon name="dec/15/2019-|-21:52:51-|-BUCVV-|-5000-|-192.168.12.4\
    1-|-6C:D7:1F:23:3C:79-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/15/2019
add comment=mikhmon name="dec/15/2019-|-22:21:31-|-BTAJD-|-5000-|-192.168.12.3\
    7-|-A8:DB:03:0B:C2:F3-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/15/2019
add comment=mikhmon name="dec/16/2019-|-09:47:28-|-BMSXB-|-5000-|-192.168.12.2\
    49-|-70:8B:CD:73:EE:C0-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/16/2019
add comment=mikhmon name="dec/16/2019-|-12:31:34-|-CSMNR-|-15000-|-192.168.12.\
    128-|-C0:87:EB:D5:D4:69-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/16/2019
add comment=mikhmon name="dec/16/2019-|-13:58:58-|-AAREW-|-3000-|-192.168.12.2\
    7-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/16/2019
add comment=mikhmon name="dec/16/2019-|-15:47:59-|-BVRKP-|-5000-|-192.168.12.2\
    21-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/16/2019
add comment=mikhmon name="dec/16/2019-|-18:05:19-|-BDSEJ-|-5000-|-192.168.12.5\
    0-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/16/2019
add comment=mikhmon name="dec/16/2019-|-18:35:26-|-BMVFF-|-5000-|-192.168.12.2\
    16-|-C0:EE:FB:05:DA:78-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/16/2019
add comment=mikhmon name="dec/16/2019-|-18:43:20-|-BDDUB-|-5000-|-192.168.12.3\
    0-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/16/2019
add comment=mikhmon name="dec/17/2019-|-01:26:22-|-AYXGJ-|-3000-|-192.168.12.3\
    5-|-A4:D9:90:74:41:79-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/17/2019
add comment=mikhmon name="dec/17/2019-|-09:52:44-|-ARVKY-|-3000-|-192.168.12.6\
    2-|-84:4B:F5:2A:51:C1-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/17/2019
add comment=mikhmon name="dec/17/2019-|-10:18:38-|-AWDIZ-|-3000-|-192.168.12.6\
    6-|-28:31:66:9A:D1:99-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/17/2019
add comment=mikhmon name="dec/17/2019-|-11:02:45-|-BYRAK-|-5000-|-192.168.12.7\
    5-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/17/2019
add comment=mikhmon name="dec/17/2019-|-14:07:22-|-BKIPT-|-5000-|-192.168.12.6\
    0-|-00:0A:00:D5:C3:D8-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/17/2019
add comment=mikhmon name="dec/17/2019-|-15:05:25-|-BGREA-|-5000-|-192.168.12.5\
    1-|-18:89:5B:86:BB:08-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/17/2019
add comment=mikhmon name="dec/17/2019-|-16:53:51-|-ARVWW-|-3000-|-192.168.12.2\
    7-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/17/2019
add comment=mikhmon name="dec/17/2019-|-18:08:47-|-ANKDT-|-3000-|-192.168.12.2\
    54-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/17/2019
add comment=mikhmon name="dec/17/2019-|-18:42:17-|-AYBKZ-|-3000-|-192.168.12.1\
    07-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/17/2019
add comment=mikhmon name="dec/17/2019-|-19:23:24-|-CMTCT-|-15000-|-192.168.12.\
    115-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/17/2019
add comment=mikhmon name="dec/17/2019-|-19:32:26-|-BCXBS-|-5000-|-192.168.12.2\
    00-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-625-10.29.19-2hari291019" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/17/2019
add comment=mikhmon name="dec/17/2019-|-20:02:29-|-ASGDG-|-3000-|-192.168.12.8\
    3-|-2C:56:DC:E7:15:E1-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/17/2019
add comment=mikhmon name="dec/17/2019-|-20:18:04-|-AKTAX-|-3000-|-192.168.12.7\
    7-|-00:0A:F5:4E:69:4C-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/17/2019
add comment=mikhmon name="dec/17/2019-|-22:29:29-|-CENHZ-|-15000-|-192.168.12.\
    37-|-A8:DB:03:0B:C2:F3-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/17/2019
add comment=mikhmon name="dec/17/2019-|-23:44:38-|-BNGNN-|-5000-|-192.168.12.4\
    5-|-18:02:AE:9F:82:7F-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/17/2019
add comment=mikhmon name="dec/18/2019-|-00:21:30-|-BWWTF-|-5000-|-192.168.12.1\
    90-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/18/2019
add comment=mikhmon name="dec/18/2019-|-07:37:31-|-CMMGG-|-15000-|-192.168.12.\
    35-|-A4:D9:90:74:41:79-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/18/2019
add comment=mikhmon name="dec/18/2019-|-12:26:17-|-BJVPM-|-5000-|-192.168.12.4\
    1-|-6C:D7:1F:23:3C:79-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/18/2019
add comment=mikhmon name="dec/18/2019-|-15:12:20-|-CNDGA-|-15000-|-192.168.12.\
    86-|-A4:D9:90:28:BB:33-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/18/2019
add comment=mikhmon name="dec/18/2019-|-15:35:56-|-BEVBK-|-5000-|-192.168.12.1\
    16-|-4C:1A:3D:83:30:70-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/18/2019
add comment=mikhmon name="dec/18/2019-|-17:26:03-|-AJTHK-|-3000-|-192.168.12.8\
    3-|-2C:56:DC:E7:15:E1-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/18/2019
add comment=mikhmon name="dec/18/2019-|-18:06:55-|-AZPRS-|-3000-|-192.168.12.1\
    9-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/18/2019
add comment=mikhmon name="dec/18/2019-|-19:20:29-|-ARUAK-|-3000-|-192.168.12.5\
    0-|-00:0A:F5:C2:FC:7C-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/18/2019
add comment=mikhmon name="dec/18/2019-|-19:38:13-|-AJMFG-|-3000-|-192.168.12.3\
    0-|-0C:98:38:1D:99:0B-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/18/2019
add comment=mikhmon name="dec/18/2019-|-20:32:04-|-AFKHB-|-3000-|-192.168.12.1\
    7-|-70:5E:55:A6:F8:99-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/18/2019
add comment=mikhmon name="dec/18/2019-|-20:56:28-|-AUCCI-|-3000-|-192.168.12.1\
    95-|-00:27:15:53:63:97-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/18/2019
add comment=mikhmon name="dec/19/2019-|-12:04:39-|-AUVIG-|-3000-|-192.168.12.2\
    54-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/19/2019
add comment=mikhmon name="dec/19/2019-|-13:23:54-|-AGAAN-|-3000-|-192.168.12.1\
    67-|-1C:7B:21:A5:C5:93-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/19/2019
add comment=mikhmon name="dec/19/2019-|-13:33:48-|-AGJTY-|-3000-|-192.168.12.2\
    16-|-C0:EE:FB:05:DA:78-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/19/2019
add comment=mikhmon name="dec/19/2019-|-13:39:07-|-ASPVZ-|-3000-|-192.168.12.7\
    5-|-08:EE:8B:F5:DA:26-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/19/2019
add comment=mikhmon name="dec/19/2019-|-14:31:07-|-ACXNU-|-3000-|-192.168.12.6\
    0-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/19/2019
add comment=mikhmon name="dec/19/2019-|-17:00:39-|-BHSCU-|-5000-|-192.168.12.8\
    2-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/19/2019
add comment=mikhmon name="dec/19/2019-|-17:32:42-|-AISPV-|-3000-|-192.168.12.2\
    7-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/19/2019
add comment=mikhmon name="dec/19/2019-|-18:04:13-|-AKSEN-|-3000-|-192.168.12.8\
    3-|-2C:56:DC:E7:15:E1-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/19/2019
add comment=mikhmon name="dec/19/2019-|-18:09:48-|-APTTW-|-3000-|-192.168.12.1\
    9-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/19/2019
add comment=mikhmon name="dec/19/2019-|-18:41:48-|-BYHMV-|-5000-|-192.168.12.5\
    1-|-18:89:5B:86:BB:08-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/19/2019
add comment=mikhmon name="dec/19/2019-|-19:28:48-|-AWDNK-|-3000-|-192.168.12.5\
    0-|-00:0A:F5:C2:FC:7C-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/19/2019
add comment=mikhmon name="dec/19/2019-|-20:58:04-|-ADKMY-|-3000-|-192.168.12.1\
    7-|-70:5E:55:A6:F8:99-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/19/2019
add comment=mikhmon name="dec/19/2019-|-21:52:50-|-AHIDG-|-3000-|-192.168.12.3\
    0-|-0C:98:38:1D:99:0B-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/19/2019
add comment=mikhmon name="dec/20/2019-|-10:37:15-|-AEBSI-|-3000-|-192.168.12.9\
    0-|-CC:2D:83:AA:45:CD-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/20/2019
add comment=mikhmon name="dec/20/2019-|-12:31:38-|-BRKEF-|-5000-|-192.168.12.2\
    44-|-6C:D7:1F:23:3C:79-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/20/2019
add comment=mikhmon name="dec/20/2019-|-13:44:48-|-AHVNZ-|-3000-|-192.168.12.7\
    5-|-08:EE:8B:F5:DA:26-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/20/2019
add comment=mikhmon name="dec/20/2019-|-14:37:59-|-AWUZD-|-3000-|-192.168.12.4\
    5-|-18:02:AE:9F:82:7F-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/20/2019
add comment=mikhmon name="dec/20/2019-|-19:26:09-|-AFITZ-|-3000-|-192.168.12.2\
    00-|-F4:60:E2:30:CF:98-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/20/2019
add comment=mikhmon name="dec/20/2019-|-19:26:26-|-AHYCJ-|-3000-|-192.168.12.6\
    0-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/20/2019
add comment=mikhmon name="dec/20/2019-|-19:29:11-|-ACHWC-|-3000-|-192.168.12.2\
    54-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/20/2019
add comment=mikhmon name="dec/20/2019-|-19:32:01-|-AKKIX-|-3000-|-192.168.12.8\
    3-|-2C:56:DC:E7:15:E1-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/20/2019
add comment=mikhmon name="dec/20/2019-|-20:03:47-|-AUYTI-|-3000-|-192.168.12.6\
    6-|-7C:03:5E:C9:04:FB-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/20/2019
add comment=mikhmon name="dec/20/2019-|-20:09:45-|-ANAJP-|-3000-|-192.168.12.5\
    0-|-00:0A:F5:C2:FC:7C-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/20/2019
add comment=mikhmon name="dec/20/2019-|-20:55:24-|-ACTID-|-3000-|-192.168.12.1\
    95-|-00:27:15:53:63:97-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/20/2019
add comment=mikhmon name="dec/20/2019-|-20:56:29-|-CCYDH-|-15000-|-192.168.12.\
    64-|-08:7F:98:C7:BC:29-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/20/2019
add comment=mikhmon name="dec/20/2019-|-21:25:24-|-ABPHK-|-3000-|-192.168.12.6\
    7-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/20/2019
add comment=mikhmon name="dec/20/2019-|-21:28:33-|-BAIKW-|-5000-|-192.168.12.1\
    90-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/20/2019
add comment=mikhmon name="dec/20/2019-|-23:43:40-|-AFUED-|-3000-|-192.168.12.3\
    0-|-0C:98:38:1D:99:0B-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/20/2019
add comment=mikhmon name="dec/21/2019-|-01:24:11-|-BIHGE-|-5000-|-192.168.12.6\
    3-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/21/2019
add comment=mikhmon name="dec/21/2019-|-09:59:29-|-CTFJT-|-15000-|-192.168.12.\
    151-|-24:79:F3:6D:00:5D-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/21/2019
add comment=mikhmon name="dec/21/2019-|-10:19:49-|-ABFUC-|-3000-|-192.168.12.8\
    3-|-2C:56:DC:E7:15:E1-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/21/2019
add comment=mikhmon name="dec/21/2019-|-11:55:33-|-BDWAC-|-5000-|-192.168.12.2\
    7-|-08:7F:98:B0:5B:A1-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/21/2019
add comment=mikhmon name="dec/21/2019-|-13:17:22-|-AYDTW-|-3000-|-192.168.12.1\
    55-|-34:E9:11:3B:E0:B3-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/21/2019
add comment=mikhmon name="dec/21/2019-|-13:50:25-|-AKKIX-|-3000-|-192.168.12.1\
    7-|-70:5E:55:A6:F8:99-|-1d-|-1hari-|-up-" owner=dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/21/2019
add comment=mikhmon name="dec/21/2019-|-14:09:39-|-AMYVN-|-3000-|-192.168.12.9\
    0-|-CC:2D:83:AA:45:CD-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/21/2019
add comment=mikhmon name="dec/21/2019-|-16:01:48-|-BKDUF-|-5000-|-192.168.12.1\
    57-|-00:27:15:57:61:2A-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/21/2019
add comment=mikhmon name="dec/21/2019-|-18:13:18-|-BZYUN-|-5000-|-192.168.12.8\
    2-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/21/2019
add comment=mikhmon name="dec/21/2019-|-19:29:15-|-BYZYK-|-5000-|-192.168.12.5\
    1-|-18:89:5B:86:BB:08-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/21/2019
add comment=mikhmon name="dec/21/2019-|-19:31:30-|-ADWAV-|-3000-|-192.168.12.8\
    0-|-C0:87:EB:EE:62:DB-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/21/2019
add comment=mikhmon name="dec/21/2019-|-19:33:29-|-AUINV-|-3000-|-192.168.12.2\
    00-|-F4:60:E2:30:CF:98-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/21/2019
add comment=mikhmon name="dec/21/2019-|-20:28:54-|-BYBUT-|-5000-|-192.168.12.6\
    6-|-7C:03:5E:C9:04:FB-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/21/2019
add comment=mikhmon name="dec/21/2019-|-20:36:39-|-AKTYN-|-3000-|-192.168.12.6\
    0-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/21/2019
add comment=mikhmon name="dec/21/2019-|-20:39:58-|-AIKUD-|-3000-|-192.168.12.2\
    54-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/21/2019
add comment=mikhmon name="dec/21/2019-|-20:41:24-|-AUWGV-|-3000-|-192.168.12.1\
    9-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/21/2019
add comment=mikhmon name="dec/21/2019-|-23:00:22-|-APYDP-|-3000-|-192.168.12.1\
    97-|-3C:B6:B7:3F:E7:1F-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/21/2019
add comment=mikhmon name="dec/22/2019-|-10:10:54-|-ACDGR-|-3000-|-192.168.12.1\
    77-|-EC:D0:9F:D5:B7:0F-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/22/2019
add comment=mikhmon name="dec/22/2019-|-17:08:24-|-BAMBSG-|-5000-|-192.168.12.\
    50-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-" owner=dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/22/2019
add comment=mikhmon name="dec/22/2019-|-17:43:20-|-AZXUK-|-3000-|-192.168.12.1\
    92-|-0C:98:38:FC:E3:AF-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/22/2019
add comment=mikhmon name="dec/22/2019-|-18:07:22-|-CMMPV-|-15000-|-192.168.12.\
    46-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/22/2019
add comment=mikhmon name="dec/22/2019-|-18:07:50-|-BZZAS-|-5000-|-192.168.12.2\
    5-|-C4:0B:CB:E3:2B:3C-|-2d-|-2hari-|-up-" owner=dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/22/2019
add comment=mikhmon name="dec/22/2019-|-18:32:00-|-BVPVS-|-5000-|-192.168.12.2\
    44-|-6C:D7:1F:23:3C:79-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/22/2019
add comment=mikhmon name="dec/22/2019-|-18:38:43-|-AJGCB-|-3000-|-192.168.12.2\
    48-|-00:27:15:07:16:06-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/22/2019
add comment=mikhmon name="dec/22/2019-|-18:48:29-|-AVDXW-|-3000-|-192.168.12.3\
    0-|-0C:98:38:1D:99:0B-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/22/2019
add comment=mikhmon name="dec/22/2019-|-19:38:36-|-BCGBV-|-5000-|-192.168.12.5\
    3-|-18:02:AE:9F:82:7F-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/22/2019
add comment=mikhmon name="dec/22/2019-|-20:00:49-|-ANTUN-|-3000-|-192.168.12.2\
    00-|-F4:60:E2:30:CF:98-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/22/2019
add comment=mikhmon name="dec/22/2019-|-20:43:41-|-AESEE-|-3000-|-192.168.12.1\
    9-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/22/2019
add comment=mikhmon name="dec/22/2019-|-20:53:57-|-AMWGW-|-3000-|-192.168.12.6\
    9-|-4C:1A:3D:83:30:70-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/22/2019
add comment=mikhmon name="dec/22/2019-|-21:07:19-|-AKWPE-|-3000-|-192.168.12.1\
    86-|-24:79:F3:52:26:EB-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/22/2019
add comment=mikhmon name="dec/22/2019-|-21:21:26-|-AVGWC-|-3000-|-192.168.12.1\
    17-|-20:5E:F7:FA:47:BC-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/22/2019
add comment=mikhmon name="dec/22/2019-|-21:25:07-|-CUCYK-|-15000-|-192.168.12.\
    17-|-70:5E:55:A6:F8:99-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/22/2019
add comment=mikhmon name="dec/22/2019-|-23:09:05-|-ASJWV-|-3000-|-192.168.12.1\
    97-|-3C:B6:B7:3F:E7:1F-|-1d-|-1hari-|-up-890-11.28.19-1hari2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/22/2019
add comment=mikhmon name="dec/23/2019-|-04:59:30-|-BGCDP-|-5000-|-192.168.12.3\
    4-|-A4:D9:90:37:57:51-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/23/2019
add comment=mikhmon name="dec/23/2019-|-05:26:16-|-AXUUR-|-3000-|-192.168.12.6\
    0-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/23/2019
add comment=mikhmon name="dec/23/2019-|-09:15:10-|-CFCKS-|-15000-|-192.168.12.\
    104-|-3C:95:09:E7:6D:13-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/23/2019
add comment=mikhmon name="dec/23/2019-|-12:48:18-|-AIXWG-|-3000-|-192.168.12.2\
    7-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/23/2019
add comment=mikhmon name="dec/23/2019-|-14:37:10-|-BPNFR-|-5000-|-192.168.12.6\
    8-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/23/2019
add comment=mikhmon name="dec/23/2019-|-17:33:18-|-AWYFU-|-3000-|-192.168.12.1\
    77-|-EC:D0:9F:D5:B7:0F-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/23/2019
add comment=mikhmon name="dec/23/2019-|-18:14:25-|-BTCYU-|-5000-|-192.168.12.9\
    0-|-CC:2D:83:AA:45:CD-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/23/2019
add comment=mikhmon name="dec/23/2019-|-18:17:31-|-ADEFV-|-3000-|-192.168.12.8\
    2-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/23/2019
add comment=mikhmon name="dec/23/2019-|-19:00:44-|-BMDXN-|-5000-|-192.168.12.8\
    3-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/23/2019
add comment=mikhmon name="dec/23/2019-|-19:09:03-|-AYAFT-|-3000-|-192.168.12.1\
    02-|-74:29:AF:E8:0E:17-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/23/2019
add comment=mikhmon name="dec/23/2019-|-19:28:15-|-AYFKY-|-3000-|-192.168.12.2\
    54-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/23/2019
add comment=mikhmon name="dec/23/2019-|-19:29:17-|-ANJMS-|-3000-|-192.168.12.6\
    7-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/23/2019
add comment=mikhmon name="dec/23/2019-|-20:46:05-|-BLDDU-|-5000-|-192.168.12.2\
    00-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/23/2019
add comment=mikhmon name="dec/23/2019-|-20:54:49-|-BFIGK-|-5000-|-192.168.12.1\
    90-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/23/2019
add comment=mikhmon name="dec/23/2019-|-21:53:09-|-AFBSI-|-3000-|-192.168.12.1\
    9-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/23/2019
add comment=mikhmon name="dec/23/2019-|-23:06:29-|-AYZNI-|-3000-|-192.168.12.1\
    30-|-CC:2D:83:90:04:D7-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/23/2019
add comment=mikhmon name="dec/23/2019-|-23:33:49-|-ABPHK-|-3000-|-192.168.12.1\
    17-|-20:5E:F7:FA:47:BC-|-1d-|-1hari-|-up-" owner=dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/23/2019
add comment=mikhmon name="dec/23/2019-|-23:46:52-|-AXXFB-|-3000-|-192.168.12.5\
    1-|-18:89:5B:86:BB:08-|-1d-|-1hari-|-up-" owner=dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/23/2019
add comment=mikhmon name="dec/24/2019-|-05:45:22-|-AKWKD-|-3000-|-192.168.12.6\
    0-|-00:0A:00:D5:C3:D8-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/24/2019
add comment=mikhmon name="dec/24/2019-|-07:55:50-|-ATHUC-|-3000-|-192.168.12.3\
    0-|-0C:98:38:1D:99:0B-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/24/2019
add comment=mikhmon name="dec/24/2019-|-10:05:10-|-BRPRG-|-5000-|-192.168.12.1\
    28-|-C0:87:EB:D5:D4:69-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/24/2019
add comment=mikhmon name="dec/24/2019-|-17:59:07-|-AGSRK-|-3000-|-192.168.12.1\
    95-|-00:27:15:53:63:97-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/24/2019
add comment=mikhmon name="dec/24/2019-|-18:20:20-|-AIGID-|-3000-|-192.168.12.1\
    6-|-EC:D0:9F:D5:B7:0F-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/24/2019
add comment=mikhmon name="dec/24/2019-|-18:23:51-|-ACIEJ-|-3000-|-192.168.12.6\
    9-|-4C:1A:3D:83:30:70-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/24/2019
add comment=mikhmon name="dec/24/2019-|-18:24:51-|-AJDUZ-|-3000-|-192.168.12.8\
    2-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/24/2019
add comment=mikhmon name="dec/24/2019-|-18:26:42-|-AJBCC-|-3000-|-192.168.12.4\
    0-|-20:5E:F7:76:C8:12-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/24/2019
add comment=mikhmon name="dec/24/2019-|-19:26:36-|-AVRDV-|-3000-|-192.168.12.2\
    54-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/24/2019
add comment=mikhmon name="dec/24/2019-|-19:29:02-|-ANRJH-|-3000-|-192.168.12.5\
    0-|-00:0A:F5:C2:FC:7C-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/24/2019
add comment=mikhmon name="dec/24/2019-|-20:22:32-|-AUGZB-|-3000-|-192.168.12.8\
    0-|-C0:87:EB:EE:62:DB-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/24/2019
add comment=mikhmon name="dec/24/2019-|-20:58:33-|-ARBPW-|-3000-|-192.168.12.2\
    7-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/24/2019
add comment=mikhmon name="dec/24/2019-|-22:34:57-|-BMXXV-|-5000-|-192.168.12.2\
    44-|-6C:D7:1F:23:3C:79-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/24/2019
add comment=mikhmon name="dec/24/2019-|-22:35:54-|-AIVMC-|-3000-|-192.168.12.6\
    7-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/24/2019
add comment=mikhmon name="dec/24/2019-|-22:41:27-|-BLHTC-|-5000-|-192.168.12.3\
    7-|-A8:DB:03:0B:C2:F3-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/24/2019
add comment=mikhmon name="dec/25/2019-|-00:29:27-|-AYDTW-|-3000-|-192.168.12.5\
    1-|-18:89:5B:86:BB:08-|-1d-|-1hari-|-up-" owner=dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/25/2019
add comment=mikhmon name="dec/25/2019-|-10:23:52-|-BNAKG-|-5000-|-192.168.12.1\
    9-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/25/2019
add comment=mikhmon name="dec/25/2019-|-10:25:14-|-BULXZ-|-5000-|-192.168.12.1\
    43-|-64:CC:2E:23:2F:F8-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/25/2019
add comment=mikhmon name="dec/25/2019-|-10:26:58-|-AWBUX-|-3000-|-192.168.12.1\
    47-|-3C:B6:B7:3F:E7:1F-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/25/2019
add comment=mikhmon name="dec/25/2019-|-14:08:33-|-BSKND-|-5000-|-192.168.12.3\
    5-|-A4:D9:90:74:41:79-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/25/2019
add comment=mikhmon name="dec/25/2019-|-15:22:31-|-BBABT-|-5000-|-192.168.12.6\
    8-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/25/2019
add comment=mikhmon name="dec/25/2019-|-19:15:00-|-AECVJ-|-3000-|-192.168.12.5\
    1-|-18:89:5B:86:BB:08-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/25/2019
add comment=mikhmon name="dec/25/2019-|-19:51:02-|-ABPMY-|-3000-|-192.168.12.8\
    2-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/25/2019
add comment=mikhmon name="dec/25/2019-|-20:43:21-|-BNEGH-|-5000-|-192.168.12.8\
    3-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/25/2019
add comment=mikhmon name="dec/25/2019-|-20:56:34-|-CSGHG-|-15000-|-192.168.12.\
    115-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/25/2019
add comment=mikhmon name="dec/25/2019-|-21:06:05-|-AIUZG-|-3000-|-192.168.12.2\
    54-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/25/2019
add comment=mikhmon name="dec/25/2019-|-22:39:28-|-AEMVF-|-3000-|-192.168.12.6\
    7-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/25/2019
add comment=mikhmon name="dec/25/2019-|-23:32:31-|-BCTGV-|-5000-|-192.168.12.3\
    2-|-C4:0B:CB:E3:2B:3C-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/25/2019
add comment=mikhmon name="dec/26/2019-|-00:20:18-|-BKVTL-|-5000-|-192.168.12.2\
    00-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/26/2019
add comment=mikhmon name="dec/26/2019-|-00:32:22-|-BSYSZ-|-5000-|-192.168.12.3\
    8-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/26/2019
add comment=mikhmon name="dec/26/2019-|-07:26:54-|-AHVYT-|-3000-|-192.168.12.2\
    7-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/26/2019
add comment=mikhmon name="dec/26/2019-|-07:30:14-|-CAMYM-|-15000-|-192.168.12.\
    86-|-A4:D9:90:28:BB:33-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/26/2019
add comment=mikhmon name="dec/26/2019-|-07:54:51-|-ACDEP-|-3000-|-192.168.12.5\
    0-|-00:0A:F5:C2:FC:7C-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/26/2019
add comment=mikhmon name="dec/26/2019-|-09:22:40-|-AKGTH-|-3000-|-192.168.12.1\
    4-|-EC:D0:9F:D5:B7:0F-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/26/2019
add comment=mikhmon name="dec/26/2019-|-11:12:06-|-ANPTD-|-3000-|-192.168.12.6\
    6-|-28:31:66:9A:D1:99-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/26/2019
add comment=mikhmon name="dec/26/2019-|-12:48:03-|-ADMRW-|-3000-|-192.168.12.5\
    4-|-18:02:AE:9F:82:7F-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/26/2019
add comment=mikhmon name="dec/26/2019-|-13:15:49-|-BKATH-|-5000-|-192.168.12.3\
    0-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/26/2019
add comment=mikhmon name="dec/26/2019-|-17:24:26-|-CWVSZ-|-15000-|-192.168.12.\
    22-|-C0:87:EB:D5:D4:69-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/26/2019
add comment=mikhmon name="dec/26/2019-|-18:02:01-|-AGJGD-|-3000-|-192.168.12.1\
    05-|-0C:98:38:94:60:51-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/26/2019
add comment=mikhmon name="dec/26/2019-|-20:56:38-|-BKMHS-|-5000-|-192.168.12.1\
    90-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/26/2019
add comment=mikhmon name="dec/26/2019-|-21:16:24-|-AFDXN-|-3000-|-192.168.12.7\
    3-|-00:27:15:84:48:CC-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/26/2019
add comment=mikhmon name="dec/26/2019-|-22:38:16-|-BYGGH-|-5000-|-192.168.12.6\
    0-|-6C:D7:1F:23:3C:79-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/26/2019
add comment=mikhmon name="dec/26/2019-|-22:45:17-|-AJUSP-|-3000-|-192.168.12.5\
    1-|-18:89:5B:86:BB:08-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/26/2019
add comment=mikhmon name="dec/27/2019-|-01:03:03-|-BMHGT-|-5000-|-192.168.12.3\
    7-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/27/2019
add comment=mikhmon name="dec/27/2019-|-07:07:02-|-BBZNX-|-5000-|-192.168.12.1\
    39-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/27/2019
add comment=mikhmon name="dec/27/2019-|-08:12:42-|-AAEXG-|-3000-|-192.168.12.3\
    3-|-00:0A:F5:C2:FC:7C-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/27/2019
add comment=mikhmon name="dec/27/2019-|-09:46:11-|-AXGHD-|-3000-|-192.168.12.2\
    54-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/27/2019
add comment=mikhmon name="dec/27/2019-|-10:40:12-|-BCNBL-|-5000-|-192.168.12.1\
    09-|-A8:DB:03:0B:C2:F3-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/27/2019
add comment=mikhmon name="dec/27/2019-|-10:43:51-|-BFFAH-|-5000-|-192.168.12.1\
    43-|-64:CC:2E:23:2F:F8-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/27/2019
add comment=mikhmon name="dec/27/2019-|-12:53:18-|-ASUCM-|-3000-|-192.168.12.6\
    6-|-28:31:66:9A:D1:99-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/27/2019
add comment=mikhmon name="dec/27/2019-|-14:54:51-|-AAJFD-|-3000-|-192.168.12.3\
    6-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/27/2019
add comment=mikhmon name="dec/27/2019-|-15:37:37-|-AHYCJ-|-3000-|-192.168.12.6\
    5-|-A4:D9:90:74:41:79-|-1d-|-1hari-|-up-" owner=dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/27/2019
add comment=mikhmon name="dec/27/2019-|-18:08:07-|-APAMR-|-3000-|-192.168.12.1\
    08-|-7C:03:5E:C9:04:FB-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/27/2019
add comment=mikhmon name="dec/27/2019-|-18:53:54-|-BFXZW-|-5000-|-192.168.12.3\
    5-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/27/2019
add comment=mikhmon name="dec/27/2019-|-19:56:44-|-AZECM-|-3000-|-192.168.12.2\
    1-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/27/2019
add comment=mikhmon name="dec/27/2019-|-22:39:07-|-BBPND-|-5000-|-192.168.12.1\
    06-|-00:27:15:53:63:97-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/27/2019
add comment=mikhmon name="dec/28/2019-|-01:45:34-|-BNDVJ-|-5000-|-192.168.12.6\
    7-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/28/2019
add comment=mikhmon name="dec/28/2019-|-09:47:57-|-ADBTE-|-3000-|-192.168.12.2\
    54-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/28/2019
add comment=mikhmon name="dec/28/2019-|-10:53:50-|-BGJVG-|-5000-|-192.168.12.2\
    3-|-08:7F:98:C7:BC:29-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/28/2019
add comment=mikhmon name="dec/28/2019-|-11:27:43-|-AIXZH-|-3000-|-192.168.12.3\
    3-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/28/2019
add comment=mikhmon name="dec/28/2019-|-16:31:08-|-BWMTE-|-5000-|-192.168.12.5\
    1-|-08:7F:98:B0:5B:A1-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/28/2019
add comment=mikhmon name="dec/28/2019-|-17:30:38-|-AFNUJ-|-3000-|-192.168.12.1\
    32-|-EC:D0:9F:D5:B7:0F-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/28/2019
add comment=mikhmon name="dec/28/2019-|-18:24:15-|-AUHAZ-|-3000-|-192.168.12.9\
    6-|-A4:D9:90:74:41:79-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/28/2019
add comment=mikhmon name="dec/28/2019-|-18:48:41-|-AWVAT-|-3000-|-192.168.12.1\
    8-|-7C:03:5E:C9:04:FB-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/28/2019
add comment=mikhmon name="dec/28/2019-|-19:24:30-|-BNBVB-|-5000-|-192.168.12.1\
    56-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/28/2019
add comment=mikhmon name="dec/28/2019-|-19:25:11-|-BDLGN-|-5000-|-192.168.12.4\
    1-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/28/2019
add comment=mikhmon name="dec/28/2019-|-19:26:09-|-BHWKE-|-5000-|-192.168.12.2\
    0-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/28/2019
add comment=mikhmon name="dec/28/2019-|-19:57:28-|-AGHRG-|-3000-|-192.168.12.8\
    9-|-20:5E:F7:76:C8:12-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/28/2019
add comment=mikhmon name="dec/28/2019-|-21:42:44-|-CHXCH-|-15000-|-192.168.12.\
    179-|-2C:FF:EE:96:FA:23-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/28/2019
add comment=mikhmon name="dec/28/2019-|-22:10:22-|-BPREH-|-5000-|-192.168.12.1\
    90-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/28/2019
add comment=mikhmon name="dec/28/2019-|-22:35:28-|-BSVGX-|-5000-|-192.168.12.2\
    5-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/28/2019
add comment=mikhmon name="dec/28/2019-|-22:46:20-|-BBFUZ-|-5000-|-192.168.12.8\
    4-|-6C:D7:1F:23:3C:79-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/28/2019
add comment=mikhmon name="dec/29/2019-|-00:24:12-|-BCZCD-|-5000-|-192.168.12.3\
    6-|-C4:0B:CB:E3:2B:3C-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/29/2019
add comment=mikhmon name="dec/29/2019-|-06:55:45-|-ATYBU-|-3000-|-192.168.12.1\
    98-|-5C:66:6C:D0:1F:37-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/29/2019
add comment=mikhmon name="dec/29/2019-|-09:10:08-|-ABWID-|-3000-|-192.168.12.8\
    8-|-18:89:5B:86:BB:08-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/29/2019
add comment=mikhmon name="dec/29/2019-|-11:01:46-|-BTJLL-|-5000-|-192.168.12.2\
    1-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/29/2019
add comment=mikhmon name="dec/29/2019-|-11:57:40-|-BFZHD-|-5000-|-192.168.12.1\
    39-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/29/2019
add comment=mikhmon name="dec/29/2019-|-12:16:20-|-BWTDL-|-5000-|-192.168.12.1\
    82-|-A8:DB:03:0B:C2:F3-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/29/2019
add comment=mikhmon name="dec/29/2019-|-13:22:56-|-BFKAK-|-5000-|-192.168.12.1\
    43-|-64:CC:2E:23:2F:F8-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/29/2019
add comment=mikhmon name="dec/29/2019-|-14:01:38-|-ATEJA-|-3000-|-192.168.12.2\
    18-|-34:8B:75:02:80:83-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/29/2019
add comment=mikhmon name="dec/29/2019-|-18:31:35-|-AMYEC-|-3000-|-192.168.12.9\
    6-|-A4:D9:90:74:41:79-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/29/2019
add comment=mikhmon name="dec/29/2019-|-18:40:17-|-BKVPK-|-5000-|-192.168.12.3\
    7-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/29/2019
add comment=mikhmon name="dec/29/2019-|-18:59:55-|-APFEX-|-3000-|-192.168.12.8\
    0-|-C0:87:EB:EE:62:DB-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/29/2019
add comment=mikhmon name="dec/29/2019-|-19:27:04-|-AZPMK-|-3000-|-192.168.12.1\
    8-|-7C:03:5E:C9:04:FB-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/29/2019
add comment=mikhmon name="dec/29/2019-|-21:28:17-|-AGWEV-|-3000-|-192.168.12.3\
    3-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/29/2019
add comment=mikhmon name="dec/29/2019-|-21:40:24-|-BFNGH-|-5000-|-192.168.12.3\
    5-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/29/2019
add comment=mikhmon name="dec/29/2019-|-21:41:10-|-BJWZP-|-5000-|-192.168.12.2\
    04-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/29/2019
add comment=mikhmon name="dec/30/2019-|-07:17:17-|-BMWBK-|-5000-|-192.168.12.2\
    43-|-58:44:98:31:1F:B5-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/30/2019
add comment=mikhmon name="dec/30/2019-|-08:15:08-|-AMYAT-|-3000-|-192.168.12.9\
    1-|-60:72:8D:62:53:EB-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/30/2019
add comment=mikhmon name="dec/30/2019-|-08:24:31-|-BCGST-|-5000-|-192.168.12.2\
    54-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/30/2019
add comment=mikhmon name="dec/30/2019-|-08:28:05-|-CUJUS-|-15000-|-192.168.12.\
    42-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/30/2019
add comment=mikhmon name="dec/30/2019-|-10:15:09-|-ACDGR-|-3000-|-192.168.12.8\
    8-|-18:89:5B:86:BB:08-|-1d-|-1hari-|-up-" owner=dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/30/2019
add comment=mikhmon name="dec/30/2019-|-11:03:44-|-BPGCY-|-5000-|-192.168.12.2\
    3-|-08:7F:98:C7:BC:29-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/30/2019
add comment=mikhmon name="dec/30/2019-|-16:44:41-|-AECYK-|-3000-|-192.168.12.5\
    1-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/30/2019
add comment=mikhmon name="dec/30/2019-|-20:50:10-|-BSNGD-|-5000-|-192.168.12.4\
    1-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/30/2019
add comment=mikhmon name="dec/30/2019-|-23:39:31-|-BPHYH-|-5000-|-192.168.12.1\
    06-|-00:27:15:53:63:97-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/30/2019
add comment=mikhmon name="dec/30/2019-|-23:47:07-|-BVBAP-|-5000-|-192.168.12.5\
    9-|-6C:D7:1F:23:3C:79-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/30/2019
add comment=mikhmon name="dec/31/2019-|-01:38:42-|-BNTBF-|-5000-|-192.168.12.1\
    01-|-A8:DB:03:0B:C2:F3-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/31/2019
add comment=mikhmon name="dec/31/2019-|-01:38:59-|-BZSAD-|-5000-|-192.168.12.9\
    6-|-A4:D9:90:74:41:79-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/31/2019
add comment=mikhmon name="dec/31/2019-|-09:28:54-|-AWWNN-|-3000-|-192.168.12.9\
    1-|-60:72:8D:62:53:EB-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/31/2019
add comment=mikhmon name="dec/31/2019-|-09:32:43-|-BXTCU-|-5000-|-192.168.12.2\
    5-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/31/2019
add comment=mikhmon name="dec/31/2019-|-10:20:12-|-BNHDH-|-5000-|-192.168.12.1\
    01-|-A8:DB:03:0B:C2:F3-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/31/2019
add comment=mikhmon name="dec/31/2019-|-11:03:04-|-CKYUV-|-15000-|-192.168.12.\
    84-|-24:79:F3:6D:00:5D-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/31/2019
add comment=mikhmon name="dec/31/2019-|-11:05:55-|-BYKRK-|-5000-|-192.168.12.1\
    56-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/31/2019
add comment=mikhmon name="dec/31/2019-|-15:46:06-|-AVHPF-|-3000-|-192.168.12.2\
    1-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/31/2019
add comment=mikhmon name="dec/31/2019-|-18:28:19-|-BRZYB-|-5000-|-192.168.12.2\
    0-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/31/2019
add comment=mikhmon name="dec/31/2019-|-18:34:56-|-AFMIR-|-3000-|-192.168.12.1\
    68-|-08:7F:98:E1:84:ED-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/31/2019
add comment=mikhmon name="dec/31/2019-|-18:46:45-|-AJNZG-|-3000-|-192.168.12.1\
    8-|-7C:03:5E:C9:04:FB-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/31/2019
add comment=mikhmon name="dec/31/2019-|-19:45:39-|-AXKEB-|-3000-|-192.168.12.1\
    79-|-2C:5D:34:99:CF:2B-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/31/2019
add comment=mikhmon name="dec/31/2019-|-19:54:39-|-AAEDY-|-3000-|-192.168.12.5\
    1-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/31/2019
add comment=mikhmon name="dec/31/2019-|-20:14:18-|-BMAFX-|-5000-|-192.168.12.3\
    7-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/31/2019
add comment=mikhmon name="dec/31/2019-|-21:00:51-|-BLULJ-|-5000-|-192.168.12.1\
    65-|-00:0A:F5:4E:69:4C-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/31/2019
add comment=mikhmon name="dec/31/2019-|-21:42:21-|-ACYUW-|-3000-|-192.168.12.1\
    95-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-905-12.20.19-" owner=dec2019 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=dec/31/2019
add comment=mikhmon name="dec/31/2019-|-21:52:20-|-BPZEE-|-5000-|-192.168.12.3\
    5-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/31/2019
add comment=mikhmon name="dec/31/2019-|-22:08:47-|-BTTRA-|-5000-|-192.168.12.1\
    94-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    dec2019 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    dec/31/2019
add comment=mikhmon name="jan/02/2020-|-17:43:53-|-BRNMF-|-5000-|-192.168.12.3\
    8-|-6C:D7:1F:23:3C:79-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/02/2020
add comment=mikhmon name="jan/02/2020-|-18:45:39-|-BUMAB-|-5000-|-192.168.12.2\
    15-|-0C:98:38:FC:E3:AF-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/02/2020
add comment=mikhmon name="jan/02/2020-|-19:32:32-|-BVFFA-|-5000-|-192.168.12.1\
    17-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/02/2020
add comment=mikhmon name="jan/02/2020-|-21:20:10-|-AKMHCY-|-3000-|-192.168.12.\
    144-|-E4:F8:EF:85:DC:C0-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/02/2020
add comment=mikhmon name="jan/02/2020-|-21:59:52-|-BZWYY-|-5000-|-192.168.12.3\
    5-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/02/2020
add comment=mikhmon name="jan/02/2020-|-23:03:14-|-ATUKE-|-3000-|-192.168.12.3\
    9-|-70:5E:55:A6:F8:99-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/02/2020
add comment=mikhmon name="jan/03/2020-|-00:15:54-|-BCVTE-|-5000-|-192.168.12.9\
    9-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/03/2020
add comment=mikhmon name="jan/03/2020-|-06:38:42-|-CRSPJ-|-15000-|-192.168.12.\
    49-|-A4:D9:90:28:BB:33-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/03/2020
add comment=mikhmon name="jan/03/2020-|-11:11:21-|-BCVKU-|-5000-|-192.168.12.1\
    14-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/03/2020
add comment=mikhmon name="jan/03/2020-|-12:07:54-|-BDYWB-|-5000-|-192.168.12.2\
    0-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/03/2020
add comment=mikhmon name="jan/03/2020-|-12:33:52-|-ACHWC-|-3000-|-192.168.12.5\
    8-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-" owner=jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/03/2020
add comment=mikhmon name="jan/03/2020-|-13:41:58-|-BLTFC-|-5000-|-192.168.12.8\
    9-|-20:5E:F7:76:C8:12-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/03/2020
add comment=mikhmon name="jan/03/2020-|-14:37:52-|-ADPXR-|-3000-|-192.168.12.1\
    56-|-2C:56:DC:E7:15:E1-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/03/2020
add comment=mikhmon name="jan/03/2020-|-15:07:07-|-ADCBM-|-3000-|-192.168.12.1\
    06-|-00:27:15:53:63:97-|-1d-|-1hari-|-up-905-12.20.19-" owner=jan2020 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jan/03/2020
add comment=mikhmon name="jan/03/2020-|-16:08:36-|-AXUYM-|-3000-|-192.168.12.7\
    1-|-64:B8:53:4F:CD:B1-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/03/2020
add comment=mikhmon name="jan/03/2020-|-16:23:33-|-AKYFW-|-3000-|-192.168.12.2\
    1-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/03/2020
add comment=mikhmon name="jan/03/2020-|-16:32:56-|-ARIRK-|-3000-|-192.168.12.7\
    3-|-2C:5D:34:99:CF:2B-|-1d-|-1hari-|-up-905-12.20.19-" owner=jan2020 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jan/03/2020
add comment=mikhmon name="jan/03/2020-|-16:36:13-|-AGRPB-|-3000-|-192.168.12.2\
    54-|-18:89:5B:86:BB:08-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/03/2020
add comment=mikhmon name="jan/03/2020-|-18:29:59-|-BRLSC-|-5000-|-192.168.12.9\
    2-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/03/2020
add comment=mikhmon name="jan/03/2020-|-18:32:30-|-AHUYH-|-3000-|-192.168.12.8\
    0-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/03/2020
add comment=mikhmon name="jan/03/2020-|-19:31:40-|-BNTUS-|-5000-|-192.168.12.1\
    93-|-20:5E:F7:FA:47:BC-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/03/2020
add comment=mikhmon name="jan/03/2020-|-20:31:58-|-CBRZF-|-15000-|-192.168.12.\
    29-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-881-09.20.19-7H20Sept19" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/03/2020
add comment=mikhmon name="jan/03/2020-|-20:43:53-|-BXFXW-|-5000-|-192.168.12.2\
    3-|-08:7F:98:C7:BC:29-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/03/2020
add comment=mikhmon name="jan/03/2020-|-22:06:34-|-ADXAB-|-3000-|-192.168.12.1\
    05-|-28:31:66:9A:D1:99-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/03/2020
add comment=mikhmon name="jan/04/2020-|-08:05:32-|-CHWGN-|-15000-|-192.168.12.\
    123-|-A4:D9:90:74:41:79-|-7d-|-7hari-|-up-652-01.01.20-" owner=jan2020 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jan/04/2020
add comment=mikhmon name="jan/04/2020-|-14:32:08-|-BXJGT-|-5000-|-192.168.12.5\
    8-|-08:7F:98:B0:5B:A1-|-2d-|-2hari-|-up-780-11.28.19-2HARI2811" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/04/2020
add comment=mikhmon name="jan/04/2020-|-17:33:21-|-ATZDP-|-3000-|-192.168.12.2\
    7-|-C0:87:EB:EE:62:DB-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/04/2020
add comment=mikhmon name="jan/04/2020-|-18:46:09-|-AVDEG-|-3000-|-192.168.12.9\
    8-|-00:27:15:53:63:97-|-1d-|-1hari-|-up-905-12.20.19-" owner=jan2020 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jan/04/2020
add comment=mikhmon name="jan/04/2020-|-19:08:17-|-BLDHF-|-5000-|-192.168.12.1\
    56-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/04/2020
add comment=mikhmon name="jan/04/2020-|-19:12:18-|-AVVHV-|-3000-|-192.168.12.8\
    0-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/04/2020
add comment=mikhmon name="jan/04/2020-|-20:01:07-|-BBMVT-|-5000-|-192.168.12.2\
    1-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/04/2020
add comment=mikhmon name="jan/04/2020-|-20:37:44-|-BJPHT-|-5000-|-192.168.12.3\
    8-|-6C:D7:1F:23:3C:79-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/04/2020
add comment=mikhmon name="jan/04/2020-|-20:49:41-|-BSEME-|-5000-|-192.168.12.2\
    15-|-0C:98:38:FC:E3:AF-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/04/2020
add comment=mikhmon name="jan/04/2020-|-21:43:05-|-BFXRK-|-5000-|-192.168.12.4\
    5-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/04/2020
add comment=mikhmon name="jan/04/2020-|-22:01:37-|-BTLKX-|-5000-|-192.168.12.8\
    5-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/04/2020
add comment=mikhmon name="jan/04/2020-|-22:23:29-|-BWSAN-|-5000-|-192.168.12.2\
    5-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/04/2020
add comment=mikhmon name="jan/04/2020-|-22:53:54-|-ACGDN-|-3000-|-192.168.12.1\
    89-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/04/2020
add comment=mikhmon name="jan/05/2020-|-08:14:43-|-BBDFK-|-5000-|-192.168.12.4\
    4-|-C0:87:EB:35:15:4B-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/05/2020
add comment=mikhmon name="jan/05/2020-|-09:22:14-|-AXJZT-|-3000-|-192.168.12.1\
    5-|-60:72:8D:62:53:EB-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/05/2020
add comment=mikhmon name="jan/05/2020-|-09:49:52-|-AYRGX-|-3000-|-192.168.12.2\
    16-|-34:8B:75:02:80:83-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/05/2020
add comment=mikhmon name="jan/05/2020-|-11:51:25-|-CZVAR-|-15000-|-192.168.12.\
    129-|-08:8C:2C:02:A3:A3-|-7d-|-7hari-|-up-652-01.01.20-" owner=jan2020 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jan/05/2020
add comment=mikhmon name="jan/05/2020-|-19:04:05-|-BJFBW-|-5000-|-192.168.12.8\
    3-|-74:29:AF:E8:0E:17-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/05/2020
add comment=mikhmon name="jan/05/2020-|-20:39:53-|-BFSUP-|-5000-|-192.168.12.1\
    93-|-20:5E:F7:FA:47:BC-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/05/2020
add comment=mikhmon name="jan/05/2020-|-21:41:01-|-AFEMM-|-3000-|-192.168.12.2\
    37-|-48:88:CA:0B:65:02-|-1d-|-1hari-|-up-905-12.20.19-" owner=jan2020 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jan/05/2020
add comment=mikhmon name="jan/05/2020-|-21:48:49-|-BHBVA-|-5000-|-192.168.12.6\
    0-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/05/2020
add comment=mikhmon name="jan/05/2020-|-21:59:55-|-AJVEN-|-3000-|-192.168.12.2\
    3-|-08:7F:98:C7:BC:29-|-1d-|-1hari-|-up-905-12.20.19-" owner=jan2020 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jan/05/2020
add comment=mikhmon name="jan/05/2020-|-23:33:56-|-AJWTF-|-3000-|-192.168.12.1\
    06-|-00:27:15:53:63:97-|-1d-|-1hari-|-up-905-12.20.19-" owner=jan2020 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jan/05/2020
add comment=mikhmon name="jan/06/2020-|-08:57:30-|-BMUHH-|-5000-|-192.168.12.8\
    0-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/06/2020
add comment=mikhmon name="jan/06/2020-|-12:31:00-|-BHMXB-|-5000-|-192.168.12.6\
    7-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/06/2020
add comment=mikhmon name="jan/06/2020-|-18:18:48-|-CFDVP-|-15000-|-192.168.12.\
    42-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-652-01.01.20-" owner=jan2020 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jan/06/2020
add comment=mikhmon name="jan/06/2020-|-19:43:34-|-BUZBV-|-5000-|-192.168.12.1\
    33-|-18:02:AE:9F:82:7F-|-2d-|-2hari-|-up-747-01.05.20-2hariferi" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/06/2020
add comment=mikhmon name="jan/06/2020-|-20:04:55-|-BEXPY-|-5000-|-192.168.12.2\
    1-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/06/2020
add comment=mikhmon name="jan/06/2020-|-21:54:45-|-ATBEW-|-3000-|-192.168.12.3\
    8-|-6C:D7:1F:23:3C:79-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/06/2020
add comment=mikhmon name="jan/06/2020-|-22:02:35-|-CTXTY-|-15000-|-192.168.12.\
    23-|-08:7F:98:C7:BC:29-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/06/2020
add comment=mikhmon name="jan/06/2020-|-22:08:55-|-BDPGP-|-5000-|-192.168.12.3\
    5-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/06/2020
add comment=mikhmon name="jan/07/2020-|-06:36:32-|-AYWRT-|-3000-|-192.168.12.1\
    47-|-4C:1A:3D:83:30:70-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/07/2020
add comment=mikhmon name="jan/07/2020-|-07:13:10-|-AXJKR-|-3000-|-192.168.12.1\
    06-|-00:27:15:53:63:97-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/07/2020
add comment=mikhmon name="jan/07/2020-|-12:38:26-|-ABIYM-|-3000-|-192.168.12.2\
    09-|-08:7F:98:F4:18:B1-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/07/2020
add comment=mikhmon name="jan/07/2020-|-14:01:58-|-BZZGA-|-5000-|-192.168.12.1\
    56-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/07/2020
add comment=mikhmon name="jan/07/2020-|-14:36:04-|-ARZWN-|-3000-|-192.168.12.1\
    89-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/07/2020
add comment=mikhmon name="jan/07/2020-|-14:45:12-|-AVVCS-|-3000-|-192.168.12.1\
    14-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/07/2020
add comment=mikhmon name="jan/07/2020-|-19:01:19-|-AXCJA-|-3000-|-192.168.12.2\
    44-|-00:90:4C:C5:12:38-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/07/2020
add comment=mikhmon name="jan/07/2020-|-19:07:27-|-AARBI-|-3000-|-192.168.12.2\
    38-|-60:72:8D:62:53:EB-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/07/2020
add comment=mikhmon name="jan/07/2020-|-19:25:22-|-BUYFF-|-5000-|-192.168.12.2\
    15-|-0C:98:38:FC:E3:AF-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/07/2020
add comment=mikhmon name="jan/07/2020-|-19:27:29-|-BDCTZ-|-5000-|-192.168.12.8\
    3-|-74:29:AF:E8:0E:17-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/07/2020
add comment=mikhmon name="jan/07/2020-|-19:36:38-|-BXMAL-|-5000-|-192.168.12.2\
    5-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/07/2020
add comment=mikhmon name="jan/07/2020-|-20:54:38-|-BEDHF-|-5000-|-192.168.12.1\
    93-|-20:5E:F7:FA:47:BC-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/07/2020
add comment=mikhmon name="jan/07/2020-|-21:51:52-|-BVRUA-|-5000-|-192.168.12.6\
    0-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/07/2020
add comment=mikhmon name="jan/07/2020-|-22:17:05-|-AKWPP-|-3000-|-192.168.12.6\
    1-|-6C:D7:1F:23:3C:79-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/07/2020
add comment=mikhmon name="jan/07/2020-|-23:42:29-|-BAPPS-|-5000-|-192.168.12.9\
    9-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/07/2020
add comment=mikhmon name="jan/08/2020-|-07:56:39-|-BMWLH-|-5000-|-192.168.12.1\
    06-|-00:27:15:53:63:97-|-2d-|-2hari-|-up-747-01.05.20-2hariferi" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/08/2020
add comment=mikhmon name="jan/08/2020-|-10:24:05-|-APEWZ-|-3000-|-192.168.12.5\
    7-|-34:8B:75:02:80:83-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/08/2020
add comment=mikhmon name="jan/08/2020-|-10:25:03-|-BERBG-|-5000-|-192.168.12.1\
    47-|-4C:1A:3D:83:30:70-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/08/2020
add comment=mikhmon name="jan/08/2020-|-12:30:10-|-AAFEM-|-3000-|-192.168.12.5\
    9-|-84:4B:F5:2A:51:C1-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/08/2020
add comment=mikhmon name="jan/08/2020-|-16:02:04-|-ASMUR-|-3000-|-192.168.12.7\
    6-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-432-01.01.20-1HariFeri" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/08/2020
add comment=mikhmon name="jan/08/2020-|-16:13:28-|-BRLMP-|-5000-|-192.168.12.2\
    08-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/08/2020
add comment=mikhmon name="jan/08/2020-|-16:50:17-|-BLWVT-|-5000-|-192.168.12.4\
    4-|-C0:87:EB:35:15:4B-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/08/2020
add comment=mikhmon name="jan/08/2020-|-18:46:59-|-AMWYS-|-3000-|-192.168.12.3\
    4-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-432-01.01.20-1HariFeri" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/08/2020
add comment=mikhmon name="jan/08/2020-|-19:04:04-|-BSLAZ-|-5000-|-192.168.12.9\
    5-|-20:F7:7C:21:6E:89-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/08/2020
add comment=mikhmon name="jan/08/2020-|-19:14:18-|-BTMDC-|-5000-|-192.168.12.1\
    73-|-CC:2D:83:AA:45:CD-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/08/2020
add comment=mikhmon name="jan/08/2020-|-19:46:05-|-AWUVA-|-3000-|-192.168.12.1\
    33-|-18:02:AE:9F:82:7F-|-1d-|-1hari-|-up-432-01.01.20-1HariFeri" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/08/2020
add comment=mikhmon name="jan/08/2020-|-20:10:17-|-AXERE-|-3000-|-192.168.12.2\
    1-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/08/2020
add comment=mikhmon name="jan/08/2020-|-20:38:37-|-BDPUS-|-5000-|-192.168.12.1\
    14-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/08/2020
add comment=mikhmon name="jan/09/2020-|-13:52:30-|-CNZGU-|-15000-|-192.168.12.\
    101-|-A8:DB:03:0B:C2:F3-|-7d-|-7hari-|-up-652-01.01.20-" owner=jan2020 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jan/09/2020
add comment=mikhmon name="jan/09/2020-|-14:29:04-|-AYBZH-|-3000-|-192.168.12.6\
    5-|-C0:87:EB:C0:28:19-|-1d-|-1hari-|-up-432-01.01.20-1HariFeri" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/09/2020
add comment=mikhmon name="jan/09/2020-|-15:06:09-|-BBYNZ-|-5000-|-192.168.12.3\
    5-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/09/2020
add comment=mikhmon name="jan/09/2020-|-17:44:47-|-BLEJD-|-5000-|-192.168.12.2\
    0-|-60:72:8D:62:53:EB-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/09/2020
add comment=mikhmon name="jan/09/2020-|-19:14:17-|-AFSBW-|-3000-|-192.168.12.1\
    89-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/09/2020
add comment=mikhmon name="jan/09/2020-|-19:35:17-|-BXADJ-|-5000-|-192.168.12.2\
    15-|-0C:98:38:FC:E3:AF-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/09/2020
add comment=mikhmon name="jan/09/2020-|-19:52:35-|-BGWTW-|-5000-|-192.168.12.2\
    5-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/09/2020
add comment=mikhmon name="jan/09/2020-|-20:12:56-|-ARRKK-|-3000-|-192.168.12.2\
    1-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/09/2020
add comment=mikhmon name="jan/09/2020-|-21:10:23-|-AAGGI-|-3000-|-192.168.12.3\
    4-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-432-01.01.20-1HariFeri" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/09/2020
add comment=mikhmon name="jan/09/2020-|-21:29:13-|-BEVFU-|-5000-|-192.168.12.1\
    93-|-20:5E:F7:FA:47:BC-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/09/2020
add comment=mikhmon name="jan/09/2020-|-21:51:36-|-BUEFE-|-5000-|-192.168.12.1\
    79-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-747-01.05.20-2hariferi" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/09/2020
add comment=mikhmon name="jan/09/2020-|-22:23:57-|-ARMRY-|-3000-|-192.168.12.2\
    54-|-18:89:5B:86:BB:08-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/09/2020
add comment=mikhmon name="jan/09/2020-|-22:31:41-|-BCLFE-|-5000-|-192.168.12.8\
    6-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/09/2020
add comment=mikhmon name="jan/10/2020-|-07:01:59-|-CIGGT-|-15000-|-192.168.12.\
    49-|-A4:D9:90:28:BB:33-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/10/2020
add comment=mikhmon name="jan/10/2020-|-11:19:54-|-BDFKT-|-5000-|-192.168.12.1\
    56-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/10/2020
add comment=mikhmon name="jan/10/2020-|-13:46:37-|-AIDCW-|-3000-|-192.168.12.1\
    33-|-18:02:AE:9F:82:7F-|-1d-|-1hari-|-up-432-01.01.20-1HariFeri" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/10/2020
add comment=mikhmon name="jan/10/2020-|-14:28:41-|-AMCXB-|-3000-|-192.168.12.8\
    1-|-6C:D7:1F:23:3C:79-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/10/2020
add comment=mikhmon name="jan/10/2020-|-17:51:02-|-BKUES-|-5000-|-192.168.12.2\
    08-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/10/2020
add comment=mikhmon name="jan/10/2020-|-18:47:41-|-AHHPZ-|-3000-|-192.168.12.1\
    06-|-00:27:15:53:63:97-|-1d-|-1hari-|-up-432-01.01.20-1HariFeri" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/10/2020
add comment=mikhmon name="jan/10/2020-|-18:56:37-|-ANTDW-|-3000-|-192.168.12.6\
    5-|-C0:87:EB:C0:28:19-|-1d-|-1hari-|-up-432-01.01.20-1HariFeri" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/10/2020
add comment=mikhmon name="jan/10/2020-|-20:15:09-|-BNVKK-|-5000-|-192.168.12.2\
    1-|-F0:6D:78:42:12:1A-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/10/2020
add comment=mikhmon name="jan/10/2020-|-21:41:53-|-ADCWN-|-3000-|-192.168.12.1\
    85-|-74:29:AF:E8:0E:17-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/10/2020
add comment=mikhmon name="jan/10/2020-|-22:30:39-|-AVDES-|-3000-|-192.168.12.2\
    54-|-18:89:5B:86:BB:08-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/10/2020
add comment=mikhmon name="jan/11/2020-|-05:45:49-|-ADJTA-|-3000-|-192.168.12.1\
    68-|-08:7F:98:E1:84:ED-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/11/2020
add comment=mikhmon name="jan/11/2020-|-06:02:29-|-BUPNR-|-5000-|-192.168.12.4\
    5-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/11/2020
add comment=mikhmon name="jan/11/2020-|-08:49:50-|-AHXTA-|-3000-|-192.168.12.1\
    23-|-A4:D9:90:74:41:79-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/11/2020
add comment=mikhmon name="jan/11/2020-|-10:50:16-|-BWYUV-|-5000-|-192.168.12.9\
    5-|-20:F7:7C:21:6E:89-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/11/2020
add comment=mikhmon name="jan/11/2020-|-11:05:12-|-APBRH-|-3000-|-192.168.12.2\
    7-|-C0:87:EB:EE:62:DB-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/11/2020
add comment=mikhmon name="jan/11/2020-|-12:20:49-|-BHXGA-|-5000-|-192.168.12.9\
    6-|-C4:0B:CB:E3:2B:3C-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/11/2020
add comment=mikhmon name="jan/11/2020-|-14:44:13-|-BCZMB-|-5000-|-192.168.12.1\
    14-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/11/2020
add comment=mikhmon name="jan/11/2020-|-18:38:04-|-BXKBC-|-5000-|-192.168.12.1\
    5-|-60:72:8D:62:53:EB-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/11/2020
add comment=mikhmon name="jan/11/2020-|-18:38:25-|-CPLEG-|-15000-|-192.168.12.\
    29-|-E0:99:71:C7:B6:9F-|-7d-|-7hari-|-up-652-01.01.20-" owner=jan2020 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jan/11/2020
add comment=mikhmon name="jan/11/2020-|-20:07:05-|-BRCGB-|-5000-|-192.168.12.2\
    15-|-0C:98:38:FC:E3:AF-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/11/2020
add comment=mikhmon name="jan/11/2020-|-20:09:33-|-BPMUT-|-5000-|-192.168.12.2\
    5-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/11/2020
add comment=mikhmon name="jan/11/2020-|-20:26:29-|-BWMDP-|-5000-|-192.168.12.3\
    5-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/11/2020
add comment=mikhmon name="jan/11/2020-|-20:44:31-|-BSNKE-|-5000-|-192.168.12.6\
    8-|-CC:2D:83:90:04:D7-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/11/2020
add comment=mikhmon name="jan/11/2020-|-22:45:02-|-AWYWG-|-3000-|-192.168.12.8\
    0-|-6C:D7:1F:23:3C:79-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/11/2020
add comment=mikhmon name="jan/11/2020-|-22:53:20-|-BBVWD-|-5000-|-192.168.12.1\
    11-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-" owner=jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/11/2020
add comment=mikhmon name="jan/12/2020-|-00:29:46-|-BAAJF-|-5000-|-192.168.12.1\
    93-|-20:5E:F7:FA:47:BC-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/12/2020
add comment=mikhmon name="jan/12/2020-|-01:02:03-|-BBRLN-|-5000-|-192.168.12.9\
    9-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-747-01.05.20-2hariferi" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/12/2020
add comment=mikhmon name="jan/12/2020-|-07:57:25-|-BWGYF-|-5000-|-192.168.12.1\
    38-|-20:5E:F7:76:C8:12-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/12/2020
add comment=mikhmon name="jan/12/2020-|-09:07:10-|-AWIEV-|-3000-|-192.168.12.3\
    3-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-432-01.01.20-1HariFeri" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/12/2020
add comment=mikhmon name="jan/12/2020-|-14:48:54-|-AGXAP-|-3000-|-192.168.12.3\
    9-|-34:8B:75:02:80:83-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/12/2020
add comment=mikhmon name="jan/12/2020-|-15:36:23-|-AGSDU-|-3000-|-192.168.12.1\
    23-|-A4:D9:90:74:41:79-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/12/2020
add comment=mikhmon name="jan/12/2020-|-16:18:08-|-AHWEI-|-3000-|-192.168.12.1\
    33-|-18:02:AE:9F:82:7F-|-1d-|-1hari-|-up-432-01.01.20-1HariFeri" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/12/2020
add comment=mikhmon name="jan/12/2020-|-17:47:24-|-ASAHD-|-3000-|-192.168.12.2\
    54-|-18:89:5B:86:BB:08-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/12/2020
add comment=mikhmon name="jan/12/2020-|-17:54:20-|-BSLTL-|-5000-|-192.168.12.1\
    85-|-74:29:AF:E8:0E:17-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/12/2020
add comment=mikhmon name="jan/12/2020-|-17:58:20-|-AMIAH-|-3000-|-192.168.12.5\
    0-|-1C:77:F6:E0:DE:02-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/12/2020
add comment=mikhmon name="jan/12/2020-|-21:12:48-|-BMLBM-|-5000-|-192.168.12.1\
    79-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-747-01.05.20-2hariferi" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/12/2020
add comment=mikhmon name="jan/12/2020-|-22:50:42-|-BCLNR-|-5000-|-192.168.12.8\
    0-|-6C:D7:1F:23:3C:79-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/12/2020
add comment=mikhmon name="jan/12/2020-|-23:42:39-|-ABEDN-|-3000-|-192.168.12.1\
    06-|-00:27:15:53:63:97-|-1d-|-1hari-|-up-432-01.01.20-1HariFeri" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/12/2020
add comment=mikhmon name="jan/13/2020-|-19:21:16-|-CHZLF-|-15000-|-192.168.12.\
    42-|-C0:87:EB:4A:C9:1F-|-7d-|-7hari-|-up-652-01.01.20-" owner=jan2020 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jan/13/2020
add comment=mikhmon name="jan/13/2020-|-19:35:23-|-BFGBF-|-5000-|-192.168.12.1\
    57-|-0C:A8:A7:11:EF:5C-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/13/2020
add comment=mikhmon name="jan/13/2020-|-22:32:48-|-BTHLJ-|-5000-|-192.168.12.3\
    5-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/13/2020
add comment=mikhmon name="jan/13/2020-|-22:51:02-|-BYPHU-|-5000-|-192.168.12.2\
    15-|-0C:98:38:FC:E3:AF-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/13/2020
add comment=mikhmon name="jan/13/2020-|-23:22:55-|-ABFUX-|-3000-|-192.168.12.1\
    7-|-70:5E:55:A6:F8:99-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/13/2020
add comment=mikhmon name="jan/14/2020-|-09:41:07-|-BPAXH-|-5000-|-192.168.12.2\
    5-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/14/2020
add comment=mikhmon name="jan/14/2020-|-10:05:01-|-CVITV-|-15000-|-192.168.12.\
    23-|-08:7F:98:C7:BC:29-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/14/2020
add comment=mikhmon name="jan/14/2020-|-11:23:28-|-BKZKA-|-5000-|-192.168.12.1\
    93-|-20:5E:F7:FA:47:BC-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/14/2020
add comment=mikhmon name="jan/14/2020-|-16:06:18-|-AZIBG-|-3000-|-192.168.12.3\
    9-|-80:91:33:83:39:2B-|-1d-|-1hari-|-up-432-01.01.20-1HariFeri" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/14/2020
add comment=mikhmon name="jan/14/2020-|-19:12:37-|-BLMNS-|-5000-|-192.168.12.1\
    85-|-74:29:AF:E8:0E:17-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/14/2020
add comment=mikhmon name="jan/14/2020-|-19:19:41-|-AMCBN-|-3000-|-192.168.12.2\
    54-|-18:89:5B:86:BB:08-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/14/2020
add comment=mikhmon name="jan/14/2020-|-19:25:40-|-BEVRL-|-5000-|-192.168.12.5\
    1-|-60:72:8D:62:53:EB-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/14/2020
add comment=mikhmon name="jan/14/2020-|-19:29:29-|-BDXRZ-|-5000-|-192.168.12.5\
    0-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-747-01.05.20-2hariferi" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/14/2020
add comment=mikhmon name="jan/14/2020-|-19:34:20-|-AWCYS-|-3000-|-192.168.12.5\
    3-|-20:16:D8:F0:C0:CD-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/14/2020
add comment=mikhmon name="jan/14/2020-|-20:03:59-|-ARABV-|-3000-|-192.168.12.1\
    56-|-2C:56:DC:E7:15:E1-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/14/2020
add comment=mikhmon name="jan/14/2020-|-21:18:39-|-AAMFW-|-3000-|-192.168.12.1\
    51-|-5C:66:6C:D0:1F:37-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/14/2020
add comment=mikhmon name="jan/14/2020-|-23:07:54-|-BUGXT-|-5000-|-192.168.12.1\
    91-|-A4:D9:90:37:57:51-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/14/2020
add comment=mikhmon name="jan/14/2020-|-23:51:25-|-BEMXJ-|-5000-|-192.168.12.1\
    90-|-70:5E:55:A6:F8:99-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/14/2020
add comment=mikhmon name="jan/15/2020-|-01:15:43-|-BYJHZ-|-5000-|-192.168.12.1\
    06-|-00:27:15:53:63:97-|-2d-|-2hari-|-up-747-01.05.20-2hariferi" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/15/2020
add comment=mikhmon name="jan/15/2020-|-12:15:13-|-BHMKY-|-5000-|-192.168.12.2\
    08-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/15/2020
add comment=mikhmon name="jan/15/2020-|-15:11:32-|-ACPMH-|-3000-|-192.168.12.8\
    0-|-6C:D7:1F:23:3C:79-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/15/2020
add comment=mikhmon name="jan/15/2020-|-16:09:57-|-BXBKH-|-5000-|-192.168.12.1\
    28-|-4C:5C:FF:46:FE:99-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/15/2020
add comment=mikhmon name="jan/15/2020-|-16:36:16-|-AWPMP-|-3000-|-192.168.12.2\
    1-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/15/2020
add comment=mikhmon name="jan/15/2020-|-16:47:09-|-BHBEU-|-5000-|-192.168.12.1\
    14-|-08:8C:2C:E5:59:4D-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/15/2020
add comment=mikhmon name="jan/15/2020-|-17:05:34-|-AVEYA-|-3000-|-192.168.12.1\
    35-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-432-01.01.20-1HariFeri" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/15/2020
add comment=mikhmon name="jan/15/2020-|-17:30:12-|-BHEWJ-|-5000-|-192.168.12.1\
    18-|-F4:60:E2:30:CF:98-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/15/2020
add comment=mikhmon name="jan/15/2020-|-18:40:12-|-AGSJR-|-3000-|-192.168.12.1\
    33-|-18:02:AE:9F:82:7F-|-1d-|-1hari-|-up-432-01.01.20-1HariFeri" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/15/2020
add comment=mikhmon name="jan/15/2020-|-19:37:43-|-AIDAZ-|-3000-|-192.168.12.1\
    43-|-6C:D7:1F:27:2E:83-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/15/2020
add comment=mikhmon name="jan/15/2020-|-22:38:30-|-BSRHM-|-5000-|-192.168.12.3\
    5-|-08:EE:8B:F5:DA:26-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/15/2020
add comment=mikhmon name="jan/15/2020-|-22:39:04-|-AVXKM-|-3000-|-192.168.12.2\
    54-|-18:89:5B:86:BB:08-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/15/2020
add comment=mikhmon name="jan/15/2020-|-23:36:29-|-AFVYP-|-3000-|-192.168.12.1\
    55-|-88:5A:06:66:12:E5-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/15/2020
add comment=mikhmon name="jan/16/2020-|-07:45:37-|-AENMZ-|-3000-|-192.168.12.1\
    5-|-4C:1A:3D:83:30:70-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/16/2020
add comment=mikhmon name="jan/16/2020-|-10:06:48-|-AFDSJ-|-3000-|-192.168.12.1\
    51-|-5C:66:6C:D0:1F:37-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/16/2020
add comment=mikhmon name="jan/16/2020-|-13:30:54-|-AAJXR-|-3000-|-192.168.12.1\
    80-|-C4:E1:A1:F7:5A:6D-|-1d-|-1hari-|-up-632-01.01.20-1HariAndre" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/16/2020
add comment=mikhmon name="jan/16/2020-|-14:48:52-|-BUSZZ-|-5000-|-192.168.12.2\
    5-|-0C:98:38:1D:99:0B-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/16/2020
add comment=mikhmon name="jan/16/2020-|-16:22:24-|-BLWEG-|-5000-|-192.168.12.9\
    5-|-20:F7:7C:21:6E:89-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/16/2020
add comment=mikhmon name="jan/16/2020-|-16:32:50-|-BFGUJ-|-5000-|-192.168.12.4\
    4-|-C0:87:EB:35:15:4B-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/16/2020
add comment=mikhmon name="jan/16/2020-|-16:49:02-|-BZLBZ-|-5000-|-192.168.12.2\
    00-|-08:7F:98:E1:84:ED-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/16/2020
add comment=mikhmon name="jan/16/2020-|-16:58:54-|-ACDKY-|-3000-|-192.168.12.7\
    3-|-3C:95:09:E7:6D:13-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/16/2020
add comment=mikhmon name="jan/16/2020-|-17:23:16-|-ARYCZ-|-3000-|-192.168.12.1\
    35-|-08:7F:98:B0:5B:A1-|-1d-|-1hari-|-up-432-01.01.20-1HariFeri" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/16/2020
add comment=mikhmon name="jan/16/2020-|-18:45:14-|-BYGSF-|-5000-|-192.168.12.1\
    33-|-18:02:AE:9F:82:7F-|-2d-|-2hari-|-up-747-01.05.20-2hariferi" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/16/2020
add comment=mikhmon name="jan/16/2020-|-19:35:20-|-APKAG-|-3000-|-192.168.12.1\
    08-|-60:72:8D:62:53:EB-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/16/2020
add comment=mikhmon name="jan/16/2020-|-19:42:23-|-AMCSB-|-3000-|-192.168.12.2\
    1-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/16/2020
add comment=mikhmon name="jan/16/2020-|-20:08:02-|-BVDRE-|-5000-|-192.168.12.1\
    79-|-60:A4:D0:B9:1E:48-|-2d-|-2hari-|-up-747-01.05.20-2hariferi" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/16/2020
add comment=mikhmon name="jan/16/2020-|-20:11:53-|-BSJRH-|-5000-|-192.168.12.2\
    15-|-0C:98:38:FC:E3:AF-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/16/2020
add comment=mikhmon name="jan/16/2020-|-21:00:23-|-BJVWN-|-5000-|-192.168.12.2\
    11-|-74:29:AF:E8:0E:17-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/16/2020
add comment=mikhmon name="jan/16/2020-|-22:11:50-|-BJFWH-|-5000-|-192.168.12.8\
    0-|-6C:D7:1F:23:3C:79-|-2d-|-2hari-|-up-441-12.23.19-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/16/2020
add comment=mikhmon name="jan/16/2020-|-22:46:47-|-CGSWF-|-15000-|-192.168.12.\
    101-|-A8:DB:03:0B:C2:F3-|-7d-|-7hari-|-up-652-01.01.20-" owner=jan2020 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jan/16/2020
add comment=mikhmon name="jan/16/2020-|-23:42:33-|-CCDZP-|-15000-|-192.168.12.\
    240-|-88:5A:06:66:12:E5-|-7d-|-7hari-|-up-652-01.01.20-" owner=jan2020 \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=jan/16/2020
add comment=mikhmon name="jan/17/2020-|-00:00:58-|-BTFZC-|-5000-|-192.168.12.4\
    8-|-28:83:35:94:FE:E2-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/17/2020
add comment=mikhmon name="jan/17/2020-|-02:10:45-|-BWNJS-|-5000-|-192.168.12.8\
    2-|-38:A4:ED:A1:2E:37-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/17/2020
add comment=mikhmon name="jan/17/2020-|-05:05:34-|-BTCRF-|-5000-|-192.168.12.5\
    0-|-1C:77:F6:E0:DE:02-|-2d-|-2hari-|-up-747-01.05.20-2hariferi" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/17/2020
add comment=mikhmon name="jan/17/2020-|-11:10:28-|-AFTGF-|-3000-|-192.168.12.2\
    54-|-18:89:5B:86:BB:08-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/17/2020
add comment=mikhmon name="jan/17/2020-|-11:12:23-|-AIZVM-|-3000-|-192.168.12.6\
    6-|-28:31:66:9A:D1:99-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/17/2020
add comment=mikhmon name="jan/17/2020-|-12:32:02-|-BCDTH-|-5000-|-192.168.12.2\
    08-|-00:0A:F5:C2:FC:7C-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/17/2020
add comment=mikhmon name="jan/17/2020-|-13:47:22-|-BHVWH-|-5000-|-192.168.12.1\
    93-|-20:5E:F7:FA:47:BC-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/17/2020
add comment=mikhmon name="jan/17/2020-|-16:36:46-|-BWCYC-|-5000-|-192.168.12.1\
    12-|-B4:CB:57:36:FA:A7-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/17/2020
add comment=mikhmon name="jan/17/2020-|-16:47:15-|-BVTMV-|-5000-|-192.168.12.1\
    28-|-4C:5C:FF:46:FE:99-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/17/2020
add comment=mikhmon name="jan/17/2020-|-19:03:35-|-BCJKR-|-5000-|-192.168.12.1\
    56-|-2C:56:DC:E7:15:E1-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/17/2020
add comment=mikhmon name="jan/17/2020-|-19:25:59-|-AZRAB-|-3000-|-192.168.12.1\
    51-|-5C:66:6C:D0:1F:37-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/17/2020
add comment=mikhmon name="jan/17/2020-|-19:28:49-|-BCWDU-|-5000-|-192.168.12.1\
    5-|-4C:1A:3D:83:30:70-|-2d-|-2hari-|-up-323-01.13.20-2hariudin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/17/2020
add comment=mikhmon name="jan/17/2020-|-19:33:49-|-CTNZE-|-15000-|-192.168.12.\
    49-|-A4:D9:90:28:BB:33-|-7d-|-7hari-|-up-869-09.28.19-feri7h" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/17/2020
add comment=mikhmon name="jan/17/2020-|-20:17:06-|-APPUG-|-3000-|-192.168.12.1\
    14-|-08:8C:2C:E5:59:4D-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/17/2020
add comment=mikhmon name="jan/17/2020-|-20:32:01-|-ADAGH-|-3000-|-192.168.12.2\
    1-|-F0:6D:78:42:12:1A-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/17/2020
add comment=mikhmon name="jan/18/2020-|-11:25:40-|-AMITV-|-3000-|-192.168.12.2\
    54-|-18:89:5B:86:BB:08-|-1d-|-1hari-|-up-258-01.01.20-1hariUdin" owner=\
    jan2020 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    jan/18/2020
/tool e-mail
set address=smtp.gmail.com from=<melatispot> password=f4c3b00k port=578 \
    start-tls=yes user=nurudinismail69@gmail.com
/tool netwatch
add comment=MyTunnel-DNS host=10.0.32.1

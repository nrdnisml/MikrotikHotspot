# oct/23/2019 09:34:57 by RouterOS 6.42.9
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
/interface vlan
add interface=eth2-home name=vlan_andre vlan-id=400
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
    \n" outgoing-packet-mark=down session-timeout=3h40m shared-users=5 \
    status-autorefresh=15s transparent-proxy=yes
/ip pool
add name=pool_leli ranges=172.16.2.3-172.16.2.254
add name=pool_PPPoE ranges=192.168.10.2-192.168.10.254
add name=pool_hotspot ranges=192.168.12.10-192.168.12.254
add name=pool_pendik ranges=172.16.3.5-172.16.3.254
add name=pool_andre ranges=172.16.4.5-172.16.4.100
/ip dhcp-server
add add-arp=yes address-pool=pool_pendik disabled=no interface=vlan_pendik \
    lease-time=1d10m name=dhcp2
add add-arp=yes address-pool=pool_leli disabled=no interface=vlan_leli \
    lease-time=1d10m name=dhcp3
add address-pool=pool_hotspot disabled=no interface=eth3-hotspot lease-time=\
    1d10m name=dhcp1
add add-arp=yes address-pool=pool_andre disabled=no interface=vlan_andre \
    lease-time=1d10m name=dhcp4
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
add max-limit=2M/5M name="1. PORT GAME DOWN" packet-marks=\
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
add name="2. ICMP DOWN" packet-marks="ICMP DOWNLOAD,ICMP UPLOAD" priority=1/1 \
    queue=default/default target="eth1-internet,192.168.12.0/24,vlan_leli,vlan\
    _pendik,172.16.0.0/24,192.168.10.0/24,172.16.4.0/24"
add max-limit=5M/37M name=ALLTRAFFIC packet-marks="SOSMED DOWNLOAD,SOSMED UPLO\
    AD,YOUTUBE DOWNLOAD,YOUTUBE UPLOAD,PORT BERAT DOWNLOAD,PORT BERAT UPLOAD,G\
    LOBAL DOWNLOAD,GLOBAL UPLOAD" priority=3/3 queue=pq-upload/pcq-download \
    target="192.168.10.0/24,eth2-home,vlan_leli,vlan_pendik,172.16.0.0/24,192.\
    168.12.0/24,172.16.4.0/24"
add max-limit=2M/30M name="3.1 HOTSPOT" parent=ALLTRAFFIC priority=5/5 queue=\
    default/default target=eth2-home,192.168.12.0/24
add max-limit=2M/12M name="3.2 HOME" parent=ALLTRAFFIC queue=\
    pq-upload/pcq-download target=\
    vlan_pendik,vlan_leli,vlan_andre,192.168.10.0/24
/ip hotspot user profile
add incoming-packet-mark=down !keepalive-timeout mac-cookie-timeout=1d name=\
    TRIALuser on-login=":put (\",,0,,,noexp,Disable,\")\r\
    \n" outgoing-packet-mark=up parent-queue="3.1 HOTSPOT" queue-type=\
    default-small rate-limit="512K/768K 1M/2M 768K/1500k 8" shared-users=30 \
    transparent-proxy=yes
add !idle-timeout !keepalive-timeout mac-cookie-timeout=1d name=1hari \
    on-login=":put (\",ntfc,3000,1d,,,Enable,\"); {:local date [ /system clock\
    \_get date ];:local year [ :pick \$date 7 11 ];:local month [ :pick \$date\
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
    \_set mac-address=\$mac [find where name=\$user]]}}\r\
    \n\r\
    \n" on-logout="\r\
    \n" open-status-page=http-login parent-queue="3.1 HOTSPOT" queue-type=\
    default-small rate-limit="512K/768K 1M/2M 768K/1500k 8" \
    transparent-proxy=yes
add !idle-timeout !keepalive-timeout mac-cookie-timeout=2d name=2hari \
    on-login=":put (\",ntfc,5000,2d,,,Enable,\"); {:local date [ /system clock\
    \_get date ];:local year [ :pick \$date 7 11 ];:local month [ :pick \$date\
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
    default-small rate-limit="512K/768K 1M/2M 768K/1500k 8" \
    transparent-proxy=yes
add !idle-timeout !keepalive-timeout mac-cookie-timeout=1w name=7hari \
    on-login=":put (\",ntfc,15000,7d,,,Enable,\"); {:local date [ /system cloc\
    k get date ];:local year [ :pick \$date 7 11 ];:local month [ :pick \$date\
    \_0 3 ];:local comment [ /ip hotspot user get [/ip hotspot user find where\
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
    r set mac-address=\$mac [find where name=\$user]]}}\r\
    \n\r\
    \n" on-logout="\r\
    \n" open-status-page=http-login parent-queue="3.1 HOTSPOT" queue-type=\
    default-small rate-limit="512K/768K 1M/2M 768K/1500k 8" \
    transparent-proxy=yes
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
    "512K/768K 1M/2M 768K/1500k 8" transparent-proxy=yes
/ip hotspot profile
add dns-name=melati.spot hotspot-address=192.168.12.1 html-directory=\
    flash/corner http-cookie-lifetime=1d login-by=\
    mac,cookie,http-chap,http-pap,trial mac-auth-mode=\
    mac-as-username-and-password name=hsprof1 trial-uptime-limit=10m \
    trial-user-profile=TRIALuser
/ip hotspot
add address-pool=pool_hotspot addresses-per-mac=1 disabled=no idle-timeout=1d \
    interface=eth3-hotspot keepalive-timeout=12h name=MELATISPOT profile=\
    hsprof1
/queue simple
add max-limit=1M/3M name=1.PENDIK parent="3.2 HOME" target=vlan_pendik
add max-limit=1M/3M name=2.LELI parent="3.2 HOME" target=vlan_leli
add burst-limit=1M/6M burst-threshold=1M/4300k burst-time=5s/5s max-limit=\
    1M/3M name="3. Andre" parent="3.2 HOME" target=vlan_andre
/queue tree
add max-limit=25M name="GLOBAL DOWN" parent=global queue=pcq-download-default
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
add address=172.16.4.1/24 interface=vlan_andre network=172.16.4.0
/ip cloud
set ddns-enabled=yes
/ip dhcp-client
add dhcp-options=hostname,clientid disabled=no interface=eth1-internet
/ip dhcp-server network
add address=10.0.0.0/24 gateway=10.0.0.1
add address=10.10.10.0/24 comment="hotspot network" gateway=10.10.10.1
add address=172.16.1.0/24 dns-server=8.8.8.8,118.98.44.10 gateway=172.16.1.1
add address=172.16.2.0/24 dns-server=8.8.8.8,118.98.44.10 gateway=172.16.2.1
add address=172.16.3.0/24 gateway=172.16.3.1
add address=172.16.4.0/24 dns-server=118.98.44.100,8.8.8.8 gateway=172.16.4.1
add address=192.168.12.0/24 comment="hotspot network" dns-server=\
    192.168.12.1,8.8.8.8 gateway=192.168.12.1
/ip dns
set allow-remote-requests=yes servers=192.168.12.1
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
    src-mac-address=24:FD:52:03:46:15 time=21h15m-4h,sun,mon,tue,wed,thu,fri
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
    "place hotspot rules here" disabled=yes
add action=masquerade chain=srcnat out-interface=eth1-internet
add action=masquerade chain=srcnat comment="masquerade hotspot network" \
    disabled=yes src-address=192.168.12.0/24
add action=passthrough chain=unused-hs-chain comment=\
    "place hotspot rules here" disabled=yes
add action=masquerade chain=srcnat comment="masquerade hotspot network" \
    src-address=10.10.10.0/24
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
add comment="hp ms dvd" mac-address=14:DD:A9:B0:23:F5 type=bypassed
add comment="hp iin" mac-address=34:97:F6:C6:0F:DA
add comment="lp udin" mac-address=54:27:1E:46:A8:03 type=bypassed
add mac-address=40:40:A7:56:5E:98
add comment="lp dvd" mac-address=AC:9E:17:9B:CE:A4 type=bypassed
add comment="lp dvd" mac-address=10:08:B1:43:98:EF type=bypassed
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
add address=192.168.12.7 comment=f609feri mac-address=D4:76:EA:DD:DB:23 \
    server=MELATISPOT type=bypassed
add comment="lp udin lan" mac-address=40:16:7E:95:9D:AC
add comment="hp nia" mac-address=80:AD:16:75:AC:62
add comment=riski mac-address=74:C6:3B:B9:E6:CD type=bypassed
/ip hotspot user
add comment=up- limit-uptime=12h name=ASLYJ password=8309 profile=1hari
add comment=up- limit-uptime=12h name=AEYJN password=2340 profile=1hari
add comment=up- limit-uptime=12h name=AUCWR password=5212 profile=1hari
add comment=up- name=BHABX password=7395 profile=2hari
add comment="sep/02/2019 11:59:01" limit-uptime=1s mac-address=\
    7C:03:5E:C9:04:FB name=BVIMX password=3437 profile=2hari
add comment="sep/10/2019 16:37:37" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=BSGMG password=8724 profile=2hari
add comment="sep/07/2019 14:07:19" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=BTPAM password=3684 profile=2hari
add comment="sep/09/2019 10:41:50" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=BNKKW password=3366 profile=2hari
add comment="sep/07/2019 20:04:45" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=BXEXW password=4992 profile=2hari
add comment="sep/19/2019 18:40:11" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=BBACS password=3772 profile=2hari
add comment="sep/07/2019 22:02:51" limit-uptime=1s mac-address=\
    74:29:AF:37:D8:01 name=BWKCV password=9556 profile=2hari
add comment="oct/07/2019 22:18:12" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=BZSAN password=9922 profile=2hari
add comment="sep/10/2019 23:26:00" limit-uptime=1s mac-address=\
    1C:87:2C:3F:F5:68 name=BFSVD password=7738 profile=2hari
add comment="sep/09/2019 19:11:15" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=BUKUH password=3842 profile=2hari
add comment="sep/01/2019 08:09:06" limit-uptime=1s mac-address=\
    08:7F:98:B0:5B:A1 name=AYRJR password=6237 profile=1hari
add comment="sep/19/2019 17:56:38" limit-uptime=1s mac-address=\
    1C:7B:21:A5:C5:93 name=AIHCE password=2853 profile=1hari
add name=BBAXX password=7890
add name=BFUTG password=3677
add comment=up- name=BVEKS password=7758 profile=2hari
add comment=up- name=CCBZC password=2727 profile=7hari
add disabled=yes name=CEK password=1
add mac-address=54:27:1E:46:A8:03 name=54:27:1E:46:A8:03 password=\
    54:27:1E:46:A8:03 profile=VIP
add mac-address=1C:B7:2C:47:C9:73 name=1C:B7:2C:47:C9:73 password=\
    1C:B7:2C:47:C9:73 profile=BINDING
add mac-address=34:97:F6:C6:0F:DA name=34:97:F6:C6:0F:DA password=\
    34:97:F6:C6:0F:DA profile=BINDING
add mac-address=40:40:A7:56:5E:98 name=40:40:A7:56:5E:98 password=\
    40:40:A7:56:5E:98 profile=BINDING
add mac-address=10:08:B1:43:98:EF name=10:08:B1:43:98:EF password=\
    10:08:B1:43:98:EF profile=BINDING
add name=AC:9E:17:9B:CE:A4 password=AC:9E:17:9B:CE:A4 profile=BINDING
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
    14:DD:A9:B0:23:F5 profile=BINDING
add comment="sep/07/2019 21:39:08" limit-uptime=1s mac-address=\
    E0:99:71:C7:B6:9F name=CJXUD password=7388 profile=7hari
add comment="sep/24/2019 09:40:20" limit-uptime=1s mac-address=\
    A4:D9:90:28:BB:33 name=CYFNG password=6338 profile=7hari
add comment="sep/11/2019 09:22:50" limit-uptime=1s mac-address=\
    C0:87:EB:4A:C9:1F name=CSRES password=5857 profile=7hari
add comment="sep/09/2019 20:52:28" limit-uptime=1s mac-address=\
    08:8C:2C:02:A3:A3 name=CLPJG password=8976 profile=7hari
add comment="sep/18/2019 17:57:32" limit-uptime=1s mac-address=\
    08:7F:98:C7:BC:29 name=CZVTW password=3454 profile=7hari
add comment="sep/25/2019 17:25:23" limit-uptime=1s mac-address=\
    C0:87:EB:4A:C9:1F name=CKFAA password=6564 profile=7hari
add comment="sep/15/2019 22:07:47" limit-uptime=1s mac-address=\
    E0:99:71:C7:B6:9F name=CUXMC password=9863 profile=7hari
add comment="sep/26/2019 16:20:25" limit-uptime=1s mac-address=\
    08:7F:98:C7:BC:29 name=CXXEE password=6439 profile=7hari
add comment="sep/17/2019 05:29:52" limit-uptime=1s mac-address=\
    A4:D9:90:28:BB:33 name=CNXWZ password=9824 profile=7hari
add comment="sep/09/2019 18:22:24" limit-uptime=1s mac-address=\
    08:7F:98:C7:BC:29 name=CLTFG password=2929 profile=7hari
add comment="sep/05/2019 18:26:38" limit-uptime=1s mac-address=\
    EC:D0:9F:CB:40:07 name=CDVBJ password=3346 profile=7hari
add comment="sep/24/2019 21:36:13" limit-uptime=1s mac-address=\
    E0:99:71:C7:B6:9F name=CLEYL password=6274 profile=7hari
add comment="oct/02/2019 13:55:45" limit-uptime=1s mac-address=\
    A4:D9:90:28:BB:33 name=CUPHL password=4299 profile=7hari
add comment="sep/19/2019 20:11:52" limit-uptime=1s mac-address=\
    08:8C:2C:02:A3:A3 name=CRBSE password=9963 profile=7hari
add comment="sep/02/2019 16:54:08" limit-uptime=1s mac-address=\
    08:7F:98:C7:BC:29 name=CXDFY password=9576 profile=7hari
add comment="sep/03/2019 17:54:20" limit-uptime=1s mac-address=\
    A4:D9:90:28:BB:33 name=CVFZJ password=7783 profile=7hari
add comment="sep/05/2019 19:07:55" limit-uptime=1s mac-address=\
    C0:87:EB:EE:62:DB name=CFLRP password=5845 profile=7hari
add comment="sep/18/2019 17:04:29" limit-uptime=1s mac-address=\
    C0:87:EB:4A:C9:1F name=CYKBH password=8682 profile=7hari
add comment="sep/03/2019 18:49:54" limit-uptime=1s mac-address=\
    C0:87:EB:4A:C9:1F name=CSZXG password=6838 profile=7hari
add comment="sep/10/2019 18:29:12" limit-uptime=1s mac-address=\
    A4:D9:90:28:BB:33 name=CEVZE password=6335 profile=7hari
add comment="sep/01/2019 19:13:16" limit-uptime=1s mac-address=\
    C0:87:EB:D5:D4:69 name=CETZX password=4656 profile=7hari
add comment="sep/03/2019 09:23:26" limit-uptime=1s mac-address=\
    74:29:AF:37:D8:01 name=BSYMS password=9299 profile=2hari
add comment=up-557-08.13.19-2hr130819 name=BGTUU password=2854 profile=2hari
add comment=up-557-08.13.19-2hr130819 name=BBYKD password=4932 profile=2hari
add comment="sep/04/2019 12:03:33" limit-uptime=1s mac-address=\
    C0:87:EB:5A:BC:3F name=BUTVX password=9326 profile=2hari
add comment="aug/31/2019 20:09:16" limit-uptime=1s mac-address=\
    20:5E:F7:E8:78:B2 name=BRVFR password=7663 profile=2hari
add comment="aug/31/2019 19:12:37" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=BVWNX password=7843 profile=2hari
add comment="aug/31/2019 19:49:26" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=BHJNE password=5784 profile=2hari
add comment="sep/01/2019 20:47:05" limit-uptime=1s mac-address=\
    C0:87:EB:5A:BC:3F name=BBUNC password=9976 profile=2hari
add mac-address=40:16:7E:95:9D:AC name=40:16:7E:95:9D:AC password=\
    40:16:7E:95:9D:AC profile=BINDING
add mac-address=A4:D9:90:37:57:51 name=A4:D9:90:37:57:51 password=\
    A4:D9:90:37:57:51 profile=VIP
add mac-address=80:AD:16:75:AC:62 name=80:AD:16:75:AC:62 password=\
    80:AD:16:75:AC:62 profile=BINDING
add comment="sep/21/2019 23:26:44" limit-uptime=1s mac-address=\
    34:31:11:F9:B8:12 name=AKBMI password=6799 profile=1hari
add comment="sep/25/2019 21:59:22" limit-uptime=1s mac-address=\
    6C:D7:1F:23:3C:79 name=AJVTX password=5984 profile=1hari
add comment="sep/27/2019 07:03:10" limit-uptime=1s mac-address=\
    C0:87:EB:5A:BC:3F name=AKYYY password=8429 profile=1hari
add comment="sep/23/2019 19:52:51" limit-uptime=1s mac-address=\
    00:0A:F5:4E:69:4C name=AHDYF password=4869 profile=1hari
add comment="sep/28/2019 18:56:28" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=AUFKS password=9987 profile=1hari
add comment="sep/21/2019 23:21:11" limit-uptime=1s mac-address=\
    0C:98:38:94:60:51 name=ANYGW password=2783 profile=1hari
add comment="sep/24/2019 21:06:45" limit-uptime=1s mac-address=\
    C0:87:EB:5A:BC:3F name=AJACR password=8633 profile=1hari
add comment="sep/21/2019 23:22:52" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=ADFTS password=7574 profile=1hari
add comment="sep/24/2019 19:07:37" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=AKGVV password=6334 profile=1hari
add comment="sep/30/2019 19:16:13" limit-uptime=1s mac-address=\
    00:0A:F5:4E:69:4C name=ABZFT password=3432 profile=1hari
add comment="sep/24/2019 13:25:30" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=AVARE password=3773 profile=1hari
add comment="sep/29/2019 20:59:08" limit-uptime=1s mac-address=\
    60:A4:D0:B9:1E:48 name=AIEWZ password=5246 profile=1hari
add comment="sep/21/2019 13:04:28" limit-uptime=1s mac-address=\
    C0:87:EB:5A:BC:3F name=AMFNV password=7388 profile=1hari
add comment="sep/25/2019 12:37:26" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=AZXNK password=7898 profile=1hari
add comment="sep/29/2019 21:51:25" limit-uptime=1s mac-address=\
    08:7F:98:E1:84:ED name=ANXNR password=2753 profile=1hari
add comment="sep/29/2019 21:32:22" limit-uptime=1s mac-address=\
    08:7F:98:C7:BC:29 name=AYAHD password=6537 profile=1hari
add comment="sep/27/2019 18:36:12" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=AYAST password=3283 profile=1hari
add comment="sep/25/2019 17:53:32" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=AFRFB password=5325 profile=1hari
add comment="sep/28/2019 09:24:16" limit-uptime=1s mac-address=\
    08:7F:98:E1:84:ED name=ARRWZ password=3579 profile=1hari
add comment="sep/30/2019 13:33:50" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=AXTFE password=2868 profile=1hari
add comment="sep/28/2019 20:24:35" limit-uptime=1s mac-address=\
    60:A4:D0:B9:1E:48 name=ATTDK password=2835 profile=1hari
add comment="sep/23/2019 15:39:04" limit-uptime=1s mac-address=\
    C0:87:EB:5A:BC:3F name=AXGHN password=7568 profile=1hari
add comment="sep/27/2019 14:41:43" limit-uptime=1s mac-address=\
    6C:D7:1F:23:3C:79 name=ADFMD password=7347 profile=1hari
add comment="sep/29/2019 21:51:51" limit-uptime=1s mac-address=\
    6C:D7:1F:27:2E:83 name=AFHMC password=9237 profile=1hari
add comment="oct/01/2019 18:46:04" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=AXFZC password=3696 profile=1hari
add comment="sep/28/2019 06:31:39" limit-uptime=1s mac-address=\
    0C:98:38:94:60:51 name=AXVUX password=3653 profile=1hari
add comment="sep/30/2019 21:35:04" limit-uptime=1s mac-address=\
    08:7F:98:C7:BC:29 name=AZTNF password=6843 profile=1hari
add comment="oct/01/2019 16:42:11" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=AYUCX password=4245 profile=1hari
add comment="sep/30/2019 12:59:09" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=AKSFR password=8236 profile=1hari
add comment="sep/30/2019 18:15:24" limit-uptime=1s mac-address=\
    60:72:8D:62:53:EB name=AGEPD password=3675 profile=1hari
add comment="sep/03/2019 18:24:14" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=AFCZE password=9467 profile=1hari
add comment="sep/03/2019 21:08:22" limit-uptime=1s mac-address=\
    1C:87:2C:84:DE:88 name=AACDP password=9272 profile=1hari
add comment="sep/13/2019 08:31:54" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=AIZWA password=8575 profile=1hari
add comment="sep/10/2019 19:31:02" limit-uptime=1s mac-address=\
    24:2E:02:8D:5E:F4 name=ABMVF password=5546 profile=1hari
add comment="sep/05/2019 18:21:43" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=AWHUA password=6749 profile=1hari
add comment="sep/03/2019 19:08:14" limit-uptime=1s mac-address=\
    CC:2D:83:90:04:D7 name=AKHNC password=9857 profile=1hari
add comment="sep/03/2019 21:07:35" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=ASDVG password=3863 profile=1hari
add comment="sep/12/2019 17:16:10" limit-uptime=1s mac-address=\
    3C:95:09:E7:6D:13 name=AERIF password=3345 profile=1hari
add comment="sep/16/2019 09:29:04" limit-uptime=1s mac-address=\
    0C:A8:A7:48:10:18 name=AWKYT password=6853 profile=1hari
add comment="sep/07/2019 17:56:32" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=AGJGN password=4672 profile=1hari
add comment="sep/03/2019 19:07:33" limit-uptime=1s mac-address=\
    0C:98:38:6A:6A:51 name=AHFDJ password=9988 profile=1hari
add comment="sep/04/2019 17:24:17" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=ATSHB password=3874 profile=1hari
add comment="sep/12/2019 20:10:07" limit-uptime=1s mac-address=\
    00:0A:F5:C2:FC:7C name=AEKMH password=2983 profile=1hari
add comment="sep/15/2019 19:03:22" limit-uptime=1s mac-address=\
    6C:D7:1F:27:2E:83 name=AMIJW password=2234 profile=1hari
add comment="sep/08/2019 18:05:28" limit-uptime=1s mac-address=\
    60:72:8D:62:53:EB name=AIDXJ password=9954 profile=1hari
add comment="sep/03/2019 19:32:02" limit-uptime=1s mac-address=\
    0C:A8:A7:48:10:18 name=ARNRV password=7452 profile=1hari
add comment="sep/12/2019 20:03:38" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=AYHJU password=8973 profile=1hari
add comment="sep/15/2019 16:30:28" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=ABEYA password=3635 profile=1hari
add comment="sep/17/2019 21:38:05" limit-uptime=1s mac-address=\
    0C:A8:A7:48:10:18 name=AVYZH password=5967 profile=1hari
add comment="sep/11/2019 07:21:03" limit-uptime=1s mac-address=\
    08:7F:98:E1:84:ED name=AXHHJ password=5767 profile=1hari
add comment="sep/05/2019 00:20:44" limit-uptime=1s mac-address=\
    0C:A8:A7:48:10:18 name=AABSC password=9899 profile=1hari
add comment="sep/29/2019 17:45:30" limit-uptime=1s mac-address=\
    60:72:8D:62:53:EB name=AAYVB password=7856 profile=1hari
add comment="sep/06/2019 12:47:54" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=ARRKB password=4799 profile=1hari
add comment="sep/17/2019 12:48:50" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=ANZJX password=7922 profile=1hari
add comment="sep/06/2019 19:09:20" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=ANSIG password=5667 profile=1hari
add comment="sep/04/2019 21:43:53" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=AIMBZ password=6235 profile=1hari
add comment="sep/03/2019 20:02:20" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=AVEHT password=6472 profile=1hari
add comment="sep/15/2019 19:00:47" limit-uptime=1s mac-address=\
    60:72:8D:62:53:EB name=ANMWG password=3295 profile=1hari
add comment="sep/16/2019 04:55:12" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=ABZTU password=8333 profile=1hari
add comment="sep/03/2019 17:24:04" limit-uptime=1s mac-address=\
    0C:A8:A7:B4:5E:7E name=AHRNF password=2982 profile=1hari
add comment="sep/09/2019 01:07:20" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=AYXSM password=3237 profile=1hari
add comment="sep/13/2019 19:23:55" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=ARNVH password=7687 profile=1hari
add comment="sep/18/2019 18:16:06" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=ADGTK password=5278 profile=1hari
add comment="sep/23/2019 19:28:36" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=AGYDR password=2449 profile=1hari
add comment="sep/11/2019 06:48:58" limit-uptime=1s mac-address=\
    88:5A:06:66:12:E5 name=AFUPD password=4969 profile=1hari
add comment="sep/14/2019 20:59:08" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=ARMCZ password=5955 profile=1hari
add comment="sep/25/2019 12:53:25" limit-uptime=1s mac-address=\
    00:0A:F5:C2:FC:7C name=ANCDX password=5647 profile=1hari
add comment="sep/23/2019 10:13:36" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=AWHKP password=3877 profile=1hari
add comment="sep/06/2019 19:48:45" limit-uptime=1s mac-address=\
    C0:87:EB:5A:BC:3F name=AFXUW password=4363 profile=1hari
add comment="sep/05/2019 19:27:30" limit-uptime=1s mac-address=\
    C0:87:EB:5A:BC:3F name=AKPXJ password=8678 profile=1hari
add comment="sep/14/2019 20:57:56" limit-uptime=1s mac-address=\
    C0:87:EB:5A:BC:3F name=AFDMA password=3764 profile=1hari
add comment="sep/18/2019 17:28:12" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=AIHJK password=3526 profile=1hari
add comment="sep/22/2019 18:03:08" limit-uptime=1s mac-address=\
    1C:87:2C:3F:F5:68 name=APXHJ password=8423 profile=1hari
add comment="sep/08/2019 13:35:07" limit-uptime=1s mac-address=\
    08:7F:98:B0:5B:A1 name=ARNAT password=6332 profile=1hari
add comment="sep/13/2019 19:10:22" limit-uptime=1s mac-address=\
    C0:87:EB:5A:BC:3F name=AGBFA password=4838 profile=1hari
add comment="sep/14/2019 11:59:49" limit-uptime=1s mac-address=\
    F4:F5:DB:10:02:37 name=AGFTE password=7984 profile=1hari
add comment="sep/18/2019 19:17:46" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=AHUFX password=6493 profile=1hari
add comment="sep/21/2019 18:56:09" limit-uptime=1s mac-address=\
    08:7F:98:E1:84:ED name=AFIMX password=7633 profile=1hari
add comment="sep/07/2019 21:21:37" limit-uptime=1s mac-address=\
    C0:87:EB:5A:BC:3F name=ATXHY password=7733 profile=1hari
add comment="sep/08/2019 22:45:14" limit-uptime=1s mac-address=\
    C0:87:EB:5A:BC:3F name=ANAJV password=5499 profile=1hari
add comment="sep/12/2019 18:56:22" limit-uptime=1s mac-address=\
    C0:87:EB:5A:BC:3F name=AKMNE password=7239 profile=1hari
add comment="sep/19/2019 19:16:33" limit-uptime=1s mac-address=\
    CC:2D:83:90:04:D7 name=AECJY password=3954 profile=1hari
add comment="sep/21/2019 18:53:23" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=AMNVT password=6575 profile=1hari
add comment="sep/13/2019 11:58:11" limit-uptime=1s mac-address=\
    7C:03:5E:C9:04:FB name=AERMG password=7654 profile=1hari
add comment="sep/12/2019 19:01:32" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=AYCEJ password=4877 profile=1hari
add comment="sep/03/2019 18:21:25" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=AMSSW password=2223 profile=1hari
add comment="sep/18/2019 18:40:15" limit-uptime=1s mac-address=\
    6C:D7:1F:27:2E:83 name=ASCSH password=8356 profile=1hari
add comment="sep/21/2019 12:13:26" limit-uptime=1s mac-address=\
    60:72:8D:62:53:EB name=AEDYR password=3747 profile=1hari
add comment="sep/02/2019 19:58:13" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=AFDGR password=4339 profile=1hari
add comment="sep/01/2019 19:54:07" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=ADWMF password=4225 profile=1hari
add comment="sep/02/2019 18:05:15" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=AIWZZ password=6632 profile=1hari
add comment="sep/01/2019 19:05:26" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=AMZNZ password=3439 profile=1hari
add comment="sep/02/2019 10:49:07" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=ARHPZ password=3583 profile=1hari
add comment="sep/01/2019 07:11:57" limit-uptime=1s mac-address=\
    08:7F:98:E1:84:ED name=AZHDN password=6643 profile=1hari
add comment="sep/01/2019 20:37:44" limit-uptime=1s mac-address=\
    0C:98:38:6A:6A:51 name=AVTPP password=2338 profile=1hari
add comment="sep/01/2019 21:41:30" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=AINCU password=3729 profile=1hari
add comment="aug/31/2019 22:54:28" limit-uptime=1s mac-address=\
    74:29:AF:37:D8:01 name=ARVSN password=9697 profile=1hari
add comment="sep/01/2019 07:28:58" limit-uptime=1s mac-address=\
    18:F0:E4:6C:02:34 name=AESMD password=6853 profile=1hari
add comment="sep/02/2019 21:31:56" limit-uptime=1s mac-address=\
    18:F0:E4:6C:02:34 name=AWYIH password=5549 profile=1hari
add comment="aug/31/2019 17:52:58" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=AJMDH password=8449 profile=1hari
add comment="sep/01/2019 18:13:46" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=AWHPR password=7296 profile=1hari
add comment="aug/31/2019 18:48:05" limit-uptime=1s mac-address=\
    0C:A8:A7:B4:5E:7E name=AHNAN password=2397 profile=1hari
add comment="sep/01/2019 19:44:47" limit-uptime=1s mac-address=\
    0C:A8:A7:B4:5E:7E name=ASWFT password=6329 profile=1hari
add comment="sep/20/2019 19:00:49" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=BFIJJ password=5552 profile=2hari
add comment="sep/23/2019 16:39:50" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=BMEJI password=5227 profile=2hari
add comment="sep/27/2019 13:13:59" limit-uptime=1s mac-address=\
    00:0A:F5:C2:FC:7C name=BUERX password=4384 profile=2hari
add comment="sep/30/2019 14:38:51" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=BUBVT password=9646 profile=2hari
add comment="sep/27/2019 22:21:30" limit-uptime=1s mac-address=\
    CC:2D:83:90:04:D7 name=BFPRS password=8954 profile=2hari
add comment="sep/25/2019 20:17:09" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=BZNWK password=8284 profile=2hari
add comment="sep/20/2019 19:20:10" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=BTRGV password=7833 profile=2hari
add comment="oct/04/2019 16:37:13" limit-uptime=1s mac-address=\
    60:72:8D:62:53:EB name=BEPSM password=3759 profile=2hari
add comment="sep/28/2019 10:23:57" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=BDFTG password=2732 profile=2hari
add comment="sep/24/2019 19:09:37" limit-uptime=1s mac-address=\
    CC:2D:83:90:04:D7 name=BHFEX password=2544 profile=2hari
add comment="oct/03/2019 22:32:36" limit-uptime=1s mac-address=\
    C4:0B:CB:E3:2B:3C name=BNJWC password=8756 profile=2hari
add comment="sep/27/2019 12:43:30" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=BKMJR password=4456 profile=2hari
add comment="sep/21/2019 14:02:33" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=BXFSG password=3892 profile=2hari
add comment="sep/28/2019 00:56:38" limit-uptime=1s mac-address=\
    38:A4:ED:A1:2E:37 name=BNHIT password=2377 profile=2hari
add comment="sep/28/2019 12:00:19" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=BFRFU password=9264 profile=2hari
add comment="sep/30/2019 18:54:09" limit-uptime=1s mac-address=\
    C0:87:EB:35:15:4B name=BRUAD password=4347 profile=2hari
add comment="oct/03/2019 11:55:26" limit-uptime=1s mac-address=\
    38:A4:ED:A1:2E:37 name=BNPMR password=3555 profile=2hari
add comment="sep/24/2019 20:13:29" limit-uptime=1s mac-address=\
    1C:87:2C:3F:F5:68 name=BSVJY password=2425 profile=2hari
add comment="sep/21/2019 19:03:31" limit-uptime=1s mac-address=\
    00:0A:F5:C2:FC:7C name=BVDMW password=8865 profile=2hari
add comment="sep/22/2019 19:19:09" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=BSJNB password=3622 profile=2hari
add comment="sep/28/2019 17:50:12" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=BAHFI password=2493 profile=2hari
add comment="sep/27/2019 14:45:16" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=BRRIM password=9836 profile=2hari
add comment="oct/01/2019 13:39:33" limit-uptime=1s mac-address=\
    68:05:71:EA:EF:29 name=BFCSF password=7969 profile=2hari
add comment="sep/25/2019 15:53:40" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=BPKXH password=2469 profile=2hari
add comment="sep/21/2019 18:35:47" limit-uptime=1s mac-address=\
    1C:87:2C:3F:F5:68 name=BJKWM password=7645 profile=2hari
add comment="sep/26/2019 00:35:48" limit-uptime=1s mac-address=\
    38:A4:ED:A1:2E:37 name=BMWEK password=6832 profile=2hari
add comment="sep/28/2019 18:13:51" limit-uptime=1s mac-address=\
    1C:87:2C:3F:F5:68 name=BNJTB password=4547 profile=2hari
add comment="sep/30/2019 18:30:33" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=BIWDZ password=7422 profile=2hari
add comment="sep/23/2019 13:21:22" limit-uptime=1s mac-address=\
    38:A4:ED:A1:2E:37 name=BSYGZ password=4459 profile=2hari
add comment="sep/25/2019 13:45:54" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=BEKWV password=3239 profile=2hari
add comment="sep/29/2019 12:42:31" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=BUCPF password=9499 profile=2hari
add comment="oct/01/2019 10:38:39" limit-uptime=1s mac-address=\
    38:A4:ED:A1:2E:37 name=BARGZ password=3857 profile=2hari
add comment="sep/22/2019 18:24:55" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=BVVRW password=8468 profile=2hari
add comment="sep/30/2019 12:30:36" limit-uptime=1s mac-address=\
    00:0A:F5:C2:FC:7C name=BVJJM password=7793 profile=2hari
add comment="sep/23/2019 15:02:25" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=BVDIU password=4556 profile=2hari
add comment="sep/23/2019 23:21:06" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=BPVGI password=6676 profile=2hari
add comment="sep/27/2019 11:28:50" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=BVBWB password=3862 profile=2hari
add comment="oct/05/2019 11:08:01" limit-uptime=1s mac-address=\
    00:0A:F5:C2:FC:7C name=BGUWP password=9778 profile=2hari
add comment="oct/05/2019 11:51:49" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=BUPBT password=6286 profile=2hari
add comment="oct/06/2019 19:35:41" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=BZHDD password=8889 profile=2hari
add comment="oct/06/2019 22:51:37" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=BSSYS password=5648 profile=2hari
add comment="oct/05/2019 14:18:35" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=BRKDB password=3238 profile=2hari
add comment=up-675-09.02.19-2Hari2Sept19 name=BPIPA password=8228 profile=\
    2hari
add comment="oct/05/2019 06:24:58" limit-uptime=1s mac-address=\
    80:AD:16:76:6E:5E name=BGEXG password=9586 profile=2hari
add comment="oct/03/2019 17:52:31" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=BKSYS password=6728 profile=2hari
add comment="oct/07/2019 19:48:32" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=BWNIX password=4863 profile=2hari
add comment="oct/03/2019 14:59:27" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=BGPZS password=8536 profile=2hari
add comment="oct/02/2019 18:58:01" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=BJMNV password=2477 profile=2hari
add comment="sep/30/2019 12:22:55" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=BBBUA password=6463 profile=2hari
add comment="oct/02/2019 17:05:42" limit-uptime=1s mac-address=\
    00:0A:F5:C2:FC:7C name=BZAJB password=3999 profile=2hari
add comment="oct/06/2019 11:25:07" limit-uptime=1s mac-address=\
    C4:0B:CB:E3:2B:3C name=BWCFT password=8337 profile=2hari
add comment="oct/05/2019 19:52:07" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=BKDAT password=9742 profile=2hari
add comment="oct/04/2019 22:24:12" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=BPVKU password=5322 profile=2hari
add comment="oct/04/2019 16:05:01" limit-uptime=1s mac-address=\
    24:79:F3:52:26:EB name=BYWIS password=2522 profile=2hari
add comment="sep/26/2019 10:41:18" limit-uptime=1s mac-address=\
    CC:2D:83:A7:D7:0D name=BGBJD password=6423 profile=2hari
add comment="sep/30/2019 19:20:24" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=BIDJZ password=7499 profile=2hari
add comment="oct/03/2019 19:28:13" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=BZYBX password=3553 profile=2hari
add comment="oct/07/2019 11:45:57" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=BVBDR password=8426 profile=2hari
add comment="oct/05/2019 15:03:10" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=BRIKY password=4792 profile=2hari
add comment="oct/01/2019 19:38:38" limit-uptime=1s mac-address=\
    CC:2D:83:90:04:D7 name=BDPRR password=4552 profile=2hari
add comment="sep/26/2019 19:58:17" limit-uptime=1s mac-address=\
    1C:87:2C:3F:F5:68 name=BFJNI password=8367 profile=2hari
add comment="sep/30/2019 19:11:31" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=BMSWY password=4625 profile=2hari
add comment="oct/04/2019 01:05:35" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=BVBIC password=8663 profile=2hari
add comment="oct/02/2019 19:43:11" limit-uptime=1s mac-address=\
    6C:D7:1F:27:2E:83 name=BWHUR password=8887 profile=2hari
add comment="oct/02/2019 19:00:48" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=BIGXF password=4376 profile=2hari
add comment="oct/04/2019 14:36:12" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=BCRJS password=8387 profile=2hari
add comment="sep/25/2019 21:03:21" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=BXCDS password=3828 profile=2hari
add comment="sep/30/2019 19:02:15" limit-uptime=1s mac-address=\
    1C:87:2C:3F:F5:68 name=BIMUA password=4727 profile=2hari
add comment="oct/05/2019 19:48:27" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=BINCK password=7669 profile=2hari
add comment="oct/06/2019 10:54:22" limit-uptime=1s mac-address=\
    C0:87:EB:D5:D4:69 name=BPZWU password=3354 profile=2hari
add comment="oct/03/2019 20:14:19" limit-uptime=1s mac-address=\
    30:CB:F8:E0:09:43 name=BVNVP password=6558 profile=2hari
add comment="oct/02/2019 20:08:12" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=BVARV password=6939 profile=2hari
add comment="sep/13/2019 19:26:12" limit-uptime=1s mac-address=\
    60:A4:D0:B9:1E:48 name=BFDEB password=9556 profile=2hari
add comment="sep/16/2019 16:54:33" limit-uptime=1s mac-address=\
    7C:03:5E:C9:04:FB name=BYSDE password=4724 profile=2hari
add comment="sep/17/2019 16:18:19" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=BRIHX password=7573 profile=2hari
add comment="sep/18/2019 20:04:53" limit-uptime=1s mac-address=\
    60:A4:D0:B9:1E:48 name=BBYJY password=7537 profile=2hari
add comment="sep/14/2019 06:41:43" limit-uptime=1s mac-address=\
    10:2A:B3:49:D9:BB name=BADDB password=2636 profile=2hari
add comment="sep/11/2019 19:21:42" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=BDUIA password=5557 profile=2hari
add comment="sep/11/2019 15:43:57" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=BHNTP password=8888 profile=2hari
add comment="sep/14/2019 23:32:22" limit-uptime=1s mac-address=\
    38:A4:ED:A1:2E:37 name=BFEAK password=7527 profile=2hari
add comment="sep/15/2019 05:44:45" limit-uptime=1s mac-address=\
    48:88:CA:0B:65:02 name=BRMAJ password=9279 profile=2hari
add comment="sep/19/2019 07:37:03" limit-uptime=1s mac-address=\
    C0:87:EB:5A:BC:3F name=BGFJF password=5685 profile=2hari
add comment="sep/17/2019 22:41:33" limit-uptime=1s mac-address=\
    74:29:AF:37:D8:01 name=BXCAR password=7589 profile=2hari
add comment="sep/12/2019 16:01:27" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=BGWMI password=6773 profile=2hari
add comment="sep/11/2019 17:55:27" limit-uptime=1s mac-address=\
    C0:87:EB:5A:BC:3F name=BDFTD password=8238 profile=2hari
add comment="sep/21/2019 19:18:59" limit-uptime=1s mac-address=\
    60:A4:D0:B9:1E:48 name=BFBIV password=4296 profile=2hari
add comment="sep/28/2019 17:10:19" limit-uptime=1s mac-address=\
    08:7F:98:C7:BC:29 name=BHADB password=6675 profile=2hari
add comment="sep/23/2019 12:54:08" limit-uptime=1s mac-address=\
    0C:A8:A7:48:10:18 name=BEXXR password=4549 profile=2hari
add comment="sep/21/2019 21:58:33" limit-uptime=1s mac-address=\
    74:29:AF:37:D8:01 name=BMIHG password=6469 profile=2hari
add comment="sep/12/2019 21:29:26" limit-uptime=1s mac-address=\
    F0:6D:78:78:4A:70 name=BCGDU password=9993 profile=2hari
add comment="sep/13/2019 17:54:03" limit-uptime=1s mac-address=\
    58:44:98:BA:56:06 name=BSHEW password=3264 profile=2hari
add comment="sep/17/2019 15:39:42" limit-uptime=1s mac-address=\
    C0:87:EB:5A:BC:3F name=BZGDG password=2683 profile=2hari
add comment="sep/29/2019 19:12:36" limit-uptime=1s mac-address=\
    6C:D7:1F:23:3C:79 name=BUXUU password=3975 profile=2hari
add comment="sep/22/2019 19:37:20" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=BVXWC password=6392 profile=2hari
add comment="sep/20/2019 11:37:45" limit-uptime=1s mac-address=\
    F4:F5:DB:10:02:37 name=BWACA password=7936 profile=2hari
add comment="sep/19/2019 01:50:14" limit-uptime=1s mac-address=\
    C4:0B:CB:E3:2B:3C name=BRBGG password=6937 profile=2hari
add comment="sep/19/2019 18:55:42" limit-uptime=1s mac-address=\
    E0:06:E6:79:95:19 name=BXUCR password=7285 profile=2hari
add comment="sep/27/2019 18:38:09" limit-uptime=1s mac-address=\
    60:A4:D0:B9:1E:48 name=BJWJV password=2874 profile=2hari
add comment="sep/25/2019 23:24:25" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=BYBXP password=3372 profile=2hari
add comment="sep/23/2019 23:24:38" limit-uptime=1s mac-address=\
    0C:98:38:94:60:51 name=BEEGS password=9857 profile=2hari
add comment="sep/19/2019 19:37:14" limit-uptime=1s mac-address=\
    90:94:97:72:FD:B7 name=BYZHW password=2577 profile=2hari
add comment="sep/12/2019 12:53:25" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=BXDWX password=4849 profile=2hari
add comment="sep/15/2019 20:58:23" limit-uptime=1s mac-address=\
    60:A4:D0:B9:1E:48 name=BXMNM password=5822 profile=2hari
add comment="sep/25/2019 20:49:51" limit-uptime=1s mac-address=\
    60:A4:D0:B9:1E:48 name=BPTDK password=3969 profile=2hari
add comment="sep/16/2019 11:50:57" limit-uptime=1s mac-address=\
    08:7F:98:B0:5B:A1 name=BVRJK password=4364 profile=2hari
add comment="sep/23/2019 19:36:29" limit-uptime=1s mac-address=\
    60:A4:D0:B9:1E:48 name=BFXDH password=6399 profile=2hari
add comment="sep/29/2019 18:39:39" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=BSHBV password=7845 profile=2hari
add comment="sep/12/2019 11:47:46" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=BXRXP password=4667 profile=2hari
add comment="sep/09/2019 05:35:20" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=BNPJK password=5544 profile=2hari
add comment="sep/10/2019 19:04:08" limit-uptime=1s mac-address=\
    3C:95:09:E7:6D:13 name=BKZHE password=7944 profile=2hari
add comment="sep/10/2019 19:40:47" limit-uptime=1s mac-address=\
    F0:6D:78:78:4A:70 name=BIMKK password=7253 profile=2hari
add comment="sep/13/2019 16:38:50" limit-uptime=1s mac-address=\
    1C:87:2C:3F:F5:68 name=BAXMC password=5647 profile=2hari
add comment="sep/16/2019 14:03:31" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=BEZFW password=5988 profile=2hari
add comment="sep/18/2019 19:27:09" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=BPKJI password=6272 profile=2hari
add comment="sep/08/2019 19:07:26" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=BYBUN password=7853 profile=2hari
add comment="sep/11/2019 11:11:56" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=BBNAA password=4823 profile=2hari
add comment="sep/13/2019 17:50:49" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=BSTZN password=4846 profile=2hari
add comment="sep/15/2019 17:09:09" limit-uptime=1s mac-address=\
    1C:87:2C:3F:F5:68 name=BNGHZ password=5783 profile=2hari
add comment="sep/17/2019 20:36:55" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=BJZXY password=5947 profile=2hari
add comment="sep/19/2019 21:38:19" limit-uptime=1s mac-address=\
    74:29:AF:37:D8:01 name=BZPIG password=2679 profile=2hari
add comment="sep/08/2019 12:36:02" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=BBWNS password=2377 profile=2hari
add comment="sep/11/2019 19:14:52" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=BJMDY password=3687 profile=2hari
add comment="sep/16/2019 19:39:57" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=BTGYU password=2526 profile=2hari
add comment="sep/17/2019 12:38:39" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=BUZRX password=7633 profile=2hari
add comment="sep/19/2019 21:59:37" limit-uptime=1s mac-address=\
    0C:A8:A7:48:10:18 name=BHHAD password=7883 profile=2hari
add comment=up-675-09.02.19-2Hari2Sept19 name=BCBWF password=7886 profile=\
    2hari
add comment="sep/08/2019 09:17:00" limit-uptime=1s mac-address=\
    0C:A8:A7:48:10:18 name=BYZWY password=7488 profile=2hari
add comment="sep/11/2019 01:13:06" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=BKUUY password=3267 profile=2hari
add comment="sep/15/2019 19:41:31" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=BKEIA password=3893 profile=2hari
add comment="sep/20/2019 18:21:05" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=BTBJY password=3568 profile=2hari
add comment="sep/14/2019 13:50:52" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=BZARK password=2644 profile=2hari
add comment=up-675-09.02.19-2Hari2Sept19 name=BZYUH password=6887 profile=\
    2hari
add comment="sep/08/2019 10:48:20" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=BKKPG password=6485 profile=2hari
add comment="sep/19/2019 16:43:36" limit-uptime=1s mac-address=\
    00:0A:F5:C2:FC:7C name=BYKGJ password=5274 profile=2hari
add comment="sep/15/2019 11:06:09" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=BJKRC password=9299 profile=2hari
add comment="sep/19/2019 14:48:52" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=BIBSX password=8272 profile=2hari
add comment="sep/15/2019 20:36:01" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=BNCDM password=7885 profile=2hari
add comment="sep/08/2019 17:57:02" limit-uptime=1s mac-address=\
    20:5E:F7:E8:78:B2 name=BUGVT password=6297 profile=2hari
add comment="sep/09/2019 18:03:04" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=BSHIF password=2797 profile=2hari
add comment="sep/15/2019 19:40:40" limit-uptime=1s mac-address=\
    C0:87:EB:35:15:4B name=BCBRW password=8353 profile=2hari
add comment="sep/20/2019 17:40:05" limit-uptime=1s mac-address=\
    CC:2D:83:A7:D7:0D name=BUEHH password=8638 profile=2hari
add comment="sep/18/2019 18:03:18" limit-uptime=1s mac-address=\
    1C:87:2C:3F:F5:68 name=BKKEI password=7525 profile=2hari
add comment="sep/17/2019 18:08:18" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=BWRAU password=2677 profile=2hari
add comment="sep/04/2019 20:10:11" limit-uptime=1s mac-address=\
    1C:87:2C:3F:F5:68 name=BUKMF password=8896 profile=2hari
add comment="sep/05/2019 02:05:24" limit-uptime=1s mac-address=\
    74:29:AF:37:D8:01 name=BXRJN password=8756 profile=2hari
add comment="sep/06/2019 19:21:15" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=BAAMJ password=6326 profile=2hari
add comment="sep/05/2019 19:13:10" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=BXGMR password=9953 profile=2hari
add comment="sep/06/2019 19:11:40" limit-uptime=1s mac-address=\
    1C:87:2C:3F:F5:68 name=BFEEZ password=7754 profile=2hari
add comment="sep/06/2019 20:38:38" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=BWMHC password=6377 profile=2hari
add comment="sep/13/2019 05:30:34" limit-uptime=1s mac-address=\
    68:05:71:EA:EF:29 name=Aziz password=1233 profile=1hari
add comment=up-881-09.20.19-7H20Sept19 name=CTFJT password=4636 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CRWSW password=6658 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CENHZ password=4295 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CEBBX password=5844 profile=7hari
add comment="oct/17/2019 15:43:42" limit-uptime=1s mac-address=\
    C0:87:EB:4A:C9:1F name=CIDTH password=7562 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CMRYA password=7945 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CGDNU password=3733 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CMMGG password=2832 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CYKXG password=9889 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CFUCP password=6625 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CFDSY password=9854 profile=7hari
add comment="oct/27/2019 16:44:11" mac-address=C0:87:EB:D5:D4:69 name=CTHIA \
    password=5384 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CHDYS password=2623 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CXGCN password=5778 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CCMSK password=5367 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CUNHD password=7958 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CPEWI password=2728 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CIDAX password=3236 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CVFNI password=9966 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CTDDS password=9298 profile=7hari
add comment="oct/12/2019 20:41:01" limit-uptime=1s mac-address=\
    08:8C:2C:02:A3:A3 name=CURSM password=9399 profile=7hari
add comment="oct/12/2019 21:56:23" limit-uptime=1s mac-address=\
    E0:99:71:C7:B6:9F name=CUKVP password=8967 profile=7hari
add comment="oct/24/2019 19:12:45" mac-address=C0:87:EB:4A:C9:1F name=CJHGS \
    password=3358 profile=7hari
add comment="oct/29/2019 16:27:15" mac-address=08:8C:2C:02:A3:A3 name=CMCXN \
    password=9632 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CVJHZ password=7984 profile=7hari
add comment="sep/27/2019 18:41:39" limit-uptime=1s mac-address=\
    E0:99:71:C7:B6:9F name=CZBJR password=4283 profile=7hari
add comment="sep/30/2019 17:43:52" limit-uptime=1s mac-address=\
    08:8C:2C:02:A3:A3 name=CXWXH password=5725 profile=7hari
add comment="oct/02/2019 18:36:39" limit-uptime=1s mac-address=\
    C0:87:EB:4A:C9:1F name=CEJKV password=9558 profile=7hari
add comment="oct/10/2019 08:51:24" limit-uptime=1s mac-address=\
    C0:87:EB:4A:C9:1F name=CSPXV password=4352 profile=7hari
add comment="oct/20/2019 11:09:21" limit-uptime=1s mac-address=\
    C0:87:EB:D5:D4:69 name=CCCYC password=7792 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CFTII password=6674 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CUCYK password=7758 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CKDHB password=9893 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CCMIY password=9693 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CKYUV password=5837 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CEEFK password=4454 profile=7hari
add comment="oct/20/2019 22:32:40" limit-uptime=1s mac-address=\
    08:8C:2C:02:A3:A3 name=CCBRS password=4857 profile=7hari
add comment="oct/26/2019 20:44:38" mac-address=E0:99:71:C7:B6:9F name=CZGRC \
    password=2988 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CNNZP password=4665 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CMSKW password=9432 profile=7hari
add comment="oct/19/2019 20:02:39" limit-uptime=1s mac-address=\
    E0:99:71:C7:B6:9F name=CSIVR password=6277 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CUJUS password=9668 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CMNCU password=9685 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CSMNR password=4794 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CBAWZ password=7889 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CIYVR password=8733 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CHXCH password=6989 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CUTMU password=6558 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CHCVT password=7986 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CWVSZ password=6279 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CBRZF password=2788 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CSGHG password=8697 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CMMPV password=6586 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CFCKS password=3922 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CSUTM password=4972 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CMFBD password=8242 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CNHGG password=4369 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CMTCT password=7246 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CCFHE password=6556 profile=7hari
add comment=up-881-09.20.19-7H20Sept19 name=CEPRJ password=7957 profile=7hari
add comment="oct/04/2019 21:34:11" limit-uptime=1s mac-address=\
    E0:99:71:C7:B6:9F name=ARIEL password=JUARA profile=7hari
add comment="oct/09/2019 20:53:37" limit-uptime=1s mac-address=\
    E0:06:E6:79:95:19 name=ABUCC password=3459 profile=1hari
add comment="oct/06/2019 19:41:56" limit-uptime=1s mac-address=\
    E0:06:E6:79:95:19 name=AWMAI password=9464 profile=1hari
add comment="oct/12/2019 14:10:03" limit-uptime=1s mac-address=\
    00:08:22:FC:7A:FC name=AVECV password=4347 profile=1hari
add comment="oct/19/2019 12:39:55" limit-uptime=1s mac-address=\
    0C:98:38:94:60:51 name=AUSCD password=9739 profile=1hari
add comment="oct/11/2019 16:19:36" limit-uptime=1s mac-address=\
    08:7F:98:B0:5B:A1 name=AJRTE password=8637 profile=1hari
add comment="oct/17/2019 07:38:16" limit-uptime=1s mac-address=\
    88:5A:06:66:12:E5 name=AMWUS password=5698 profile=1hari
add comment="oct/05/2019 22:54:43" limit-uptime=1s mac-address=\
    08:7F:98:C7:BC:29 name=AVAYH password=6439 profile=1hari
add comment="oct/06/2019 18:08:48" limit-uptime=1s mac-address=\
    08:7F:98:B0:5B:A1 name=ACZAY password=3889 profile=1hari
add comment="oct/20/2019 14:10:30" limit-uptime=1s mac-address=\
    08:7F:98:B0:5B:A1 name=ABJTE password=8745 profile=1hari
add comment="oct/10/2019 18:10:08" limit-uptime=1s mac-address=\
    68:05:71:EA:EF:29 name=ANBWW password=3673 profile=1hari
add comment="oct/09/2019 19:55:37" limit-uptime=1s mac-address=\
    7C:03:5E:C9:04:FB name=AETCT password=4562 profile=1hari
add comment="oct/13/2019 11:23:23" limit-uptime=1s mac-address=\
    68:05:71:EA:EF:29 name=AVCGN password=7878 profile=1hari
add comment="oct/17/2019 16:06:53" limit-uptime=1s mac-address=\
    68:05:71:EA:EF:29 name=ADACA password=3799 profile=1hari
add comment="oct/15/2019 06:16:48" limit-uptime=1s mac-address=\
    F0:6D:78:3F:31:24 name=AYDHY password=5686 profile=1hari
add comment="oct/11/2019 16:12:34" limit-uptime=1s mac-address=\
    F4:0E:22:03:16:0E name=AYGSA password=4442 profile=1hari
add comment="oct/12/2019 17:29:55" limit-uptime=1s mac-address=\
    08:7F:98:B0:5B:A1 name=AYDYA password=6726 profile=1hari
add comment="oct/06/2019 09:01:30" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=APNWT password=8685 profile=1hari
add comment="oct/08/2019 19:17:38" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=ATDDW password=2547 profile=1hari
add comment="oct/16/2019 13:26:39" limit-uptime=1s mac-address=\
    08:7F:98:B0:5B:A1 name=ABTPD password=8352 profile=1hari
add comment="oct/10/2019 20:33:16" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=AIBYJ password=8682 profile=1hari
add comment="oct/04/2019 07:50:37" limit-uptime=1s mac-address=\
    74:23:44:5C:38:28 name=AJXZH password=9328 profile=1hari
add comment="oct/13/2019 21:12:44" limit-uptime=1s mac-address=\
    7C:03:5E:C9:04:FB name=AXZIS password=9247 profile=1hari
add comment="oct/09/2019 20:03:45" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=APBXE password=6898 profile=1hari
add comment="oct/12/2019 13:04:22" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=AFWIS password=5386 profile=1hari
add comment="oct/10/2019 13:33:42" limit-uptime=1s mac-address=\
    C0:87:EB:5A:BC:3F name=APDKV password=5889 profile=1hari
add comment="oct/01/2019 19:45:16" limit-uptime=1s mac-address=\
    60:A4:D0:B9:1E:48 name=AJTYI password=4767 profile=1hari
add comment="oct/12/2019 18:52:32" limit-uptime=1s mac-address=\
    0C:98:38:94:60:51 name=AKFPC password=7585 profile=1hari
add comment="oct/08/2019 20:09:45" limit-uptime=1s mac-address=\
    C0:87:EB:5A:BC:3F name=AKNDV password=5749 profile=1hari
add comment="oct/11/2019 16:34:52" limit-uptime=1s mac-address=\
    0C:98:38:94:60:51 name=ADGHD password=4482 profile=1hari
add comment="sep/30/2019 09:38:07" limit-uptime=1s mac-address=\
    08:7F:98:B0:5B:A1 name=AHHXY password=2335 profile=1hari
add comment="oct/07/2019 17:13:22" limit-uptime=1s mac-address=\
    00:08:22:9A:BA:FB name=BHRXG password=8992 profile=2hari
add comment="oct/15/2019 16:17:46" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=BBGUX password=2232 profile=2hari
add comment="oct/06/2019 10:23:30" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=BHPIP password=7426 profile=2hari
add comment="oct/22/2019 20:33:57" limit-uptime=1s mac-address=\
    60:A4:D0:B9:1E:48 name=BVFIC password=5334 profile=2hari
add comment="oct/17/2019 08:36:42" limit-uptime=1s mac-address=\
    00:08:22:02:42:1D name=BGBNE password=2642 profile=2hari
add comment="oct/21/2019 23:00:34" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=BMVSR password=4445 profile=2hari
add comment="oct/16/2019 08:34:51" limit-uptime=1s mac-address=\
    60:A4:D0:B9:1E:48 name=BEEKE password=9284 profile=2hari
add comment="oct/05/2019 23:06:43" limit-uptime=1s mac-address=\
    00:08:22:3E:23:03 name=BDZSN password=7674 profile=2hari
add comment="oct/23/2019 15:05:49" mac-address=08:7F:98:C7:BC:29 name=BBXBM \
    password=4664 profile=2hari
add comment="oct/03/2019 16:00:48" limit-uptime=1s mac-address=\
    08:7F:98:C7:BC:29 name=BUTJV password=5942 profile=2hari
add comment="oct/10/2019 12:45:37" limit-uptime=1s mac-address=\
    38:A4:ED:A1:2E:37 name=BYEJD password=2364 profile=2hari
add comment="oct/21/2019 18:21:27" limit-uptime=1s mac-address=\
    00:08:22:04:48:45 name=BIBWI password=8427 profile=2hari
add comment="oct/10/2019 22:42:46" limit-uptime=1s mac-address=\
    60:A4:D0:B9:1E:48 name=BUBME password=4972 profile=2hari
add comment="oct/24/2019 20:55:25" mac-address=6C:D7:1F:23:3C:79 name=BYZAH \
    password=6833 profile=2hari
add comment="oct/17/2019 20:33:41" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=BPNFN password=2827 profile=2hari
add comment="oct/06/2019 20:26:48" limit-uptime=1s mac-address=\
    60:A4:D0:B9:1E:48 name=BKMYP password=7555 profile=2hari
add comment="oct/18/2019 09:38:16" limit-uptime=1s mac-address=\
    60:A4:D0:B9:1E:48 name=BHRUF password=4773 profile=2hari
add comment="oct/21/2019 14:01:56" limit-uptime=1s mac-address=\
    0C:98:38:94:60:51 name=BZRNE password=5386 profile=2hari
add comment="oct/09/2019 13:13:31" limit-uptime=1s mac-address=\
    34:31:11:F9:B8:12 name=BBGZG password=9766 profile=2hari
add comment="oct/13/2019 04:34:53" limit-uptime=1s mac-address=\
    60:A4:D0:B9:1E:48 name=BKIWD password=6966 profile=2hari
add comment="oct/10/2019 16:36:22" limit-uptime=1s mac-address=\
    00:08:22:9A:BA:FB name=BVNYR password=2867 profile=2hari
add comment="oct/15/2019 09:29:32" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=BXSXK password=3855 profile=2hari
add comment=up-739-09.28.19-feri2h name=BKJPI password=7997 profile=2hari
add comment="oct/20/2019 20:54:21" limit-uptime=1s mac-address=\
    60:A4:D0:B9:1E:48 name=BGPSC password=4862 profile=2hari
add comment="oct/06/2019 07:13:17" limit-uptime=1s mac-address=\
    38:A4:ED:A1:2E:37 name=BCXYK password=8356 profile=2hari
add comment="oct/15/2019 15:25:56" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=BSBDC password=8996 profile=2hari
add comment="oct/14/2019 10:41:10" limit-uptime=1s mac-address=\
    0C:98:38:94:60:51 name=BTYAW password=4723 profile=2hari
add comment="oct/08/2019 20:04:11" limit-uptime=1s mac-address=\
    60:A4:D0:B9:1E:48 name=BADIK password=8269 profile=2hari
add comment="oct/03/2019 20:19:22" limit-uptime=1s mac-address=\
    60:A4:D0:B9:1E:48 name=BHNWR password=4227 profile=2hari
add comment="oct/01/2019 18:55:45" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=BHWGD password=4443 profile=2hari
add comment=up-869-09.28.19-feri7h name=CVITV password=7326 profile=7hari
add comment=up-869-09.28.19-feri7h name=CCYDH password=7434 profile=7hari
add comment=up-869-09.28.19-feri7h name=CRRET password=4648 profile=7hari
add comment=up-869-09.28.19-feri7h name=CZGNU password=3638 profile=7hari
add comment=up-869-09.28.19-feri7h name=CAPZD password=2252 profile=7hari
add comment="oct/20/2019 05:43:49" limit-uptime=1s mac-address=\
    74:23:44:5C:38:28 name=CKIFS password=7984 profile=7hari
add comment=up-869-09.28.19-feri7h name=CAGCA password=9944 profile=7hari
add comment=up-869-09.28.19-feri7h name=CNDGA password=5757 profile=7hari
add comment=up-869-09.28.19-feri7h name=CRSPJ password=9925 profile=7hari
add comment=up-869-09.28.19-feri7h name=CESTX password=3683 profile=7hari
add comment="oct/21/2019 14:40:20" limit-uptime=1s mac-address=\
    08:7F:98:C7:BC:29 name=CWVJE password=9376 profile=7hari
add comment=up-869-09.28.19-feri7h name=CJXKE password=9736 profile=7hari
add comment=up-869-09.28.19-feri7h name=CRSPM password=2727 profile=7hari
add comment="oct/28/2019 11:28:31" mac-address=74:23:44:5C:38:28 name=CGWNY \
    password=9938 profile=7hari
add comment=up-869-09.28.19-feri7h name=CAFBG password=4447 profile=7hari
add comment=up-869-09.28.19-feri7h name=CTNZE password=9633 profile=7hari
add comment=up-869-09.28.19-feri7h name=CAMYM password=6358 profile=7hari
add comment=up-869-09.28.19-feri7h name=CTXTY password=2495 profile=7hari
add comment=up-869-09.28.19-feri7h name=CPMCE password=9458 profile=7hari
add comment="oct/13/2019 07:30:19" limit-uptime=1s mac-address=\
    08:7F:98:C7:BC:29 name=CIAWC password=3377 profile=7hari
add comment=up-869-09.28.19-feri7h name=CUFSI password=6747 profile=7hari
add comment=up-869-09.28.19-feri7h name=CPWHU password=6528 profile=7hari
add comment=up-869-09.28.19-feri7h name=CNSNA password=2397 profile=7hari
add comment=up-869-09.28.19-feri7h name=CIJCX password=9852 profile=7hari
add comment="oct/12/2019 04:03:24" limit-uptime=1s mac-address=\
    74:23:44:5C:38:28 name=CXVUC password=8256 profile=7hari
add comment=up-869-09.28.19-feri7h name=CUSGK password=5573 profile=7hari
add comment=up-869-09.28.19-feri7h name=CWSIS password=6285 profile=7hari
add comment="oct/09/2019 18:33:38" limit-uptime=1s mac-address=\
    A4:D9:90:28:BB:33 name=CURUM password=2474 profile=7hari
add comment=up-869-09.28.19-feri7h name=CIGGT password=5394 profile=7hari
add comment="oct/17/2019 06:18:01" limit-uptime=1s mac-address=\
    A4:D9:90:28:BB:33 name=CIHPB password=7564 profile=7hari
add comment="oct/03/2019 19:46:30" limit-uptime=1s mac-address=\
    6C:D7:1F:27:2E:83 name=ADCCE password=5248 profile=1hari
add comment="oct/12/2019 19:56:33" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=AXWGS password=6593 profile=1hari
add comment="oct/09/2019 19:15:39" limit-uptime=1s mac-address=\
    6C:D7:1F:27:2E:83 name=ADATN password=9664 profile=1hari
add comment="oct/12/2019 18:40:15" limit-uptime=1s mac-address=\
    C0:87:EB:EE:62:DB name=ASKCN password=6539 profile=1hari
add comment="oct/12/2019 09:27:32" limit-uptime=1s mac-address=\
    6C:D7:1F:27:38:79 name=AHVGK password=2648 profile=1hari
add comment="oct/04/2019 17:04:17" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=ATXYA password=4797 profile=1hari
add comment="oct/12/2019 16:58:09" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=ATKVZ password=2865 profile=1hari
add comment="oct/14/2019 01:26:11" limit-uptime=1s mac-address=\
    C4:0B:CB:E3:2B:3C name=AZESC password=8527 profile=1hari
add comment="oct/12/2019 20:09:37" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=AHXHC password=6542 profile=1hari
add comment="oct/11/2019 18:54:10" limit-uptime=1s mac-address=\
    38:E6:0A:82:FD:6D name=AKHJU password=2587 profile=1hari
add comment="oct/06/2019 16:56:37" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=ADFVV password=9559 profile=1hari
add comment="oct/10/2019 19:31:04" limit-uptime=1s mac-address=\
    6C:D7:1F:27:2E:83 name=ADHDA password=2897 profile=1hari
add comment="oct/13/2019 22:48:54" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=AEIFD password=9728 profile=1hari
add comment="oct/13/2019 20:29:09" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=ABDVX password=7669 profile=1hari
add comment="oct/11/2019 19:00:14" limit-uptime=1s mac-address=\
    3C:95:09:E7:6D:13 name=AMIRA password=8428 profile=1hari
add comment="oct/07/2019 19:40:45" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=AEVKH password=2763 profile=1hari
add comment="oct/08/2019 19:12:48" limit-uptime=1s mac-address=\
    6C:D7:1F:27:2E:83 name=AZFAN password=3479 profile=1hari
add comment="oct/12/2019 18:55:32" limit-uptime=1s mac-address=\
    00:0A:F5:4E:69:4C name=ANHBI password=3236 profile=1hari
add comment="oct/13/2019 13:20:28" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=ASYIR password=5772 profile=1hari
add comment="oct/11/2019 19:34:36" limit-uptime=1s mac-address=\
    08:7F:98:C6:65:AF name=ACTRA password=9832 profile=1hari
add comment="oct/07/2019 12:41:48" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=ARKSH password=4434 profile=1hari
add comment="oct/08/2019 17:47:43" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=AYXEF password=5977 profile=1hari
add comment="oct/13/2019 19:18:56" limit-uptime=1s mac-address=\
    C0:87:EB:EE:62:DB name=AUVZP password=2537 profile=1hari
add comment="oct/12/2019 19:18:35" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=AYYTB password=7564 profile=1hari
add comment="oct/11/2019 19:35:37" limit-uptime=1s mac-address=\
    6C:D7:1F:27:2E:83 name=ADBEK password=4763 profile=1hari
add comment="oct/06/2019 20:07:49" limit-uptime=1s mac-address=\
    6C:D7:1F:27:2E:83 name=ADWEM password=7392 profile=1hari
add comment="oct/08/2019 16:34:07" limit-uptime=1s mac-address=\
    60:72:8D:62:53:EB name=ATCKY password=5567 profile=1hari
add comment="oct/12/2019 19:41:59" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=APPSM password=5499 profile=1hari
add comment="oct/13/2019 01:22:38" limit-uptime=1s mac-address=\
    C4:0B:CB:E3:2B:3C name=ANARZ password=3694 profile=1hari
add comment="oct/11/2019 18:57:23" limit-uptime=1s mac-address=\
    E4:C4:83:53:D3:CB name=AFDCC password=8838 profile=1hari
add comment="oct/11/2019 19:36:06" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=BEKDE password=9807 profile=2hari
add comment="oct/10/2019 16:08:10" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=BYSQN password=1676 profile=2hari
add comment=up-744-10.05.19- name=BMWIS password=9769 profile=2hari
add comment=up-744-10.05.19- name=BQRNW password=2306 profile=2hari
add comment="oct/09/2019 19:21:51" limit-uptime=1s mac-address=\
    C0:87:EB:04:A5:2B name=BZYTF password=6005 profile=2hari
add comment="oct/12/2019 14:36:24" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=BNVLY password=7085 profile=2hari
add comment="oct/10/2019 21:52:26" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=BDNBF password=5265 profile=2hari
add comment=up-744-10.05.19- name=BUNXG password=4763 profile=2hari
add comment=up-744-10.05.19- name=BNOPF password=5298 profile=2hari
add comment="oct/09/2019 19:44:01" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=BDILI password=2089 profile=2hari
add comment="oct/11/2019 16:48:47" limit-uptime=1s mac-address=\
    00:0A:F5:C2:FC:7C name=BXOYS password=3854 profile=2hari
add comment="oct/10/2019 12:02:44" limit-uptime=1s mac-address=\
    C4:0B:CB:E3:2B:3C name=BUTMP password=5813 profile=2hari
add comment="oct/09/2019 19:21:34" limit-uptime=1s mac-address=\
    C0:87:EB:D5:D4:69 name=BTVPE password=7684 profile=2hari
add comment=up-744-10.05.19- name=BIJPP password=4686 profile=2hari
add comment="oct/12/2019 19:37:34" limit-uptime=1s mac-address=\
    C0:87:EB:04:A5:2B name=BPAAC password=5537 profile=2hari
add comment="oct/11/2019 19:46:03" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=BINHW password=5457 profile=2hari
add comment="oct/10/2019 18:10:40" limit-uptime=1s mac-address=\
    1C:87:2C:3F:F5:68 name=BPMTB password=4164 profile=2hari
add comment=up-744-10.05.19- name=BISZV password=5877 profile=2hari
add comment=up-744-10.05.19- name=BIXIL password=1314 profile=2hari
add comment="oct/12/2019 22:57:36" limit-uptime=1s mac-address=\
    C0:87:EB:D5:D4:69 name=BQPGB password=3695 profile=2hari
add comment="oct/08/2019 18:53:21" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=BFPEW password=3738 profile=2hari
add comment="oct/09/2019 14:52:45" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=BYPOA password=5662 profile=2hari
add comment="oct/13/2019 17:34:05" limit-uptime=1s mac-address=\
    00:0A:F5:C2:FC:7C name=BYFUT password=9185 profile=2hari
add comment="oct/12/2019 15:18:27" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=BPEKF password=9527 profile=2hari
add comment="oct/12/2019 14:21:43" limit-uptime=1s mac-address=\
    CC:2D:83:90:04:D7 name=BMESP password=6405 profile=2hari
add comment="oct/08/2019 12:49:21" limit-uptime=1s mac-address=\
    24:79:F3:52:26:EB name=BGWHD password=4040 profile=2hari
add comment="oct/08/2019 22:56:13" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=BXAMZ password=2149 profile=2hari
add comment="oct/09/2019 16:24:24" limit-uptime=1s mac-address=\
    00:0A:F5:C2:FC:7C name=BHFSH password=4952 profile=2hari
add comment="oct/10/2019 07:30:58" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=BMFNH password=3167 profile=2hari
add comment="oct/11/2019 14:56:13" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=BGQFE password=1012 profile=2hari
add comment="oct/14/2019 13:57:29" limit-uptime=1s mac-address=\
    6C:D7:1F:23:3C:79 name=BBBZX password=1122 profile=2hari
add comment="oct/16/2019 19:02:17" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=BCVHZ password=3448 profile=2hari
add comment="oct/19/2019 18:22:59" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=BUBBZ password=5996 profile=2hari
add comment="oct/19/2019 14:29:31" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=BCPRS password=3244 profile=2hari
add comment="oct/22/2019 16:47:06" limit-uptime=1s mac-address=\
    C0:87:EB:04:A5:2B name=BUCTW password=3722 profile=2hari
add comment="oct/21/2019 18:57:51" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=BNKCF password=3524 profile=2hari
add comment=up-402-10.12.19-2hari101219 name=BEGPP password=9299 profile=\
    2hari
add comment="oct/16/2019 20:03:10" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=BMKWR password=3466 profile=2hari
add comment="oct/18/2019 18:59:51" limit-uptime=1s mac-address=\
    00:0A:F5:C2:FC:7C name=BCNSD password=7262 profile=2hari
add comment="oct/19/2019 18:56:32" limit-uptime=1s mac-address=\
    2C:57:31:F0:77:09 name=BXLVX password=3873 profile=2hari
add comment="oct/20/2019 20:47:09" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=BMXZN password=5687 profile=2hari
add comment="oct/23/2019 11:33:53" mac-address=08:8C:2C:E5:59:4D name=BUPYY \
    password=2963 profile=2hari
add comment=up-402-10.12.19-2hari101219 name=BJHMV password=2786 profile=\
    2hari
add comment="oct/16/2019 19:43:04" limit-uptime=1s mac-address=\
    6C:D7:1F:23:3C:79 name=BCWHX password=9736 profile=2hari
add comment="oct/18/2019 18:10:40" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=BSWFX password=7568 profile=2hari
add comment="oct/20/2019 19:09:03" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=BXDYR password=8963 profile=2hari
add comment="oct/23/2019 18:22:31" mac-address=C0:87:EB:16:52:21 name=BMMEW \
    password=4825 profile=2hari
add comment="oct/20/2019 18:35:34" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=BEPUF password=7873 profile=2hari
add comment=up-402-10.12.19-2hari101219 name=BUEJR password=8834 profile=\
    2hari
add comment="oct/19/2019 09:16:54" limit-uptime=1s mac-address=\
    80:AD:16:76:6E:5E name=BYCVT password=5456 profile=2hari
add comment="oct/17/2019 18:55:38" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=BLAUF password=4426 profile=2hari
add comment="oct/20/2019 12:02:16" limit-uptime=1s mac-address=\
    CC:2D:83:90:04:D7 name=BDTBA password=4594 profile=2hari
add comment="oct/21/2019 13:31:17" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=BSYJT password=9573 profile=2hari
add comment="oct/21/2019 14:06:54" limit-uptime=1s mac-address=\
    6C:D7:1F:23:3C:79 name=BVLND password=9234 profile=2hari
add comment=up-402-10.12.19-2hari101219 name=BHYFA password=4323 profile=\
    2hari
add comment="oct/17/2019 18:07:58" limit-uptime=1s mac-address=\
    70:5E:55:A6:F8:99 name=BZFFD password=7427 profile=2hari
add comment="oct/18/2019 19:05:13" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=BMBGE password=8526 profile=2hari
add comment="oct/21/2019 23:44:29" limit-uptime=1s mac-address=\
    C4:0B:CB:E3:2B:3C name=BPDDZ password=4375 profile=2hari
add comment="oct/23/2019 10:56:30" mac-address=00:0A:F5:C2:FC:7C name=BBFNE \
    password=3483 profile=2hari
add comment="oct/22/2019 18:57:09" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=BSCGR password=2725 profile=2hari
add comment=up-402-10.12.19-2hari101219 name=BDNAA password=6843 profile=\
    2hari
add comment="oct/18/2019 19:55:47" limit-uptime=1s mac-address=\
    1C:87:2C:3F:F5:68 name=BFERD password=7739 profile=2hari
add comment="oct/17/2019 13:54:02" limit-uptime=1s mac-address=\
    CC:2D:83:90:04:D7 name=BTXUT password=9965 profile=2hari
add comment="oct/19/2019 14:31:25" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=BGJEM password=3427 profile=2hari
add comment="oct/21/2019 10:42:13" limit-uptime=1s mac-address=\
    80:AD:16:76:6E:5E name=BTJSF password=3753 profile=2hari
add comment="oct/20/2019 19:13:44" limit-uptime=1s mac-address=\
    00:0A:F5:C2:FC:7C name=BUSZT password=8668 profile=2hari
add comment=up-402-10.12.19-2hari101219 name=BEYWR password=6923 profile=\
    2hari
add comment="oct/14/2019 20:00:08" limit-uptime=1s mac-address=\
    F0:6D:78:42:12:1A name=BTAZU password=4583 profile=2hari
add comment="oct/15/2019 19:21:09" limit-uptime=1s mac-address=\
    00:0A:F5:C2:FC:7C name=BDREW password=8856 profile=2hari
add comment=up-402-10.12.19-2hari101219 name=BDMES password=8889 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BNJUY password=2364 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BBASK password=3853 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BLEPW password=3444 profile=\
    2hari
add comment="oct/14/2019 20:07:48" limit-uptime=1s mac-address=\
    CC:2D:83:90:04:D7 name=BLSHZ password=7586 profile=2hari
add comment="oct/15/2019 19:36:33" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=BVDPP password=4987 profile=2hari
add comment=up-402-10.12.19-2hari101219 name=BGKEK password=2795 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BREWE password=5325 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BPFGS password=5586 profile=\
    2hari
add comment=up-402-10.12.19-2hari101219 name=BYHHR password=6226 profile=\
    2hari
add comment="oct/14/2019 19:41:00" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=BJERU password=7852 profile=2hari
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
add comment="oct/16/2019 11:47:39" limit-uptime=1s mac-address=\
    0C:98:38:1D:99:0B name=BMMXD password=6657 profile=2hari
add comment="oct/16/2019 19:43:12" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=BUVHV password=7424 profile=2hari
add comment="oct/19/2019 01:04:35" limit-uptime=1s mac-address=\
    38:A4:ED:A1:2E:37 name=BDVCS password=8486 profile=2hari
add comment=up-402-10.12.19-2hari101219 name=BKJXL password=6363 profile=\
    2hari
add comment="oct/16/2019 00:08:01" limit-uptime=1s mac-address=\
    38:A4:ED:A1:2E:37 name=BGFMZ password=9798 profile=2hari
add comment=up-402-10.12.19-2hari101219 name=BMBSZ password=6684 profile=\
    2hari
add comment=up-880-10.12.19-1hari121019 name=ATDDB password=6852 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=AWSHJ password=6889 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=AGZEE password=3543 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=AUWMF password=3675 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=AZBAG password=4767 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=ATGNB password=4985 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=AUHUH password=2836 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=AVYKW password=2249 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=APWGH password=4622 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=AYVCP password=5938 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=ANPSH password=4959 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=AEXSH password=5653 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=ARNYG password=8324 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=ANECZ password=2892 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=AUSZE password=9223 profile=\
    1hari
add comment="oct/20/2019 15:36:36" limit-uptime=1s mac-address=\
    C0:87:EB:EE:62:DB name=AZTJS password=3895 profile=1hari
add comment=up-880-10.12.19-1hari121019 name=AABYC password=6746 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=ANLLG password=9624 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=AHSSZ password=9294 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=ADKJX password=4976 profile=\
    1hari
add comment="oct/15/2019 20:19:31" limit-uptime=1s mac-address=\
    6C:D7:1F:27:2E:83 name=AUMGV password=8226 profile=1hari
add comment="oct/20/2019 10:57:27" limit-uptime=1s mac-address=\
    DC:85:DE:38:D3:57 name=AXPDL password=3374 profile=1hari
add comment=up-880-10.12.19-1hari121019 name=AGNUP password=4944 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=ATAVZ password=7296 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=AXVBJ password=4526 profile=\
    1hari
add comment="oct/14/2019 20:16:34" limit-uptime=1s mac-address=\
    6C:D7:1F:27:2E:83 name=ARRGM password=8763 profile=1hari
add comment="oct/16/2019 18:48:08" limit-uptime=1s mac-address=\
    08:8C:2C:E5:59:4D name=APGEC password=2623 profile=1hari
add comment=up-880-10.12.19-1hari121019 name=ARLPZ password=6954 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=AKZEV password=4654 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=ATMTK password=8289 profile=\
    1hari
add comment="oct/13/2019 17:43:39" limit-uptime=1s mac-address=\
    60:72:8D:62:53:EB name=AHXAM password=2339 profile=1hari
add comment="oct/13/2019 18:42:17" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=AYVUV password=8852 profile=1hari
add comment="oct/14/2019 19:40:52" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=AGASC password=6642 profile=1hari
add comment="oct/13/2019 19:21:43" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=AEGPE password=4456 profile=1hari
add comment=up-880-10.12.19-1hari121019 name=AJJEU password=6776 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=APZGN password=4587 profile=\
    1hari
add comment="oct/17/2019 17:19:11" limit-uptime=1s mac-address=\
    C0:87:EB:EE:62:DB name=ANYNH password=4556 profile=1hari
add comment=up-880-10.12.19-1hari121019 name=ABYVW password=2553 profile=\
    1hari
add comment="oct/23/2019 08:15:50" limit-uptime=1s mac-address=\
    24:79:F3:6F:AA:6D name=AWTUX password=5262 profile=1hari
add comment="oct/20/2019 18:04:15" limit-uptime=1s mac-address=\
    60:72:8D:62:53:EB name=ARBED password=4252 profile=1hari
add comment="oct/20/2019 21:21:23" limit-uptime=1s mac-address=\
    6C:D7:1F:27:2E:83 name=AETVJ password=4429 profile=1hari
add comment=up-880-10.12.19-1hari121019 name=AGKKJ password=3586 profile=\
    1hari
add comment="oct/17/2019 21:53:50" limit-uptime=1s mac-address=\
    6C:D7:1F:23:3C:79 name=ARYTX password=7385 profile=1hari
add comment=up-880-10.12.19-1hari121019 name=AAALR password=7565 profile=\
    1hari
add comment="oct/21/2019 20:31:50" limit-uptime=1s mac-address=\
    1C:77:F6:E0:DE:02 name=AEJLH password=7994 profile=1hari
add comment="oct/14/2019 09:43:37" limit-uptime=1s mac-address=\
    B0:E2:35:DC:34:67 name=AXVJV password=7468 profile=1hari
add comment=up-880-10.12.19-1hari121019 name=AWBAU password=4457 profile=\
    1hari
add comment="oct/17/2019 18:05:10" limit-uptime=1s mac-address=\
    2C:56:DC:E7:15:E1 name=AWWCZ password=5827 profile=1hari
add comment=up-880-10.12.19-1hari121019 name=APYLD password=6535 profile=\
    1hari
add comment="oct/22/2019 11:41:23" limit-uptime=1s mac-address=\
    80:AD:16:76:6E:5E name=AWBTC password=7289 profile=1hari
add comment="oct/14/2019 14:19:25" limit-uptime=1s mac-address=\
    78:36:CC:C6:A4:65 name=AKATM password=4458 profile=1hari
add comment=up-880-10.12.19-1hari121019 name=AZNDE password=5987 profile=\
    1hari
add comment="oct/17/2019 13:18:26" limit-uptime=1s mac-address=\
    6C:D7:1F:27:2E:83 name=AJJVW password=7896 profile=1hari
add comment=up-880-10.12.19-1hari121019 name=AFFLF password=9749 profile=\
    1hari
add comment="oct/22/2019 18:04:02" limit-uptime=1s mac-address=\
    3C:95:09:E7:6D:13 name=AJXUD password=7388 profile=1hari
add comment="oct/13/2019 20:07:59" limit-uptime=1s mac-address=\
    6C:D7:1F:27:2E:83 name=ANCPG password=9227 profile=1hari
add comment=up-880-10.12.19-1hari121019 name=AMSPK password=4395 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=AYFNG password=6338 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=ASRES password=5857 profile=\
    1hari
add comment=up-880-10.12.19-1hari121019 name=ALPJG password=8976 profile=\
    1hari
add comment=feri mac-address=F0:6D:78:3F:31:24 name=F0:6D:78:3F:31:24 \
    password=F0:6D:78:3F:31:24 profile=BINDING
add comment=FAIZIN name=28:31:66:8E:C6:03 password=28:31:66:8E:C6:03 profile=\
    BINDING
add comment="oct/20/2019 16:28:14" limit-uptime=1s mac-address=\
    20:5E:F7:30:5E:78 name=APPUW password=3769 profile=1hari
add comment="oct/24/2019 06:43:26" mac-address=0C:98:38:94:60:51 name=AXFXK \
    password=9286 profile=1hari
add comment=up-347-10.20.19-1hariferi20ct name=AIAYR password=3986 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=APGRM password=6293 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=AFVTV password=7572 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=ADGYF password=5622 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=AZNBR password=6478 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=ANGWT password=7542 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=ANGBF password=8777 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=AUFIX password=4875 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=AYZPM password=4689 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=AWDMV password=4729 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=AERUN password=3924 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=AUBEJ password=7277 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=AGFMG password=5759 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=ANYMU password=4847 profile=\
    1hari
add comment="oct/23/2019 21:12:48" mac-address=60:A4:D0:B9:1E:48 name=AFWWT \
    password=2287 profile=1hari
add comment=up-347-10.20.19-1hariferi20ct name=ADUIW password=4298 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=AAJVX password=9857 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=APNWR password=7883 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=ARYHU password=4992 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=AXHYC password=5278 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=ACKKI password=9775 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=AABPH password=5777 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=AJYDT password=8863 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=AAUWG password=8887 profile=\
    1hari
add comment="oct/22/2019 21:27:45" limit-uptime=1s mac-address=\
    0C:A8:A7:D5:69:D4 name=APIKU password=3552 profile=1hari
add comment=up-347-10.20.19-1hariferi20ct name=AWKTY password=6522 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=APUIN password=8653 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=ANCDG password=6545 profile=\
    1hari
add comment=up-347-10.20.19-1hariferi20ct name=AJDWA password=8256 profile=\
    1hari
add comment="oct/22/2019 19:44:23" limit-uptime=1s mac-address=\
    00:0A:00:D5:C3:D8 name=BTEJA password=2732 profile=2hari
add comment=up-138-10.20.19-2hari20Oct name=BMYEC password=2735 profile=2hari
add comment=up-138-10.20.19-2hari20Oct name=BGWEV password=2337 profile=2hari
add comment=up-138-10.20.19-2hari20Oct name=BVRDV password=6996 profile=2hari
add comment=up-138-10.20.19-2hari20Oct name=BWBUX password=6742 profile=2hari
add comment="oct/22/2019 20:08:11" limit-uptime=1s mac-address=\
    F4:60:E2:30:CF:98 name=BCYUW password=6497 profile=2hari
add comment=up-138-10.20.19-2hari20Oct name=BIXZH password=5573 profile=2hari
add comment=up-138-10.20.19-2hari20Oct name=BIVDE password=9736 profile=2hari
add comment=up-138-10.20.19-2hari20Oct name=BWHZD password=9334 profile=2hari
add comment=up-138-10.20.19-2hari20Oct name=BPFEX password=9464 profile=2hari
add comment="oct/22/2019 20:57:18" limit-uptime=1s mac-address=\
    08:EE:8B:F5:DA:26 name=BGHRG password=8923 profile=2hari
add comment=up-138-10.20.19-2hari20Oct name=BUHAZ password=4948 profile=2hari
add comment="oct/24/2019 20:19:12" mac-address=0C:98:38:1D:99:0B name=BTYBU \
    password=3929 profile=2hari
add comment="oct/24/2019 18:54:34" mac-address=C0:87:EB:04:A5:2B name=BYZNI \
    password=2734 profile=2hari
add comment="oct/24/2019 13:01:46" mac-address=80:AD:16:76:6E:5E name=BCDEP \
    password=9946 profile=2hari
add comment="oct/23/2019 19:38:29" mac-address=F0:6D:78:42:12:1A name=BBFUC \
    password=5646 profile=2hari
add comment=up-138-10.20.19-2hari20Oct name=BMYAT password=3282 profile=2hari
add comment=up-138-10.20.19-2hari20Oct name=BDBTE password=3567 profile=2hari
add comment=up-138-10.20.19-2hari20Oct name=BVHPF password=2454 profile=2hari
add comment=up-138-10.20.19-2hari20Oct name=BFMIR password=5526 profile=2hari
add comment="oct/24/2019 09:08:33" mac-address=2C:56:DC:E7:15:E1 name=BCHWC \
    password=3745 profile=2hari
add comment=up-138-10.20.19-2hari20Oct name=BFNUJ password=3685 profile=2hari
add comment=up-138-10.20.19-2hari20Oct name=BIXWG password=9255 profile=2hari
add comment=up-138-10.20.19-2hari20Oct name=BFDXN password=4882 profile=2hari
add comment=up-138-10.20.19-2hari20Oct name=BRBPW password=2683 profile=2hari
add comment="oct/24/2019 19:48:29" mac-address=00:0A:00:D5:C3:D8 name=BFITZ \
    password=9226 profile=2hari
add comment=up-138-10.20.19-2hari20Oct name=BWVAT password=7348 profile=2hari
add comment=up-138-10.20.19-2hari20Oct name=BDEFV password=2559 profile=2hari
add comment=up-138-10.20.19-2hari20Oct name=BAEDY password=8824 profile=2hari
add comment=up-138-10.20.19-2hari20Oct name=BBPMY password=7922 profile=2hari
/ip hotspot walled-garden
add comment="place hotspot rules here" disabled=yes
add dst-host=laksa19.github.io
add dst-host=\
    "play.google.com/store/apps/details\?id=hijrahpay.larakostpulsa.com"
add dst-host=*.intergram.*
/ip route
add comment="PPPoE MAIL" distance=1 dst-address=172.16.0.0/24 gateway=\
    192.168.10.3
/ip service
set telnet disabled=yes
set ssh disabled=yes
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
add comment="Monitor Profile 7hari" interval=2m33s name=7hari on-event=":local\
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
    start-date=may/03/2019 start-time=01:23:26
add comment="Monitor Profile 2hari" interval=2m16s name=2hari on-event=":local\
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
    start-date=aug/06/2019 start-time=04:58:32
add comment="Monitor Profile 1hari" interval=2m45s name=1hari on-event=":local\
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
    start-date=aug/06/2019 start-time=05:53:52
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
add name="deluser-startup hotspot" on-event=\
    "/queue simple remove [find where comment=\"user_hotspot\"]" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-time=startup
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
add comment=-|-Jul-|-,-|-Aug-|- name=RekapPendapatan owner=nrdnisml policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    0,805000
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
/tool e-mail
set address=smtp.gmail.com from=<melatispot> password=f4c3b00k port=578 \
    start-tls=yes user=nurudinismail69@gmail.com
/tool netwatch
add comment=MikroTik_Rumah-|-telegram down-script="[/tool fetch url=\"https://\
    api.telegram.org/bot926416519:AAF6MUIEMq2PLcz5AP_pag1xMqAcjLMV2Pc/sendmess\
    age\?chat_id=-612177944& text============================%0A%10%10%10%10%1\
    0%10%10*Mikhmon%10Netwatch%10Monitor*%0A===========================%0AName\
    \_: MikroTik_Rumah%0AStatus : Down&parse_mode=markdown\" keep-result=no]" \
    host=192.168.12.1 timeout=10s up-script="[/tool fetch url=\"https://api.te\
    legram.org/bot926416519:AAF6MUIEMq2PLcz5AP_pag1xMqAcjLMV2Pc/sendmessage\?c\
    hat_id=-612177944&text============================%0A%10%10%10%10%10%10%10\
    *Mikhmon%10Netwatch%10Monitor*%0A===========================%0AName : Mikr\
    oTik_Rumah%0AStatus : Normal&parse_mode=markdown\" keep-result=no]"

# jan/18/2020 13:20:04 by RouterOS 6.42.9
# software id = 4RT7-XCC3
#
# model = RouterBOARD 750G r3
# serial number = 6F38083515DD
/ip firewall layer7-protocol
add name=speedtest regexp="^.+(speedtest).*\\\$"
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

# jan/18/2020 13:20:27 by RouterOS 6.42.9
# software id = 4RT7-XCC3
#
# model = RouterBOARD 750G r3
# serial number = 6F38083515DD
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

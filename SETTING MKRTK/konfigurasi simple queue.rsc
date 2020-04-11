# jan/18/2020 13:32:13 by RouterOS 6.42.9
# software id = 4RT7-XCC3
#
# model = RouterBOARD 750G r3
# serial number = 6F38083515DD
/queue simple
add max-limit=2M/3M name="1. PORT GAME DOWN" packet-marks=\
    "PORT GAME DOWNLOAD,PORT GAME UPLOAD" priority=1/1 
add max-limit=20M/20M name="2. ICMP DOWN" packet-marks=\
    "ICMP DOWNLOAD,ICMP UPLOAD" priority=1/1 queue=default/default 
add max-limit=5M/25M name=ALLTRAFFIC packet-marks="SOSMED DOWNLOAD,SOSMED UPLO\
    AD,YOUTUBE DOWNLOAD,YOUTUBE UPLOAD,PORT BERAT DOWNLOAD,PORT BERAT UPLOAD,G\
    LOBAL DOWNLOAD,GLOBAL UPLOAD" priority=3/3 
    
add max-limit=2M/20M name="3.1 HOTSPOT" parent=ALLTRAFFIC priority=5/5 queue=\
    default/default 
add max-limit=2M/9M name="3.2 HOME" parent=ALLTRAFFIC 
   
   

																																																																									<?php
$bg = "#FFA07A";
if($validity=="1d"){$bg="#FF0000";}
elseif($validity=="2d"){$bg="#9867ff";}
elseif($validity=="7d"){$bg="#ADFF2F";}
?>


<!-- MULAI -->
<style>
.qrcode{
		height:60px;
		width:60px;
}
</style> 
<div style="overflow:hidden;position:relative;padding: 0px;margin: 2px;border: 1px solid #000;width:180px;height:115px;float:left;-webkit-print-color-adjust: exact;">

<!-- NUM -->
<div style="position:absolute;width:auto;top:10px;right:80px;color:#333;font-size:10px;padding:0px;"><small><?php echo " [$num]";?></small></div>
<!-- NUM -->

<!-- PRICE -->
<div style="position:absolute;margin-top:1px;background:<?php echo $bg ?>;width:auto;color:#fff;font-weight:bold;font-family:Agency FB;font-size:24px;padding:2.5px 25px 2.5px 20px;border-radius:0 0 50px 0;"><small style="font-size:14px;margin-left:-15px;position:absolute;">Rp.</small><?php echo $getprice;?></div>
<!-- PRICE -->
<!-- AKUN -->
<div style="position:absolute;top:50px;right:0px;display:inline;color:#000;text-align:right;">
<?php if($usermode == "vc"){?>
<!-- Voucher : Username = Password  -->
<div style="padding:0px;text-align:right;font-weight:bold;font-size:11px;font-family:Courier New;width:90px;background:#333;color:#fff;padding:2.5px 5px;margin-bottom:2.5px;">VOUCHER</div>
<div style="padding:0px 5px 0px 0px;border-top:1px solid #fff;border-bottom:1px solid #fff;text-align:right;font-weight:bold;font-size:14px;font-family:Courier New;"><?php echo $username;?></div>
<?php }elseif($usermode == "up"){?>
<!-- Voucher : Username & Password  -->
<div style="padding:0px;text-align:right;font-weight:bold;font-size:11px;font-family:Courier New;width:90px;background:#333;color:#fff;padding:2.5px 5px;position:absolute;right:0;top:-17px;">KODE VOUCHER</div>
<div style="padding:00px 5px 0px 0px;border-top:1px solid #fff;border-bottom:1px solid #fff;text-align:right;font-weight:bold;font-size:14px;font-family:Courier New;"><small style="font-size:10px;">Username: </small><?php echo $username;?></div>
<div style="padding:0px 5px 0px 0px;border-bottom:1px solid #fff;text-align:right;font-weight:bold;font-size:14px;font-family:Courier New;"><small style="font-size:10px;">Password: </small><?php echo $password;?></div>
<?php }?>
</div>
<!-- AKUN -->
<!-- AKTIF & LIMIT -->
<div style="position:absolute;top:10px;right:0px;display:inline;color:#fff;text-align:right;">
<div style="padding:0 2.5px;text-align:right;font-size:9px;font-weight:bold;color:#333333;">
<?php if($validity == "1d"){?>Aktif 1 Hari
<?php }elseif($validity == "2d"){?>Aktif 2 Hari
<?php }elseif($validity == "3d"){?>Aktif 3 Hari
<?php }elseif($validity == "4d"){?>Aktif 4 Hari
<?php }elseif($validity == "5d"){?>Aktif 5 Hari
<?php }elseif($validity == "6d"){?>Aktif 6 Hari
<?php }elseif($validity == "7d"){?>Aktif 1 Minggu
<?php }elseif($validity == "14d"){?>Aktif 2 Minggu
<?php }elseif($validity == "30d"){?>Aktif 1 Bulan
<?php }elseif($validity == "1h"){?>Aktif 1 Jam
<?php }elseif($validity == "5h"){?>Aktif 5 Jam
<?php }else{?>Aktif <span style="text-transform: uppercase;"><?php echo $validity ?></span>
<?php }?>
</div>
<div style="padding:0 2.5px;text-align:right;font-size:10px;font-weight:bold;color:#fff;"><?php if(empty($datalimit)){;?>Unlimted <?php }else{ echo $datalimit;}?></div>
</div>
<!-- AKTIF & LIMIT -->
<!-- QRCODE-->
<?php if($qr == "yes"){?>
<div style="position:absolute;bottom:10px;left:3px;display:inline;width:50px;"><?php echo $qrcode ?></div>
<?php }?>
<!-- QRCODE-->

<!-- LOGIN-->
<div style="position:absolute;bottom:2px;right:5px;display:inline;color:#fff;font-size:9px;font-weight:bold;margin:0 -2.5px;padding:2.5px;width:60%;text-align:right;">
Login pada browser : <div style="color:#000"><?=$dnsname;?></div>
</div>
<!-- LOGIN-->
<!-- BG-->
<div style="overflow: hidden;padding: 0px;float:left;">
<div style="margin-top:-100px;width: 0; height: 0; border-top: 230px solid transparent;border-left: 50px solid transparent;border-right:140px solid <?php echo$bg ?>; "></div>
</div>
<!-- BG-->
</div>
<!-- AKHIR -->	        	        	        	        	        	        	        	        	        	        	        	        
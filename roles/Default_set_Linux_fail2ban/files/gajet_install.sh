#!/bin/sh



function arp_st() {
clear
echo "####### 1. ARP Static ######"
arp 
echo "input Gateway IP"
read ip
echo "input Gateway MAC"
read mac
echo "## 10 seconds Apply / Cancel  ctrl + c Press Enter##"
echo "arp -s $ip $mac"
sleep 10
arp -s $ip $mac
arp
echo "arp -s $ip $mac" >> /etc/rc.local
sleep 3
}


function bb() {
clear
echo "####### 2. BB Client Install  ######"
cd /home/gabia/
yum -y install ld-linux.so.2
wget -P /home/gabia/ http://staffs2.tt.co.kr/~kyk/tool/bb_client_b.tar
tar xvfz bb_client_b.tar
mv bb /home/
adduser -d /home/bb/ bb
chown -R bb.bb /home/bb
chmod 644 /var/log/messages
chmod 755 /var/spool/mqueue
echo "BB2 -> 211.115.83.232"
echo "BB3 -> 121.78.114.251"
echo "BB4 -> 110.45.183.14"
echo "BB5 -> 121.125.65.197"
echo " "
echo "input BB Server IP"
read bb_server
echo "input BB Client IP"
read ipadd
echo "input BB Host Name"
read host
echo "$bb_server $bb_server # BBPAGER BBNET BBDISPLAY" >  /home/bb/bb17b4/etc/bb-hosts
echo "$ipadd $host" >> /home/bb/bb17b4/etc/bb-hosts
echo "$host" > /home/bb/bb17b4/etc/bbaliasname
su - bb -c "/home/bb/bb17b4/runbb.sh stop"
su - bb -c "/home/bb/bb17b4/runbb.sh start"
echo "su -l bb -c '/home/bb/bb17b4/runbb.sh'" >> /etc/rc.local
sleep 3
}

function gajet() {
clear
echo "####### 5 gajet agent install ######"
cd /home/gabia/
wget -P /home/gabia/ http://staffs2.tt.co.kr/~kyk/tool/back-src.tar.gz
tar xvfz back-src.tar.gz
./install.sh

sleep 3
}

function fail2ban() {
clear
echo "####### 6 Fail2ban install ######"
VER=0.8.14
DIR=/home/gabia/fail2ban
if [ ! -d $DIR ]; then
        mkdir -p $DIR
fi
cd $DIR
wget -P /home/gabia/fail2ban http://staffs2.tt.co.kr/~kyk/tool/fail2ban-0.8.14.tar.gz
wget -P /home/gabia/fail2ban http://staffs2.tt.co.kr/~kyk/tool/gabia_default_jail.conf
if [ -f $VER ]; then
        mv $VER fail2ban-$VER.tar.gz
elif [ -f $VER.tar.gz ]; then
        mv $VER.tar.gz fail2ban-$VER.tar.gz
fi
tar xvfz fail2ban-$VER.tar.gz -C /home/gabia/fail2ban
cd /home/gabia/fail2ban/fail2ban-$VER

python setup.py install

cp -f /home/gabia/fail2ban/fail2ban-$VER/files/redhat-initd /etc/init.d/fail2ban
chmod 700 /etc/init.d/fail2ban
chkconfig --add fail2ban
cp -f /home/gabia/fail2ban/gabia_default_jail.conf /etc/fail2ban/jail.conf
echo "setup complete!"
echo "service fail2ban start!!"
/etc/rc.d/init.d/fail2ban start

sleep 3
}

function zabbix() {
clear
echo "####### 7 Zabbix install ######"


cd /home/gabia
wget http://staffs2.tt.co.kr/~kyk/tool/gajet_check_lastest.tar.gz -O /home/gabia/gajet_check_lastest.tar.gz
tar zxvf ./gajet_check_lastest.tar.gz
[ -f "./gajet_check_lastest.tar.gz" ] && rm -f ./gajet_check_lastest.tar.gz

curl hhttp://staffs2.tt.co.kr/~kyk/tool/gajet_zabbix_install.sh | sh

/etc/init.d/zabbix_agentd start
}

function user_del {
clear
echo "####### 21. delete account   #######"
echo " "
echo "삭제할 계정명"
read account
comparison=`cat /etc/passwd | awk -F: '{print $1}' | grep $account`
if [ "$comparison"  !=  "$account" ]; then
echo "account does not exist"
else
echo "Delete Account Start....."
sleep 1
echo "/etc/sudoers -> Delete....."
sed -i '/'$account'/d' /etc/sudoers
sleep 1
echo "/etc/passwd -> Delete....."
sleep 1
sed -i '/'$account'/d' /etc/passwd
echo "/etc/shadow -> Delete....."
sleep 1
sed -i '/'$account'/d' /etc/shadow
echo "/etc/group -> 삭제중....."
sleep 1
sed -i '/'$account'/d' /etc/group
echo "Home directory delete....."
sleep 1
rm -rf /home/gabia
echo "Complete delete account....."
fi
sleep 3
}


function arp_st_del {
clear
echo "####### 22. ARP Static Release #######"
echo " "
arp
echo "input Relase Gateway IP"
read gw_ip
echo "10 seconds Apply"
echo "arp -d $gw_ip"
sleep 10
arp -d $gw_ip
sleep 1
sed -i '/'arp'/d' /etc/rc.local
echo "ARP Static Relase Complete"
arp
sleep 3
}

function bb_del {
clear
echo "####### 23. BB Client Delete #######"
echo " "
echo "BB Client Stopping..."
su - bb -c "/home/bb/bb17b4/runbb.sh stop"
pkill runbb
sleep 1
echo "BB account or Home Directory Delete...."
userdel -r bb
sed -i '/'runbb'/d' /etc/rc.local
echo "BB Client Delete Complete....."
sleep 3
}

function gajet_del {
clear
echo "####### 24. gajet agent delete #######"
echo " "
echo "Crond setting  delete...."
sed -i '/'consignClient'/d' /etc/crontab
sleep 1
echo "gajet agent delete Complete"
sleep 3
}

function fail2ban_del {
clear
echo "####### 25. Fail2ban Delete #######"
echo " "
sleep 1
echo "fail2ban Stoping....."
/etc/rc.d/init.d/fail2ban stop
pkill fail2ban
sleep 1
echo "fail2ban Delete....."
rm -rf /etc/fail2ban
rm -rf /usr/bin/fail2ban-client
rm -rf /var/run/fail2ban
rm -f /etc/rc.d/init.d/fail2ban 
sleep 1
echo "fail2ban Delete Complete....."
sleep 3
}

function zabbix_del {
clear
echo "####### 26. Zabbix Client Delete"
echo " "
sleep 1
echo "zabbix Sroping....."
/etc/rc.d/init.d/zabbix_agentd stop
pkill zabbix
sleep 1
echo "zabbix Delete....."
rm -rf /home/gabia/zabbix
rm -f /etc/rc.d/init.d/zabbix_agentd
sleep 1
echo "zabbix Delete Complete....."
sleep 3
}

function info {
clear
echo "####### 8. login info check "
echo " "
sleep 1
wget -P /home/gabia/ http://staffs2.tt.co.kr/~kyk/tool/info.sh
chmod 755 /home/gabia/info.sh

echo "/home/gabia/info.sh" >> /root/.bash_profile

}

function info_del {
clear
echo "####### 27. login info check del"
echo " "
sleep 1
sed -i '/'info.sh'/d' /root/.bash_profile


}

function iptables_off {
clear
echo "####### 9. iptables disable"
echo " "
sleep 1

cent=`find /etc/init.d/ -name 'iptables' | wc -l`

if [ "$cent" -eq "1" ]; then
  /etc/rc.d/init.d/iptables stop
  chkconfig --level 3 iptables off
  echo "cent(5.x or 6.x) iptables off...."

else
  systemctl stop firewalld
  systemctl disable firewalld
  echo "cent7.x iptables off...."

fi


}

function hpacucli {
clear
echo "####### 11. hpacucli install"
echo " "
sleep 1
wget http://staffs2.tt.co.kr/~kyk/tool/hpacucli-9.40-12.0.x86_64.rpm
echo " hpacucli download....ok "
sleep 1
rpm -Uvh hpacucli-9.40-12.0.x86_64.rpm
sleep 1
echo " hpacucli install.....ok"
}

function hpssacli {
clear
echo "####### 11. hpacucli install"
echo " "
sleep 1
wget http://staffs2.tt.co.kr/~kyk/gen9_hpssacli-2.30-6.0.x86_64.rpm
echo " hpassacli download....ok "
sleep 1
rpm -Uvh gen9_hpssacli-2.30-6.0.x86_64.rpm
sleep 1
echo " hpassacli install.....ok"
}


function megacli {
clear
echo "####### 12. megacli install"
echo " "
sleep 1
wget http://staffs2.tt.co.kr/~kyk/tool/Lib_Utils-1.00-09.noarch.rpm
wget http://staffs2.tt.co.kr/~kyk/tool/MegaCli-8.04.10-1.noarch.rpm
echo " megacli download....ok "
sleep 1
rpm -Uvh Lib_Utils-1.00-09.noarch.rpm
sleep 1
rpm -Uvh MegaCli-8.04.10-1.noarch.rpm
sleep 1
echo " megacli install.....ok"
}

echo "Selected works"
echo "==================================="
echo "Gajet Setting Menu"
echo "==================================="
echo "1. ARP Static"
echo "2. BB Client settings"
echo "3. server setting ( Gajet, Fail2ban, Zabbix, info, iptables )"
echo "4. cloud setting ( Fail2ban, Zabbix, info )"
echo " "
echo "5. Gajet Agent"
echo "6. Fail2ban"
echo "7. Zabbix settings"
echo "8. info settings"
echo "9. iptables off"
echo " "
echo "==================================="
echo "ETC Setting Menu"
echo "==================================="
echo "11. hpacucli install"
echo "12. hpssacli install"
echo "13. Megacli install"
echo " "
echo "==================================="
echo "Gajet Termination Menu"
echo "==================================="
echo "21. Delete account"
echo "22. ARP Static Release"
echo "23. BB Client Delete"
echo "24. Gajet Agent Delete"
echo "25. Fail2ban Delete"
echo "26. Zabbix Client Delete"
echo "27. info_del"
echo "28. Delete ALL"
echo " "
echo "input Number"
read job

case $job in
1)
arp_st ;;
2)
bb ;;
3)
gajet
fail2ban
#zabbix
info
iptables_off
;;
4)
fail2ban
#zabbix
info
;;
5)
gajet ;;
6)
fail2ban
;;
7)
#zabbix
;;
8)
info
;;
9)
iptables_off
;;
11)
hpacucli
;;
12)
hpssacli
;;
13)
megacli
;;
21)
user_del
;;
22)
arp_st_del
;;
23)
bb_del
;;
24)
gajet_del
;;
25)
fail2ban_del
;;
26)
zabbix_del
;;
27)
info_del
;;
28)
user_del
arp_st_del
bb_del
gajet_del
fail2ban_del
zabbix_del
info_del
;;
esac



#!/bin/bash
if [ $# -ne 5 ]
then
     echo " Usage Error: \
     remote-vnf-setup.sh  PaloAlto_FIP admin new_passwd private_alb_hostname auth-code";
     printf  "\nInvalid number of arguments, please check the inputs and try again\n"
     exit;
fi;


rm ~/.ssh/known_hosts*
expect << EOF
set timeout 3
spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null admin@$1
expect "* Password:#" 
send "admin\r"
expect "Enter old password :#"
send "admin\r"
expect "Enter new password :#"
send "$3\r"
expect "Confirm password   :#"
send "$3\r"
expect "admin@PA-VM>#"
send "configure\r"
expect "admin@PA-VM>#"
send "\r"
expect "admin@PA-VM>#"
send "set deviceconfig system dns-setting servers primary 8.8.8.8 secondary 127.0.0.53\r"
expect "admin@PA-VM>#"
send "set network profiles interface-management-profile man ssh yes\r"
expect "admin@PA-VM>#"
send "set network profiles interface-management-profile man http yes\r"
expect "admin@PA-VM>#"
send " set network interface ethernet ethernet1/1 layer3 interface-management-profile man\r"
expect "admin@PA-VM>#"
send " set network interface ethernet ethernet1/2 layer3 interface-management-profile man\r"
expect "admin@PA-VM>#"
send " set network interface ethernet ethernet1/3 layer3 interface-management-profile man\r"
expect "admin@PA-VM>#"
send "set network interface ethernet ethernet1/1 layer3\r"
expect "admin@PA-VM>#"
send "set network interface ethernet ethernet1/2 layer3\r"
expect "admin@PA-VM>#"
send "set network interface ethernet ethernet1/3 layer3\r"
expect "admin@PA-VM>#"
send "set zone untrusted network layer3 ethernet1/1\r"
expect "admin@PA-VM>#"
send "set zone trusted network layer3 ethernet1/2\r"
expect "admin@PA-VM>#"
send "set zone trusted network layer3 ethernet1/3\r"
expect "admin@PA-VM>#"
send "set network interface ethernet ethernet1/1 layer3 dhcp-client create-default-route no enable yes\r"
expect "admin@PA-VM>#"
send "set network interface ethernet ethernet1/2 layer3 dhcp-client create-default-route no enable yes\r"
expect "admin@PA-VM>#"
send "set network interface ethernet ethernet1/3 layer3 dhcp-client create-default-route no enable yes\r"
expect "admin@PA-VM>#"
send "set network virtual-router VR interface ethernet1/1 \r"
expect "admin@PA-VM>#"
send "set network virtual-router VR interface ethernet1/2 \r"
expect "admin@PA-VM>#"
send "set network virtual-router VR interface ethernet1/3 \r"
expect "admin@PA-VM>#"
send "set address iks-alb fqdn $4 \r"
expect "admin@PA-VM>#"
send "set rulebase nat rules StaticNAT description staticNAT from untrusted to untrusted service any source any destination any source-translation dynamic-ip-and-port interface-address interface ethernet1/3 \r"
expect "admin@PA-VM>#"
send "set rulebase nat rules StaticNAT description staticNAT from untrusted to untrusted service any source any dynamic-destination-translation translated-address iks-alb distribution round-robin \r"
expect "admin@PA-VM>#"
send "set rulebase security rules allow-all description allow-all from any to any service any source any destination any application any action allow \r"
expect "admin@PA-VM>#"
send "commit\r"
set timeout 60
expect "admin@PA-VM>#"
set timeout 3
send "exit\r"
expect "admin@PA-VM>#"
send "request license fetch auth-code $5\r"
set timeout 120
expect "admin@PA-VM>#"
set timeout 3
send "reboot\r"
expect "admin@PA-VM>#"
send "exit\r"
EOF

#########################################################################
#                                                                       #
#       Name of Script: netplan-easy                                    #
#       Description: no comment                                         #
#       Author: Jose Manuel Afonso Santana                              #
#       Alias: joseafon                                                 #
#       Email: jmasantana@linuxmail.org                                 #
#                                                                       #
#########################################################################

#!/bin/sh

    clear

    # CONS
    NICKNAME=$(ip address show | grep -w 2 | awk '{print $2}')

    if [ $USER != 'root' ]
    then
        echo "\e[31mYou need privileges of administrator\e[0m"
        echo

        exit 1
    fi 

    which apt > /dev/null 2>&1

    if [ $? -ne 0 ]
    then
        echo "\e[31mYour operating system is not compatible with this script\e[0m"
        echo

        exit 2
    fi

    if [ ! -d /etc/netplan/original ]
    then
        mkdir -p /etc/netplan/original
        mv /etc/netplan/*.yaml /etc/netplan/original || mv /etc/netplan/*.yml /etc/netplan/original
    fi
    
    echo "\e[92m
███╗   ██╗███████╗████████╗██████╗ ██╗      █████╗ ███╗   ██╗
████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██╔══██╗████╗  ██║
██╔██╗ ██║█████╗     ██║   ██████╔╝██║     ███████║██╔██╗ ██║
██║╚██╗██║██╔══╝     ██║   ██╔═══╝ ██║     ██╔══██║██║╚██╗██║
██║ ╚████║███████╗   ██║   ██║     ███████╗██║  ██║██║ ╚████║
╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝
    ███████╗ █████╗ ███████╗██╗   ██╗                        
    ██╔════╝██╔══██╗██╔════╝╚██╗ ██╔╝                        
    █████╗  ███████║███████╗ ╚████╔╝                         
    ██╔══╝  ██╔══██║╚════██║  ╚██╔╝                          
    ███████╗██║  ██║███████║   ██║                           
    ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝                           
\e[0m"
    echo "\e[96m
+---------------------------------+
|         Input IP address        |    
+---------------------------------+
\e[0m"
    echo
    
    read IP

    echo "\e[96m
+---------------------------------+
|        Input CIDR prefix        |    
+---------------------------------+
\e[0m"
    echo
    echo "\e[92mExamples\e[0m"
    echo "--------------------"
    echo "\e[96m24 =\e[0m \e[93m255.255.255.0\e[0m"
    echo "\e[96m16 =\e[0m \e[93m255.255.0.0\e[0m"
    echo "\e[96m8 = \e[0m\e[93m255.0.0.0\e[0m"
    echo "---------------------"
    
    echo 

    read CIDR

    if [ $CIDR -gt 32 -o $CIDR -lt 0 ]
    then
        echo
        echo "\e[31mPrefix out of range\e[0m"
        echo

        exit 3
    fi

    echo "\e[96m
+---------------------------------+
|          Input Gateway          |    
+---------------------------------+
\e[0m"

    read GATEWAY

    echo "\e[96m
+---------------------------------+
|           Input DNS 1           |    
+---------------------------------+
\e[0m"

    read DNS1

    echo "\e[96m
+---------------------------------+
|           Input DNS 2           |    
+---------------------------------+
\e[0m"

    read DNS2

    echo "
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
    $NICKNAME
       dhcp4: no
       dhcp6: no

       addresses: [$IP/$CIDR]
       gateway4: $GATEWAY
       nameservers:

           addresses: [$DNS1,$DNS2]" > /etc/netplan/01-netcfg.yaml
    echo
    echo "\e[96mchecking file syntax\e[0m"

    netplan --debug generate > /dev/null 2>&1

    if [ $? -ne 0 ]
    then
        echo
        echo "\e[31mError of sintax\e[0m"
        echo

        exit 4

    else
        echo
            netplan apply

        echo "\e[92mDone\e[0m"
    fi

    echo 
    echo "\e[96mChecking internet connection\e[0m"
    echo

    ping -c 4 8.8.8.8

    sleep 2

    clear

    echo "\e[92mAll Done\e[0m"
    echo

    networkctl status


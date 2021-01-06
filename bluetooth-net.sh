#!/system/bin/sh
# date 2021-01-06 15:08:12
# author calllivecn <c-all@qq.com>


BLUE_IFNAME="bt-pan"

GATEWAY="10.250.250.1"
NET="10.250.250.0/24"
IP="10.250.250.2/24"

TABLE_ID=192

CWD=$(dirname ${0})

resolver(){
	ndc resolver setnetdns "${BLUE_IFNAME}" "" "223.5.5.5"
}


save(){
	iptables-save > "${CWD}/iptables"
	#iptables-save -t nat > "${CWD}/iptables-nat"
	#iptables-save -t mangle > "${CWD}/iptables-mangle"
	iptables -F
	iptables -X
	iptables -Z

	#ip rule save > "${CWD}/iprule"
	#ip rule flush
}

restore(){
	
	iptables-restore < "${CWD}/iptables"	
	#iptables-restore --table=nat < "${CWD}/iptables-nat"

	#ip rule restore < "${CWD}/iprule"
}


ip_set(){
	ip addr add dev $BLUE_IFNAME $IP

	#ip route add default via $GATEWAY dev $BLUE_IFNAME table $TABLE_ID
	#ip route add $NET dev $BLUE_IFNAME table $TABLE_ID

	#ip rule add suppress_prefixlength 0 table main

	ip route add default via $GATEWAY dev $BLUE_IFNAME
	ip route add $NET dev $BLUE_IFNAME


	ip rule add from $NET table $TABLE_ID
}

ip_unset(){
	#ip route flush table $TABLE_ID
	#ip rule del from $NET table $TABLE_ID

	#ip rule del suppress_prefixlength 0 table main

	ip addr del dev $BLUE_IFNAME $IP
}


main(){
	save

	ip_set

	resolver

	echo -n "用完之后按回车键退出。"
	echo
	read enter

	ip_unset
	restore
}

main

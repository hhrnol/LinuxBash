#!/bin/bash
declare -i StartHost EndHost
ip2u32() {
    local -i _o1 _o2 _o3 _o4 _m
    IFS=./ read _o1 _o2 _o3 _o4 _m <<< "${2}"
    printf -v $1 $((_o4+_o3*256+_o2*256*256+_o1*256*256*256))
    [[ $3 ]] && printf -v $3 $((StartHost+2**(32-_m)))
	  }
Network()	{
    local -i i1 i2 i3 i4 m1 m2 m3 m4
    IFS=./ read -r i1 i2 i3 i4 <<< "${1}"
    IFS=./ read -r m1 m2 m3 m4 <<< "${2}"
    printf "%d.%d.%d.%d" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" "$((i4 & m4))"
		}	
GetPrefix () { 
		c=0 x=0$( printf '%o' ${1//./ } )
		while [ $x -gt 0 ]; do
		let c+=$((x%2)) 'x>>=1'
		done
		echo /$c ; 
		}
Ipv4Qty=$(ifconfig | grep -w inet | grep -v -e 127|\
       		awk -F"inet " '{split($2,a," ");print a[1]}'|wc -l)

case $1 in
--all)
  
	for (( i=1; i<=$Ipv4Qty; i++ ))
		do
			IP=$(ifconfig | grep -w inet | grep -v -e 127|\
	       			awk -F"inet " "NR==$i"'{split($2,a," ");print a[1]}')
			MASK=$(ifconfig | grep -w inet | grep -v -e 127|\
	       			awk -F"netmask " "NR==$i"'{split($2,a," ");print a[1]}')
			PREFIX=$(GetPrefix "$MASK")
      Network=$(Network "$IP" "$MASK")
			CIDR="$Network$PREFIX"
      echo "scan network $CIDR"
			ip2u32 StartHost $CIDR EndHost
      echo "ping from $StartHost to $EndHost"
      for ipsub in $(seq $StartHost $EndHost)
        do
          (ping -c1 -t 1 $ipsub > /dev/null 2>&1) &
        done
    done
    arp -a | grep -v incomplete |awk '{print "ip="$2 " symbolic names " $1}'| tr -d '()' | sort
;;
--target)
	Ipv4Targ=$(ifconfig | grep -w inet |\
		awk -F"inet" '{split($2,a," ");print a[1]}')
	if [ -z $2 ] 
		then
		for i in $Ipv4Targ 
		do
		echo "Scan open tcp ports from ip address $i"	
		nmap -sT -O $i | awk '/open/'
		done
	elif [[ $2 ]]
		then
		nmap -sT -O $2 | awk '/open/'
	fi
;;
*)
	echo "possible keys --all , --target"
        echo "all - displays the IP addresses and symbolic names of all hosts in the current subnet"
	echo "target key displays a list of open system TCP ports"
;;
esac
#!/bin/bash

#Colours palette
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


### Constants ####

# Timing
MINUTE=60
TOP_MINUTE=300

# Curl options
CURL_INDEX=5
CURL[0]="curl -s ipconfig.io"
CURL[1]="curl -s ifconfig.me"
CURL[2]="curl -s icanhazip.com"
CURL[3]="curl -s ipecho.net/plain"
CURL[4]="curl -s ipinfo.io/ip"
CURL[5]="curl -s ip-api.com/line/?fields=query"

# Date command for log
DATELOG="date +%Y/%m/%d-%H:%M:%S"


### Checking if our ip is local or from outside ###
function check_public(){
 
	index=$(randomize 0 $CURL_INDEX)

	check_wg

	myIp=`eval ${CURL[index]}`

	if [[ -z $myIp ]]
	then
		echo -e "${redColour} $($DATELOG) [ERROR] Curl not worked! (${CURL[index]}) Trying again ${endColour}"

		sleep 1

		check_public
	else
		if [[ $myIp != $OUT_IP ]]
		then
			echo -e "${greenColour} $($DATELOG) [INFO]${turquoiseColour} Public IP checked correctly, we are going outside through [$myIp] instead [$OUT_IP] ${endColour}"
		else
			echo -e "${redColour} $($DATELOG) [ERROR] We aren't connected to Wireguard, we are in our [$myIp], restarting 3proxy and wireguard services ... ${endColour}"
			
			kill_3proxy
			
			delete_wg

			echo -e "${redColour} $($DATELOG) [ERROR]${turquoiseColour} Wait until next check [$myIp] ${endColour}"
			
			sleep 1

			check_public
		fi
	fi
}


### Checking if wireguard is connected ###
function check_wg(){

	if [[ ! $(wg) ]]
	then
        echo -e "${redColour} $($DATELOG) [ERROR] WG is down!!! ${endColour}"
        
        kill_3proxy

		delete_wg

        sleep 1
    fi
}


### Connect lete and 3proxy
function connect_wg_3proxy() {
	echo -e "${turquoiseColour} $($DATELOG) [INFO] Connecting to vpn network... ${endColour}"
	wg-quick up $WG_FILE
	
	check_wg
	
	echo -e "${turquoiseColour} $($DATELOG) [INFO] Launching proxy server... ${endColour}"
	/usr/local/bin/3proxy $CONF_FILE &
}


### Stopping wg interface
function delete_wg(){

	echo -e "${turquoiseColour} $($DATELOG) [INFO] Stopping wireguard connection... ${endColour}"   
	   
    wg-quick down $WG_FILE
	sleep 1  

	connect_wg_3proxy
}


### Killing 3proxy ###
function kill_3proxy(){

	PROXY=`ps -ef | grep 3proxy | grep -v grep | awk '{print $2}'`

	echo $PROXY

    if [[ ! -z $PROXY ]]
    then
    	echo -e "${turquoiseColour} $($DATELOG) [INFO] 3proxy pid is $PROXY. Killing 3proxy...${endColour}"
    	kill -9 $PROXY
    fi

}


### Getting a random number from an interval given
function randomize(){

	R=$[ $RANDOM % $2 + $1 ]
    echo "$R"
}


### Main ###

echo -e "${redColour}"

cat << "EOF"
                        🩸👁️...エルフェンリート...👁️🩸


EOF

echo -e "${endColour}"


echo -e "${turquoiseColour} $($DATELOG) [INFO] Starting Nyu proxy changing original IP $OUT_IP ${endColour}"

# adding to routing table
if [[ "$NETWORK" != "" ]];then
	echo $NETWORK | base64 -d | bash
fi

connect_wg_3proxy

while true
do
    # We check our ip if we have annonymous connection
    check_public

    # Sleeping until next check
    time=$(randomize $MINUTE $TOP_MINUTE)
    echo -e "${turquoiseColour} $($DATELOG) [INFO]  Waiting $time seconds... ${endColour}"   

    sleep $time
done


# Function to scan with NMAP, automating almost everything.
# Copy this into your `.bashrc` or `.zshrc` file, depending on your shell.
#
# This function performs the following tasks:
# - Identifies the type of machine (Linux or Windows).
# - Provides information about open ports and available services.
# - Generates a colorful report thanks to `batcat` (requires it to be installed).
#
# 4ndymcfly 2024

scanNmap () {
  NOCOLOR="\033[0m\e[0m"
  RED="\e[0;31m\033[1m"
  BLUE="\e[0;34m\033[1m"
  GRAY="\e[0;37m\033[1m"
	
  TTL=$(sudo ping -c 1 $1 2>/dev/null | grep ttl | awk '{print $6}' | cut -d "=" -f2)
	echo -e "\n${BLUE}[i] Starting port scan...${NOCOLOR}"
	sudo nmap -sS -p- --open --min-rate 5000 -n -Pn $1 -oG allPorts > /dev/null
	allPortsContent=$(cat ./allPorts)
	ip_address=$(echo "$allPortsContent" | grep -oP '^Host: .* \(\)' | head -n 1 | awk '{print $2}')
	open_ports=$(echo "$allPortsContent" | grep -oP '\d{1,5}/open' | awk '{print $1}' FS="/" | xargs | tr ' ' ',')
	num_ports=$(echo $open_ports | tr ',' '\n' | wc -l)
	echo -e "\n"
	echo -e "\t${BLUE}[*] IP:\t\t\t ${GRAY}$ip_address${NOCOLOR}\n"
	if [ -n "$TTL" ]
	then
		if [ $TTL -ge 120 ] && [ $TTL -le 130 ]
		then
			echo -e "\t${BLUE}[*] OS:\t\t\t ${GRAY}Windows${NOCOLOR}\n"
		elif [ $TTL -ge 60 ] && [ $TTL -le 70 ]
		then
			echo -e "\t${BLUE}[*] OS:\t\t\t ${GRAY}Linux${NOCOLOR}\n"
		elif [ $TTL -ge 250 ] && [ $TTL -le 254 ]
		then
			echo -e "\t${BLUE}[*] OS:\t\t\t ${GRAY}FreeBSD - Others${NOCOLOR}\n"
		else
			echo -e "\t${BLUE}[!]${NOCOLOR} Could not determine the operating system.\n"
		fi
	else
		echo -e "\t${BLUE}[!]${NOCOLOR} Could not obtain TTL or no response from the host.\n"
	fi
	echo -e "\t${BLUE}[*] Found $num_ports Ports:\t ${GRAY}$open_ports${NOCOLOR}\n\n"
	if [ -n "$open_ports" ]
	then
		echo $open_ports | tr -d '\n' | xclip -sel clip
		echo -e "${BLUE}[i] Starting comprehensive scan on the found ports...${NOCOLOR}"
		sudo nmap -sCV -p $open_ports $1 --stylesheet=https://raw.githubusercontent.com/honze-net/nmap-bootstrap-xsl/stable/nmap-bootstrap.xsl -oN targeted -oX targeted.xml > /dev/null
		/usr/bin/batcat --paging=never -l perl ./targeted
	else
		echo -e "${RED}[!] No open ports found.${NOCOLOR}"
	fi
}

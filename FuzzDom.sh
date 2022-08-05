#!/bin/bash

#------------------------------------------------------#
#                   PUZZDOM 1.0 !                      #
#               Coded by Tarek Dhokkar                 #
#~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ #
#      Github     :   github.com/DHK-Tn                #
#     Instagram  :    instagram.com/tarek_dhokkar/     #
#------------------------------------------------------#
#               Dont try to Steal it Bitch             #
#------------------------------------------------------#

# Colors FG

RED="$(printf '\e[31m')"
GREEN="$(printf '\e[32m')"
WHITE="$(printf '\e[37m')"

clear
just() {
clear
sleep 1
echo ""
echo ""
printf  "                                \e[32m|C|O|N|N|E|C|T|I|N|G|"
echo ""
echo ""
echo ""
}

banner() {
echo -e ""
echo "          $WHITE ██▓███   █    ██ ▒███████▒▒███████▒▓█████▄  ▒█████   ███▄ ▄███▓"
echo "          $RED▓██░  ██▒ ██  ▓██▒▒ ▒ ▒ ▄▀░▒ ▒ ▒ ▄▀░▒██▀ ██▌▒██▒  ██▒▓██▒▀█▀ ██▒"
echo "          $WHITE▓██░ ██▓▒▓██  ▒██░░ ▒ ▄▀▒░ ░ ▒ ▄▀▒░ ░██   █▌▒██░  ██▒▓██    ▓██░"
echo "          $RED▒██▄█▓▒ ▒▓▓█  ░██░  ▄▀▒   ░  ▄▀▒   ░░▓█▄   ▌▒██   ██░▒██    ▒██ "
echo "          $WHITE▒██▒ ░  ░▒▒█████▓ ▒███████▒▒███████▒░▒████▓ ░ ████▓▒░▒██▒   ░██▒"
echo "          $RED▒▓▒░ ░  ░░▒▓▒ ▒ ▒ ░▒▒ ▓░▒░▒░▒▒ ▓░▒░▒ ▒▒▓  ▒ ░ ▒░▒░▒░ ░ ▒░   ░  ░"
echo "          $WHITE░▒ ░     ░░▒░ ░ ░ ░░▒ ▒ ░ ▒░░▒ ▒ ░ ▒ ░ ▒  ▒   ░ ▒ ▒░ ░  ░      ░"
echo "          $RED░░        ░░░ ░ ░ ░ ░ ░ ░ ░░ ░ ░ ░ ░ ░ ░  ░ ░ ░ ░ ▒  ░      ░   "
echo "          $WHITE            ░       ░ ░      ░ ░       ░        ░ ░         ░   "
echo "          $RED                  ░        ░         ░                          "
echo ""
sleep 1
echo "                                    $WHITE Author:$RED Tarek Dhk"
echo ""

}
just
banner

url=$1
echo "$GREEN[+] Start FUZZDOM working with URL : $RED$url"
sleep 1
echo "$RED Take a$GREEN COFFE$RED it Will Take some Time <3 "
sleep 1
if [ ! -d "$url" ];then
	mkdir $url
fi
if [ ! -d "$url/dump" ];then
	mkdir $url/dump
fi
#    if [ ! -d '$url/dump/eyewitness' ];then
#        mkdir $url/dump/eyewitness
#    fi
if [ ! -d "$url/dump/scan-results" ];then
	mkdir $url/dump/scan-results
fi
if [ ! -d "$url/dump/httprobe" ];then
	mkdir $url/dump/httprobe
fi
if [ ! -d "$url/dump/potential_takeovers" ];then
	mkdir $url/dump/potential_takeovers
fi
if [ ! -d "$url/dump/wayback" ];then
	mkdir $url/dump/wayback
fi
if [ ! -d "$url/dump/wayback/params" ];then
	mkdir $url/dump/wayback/params
fi
if [ ! -d "$url/dump/wayback/extensions" ];then
	mkdir $url/dump/wayback/extensions
fi
if [ ! -f "$url/dump/httprobe/alive.txt" ];then
	touch $url/dump/httprobe/alive.txt
fi
if [ ! -f "$url/dump/final-results.txt" ];then
	touch $url/dump/final-results.txt
fi

echo "$GREEN[+] Harvesting subdomains with assetfinder$RED..."
assetfinder $url >> $url/dump/assets.txt
cat $url/dump/assets.txt | grep $1 >> $url/dump/final-results.txt
rm $url/dump/assets.txt

echo "$GREEN[+] Double checking for subdomains with amass$RED..."

amass enum -d $url >> $url/dump/f.txt
sort -u $url/dump/f.txt >> $url/dump/final-results.txt
rm $url/dump/f.txt

echo "$GREEN[+] Probing for alive domains$RED..."
cat $url/dump/final-results.txt | sort -u | httprobe -s -p https:443 | sed 's/https\?:\/\///' | tr -d ':443' >> $url/dump/httprobe/a.txt
sort -u $url/dump/httprobe/a.txt > $url/dump/httprobe/alive.txt
rm $url/dump/httprobe/a.txt

echo "$GREEN[+] Checking for possible subdomain takeover$RED..."
if [ ! -f "$url/dump/potential_takeovers/potential_takeovers.txt" ];then
	touch $url/dump/potential_takeovers/potential_takeovers.txt
fi

subjack -w $url/dump/final-results.txt -t 100 -timeout 30 -ssl -c ~/go/src/github.com/haccer/subjack/fingerprints.json -v 3 -o $url/dump/potential_takeovers/potential_takeovers.txt

echo "$GREEN[+] Scanning for open ports$RED..."
echo "$WHITE"
nmap -iL $url/dump/httprobe/alive.txt -T4 -oA $url/dump/scan-results/scanned.txt

echo "$GREEN[+] Scraping wayback data$RED..."
cat $url/dump/final-results.txt | waybackurls >> $url/dump/wayback/wayback_output.txt
sort -u $url/dump/wayback/wayback_output.txt

echo "$GREEN[+] Pulling and compiling all possible params found in wayback data$RED..."
cat $url/dump/wayback/wayback_output.txt | grep '?*=' | cut -d '=' -f 1 | sort -u >> $url/dump/wayback/params/wayback_params.txt
for line in $(cat $url/dump/wayback/params/wayback_params.txt);do echo $line'=';done

echo "$GREEN[+] Pulling and compiling js/php/aspx/jsp/json files from wayback output$WHITE..."
for line in $(cat $url/dump/wayback/wayback_output.txt);do
	ext="${line##*.}"
	if [[ "$ext" == "js" ]]; then
		echo $line >> $url/dump/wayback/extensions/js1.txt
		sort -u $url/dump/wayback/extensions/js1.txt >> $url/dump/wayback/extensions/js.txt
	fi
	if [[ "$ext" == "html" ]];then
		echo $line >> $url/dump/wayback/extensions/jsp1.txt
		sort -u $url/dump/wayback/extensions/jsp1.txt >> $url/dump/wayback/extensions/jsp.txt
	fi
	if [[ "$ext" == "json" ]];then
		echo $line >> $url/dump/wayback/extensions/json1.txt
		sort -u $url/dump/wayback/extensions/json1.txt >> $url/dump/wayback/extensions/json.txt
	fi
	if [[ "$ext" == "php" ]];then
		echo $line >> $url/dump/wayback/extensions/php1.txt
		sort -u $url/dump/wayback/extensions/php1.txt >> $url/dump/wayback/extensions/php.txt
	fi
	if [[ "$ext" == "aspx" ]];then
		echo $line >> $url/dump/wayback/extensions/aspx1.txt
		sort -u $url/dump/wayback/extensions/aspx1.txt >> $url/dump/wayback/extensions/aspx.txt
	fi
done

rm $url/dump/wayback/extensions/js1.txt
rm $url/dump/wayback/extensions/jsp1.txt
rm $url/dump/wayback/extensions/json1.txt
rm $url/dump/wayback/extensions/php1.txt
rm $url/dump/wayback/extensions/aspx1.txt
#echo "$GREEN[+] Running eyewitness against all compiled domains..."
#python3 EyeWitness/EyeWitness.py --web -f $url/dump/httprobe/alive.txt -d $url/dump/eyewitness --resolve
echo "$GREEN[+] WELL ALL DONE THANK YOU FOR WAITING YOU CAN CHECK THE RESULTS IN THE --  $url -- FOLDER"



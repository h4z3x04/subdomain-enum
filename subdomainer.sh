#!bin/bash


list_resolver=/usr/share/seclists/Miscellaneous/dns-resolvers.txt
list_wordlist=2m-subdomains.txt
amass_config=~/.config/amass/config.ini

echo "Recon started..."

subfinder -dL $1 -t 100 -o $2/subfinder.txt
cat $1 | assetfinder -subs-only | tee -a $2/assetfinder.txt
amass enum -df $1 -config $amass_config -ip -src -nf $2/subfinder.txt -o $2/amass.txt

echo "filtering live domains..."
shuffledns -list $1 -r $list_resolver -o ~/targets/$2/live_subomains.txt

cd $2

cat subfinder.txt assetfinder.txt live_subdomains.txt | sort -u | tee -a all_subdomains.txt

cat all_subdomains.txt | httpx -sc -title -o web_live_subdomains.txt

cat web_live_subdomains.txt | sed -nE 's/^(https?:\/\/\S+).*/\1/p' | tee -a filtered_web_live_subdomains.txt 

echo "Completed subdomain enum..!"

echo "Screenshoting.."
cat $2/filtered_web_live_subdomains.txt | aquatone -ports xlarge -out $2/

echo "Recon completed!"

tnotify(){
 message=$1
 token="6953348972:AAHemFnxqJTcQFSPTNR7m5Yz4S4Ll7yBcCM"
 chatid="1859013250"
 curl -s -X POST https://api.telegram.org/bot$token/sendMessage -d chat_id=$chatid -d text="Recon has been completed check your laptop"
}

tnotify

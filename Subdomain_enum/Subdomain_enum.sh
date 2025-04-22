#!/bin/bash

# =====================================================
#  JISANINFOSEC - SUBDOMAIN ENUMERATION & RECON TOOL
#  "Discover the Hidden, Secure the Visible"  
#  GitHub: @JisanInfosec | Twitter: @JisanInfosec
#  Note: This script is for educational purposes only. Always obtain permission before scanning any target.
# =====================================================

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

# ===== ASCII BANNER =====
echo -e "${PURPLE}"
cat << "EOF"
   ___ _____ ___ ___ _  _ _  _ ___   ___ _____ ___ ___  ___ 
  / __|_   _|_ _/ __| \| | \| | __| | _ \_   _| __/ _ \/ __|
  \__ \ | |  | |\__ \ .` | .` | _|  |   / | | | _| (_) \__ \
  |___/ |_| |___|___/_|\_|_|\_|___| |_|_\ |_| |___\___/|___/
EOF
echo -e "${NC}"
echo -e "${CYAN}>>> Subdomain Recon by ${RED}JisanInfosec${NC} <<<"
echo -e "${YELLOW}----------------------------------------${NC}"

# ===== ARGUMENTS =====
if [[ $# -lt 1 ]]; then
    echo -e "${RED}[-] Usage: $0 <domain> [--full]${NC}"
    echo -e "${YELLOW}[i] --full: Enable full recon (DNS resolve, HTTP check, screenshots)${NC}"
    echo -e "${YELLOW}[i] Required tools: subfinder, assetfinder, amass, sublist3r, ffuf, findomain, curl, jq, puredns, httpx, gowitness${NC}"
    echo -e "${YELLOW}[i] Install tools: sudo apt install <tool> or go install <tool> or pipx install sublist3r${NC}"
    exit 1
fi

DOMAIN="$1"
FULL_RECON=false
if [[ "$2" == "--full" ]]; then
    FULL_RECON=true
fi

# ===== CONFIG =====
OUTPUT_DIR="$HOME/jisan_recon/$DOMAIN"
TOOLS_DIR="$OUTPUT_DIR/tools_output"
SCREENSHOTS_DIR="$OUTPUT_DIR/screenshots"
LOG_FILE="$OUTPUT_DIR/jisan_recon.log"
RESOLVERS_FILE="$HOME/tools/resolvers.txt"  # Customize path if needed
WORDLIST="/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt"

# Required tools
REQUIRED_TOOLS=("subfinder" "assetfinder" "amass" "sublist3r" "ffuf" "findomain" "curl" "jq" "puredns" "httpx" "gowitness")

# ===== INITIALIZE =====
mkdir -p "$OUTPUT_DIR" "$TOOLS_DIR" "$SCREENSHOTS_DIR" || { echo -e "${RED}[-] Failed to create directories!${NC}"; exit 1; }
echo -e "${GREEN}[+] Output directory: ${BLUE}$OUTPUT_DIR${NC}"

# Logging function
log() {
    echo -e "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# ===== TOOL CHECK =====
SKIPPED_TOOLS=()
log "${YELLOW}[*] Checking tools...${NC}"
for tool in "${REQUIRED_TOOLS[@]}"; do
    if [[ "$tool" == "sublist3r" ]]; then
        if ! python3 -c "import sublist3r" &>/dev/null; then
            log "${YELLOW}[-] $tool not present, skipping...${NC}"
            SKIPPED_TOOLS+=("$tool")
        fi
    else
        if ! command -v "$tool" &>/dev/null; then
            log "${YELLOW}[-] $tool not present, skipping...${NC}"
            SKIPPED_TOOLS+=("$tool")
        fi
    fi
done
if [[ ${#SKIPPED_TOOLS[@]} -eq ${#REQUIRED_TOOLS[@]} ]]; then
    log "${RED}[-] No tools available, exiting.${NC}"
    exit 1
else
    log "${GREEN}[+] Proceeding with available tools!${NC}"
fi

# Check for wordlist
if [[ ! -f "$WORDLIST" ]]; then
    log "${RED}[-] Wordlist not found: $WORDLIST${NC}"
    log "${YELLOW}[i] Install SecLists: sudo apt install seclists${NC}"
    exit 1
fi

# Check for resolvers file if full recon is enabled
if [[ "$FULL_RECON" == true ]]; then
    if [[ ! -f "$RESOLVERS_FILE" ]]; then
        log "${RED}[-] Resolvers file not found: $RESOLVERS_FILE${NC}"
        log "${YELLOW}[i] Please create a resolvers file or update the path in the script.${NC}"
        exit 1
    fi
fi

# Create empty output files for skipped tools
for tool in "${SKIPPED_TOOLS[@]}"; do
    case "$tool" in
        "subfinder") touch "$TOOLS_DIR/subfinder.txt" ;;
        "assetfinder") touch "$TOOLS_DIR/assetfinder.txt" ;;
        "amass") touch "$TOOLS_DIR/amass.txt" ;;
        "sublist3r") touch "$TOOLS_DIR/sublist3r.txt" ;;
        "ffuf") touch "$TOOLS_DIR/ffuf.txt" ;;
        "findomain") touch "$TOOLS_DIR/findomain.txt" ;;
        "curl" | "jq") touch "$TOOLS_DIR/crtsh.txt" ;;  # crt.sh uses both curl and jq
        *) ;;  # Skip puredns, httpx, gowitness as they are full-recon only
    esac
done

# ===== SUBDOMAIN ENUMERATION =====
log "${CYAN}[*] Starting subdomain hunt...${NC}"

# Subfinder
if [[ ! " ${SKIPPED_TOOLS[@]} " =~ " subfinder " ]]; then
    log "[+] ${BLUE}Subfinder${NC} (Fast passive enumeration)"
    subfinder -d "$DOMAIN" -silent -o "$TOOLS_DIR/subfinder.txt" 2>> "$LOG_FILE"
fi

# Assetfinder
if [[ ! " ${SKIPPED_TOOLS[@]} " =~ " assetfinder " ]]; then
    log "[+] ${BLUE}Assetfinder${NC} (Quick subdomain discovery)"
    assetfinder --subs-only "$DOMAIN" > "$TOOLS_DIR/assetfinder.txt" 2>> "$LOG_FILE"
fi

# Amass (Passive)
if [[ ! " ${SKIPPED_TOOLS[@]} " =~ " amass " ]]; then
    log "[+] ${BLUE}Amass${NC} (Deep passive recon)"
    amass enum -passive -d "$DOMAIN" -silent -o "$TOOLS_DIR/amass.txt" 2>> "$LOG_FILE"
fi

# Sublist3r
if [[ ! " ${SKIPPED_TOOLS[@]} " =~ " sublist3r " ]]; then
    log "[+] ${BLUE}Sublist3r${NC} (Search engine scraping)"
    python3 -m sublist3r -d "$DOMAIN" -o "$TOOLS_DIR/sublist3r.txt" >> "$LOG_FILE" 2>&1
fi

# FFuf (Brute-force)
if [[ ! " ${SKIPPED_TOOLS[@]} " =~ " ffuf " ]]; then
    log "[+] ${BLUE}FFuf${NC} (Subdomain brute-forcing)"
    ffuf -u "http://FUZZ.$DOMAIN" -w "$WORDLIST" -o "$TOOLS_DIR/ffuf.json" -of json -t 50 &>> "$LOG_FILE"
    if [[ -s "$TOOLS_DIR/ffuf.json" ]]; then
        jq -r '.results[].url' "$TOOLS_DIR/ffuf.json" | sed 's/http:\/\///;s/\/$//' | sort -u > "$TOOLS_DIR/ffuf.txt"
    else
        log "${YELLOW}[!] FFuf found no subdomains${NC}"
        echo "" > "$TOOLS_DIR/ffuf.txt"
    fi
fi

# Findomain
if [[ ! " ${SKIPPED_TOOLS[@]} " =~ " findomain " ]]; then
    log "[+] ${BLUE}Findomain${NC} (Certificate transparency)"
    findomain -t "$DOMAIN" -u "$TOOLS_DIR/findomain.txt" >> "$LOG_FILE" 2>&1
fi

# crt.sh (uses curl and jq)
if [[ ! " ${SKIPPED_TOOLS[@]} " =~ " curl " ]] && [[ ! " ${SKIPPED_TOOLS[@]} " =~ " jq " ]]; then
    log "[+] ${BLUE}crt.sh${NC} (Certificate transparency)"
    curl -s "https://crt.sh/?q=%.$DOMAIN&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u > "$TOOLS_DIR/crtsh.txt" 2>> "$LOG_FILE"
else
    touch "$TOOLS_DIR/crtsh.txt"
fi

# Merge results
log "[+] Merging results..."
cat "$TOOLS_DIR"/*.txt | sort -u > "$OUTPUT_DIR/jisan_subdomains.txt"
TOTAL_SUBS=$(wc -l < "$OUTPUT_DIR/jisan_subdomains.txt")
log "${GREEN}[+] ${TOTAL_SUBS} unique subdomains found!${NC}"

# ===== FULL RECON (OPTIONAL) =====
if [[ "$FULL_RECON" == true ]]; then
    log "${CYAN}[*] Starting full reconnaissance...${NC}"

    # DNS Resolution (Puredns)
    if [[ ! " ${SKIPPED_TOOLS[@]} " =~ " puredns " ]]; then
        log "[+] ${BLUE}Puredns${NC} (DNS resolving)"
        puredns resolve "$OUTPUT_DIR/jisan_subdomains.txt" -r "$RESOLVERS_FILE" -w "$OUTPUT_DIR/verified_subdomains.txt" 2>> "$LOG_FILE"
    else
        touch "$OUTPUT_DIR/verified_subdomains.txt"
    fi

    # HTTPX (Live hosts)
    if [[ ! " ${SKIPPED_TOOLS[@]} " =~ " httpx " ]]; then
        log "[+] ${BLUE}HTTPX${NC} (Live subdomain check)"
        httpx -l "$OUTPUT_DIR/verified_subdomains.txt" -silent -o "$OUTPUT_DIR/live_subdomains.txt" 2>> "$LOG_FILE"
    else
        touch "$OUTPUT_DIR/live_subdomains.txt"
    fi

    # Gowitness (Screenshots)
    if [[ ! " ${SKIPPED_TOOLS[@]} " =~ " gowitness " ]]; then
        log "[+] ${BLUE}Gowitness${NC} (Taking screenshots)"
        gowitness file -f "$OUTPUT_DIR/live_subdomains.txt" -P "$SCREENSHOTS_DIR" --delay 2 >> "$LOG_FILE" 2>&1
    fi

    log "${GREEN}[+] Full recon completed!${NC}"
fi

# ===== CLEANUP =====
log "[*] Cleaning up temporary files..."
rm -f "$TOOLS_DIR/ffuf.json"

# ===== SUMMARY =====
echo -e "${PURPLE}"
echo "===================================="
echo "           JISAN RECON SUMMARY      "
echo "===================================="
echo -e "${NC}"
echo -e "🔍 ${CYAN}Target: ${GREEN}$DOMAIN${NC}"
echo -e "📂 ${CYAN}Output Dir: ${GREEN}$OUTPUT_DIR${NC}"
echo -e "📊 ${CYAN}Total Subdomains: ${GREEN}$TOTAL_SUBS${NC}"
if [[ ${#SKIPPED_TOOLS[@]} -gt 0 ]]; then
    echo -e "⚠️ ${CYAN}Skipped Tools: ${YELLOW}${SKIPPED_TOOLS[*]}${NC}"
fi
if [[ "$FULL_RECON" == true ]]; then
    echo -e "✅ ${CYAN}Verified Subdomains: ${GREEN}$(wc -l < "$OUTPUT_DIR/verified_subdomains.txt")${NC}"
    echo -e "🌐 ${CYAN}Live Subdomains: ${GREEN}$(wc -l < "$OUTPUT_DIR/live_subdomains.txt")${NC}"
    if [[ ! " ${SKIPPED_TOOLS[@]} " =~ " gowitness " ]]; then
        echo -e "📸 ${CYAN}Screenshots: ${GREEN}$(ls "$SCREENSHOTS_DIR" | grep -E '\.(jpg|png)$' | wc -l)${NC}"
    else
        echo -e "📸 ${CYAN}Screenshots: ${YELLOW}Skipped (Gowitness not available)${NC}"
    fi
fi
echo -e "${YELLOW}----------------------------------------${NC}"
echo -e "${GREEN}[+] Recon completed by ${RED}JisanInfosec${GREEN}!${NC}"
echo -e "${YELLOW}🚀 Happy Hacking! 🚀${NC}"
```

# Jisan-Automated-Tools: Subdomain Enumeration Script | JisanInfosec

**Author**: Md Jisan ([JisanInfosec](https://github.com/JisanInfosec))  
**Date**: April 21, 2025  
**Topics**: Subdomain Enumeration, Bash Scripting, Cyber Bangla, Bug Hunting  
**File**: `subdomain_enum.sh`  

## Overview
Alhamdulillah, I built `subdomain_enum.sh` for Cyber Bangla’s Recon Day-2 assignment, automating subdomain enumeration for bug hunting. It integrates 10 tools (Subfinder, Assetfinder, Amass, Sublist3r, FFuf, Findomain, crt.sh, Puredns, httpx, Gowitness) with basic and full recon modes (`--full` for DNS, HTTP, screenshots). Tested on scanme.nmap.org (5 subdomains) and yahoo.com (26,993 subdomains, 323 screenshots), it’s part of my #Pentest-Journey-2025! #JisanInfosec

## Features
- **10 Tools**: Subfinder, Assetfinder, Amass, Sublist3r, FFuf, Findomain, crt.sh (curl/jq), Puredns, httpx, Gowitness.
- **Two Modes**: Basic (quick enum) and full (DNS resolve, live checks, screenshots).
- **Error Handling**: Skips missing tools, creates empty output files.
- **User-Friendly**: Colorful ASCII banner, logging, results in `$HOME/jisan_recon/<domain>`.
- **Tested**: scanme.nmap.org (slow Amass/FFuf).

## Prepare Your Environment
### Check and Install Tools
Run this script to check/install required tools:
```bash
#!/bin/bash
TOOLS=("subfinder" "assetfinder" "amass" "ffuf" "findomain" "curl" "jq" "puredns" "httpx" "gowitness")
for tool in "${TOOLS[@]}"; do
  command -v "$tool" &>/dev/null && echo "$tool installed" || echo "$tool missing"
done
python3 -c "import sublist3r" &>/dev/null && echo "Sublist3r installed" || echo "Sublist3r missing"
```

## Usage
```
# Basic enumeration (quick subdomain discovery)
./subdomain_enum.sh scanme.nmap.org

# Full recon (DNS resolution, HTTP checks, screenshots)
./subdomain_enum.sh yahoo.com --full
```

## Install missing tools (Kali Linux):
```
# Go-based tools
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/tomnomnom/assetfinder@latest
go install -v github.com/projectdiscovery/puredns/v2/cmd/puredns@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/sensepost/gowitness@latest
# Apt-based tools
sudo apt update
sudo apt install amass ffuf curl jq seclists -y
# Findomain
wget https://github.com/Findomain/Findomain/releases/download/9.0.4/findomain-linux -O findomain
chmod +x findomain
sudo mv findomain /usr/local/bin/
# Sublist3r
pip3 install sublist3r
```
## Verify Wordlist

### Check FFuf wordlist:
```
ls /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt || sudo apt install seclists -y
```
## Set Up Resolvers

### Create resolvers for Puredns:
```
mkdir -p ~/tools
echo -e "8.8.8.8\n1.1.1.1\n9.9.9.9" > ~/tools/resolvers.txt
cat ~/tools/resolvers.txt  # Verify
```
## Installation
```
# Clone the repository
git clone https://github.com/JisanInfosec/Jisan-Automated-Tools.git
cd Jisan-Automated-Tools
# Make executable
chmod +x subdomain_enum.sh
```

## Requirements

- **Tools**: `subfinder`, `assetfinder`, `amass`, `sublist3r`, `ffuf`, `findomain`, `curl`, `jq`, `puredns`, `httpx`, `gowitness`.

- **Wordlist**: `/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt`.

- **Resolvers**: `~/tools/resolvers.txt` (for `--full` mode).

## Output

- **Directory**: `$HOME/jisan_recon/<domain>` (e.g., `jisan_recon/scanme.nmap.org`).

- **Files**: `jisan_subdomains.txt` (all subdomains), `verified_subdomains.txt` (DNS resolved), `live_subdomains.txt` (HTTP live), `screenshots/` (Gowitness images).

- **Log**: `jisan_recon.log` for debugging.

## Example Results

- **`scanme.nmap.org`**: ~5 subdomains, `Amass`/`FFuf` slow due to large wordlist (April 21, 2025).


## Troubleshooting

- **Tool Missing**: Install missing tools (see above). Check `jisan_recon.log`.

- **FFuf Fails**: Verify network (`ping 8.8.8.8`) and wordlist path.

- **Sublist3r Fails**: Run manually: `python3 -m sublist3r -d scanme.nmap.org -o sublist3r.txt`.

- **Gowitness Fails**: Ensure live subdomains exist: `cat live_subdomains.txt`. Run: `gowitness file -f live_subdomains.txt -P screenshots/ --delay 2`.

- **Resolvers Missing**: Recreate `~/tools/resolvers.txt`.

## Notes

- **Ethical Use**: For educational purposes only. Get permission before scanning.

- **Performance**: Use smaller wordlists for `Amass`/`FFuf` to speed up scans (`scanme.nmap.org` delays, April 21, 2025).

## Follow My Journey

- **GitHub**: https://github.com/JisanInfosec

- **LinkedIn**: [Md Jisan](https://www.linkedin.com/in/md-jisan-2a4582282/)

- **Pentest-Journey-2025**: Repo (`https://github.com/JisanInfosec/Pentest-Journey-2025`)

- **Hashtags**: #PentestingJourney #JisanInfosec #CyberBangla #BugBounty #SubdomainEnumeration

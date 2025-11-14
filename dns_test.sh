#!/bin/bash

# ANSI color codes for colored output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Function to get country flag emoji
get_flag() {
    local country_code=$1
    case $country_code in
        "TR") echo "🇹🇷" ;;
        "US") echo "🇺🇸" ;;
        "GB") echo "🇬🇧" ;;
        "DE") echo "🇩🇪" ;;
        "FR") echo "🇫🇷" ;;
        "CA") echo "🇨🇦" ;;
        "AU") echo "🇦🇺" ;;
        "NL") echo "🇳🇱" ;;
        "JP") echo "🇯🇵" ;;
        "KR") echo "🇰🇷" ;;
        "CN") echo "🇨🇳" ;;
        "IN") echo "🇮🇳" ;;
        "BR") echo "🇧🇷" ;;
        "RU") echo "🇷🇺" ;;
        "ES") echo "🇪🇸" ;;
        "IT") echo "🇮🇹" ;;
        "SE") echo "🇸🇪" ;;
        "NO") echo "🇳🇴" ;;
        "DK") echo "🇩🇰" ;;
        "FI") echo "🇫🇮" ;;
        "PL") echo "🇵🇱" ;;
        "CH") echo "🇨🇭" ;;
        "AT") echo "🇦🇹" ;;
        "BE") echo "🇧🇪" ;;
        "SG") echo "🇸🇬" ;;
        "HK") echo "🇭🇰" ;;
        "NZ") echo "🇳🇿" ;;
        "ZA") echo "🇿🇦" ;;
        "MX") echo "🇲🇽" ;;
        "AR") echo "🇦🇷" ;;
        *) echo "🌍" ;;
    esac
}

# Function to get country name
get_country_name() {
    local country_code=$1
    case $country_code in
        "TR") echo "Turkey" ;;
        "US") echo "United States" ;;
        "GB") echo "United Kingdom" ;;
        "DE") echo "Germany" ;;
        "FR") echo "France" ;;
        "CA") echo "Canada" ;;
        "AU") echo "Australia" ;;
        "NL") echo "Netherlands" ;;
        "JP") echo "Japan" ;;
        "KR") echo "South Korea" ;;
        "CN") echo "China" ;;
        "IN") echo "India" ;;
        "BR") echo "Brazil" ;;
        "RU") echo "Russia" ;;
        "ES") echo "Spain" ;;
        "IT") echo "Italy" ;;
        "SE") echo "Sweden" ;;
        "NO") echo "Norway" ;;
        "DK") echo "Denmark" ;;
        "FI") echo "Finland" ;;
        "PL") echo "Poland" ;;
        "CH") echo "Switzerland" ;;
        "AT") echo "Austria" ;;
        "BE") echo "Belgium" ;;
        "SG") echo "Singapore" ;;
        "HK") echo "Hong Kong" ;;
        "NZ") echo "New Zealand" ;;
        "ZA") echo "South Africa" ;;
        "MX") echo "Mexico" ;;
        "AR") echo "Argentina" ;;
        *) echo "Unknown" ;;
    esac
}

# Test domains
TEST_DOMAINS=("google.com" "amazon.com" "facebook.com" "youtube.com" "wikipedia.org")

# Global DNS servers
GLOBAL_DNS_LIST=(
    "Google Primary|8.8.8.8|Global"
    "Google Secondary|8.8.4.4|Global"
    "Cloudflare Primary|1.1.1.1|Global"
    "Cloudflare Secondary|1.0.0.1|Global"
    "Quad9 Primary|9.9.9.9|Global"
    "Quad9 Secondary|149.112.112.112|Global"
    "OpenDNS Home Primary|208.67.222.222|Global"
    "OpenDNS Home Secondary|208.67.220.220|Global"
    "AdGuard DNS Primary|94.140.14.14|Global"
    "AdGuard DNS Secondary|94.140.15.15|Global"
    "CleanBrowsing Primary|185.228.168.9|Global"
    "CleanBrowsing Secondary|185.228.169.9|Global"
    "Comodo Secure DNS|8.26.56.26|Global"
    "Level3 Primary|209.244.0.3|Global"
    "Level3 Secondary|209.244.0.4|Global"
    "Verisign Primary|64.6.64.6|Global"
    "Verisign Secondary|64.6.65.6|Global"
    "DNS.WATCH Primary|84.200.69.80|Global"
    "DNS.WATCH Secondary|84.200.70.40|Global"
    "Yandex DNS|77.88.8.8|Global"
    "Alternate DNS Primary|76.76.19.19|Global"
    "Alternate DNS Secondary|76.223.122.150|Global"
    "NextDNS|45.90.28.0|Global"
    "Control D|76.76.2.0|Global"
    "Freenom World|80.80.80.80|Global"
)

# Function to get local DNS servers based on country using API
get_local_dns_from_api() {
    local country_code=$1
    local country_lower=$(echo "$country_code" | tr '[:upper:]' '[:lower:]')
    
    echo -e "${YELLOW}   Fetching local DNS servers for $country_code...${NC}" >&2
    
    # Try public-dns.info API
    local dns_data=$(curl -s --connect-timeout 5 "https://public-dns.info/nameserver/${country_lower}.json" 2>/dev/null)
    
    if [ -n "$dns_data" ] && [ "$dns_data" != "[]" ]; then
        # Parse JSON and extract DNS servers
        if command -v python3 &> /dev/null; then
            echo "$dns_data" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    count = 0
    for dns in data:
        if count >= 10:  # Limit to 10 servers
            break
        ip = dns.get('ip', '')
        name = dns.get('name', '')
        if ip and ip != '0.0.0.0':
            # Create a descriptive name
            if name and name != ip:
                display_name = f'{name}'
            else:
                display_name = f'DNS Server {count+1}'
            print(f'{display_name}|{ip}|Local')
            count += 1
except:
    pass
" 2>/dev/null
        fi
    fi
}

# Function to get local DNS servers with fallback to manual list
get_local_dns() {
    local country_code=$1
    
    # First try API
    local api_result=$(get_local_dns_from_api "$country_code")
    
    if [ -n "$api_result" ]; then
        echo "$api_result"
        return
    fi
    
    # Fallback to manual list if API fails
    echo -e "${YELLOW}   Using fallback DNS list...${NC}" >&2
    case $country_code in
        "TR")
            echo "Turk Telekom Primary|195.175.39.39|Local"
            echo "Turk Telekom Secondary|195.175.39.40|Local"
            echo "Turk Telekom Alt 1|85.153.13.10|Local"
            echo "Turk Telekom Alt 2|85.153.13.11|Local"
            echo "Vodafone TR|193.140.100.100|Local"
            echo "Turkcell Superonline 1|212.252.192.20|Local"
            echo "Turkcell Superonline 2|212.252.192.30|Local"
            ;;
        "US")
            echo "AT&T DNS 1|68.94.156.1|Local"
            echo "AT&T DNS 2|68.94.157.1|Local"
            echo "Comcast DNS 1|75.75.75.75|Local"
            echo "Comcast DNS 2|75.75.76.76|Local"
            echo "Verizon DNS 1|198.55.96.1|Local"
            echo "Verizon DNS 2|198.55.97.1|Local"
            ;;
        "GB")
            echo "BT DNS 1|194.168.4.100|Local"
            echo "BT DNS 2|194.168.8.100|Local"
            echo "Virgin Media 1|194.168.4.100|Local"
            echo "Sky Broadband 1|90.207.238.97|Local"
            ;;
        "DE")
            echo "Deutsche Telekom 1|217.237.148.102|Local"
            echo "Deutsche Telekom 2|217.237.149.205|Local"
            echo "Vodafone DE 1|139.7.30.125|Local"
            echo "Vodafone DE 2|139.7.30.126|Local"
            ;;
        "FR")
            echo "Orange France 1|80.10.246.2|Local"
            echo "Orange France 2|80.10.246.129|Local"
            echo "Free France 1|212.27.40.240|Local"
            echo "Free France 2|212.27.40.241|Local"
            ;;
        "CA")
            echo "Rogers DNS 1|64.71.255.198|Local"
            echo "Rogers DNS 2|64.71.255.199|Local"
            echo "Bell Canada 1|207.164.117.118|Local"
            echo "Bell Canada 2|207.164.117.119|Local"
            ;;
        "AU")
            echo "Telstra DNS 1|139.130.4.5|Local"
            echo "Telstra DNS 2|203.50.2.71|Local"
            echo "Optus DNS 1|211.29.132.12|Local"
            echo "Optus DNS 2|211.29.132.13|Local"
            ;;
        "JP")
            echo "NTT DNS 1|210.196.3.183|Local"
            echo "NTT DNS 2|210.141.112.163|Local"
            echo "SoftBank DNS 1|202.229.97.43|Local"
            ;;
        "KR")
            echo "KT DNS 1|168.126.63.1|Local"
            echo "KT DNS 2|168.126.63.2|Local"
            echo "SK Broadband 1|210.220.163.82|Local"
            ;;
        "BR")
            echo "NET Brazil 1|200.248.178.54|Local"
            echo "NET Brazil 2|200.248.178.180|Local"
            ;;
        "RU")
            echo "Yandex DNS Russia|77.88.8.8|Local"
            echo "Rostelecom 1|212.48.193.36|Local"
            ;;
        "IN")
            echo "Airtel India 1|122.160.230.91|Local"
            echo "Jio India 1|49.44.94.254|Local"
            ;;
        "NL")
            echo "KPN DNS 1|195.121.1.34|Local"
            echo "Ziggo DNS 1|195.121.1.66|Local"
            ;;
        "ES")
            echo "Telefonica Spain 1|80.58.61.250|Local"
            echo "Orange Spain 1|62.37.228.20|Local"
            ;;
        "IT")
            echo "Telecom Italia 1|85.37.17.51|Local"
            echo "Fastweb Italy 1|195.31.8.226|Local"
            ;;
        "SE")
            echo "Telia Sweden 1|62.20.250.130|Local"
            echo "Telenor Sweden 1|213.64.129.129|Local"
            ;;
        *)
            # Return empty for unknown countries
            ;;
    esac
}

echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║      DNS Server Speed Test Tool (Global)          ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Detect user's location
echo -e "${YELLOW}🌍 Detecting your location...${NC}"
LOCATION_DATA=$(curl -s "http://ip-api.com/json" 2>/dev/null)

if [ -n "$LOCATION_DATA" ]; then
    # Use Python to parse JSON
    if command -v python3 &> /dev/null; then
        COUNTRY_CODE=$(echo "$LOCATION_DATA" | python3 -c "import sys, json; print(json.load(sys.stdin).get('countryCode',''))" 2>/dev/null)
        COUNTRY_NAME=$(echo "$LOCATION_DATA" | python3 -c "import sys, json; print(json.load(sys.stdin).get('country',''))" 2>/dev/null)
        CITY=$(echo "$LOCATION_DATA" | python3 -c "import sys, json; print(json.load(sys.stdin).get('city',''))" 2>/dev/null)
        IP=$(echo "$LOCATION_DATA" | python3 -c "import sys, json; print(json.load(sys.stdin).get('query',''))" 2>/dev/null)
        LAT=$(echo "$LOCATION_DATA" | python3 -c "import sys, json; print(json.load(sys.stdin).get('lat',''))" 2>/dev/null)
        LON=$(echo "$LOCATION_DATA" | python3 -c "import sys, json; print(json.load(sys.stdin).get('lon',''))" 2>/dev/null)
    else
        # Fallback: try with grep/sed if Python is not available
        COUNTRY_CODE=$(echo "$LOCATION_DATA" | grep -o '"countryCode":"[^"]*"' | cut -d'"' -f4)
        COUNTRY_NAME=$(echo "$LOCATION_DATA" | grep -o '"country":"[^"]*"' | cut -d'"' -f4)
        CITY=$(echo "$LOCATION_DATA" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
        IP=$(echo "$LOCATION_DATA" | grep -o '"query":"[^"]*"' | cut -d'"' -f4)
        LAT=$(echo "$LOCATION_DATA" | grep -o '"lat":[^,]*' | cut -d':' -f2)
        LON=$(echo "$LOCATION_DATA" | grep -o '"lon":[^,]*' | cut -d':' -f2)
    fi
    
    if [ -z "$COUNTRY_CODE" ]; then
        COUNTRY_CODE="UNKNOWN"
        COUNTRY_NAME="Unknown"
    fi
else
    COUNTRY_CODE="UNKNOWN"
    COUNTRY_NAME="Unknown"
    CITY="Unknown"
    IP="Unknown"
    LAT=""
    LON=""
fi

FLAG=$(get_flag "$COUNTRY_CODE")

echo -e "${GREEN}✓ Location detected:${NC}"
echo -e "   ${FLAG} Country: ${CYAN}$COUNTRY_NAME${NC} ($COUNTRY_CODE)"
echo -e "   📍 City: ${CYAN}$CITY${NC}"
echo -e "   🌐 IP: ${CYAN}$IP${NC}"
if [ -n "$LAT" ] && [ -n "$LON" ]; then
    echo -e "   📍 Coordinates: ${CYAN}$LAT, $LON${NC}"
fi
echo ""

# Build DNS list
DNS_LIST=("${GLOBAL_DNS_LIST[@]}")

# Add local DNS servers if available
LOCAL_DNS_COUNT=0
if [ "$COUNTRY_CODE" != "UNKNOWN" ]; then
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            DNS_LIST+=("$line")
            ((LOCAL_DNS_COUNT++))
        fi
    done < <(get_local_dns "$COUNTRY_CODE")
fi

# First ask for test mode
echo -e "${YELLOW}Select test mode:${NC}"
echo ""
echo -e "  ${GREEN}1)${NC} Quick Test (1 query per DNS - Faster but less reliable)"
echo -e "  ${BLUE}2)${NC} Normal Test (5 queries per DNS - Recommended)"
echo ""
echo -ne "${CYAN}Your choice [1/2]:${NC} "
read -r test_mode
echo ""

case $test_mode in
    1)
        QUERY_COUNT=1
        echo -e "${GREEN}✓ Quick test mode selected${NC}"
        ;;
    2)
        QUERY_COUNT=5
        echo -e "${BLUE}✓ Normal test mode selected${NC}"
        ;;
    *)
        QUERY_COUNT=5
        echo -e "${YELLOW}✓ Normal test mode selected by default${NC}"
        ;;
esac
echo ""

# Then ask for DNS category
echo -e "${YELLOW}Which DNS servers would you like to test?${NC}"
echo ""
if [ $LOCAL_DNS_COUNT -gt 0 ]; then
    echo -e "  ${GREEN}1)${NC} Local DNS Servers Only ($LOCAL_DNS_COUNT servers from $COUNTRY_NAME)"
    echo -e "  ${BLUE}2)${NC} Global DNS Servers Only (${#GLOBAL_DNS_LIST[@]} servers)"
    echo -e "  ${MAGENTA}3)${NC} All DNS Servers ($((${#GLOBAL_DNS_LIST[@]} + LOCAL_DNS_COUNT)) servers)"
else
    echo -e "  ${YELLOW}Note: No local DNS servers found for $COUNTRY_NAME${NC}"
    echo -e "  ${BLUE}1)${NC} Global DNS Servers Only (${#GLOBAL_DNS_LIST[@]} servers)"
fi
echo ""
echo -ne "${CYAN}Your choice [1/2/3]:${NC} "
read -r choice
echo ""

# Filter based on selection
if [ $LOCAL_DNS_COUNT -gt 0 ]; then
    case $choice in
        1)
            FILTER="Local"
            echo -e "${GREEN}✓ Local DNS servers will be tested${NC}"
            ;;
        2)
            FILTER="Global"
            echo -e "${BLUE}✓ Global DNS servers will be tested${NC}"
            ;;
        3)
            FILTER="All"
            echo -e "${MAGENTA}✓ All DNS servers will be tested${NC}"
            ;;
        *)
            echo -e "${RED}✗ Invalid selection! All servers will be tested.${NC}"
            FILTER="All"
            ;;
    esac
else
    FILTER="Global"
    echo -e "${BLUE}✓ Global DNS servers will be tested${NC}"
fi
echo ""

# Create temporary file
TEMP_FILE="/tmp/dns_test_results_$.txt"
> "$TEMP_FILE"

# Build filtered DNS list
FILTERED_DNS=()
for dns_entry in "${DNS_LIST[@]}"; do
    IFS='|' read -r dns_name dns_ip dns_type <<< "$dns_entry"
    if [ "$FILTER" = "All" ] || [ "$FILTER" = "$dns_type" ]; then
        FILTERED_DNS+=("$dns_entry")
    fi
done

# Number of servers to test
total_servers=${#FILTERED_DNS[@]}

if [ $total_servers -eq 0 ]; then
    echo -e "${RED}Error: No DNS servers found to test!${NC}"
    exit 1
fi

echo -e "${YELLOW}Testing ${total_servers} DNS servers (${QUERY_COUNT} requests each)...${NC}"
if [ $QUERY_COUNT -eq 1 ]; then
    echo -e "${MAGENTA}(Quick test - Approximately $((total_servers * 3 / 60)) minutes)${NC}"
else
    echo -e "${MAGENTA}(Normal test - Approximately $((total_servers * 15 / 60)) minutes)${NC}"
fi
echo ""

# For progress bar
current=0
success_count=0
failed_count=0

# Test DNS servers
for dns_entry in "${FILTERED_DNS[@]}"; do
    IFS='|' read -r dns_name dns_ip dns_type <<< "$dns_entry"
    
    total_time=0
    successful_queries=0
    
    ((current++))
    progress=$((current * 100 / total_servers))
    
    error_msg=""
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}[${progress}%] Testing: ${YELLOW}$dns_name${NC} (${MAGENTA}$dns_ip${NC})${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    for ((i=1; i<=QUERY_COUNT; i++)); do
        domain_index=$(((i - 1) % ${#TEST_DOMAINS[@]}))
        domain="${TEST_DOMAINS[$domain_index]}"
        
        echo -ne "  ${BLUE}→${NC} Query ${i}/${QUERY_COUNT} to ${CYAN}$domain${NC} ... "
        
        result=$(dig @"$dns_ip" "$domain" +tries=2 +time=5 +short 2>&1)
        query_status=$?
        
        query_time_result=$(dig @"$dns_ip" "$domain" +tries=2 +time=5 2>&1 | grep "Query time:")
        
        if echo "$query_time_result" | grep -q "Query time:"; then
            query_time=$(echo "$query_time_result" | grep "Query time:" | awk '{print $4}')
            total_time=$((total_time + query_time))
            ((successful_queries++))
            
            echo -e "${GREEN}✓ ${query_time}ms${NC}"
        else
            if [ -z "$error_msg" ]; then
                if echo "$result" | grep -qi "connection timed out"; then
                    error_msg="Connection Timeout"
                elif echo "$result" | grep -qi "no servers could be reached"; then
                    error_msg="Server Unreachable"
                elif echo "$result" | grep -qi "SERVFAIL"; then
                    error_msg="Server Failure"
                elif echo "$result" | grep -qi "REFUSED"; then
                    error_msg="Query Refused"
                elif [ $query_status -ne 0 ]; then
                    error_msg="DNS Resolution Failed"
                else
                    error_msg="Unknown Error"
                fi
            fi
            
            echo -e "${RED}✗ FAILED${NC}"
            echo -e "     ${YELLOW}Error: $error_msg${NC}"
            if [ -n "$result" ]; then
                short_result=$(echo "$result" | head -c 80)
                echo -e "     ${YELLOW}Details: $short_result${NC}"
            fi
        fi
    done
    
    if [ $successful_queries -gt 0 ]; then
        avg_time=$((total_time / successful_queries))
        success_rate=$((successful_queries * 100 / QUERY_COUNT))
        echo -e "  ${GREEN}Summary: ${avg_time}ms avg (${success_rate}% success)${NC}"
        
        printf "%d|%s|%s|%s|OK|%d|N/A\n" "$avg_time" "$dns_name" "$dns_ip" "$dns_type" "$success_rate" >> "$TEMP_FILE"
        ((success_count++))
    else
        echo -e "  ${RED}Summary: All queries failed${NC}"
        
        printf "99999|%s|%s|%s|FAILED|0|%s\n" "$dns_name" "$dns_ip" "$dns_type" "$error_msg" >> "$TEMP_FILE"
        ((failed_count++))
    fi
    echo ""
done

echo -e "${GREEN}Test completed!${NC}"
echo ""

if [ ! -s "$TEMP_FILE" ]; then
    echo -e "${RED}ERROR: Result file is empty or not found!${NC}"
    exit 1
fi

sort -t'|' -k1 -n "$TEMP_FILE" > "${TEMP_FILE}.sorted"

if [ ! -s "${TEMP_FILE}.sorted" ]; then
    echo -e "${RED}ERROR: Sorted file could not be created!${NC}"
    exit 1
fi

# Print results table
echo -e "${CYAN}╔═════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                         TEST RESULTS                                ║${NC}"
echo -e "${CYAN}╠═════════════════════════════════════════════════════════════════════╣${NC}"
printf "${CYAN}║${NC} %-3s %-42s %-12s %-6s ${CYAN}║${NC}\n" "#" "DNS Server" "Avg. Time" "Status"
echo -e "${CYAN}╠═════════════════════════════════════════════════════════════════════╣${NC}"

rank=1
local_count=0
global_count=0

while IFS='|' read -r avg_time dns_name dns_ip dns_type status success_rate error_msg; do
    if [ "$dns_type" = "Local" ]; then
        ((local_count++))
        flag="$FLAG "
    else
        ((global_count++))
        flag=""
    fi
    
    if [ "$status" = "OK" ]; then
        if [ $avg_time -lt 30 ]; then
            color=$GREEN
            speed_icon="🚀"
        elif [ $avg_time -lt 50 ]; then
            color=$GREEN
            speed_icon="⚡"
        elif [ $avg_time -lt 100 ]; then
            color=$YELLOW
            speed_icon="➤"
        else
            color=$RED
            speed_icon="⊗"
        fi
        
        display_name="$flag$dns_name"
        if [ ${#display_name} -gt 25 ]; then
            display_name="${display_name:0:25}..."
        fi
        
        printf "${CYAN}║${NC} ${color}%-3s${NC} %-42s ${color}%-9s ms${NC} ${GREEN}%-6s${NC} ${CYAN}║${NC}\n" \
            "$rank" "$display_name ($dns_ip)" "$avg_time" "$speed_icon"
    else
        display_name="$flag$dns_name"
        if [ ${#display_name} -gt 25 ]; then
            display_name="${display_name:0:25}..."
        fi
        printf "${CYAN}║${NC} ${RED}%-3s${NC} %-42s ${RED}%-9s${NC}    ${RED}%-6s${NC} ${CYAN}║${NC}\n" \
            "$rank" "$display_name ($dns_ip)" "TIMEOUT" "✗"
    fi
    
    ((rank++))
done < "${TEMP_FILE}.sorted"

echo -e "${CYAN}╚═════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Statistics
echo -e "${BLUE}📊 Statistics:${NC}"
if [ "$FILTER" = "All" ] || [ "$FILTER" = "Global" ]; then
    echo -e "   Global DNS Servers: ${GREEN}${global_count}${NC}"
fi
if [ "$FILTER" = "All" ] || [ "$FILTER" = "Local" ]; then
    echo -e "   Local DNS Servers ($COUNTRY_NAME): ${MAGENTA}${local_count}${NC}"
fi
echo -e "   Successful: ${GREEN}${success_count}${NC} | Failed: ${RED}${failed_count}${NC}"
echo -e "   Total Tests: ${YELLOW}$((total_servers * QUERY_COUNT))${NC} DNS queries"
if [ $QUERY_COUNT -eq 1 ]; then
    echo -e "   Test Mode: ${YELLOW}Quick Test${NC} (1 query/DNS)"
else
    echo -e "   Test Mode: ${GREEN}Normal Test${NC} (5 queries/DNS - More reliable)"
fi
echo ""

# Top 5 fastest
echo -e "${GREEN}🏆 Recommended DNS Servers (Top 5 Fastest):${NC}"
echo ""
head -n 5 "${TEMP_FILE}.sorted" | while IFS='|' read -r avg_time dns_name dns_ip dns_type status success_rate error_msg; do
    if [ "$status" = "OK" ] && [ $avg_time -lt 99999 ]; then
        if [ "$dns_type" = "Local" ]; then
            flag="$FLAG "
        else
            flag=""
        fi
        if [ $QUERY_COUNT -eq 1 ]; then
            echo -e "  ${GREEN}✓${NC} $flag$dns_name - ${BLUE}$dns_ip${NC} (${YELLOW}${avg_time}ms${NC})"
        else
            echo -e "  ${GREEN}✓${NC} $flag$dns_name - ${BLUE}$dns_ip${NC} (${YELLOW}${avg_time}ms${NC} - ${success_rate}% success)"
        fi
    fi
done

# Fastest local DNS
if [ "$FILTER" = "Local" ] || [ "$FILTER" = "All" ]; then
    if [ $LOCAL_DNS_COUNT -gt 0 ]; then
        echo ""
        echo -e "${MAGENTA}$FLAG Fastest Local DNS Servers in $COUNTRY_NAME (Top 3):${NC}"
        echo ""
        grep "|Local|" "${TEMP_FILE}.sorted" | head -n 3 | while IFS='|' read -r avg_time dns_name dns_ip dns_type status success_rate error_msg; do
            if [ "$status" = "OK" ] && [ $avg_time -lt 99999 ]; then
                if [ $QUERY_COUNT -eq 1 ]; then
                    echo -e "  ${GREEN}✓${NC} $FLAG $dns_name - ${BLUE}$dns_ip${NC} (${YELLOW}${avg_time}ms${NC})"
                else
                    echo -e "  ${GREEN}✓${NC} $FLAG $dns_name - ${BLUE}$dns_ip${NC} (${YELLOW}${avg_time}ms${NC} - ${success_rate}% success)"
                fi
            fi
        done

        if ! grep -q "|Local|OK" "${TEMP_FILE}.sorted"; then
            echo -e "  ${RED}Local DNS servers are not responding${NC}"
        fi
    fi
fi

# Failed servers
if [ "$failed_count" -gt 0 ]; then
    echo ""
    echo -e "${RED}❌ Unresponsive DNS Servers:${NC}"
    echo ""
    grep "|FAILED|" "${TEMP_FILE}.sorted" 2>/dev/null | while IFS='|' read -r avg_time dns_name dns_ip dns_type status success_rate error_msg; do
        if [ "$dns_type" = "Local" ]; then
            flag="$FLAG "
        else
            flag=""
        fi
        echo -e "  ${RED}✗${NC} $flag$dns_name (${BLUE}$dns_ip${NC}) - ${RED}$error_msg${NC}"
    done
fi

echo ""
echo -e "${YELLOW}💡 Tip:${NC} To change DNS settings on macOS:"
echo -e "   System Settings > Network > Wi-Fi/Ethernet > Details > DNS"
echo ""
echo -e "${CYAN}Speed Indicators:${NC} 🚀 Very Fast (<30ms) | ⚡ Fast (<50ms) | ➤ Medium (<100ms) | ⊗ Slow (>100ms)"
echo ""

# Cleanup
rm -f "$TEMP_FILE" "${TEMP_FILE}.sorted"

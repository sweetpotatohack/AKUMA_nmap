#!/bin/bash

RED="\033[0;31m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
RESET="\033[0m"

print_help() {
    echo -e "${CYAN}"
    echo "┌───────────────────────────────┐"
    echo "│         NMAP SCANNER          │"
    echo "└───────────────────────────────┘"
    echo -e "${RESET}Автоматический скан в 3 этапа. Только живые, только нужные."
    echo ""
    echo -e "${CYAN}Использование:${RESET}"
    echo "  ./nmap.sh -t <цель> [-A]"
    echo ""
    echo -e "${CYAN}Параметры:${RESET}"
    echo "  -t <цель>   Цель (например, 192.168.1.0/24)"
    echo "  -A         Включить сканирование сервисов"
    echo "  --help     Показать помощь"
    echo ""
}

TARGET=""
DO_SERVICE_SCAN=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -t) TARGET="$2"; shift ;;
        -A) DO_SERVICE_SCAN=true ;;
        --help) print_help; exit 0 ;;
        *) echo -e "${RED}[!] Неизвестный аргумент: $1${RESET}"; exit 1 ;;
    esac
    shift
done

if [[ -z "$TARGET" ]]; then
    echo -e "${RED}[!] Цель не указана. Используй --help для справки.${RESET}"
    exit 1
fi

# Очистка логов/выходных файлов
> live_hosts.txt
> open_ports.txt
> services.txt
> closed_hosts.txt
> skipped_hosts.log

# 1. PING SCAN
echo -e "${GREEN}[1/3] Поиск живых хостов...${RESET}"
nmap -sn "$TARGET" -oG temp_ping.gnmap > /dev/null
LIVE_HOSTS=$(grep "Up" temp_ping.gnmap | awk '{print $2}')
rm -f temp_ping.gnmap
if [[ -z "$LIVE_HOSTS" ]]; then
    echo -e "${RED}[!] Нет живых хостов${RESET}"
    exit 1
fi
echo "$LIVE_HOSTS" > live_hosts.txt
echo -e "${GREEN}→ Найдено $(wc -l < live_hosts.txt) живых хостов${RESET}"

# 2. PORT SCAN
echo -e "${GREEN}[2/3] Сканирование портов...${RESET}"
for host in $LIVE_HOSTS; do
    echo -e "${GREEN}→ $host${RESET}"
    PORTS=$(nmap -T5 -Pn -n -p- --min-rate 10000 "$host" | awk '/^[0-9]+\/tcp/ && /open/ {print $1}' | paste -sd "," -)
    if [[ -z "$PORTS" ]]; then
        echo "$host" >> closed_hosts.txt
        echo "$host: порты закрыты — сервисы не сканируются" >> skipped_hosts.log
    else
        echo "$host: $PORTS" >> open_ports.txt
    fi
done

# 3. SERVICE SCAN (если -A)
if [[ "$DO_SERVICE_SCAN" = true ]]; then
    echo -e "${GREEN}[3/3] Глубокий анализ сервисов...${RESET}"
    while IFS= read -r line; do
        host=$(echo "$line" | cut -d':' -f1)
        ports=$(echo "$line" | cut -d':' -f2 | tr -d ' ')
        echo -e "${GREEN}→ $host (порты: $ports)${RESET}"
        nmap -T5 -Pn -sV -n -p "$ports" "$host" | awk '
            BEGIN { skip=1 }
            /^PORT/ { skip=0; next }
            /^Nmap done/ { exit }
            skip==0 && /^[0-9]+\/tcp/ { print "'$host':", $0 }
        ' >> services.txt
    done < open_ports.txt
fi

echo -e "${GREEN}[✔] Готово. Всех отсканировал, кто был достоин.${RESET}"

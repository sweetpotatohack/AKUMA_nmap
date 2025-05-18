#!/bin/bash

# Цвета
RED="\033[0;31m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
RESET="\033[0m"

# Справка
print_help() {
    echo -e "${CYAN}"
    echo "┌───────────────────────────────┐"
    echo "│         NMAP SCANNER          │"
    echo "└───────────────────────────────┘"
    echo -e "${RESET}Скрипт для быстрой разведки сети в 4 этапа:"
    echo ""
    echo -e "${GREEN}1.${RESET} Поиск живых хостов (ping scan)"
    echo -e "${GREEN}2.${RESET} Сканирование всех портов (--min-rate)"
    echo -e "${GREEN}3.${RESET} (Опционально) Сканирование сервисов с -A и -sV"
    echo ""
    echo -e "${CYAN}Использование:${RESET}"
    echo "  ./nmap.sh -t <цель> [-A]"
    echo ""
    echo -e "${CYAN}Аргументы:${RESET}"
    echo "  -t <цель>     Диапазон IP-адресов или подсеть (например, 192.168.1.0/24)"
    echo "  -A           Включить глубокое сканирование сервисов (nmap -A -sV)"
    echo "  --help       Показать это справочное меню"
    echo ""
    echo -e "${CYAN}Примеры:${RESET}"
    echo "  ./nmap.sh -t 192.168.1.0/24"
    echo "  ./nmap.sh -t 10.10.10.0/24 -A"
    echo ""
    echo -e "${CYAN}Файлы на выходе:${RESET}"
    echo "  live_hosts.txt               — список живых хостов"
    echo "  scan_ports_<ip>.txt          — открытые порты"
    echo "  scan_services_<ip>.txt       — службы и ОС (если флаг -A)"
    echo ""
}

# Аргументы
TARGET=""
DO_SERVICE_SCAN=false

# Парсинг аргументов
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -t) TARGET="$2"; shift ;;
        -A) DO_SERVICE_SCAN=true ;;
        --help) print_help; exit 0 ;;
        *) echo -e "${RED}[!] Неизвестный аргумент: $1${RESET}"; exit 1 ;;
    esac
    shift
done

# Проверка цели
if [[ -z "$TARGET" ]]; then
    echo -e "${RED}[!] Цель не указана. Используйте --help для справки.${RESET}"
    exit 1
fi

# 1. Ping scan
echo -e "${GREEN}[1/4] Поиск живых хостов...${RESET}"
nmap -sn "$TARGET" -oG live_hosts.gnmap > /dev/null
LIVE_HOSTS=$(grep "Up" live_hosts.gnmap | awk '{print $2}')
if [[ -z "$LIVE_HOSTS" ]]; then
    echo -e "${RED}[!] Живые хосты не найдены${RESET}"
    exit 1
fi
echo "$LIVE_HOSTS" > live_hosts.txt
echo -e "${GREEN}Найдено $(wc -l < live_hosts.txt) живых хостов.${RESET}"

# 2. Port scan
echo -e "${GREEN}[2/4] Быстрое сканирование всех портов...${RESET}"
for host in $LIVE_HOSTS; do
    echo -e "${GREEN}→ $host${RESET}"
    nmap -T5 -Pn -n -p- --min-rate 10000 "$host" -oN "scan_ports_$host.txt"
done

# 3. Service scan (если -A)
if [[ "$DO_SERVICE_SCAN" = true ]]; then
    echo -e "${GREEN}[3/4] Глубокое сканирование сервисов (-A)...${RESET}"
    for host in $LIVE_HOSTS; do
        echo -e "${GREEN}→ $host${RESET}"
        nmap -T5 -Pn -sV -A -n -p- --min-rate 10000 "$host" -oN "scan_services_$host.txt"
    done
fi

echo -e "${GREEN}[✔] Сканирование завершено.${RESET}"

#!/bin/bash
#autor: from YuryA www.uar@gmail.com
#create: for SPbf-Kbf-SPmd

# Проверяем, установлены ли необходимые утилиты
if ! command -v dialog &> /dev/null || ! command -v sshpass &> /dev/null || ! command -v firefox &> /dev/null; then
    clear
    echo "ОШИБКА"
    echo "Не найдены один или несколько пакетов для выполнения команд"
    echo "Установите dialog, sshpass и firefox для работы скрипта:"
    echo "sudo apt install dialog sshpass firefox"
    exit 1
fi

# Серверы с описаниями
declare -A SERVERS=(
    ["192.168.0.10"]="server0 (бухгалтерия 2-й этаж)"
    ["192.168.0.11"]="server1 (столовая цокольный этаж)"
    ["192.168.0.12"]="server2 (кадры 3-й этаж)"
    ["192.168.0.13"]="server3 (сервер СОЭН)"
    ["192.168.0.14"]="server4 (сервер СКУД)"
    ["192.168.0.15"]="server5 (сервер СОС)"
)

# Пароль и пользователь
PASSWORD='Password123'
SSH_USER="admin"

# Функция проверки статуса LSA
check_lsa_active() {
    local ip=$1
    local status=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $SSH_USER@"$ip" "sudo systemctl is-active LsiSASH 2>/dev/null")
    [[ "$status" == "active" ]]
}

# Подготовка меню для dialog
menu_items=()
for ip in "${!SERVERS[@]}"; do
    menu_items+=("$ip" "${SERVERS[$ip]}")
done

# Диалог выбора сервера
IP=$(dialog --clear \
            --backtitle "Управление LSA на серверах предприятия" \
            --title "Выбор сервера" \
            --menu "Выберите сервер для управления:" \
            15 60 6 \
            "${menu_items[@]}" \
            2>&1 >/dev/tty)

# Проверка выбора
if [ -z "$IP" ]; then
    clear
    echo "Выбор сервера отменен"
    exit 0
fi

clear
echo "========================================"
echo " Выбран сервер: ${SERVERS[$IP]}"
echo " IP-адрес: $IP"
echo "========================================"


# Проверка доступности
echo -n "Проверка доступности сервера... "
if ! ping -c 3 -W 1 "$IP" &>/dev/null; then
    echo "ОШИБКА"
    echo "Сервер $IP недоступен!"
    exit 1
fi
echo "OK"

# Запуск LSA
echo -n "Запуск LSA... "
if ! sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $SSH_USER@"$IP" "sudo systemctl start LsiSASH"; then
    echo "ОШИБКА"
    echo "Не удалось запустить LSA на сервере!"
    exit 1
fi

# Ожидание загрузки службы
echo -n "Ожидание загрузки LSA."
TIMEOUT=30
while ! check_lsa_active "$IP" && (( TIMEOUT-- > 0 )); do
    echo -n "."
    sleep 1
done

if ! check_lsa_active "$IP"; then
    echo " ОШИБКА"
    echo "Служба LsiSASH не запустилась за 30 секунд!"
    exit 1
fi
echo " OK"

# Запуск Firefox
echo -n "Запуск браузера... "
FF_PROFILE=$(mktemp -d)
firefox --no-remote --new-instance --profile "$FF_PROFILE" --new-window --start-maximized "http://$IP:2463" &>/dev/null &
FF_PID=$!
echo "OK (PID: $FF_PID)"
echo "========================================"
echo " Интерфейс LSA открыт в браузере"
echo " Закройте окно браузера для остановки LSA"
echo "========================================"

# Ожидание закрытия Firefox
while kill -0 $FF_PID 2>/dev/null; do
    sleep 2
done

# Остановка LSA
echo -n "Остановка LSA... "
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $SSH_USER@"$IP" "sudo systemctl stop LsiSASH"
echo "OK"

# Очистка
rm -rf "$FF_PROFILE"
echo "Работа завершена"

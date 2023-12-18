#!/bin/bash

# Функция для преобразования размера в человекочитаемый формат
human_readable_size() {
    local size=$1
    local suffixes=("B" "KB" "MB" "GB" "TB" "PB" "EB" "ZB" "YB")
    local i=0

    while [ $size -ge 1024 ] && [ $i -lt ${#suffixes[@]} ]; do
        size=$(($size / 1024))
        ((i++))
    done

    echo "$size${suffixes[$i]}"
}

# Вывод справки
show_help() {
    echo "Формат вызова: $0 [--help] [-h] [-N N] [-s minsize] [--] [dir...]"
    echo "Параметры:"
    echo "  --help  Вывод справки о формате вызова и завершение программы"
    echo "  -h      Вывод размера в человекочитаемом формате"
    echo "  -N N    Количество файлов для вывода (если не указано, выводятся все файлы)"
    echo "  -s      Минимальный размер файла для учёта"
    echo "  dir...  Каталог(и) поиска (если не указаны, используется текущий каталог)"
    echo "Примеры использования:"
    echo "  $0 -N 5 -s 1024 -- /path/to/directory"
    echo "  $0 -h -s 4096"
}

# Парсинг аргументов командной строки
while [ $# -gt 0 ]; do
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        -h)
            human_readable=true
            shift
            ;;
        -N)
            N="$2"
            shift 2
            ;;
        -s)
            minsize="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Ошибка: Некорректный аргумент: $1"
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

# Установка значений по умолчанию, если не заданы
N="${N:--1}"
minsize="${minsize:-1}"

# Получение списка файлов и вывод топа
file_list=$(find "${@:-.}" -type f -size +"$minsize"c -exec stat -c '%s %n' {} + | sort -rn)

# Проверка наличия опции -N и применение head
if [ "$N" -eq -1 ]; then
    for entry in $file_list; do
        if [ "$human_readable" ]; then
            size=$(echo "$entry" | awk '{print $1}')
            size=$(human_readable_size "$size")
            echo "$size $(echo "$entry" | cut -f2- -d' ')"
        else
            echo "$entry"
        fi
    done
else
    for entry in $(echo "$file_list" | head -n "$N"); do
        if [ "$human_readable" ]; then
            size=$(echo "$entry" | awk '{print $1}')
            size=$(human_readable_size "$size")
            echo "$size $(echo "$entry" | cut -f2- -d' ')"
        else
            echo "$entry"
        fi
    done
fi

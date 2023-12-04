#!/bin/sh

# Парсинг аргументов командной строки
while [ $# -gt 0 ]; do
    case "$1" in
        -N)
            N="$2"
            shift 2
            ;;
        -s|--minsize)
            minsize="$2"
            shift 2
            ;;
        -h)
            human_readable="-h"
            shift
            ;;
        --help)
            echo "Формат вызова: $0 [-N] [-s minsize] [-h] [--] [dir...]"
            exit 0
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
human_readable="${human_readable:--d}"

# Получение списка файлов и вывод топа
find "${@:-.}" -type f -size +"$minsize"c -exec stat -c '%s %n' {} + | sort -rn | head -n "$N"

#!/bin/bash

# Функция для вывода справки
print_help() {
  echo "Использование: $0 [ОПЦИИ] суффикс файл1 [файл2 ...]"
  echo "Опции:"
  echo "  -h        Вывести справку"
  echo "  -d        Пробный запуск: показать исходные и новые имена файлов без переименования"
  echo "  -v        Режим отладки: показывать имена переименовываемых файлов"
}

# Переменные по умолчанию
dry_run=false
verbose=false

# Обработка опций
while getopts "hdv" opt; do
  case $opt in
    h)
      print_help
      exit 0
      ;;
    d)
      dry_run=true
      ;;
    v)
      verbose=true
      ;;
    \?)
      echo "Неверная опция: -$OPTARG" >&2
      print_help
      exit 1
      ;;
  esac
done

# Сдвигаем аргументы до первого неопционального параметра
shift "$((OPTIND - 1))"

# Проверяем, что суффикс указан
if [ -z "$1" ]; then
  echo "Ошибка: Суффикс не указан." >&2
  print_help
  exit 1
fi

suffix="$1"
shift

# Проверяем, что указан хотя бы один файл
if [ "$#" -lt 1 ]; then
  echo "Ошибка: Нет указанных файлов для переименования." >&2
  print_help
  exit 1
fi

# Переименовываем файлы
for file in "$@"; do
  if [ ! -e "$file" ]; then
    echo "Ошибка: Файл '$file' не найден." >&2
    continue
  fi

  # Создаем новое имя файла с учетом суффикса
  new_name="${file%.*}$suffix.${file##*.}"

  # Выводим информацию о переименовании, если включен режим отладки
  if [ "$verbose" = true ]; then
    echo "Переименование: $file -> $new_name"
  fi

  # Переименовываем файл, если не включен пробный запуск
  if [ "$dry_run" = false ]; then
    mv -v "$file" "$new_name"
  fi
done

exit 0

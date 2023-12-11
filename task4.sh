#!/bin/bash

# Функция вывода сообщения об ошибке и выхода
error_exit() {
  echo "Error: $1" >&2
  exit 1
}

# Функция для вывода справки
print_help() {
  cat << EOF
Usage: $0 [OPTIONS] suffix file1 [file2 ...]
Options:
  -h            Display this help message
  -d            Dry run: Display original and new file names without renaming
  -v            Verbose mode: Display file names being renamed
Examples:
  $0 -d -v sfx file1.txt file2.doc
EOF
}

# Обработка параметров командной строки
while getopts ":hdv" opt; do
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
      error_exit "Invalid option: -$OPTARG"
      ;;
  esac
done

# Сдвигаем опции
shift $((OPTIND-1))

# Проверяем наличие суффикса и списка файлов
[ $# -lt 2 ] && error_exit "Missing suffix or file list. Use -h for help."

# Получаем суффикс
suffix=$1
shift

# Переименование файлов
for file in "$@"; do
  # Проверяем существование файла
  [ -e "$file" ] || error_exit "File not found: $file"

  # Получаем имя файла и расширение
  filename="${file%.*}"
  extension="${file##*.}"

  # Формируем новое имя файла
  new_name="${filename}${suffix}.${extension}"

  # Выводим имена файлов при необходимости
  [ "$verbose" = true ] && echo "Renaming: $file -> $new_name"

  # Переименовываем или выводим информацию при "сухом запуске"
  if [ "$dry_run" = false ]; then
    mv -i "$file" "$new_name" || error_exit "Unable to rename $file"
  else
    echo "Dry Run: $file -> $new_name"
  fi
done

exit 0


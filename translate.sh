#!/usr/bin/env bash

set -eu # European Union mode activated

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

finish() {
  rm -rf "${DIR}/parts"
}

trap finish EXIT

mkdir -p "${DIR}/parts"

declare -r PATH_TO_PDFS="${1:-$(pwd)}"
declare -r LANGUAGE="${2:-en}"

while read -r PDF_FILE_PATH; do
   declare PDF_FILE_PATH_ENCODED="$(base64 <<< "${PDF_FILE_PATH}")"
   declare PARTS_FOLDER="${DIR}/parts/${PDF_FILE_PATH_ENCODED}"
   declare BASE_NAME="$(basename "$PDF_FILE_PATH" ".pdf")"
   declare DIR_NAME="$(dirname "$PDF_FILE_PATH")"
   declare OUTPUT_PATH="${DIR_NAME}/${BASE_NAME}.${LANGUAGE}.pdf"

   rm -rf "${PARTS_FOLDER}"
   mkdir -p "${PARTS_FOLDER}"
   gs -o "${PARTS_FOLDER}/no_images.pdf" -sDEVICE=pdfwrite -dFILTERIMAGE "${PDF_FILE_PATH}" > /dev/null
   pdfseparate "${PARTS_FOLDER}/no_images.pdf" "${PARTS_FOLDER}/%d.part.pdf"

   while read -r PDF_PART_FILE_PATH; do
       node "${DIR}/index.js" "${PDF_PART_FILE_PATH}" "${LANGUAGE}"
   done < <(find "${PARTS_FOLDER}" -type f -name "*.part.pdf")

   pdfunite $(find "${PARTS_FOLDER}" -type f -name "*.translated.pdf" -exec basename {} + | sort -n -t . -k 1 | sed "s#^#${PARTS_FOLDER}/#") "${OUTPUT_PATH}"
   echo "${OUTPUT_PATH}"
done < <(find "${PATH_TO_PDFS}" -type f -name "*.pdf" | grep -v ".${LANGUAGE}.pdf")


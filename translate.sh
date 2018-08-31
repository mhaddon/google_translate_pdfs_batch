#!/usr/bin/env bash

set -eu # European Union mode activated

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

finish() {
  rm -rf "${DIR}/parts"
}

trap finish EXIT

mkdir -p "${DIR}/parts"

declare -r PATH_TO_PDFS=${1:-$(pwd)}
declare -r LANGUAGE=${2:-en}

while read -r PDF_FILE_PATH; do
   declare PDF_FILE_PATH_ENCODED="$(base64 <<< ${PDF_FILE_PATH})"
   declare PARTS_FOLDER="${DIR}/parts/${PDF_FILE_PATH_ENCODED}"
   declare BASE_NAME="$(basename "$PDF_FILE_PATH" ".pdf")"
   declare DIR_NAME="$(dirname "$PDF_FILE_PATH")"
   declare OUTPUT_PATH="${DIR_NAME}/${BASE_NAME}.${LANGUAGE}.pdf"

   rm -rf "${PARTS_FOLDER}"
   mkdir -p "${PARTS_FOLDER}"
   pdfseparate "${PDF_FILE_PATH}" "${PARTS_FOLDER}/%d.part.pdf"

   while read -r PDF_PART_FILE_PATH; do
       node "${DIR}/index.js" "${PDF_PART_FILE_PATH}" "${LANGUAGE}"
   done < <(find "${PARTS_FOLDER}" -type f -name "*.part.pdf" | xargs -n1)

   pdfunite $(find "${PARTS_FOLDER}" -type f -name "*.translated.pdf") "${OUTPUT_PATH}"
   echo "${OUTPUT_PATH}"
done < <(find "${PATH_TO_PDFS}" -type f -name "*.pdf" | grep -v ".${LANGUAGE}.pdf" | xargs -n1)

